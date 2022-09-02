FROM public.ecr.aws/z7w4g5k0/mirrors:alpine-build AS build
VOLUME /tmp

WORKDIR /app

COPY . /app/

RUN npm ci

RUN npm run build

RUN npm prune --production --ignore-scripts
FROM public.ecr.aws/z7w4g5k0/mirrors:alpine-final AS final

RUN apk add --update nodejs
RUN apk add --update npm
RUN addgroup -S node && adduser -S node -G node
USER node
RUN mkdir /home/node/app
WORKDIR /home/node/app

COPY --from=build --chown=node:node /app/package*.json /home/node/app/
COPY --from=build --chown=node:node /app/dist /home/node/app/dist
COPY --from=build --chown=node:node /app/node_modules/ /home/node/app/node_modules/
EXPOSE 3000

CMD ["node", "dist/main.js"]