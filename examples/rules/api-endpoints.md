---
paths:
  - "src/api/**/*.ts"
  - "src/routes/**/*.ts"
---

# API Endpoint Rules

- All endpoints must validate input before processing
- Use consistent error response format: `{ error: string, code: string }`
- Return appropriate HTTP status codes (don't default everything to 500)
- Log errors with context (request ID, user ID) but never log sensitive data
- Include rate limiting headers in responses
