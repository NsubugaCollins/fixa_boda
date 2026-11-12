package com.fixaboda.controller;

import com.fixaboda.entity.Review;
import com.fixaboda.service.ReviewService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @PostMapping("/reviews")
    public ResponseEntity<Review> createReview(@RequestBody Review review) {
        return ResponseEntity.ok(reviewService.createReview(review));
    }

    @GetMapping("/mechanics/{mechanicId}/reviews")
    public ResponseEntity<List<Review>> getMechanicReviews(@PathVariable Long mechanicId) {
        return ResponseEntity.ok(reviewService.getReviewsForMechanic(mechanicId));
    }

    @GetMapping("/mechanics/{mechanicId}/rating")
    public ResponseEntity<Double> getMechanicRating(@PathVariable Long mechanicId) {
        return ResponseEntity.ok(reviewService.getAverageRating(mechanicId));
    }
}
