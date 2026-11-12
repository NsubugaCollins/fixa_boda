package com.fixaboda.service;

import com.fixaboda.dto.ServiceRequestDto;
import com.fixaboda.entity.MechanicProfile;
import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.RequestType;
import com.fixaboda.entity.RoleName;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.entity.User;
import com.fixaboda.repository.ServiceRequestRepository;
import com.fixaboda.repository.UserRepository;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class ServiceRequestService {

    public static final double DEFAULT_RIDER_LATITUDE = 0.3476;
    public static final double DEFAULT_RIDER_LONGITUDE = 32.5825;

    private final ServiceRequestRepository serviceRequestRepository;
    private final UserRepository userRepository;

    public ServiceRequestService(ServiceRequestRepository serviceRequestRepository, UserRepository userRepository) {
        this.serviceRequestRepository = serviceRequestRepository;
        this.userRepository = userRepository;
    }

    public ServiceRequest createRequest(ServiceRequestDto dto) {
        User rider = userRepository.findById(dto.getRiderId())
                .orElseThrow(() -> new IllegalArgumentException("Rider not found"));

        User mechanic = null;
        if (dto.getMechanicId() != null) {
            mechanic = userRepository.findById(dto.getMechanicId())
                    .orElseThrow(() -> new IllegalArgumentException("Mechanic not found"));
        }

        String normalizedType = dto.getRequestType() == null ? "OTHER" : dto.getRequestType().trim();
        normalizedType = normalizedType.replace('-', '_').replace(' ', '_').toUpperCase();

        String pickupLocation = dto.getPickupLocation() != null ? dto.getPickupLocation() : dto.getLocation();
        String destinationLocation = dto.getDestinationLocation() != null ? dto.getDestinationLocation() : pickupLocation;

        ServiceRequest request = new ServiceRequest();
        request.setRider(rider);
        request.setMechanic(mechanic);
        request.setRequestType(RequestType.valueOf(normalizedType));
        request.setDescription(dto.getDescription());
        request.setPickupLocation(pickupLocation != null ? pickupLocation : "Nearby service location");
        request.setDestinationLocation(destinationLocation != null ? destinationLocation : request.getPickupLocation());
        request.setEstimatedCost(dto.getEstimatedCost() != null ? dto.getEstimatedCost() : java.math.BigDecimal.ZERO);
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

    public List<ServiceRequest> getRequestsByStatus(RequestStatus status) {
        return serviceRequestRepository.findByStatus(status);
    }

    public Optional<ServiceRequest> getRequestById(Long requestId) {
        return serviceRequestRepository.findById(requestId);
    }

    public List<Map<String, Object>> getNearbyMechanics() {
        return getNearbyMechanics(DEFAULT_RIDER_LATITUDE, DEFAULT_RIDER_LONGITUDE);
    }

    public List<Map<String, Object>> getNearbyMechanics(double riderLatitude, double riderLongitude) {
        List<Map<String, Object>> mechanics = new ArrayList<>();
        for (User mechanic : userRepository.findByRole(RoleName.MECHANIC)) {
            MechanicProfile profile = mechanic.getMechanicProfile();
            Map<String, Object> entry = new HashMap<>();
            entry.put("id", mechanic.getId());
            entry.put("name", mechanic.getFirstName() + " " + mechanic.getLastName());
            entry.put("available", profile != null && profile.isAvailable());
            entry.put("verified", profile != null && profile.isVerified());
            entry.put("serviceRadiusKm", profile != null ? profile.getServiceRadiusKm() : 6.0);
            entry.put("rating", profile != null ? profile.getRating() : 4.8);
            entry.put("serviceArea", profile != null ? profile.getServiceArea() : "Kampala");
            entry.put("garageName", profile != null ? profile.getGarageName() : "Independent Garage");

            double mechanicLatitude = profile != null ? profile.getLatitude() : 0.0;
            double mechanicLongitude = profile != null ? profile.getLongitude() : 0.0;
            double distanceKm = calculateDistanceKm(riderLatitude, riderLongitude, mechanicLatitude, mechanicLongitude);
            double serviceRadius = profile != null ? profile.getServiceRadiusKm() : 6.0;

            entry.put("distanceKm", round(distanceKm));
            entry.put("etaMinutes", calculateEtaMinutes(distanceKm));
            entry.put("withinServiceRadius", distanceKm <= serviceRadius);
            entry.put("etaLabel", formatEta(calculateEtaMinutes(distanceKm)));
            mechanics.add(entry);
        }

        mechanics.sort((left, right) -> {
            boolean leftAvailable = Boolean.TRUE.equals(left.get("available"));
            boolean rightAvailable = Boolean.TRUE.equals(right.get("available"));
            if (leftAvailable != rightAvailable) {
                return Boolean.compare(rightAvailable, leftAvailable);
            }

            boolean leftVerified = Boolean.TRUE.equals(left.get("verified"));
            boolean rightVerified = Boolean.TRUE.equals(right.get("verified"));
            if (leftVerified != rightVerified) {
                return Boolean.compare(rightVerified, leftVerified);
            }

            boolean leftWithinRadius = Boolean.TRUE.equals(left.get("withinServiceRadius"));
            boolean rightWithinRadius = Boolean.TRUE.equals(right.get("withinServiceRadius"));
            if (leftWithinRadius != rightWithinRadius) {
                return Boolean.compare(rightWithinRadius, leftWithinRadius);
            }

            double leftDistance = ((Number) left.getOrDefault("distanceKm", 999.0)).doubleValue();
            double rightDistance = ((Number) right.getOrDefault("distanceKm", 999.0)).doubleValue();
            int distanceComparison = Double.compare(leftDistance, rightDistance);
            if (distanceComparison != 0) {
                return distanceComparison;
            }

            double leftRating = ((Number) left.getOrDefault("rating", 0.0)).doubleValue();
            double rightRating = ((Number) right.getOrDefault("rating", 0.0)).doubleValue();
            return Double.compare(rightRating, leftRating);
        });

        return mechanics;
    }

    private double calculateDistanceKm(double riderLatitude, double riderLongitude, double mechanicLatitude, double mechanicLongitude) {
        if (mechanicLatitude == 0.0 && mechanicLongitude == 0.0) {
            return 5.0;
        }

        final double earthRadiusKm = 6371.0;
        double latDistance = Math.toRadians(mechanicLatitude - riderLatitude);
        double lonDistance = Math.toRadians(mechanicLongitude - riderLongitude);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(riderLatitude)) * Math.cos(Math.toRadians(mechanicLatitude))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return Math.max(0.5, earthRadiusKm * c);
    }

    private double round(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private int calculateEtaMinutes(double distanceKm) {
        if (distanceKm <= 1.0) {
            return 4;
        }
        if (distanceKm <= 3.0) {
            return 7;
        }
        if (distanceKm <= 6.0) {
            return 12;
        }
        return (int) Math.max(16, Math.ceil(distanceKm * 2.5));
    }

    private String formatEta(int minutes) {
        return minutes + " min";
    }

    public MechanicProfile updateMechanicAvailability(Long mechanicId, boolean available) {
        User mechanic = userRepository.findById(mechanicId)
                .orElseThrow(() -> new IllegalArgumentException("Mechanic not found"));

        MechanicProfile profile = mechanic.getMechanicProfile();
        if (profile == null) {
            profile = new MechanicProfile();
            profile.setUser(mechanic);
        }
        profile.setAvailable(available);
        mechanic.setMechanicProfile(profile);
        userRepository.save(mechanic);
        return profile;
    }

    public MechanicProfile updateMechanicLocation(Long mechanicId, double latitude, double longitude) {
        User mechanic = userRepository.findById(mechanicId)
                .orElseThrow(() -> new IllegalArgumentException("Mechanic not found"));

        MechanicProfile profile = mechanic.getMechanicProfile();
        if (profile == null) {
            profile = new MechanicProfile();
            profile.setUser(mechanic);
        }
        profile.setLatitude(latitude);
        profile.setLongitude(longitude);
        mechanic.setMechanicProfile(profile);
        userRepository.save(mechanic);
        return profile;
    }

    public Map<String, Object> getLiveRouteSnapshot(Long requestId) {
        ServiceRequest request = serviceRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));

        User rider = request.getRider();
        User mechanic = request.getMechanic();
        double riderLatitude = rider != null && rider.getRiderProfile() != null && rider.getRiderProfile().getLatitude() != null
                ? rider.getRiderProfile().getLatitude()
                : DEFAULT_RIDER_LATITUDE;
        double riderLongitude = rider != null && rider.getRiderProfile() != null && rider.getRiderProfile().getLongitude() != null
                ? rider.getRiderProfile().getLongitude()
                : DEFAULT_RIDER_LONGITUDE;

        double mechanicLatitude = mechanic != null && mechanic.getMechanicProfile() != null
                ? mechanic.getMechanicProfile().getLatitude()
                : riderLatitude + 0.004;
        double mechanicLongitude = mechanic != null && mechanic.getMechanicProfile() != null
                ? mechanic.getMechanicProfile().getLongitude()
                : riderLongitude + 0.006;

        double distanceKm = calculateDistanceKm(riderLatitude, riderLongitude, mechanicLatitude, mechanicLongitude);
        Map<String, Object> payload = new HashMap<>();
        payload.put("requestId", requestId);
        payload.put("status", request.getStatus().name());
        payload.put("riderLatitude", riderLatitude);
        payload.put("riderLongitude", riderLongitude);
        payload.put("mechanicLatitude", mechanicLatitude);
        payload.put("mechanicLongitude", mechanicLongitude);
        payload.put("distanceKm", round(distanceKm));
        payload.put("etaMinutes", calculateEtaMinutes(distanceKm));
        return payload;
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
