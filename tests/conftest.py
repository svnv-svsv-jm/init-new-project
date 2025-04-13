import pytest, os
import typing as ty
import pyrootutils

root = pyrootutils.setup_root(
    search_from=".",
    indicator=[".git", "pyproject.toml"],
    pythonpath=True,
    dotenv=True,
    cwd=True,
)


@pytest.fixture(scope="session")
def data_path() -> str:
    """Path where to download any dataset."""
    return os.environ.get("PATH_DATASETS", "./.data")
