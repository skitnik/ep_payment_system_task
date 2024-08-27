# README

## Startup

```bash
git clone <repository-url>
```

### Option 1

```bash
bundle install
rails db:create db:migrate
rails db:seed # optional - will set up admin and merchant users and some transactions
rails s
```
### Option 2 - Quickstart with Docker
Start the application with a clean, pre-seeded database:
```bash
docker-compose up --build
```

## Login

### Option 1

If the database was seeded:

- **Admin:**
  - email: `admin@admin.com`
  - password: `admin`

- **Merchant:**
  - email: `merchant@merchant.com`
  - password: `merchant`

### Option 2

Run the following to import users from a CSV file:

```bash
rake users:import[file.csv]
```

The CSV file should have the following structure:

```csv
name,email,password,status,type,description
Alice,alice@example.com,password,active,admin,Admin user
Bob,bob@example.com,password,active,merchant,Merchant user
```

## User Types

- **Admin:** Can view/edit/destroy other users and view all transactions.
- **Merchant:** Can view related transactions.

## API Overview

This API provides endpoints for user authentication and payment transactions. All endpoints are namespaced under `/api`.

### Formats

The API supports both JSON and XML request/response formats. The format is determined by the `Content-Type` and `Accept` headers:

- **JSON:** `application/json`
- **XML:** `application/xml`

## Endpoints

### 1. Authentication

**POST /api/login**

This endpoint is used to authenticate users. Upon successful authentication, it returns a JSON Web Token (JWT) that can be used to authorize subsequent API requests.

**Example Requests:**

**JSON:**

```bash
curl -X POST http://localhost:3000/api/login \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-d '{"user": {"email": "merchant@merchant.com", "password": "merchant"}}'
```

**XML:**

```bash
curl -X POST http://localhost:3000/api/login \
-H "Content-Type: application/xml" \
-H "Accept: application/xml" \
-d '<user><email>merchant@merchant.com</email><password>merchant</password></user>'
```

**Response:**

- **Success (200 OK):**

  **JSON:**
  ```json
  {
    "token": "your_jwt_token"
  }
  ```

- **Failure (401 Unauthorized):**

  **JSON:**
  ```json
  {
    "error": "Invalid email or password"
  }
  ```

### 2. Payments

**POST /api/payments**

This endpoint allows merchants to create a payment transaction. The type of transaction (e.g., authorize, charge, refund, reversal) must be specified in the request. All requests must include an Authorization header with a valid JWT token: `Authorization: Bearer your_jwt_token`

**Note:** The user must be authenticated as a Merchant to create a payment transaction.

**Example Requests:**

**Authorize:**

**JSON:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "Authorization: Bearer your_jwt_token" \
-d '{"amount": 100.00, "customer_email": "customer@examlple.com", "customer_phone": "12345", "transaction_type": "authorize"}'
```

**XML:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/xml" \
-H "Accept: application/xml" \
-H "Authorization: Bearer your_jwt_token" \
-d '<payment><amount>100.00</amount><customer_email>customer@example.com</customer_email><customer_phone>123456</customer_phone><transaction_type>authorize</transaction_type></payment>'
```

**Charge:**

**JSON:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "Authorization: Bearer your_jwt_token" \
-d '{"amount": 20.00, "customer_email": "customer@examlple.com", "customer_phone": "12345", "transaction_type": "charge", "reference_transaction_id": authorize_transation_id}'
```

**XML:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/xml" \
-H "Accept: application/xml" \
-H "Authorization: Bearer your_jwt_token" \
-d '<payment><amount>20.00</amount><customer_email>customer@example.com</customer_email><customer_phone>123456</customer_phone><transaction_type>charge</transaction_type><reference_transaction_id>authorize_transation_id</reference_transaction_id></payment>'
```

**Refund:**

**JSON:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "Authorization: Bearer your_jwt_token" \
-d '{"amount": 20.00, "customer_email": "customer@examlple.com", "customer_phone": "12345", "transaction_type": "refund", "reference_transaction_id": charge_transaction_id}'
```

**XML:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/xml" \
-H "Accept: application/xml" \
-H "Authorization: Bearer your_jwt_token" \
-d '<payment><amount>20.00</amount><customer_email>customer@example.com</customer_email><customer_phone>123456</customer_phone><transaction_type>refund</transaction_type><reference_transaction_id>charge_transaction_id</reference_transaction_id></payment>'
```

**Reversal:**

**JSON:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/json" \
-H "Accept: application/json" \
-H "Authorization: Bearer your_jwt_token" \
-d '{"customer_email": "customer@examlple.com", "customer_phone": "12345", "transaction_type": "reversal", "reference_transaction_id": authorize_transaction_id}'
```

**XML:**

```bash
curl -X POST http://localhost:3000/api/payments \
-H "Content-Type: application/xml" \
-H "Accept: application/xml" \
-H "Authorization: Bearer your_jwt_token" \
-d '<payment><customer_email>customer@example.com</customer_email><customer_phone>123456</customer_phone><transaction_type>reversal</transaction_type><reference_transaction_id>authorize_transaction_id</reference_transaction_id></payment>'
```

