module Itbit
  # Public market data for a pair, do not use directly, use
  # {XBTUSDMarketData}, {XBTSGDMarketData} and {XBTEURMarketData} instead.
  # @see http://api-portal.anypoint.mulesoft.com/itbit/api/itbit-exchange#raml-console
  class MarketData

    # The symbol ticker conveniently formatted as a ruby Hash with
    # symbolized keys.
    def self.ticker
      ticker = Api.request(:get, "/markets/#{self.symbol}/ticker").symbolize_keys
      ticker.each do |key, value|
        next if [:pair, :servertimeUTC].include? key
        ticker[key] = value.to_d
      end
      ticker[:servertimeUTC] = Time.parse(ticker[:servertimeUTC])
      ticker
    end

    # The symbol order book as a Hash with two keys: bids and asks.
    # Each of them is a list of list consisting of [price, quantity]
    def self.orders
      order_book = old_request("/markets/#{self.symbol.upcase}/orders").symbolize_keys
      order_book.each do |key, value|
        order_book[key] = value.collect { |tuple| tuple.collect(&:to_d) }
      end
    end

    # The symbol trades since tid (transaction id) as a list of hashes
    # that look like {date: unix_timestamp, price: 123.5, amount: 1.97, tid: 98375}
    def self.trades(tid = 0)
      trades = old_request("/markets/#{symbol.upcase}/trades", since: tid)
      trades.collect do |t|
        t.merge(price: t['price'].to_d, amount: t['amount'].to_d)
          .with_indifferent_access
      end
    end

    # @visibility private
    def self.old_request(path, options = { })
      url = "https://www.itbit.com/api/v2#{path}"
      url << "?#{options.to_query}" if options.any?
      JSON.parse(RestClient.get(url))
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