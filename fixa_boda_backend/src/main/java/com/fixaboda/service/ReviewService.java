package com.fixaboda.service;

import com.fixaboda.entity.Review;
import com.fixaboda.repository.ReviewRepository;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;

    public ReviewService(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    public Review createReview(Review review) {
        return reviewRepository.save(review);
    }

    public List<Review> getReviewsForMechanic(Long mechanicId) {
        return reviewRepository.findByMechanicId(mechanicId);
    }

    public double getAverageRating(Long mechanicId) {
        List<Review> reviews = reviewRepository.findByMechanicId(mechanicId);
        if (reviews.isEmpty()) {
            return 4.8;
        }
        return reviews.stream().mapToDouble(Review::getRating).average().orElse(4.8);
    }
}
