from fastapi import APIRouter, HTTPException, status, Depends
from datetime import timedelta
from app.schemas.user import UserCreate, UserLogin, Token, UserResponse, UserInDB
from app.services.auth import create_access_token, get_current_user
from app.services.database import db_service, DatabaseService
from app.core.supabase import get_supabase_client, get_supabase_service_client

router = APIRouter(prefix="/auth", tags=["Authentication"])


def _http_error_from_signup_exception(exc: Exception) -> HTTPException:
    message = str(exc)
    lowered = message.lower()

    if "email rate limit exceeded" in lowered:
        return HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email rate limit exceeded. Wait a bit and try again.",
        )
    if "already registered" in lowered or "users_email_key" in lowered:
        return HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already exists. Try logging in instead.",
        )
    if "users_id_fkey" in lowered:
        return HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Signup could not be completed for this user. Try logging in instead.",
        )
    return HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=message)


def _ensure_user_profile(
    db: DatabaseService, user_id: str, email: str, full_name: str | None = None
) -> str:
    user = db.service_get_by_id("users", user_id)
    if not user:
        try:
            db.service_insert(
                "users",
                {
                    "id": user_id,
                    "email": email,
                    "full_name": full_name,
                },
            )
        except Exception as exc:
            raise _http_error_from_signup_exception(exc)

    roles = db.service_select("user_roles", filters={"user_id": user_id})
    if roles:
        return roles[0]["role"]

    try:
        db.service_insert("user_roles", {"user_id": user_id, "role": "user"})
    except Exception as exc:
        raise _http_error_from_signup_exception(exc)

    return "user"


@router.post("/signup", response_model=Token, status_code=status.HTTP_201_CREATED)
async def signup(
    user_data: UserCreate, db: DatabaseService = Depends(lambda: db_service)
):
    supabase = get_supabase_client()

    try:
        auth_response = supabase.auth.sign_up(
            {
                "email": user_data.email,
                "password": user_data.password,
            }
        )

        if auth_response.user is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST, detail="Failed to create user"
            )

        user_id = auth_response.user.id
        role = _ensure_user_profile(
            db, user_id, user_data.email, user_data.full_name
        )

        access_token = create_access_token(
            data={"sub": user_id, "email": user_data.email, "role": role},
            expires_delta=timedelta(minutes=60),
        )

        return Token(access_token=access_token)

    except HTTPException:
        raise
    except Exception as e:
        raise _http_error_from_signup_exception(e)


@router.post("/login", response_model=Token)
async def login(
    login_data: UserLogin, db: DatabaseService = Depends(lambda: db_service)
):
    supabase = get_supabase_client()

    try:
        auth_response = supabase.auth.sign_in_with_password(
            {
                "email": login_data.email,
                "password": login_data.password,
            }
        )

        if auth_response.user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials"
            )

        user_id = auth_response.user.id
        role = _ensure_user_profile(
            db,
            user_id,
            login_data.email,
            getattr(auth_response.user, "user_metadata", {}).get("full_name"),
        )

        access_token = create_access_token(
            data={"sub": user_id, "email": login_data.email, "role": role},
            expires_delta=timedelta(minutes=60),
        )

        return Token(access_token=access_token)

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials"
        )


@router.get("/me", response_model=UserResponse)
async def get_me(current_user=Depends(get_current_user)):
    db = db_service
    user = db.service_get_by_id("users", current_user.user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )

    roles = db.service_select("user_roles", filters={"user_id": current_user.user_id})
    role = roles[0]["role"] if roles else "user"

    return UserResponse(
        id=user["id"],
        email=user["email"],
        full_name=user.get("full_name"),
        created_at=user["created_at"],
        role=role,
    )
