FROM quay.io/jupyter/datascience-notebook:2023-11-07

SHELL ["/bin/bash", "-o", "pipefail", "-e", "-u", "-x", "-c"]

ARG VOLUME_MOUNT_PATH

USER root

ENV MSSQL_DRIVER="ODBC Driver 18 for SQL Server"
ENV PATH="/opt/mssql-tools18/bin:${PATH}"

# In case people want to use ODBC drivers.
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends gnupg2=2.2.27-3ubuntu2.1 freetds-dev=1.3.6-1 freetds-bin=1.3.6-1 tdsodbc=1.3.6-1 && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg && \
    apt-get purge --yes gnupg2 && \
    echo "deb [arch=amd64,armhf,arm64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft.list && \
    apt-get update --yes && \
    ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql18=18.2.1.1-1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir pip==23.1.2 && \
    pip install --no-cache-dir pre-commit==3.3.3 nbstripout==0.6.1

RUN mkdir -p ${VOLUME_MOUNT_PATH}
RUN chown -R ${NB_UID}:${NB_GID} ${VOLUME_MOUNT_PATH}

# Set up for Windows Authentication.
RUN echo "[FreeTDS]" >> /etc/odbcinst.ini
RUN echo "Description=FreeTDS" >> /etc/odbcinst.ini
RUN echo "Driver=/usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so" >> /etc/odbcinst.ini
RUN echo "Setup=/usr/lib/x86_64-linux-gnu/odbc/libtdsS.so" >> /etc/odbcinst.ini
RUN echo "" >> /etc/odbcinst.ini

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}
WORKDIR ${VOLUME_MOUNT_PATH}
