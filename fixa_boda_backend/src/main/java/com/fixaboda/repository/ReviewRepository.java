package com.fixaboda.repository;

import com.fixaboda.entity.Review;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByMechanicId(Long mechanicId);
    List<Review> findByRequestId(Long requestId);
}
