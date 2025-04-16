FROM nvidia/cuda:12.6.3-cudnn-devel-ubuntu24.04

# Set environment variables to avoid interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3-dev \
    python3-venv \
    git \
    wget \
    curl \
    nodejs \
    npm \
    lsb-release \
    gpg \
    && rm -rf /var/lib/apt/lists/*

# Create and activate a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install PyTorch with CUDA support in the virtual environment
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126

# Install uv (Python package installer)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install code-server (VS Code Web)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install some VS Code extensions
RUN code-server --install-extension ms-python.python \
    code-server --install-extension ms-toolsai.jupyter

# Verify installations
RUN python -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available()); print('CUDA version:', torch.version.cuda if torch.cuda.is_available() else 'N/A')"
# Verify uv
RUN uv --version

# Set working directory
WORKDIR /workspace

# Expose the code-server port
EXPOSE 8080

# Start code-server
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none", "/workspace"]
