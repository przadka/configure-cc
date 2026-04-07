FROM node:22-slim

# Install only git (needed for claude to work in a repo) + python3 for realism
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create a fresh user with no ~/.claude/ config
RUN useradd -m -s /bin/bash testuser
USER testuser
WORKDIR /home/testuser

# Set up a minimal git repo so claude can operate
RUN git init project && \
    cd project && \
    git config user.email "test@test.com" && \
    git config user.name "Test User"

# Copy skill files into the project
COPY --chown=testuser:testuser .claude/skills/ /home/testuser/project/.claude/skills/

WORKDIR /home/testuser/project

# Entrypoint copies mounted credentials (owned by root) to user-owned location
COPY --chown=testuser:testuser test/entrypoint.sh /home/testuser/entrypoint.sh
ENTRYPOINT ["/bin/bash", "/home/testuser/entrypoint.sh"]
