from app import app

def test_home():
    # Create a dummy client to test our app
    client = app.test_client()
    response = client.get('/')

    # Check if the response matches our expectation
    assert response.status_code == 200
    assert b"Pipeline is WORKING" in response.data