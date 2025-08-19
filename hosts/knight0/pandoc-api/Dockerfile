FROM pandoc/extra:latest

# Install Python and FastAPI
RUN apk add --no-cache python3 py3-pip && \
    pip3 install --upgrade pip

# Copy app and install deps
COPY app /app
WORKDIR /app
RUN pip install -r requirements.txt

# Expose API on port 8080
EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
