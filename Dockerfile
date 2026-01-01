FROM codercom/enterprise-base:latest

# Switch to root to install system packages
USER root

# Update package list and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    bash \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    unzip \
    nano \
    gpg \
    gpg-agent \
    dirmngr \
    && rm -rf /var/lib/apt/lists/*

# Switch to coder user for all user-specific installations
USER coder

# Install Claude Code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install mise
RUN curl https://mise.run | sh

# Add mise and claude to PATH
ENV PATH="/home/coder/.local/bin:/home/coder/.local/share/mise/shims:${PATH}"

# Configure mise
RUN echo 'eval "$(mise activate bash)"' >> /home/coder/.bashrc

# Install development tools
RUN mise install node@20 && \
    mise install python@3.12 && \
    mise install go@latest && \
    mise install pnpm@latest && \
    mise install bun@latest && \
    mise install rust@latest && \
    mise global node@20 python@3.12 go@latest pnpm@latest bun@latest rust@latest

RUN curl -o /tmp/github.copilot.vsix -LSsf \
      "https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"
    
RUN curl -o /tmp/github.copilot-chat.vsix -LSsf \
      "https://github.gallery.vsassets.io/_apis/public/gallery/publisher/github/extension/copilot-chat/latest/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

# Add claude alias
RUN echo 'alias clauded="claude --dangerously-skip-permissions"' >> /home/coder/.bashrc
RUN npm install -g @fresh-editor/fresh-editor
RUN npm install -g @google/gemini-cli

# Set working directory
WORKDIR /home/coder

# Verify installations
RUN mise list && \
    node --version && \
    python --version && \
    go version && \
    pnpm --version && \
    bun --version && \
    claude --version && \
    fresh --version