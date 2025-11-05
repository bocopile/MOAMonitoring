package com.moao11y.agent;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * MOAAgent Application
 * 메트릭 수집 에이전트
 *
 * @author bocopile
 * @since 1.0.0
 */
@SpringBootApplication
@EnableScheduling
public class MOAAgentApplication {

    public static void main(String[] args) {
        SpringApplication.run(MOAAgentApplication.class, args);
    }
}
