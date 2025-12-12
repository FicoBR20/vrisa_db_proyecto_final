FROM postgres:14

ENV POSTGRES_USER=fico
ENV POSTGRES PASSWORD=123
ENV POSGRES_DB=vrisa_db


COPY ./*.sql /docker-entrypoint-initdb.d/


EXPOSE 5432