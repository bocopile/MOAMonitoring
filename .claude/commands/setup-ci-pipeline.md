# Setup CI/CD Pipeline

Set up or update the CI/CD pipeline configuration for the MOAO11y project.

## Task

Create or update GitHub Actions workflow files to automate build, test, and deployment processes for both MOAAgent and MOAServer.

## Requirements

1. **Build Pipeline**
   - Java 11 setup
   - Gradle build for both modules
   - Dependency caching
   - Build artifact upload

2. **Test Pipeline**
   - Unit tests execution
   - Integration tests
   - Code coverage reporting (JaCoCo)
   - Test result publishing

3. **Quality Gates**
   - Code coverage threshold (>80%)
   - Checkstyle enforcement
   - Security scanning (Dependabot, Snyk)
   - Build success required

4. **Multi-Environment Support**
   - Development (auto-deploy on dev branch)
   - Staging (manual approval)
   - Production (tagged releases only)

5. **Notifications**
   - Build status to Slack/Teams
   - Failed build alerts
   - Deployment notifications

## Workflow Files to Create

### 1. `.github/workflows/build.yml`
- Trigger: Push to any branch
- Jobs: Build, Test, Quality Check

### 2. `.github/workflows/deploy-dev.yml`
- Trigger: Push to `dev` branch
- Jobs: Build, Test, Deploy to Dev

### 3. `.github/workflows/deploy-stg.yml`
- Trigger: Manual workflow dispatch
- Jobs: Build, Test, Deploy to Staging

### 4. `.github/workflows/deploy-live.yml`
- Trigger: Release tag created
- Jobs: Build, Test, Deploy to Production

## Template Structure

```yaml
name: Build and Test

on:
  push:
    branches: [ main, dev ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 11
        uses: actions/setup-java@v4
        with:
          java-version: '11'
          distribution: 'adoptium'

      - name: Cache Gradle packages
        uses: actions/cache@v3
        with:
          path: ~/.gradle/caches
          key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle') }}

      - name: Build with Gradle
        run: ./gradlew build

      - name: Run Tests
        run: ./gradlew test

      - name: Generate Coverage Report
        run: ./gradlew jacocoTestReport

      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

## Steps

1. Create `.github/workflows/` directory if not exists
2. Generate workflow files based on requirements
3. Configure secrets in GitHub repository
4. Set up environment-specific variables
5. Test the pipeline with a dummy commit
6. Document the CI/CD process in README

Please proceed with setting up the CI/CD pipeline.