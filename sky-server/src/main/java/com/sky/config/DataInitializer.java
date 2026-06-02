package com.sky.config;

import com.sky.entity.Employee;
import com.sky.mapper.EmployeeMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.time.LocalDateTime;

@Component
@Slf4j
public class DataInitializer implements CommandLineRunner {

    @Resource
    private EmployeeMapper employeeMapper;

    @Override
    public void run(String... args) throws Exception {
        Employee admin = employeeMapper.getByUsername("admin");
        if (admin != null) {
            String currentPassword = admin.getPassword();
            if (!currentPassword.startsWith("$2a$") && !currentPassword.startsWith("$2b$") && !currentPassword.startsWith("$2y$")) {
                BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
                String encodedPassword = encoder.encode(currentPassword);
                admin.setPassword(encodedPassword);
                admin.setUpdateTime(LocalDateTime.now());
                admin.setUpdateUser(1L);
                
                employeeMapper.update(admin);
                log.info("已将 admin 用户的密码更新为 BCrypt 加密格式");
            }
        }
    }
}