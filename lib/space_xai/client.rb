require "net/http"
require "json"
require "uri"

module SpaceXai
  class Client
    BASE_URL = "https://api.x.ai/v1"
    DEFAULT_MODEL = "grok-4.6"

    def initialize(api_key: ENV["XAI_API_KEY"], model: ENV.fetch("XAI_MODEL", DEFAULT_MODEL))
      @api_key = api_key
      @model = model
    end

    def configured?
      @api_key.present?
    end

    def complete(messages:, model: nil, json_schema: nil)
      raise SpaceXai::ConfigurationError, "XAI_API_KEY is not set" unless configured?

      payload = {
        model: model.presence || @model,
        messages: messages
      }
      payload[:response_format] = { type: "json_schema", json_schema: json_schema } if json_schema

      body = post("/chat/completions", payload)
      choice = body.dig("choices", 0, "message", "content")
      raise Error, "Empty response from SpaceXAI" if choice.blank?
      choice
    end

    private
      def post(path, payload)
        uri = URI("#{BASE_URL}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.read_timeout = 120
        http.open_timeout = 10

        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request.body = JSON.generate(payload)

        response = http.request(request)
        parsed = parse_json(response.body)

        unless response.is_a?(Net::HTTPSuccess)
          message = parsed["error"]&.then { |error| error.is_a?(Hash) ? error["message"] : error } || response.body
          raise Error, "SpaceXAI #{response.code}: #{message}"
        end

        parsed
      end

      def parse_json(raw)
        JSON.parse(raw)
      rescue JSON::ParserError
        {}
      end
  end
end
