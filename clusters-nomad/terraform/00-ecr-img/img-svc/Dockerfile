FROM mhart/alpine-node:8.7.0
WORKDIR /wd
COPY server.js server.js
COPY package.json package.json
RUN npm install --production
EXPOSE 8080
CMD node server.js
