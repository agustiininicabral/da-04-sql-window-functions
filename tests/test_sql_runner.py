from __future__ import annotations

import sqlite3

import pytest

from scripts.run_sql import execute_queries, run_queries


def _result(results, prefix):
    return next(rows for name, rows in results.items() if name.startswith(prefix))


def test_all_baseline_and_window_queries_execute() -> None:
    results = run_queries()

    assert len(results) == 8
    assert all(
        name.startswith(f"Q{index:02d}") for index, name in enumerate(results, 1)
    )


def test_monthly_lag_and_running_total_preserve_revenue() -> None:
    results = run_queries()
    monthly = _result(results, "Q04")
    running = _result(results, "Q05")

    assert len(monthly) == 24
    assert monthly[0]["previous_month_revenue"] is None
    assert monthly[0]["mom_change_pct"] is None
    assert monthly[1]["previous_month_revenue"] == pytest.approx(
        monthly[0]["revenue"], abs=0.01
    )

    total_revenue = sum(float(row["revenue"]) for row in monthly)
    assert total_revenue == pytest.approx(608810.14, abs=0.01)
    assert float(running[-1]["cumulative_revenue"]) == pytest.approx(
        total_revenue, abs=0.01
    )


def test_moving_average_cohorts_and_country_rankings_are_valid() -> None:
    results = run_queries()
    moving_average = _result(results, "Q06")
    cohorts = _result(results, "Q07")
    country_rankings = _result(results, "Q08")

    assert len(moving_average) > 300
    assert moving_average[0]["moving_average_7_observed_dates"] == pytest.approx(
        moving_average[0]["daily_revenue"], abs=0.01
    )
    assert all(int(row["month_number"]) >= 0 for row in cohorts)
    assert len(country_rankings) == 15
    assert max(int(row["country_rank"]) for row in country_rankings) == 3


def test_query_runner_rejects_unnamed_statements() -> None:
    with sqlite3.connect(":memory:") as connection:
        with pytest.raises(ValueError, match="must start with"):
            execute_queries(connection, "SELECT 1;")
