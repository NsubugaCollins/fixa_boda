package com.fixaboda.repository;

import com.fixaboda.entity.ChatMessage;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByRequestIdOrderByCreatedAtAsc(Long requestId);
}
