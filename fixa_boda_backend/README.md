# FixaBoda Backend

This project is a Java Spring MVC backend for the FixaBoda rider-mechanic marketplace. It includes authentication, role-based authorization, rider, mechanic, and admin APIs, and PostgreSQL persistence.

## Requirements

- Java 17+
- Maven 3.9+
- PostgreSQL 14+

## Local PostgreSQL setup

Create database:

```sql
CREATE DATABASE fixaboda;
```

Then update credentials in `src/main/resources/application.properties` if needed.

## Build

```bash
mvn clean package
```

## Run

Deploy the generated WAR to Tomcat or any servlet container.

For a local dev server, you can also run via a servlet container such as Tomcat 10 with this app deployed.

## API quick start

### Register rider

```http
POST /api/auth/register
Content-Type: application/json

{
  "firstName": "David",
  "lastName": "Ssemakula",
  "email": "david@example.com",
  "password": "secret123",
  "phoneNumber": "+256700000001",
  "role": "RIDER"
}
```

### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "david@example.com",
  "password": "secret123"
}
```

### Use token

```http
Authorization: Bearer <jwt-token>
```
