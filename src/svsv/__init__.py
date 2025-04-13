__all__ = []

import os
from loguru import logger

package_name = os.path.basename(os.path.dirname(__file__))
logger.disable(package_name)


def configure_logger(enable: bool = False) -> None:
    """Configure logging."""
    logger.disable(package_name)
    if enable:
        logger.enable(package_name)


try:
    from importlib import metadata

    v = metadata.version(package_name)
    __version__ = f"{v}"
except Exception:  # pragma: no cover
    __version__ = "idb"
    pass

