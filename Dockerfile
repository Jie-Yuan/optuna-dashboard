FROM node:14 AS front-builder
WORKDIR /usr/src

ADD ./package.json /usr/src/package.json
ADD ./package-lock.json /usr/src/package-lock.json
RUN npm install

ADD ./tsconfig.json /usr/src/tsconfig.json
ADD ./webpack.config.js /usr/src/webpack.config.js
ADD ./optuna_dashboard/static/ /usr/src/optuna_dashboard/static
RUN mkdir -p /usr/src/optuna_dashboard/public

ENV NODE_OPTIONS='--max-old-space-size=8000'
RUN npm run build:prd

FROM python:3.8

WORKDIR /usr/src
RUN pip install --upgrade pip setuptools
RUN pip install --no-cache-dir --progress-bar off PyMySQL cryptography psycopg2-binary

ADD ./setup.cfg /usr/src/setup.cfg
ADD ./setup.py /usr/src/setup.py
ADD ./optuna_dashboard /usr/src/optuna_dashboard
RUN pip install --no-cache-dir --progress-bar off .

COPY --from=front-builder /usr/src/optuna_dashboard/public/bundle.js /usr/src/optuna_dashboard/public/bundle.js
COPY --from=front-builder /usr/src/optuna_dashboard/public/bundle.js.LICENSE.txt /usr/src/optuna_dashboard/public/bundle.js.LICENSE.txt

ENTRYPOINT ["optuna-dashboard"]
