# ==============================================================================
# Production Dockerfile for Sunrise Dental Clinic
# Stack: Java 21, Apache Tomcat 10.1 (Jakarta Servlet 6.0), JSP, MySQL
# Deployment Target: Render (Web Service) / Cloud Container
# Context: Eclipse Dynamic Web Project (Project root: Sunrise_Dental)
# ==============================================================================

# ------------------------------------------------------------------------------
# Stage 1: Build Stage (Compile Production Java Sources)
# ------------------------------------------------------------------------------
FROM tomcat:10.1-jdk21-temurin AS builder

WORKDIR /build

# Copy web application skeleton (JSPs, CSS, JS, WEB-INF/web.xml, WEB-INF/lib)
COPY src/main/webapp ./webapp

# Copy Java source code
COPY src/main/java ./src

# Clean any existing classes, discover production Java sources (excluding test classes),
# and compile using the existing pre-packaged libraries in WEB-INF/lib
RUN rm -rf ./webapp/WEB-INF/classes && \
    mkdir -p ./webapp/WEB-INF/classes && \
    find ./src -type f -name "*.java" ! -path "*/test/*" > sources.txt && \
    javac -encoding UTF-8 \
          -cp "./webapp/WEB-INF/lib/*" \
          -d ./webapp/WEB-INF/classes \
          @sources.txt

# ------------------------------------------------------------------------------
# Stage 2: Runtime Stage (Production Tomcat 10.1 Container)
# ------------------------------------------------------------------------------
FROM tomcat:10.1-jdk21-temurin

WORKDIR /usr/local/tomcat

# Remove default Tomcat web applications (ROOT, docs, examples, manager, host-manager)
RUN rm -rf webapps/*

# Deploy the compiled web application to Tomcat ROOT context
COPY --from=builder /build/webapp webapps/ROOT

# Render dynamically assigns a port via the PORT environment variable (default: 10000)
ENV 10000
EXPOSE 10000

# Dynamically bind Tomcat HTTP connector to Render's $PORT and start Catalina
CMD ["sh", "-c", "sed -i \"s/port=\\\"8080\\\"/port=\\\"${PORT:-10000}\\\"/g\" conf/server.xml && exec catalina.sh run"]
