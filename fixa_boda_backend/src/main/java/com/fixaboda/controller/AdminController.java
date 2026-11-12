package com.fixaboda.controller;

import com.fixaboda.entity.AccountStatus;
import com.fixaboda.entity.RoleName;
import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.User;
import com.fixaboda.service.ServiceRequestService;
import com.fixaboda.service.UserService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UserService userService;
    private final ServiceRequestService serviceRequestService;

    public AdminController(UserService userService, ServiceRequestService serviceRequestService) {
        this.userService = userService;
        this.serviceRequestService = serviceRequestService;
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

    @GetMapping("/dashboard/summary")
    public ResponseEntity<Map<String, Object>> getSummary() {
        Map<String, Object> summary = new HashMap<>();
        List<User> riders = userService.getUsersByRole(RoleName.RIDER);
        List<User> mechanics = userService.getUsersByRole(RoleName.MECHANIC);

        summary.put("riders", riders.size());
        summary.put("mechanics", mechanics.size());
        summary.put("verifiedMechanics", (int) mechanics.stream().filter(user -> user.getMechanicProfile() != null && user.getMechanicProfile().isVerified()).count());
        summary.put("availableMechanics", (int) mechanics.stream().filter(user -> user.getMechanicProfile() != null && user.getMechanicProfile().isAvailable()).count());
        summary.put("openRequests", serviceRequestService.getRequestsByStatus(RequestStatus.PENDING).size());
        summary.put("acceptedRequests", serviceRequestService.getRequestsByStatus(RequestStatus.ACCEPTED).size());
        summary.put("completedRequests", serviceRequestService.getRequestsByStatus(RequestStatus.COMPLETED).size());
        return ResponseEntity.ok(summary);
    }
}
