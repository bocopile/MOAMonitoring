package com.moao11y.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * MOAServer Application
 * 메트릭 저장 및 처리 서버
 *
 * @author bocopile
 * @since 1.0.0
 */
@SpringBootApplication
@EnableScheduling
public class MOAServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(MOAServerApplication.class, args);
    }
}
