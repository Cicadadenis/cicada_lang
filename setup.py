from setuptools import setup, find_packages

setup(
    name="cicada_lang",
    version="0.1.2",
    description="Язык программирования Cicada",
    author="Cicada3301",
    author_email="email@example.com",
    url="https://github.com/Cicadadenis/cicada_lang",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
    ],
    python_requires=">=3.8",
    entry_points={
        "console_scripts": [
            "cicada=cicada.cicada:main",
        ],
    },
)
