from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)
for path, method in [('/api/branches', 'get'), ('/api/branches/', 'get'), ('/api/branches', 'post'), ('/api/branches/', 'post')]:
    response = getattr(client, method)(path)
    print(path, method.upper(), response.status_code, response.text[:200])
