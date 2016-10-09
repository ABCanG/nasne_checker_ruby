require 'nasne_checker/version'
require 'nasne_checker/nasne'
require 'slack/poster'
require 'parse-cron'
require 'time'

module NasneChecker
  class << self
    def run(option)
      @nasne = Nasne.new(option[:nasne])
      @slack = Slack::Poster.new(option[:slack])

      if option[:cron]
        cron_parser = CronParser.new(option[:cron])
        loop do
          next_time = cron_parser.next(Time.now)
          sleep next_time - Time.now
          ckeck_nasne
        end
      else
        ckeck_nasne
      end
    end

    private

    attr_reader :slack, :nasne

    def convert_enclose(text)
      enclose = [
        ["\ue0fd", '[手]'],
        ["\ue0fe", '[字]'],
        ["\ue0ff", '[双]'],
        ["\ue180", '[デ]'],
        ["\ue182", '[二]'],
        ["\ue183", '[多]'],
        ["\ue184", '[解]'],
        ["\ue185", '[SS]'],
        ["\ue18c", '[映]'],
        ["\ue18d", '[無]'],
        ["\ue190", '[前]'],
        ["\ue191", '[後]'],
        ["\ue192", '[再]'],
        ["\ue193", '[新]'],
        ["\ue194", '[初]'],
        ["\ue195", '[終]'],
        ["\ue196", '[生]'],
        ["\ue19c", '[他]']
      ]

      enclose.reduce(text) do |converted, target|
        before, after = target
        converted.gsub(before, after)
      end
    end

    def convert_field(item)
      start_time = Time.parse(item[:startDateTime]).strftime('%Y/%m/%d(%a) %H:%M')
      end_time = (Time.parse(item[:startDateTime]) + item[:duration]).strftime('%H:%M')
      {
        title: convert_enclose(item[:title]),
        value: "#{start_time} - #{end_time}",
        short: false
      }
    end

    def post_warning(text, attachment_hash = nil)
      message =
        if attachment_hash
          attachment = Slack::Attachment.new(attachment_hash)
          attachment_hash[:fields].each do |field|
            attachment.add_field field[:title], field[:value], field[:short]
          end
          Slack::Message.new(text, attachment)
        else
          text
        end
      slack.send_message(message)
    end

    def ckeck_nasne
      nasne.hdd_detail.each do |hdd|
        parcent = ((hdd[:usedVolumeSize].to_f / hdd[:totalVolumeSize].to_f) * 100).round
        if parcent > 90
          type = hdd[:internalFlag].zero? ? 'Internal' : 'External'
          post_warning(":floppy_disk: The capacity of the #{type} HDD is insufficient (#{parcent}% used).")
        end
      end

      items = nasne.reserved_list[:item].sort_by { |item| Time.parse(item[:startDateTime]) }

      fields = items.select { |item| (item[:conflictId]).positive? }
        .map { |item| convert_field(item) }

      unless fields.empty?
        post_warning(':warning: Reservations are overlap.', color: 'warning',
          fields: fields)
      end

      fields = items.select { |item| item[:eventId] == 65_536 }
        .map { |item| convert_field(item) }

      unless fields.empty?
        post_warning(':exclamation: Reservations does not exist.', color: 'warning',
          fields: fields)
      end
    end
  end
end
