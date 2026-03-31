# Idempotent Request Processing Service (Ruby on Rails)

##  Overview

This project is a backend service built using Ruby on Rails that processes requests asynchronously while ensuring **idempotency**, **retry safety**, and **concurrency control**.

It simulates real-world backend challenges like duplicate requests, retries, failures, and cancellation handling.

---

##  Features

* Idempotent API using unique `idempotency_key`
* Background job processing using Sidekiq
* Retry mechanism with exponential backoff
* Concurrency-safe updates using DB locks
* Request cancellation support
* Failure handling and logging
* JSONB payload storage (PostgreSQL)

---

##  Architecture

```
Client → Rails API → Database (status: pending)
                    → Background Job (Sidekiq)
                    → Processing → Update Status
```

---

##  Key Design Decisions

### Idempotency

* Each request is uniquely identified by `idempotency_key`
* Duplicate requests return existing records

### Concurrency Handling

* Row-level locking using `with_lock`

### Retry Strategy

* Automatic retries for transient failures
* Avoid retries for validation/business errors

### Status Lifecycle

```
pending → processing → completed / failed / cancelled
```

---

##  Tech Stack

* Ruby on Rails
* PostgreSQL
* Sidekiq
* Redis

---

##  Setup Instructions

### 1. Clone Repository

```
git clone https://github.com/YOUR_USERNAME/rails-idempotent-service.git
cd rails-idempotent-service
```

### 2. Install Dependencies

```
bundle install
```

### 3. Setup Database

```
rails db:create
rails db:migrate
```

### 4. Start Services

```
redis-server
bundle exec sidekiq
rails server
```

---

##  API Endpoints

### Create Request

**POST /requests**

Request Body:

```json
{
  "idempotency_key": "abc-123",
  "payload": { "amount": 100 }
}
```

Responses:

* `202 Accepted` → New request created
* `200 OK` → Duplicate request

---

### Cancel Request

**PATCH /requests/:id/cancel**

Responses:

* `200 OK` → Cancelled
* `409 Conflict` → Already processing

---

##  API Testing with Postman

You can test the API using Postman.

---

###  Import Collection

1. Open Postman
2. Click **Import**
3. Select **Raw Text**
4. Paste the provided Postman Collection JSON
5. Click **Continue → Import**

---

###  Setup Environment

Create a variable:

| Key      | Value                 |
| -------- | --------------------- |
| base_url | http://localhost:3000 |

---

###  Test Scenarios

#### 1. Create Request (New)

* Expected: `202 Accepted`
* Description: Creates new request and triggers background job

#### 2. Create Request (Duplicate)

* Expected: `200 OK`
* Description: Same `idempotency_key` returns existing record

#### 3. Create Request (Different Key)

* Expected: `202 Accepted`

#### 4. Cancel Request

* Expected: `200 OK`

#### 5. Cancel While Processing

* Expected: `409 Conflict`

#### 6. Invalid Request

* Expected: `400 Bad Request`

---


