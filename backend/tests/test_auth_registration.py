from app.schemas.auth import RegisterRequest


def test_register_request_accepts_missing_branch_id():
    request = RegisterRequest(
        first_name="Test",
        last_name="User",
        email="test.user@example.com",
        phone="1234567890",
        password="StrongPass123!",
    )

    assert request.branch_id is None


def test_register_request_treats_blank_branch_id_as_none():
    request = RegisterRequest(
        first_name="Test",
        last_name="User",
        email="test.user@example.com",
        phone="1234567890",
        password="StrongPass123!",
        branch_id="",
    )

    assert request.branch_id is None
