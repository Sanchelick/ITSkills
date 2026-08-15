module Gemini
  class QuizGenerator
    # Используем модель из ENV или актуальное дефолтное название gemini-1.5-flash
    DEFAULT_MODEL = "gemini-3.6-flash"

    def initialize(skill_name:, target_level:, question_count: 10)
      @skill_name = skill_name
      @target_level = target_level
      @question_count = question_count
      @api_key = ENV.fetch("GEMINI_API_KEY", nil)
      @model_name = ENV.fetch("GEMINI_MODEL", DEFAULT_MODEL)
    end

    def call
      unless @api_key.present?
        Rails.logger.error("[Gemini API Error] GEMINI_API_KEY не установлен в ENV!")
        return nil
      end

      Rails.logger.info("[Gemini API] Отправка запроса на генерацию теста для #{@skill_name} (#{@target_level}) с моделью #{@model_name}...")

      # Выполняем HTTP-запрос к Gemini API
      response = Faraday.post(api_endpoint) do |req|
        req.headers["Content-Type"] = "application/json"
        req.options.timeout = 120
        req.options.open_timeout = 15
        req.body = request_payload.to_json
      end

      Rails.logger.info("[Gemini API] Ответ получен. HTTP Status: #{response.status}")

      unless response.success?
        Rails.logger.error("[Gemini API HTTP Error] Статус: #{response.status}, Тело ответа: #{response.body}")
        return nil
      end

      parsed_response = JSON.parse(response.body)
      raw_json_text = parsed_response.dig("candidates", 0, "content", "parts", 0, "text")

      unless raw_json_text.present?
        Rails.logger.error("[Gemini API Error] В ответе от ИИ отсутствует текст. Ответ: #{parsed_response}")
        return nil
      end

      JSON.parse(raw_json_text)

    rescue Faraday::ConnectionFailed => e
      Rails.logger.error("[Gemini API Network Error] Ошибка соединения: #{e.message}")
      nil
    rescue Faraday::TimeoutError => e
      Rails.logger.error("[Gemini API Network Error] Таймаут соединения: #{e.message}")
      nil
    rescue JSON::ParserError => e
      Rails.logger.error("[Gemini API JSON Error] Ошибка парсинга JSON: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("[Gemini API Unexpected Error] Непредвиденная ошибка: #{e.class} - #{e.message}")
      nil
    end

    private

    # Динамическое формирование URL с учётом выбранной модели
    def api_endpoint
      "https://generativelanguage.googleapis.com/v1beta/models/#{@model_name}:generateContent?key=#{@api_key}"
    end

    def request_payload
      prompt = <<~PROMPT
        Сгенерируй тест для проверки знаний по технологии "#{@skill_name}" на уровень "#{@target_level}".
        Всего вопросов: #{@question_count}.
        Формат должен быть смешанным: часть вопросов с выбором ответа (mcq), часть — с открытым кодом/задачей (code_submission).

        Верни ответ СТРОГО в формате JSON без разметки Markdown:
        {
          "questions": [
            {
              "type": "mcq",
              "prompt": "Текст вопроса?",
              "options": ["Вариант A", "Вариант B", "Вариант C", "Вариант D"],
              "correct_answer": "Вариант A"
            },
            {
              "type": "code_submission",
              "prompt": "Текст задачи по программированию",
              "code_starter": "def solution\n  # ваш код\nend",
              "correct_answer": "Пример эталонного решения"
            }
          ]
        }
      PROMPT

      {
        contents: [ { parts: [ { text: prompt } ] } ],
        generationConfig: { responseMimeType: "application/json" }
      }
    end
  end
end
