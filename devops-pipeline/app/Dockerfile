# ─── Stage 1: Builder ────────────────────────────────────────────────────────
FROM amazoncorretto:17-alpine AS builder

RUN groupadd -r appuser && useradd -r -g appuser appuser

RUN install -o appuser -g appuser -d /opt/jmx_exporter /etc/jmx_exporter

ADD --chown=appuser:appuser \
    https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.13.0/jmx_prometheus_javaagent-0.13.0.jar \
    /opt/jmx_exporter/jmx_prometheus_javaagent.jar

COPY --chown=appuser:appuser prometheus-jmx-config.yml /etc/jmx_exporter/prometheus-jmx-config.yml

# ─── Stage 2: Runtime ────────────────────────────────────────────────────────
FROM amazoncorretto:17-alpine

RUN apk add --no-cache \
    shadow \
    curl \
    rpm \
    net-tools \
    sudo

RUN groupadd -r appuser && useradd -r -g appuser appuser

RUN install -o appuser -g appuser -d /opt/jmx_exporter /etc/jmx_exporter

# Copy JMX agent and config from builder
COPY --from=builder --chown=appuser:appuser \
    /opt/jmx_exporter/jmx_prometheus_javaagent.jar \
    /opt/jmx_exporter/jmx_prometheus_javaagent.jar

COPY --from=builder --chown=appuser:appuser \
    /etc/jmx_exporter/prometheus-jmx-config.yml \
    /etc/jmx_exporter/prometheus-jmx-config.yml

ARG JAR_FILE
ARG appName
ENV appName=${appName}
ENV Xmx=${max_heap_size}
ENV Xms=${initial_heap_size}

RUN mkdir -p /data/log/peoplehum/${appName} /data/app/peoplehum/${appName} && \
    chown -R appuser: /data/log/peoplehum/${appName} /data/app/peoplehum/${appName}

USER appuser
WORKDIR /data/app/peoplehum/${appName}

COPY config/ config/
COPY ${JAR_FILE} ${appName}.jar

EXPOSE 8080 5382

ENTRYPOINT ["sh", "-c", "\
    mkdir -p /data/log/peoplehum/${appName}/heap_dump && \
    java -javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent.jar=5382:/etc/jmx_exporter/prometheus-jmx-config.yml \
    -Xms${Xms} -Xmx${Xmx} -Xss256k -Dfile.encoding=UTF-8 -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=250m -XX:+UseG1GC \
    -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/data/log/peoplehum/${appName}/heap_dump/${appName}_$(date +\"%Y-%m-%d_%H-%M-%S\").hprof \
    -jar ${appName}.jar"]