# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables to non-interactive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and Shadowsocks-libev
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y shadowsocks-libev ufw

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose the port for Shadowsocks
EXPOSE 8388

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]