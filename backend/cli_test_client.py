#!/usr/bin/env python3
"""CLI Test Client for Ecommerce API"""

import sys
import os
import json
import time
from typing import Optional, Dict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import httpx
from fastapi import status

BASE_URL = "http://localhost:8000"
TIMEOUT = 30.0


class APITestClient:
    def __init__(self, base_url: str = BASE_URL):
        self.base_url = base_url
        self.client = httpx.Client(timeout=TIMEOUT)
        self.user_token: Optional[str] = None
        self.admin_token: Optional[str] = None
        self.failed_tests = []

    def close(self):
        self.client.close()

    def _get_headers(self, token: Optional[str] = None) -> Dict[str, str]:
        headers = {"Content-Type": "application/json"}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        return headers

    def _request(
        self,
        method: str,
        path: str,
        token: Optional[str] = None,
        json_data: Optional[Dict] = None,
        params: Optional[Dict] = None,
    ) -> httpx.Response:
        url = f"{self.base_url}{path}"
        headers = self._get_headers(token)

        if method == "GET":
            return self.client.get(url, headers=headers, params=params)
        elif method == "POST":
            return self.client.post(url, headers=headers, json=json_data)
        elif method == "PUT":
            return self.client.put(url, headers=headers, json=json_data)
        elif method == "DELETE":
            return self.client.delete(url, headers=headers)
        raise ValueError(f"Unsupported method: {method}")

    def test(
        self,
        name: str,
        method: str,
        path: str,
        expected_status: int,
        token: Optional[str] = None,
        json_data: Optional[Dict] = None,
        params: Optional[Dict] = None,
    ) -> bool:
        try:
            response = self._request(method, path, token, json_data, params)
            success = response.status_code == expected_status

            if success:
                print(f"[PASS] {name}")
            else:
                print(f"[FAIL] {name}")
                print(f"  Expected: {expected_status}, Got: {response.status_code}")
                if response.text:
                    try:
                        body = response.json()
                        print(f"  Response: {json.dumps(body, indent=2)[:500]}")
                    except:
                        print(f"  Response: {response.text[:500]}")
                self.failed_tests.append(name)
            return success
        except Exception as e:
            print(f"[FAIL] {name} - Exception: {e}")
            self.failed_tests.append(name)
            return False

    def run_all_tests(self) -> bool:
        print("=" * 60)
        print("Ecommerce API CLI Test Client")
        print("=" * 60)

        print("\n--- Health Checks ---")
        self.test("root endpoint", "GET", "/", status.HTTP_200_OK)
        self.test("health check", "GET", "/health", status.HTTP_200_OK)

        print("\n--- Product Tests ---")
        self.test("products GET - list", "GET", "/products", status.HTTP_200_OK)
        self.test(
            "products GET - filtered",
            "GET",
            "/products",
            status.HTTP_200_OK,
            params={"category": "Electronics"},
        )
        self.test(
            "products GET - invalid",
            "GET",
            "/products/invalid-id",
            status.HTTP_404_NOT_FOUND,
        )

        print("\n--- Order Tests ---")
        self.test(
            "orders POST - no auth",
            "POST",
            "/orders",
            status.HTTP_401_UNAUTHORIZED,
            json_data={
                "shipping_address": "123 Test St",
                "contact_phone": "+1234567890",
                "items": [],
            },
        )

        print("\n--- Input Validation ---")
        self.test(
            "validation - missing field",
            "POST",
            "/orders",
            status.HTTP_401_UNAUTHORIZED,
            json_data={"contact_phone": "+1234567890", "items": []},
        )

        print("\n" + "=" * 60)
        if self.failed_tests:
            print(f"FAILED: {len(self.failed_tests)} test(s)")
            for test in self.failed_tests:
                print(f"  - {test}")
            return False
        else:
            print("PASSED: All tests passed!")
            return True


def main():
    client = APITestClient()
    try:
        success = client.run_all_tests()
    finally:
        client.close()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
