require 'faraday'
require 'faraday_middleware/multi_json'

module NasneChecker
  class Nasne
    attr_reader :host

    def initialize(host)
      @host = host
      @clients = {}
    end

    def reserved_list
      get(
        '64220', '/schedule/reservedListGet',
        searchCriteria: 0,
        filter: 0,
        startingIndex: 0,
        requestedCount: 0,
        sortCriteria: 0,
        withDescriptionLong: 0,
        withUserData: 1
      ).body
    end

    def hdd_list
      get('64210', '/status/HDDListGet').body
    end

    def hdd_info(id)
      get('64210', '/status/HDDInfoGet', id: id).body
    end

    def hdd_detail
      hdd = hdd_list[:HDD].select{ |info| info[:registerFlag] == 1 }
      hdd.map {|info| hdd_info(info[:id])[:HDD] }
    end

    private

    def client(port)
      @clients[port] ||= Faraday.new(url: "http://#{host}:#{port}") do |faraday|
        faraday.request  :url_encoded
        faraday.response :raise_error
        faraday.response :multi_json, symbolize_keys: true
        faraday.adapter  Faraday.default_adapter
      end
    end

    def get(port, path, query = nil)
      client(port).get path, query
    end
  end
end
