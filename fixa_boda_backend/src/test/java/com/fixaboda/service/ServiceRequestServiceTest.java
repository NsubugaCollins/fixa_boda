package com.fixaboda.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import com.fixaboda.dto.ServiceRequestDto;
import com.fixaboda.entity.MechanicProfile;
import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.RoleName;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.entity.User;
import com.fixaboda.repository.ServiceRequestRepository;
import com.fixaboda.repository.UserRepository;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.junit.jupiter.api.Test;

class ServiceRequestServiceTest {

    @Test
    void createRequestShouldAssignMechanicAndPickupLocation() {
        ServiceRequestRepository requestRepository = mock(ServiceRequestRepository.class);
        UserRepository userRepository = mock(UserRepository.class);
        ServiceRequestService service = new ServiceRequestService(requestRepository, userRepository);

        User rider = new User();
        rider.setId(10L);
        rider.setFirstName("Rider");
        rider.setLastName("One");

        User mechanic = new User();
        mechanic.setId(22L);
        mechanic.setFirstName("Kato");
        mechanic.setLastName("Motors");

        when(userRepository.findById(10L)).thenReturn(Optional.of(rider));
        when(userRepository.findById(22L)).thenReturn(Optional.of(mechanic));
        when(requestRepository.save(any(ServiceRequest.class))).thenAnswer(invocation -> {
            ServiceRequest request = invocation.getArgument(0);
            request.setId(99L);
            return request;
        });

        ServiceRequestDto dto = new ServiceRequestDto();
        dto.setRiderId(10L);
        dto.setMechanicId(22L);
        dto.setRequestType("Flat tyre");
        dto.setDescription("Need roadside help");
        dto.setLocation("Wandegeya, Kampala");
        dto.setDestinationLocation("Kampala Road");
        dto.setEstimatedCost(new BigDecimal("20000"));

        ServiceRequest saved = service.createRequest(dto);

        assertEquals(mechanic, saved.getMechanic());
        assertEquals("Wandegeya, Kampala", saved.getPickupLocation());
        assertEquals("Kampala Road", saved.getDestinationLocation());
        assertEquals(RequestStatus.PENDING, saved.getStatus());
    }

    @Test
    void getNearbyMechanicsShouldPrioritizeAvailableVerifiedMechanics() {
        ServiceRequestRepository requestRepository = mock(ServiceRequestRepository.class);
        UserRepository userRepository = mock(UserRepository.class);
        ServiceRequestService service = new ServiceRequestService(requestRepository, userRepository);

        User offline = createMechanic(1L, "Offline", "One", false, true, 3.0);
        User available = createMechanic(2L, "Kato", "Motors", true, true, 4.9);
        User verifiedButBusy = createMechanic(3L, "Busy", "Garage", true, true, 4.4);
        User unverified = createMechanic(4L, "New", "Garage", true, false, 4.8);

        when(userRepository.findByRole(RoleName.MECHANIC)).thenReturn(List.of(offline, available, verifiedButBusy, unverified));

        List<Map<String, Object>> nearby = service.getNearbyMechanics();

        assertEquals(2L, ((Number) nearby.get(0).get("id")).longValue());
        assertEquals(3L, ((Number) nearby.get(1).get("id")).longValue());
        assertEquals(4L, ((Number) nearby.get(2).get("id")).longValue());
        assertEquals(1L, ((Number) nearby.get(3).get("id")).longValue());
    }

    @Test
    void getNearbyMechanicsShouldComputeRealGpsDistanceAndEta() {
        ServiceRequestRepository requestRepository = mock(ServiceRequestRepository.class);
        UserRepository userRepository = mock(UserRepository.class);
        ServiceRequestService service = new ServiceRequestService(requestRepository, userRepository);

        User closeMechanic = createMechanic(10L, "Near", "Garage", true, true, 4.9);
        closeMechanic.getMechanicProfile().setLatitude(0.3476);
        closeMechanic.getMechanicProfile().setLongitude(32.5825);

        User farMechanic = createMechanic(11L, "Far", "Garage", true, true, 4.7);
        farMechanic.getMechanicProfile().setLatitude(0.3600);
        farMechanic.getMechanicProfile().setLongitude(32.6100);

        when(userRepository.findByRole(RoleName.MECHANIC)).thenReturn(List.of(closeMechanic, farMechanic));

        List<Map<String, Object>> nearby = service.getNearbyMechanics(0.3430, 32.5770);

        assertEquals(10L, ((Number) nearby.get(0).get("id")).longValue());
        assertTrue(((Number) nearby.get(0).get("distanceKm")).doubleValue() > 0.0);
        assertTrue(((Number) nearby.get(0).get("etaMinutes")).intValue() > 0);
        assertTrue(((Number) nearby.get(1).get("distanceKm")).doubleValue() > ((Number) nearby.get(0).get("distanceKm")).doubleValue());
    }

    private User createMechanic(Long id, String firstName, String lastName, boolean available, boolean verified, double rating) {
        User user = new User();
        user.setId(id);
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setRole(RoleName.MECHANIC);

        MechanicProfile profile = new MechanicProfile();
        profile.setUser(user);
        profile.setAvailable(available);
        profile.setVerified(verified);
        profile.setRating(rating);
        profile.setServiceRadiusKm(5.0);
        user.setMechanicProfile(profile);
        return user;
    }
}
