package com.fixaboda.service;

import com.fixaboda.dto.ServiceRequestDto;
import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.RequestType;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.entity.User;
import com.fixaboda.repository.ServiceRequestRepository;
import com.fixaboda.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class ServiceRequestService {

    private final ServiceRequestRepository serviceRequestRepository;
    private final UserRepository userRepository;

    public ServiceRequestService(ServiceRequestRepository serviceRequestRepository, UserRepository userRepository) {
        this.serviceRequestRepository = serviceRequestRepository;
        this.userRepository = userRepository;
    }

    public ServiceRequest createRequest(ServiceRequestDto dto) {
        User rider = userRepository.findById(dto.getRiderId())
                .orElseThrow(() -> new IllegalArgumentException("Rider not found"));

        ServiceRequest request = new ServiceRequest();
        request.setRider(rider);
        request.setRequestType(RequestType.valueOf(dto.getRequestType().toUpperCase()));
        request.setDescription(dto.getDescription());
        request.setPickupLocation(dto.getPickupLocation());
        request.setDestinationLocation(dto.getDestinationLocation());
        request.setEstimatedCost(dto.getEstimatedCost());
        request.setStatus(RequestStatus.PENDING);
        request.setCreatedAt(LocalDateTime.now());
        request.setUpdatedAt(LocalDateTime.now());

        return serviceRequestRepository.save(request);
    }

    public List<ServiceRequest> getRequestsByRider(Long riderId) {
        User rider = userRepository.findById(riderId)
                .orElseThrow(() -> new IllegalArgumentException("Rider not found"));
        return serviceRequestRepository.findByRider(rider);
    }

    public List<ServiceRequest> getRequestsByMechanic(Long mechanicId) {
        User mechanic = userRepository.findById(mechanicId)
                .orElseThrow(() -> new IllegalArgumentException("Mechanic not found"));
        return serviceRequestRepository.findByMechanic(mechanic);
    }

    public Optional<ServiceRequest> getRequestById(Long requestId) {
        return serviceRequestRepository.findById(requestId);
    }

    public ServiceRequest acceptRequest(Long requestId, Long mechanicId) {
        ServiceRequest request = serviceRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));
        User mechanic = userRepository.findById(mechanicId)
                .orElseThrow(() -> new IllegalArgumentException("Mechanic not found"));

        request.setMechanic(mechanic);
        request.setStatus(RequestStatus.ACCEPTED);
        request.setUpdatedAt(LocalDateTime.now());
        return serviceRequestRepository.save(request);
    }

    public ServiceRequest updateRequestStatus(Long requestId, RequestStatus status) {
        ServiceRequest request = serviceRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));
        request.setStatus(status);
        request.setUpdatedAt(LocalDateTime.now());
        return serviceRequestRepository.save(request);
    }
}
