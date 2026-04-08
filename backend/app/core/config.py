from pydantic_settings import BaseSettings
from functools import lru_cache

_INSECURE_DEFAULT = "your-super-secret-jwt-key-change-in-production"


class Settings(BaseSettings):
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""
    SUPABASE_SERVICE_KEY: str = ""
    JWT_SECRET: str = _INSECURE_DEFAULT
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    ALLOWED_ORIGINS: str = "*"

    model_config = {"extra": "ignore", "env_file": ".env"}

    def model_post_init(self, __context: object) -> None:
        if self.JWT_SECRET == _INSECURE_DEFAULT:
            import warnings
            warnings.warn(
                "JWT_SECRET is using the insecure default value. "
                "Set a strong secret in your environment variables.",
                stacklevel=2,
            )


@lru_cache()
def get_settings() -> Settings:
    return Settings()
