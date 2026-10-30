package com.fixaboda.controller;

import com.fixaboda.entity.AccountStatus;
import com.fixaboda.entity.RoleName;
import com.fixaboda.entity.User;
import com.fixaboda.service.UserService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserService userService;

    public AdminController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/users")
    public ResponseEntity<List<User>> getUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/users/role/{role}")
    public ResponseEntity<List<User>> getUsersByRole(@PathVariable String role) {
        return ResponseEntity.ok(userService.getUsersByRole(RoleName.valueOf(role.toUpperCase())));
    }

    @PutMapping("/users/{id}/status")
    public ResponseEntity<Void> updateUserStatus(@PathVariable Long id, @RequestParam String status) {
        userService.updateUserStatus(id, AccountStatus.valueOf(status.toUpperCase()));
        return ResponseEntity.ok().build();
    }
}
