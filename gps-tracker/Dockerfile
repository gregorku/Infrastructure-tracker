FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN pip install --no-cache-dir fastapi==0.116.1 uvicorn[standard]==0.35.0

COPY app.py /app/app.py
COPY static /app/static

RUN useradd --system --create-home --uid 10001 gps \
    && mkdir -p /data \
    && chown -R gps:gps /app /data

USER gps

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
