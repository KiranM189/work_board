# Use the Node.js image for building the Node.js part
FROM node:slim

WORKDIR /app

RUN npm init -y
RUN npm install express
RUN npm install multer

# Use the Python image for building the Python part
FROM python:slim

WORKDIR /app

RUN pip install inference
RUN pip install transformers
RUN pip install Pillow  # PIL is now Pillow

COPY server.js /app/server.js
COPY uploads /app/uploads
COPY main.py /app/main.py
COPY image_enhancer.py /app/image_enhancer.py

ENV PORT=5000

CMD ["node", "server.js"]
