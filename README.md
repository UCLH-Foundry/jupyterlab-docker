# JupyterLab Docker Services

Collection of JupyterLab Docker services to run the platform for multiple users.

The JupyterLab image is based on the latest official data science image, with additional tools required at UCLH.

## Features

- ✔️ R
- ✔️ Python and Conda
- ✔️ Julia
- ✔️ ODBC drivers for MS SQL databases

This project is based on Jon Ghillam's repository: [space-safety/jupyter](https://github.com/space-safety/jupyter/).

## Getting Started

### Prerequisites

- Docker installed on your machine. Follow the official Docker [installation guide](https://docs.docker.com/get-docker/) for your operating system.


## Included Tools and Packages

### Data Science Tools

- **R**: A language and environment for statistical computing and graphics.
- **Python**: A powerful programming language with extensive libraries.
- **Conda**: An open-source package management and environment management system.
- **Julia**: A high-level, high-performance dynamic programming language for technical computing.

### ODBC Drivers

- **ODBC drivers for MS SQL databases**: Includes drivers for connecting to Microsoft SQL Server databases.

## Customization

### Adding Additional Packages

To add more Python or R packages, you can modify the `Dockerfile` and rebuild the image. For example, to add more Python packages:

```dockerfile
RUN conda install --quiet --yes \
    new-python-package1 \
    new-python-package2 && \
    conda clean --all --force-pkgs-dirs --yes
```

for R packages:

```dockerfile
RUN conda install --quiet --yes --channel r \
    new-r-package1 \
    new-r-package2 && \
    conda clean --all --force-pkgs-dirs --yes
```

### Environment Variables
You can set various environment variables to customize the container. For example:

JUPYTER_WORKDIR: Set the working directory for JupyterLab.


## License
This project is licensed under GNU General Public License v3.0 - see the LICENSE file for details.
