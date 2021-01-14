import os
from setuptools import setup

setup(
    name="bridgemetadata",
    version="0.1",
    author="GeoCat",
    author_email="volaya@geocat.net",
    description="A library to convert between different GIS metadata formats",
    license="MIT",
    keywords="GeoCat",
    url="",
    packages=["bridgemetadata"],
    include_package_data=True,
    entry_points={"console_scripts": ["md2md=bridgemetadata.convert:main","md-eval=bridgemetadata.convert:validate"]},
)
