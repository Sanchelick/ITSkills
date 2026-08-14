
#!/usr/bin/env bash
# Завершать скрипт при критических ошибках
set -e

echo "==> Проверка подключения к базе данных..."

# Цикл ожидания: пытаемся выполнить db:prepare, пока база не ответит успешно
until bundle exec rails db:prepare 2>/dev/null; do
  echo "==> База данных PostgreSQL еще запускается. Повторная попытка через 2 секунды..."
  sleep 2
done

echo "==> База данных готова и миграции выполнены успешно!"
echo "==> Запуск веб-сервера Puma..."

# Запускаем Puma на порту, который выделил Railway
exec bundle exec puma -C config/puma.rb -p ${PORT:-3000}
