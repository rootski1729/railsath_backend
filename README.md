# RailSathi Backend - Dockerized FastAPI Application

## Assignment Overview

This project demonstrates the **dockerization of a FastAPI application** (adapted from the original Django assignment) with PostgreSQL database integration, following all assignment requirements.

**Note**: The provided repository was FastAPI-based rather than Django, so this implementation uses FastAPI while maintaining all core assignment objectives.

## Assignment Requirements Met

### Core Requirements
-**Python Base Image**: Uses official `python:3.11-slim`
-**Dependencies**: Installs from `requirements.txt`
-**Database Setup**: PostgreSQL container with proper schema initialization
-**Docker Compose**: Orchestrates FastAPI app + PostgreSQL
-**Environment Variables**: Configured via `.env` file
-**Database Connectivity**: App connects to PostgreSQL via Docker networking

### ✅ Bonus Requirements
-**Database Startup Handling**: `wait-for-it.sh` script ensures DB is ready
-**API Documentation**: Auto-generated Swagger/OpenAPI docs
-**Hot Reload**: Development volumes for code changes
-**Database Admin**: pgAdmin interface (equivalent to Django admin)

## Quick Start

### Prerequisites
- Docker Desktop installed and running
- Git for cloning the repository

### 1. Clone and Setup
```bash
git clone <your-repository-url>
cd RailSathiBE

# Copy environment template
cp .env

# Edit .env with your configurations (database credentials, email settings)
```

### 2. Start the Application
```bash
# Build and start all services
docker-compose up --build

# Or run in background
docker-compose up --build -d
```

### 3. Verify Installation
- **API Base**: http://localhost:5002/rs_microservice
- **API Documentation**: http://localhost:5002/rs_microservice/docs
- **Health Check**: http://localhost:5002/health
- **Database Admin**: http://localhost:8081 (admin@railsathi.com / admin123)

## Architecture

### Services
- **app**: FastAPI application container
- **db**: PostgreSQL 15 database container  
- **pgadmin**: Database administration interface

### Key Files
- `Dockerfile`: Application container definition
- `docker-compose.yml`: Multi-service orchestration
- `init.sql`: Database schema and initial data
- `wait-for-it.sh`: Database startup synchronization
- `.env.example`: Environment variables template

## API Endpoints

### Core Complaint Management
```
GET    /rs_microservice                          # Service status
GET    /rs_microservice/complaint/get/{id}       # Get complaint by ID
GET    /rs_microservice/complaint/get/date/{date}?mobile_number={phone} # Get complaints by date
POST   /rs_microservice/complaint/add            # Create new complaint
PATCH  /rs_microservice/complaint/update/{id}    # Update complaint
PUT    /rs_microservice/complaint/update/{id}    # Replace complaint
DELETE /rs_microservice/complaint/delete/{id}    # Delete complaint
```

### Utility Endpoints
```
GET    /health                                   # Health check
GET    /rs_microservice/train_details/{train_no} # Train information
DELETE /rs_microservice/media/delete/{id}        # Delete media files
```

## Testing the API

### Using cURL
```bash
# Health check
curl http://localhost:5002/health

# Create a complaint
curl -X POST "http://localhost:5002/rs_microservice/complaint/add" \
  -H "Content-Type: multipart/form-data" \
  -F "name=John Doe" \
  -F "mobile_number=9876543210" \
  -F "complain_type=cleanliness" \
  -F "complain_description=Test complaint" \
  -F "train_number=12345"

# Get complaint by ID
curl http://localhost:5002/rs_microservice/complaint/get/1
```

### Using Swagger UI
Visit http://localhost:5002/rs_microservice/docs for interactive API testing.

## 🗄️ Database Schema

The application includes complete railway complaint management schema:

- **rail_sathi_railsathicomplain**: Main complaints table
- **rail_sathi_railsathicomplainmedia**: Media attachments
- **trains_traindetails**: Train information
- **user_onboarding_**: User management tables
- **station_**: Station/depot/division hierarchy

## 🔧 Development

### Hot Reload Development
```bash
# Use development compose file for hot reload
docker-compose -f docker-compose.dev.yml up --build
```

### Database Access
```bash
# Connect to PostgreSQL
docker exec -it railsathi_db psql -U railsathi_user -d rail_sathi_db

# Or use pgAdmin at http://localhost:8081
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
```

## Environment Configuration

### Required Environment Variables (.env)
```bash
# Database
POSTGRES_HOST=db
POSTGRES_PORT=5432
POSTGRES_USER=railsathi_user
POSTGRES_PASSWORD=your_password
POSTGRES_DB=rail_sathi_db

# Email (Optional - for notifications)
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_FROM=your_email@gmail.com

# Google Cloud Storage (Optional - for file uploads)
GCS_BUCKET_NAME=your-bucket-name
PROJECT_ID=your-project-id
GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json
```

## Project Structure
```
RailSathiBE/
├── main.py                 # FastAPI application entry point
├── services.py             # Business logic and database operations
├── database.py             # Database connection utilities
├── utils/
│   └── email_utils.py      # Email notification services
├── templates/              # Email templates
├── Dockerfile              # Application container definition
├── docker-compose.yml      # Production orchestration
├── docker-compose.dev.yml  # Development with hot reload
├── requirements.txt        # Python dependencies
├── init.sql               # Database schema initialization
├── wait-for-it.sh         # Database startup synchronization
├── .env.example           # Environment variables template
└── README.md              # This documentation
```

## Troubleshooting

### Common Issues

**1. Port Conflicts**
```bash
# Change ports in docker-compose.yml if needed
ports:
  - "5003:5002"  # Change host port
```

**2. Database Connection Issues**
```bash
# Reset database
docker-compose down -v
docker-compose up --build
```

**3. Permission Issues**
```bash
# Make scripts executable
chmod +x wait-for-it.sh
```

**4. Email/File Upload Not Working**
- Email: Configure Gmail app password in .env
- File Upload: Add Google Cloud service account key

## Security Considerations

### Development vs Production
- Current setup uses `POSTGRES_HOST_AUTH_METHOD=trust` for development
- For production: Remove trust auth, use strong passwords
- Add proper SSL/TLS certificates
- Implement authentication/authorization
- Secure environment variable handling

## Assignment Compliance

### Core Requirements Met
1. **Python Base Image**: `python:3.11-slim` in Dockerfile
2. **Dependencies**: `requirements.txt` installation  
3. **Database Migration**: Automated via `init.sql`
4. **Multi-container Setup**: FastAPI + PostgreSQL via Docker Compose
5. **Environment Config**: `.env` file support
6. **Network Connectivity**: Containers communicate via Docker networking

### Bonus Features Implemented
1. **Startup Synchronization**: `wait-for-it.sh` ensures database readiness
2. **Admin Interface**: pgAdmin for database management
3. **API Documentation**: Swagger/OpenAPI auto-generated docs
4. **Development Mode**: Hot reload with volume mounting

### Assignment Adaptations
- **FastAPI instead of Django**: Repository was FastAPI-based
- **PostgreSQL Schema**: Custom railway management schema vs Django ORM
- **API Endpoints**: RESTful complaint management vs Django views
- **pgAdmin**: Database admin interface equivalent to Django admin
