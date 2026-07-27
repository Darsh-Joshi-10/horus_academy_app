import asyncio

from app.db.init_db import initialize_database


async def main() -> None:
    await initialize_database(drop_existing=True)
    print("Database reset complete.")


if __name__ == "__main__":
    asyncio.run(main())
