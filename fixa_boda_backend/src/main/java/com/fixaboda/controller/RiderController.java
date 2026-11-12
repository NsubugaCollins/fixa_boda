package com.fixaboda.controller;

import com.fixaboda.dto.ServiceRequestDto;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.service.ServiceRequestService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/rider")
@PreAuthorize("hasRole('RIDER')")
public class RiderController {

    private final ServiceRequestService serviceRequestService;

    public RiderController(ServiceRequestService serviceRequestService) {
        this.serviceRequestService = serviceRequestService;
    }

    @PostMapping("/requests")
    public ResponseEntity<ServiceRequest> createRequest(@RequestBody ServiceRequestDto dto) {
        return ResponseEntity.ok(serviceRequestService.createRequest(dto));
    }

    @GetMapping("/requests/{riderId}")
    public ResponseEntity<List<ServiceRequest>> getRequests(@PathVariable Long riderId) {
        return ResponseEntity.ok(serviceRequestService.getRequestsByRider(riderId));
    }

    @GetMapping("/requests/{riderId}/live")
    public ResponseEntity<List<java.util.Map<String, Object>>> getLiveRequests(@PathVariable Long riderId) {
        return ResponseEntity.ok(
                serviceRequestService.getRequestsByRider(riderId).stream()
                        .filter(request -> request.getMechanic() != null)
                        .map(request -> serviceRequestService.getLiveRouteSnapshot(request.getId()))
                        .toList()
        );
    }
}
