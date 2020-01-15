FROM node:8.12.0-slim

MAINTAINER georg.waltner@gmail.com

WORKDIR /home/node/app

COPY package*.json /home/node/app/

RUN npm install

RUN /bin/sh -c 'curl https://install.meteor.com/ | sh'

COPY ./ /home/node/app

RUN mkdir -p /home/node/app/input_img/ /home/node/app/output_img/

EXPOSE 3000
EXPOSE 3001

# RUN meteor update --all-packages --allow-superuser

CMD [ "npm", "start" ]
