import unittest
import uuid
from datetime import datetime, timezone

from app.api.branch_router import router as branch_router
from app.schemas.branch import BranchCreate, BranchResponse, BranchUpdate


class TestBranchManagementSystem(unittest.TestCase):

    def test_branch_create_schema(self):
        branch = BranchCreate(
            branch_code="B001",
            name="Main Campus",
            address="123 Main St",
            city="Mumbai",
            state="Maharashtra",
            phone="9876543210",
            email="main@horusacademy.com",
        )
        self.assertEqual(branch.branch_code, "B001")
        self.assertEqual(branch.name, "Main Campus")

    def test_branch_update_schema_partial(self):
        update = BranchUpdate(name="Updated Campus", is_active=False)
        data = update.model_dump(exclude_unset=True)
        self.assertEqual(data, {"name": "Updated Campus", "is_active": False})

    def test_branch_response_schema(self):
        branch_id = uuid.uuid4()
        now = datetime.now(timezone.utc)
        response = BranchResponse(
            id=branch_id,
            branch_code="B001",
            name="Main Campus",
            address="123 Main St",
            city="Mumbai",
            state="Maharashtra",
            phone=None,
            email=None,
            is_active=True,
            created_at=now,
            updated_at=now,
        )
        self.assertEqual(response.id, branch_id)
        self.assertTrue(response.is_active)

    def test_branch_crud_endpoint_methods(self):
        list_routes = [
            route for route in branch_router.routes if route.path == "/branches"
        ]
        detail_routes = [
            route
            for route in branch_router.routes
            if route.path == "/branches/{branch_id}"
        ]

        list_methods = set()
        for route in list_routes:
            list_methods.update(route.methods)

        detail_methods = set()
        for route in detail_routes:
            detail_methods.update(route.methods)

        self.assertIn("POST", list_methods)
        self.assertIn("GET", list_methods)
        self.assertIn("PUT", detail_methods)
        self.assertIn("DELETE", detail_methods)


if __name__ == "__main__":
    unittest.main()
