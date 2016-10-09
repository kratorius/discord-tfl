# frozen_string_literal: true
module Bot
  module Commands
    extend Discordrb::EventContainer
    extend Discordrb::Commands::CommandContainer
    extend Loggy

    MAX_LIST_RESPONSE_COUNT = 30
    MAX_QUERY_LENGTH = 35

    mention do |event|
      unless event.from_bot?
        args = event.message.text.split.reject do |word|
          # Terrible hack to work around the fact that there's no way to
          # exclude mentions directly from a message.
          mentions = event.message.mentions.map { |mention| "<@#{mention.id}>" }
          mentions.include? word
        end
        on_status(event, *args)
      end
    end
    command(:status) { |event, *args| on_status(event, *args) }

    def self.on_status(event, *args)
      return if event.from_bot?

      type, entity = status_decode(args)

      log "[command/status(from:#{event.user.name})] " \
        "\"#{args.join(' ')}\" (resolved to #{entity})"

      begin
        response = TFL.status(type, entity)
      rescue Tfl::InvalidLineException
        event << "#{entity}: invalid line"
        return nil
      end

      if response.respond_to?(:each)
        status_list(event, entity, response)
      else
        status_single_item(event, response)
      end

      nil
    end

    def self.status_decode(args)
      if args.empty?
        entity = Tfl::Const::Mode::METROPOLITAN_TRAINS
        type = :by_mode
      else
        entity = Tfl::IdResolver.resolve(args.join(" ").
            truncate(MAX_QUERY_LENGTH).
            downcase)

        type = :by_id
        type = :by_mode if Tfl::Const::Mode.valid? entity
      end

      [type, entity]
    end

    def self.status_list(event, original_query, line_statuses)
      if line_statuses.empty?
        event << "TfL did not return any data for #{original_query}"
        return
      end

      if line_statuses.count > MAX_LIST_RESPONSE_COUNT
        event << "Wow. Much data. Not show."
        return
      end

      line_statuses.each do |line|
        status_single_item(event, line, detailed: line_statuses.count == 1)
      end
    end

    def self.status_single_item(event, line, detailed: true)
      if line.nil?
        event << "#{entity}: TfL did not return any data :("
      elsif line.good_service? || !detailed
        event << "#{line.display_name}: #{line.current_status}"
      else
        line.disruptions.each do |disruption|
          event << "#{line.display_name}: #{disruption}"
        end
      end
    end
  end
end
