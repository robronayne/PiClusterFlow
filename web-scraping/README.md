# Web Scraping Docker Images

This repository contains Dockerfiles and scripts for running web scrapers that collect surf-related data. The scrapers are built as Docker images and executed in a Kubernetes environment using Argo Workflows.

## Docker Image Builds

Each scraper is built using web_scraper.Dockerfile, with build arguments provided at runtime. Sensitive information such as database credentials and API keys are passed as build arguments but will be stored securely in GitHub Actions secrets and repository variables.

### Swell Scraper

This scraper collects wave and swell data from NOAA buoys. The extracted information includes:
- Wave height
- Swell height
- Swell period
- Swell direction
- Wind wave height
- Wind wave period
- Wind wave direction
- Wave steepness
- Average wave period

#### Build & Run Commands

```
docker build -f web_scraper.Dockerfile \
  --build-arg DB_HOST=<RASPBERRY_PI_IP> \
  --build-arg DB_USER=<DB_USER> \
  --build-arg DB_PASSWORD=<DB_PASSWORD> \
  --build-arg DB_NAME=surf_analytics \
  --build-arg JOB_NAME=swell_scraper_hourly.py \
  -t argo-swell-scraper-hourly:latest .

docker run --name argo-swell-scraper-hourly argo-swell-scraper-hourly:latest
```

### Wind Scraper

This scraper fetches real-time wind data from the OpenWeather API. The extracted information includes:
- Wind speed
- Wind direction
- Wind gusts (if available)

#### Build & Run Commands

```
docker build -f web_scraper.Dockerfile \
  --build-arg DB_HOST=<RASPBERRY_PI_IP> \
  --build-arg DB_USER=<DB_USER> \
  --build-arg DB_PASSWORD=<DB_PASSWORD> \
  --build-arg DB_NAME=surf_analytics \
  --build-arg API_KEY=<API_KEY> \
  --build-arg JOB_NAME=wind_scraper_hourly.py \
  -t argo-wind-scraper-hourly:latest .

docker run --name argo-wind-scraper-hourly argo-wind-scraper-hourly:latest
```

## Deployment and Secrets Management

These images will be built and deployed using GitHub Actions. All sensitive information, such as database credentials and API keys, is securely stored in GitHub repository secrets and environment variables. The build process retrieves these secrets at runtime to ensure security and maintainability.

## Database Configuration

The PostgreSQL database used for storing scraped data is hosted on a Raspberry Pi. The DB_HOST build argument should be set to the local IP address of the Raspberry Pi running the database instance.
