module Gemini
  class ResponseEvaluator
    # Актуальная модель по умолчанию, если не переопределена в .env
    DEFAULT_MODEL = "gemini-3.6-flash"

    # Принимаем текст вопроса, ответ пользователя и эталонный ответ/критерии
    def initialize(question_prompt:, user_answer:, correct_answer:)
      @question_prompt = question_prompt
      @user_answer = user_answer
      @correct_answer = correct_answer
      @api_key = ENV.fetch("GEMINI_API_KEY", nil)
      @model_name = ENV.fetch("GEMINI_MODEL", DEFAULT_MODEL)
    end

    def call
      unless @api_key.present?
        Rails.logger.error("[Gemini ResponseEvaluator Error] GEMINI_API_KEY не установлен!")
        return fallback_response("Ошибка конфигурации API на сервере.")
      end

      Rails.logger.info("[Gemini ResponseEvaluator] Оценка ответа с помощью модели #{@model_name}...")

      # Выполняем HTTP-запрос к Gemini API
      response = Faraday.post(api_endpoint) do |req|
        req.headers["Content-Type"] = "application/json"
        req.options.timeout = 15     # Время на получение ответа
        req.options.open_timeout = 5 # Время на установку соединения
        req.body = request_payload.to_json
      end

      Rails.logger.info("[Gemini ResponseEvaluator] Ответ получен. HTTP Status: #{response.status}")

      unless response.success?
        Rails.logger.error("[Gemini ResponseEvaluator HTTP Error] Статус: #{response.status}, Тело: #{response.body}")
        return fallback_response("Ошибка сервиса оценки. Код: #{response.status}")
      end

      parsed_response = JSON.parse(response.body)
      raw_json_text = parsed_response.dig("candidates", 0, "content", "parts", 0, "text")

      unless raw_json_text.present?
        Rails.logger.error("[Gemini ResponseEvaluator Error] ИИ вернул пустой текст.")
        return fallback_response("ИИ не сгенерировал разбор ответа.")
      end

      # Возвращаем сгенерированный результат в виде Hash
      JSON.parse(raw_json_text)

    # Обработка возможных сетевых сбоев и ошибок формата
    rescue Faraday::ConnectionFailed => e
      Rails.logger.error("[Gemini ResponseEvaluator Network Error] Сбой сети: #{e.message}")
      fallback_response("Проблема с сетевым соединением.")
    rescue Faraday::TimeoutError => e
      Rails.logger.error("[Gemini ResponseEvaluator Network Error] Таймаут: #{e.message}")
      fallback_response("Превышено время ожидания ответа ИИ.")
    rescue JSON::ParserError => e
      Rails.logger.error("[Gemini ResponseEvaluator JSON Error] Ошибка парсинга JSON: #{e.message}")
      fallback_response("Ошибка формата ответа ИИ.")
    rescue StandardError => e
      Rails.logger.error("[Gemini ResponseEvaluator Unexpected Error] Ошибка: #{e.class} - #{e.message}")
      fallback_response("Непредвиденная ошибка при проверке.")
    end

    private

    # Динамический адрес API с подстановкой модели
    def api_endpoint
      "https://generativelanguage.googleapis.com/v1beta/models/#{@model_name}:generateContent?key=#{@api_key}"
    end

    # Формирование промпта с жестким требованием верни строго JSON
    def request_payload
      prompt = <<~PROMPT
        Ты — строгий, но справедливый проверяющий преподаватель по программированию.
        Оцени ответ студента на вопрос.

        Текст вопроса:
        #{@question_prompt}

        Эталонный ответ / Критерии проверки:
        #{@correct_answer}

        Ответ студента:
        #{@user_answer}

        Верни результат СТРОГО в формате JSON без разметки Markdown:
        {
          "is_correct": true,
          "feedback": "Краткое и понятное объяснение вердикта на русском языке."
        }
      PROMPT

      {
        contents: [ { parts: [ { text: prompt } ] } ],
        generationConfig: { responseMimeType: "application/json" }
      }
    end

    # Запасной ответ на случай сбоя API
    def fallback_response(message)
      {
        "is_correct" => false,
        "feedback" => "Не удалось автоматически проверить ответ: #{message}"
      }
    end
  end
end
