package com.fixaboda.controller;

import com.fixaboda.entity.ChatMessage;
import com.fixaboda.service.ChatMessageService;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ChatController {

    private final ChatMessageService chatMessageService;

    public ChatController(ChatMessageService chatMessageService) {
        this.chatMessageService = chatMessageService;
    }

    @PostMapping("/requests/messages")
    public ResponseEntity<ChatMessage> sendMessage(@RequestBody ChatMessage message) {
        return ResponseEntity.ok(chatMessageService.sendMessage(message));
    }

    @GetMapping("/requests/{requestId}/messages")
    public ResponseEntity<List<ChatMessage>> getMessages(@PathVariable Long requestId) {
        return ResponseEntity.ok(chatMessageService.getMessages(requestId));
    }
}
