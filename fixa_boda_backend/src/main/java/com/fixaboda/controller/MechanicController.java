package com.fixaboda.controller;

import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.service.ServiceRequestService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mechanic")
@PreAuthorize("hasRole('MECHANIC')")
public class MechanicController {

    private final ServiceRequestService serviceRequestService;

    public MechanicController(ServiceRequestService serviceRequestService) {
        this.serviceRequestService = serviceRequestService;
    }

    @GetMapping("/requests/{mechanicId}")
    public ResponseEntity<List<ServiceRequest>> getRequests(@PathVariable Long mechanicId) {
        return ResponseEntity.ok(serviceRequestService.getRequestsByMechanic(mechanicId));
    }

    @PutMapping("/requests/{requestId}/accept/{mechanicId}")
    public ResponseEntity<ServiceRequest> acceptRequest(@PathVariable Long requestId, @PathVariable Long mechanicId) {
        return ResponseEntity.ok(serviceRequestService.acceptRequest(requestId, mechanicId));
    }

    @PutMapping("/requests/{requestId}/status")
    public ResponseEntity<ServiceRequest> updateStatus(@PathVariable Long requestId, @RequestParam String status) {
        return ResponseEntity.ok(serviceRequestService.updateRequestStatus(requestId, RequestStatus.valueOf(status.toUpperCase())));
    }
}
