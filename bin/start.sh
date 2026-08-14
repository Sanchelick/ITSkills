#!/usr/bin/env bash
set -e

echo "==> Проверка подключения к базе данных..."

# Цикл ожидания готовности PostgreSQL
until bundle exec rails db:prepare 2>/dev/null; do
  echo "==> База данных PostgreSQL еще запускается. Повторная попытка через 2 секунды..."
  sleep 2
done

echo "==> База данных готова!"
echo "==> Запуск веб-сервера Puma на 0.0.0.0:${PORT:-3000}..."

# Явно связываем Puma с 0.0.0.0 и динамическим портом PORT
exec bundle exec puma -C config/puma.rb -b tcp://0.0.0.0:${PORT:-3000}
