# Good Night API Documentation

"Good Night" application lets users track when they go to bed and when they wake up, follow/unfollow other users, and see friends’ sleep records.

---

## 🚀 Features

- **Clock In & Clock Out:** Track user sleep times.
- **Follow/Unfollow Users:** Connect with friends.
- **View Friends’ Sleep Records:** See your following users’ sleep from the previous week, sorted by sleep duration.
- **Pagination:** Supports paging through records.

---

## 🛠 Tech Stack

- **Framework:** Ruby on Rails 8.0
- **Database:** postgresql (development/test)
- **Cache/Queue:** Redis
- **Testing:** RSpec

---

## 📋 Prerequisites

- Ruby 3.2 (`ruby --version`)
- Rails 8.0 (`rails --version`)
- Redis server

### Installing Redis

**macOS (Homebrew):**
```bash
brew install redis
brew services start redis
```
**macOS (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install redis-server
sudo systemctl start redis-server
sudo systemctl enable redis-server
```

## 🔧 Installation
```bash
git clone https://github.com/username/good-night-app.git
cd good-night-app
bundle install
rails db:prepare
sudo service redis-server start
rails db:seed
rails server
```
Visit: http://localhost:3000

## 🧪 Testing
```bash
# Run all tests
bundle exec rspec

# Run specific test
bundle exec rspec spec/models/sleep_records_spec.rb
#or
bundle exec rspec spec/models/users_spec.rb
```

## 🧪 Testing

### 📦 API Endpoints

#### 1️⃣ Sleep Records

##### 1 Get All Sleep Records
*GET* `/api/sleep_records`

- Description: List all sleep records of the current user.

- Query params:

  - `page` (optional, default: 1)

  - `per_page` (optional, default: 50, max: 200)

Response Example:

```bash
{
    "pagination":
     {
        "page": 1,
        "per_page": 50,
        "has_more": false
    },
    "records": [
        {
            "id": 3,
            "user_id": 1,
            "start_time": "2025-09-05T04:45:02.160Z",
            "end_time": "2025-09-05T07:00:45.335Z",
            "duration_seconds": 8143,
            "created_at": "2025-09-05T04:45:02.161Z",
            "user":
             {
                "id": 1,
                "name": "Rev. Heidi Nolan"
            }
        },
        {
            "id": 2,
            "user_id": 1,
            "start_time": "2025-09-05T04:44:53.752Z",
            "end_time": "2025-09-05T07:00:33.913Z",
            "duration_seconds": 8140,
            "created_at": "2025-09-05T04:44:53.755Z",
            "user": 
            {
                "id": 1,
                "name": "Rev. Heidi Nolan"
            }
        },
        {
            "id": 1,
            "user_id": 1,
            "start_time": "2025-09-05T04:36:55.320Z",
            "end_time": "2025-09-05T06:57:31.020Z",
            "duration_seconds": 8435,
            "created_at": "2025-09-05T04:36:55.333Z",
            "user": 
            {
                "id": 1,
                "name": "Rev. Heidi Nolan"
            }
        }
    ]
}
```

##### 2 get Sleep Record
*GET* `/api/sleep_records/1`

- Description: Show sleep record by id.

Response Example:

```bash
{
    "id": 7,
    "user_id": 2,
    "start_time": "2025-09-05T08:17:51.936Z",
    "end_time": "2025-09-05T08:19:44.642Z",
    "duration_seconds": 112,
    "created_at": "2025-09-05T08:17:51.937Z",
    "user": 
    {
        "id": 2,
        "name": "Lavenia Kuvalis"
    }
}
```

##### 3 get Sleep Record
*POST* `/api/sleep_records`

- Description: Add new sleep record (start sleep), User can't add new sleep record untill current record is clocked out.

Response Example:

```bash
{
    "id": 14,
    "user_id": 3,
    "start_time": "2025-09-06T03:42:11.227Z",
    "end_time": null,
    "duration_seconds": null,
    "created_at": "2025-09-06T03:42:11.228Z",
    "user": 
    {
        "id": 3,
        "name": "Javier Ryan DC"
    }
}
```

##### 4 Clock out
*PATCH* `/api/sleep_records/13/clock_out`

- Description: Clock out (end sleep). Calculates `duration_seconds`.

Response Example:

```bash
{
    "id": 14,
    "user_id": 3,
    "start_time": "2025-09-06T03:42:11.227Z",
    "end_time": "2025-09-06T03:46:02.341Z",
    "duration_seconds": 231,
    "created_at": "2025-09-06T03:42:11.228Z",
    "user": 
    {
        "id": 3,
        "name": "Javier Ryan DC"
    }
}
```


#### 2️⃣ Users / Following

##### 1 Follow other user
*POST* `/api/users/3/follow`

- Description: Follow another user.

Response Example:

```bash
{
    "id": 11,
    "created_at": "2025-09-06T03:48:37.475Z",
    "follower": 
    {
        "id": 1,
        "name": "Rev. Heidi Nolan"
    },
    "followed": 
    {
        "id": 3,
        "name": "Javier Ryan DC"
    }
}
```

##### 2 Show following
*POST* `/api/users/1`

- Description: Show following with their sleep records.

Response Example:

```bash
{
    "since": "2025-08-30T03:51:05.568Z",
    "until": "2025-09-06T03:51:05.568Z",
    "pagination":
     {
        "page": 1,
        "per_page": 50,
        "has_more": false
    },
    "users": [
        {
            "id": 2,
            "name": "Lavenia Kuvalis",
            "records": [
                {
                    "id": 9,
                    "start_time": "2025-09-05T08:22:26.109Z",
                    "end_time": "2025-09-05T08:24:25.018Z",
                    "duration_seconds": 118
                },
                {
                    "id": 7,
                    "start_time": "2025-09-05T08:17:51.936Z",
                    "end_time": "2025-09-05T08:19:44.642Z",
                    "duration_seconds": 112
                },
                {
                    "id": 8,
                    "start_time": "2025-09-05T08:21:05.360Z",
                    "end_time": "2025-09-05T08:22:47.859Z",
                    "duration_seconds": 102
                }
            ]
        }
    ]
}
```

### ⚡ Notes

- All endpoints return JSON.

- Pagination is available for list endpoints.

- Caching is enabled for performance (Redis, 5 minutes TTL).

- Errors return standard HTTP status codes with errors key.
