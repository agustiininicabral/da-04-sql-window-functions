from __future__ import annotations

import sqlite3

import pytest

from scripts.run_sql import execute_queries, run_queries


def test_all_window_queries_execute_with_expected_results() -> None:
    results = run_queries()

    assert len(results) == 4
    assert all(
        name.startswith(f"Q{index:02d}") for index, name in enumerate(results, 1)
    )

    ranking = results["Q01 Category revenue ranking"]
    monthly = results["Q02 Monthly revenue trend, lag, rolling average, and running total"]
    customer_orders = results["Q03 Customer order sequence and days between purchases"]
    retention = results["Q04 Monthly cohort retention"]

    assert len(ranking) == 6
    assert ranking[0]["category"] == "Infantil"
    assert ranking[0]["revenue_rank"] == 1
    assert sum(float(row["revenue"]) for row in ranking) == pytest.approx(608810.14, abs=0.01)

    assert len(monthly) == 24
    assert monthly[0]["previous_month_revenue"] is None
    assert monthly[-1]["cumulative_revenue"] == pytest.approx(608810.14, abs=0.01)
    assert all(row["rolling_3_month_avg"] is not None for row in monthly[2:])

    assert len(customer_orders) == 3500
    assert any(row["order_number"] > 1 for row in customer_orders)
    assert any(row["days_since_previous_order"] is not None for row in customer_orders)

    first_month_cohorts = [row for row in retention if row["month_offset"] == 0]
    assert first_month_cohorts
    assert all(row["retention_pct"] == 100.0 for row in first_month_cohorts)
    assert all(row["cohort_size"] == row["active_customers"] for row in first_month_cohorts)


def test_query_runner_rejects_unnamed_statements() -> None:
    with sqlite3.connect(":memory:") as connection:
        with pytest.raises(ValueError, match="must start with"):
            execute_queries(connection, "SELECT 1;")
