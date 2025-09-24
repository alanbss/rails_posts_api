# Rails Posts API

This is a Rails API application for managing posts and ratings. It's designed to handle a large volume of data efficiently.

## Installation

Follow these steps to get the application up and running on your local machine.

### Prerequisites

*   **Ruby:** This project uses Ruby. Make sure you have a recent version installed. You can check your Ruby version with `ruby -v`.
*   **PostgreSQL:** The application uses PostgreSQL as its database. Ensure you have it installed and running.
*   **Bundler:** You'll need Bundler to manage the Ruby gems. Install it with `gem install bundler`.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd rails_posts_api
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    ```

3.  **Configure environment variables:**
    Create a `.env` file in the root of the project and add the following variables. This file is used to load environment variables in development.

    ```
    POSTGRES_HOST=localhost
    POSTGRES_PORT=5432
    POSTGRES_USER=<your-postgres-username>
    POSTGRES_PASSWORD=<your-postgres-password>
    RAILS_MAX_THREADS=5
    ```

4.  **Create and migrate the database:**
    ```bash
    rails db:create
    rails db:migrate
    ```

5.  **Run the application:**
    ```bash
    rails s
    ```
    The API will be available at `http://localhost:3000`.

## Seed Data

The `db/seeds.rb` script is designed to populate the database with a large amount of sample data for performance testing and demonstration purposes.

### What it does:

*   **Generates 200,000 posts:** Each post has a title, body, IP address, and is associated with a user.
*   **Generates ratings:** It creates ratings for approximately 75% of the posts. Each rating has a value from 1 to 5.
*   **Uses bulk creation:** To ensure high performance, the seed script uses custom `bulk_create` endpoints in the API. Instead of creating records one by one (which would be very slow), it sends data in large batches (e.g., 5,000 records at a time).
*   **Uses Faker:** The data (usernames, post content, IP addresses) is generated using the [Faker](https://github.com/faker-ruby/faker) gem.

### How to use it:

To populate your database with this seed data, run the following command:

```bash
rails db:seed
```

You will see real-time progress in your terminal as the posts and ratings are generated and sent to the API.

## API Usage

The main API endpoints are available under `/api/v1`.

*   `POST /api/v1/posts`: Create a single post.
*   `POST /api/v1/posts/bulk_create`: Create multiple posts in a single request.
*   `GET /api/v1/posts/top?n=<number>`: Get the top `n` posts based on their average rating.
*   `POST /api/v1/ratings`: Create a single rating for a post.
*   `POST /api/v1/ratings/bulk_create`: Create multiple ratings in a single request.
*   `GET /api/v1/multi_author_ips`: Get a list of IP addresses that have been used by more than one author.

### cURL Examples

Here are some `curl` examples for interacting with the API:

**Create a single post:**

```bash
curl -X POST http://localhost:3000/api/v1/posts \
-H "Content-Type: application/json" \
-d '{
  "post": {
    "title": "My First Post",
    "body": "This is the body of my first post.",
    "login": "new_user",
    "ip": "192.168.1.1"
  }
}'
```

**Get top posts:**

```bash
curl http://localhost:3000/api/v1/posts/top?n=5
```

**Create a single rating:**

```bash
curl -X POST http://localhost:3000/api/v1/ratings \
-H "Content-Type: application/json" \
-d '{
  "rating": {
    "post_id": 1,
    "user_id": 1,
    "value": 5
  }
}'
```

**Get multi-author IPs:**

```bash
curl http://localhost:3000/api/v1/multi_author_ips
```
