# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-02

### Added
- `NetworkClient` struct for type-safe HTTP requests
- `Endpoint` protocol for declarative API definitions
- `HTTPMethod` enum (GET, POST, PUT, PATCH, DELETE, HEAD)
- `Response<T>` typed response wrapper with status code and headers
- `RetryPolicy` with configurable max attempts, delay, and retryable status codes
- `CachePolicy` with in-memory TTL-based caching
- `NetworkPlugin` protocol for request/response interceptors
- `AuthPlugin` for automatic Authorization header injection
- `LoggingPlugin` for request/response logging
- `NetworkError` enum with descriptive error cases
- Automatic `Codable` response decoding
- Upload and download support
- Zero external dependencies
