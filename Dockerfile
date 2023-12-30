# FROM node:latest
# WORKDIR /app
# RUN npm install -g npm@9
# COPY package*.json .
# COPY themes themes
# COPY extensions extensions
# COPY public public
# COPY media media
# COPY config config
# COPY translations translations
# RUN npm install
# RUN npm install @evershop/evershop
# COPY . .
# RUN npm run build

# EXPOSE 80
# CMD ["npm", "run", "start"]

FROM node
WORKDIR /app
COPY package*.json ./
COPY . .
RUN npm install
# RUN npm install @evershop/evershop
RUN npm run build
EXPOSE 80
CMD ["npm", "run", "start"]