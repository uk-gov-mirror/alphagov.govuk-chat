module AnswerComposition::MultipleGuardrail
  class Prompt
    Guardrail = Data.define(:key, :name, :content)

    def initialize(prompt_name)
      prompts = AnswerComposition::Pipeline::Prompts.config(
        prompt_name, Checker.bedrock_model
      )

      raise "No LLM prompts found for #{prompt_name}" unless prompts

      @prompts = prompts
    end

    def system_prompt
      guardrails_content = guardrails.map { |g| "#{g.key}. #{g.content}" }
                                     .join("\n")

      prompts.fetch(:system_prompt)
             .sub("{guardrails}", guardrails_content)
             .sub("{date}", Date.current.strftime("%A %d %B %Y"))
    end

    def user_prompt(input)
      prompts.fetch(:user_prompt).sub("{input}", input)
    end

    def guardrails
      @guardrails ||= prompts.fetch(:guardrails).map.with_index(1) do |name, key|
        content = prompts.fetch(:guardrail_definitions).fetch(name)
        Guardrail.new(key:, name:, content:)
      end
    end

    def json_schema
      if Checker.bedrock_model == :claude_sonnet_4_0
        raise NotImplementedError, "Structured responses are not supported for claude_sonnet_4_0"
      end

      schema = prompts.fetch(:json_schema)
      enum_values = (1..guardrails.length).to_a
      schema.fetch("schema").fetch("items")["enum"] = enum_values
      schema
    end

  private

    attr_reader :prompts
  end
end
