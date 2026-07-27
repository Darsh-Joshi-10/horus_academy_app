from app.main import app

for route in app.routes:
    if hasattr(route, 'path') and 'branches' in route.path:
        print(route.path, sorted(route.methods))
