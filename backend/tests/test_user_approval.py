import unittest
import uuid

from app.api.user_router import router as user_router
from app.models.user import UserStatus
from app.schemas.auth import ApproveUserRequest, UserResponse


class TestUserApprovalSystem(unittest.TestCase):

    def test_approve_user_request_schema(self):
        req = ApproveUserRequest(role_id=2)
        self.assertEqual(req.role_id, 2)
        self.assertIsNone(req.branch_id)

        req_with_branch = ApproveUserRequest(
            role_id=2,
            branch_id=uuid.uuid4(),
        )
        self.assertEqual(req_with_branch.role_id, 2)
        self.assertIsNotNone(req_with_branch.branch_id)

        req_none = ApproveUserRequest()
        self.assertIsNone(req_none.role_id)
        self.assertIsNone(req_none.branch_id)

        req_blank_branch = ApproveUserRequest(role_id=2, branch_id="")
        self.assertIsNone(req_blank_branch.branch_id)

    def test_user_status_enum_values(self):
        self.assertEqual(UserStatus.PENDING, "PENDING")
        self.assertEqual(UserStatus.APPROVED, "APPROVED")
        self.assertEqual(UserStatus.REJECTED, "REJECTED")
        self.assertEqual(UserStatus.SUSPENDED, "SUSPENDED")

    def test_user_response_schema_validation(self):
        user_id = uuid.uuid4()
        resp = UserResponse(
            id=user_id,
            first_name="John",
            last_name="Doe",
            email="john@example.com",
            phone="1234567890",
            role_id=2,
            branch_id=None,
            status="APPROVED",
            email_verified=False,
            phone_verified=False,
            is_active=True,
        )
        self.assertEqual(resp.id, user_id)
        self.assertEqual(resp.status, "APPROVED")
        self.assertEqual(resp.role_id, 2)

    def test_approve_endpoint_methods_allowed(self):
        approve_routes = [
            route
            for route in user_router.routes
            if route.path.endswith("/approve")
        ]
        self.assertTrue(len(approve_routes) > 0)
        methods = approve_routes[0].methods
        self.assertIn("PATCH", methods)
        self.assertIn("POST", methods)
        self.assertIn("PUT", methods)


if __name__ == "__main__":
    unittest.main()
