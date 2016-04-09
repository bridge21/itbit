module Itbit
  # Public market data for a pair, do not use directly, use
  # {XBTUSDMarketData}, {XBTSGDMarketData} and {XBTEURMarketData} instead.
  # @see http://api-portal.anypoint.mulesoft.com/itbit/api/itbit-exchange#raml-console
  class MarketData

    # The symbol ticker conveniently formatted as a ruby Hash with
    # symbolized keys.
    def self.ticker
      public_request("/markets/#{symbol.upcase}/ticker").reduce({}) do |ticker, pair|
        key = pair.first.underscore.to_sym
        value = case key
        when :pair then pair[1].underscore.to_sym
        when :servertime_utc then Time.parse(pair[1]).to_i
        else pair[1].to_d
        end
        ticker[key] = value
        ticker
      end
    end

    # The symbol order book as a Hash with two keys: bids and asks.
    # Each of them is a list of list consisting of [price, quantity]
    def self.orders
      order_book = public_request("/markets/#{symbol.upcase}/order_book").symbolize_keys
      order_book.each do |key, value|
        order_book[key] = value.collect { |tuple| tuple.collect(&:to_d) }
      end
    end

    # The symbol trades since tid (transaction id) as a list of hashes
    # that look like {date: unix_timestamp, price: 123.5, amount: 1.97, tid: 98375}
    def self.trades(tid = 0)
      trades = public_request("/markets/#{symbol.upcase}/trades", since: tid)
      trades['recentTrades'].collect do |t|
        { price: t['price'].to_d, amount: t['amount'].to_d,
          tid: t['matchNumber'], date: DateTime.parse(t['timestamp']).to_i
        }.with_indifferent_access
      end
    end

    # @visibility private
    def self.public_request(path, options = { })    
      url = "#{Api.api_url}#{path}"
      url << "?#{options.to_query}" if options.any?
      rest_cl = RestClient::Request.execute :method => :get, :url => url, :ssl_version => 'SSLv23'
      JSON.parse(rest_cl)
    end
  end

  # A {MarketData} for the Bitcoin-USD pair.
  class XBTUSDMarketData < MarketData
    def self.symbol
      'xbtusd'
    end
  end

  # A {MarketData} for the Bitcoin-SGD pair.
  class XBTSGDMarketData < MarketData
    def self.symbol
      'xbtsgd'
    end
  end

  # A {MarketData} for the Bitcoin-EUR pair.
  class XBTEURMarketData < MarketData
    def self.symbol
      'xbteur'
    end
  end
end
