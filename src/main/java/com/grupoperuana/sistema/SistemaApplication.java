package com.grupoperuana.sistema;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class SistemaApplication extends SpringBootServletInitializer {

	public static void main(String[] args) {
		SpringApplication.run(SistemaApplication.class, args);
	}

}
