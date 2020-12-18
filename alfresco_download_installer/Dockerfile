FROM node
VOLUME [ "/alfresco" ]
WORKDIR /alfresco
RUN npm install -g yo && \
npm install --global generator-alfresco-docker-installer
CMD ["yo alfresco-docker-installer"]