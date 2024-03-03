
# Используем официальный образ Swift
FROM swift

# Устанавливаем рабочую директорию в контейнере
WORKDIR /app

# Копируем файлы проекта в контейнер
COPY . .

# Сборка проекта
RUN swift build -c release

# Команда по умолчанию для запуска приложения
CMD ["./.build/release/spendingtrackercoredata"]
