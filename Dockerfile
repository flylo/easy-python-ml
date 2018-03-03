# starting with the jupyter scipy image because it's got lots of python goodies already
FROM jupyter/scipy-notebook:2410ad57203a

USER root

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

RUN apt-get --allow-unauthenticated update \
  && apt-get install -yqq --no-install-recommends curl \
  && pip install googleapis-common-protos \
  && pip install google-cloud-bigquery \
  && pip install google-api-python-client \
  && pip install google-cloud-storage \
  && pip install fastavro

ENV HOME /home/jovyan

# switch to jovyan user account to install Google Cloud SDK
USER jovyan
WORKDIR ${HOME}
ENV HOME ${HOME}
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
ENV CLOUDSDK_PYTHON /usr/bin/python3
ENV GOOGLE_APPLICATION_CREDENTIALS ${HOME}/google_service_key.json

# Install the Google Cloud SDK. This has to go down here since we're installing as the jovyan user
RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip > google-cloud-sdk.zip \
 && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip \
 && google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true \
 && google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true \
 && sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' google-cloud-sdk/lib/googlecloudsdk/core/config.json \
 && mkdir .ssh

ADD google_service_key.json ${HOME}/google_service_key.json

ENV PATH google-cloud-sdk/bin:$PATH

USER root

# Annoy for nearest neighbor searches.
RUN pip install annoy

# Installing R tidyverse package. See https://github.com/jupyter/docker-stacks/tree/master/r-notebook AND rpy2
RUN conda config --add channels r && \
    conda install --quiet --yes \
    'r-base=3.3.2' \
    'r-irkernel=0.7*' \
    'r-plyr=1.8*' \
    'r-devtools=1.12*' \
    'r-tidyverse=1.0*' \
    'r-shiny=0.14*' \
    'r-rmarkdown=1.2*' \
    'r-forecast=7.3*' \
    'r-rsqlite=1.1*' \
    'r-reshape2=1.4*' \
    'r-nycflights13=0.2*' \
    'r-caret=6.0*' \
    'r-rcurl=1.95*' \
    'r-crayon=1.3*' \
    'r-randomforest=4.6*' \
    'rpy2=2.8.5' && conda clean -tipsy

ADD easy_ml ${HOME}/easy_ml
ADD test ${HOME}/test
ADD setup.py ${HOME}/setup.py

RUN python3 setup.py install \
    && rm setup.py \
    && rm -r build

ENV PATH $PATH:${HOME}/google-cloud-sdk/bin

ADD scripts/auth_and_start.sh /usr/local/bin/
ADD scripts/lookup_value_from_json /usr/local/bin

RUN python3 -m unittest discover -v \
    && rm -r test

CMD ["auth_and_start.sh", "jupyter", "notebook"]
