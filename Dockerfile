# Dockerfile for Postal Coffee

FROM ruby:3.3

# Install OS packages
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      nodejs \
      postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install gems (use Gemfile + Gemfile.lock for caching)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the app
COPY . .

# Make sure tmp and log dirs exist
RUN mkdir -p tmp/pids tmp/cache tmp/sockets log

# Expose Rails port
EXPOSE 3000

# Default command: Rails server
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bin/rails server -b 0.0.0.0 -p 3000"]
