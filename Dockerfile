FROM openjdk:11 as base
WORKDIR /app
COPY . .
RUN chmod +x gradlew && ./gradlew build

FROM tomcat:9
WORKDIR /webapp
COPY --from=base /app/build/libs/sampleweb-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv sampleweb-0.0.1-SNAPSHOT.war ROOT.war
ENTRYPOINT [ "executable" ]