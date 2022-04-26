import setuptools


with open("README.md", "r", encoding="utf-8") as f:
    README = f.read()


with open("LICENSE", "r", encoding="utf-8") as f:
    LICENSE = f.read()


setuptools.setup(
    name="test",
    version="1.0.0",
    author="Gianmarco",
    author_email="janmail1990@gmail.com",
    description="PyTorch Lightning",
    long_description=README,
    long_description_content_type="text/markdown",
    url="",
    project_urls={
        "Bug Tracker": "",
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src", exclude=("tests", "docs")),
    license=LICENSE,
    python_requires=">=3.8",
    zip_safe=False,
)
