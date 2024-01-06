import pytest
from loguru import logger
import sys
import typing as ty

from package import fn


@pytest.mark.parametrize("x", [1, 10, 1e3])
def test_fn(x: float) -> None:
    """Test it runs on synthetic data."""
    assert fn(x) == 0


if __name__ == "__main__":
    logger.remove()
    logger.add(sys.stderr, level="DEBUG")
    pytest.main([__file__, "-x", "-s", "--pylint"])
