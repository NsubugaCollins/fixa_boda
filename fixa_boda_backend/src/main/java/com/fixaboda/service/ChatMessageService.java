package com.fixaboda.service;

import com.fixaboda.entity.ChatMessage;
import com.fixaboda.repository.ChatMessageRepository;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class ChatMessageService {

    private final ChatMessageRepository chatMessageRepository;

    public ChatMessageService(ChatMessageRepository chatMessageRepository) {
        this.chatMessageRepository = chatMessageRepository;
    }

    public ChatMessage sendMessage(ChatMessage message) {
        return chatMessageRepository.save(message);
    }

    public List<ChatMessage> getMessages(Long requestId) {
        return chatMessageRepository.findByRequestIdOrderByCreatedAtAsc(requestId);
    }
}
