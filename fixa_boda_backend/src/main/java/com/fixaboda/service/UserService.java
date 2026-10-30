package com.fixaboda.service;

import com.fixaboda.entity.AccountStatus;
import com.fixaboda.entity.RoleName;
import com.fixaboda.entity.User;
import com.fixaboda.repository.UserRepository;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    public List<User> getUsersByRole(RoleName role) {
        return userRepository.findByRole(role);
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public User saveUser(User user) {
        return userRepository.save(user);
    }

    public void updateUserStatus(Long id, AccountStatus status) {
        userRepository.updateUserStatus(id, status);
    }
}
