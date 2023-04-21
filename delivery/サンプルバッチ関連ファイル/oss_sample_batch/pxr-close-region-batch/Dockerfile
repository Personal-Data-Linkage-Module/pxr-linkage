FROM node:12

WORKDIR /usr/src/app

# Install node modules
COPY package*.json ./
RUN npm install

# Copy
COPY . ./

# Start a container with this line.
ENTRYPOINT [ ":" ]
