package com.fixaboda.entity;

import java.util.List;
import org.springframework.security.core.authority.SimpleGrantedAuthority;

public enum RoleName {
    RIDER,
    MECHANIC,
    ADMIN;

    public List<SimpleGrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + this.name()));
    }
}
