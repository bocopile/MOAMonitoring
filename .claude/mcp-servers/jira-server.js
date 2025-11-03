#!/usr/bin/env node

/**
 * JIRA MCP Server
 * Provides JIRA integration through Model Context Protocol
 */

const https = require('https');
const { URL } = require('url');

// Read configuration from environment variables
const JIRA_BASE_URL = process.env.JIRA_BASE_URL;
const JIRA_USER_EMAIL = process.env.JIRA_USER_EMAIL;
const JIRA_API_TOKEN = process.env.JIRA_API_TOKEN;
const JIRA_PROJECT_KEY = process.env.JIRA_PROJECT_KEY;

// Validate configuration
if (!JIRA_BASE_URL || !JIRA_USER_EMAIL || !JIRA_API_TOKEN || !JIRA_PROJECT_KEY) {
  console.error('Error: Missing JIRA configuration. Please check your .env file.');
  process.exit(1);
}

// Basic auth header
const authHeader = 'Basic ' + Buffer.from(`${JIRA_USER_EMAIL}:${JIRA_API_TOKEN}`).toString('base64');

/**
 * Make JIRA API request
 */
function jiraRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, JIRA_BASE_URL);

    const options = {
      method: method,
      headers: {
        'Authorization': authHeader,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    };

    const req = https.request(url, options, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(body);
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(json);
          } else {
            reject(new Error(`JIRA API error: ${res.statusCode} - ${json.errorMessages || json.message || body}`));
          }
        } catch (e) {
          reject(new Error(`Failed to parse response: ${body}`));
        }
      });
    });

    req.on('error', reject);

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

/**
 * Create JIRA issue
 */
async function createIssue(summary, description, issueType = 'Task', priority = 'Medium') {
  const data = {
    fields: {
      project: { key: JIRA_PROJECT_KEY },
      summary: summary,
      description: {
        type: 'doc',
        version: 1,
        content: [{
          type: 'paragraph',
          content: [{
            type: 'text',
            text: description
          }]
        }]
      },
      issuetype: { name: issueType },
      priority: { name: priority }
    }
  };

  const result = await jiraRequest('POST', '/rest/api/3/issue', data);
  return {
    key: result.key,
    id: result.id,
    url: `${JIRA_BASE_URL}/browse/${result.key}`
  };
}

/**
 * Get JIRA issue
 */
async function getIssue(issueKey) {
  const result = await jiraRequest('GET', `/rest/api/3/issue/${issueKey}`);
  return {
    key: result.key,
    summary: result.fields.summary,
    status: result.fields.status.name,
    assignee: result.fields.assignee?.displayName || 'Unassigned',
    url: `${JIRA_BASE_URL}/browse/${result.key}`
  };
}

/**
 * Transition JIRA issue
 */
async function transitionIssue(issueKey, transitionName) {
  // Get available transitions
  const transitions = await jiraRequest('GET', `/rest/api/3/issue/${issueKey}/transitions`);
  const transition = transitions.transitions.find(t => t.name === transitionName);

  if (!transition) {
    throw new Error(`Transition '${transitionName}' not found. Available: ${transitions.transitions.map(t => t.name).join(', ')}`);
  }

  await jiraRequest('POST', `/rest/api/3/issue/${issueKey}/transitions`, {
    transition: { id: transition.id }
  });

  return { success: true, transitionName };
}

/**
 * Search JIRA issues
 */
async function searchIssues(jql, maxResults = 50) {
  const result = await jiraRequest('POST', '/rest/api/3/search', {
    jql: jql,
    maxResults: maxResults,
    fields: ['summary', 'status', 'assignee']
  });

  return result.issues.map(issue => ({
    key: issue.key,
    summary: issue.fields.summary,
    status: issue.fields.status.name,
    assignee: issue.fields.assignee?.displayName || 'Unassigned',
    url: `${JIRA_BASE_URL}/browse/${issue.key}`
  }));
}

/**
 * MCP Protocol Handler
 */
const tools = {
  create_jira_issue: {
    description: 'Create a new JIRA issue',
    parameters: {
      summary: { type: 'string', required: true },
      description: { type: 'string', required: true },
      issueType: { type: 'string', default: 'Task' },
      priority: { type: 'string', default: 'Medium' }
    },
    handler: createIssue
  },
  get_jira_issue: {
    description: 'Get JIRA issue details',
    parameters: {
      issueKey: { type: 'string', required: true }
    },
    handler: getIssue
  },
  transition_jira_issue: {
    description: 'Change JIRA issue status',
    parameters: {
      issueKey: { type: 'string', required: true },
      transitionName: { type: 'string', required: true }
    },
    handler: transitionIssue
  },
  search_jira_issues: {
    description: 'Search JIRA issues with JQL',
    parameters: {
      jql: { type: 'string', required: true },
      maxResults: { type: 'number', default: 50 }
    },
    handler: searchIssues
  }
};

// Simple MCP server implementation
async function handleRequest(request) {
  const { method, params } = request;

  if (method === 'tools/list') {
    return {
      tools: Object.entries(tools).map(([name, tool]) => ({
        name,
        description: tool.description,
        inputSchema: {
          type: 'object',
          properties: tool.parameters
        }
      }))
    };
  }

  if (method === 'tools/call') {
    const { name, arguments: args } = params;
    const tool = tools[name];

    if (!tool) {
      throw new Error(`Unknown tool: ${name}`);
    }

    try {
      const result = await tool.handler(...Object.values(args));
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(result, null, 2)
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: 'text',
          text: `Error: ${error.message}`
        }],
        isError: true
      };
    }
  }

  throw new Error(`Unknown method: ${method}`);
}

// Main
if (require.main === module) {
  console.log('JIRA MCP Server started');
  console.log(`Connected to: ${JIRA_BASE_URL}`);
  console.log(`Project: ${JIRA_PROJECT_KEY}`);

  // For testing purposes - in real MCP, this would listen to stdin/stdout
  // This is a simplified version for demonstration
  process.stdin.setEncoding('utf8');

  let buffer = '';
  process.stdin.on('data', async (chunk) => {
    buffer += chunk;
    const lines = buffer.split('\n');
    buffer = lines.pop();

    for (const line of lines) {
      if (line.trim()) {
        try {
          const request = JSON.parse(line);
          const response = await handleRequest(request);
          console.log(JSON.stringify({ id: request.id, result: response }));
        } catch (error) {
          console.log(JSON.stringify({ id: request.id, error: { message: error.message } }));
        }
      }
    }
  });
}

module.exports = { createIssue, getIssue, transitionIssue, searchIssues };
