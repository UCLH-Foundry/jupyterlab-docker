FROM quay.io/jupyter/datascience-notebook:2023-11-07

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

ARG JUPYTER_WORKDIR
ARG HTTP_PROXY
ARG HTTPS_PROXY

USER root

ENV MSSQL_DRIVER="ODBC Driver 18 for SQL Server"
ENV PATH="/opt/mssql-tools18/bin:${PATH}"

ENV DEBIAN_FRONTEND=noninteractive


###############################################################################
# Install and update Linux packages                                           #
###############################################################################

# Add latest Ubuntu repos to sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse" | tee -a /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse" | tee -a /etc/apt/sources.list && \
    echo "deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse" | tee -a /etc/apt/sources.list && \
    echo "deb http://archive.canonical.com/ubuntu/ jammy partner" | tee -a /etc/apt/sources.list && \
    echo "deb-src http://archive.canonical.com/ubuntu/ jammy partner" | tee -a /etc/apt/sources.list

# Generic Linux packages
RUN apt-get update --yes && apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends gnupg2=2.2.27-3ubuntu2.1

# ODBC PostgreSQL drivers
RUN apt-get install --yes libodbcinst2 unixodbc unixodbc-dev odbcinst odbc-postgresql && \
    sed -i -r 's/=(psqlodbc(a|w).so|libodbcpsqlS.so)/=\/usr\/lib\/x86_64-linux-gnu\/odbc\/\1/' /etc/odbcinst.ini

# ODBC SQL Server drivers
RUN apt-get install --yes --no-install-recommends freetds-dev=1.3.6-1 freetds-bin=1.3.6-1 tdsodbc=1.3.6-1 && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64,armhf,arm64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft.list && \
    apt-get update --yes && \
    ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql18=18.2.1.1-1

# Create SQL Server ODBC Driver: FreeTDS
RUN echo "[FreeTDS]" >> /etc/odbcinst.ini
RUN echo "Description=FreeTDS" >> /etc/odbcinst.ini
RUN echo "Driver=/usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so" >> /etc/odbcinst.ini
RUN echo "Setup=/usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini
RUN echo "" >> /etc/odbcinst.ini

# Git Large File Storage extension
RUN wget -qO- https://packagecloud.io/github/git-lfs/gpgkey | gpg --dearmor > /usr/share/keyrings/github_git-lfs.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/github_git-lfs.gpg] https://packagecloud.io/github/git-lfs/ubuntu/ jammy main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    echo "deb-src [signed-by=/usr/share/keyrings/github_git-lfs.gpg] https://packagecloud.io/github/git-lfs/ubuntu/ jammy main" > /etc/apt/sources.list.d/github_git-lfs.list && \
    apt-get update --yes && \
    apt-get install --yes --no-install-recommends git-lfs && \
    su - jovyan && cd ~ && git lfs install && exit

# Chrome (for Selenium)
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install --yes --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm -f ./google-chrome-stable_current_amd64.deb

# Quarto
RUN wget -q https://github.com/quarto-dev/quarto-cli/releases/download/v1.4.543/quarto-1.4.543-linux-amd64.deb && \
    apt-get install --yes --no-install-recommends ./quarto-1.4.543-linux-amd64.deb && \
    rm -f ./quarto-1.4.543-linux-amd64.deb

# Clear packages not required during runtime
RUN apt-get purge --yes gnupg2 && \
    apt-get autoremove --yes && apt-get clean --yes && rm -rf /var/lib/apt/lists/*


###############################################################################
# Conda, Python, R packages                                                   #
###############################################################################

# Install packages as final user (prevents ~/.cache/conda to be owned by root)
USER ${NB_UID}

# Upgrade Conda
RUN conda update --y conda && \
    conda update --all --y

# Python dependencies
#RUN pip install --no-cache-dir pip==23.1.2 && \
#    pip install --no-cache-dir pre-commit==3.3.3 nbstripout==0.6.1

RUN conda install --quiet --yes \
      psycopg2 \
      pyodbc \
      pymssql

# R minimum general-use dependencies
RUN conda install --quiet --y --channel r \
      r-bit64 \
      r-arrow \
      r-here \
      r-tidyverse \
      r-config \
      r-odbc

# Clean conda after install
RUN conda clean --all --force-pkgs-dirs --y

# Reset user to root to continue setup
USER root


###############################################################################
# Prepare working directory                                                   #
###############################################################################

RUN mkdir -p ${JUPYTER_WORKDIR}
RUN chown -R ${NB_UID}:${NB_GID} ${JUPYTER_WORKDIR}

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
WORKDIR ${JUPYTER_WORKDIR}

COPY --chown=${NB_UID}:${NB_GID} entrypoint.sh /usr/bin/.
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT entrypoint.sh 
