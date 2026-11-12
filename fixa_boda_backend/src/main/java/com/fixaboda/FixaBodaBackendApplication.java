package com.fixaboda;

import com.fixaboda.config.AppConfig;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Import;

@SpringBootApplication(scanBasePackages = "com.fixaboda")
@Import(AppConfig.class)
public class FixaBodaBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(FixaBodaBackendApplication.class, args);
    }
}
