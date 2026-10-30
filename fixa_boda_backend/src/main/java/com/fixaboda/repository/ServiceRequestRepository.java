package com.fixaboda.repository;

import com.fixaboda.entity.RequestStatus;
import com.fixaboda.entity.ServiceRequest;
import com.fixaboda.entity.User;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ServiceRequestRepository extends JpaRepository<ServiceRequest, Long> {
    List<ServiceRequest> findByRider(User rider);
    List<ServiceRequest> findByMechanic(User mechanic);
    List<ServiceRequest> findByStatus(RequestStatus status);
}
