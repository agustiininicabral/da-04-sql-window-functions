from __future__ import annotations

import csv
import re
import sqlite3
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SALES_PATH = ROOT / "02-data" / "raw" / "sales.csv"
PRODUCTS_PATH = ROOT / "02-data" / "raw" / "products.csv"
SQL_PATHS = (
    ROOT / "03-work" / "sql" / "01_core_queries.sql",
    ROOT / "03-work" / "sql" / "02_window_examples.sql",
)
IDENTIFIER = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def load_csv(connection: sqlite3.Connection, path: Path, table: str) -> int:
    if not IDENTIFIER.fullmatch(table):
        raise ValueError(f"Unsafe SQLite table name: {table!r}")

    with path.open("r", encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source)
        columns = reader.fieldnames
        if not columns:
            raise ValueError(f"CSV has no header: {path}")
        if any(not IDENTIFIER.fullmatch(column) for column in columns):
            raise ValueError(f"CSV has unsupported column names: {columns}")
        rows = list(reader)

    quoted_columns = ", ".join(f'"{column}" TEXT' for column in columns)
    placeholders = ", ".join("?" for _ in columns)
    quoted_names = ", ".join(f'"{column}"' for column in columns)
    connection.execute(f'CREATE TABLE "{table}" ({quoted_columns})')
    connection.executemany(
        f'INSERT INTO "{table}" ({quoted_names}) VALUES ({placeholders})',
        [[row.get(column) for column in columns] for row in rows],
    )
    return len(rows)


def execute_queries(
    connection: sqlite3.Connection,
    sql_text: str,
) -> dict[str, list[dict[str, Any]]]:
    results: dict[str, list[dict[str, Any]]] = {}
    for statement in (part.strip() for part in sql_text.split(";")):
        if not statement:
            continue

        match = re.search(r"^\s*--\s*QUERY:\s*(.+)$", statement, flags=re.MULTILINE)
        if match is None:
            raise ValueError(
                "Every SQL statement must start with a '-- QUERY: name' comment."
            )

        query_name = match.group(1).strip()
        sql = "\n".join(
            line for line in statement.splitlines() if not line.strip().startswith("--")
        ).strip()
        if not sql:
            raise ValueError(f"Query {query_name!r} has no SQL statement.")
        if query_name in results:
            raise ValueError(f"Duplicate SQL query name: {query_name!r}")

        cursor = connection.execute(sql)
        columns = [description[0] for description in cursor.description or []]
        results[query_name] = [dict(zip(columns, row)) for row in cursor.fetchall()]

    if not results:
        raise ValueError("No named SQL queries were found.")
    return results


def run_queries() -> dict[str, list[dict[str, Any]]]:
    with sqlite3.connect(":memory:") as connection:
        sales_rows = load_csv(connection, SALES_PATH, "sales")
        product_rows = load_csv(connection, PRODUCTS_PATH, "products")
        results: dict[str, list[dict[str, Any]]] = {}
        for sql_path in SQL_PATHS:
            file_results = execute_queries(
                connection,
                sql_path.read_text(encoding="utf-8"),
            )
            duplicate_names = results.keys() & file_results.keys()
            if duplicate_names:
                raise ValueError(f"Duplicate query names across files: {sorted(duplicate_names)}")
            results.update(file_results)

    print(f"Loaded {sales_rows} sales rows and {product_rows} products.")
    for name, rows in results.items():
        print(f"{name}: {len(rows)} result rows")
    return results


def main() -> int:
    try:
        run_queries()
    except (OSError, sqlite3.Error, ValueError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
