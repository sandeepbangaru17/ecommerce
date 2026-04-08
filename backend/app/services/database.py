from typing import Optional, Dict, Any, List
from supabase import Client
from app.core.supabase import get_supabase_client, get_supabase_service_client


class DatabaseService:
    def __init__(self, client: Optional[Client] = None):
        self.client = client

    @property
    def supabase(self) -> Client:
        if self.client:
            return self.client
        return get_supabase_client()

    @property
    def service_supabase(self) -> Client:
        if self.client:
            return self.client
        return get_supabase_service_client()

    def insert(self, table: str, data: Dict[str, Any]) -> Dict[str, Any]:
        result = self.supabase.table(table).insert(data).execute()
        return result.data[0] if result.data else {}

    def service_insert(self, table: str, data: Dict[str, Any]) -> Dict[str, Any]:
        result = self.service_supabase.table(table).insert(data).execute()
        return result.data[0] if result.data else {}

    def select(
        self,
        table: str,
        filters: Optional[Dict[str, Any]] = None,
        order: Optional[str] = None,
        limit: Optional[int] = None,
        offset: int = 0,
    ) -> List[Dict[str, Any]]:
        query = self.supabase.table(table).select("*")
        if filters:
            for key, value in filters.items():
                query = query.eq(key, value)
        if order:
            query = query.order(order, desc=True)
        if limit:
            query = query.limit(limit)
        query = query.offset(offset)
        result = query.execute()
        return result.data or []

    def service_select(
        self,
        table: str,
        filters: Optional[Dict[str, Any]] = None,
        order: Optional[str] = None,
        limit: Optional[int] = None,
        offset: int = 0,
    ) -> List[Dict[str, Any]]:
        query = self.service_supabase.table(table).select("*")
        if filters:
            for key, value in filters.items():
                query = query.eq(key, value)
        if order:
            query = query.order(order, desc=True)
        if limit:
            query = query.limit(limit)
        query = query.offset(offset)
        result = query.execute()
        return result.data or []

    def get_by_id(self, table: str, id: str) -> Optional[Dict[str, Any]]:
        result = self.supabase.table(table).select("*").eq("id", id).execute()
        return result.data[0] if result.data else None

    def service_get_by_id(self, table: str, id: str) -> Optional[Dict[str, Any]]:
        result = self.service_supabase.table(table).select("*").eq("id", id).execute()
        return result.data[0] if result.data else None

    def update(self, table: str, id: str, data: Dict[str, Any]) -> Dict[str, Any]:
        result = self.supabase.table(table).update(data).eq("id", id).execute()
        return result.data[0] if result.data else {}

    def service_update(
        self, table: str, id: str, data: Dict[str, Any]
    ) -> Dict[str, Any]:
        result = self.service_supabase.table(table).update(data).eq("id", id).execute()
        return result.data[0] if result.data else {}

    def delete(self, table: str, id: str) -> bool:
        result = self.supabase.table(table).delete().eq("id", id).execute()
        return True

    def service_delete(self, table: str, id: str) -> bool:
        result = self.service_supabase.table(table).delete().eq("id", id).execute()
        return True


db_service = DatabaseService()
