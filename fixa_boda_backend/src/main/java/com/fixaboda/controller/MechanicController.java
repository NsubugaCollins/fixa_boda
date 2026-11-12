package com.fixaboda.controller;

import com.fixaboda.entity.MechanicProfile;
import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.service.ServiceRequestService;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

    @GetMapping("/nearby")
    public ResponseEntity<List<Map<String, Object>>> getNearbyMechanics(
            @RequestParam(required = false) Double latitude,
            @RequestParam(required = false) Double longitude) {
        double riderLatitude = latitude != null ? latitude : ServiceRequestService.DEFAULT_RIDER_LATITUDE;
        double riderLongitude = longitude != null ? longitude : ServiceRequestService.DEFAULT_RIDER_LONGITUDE;
        return ResponseEntity.ok(serviceRequestService.getNearbyMechanics(riderLatitude, riderLongitude));
    }

    @PutMapping("/{mechanicId}/availability")
    public ResponseEntity<Map<String, Object>> updateAvailability(@PathVariable Long mechanicId, @RequestParam boolean available) {
        MechanicProfile profile = serviceRequestService.updateMechanicAvailability(mechanicId, available);
        Map<String, Object> payload = new HashMap<>();
        payload.put("mechanicId", mechanicId);
        payload.put("available", profile.isAvailable());
        payload.put("verified", profile.isVerified());
        payload.put("serviceRadiusKm", profile.getServiceRadiusKm());
        return ResponseEntity.ok(payload);
    }

    @PutMapping("/{mechanicId}/location")
    public ResponseEntity<Map<String, Object>> updateLocation(
            @PathVariable Long mechanicId,
            @RequestParam double latitude,
            @RequestParam double longitude) {
        MechanicProfile profile = serviceRequestService.updateMechanicLocation(mechanicId, latitude, longitude);
        Map<String, Object> payload = new HashMap<>();
        payload.put("mechanicId", mechanicId);
        payload.put("latitude", profile.getLatitude());
        payload.put("longitude", profile.getLongitude());
        return ResponseEntity.ok(payload);
    }
}
