# Generate Metrics Collector

Generate a new metrics collector component for the MOAO11y Observability Framework.

## Task

Create a new metrics collector class that integrates with the MOAAgent system to collect observability data from specified sources.

## Requirements

1. **Collector Class**
   - Create a new Java class in `MOAAgent/src/main/java/com/moao11y/agent/collector/`
   - Implement proper Spring Boot component annotations
   - Follow existing collector patterns

2. **Configuration**
   - Add necessary configuration properties to `application.yml`
   - Support environment-specific settings (dev, stg, live)
   - Include enable/disable toggle

3. **Metrics Format**
   - Follow Prometheus metrics format
   - Include proper labels and tags
   - Support time-series data

4. **Error Handling**
   - Implement retry logic
   - Add circuit breaker pattern
   - Log errors appropriately

5. **Testing**
   - Create unit tests
   - Add integration tests
   - Mock external dependencies

6. **Documentation**
   - Add JavaDoc comments
   - Update README if needed
   - Document configuration options

## Supported Collector Types

- **OS Metrics**: CPU, Memory, Disk, Network
- **RabbitMQ Metrics**: Queue depth, message rates, connections
- **MySQL Metrics**: Queries, connections, replication lag
- **Spring Actuator**: Health, metrics endpoints
- **PM2 Metrics**: Process status, resource usage

## Steps

1. Ask the user what type of metrics collector to generate
2. Create the collector class with proper structure
3. Add configuration properties
4. Implement collection logic
5. Add error handling
6. Create tests
7. Update documentation

## Example Structure

```java
@Component
@ConditionalOnProperty(name = "moao11y.collector.{type}.enabled", havingValue = "true")
public class {Type}MetricsCollector implements MetricsCollector {

    private final {Type}Client client;
    private final MetricsRegistry registry;

    @Scheduled(fixedDelayString = "${moao11y.collector.{type}.interval}")
    public void collect() {
        // Collection logic
    }
}
```

Please proceed with generating the metrics collector based on user input.