__all__ = ["fn"]

import typing as ty
from loguru import logger


def fn(*args: ty.Any, **kwargs: ty.Any) -> float:
    """Always returns zero. Whatever you input."""
    logger.info("You are always getting zero.")
    logger.debug("No need to see debug logs, it's zero.")
    logger.trace("Ok this is a lot of printing, though.")
    return 0.0
