require "nokogiri"
require "net/http"
require "uri"
require_relative "database"

class AmazonScraper
  BASE_URL = "https://www.amazon.pl"

  def initialize(keyword)
    @keyword = keyword
    @searchkeyword = "/s?k=#{keyword}"
    @products = []
  end

  def scrape
    max_retries = 99
    retries = 0
    doc = nil
    search_url = "#{BASE_URL}#{@keyword}"
    puts "Scraping: #{search_url}"

    begin
      doc = fetch_page(search_url)
      items = doc.css("li.octopus-pc-item.octopus-pc-item-v3")

      if items.empty?
        raise "Brak produktów, ponawiam próbę" if retries < max_retries
        puts "Brak produktów po maksymalnej liczbie prób"
        return
      end
    rescue StandardError => e
      retries += 1
      puts "Błąd pobierania strony: #{e.message} (Próba: #{retries})"
      retry if retries <= max_retries
      return
    end

    items.each do |item|
      # Pobranie nazwy produktu
      title = item.css("div.a-section.octopus-pc-asin-title span").text.strip
      title = "Brak nazwy" if title.empty?

      # Pobranie ceny produktu i oczyszczenie z "zł" oraz spacji
      price = item.css("div.a-section.octopus-pc-asin-price span.a-price span.a-offscreen").text.strip
      price = clean_price(price)

      # Pobranie linku do produktu
      url = item.css("a.a-link-normal.octopus-pc-item-link").attr("href")&.value
      next if url.nil? || url.include?("sspa") # Pomija produkty sponsorowane
      url = "#{BASE_URL}#{url}"

      details = scrape_details(url)

      @products << { title: title, price: price, url: url, details: details }

      Product.create(title: title, price: price, url: url, details: details)
    end
  end

  def scrapeSearch
    max_retries = 99
    retries = 0
    doc = nil

    search_url = "#{BASE_URL}#{@searchkeyword}"
    puts "Scraping: #{search_url}"

    begin
      doc = fetch_page(search_url)
      items = doc.css("div[role='listitem'].s-result-item")

      if items.empty?
        raise "Brak produktów, ponawiam próbę" if retries < max_retries
        puts "Brak produktów po maksymalnej liczbie prób"
        return
      end
    rescue StandardError => e
      retries += 1
      puts "Błąd pobierania strony: #{e.message} (Próba: #{retries})"
      retry if retries <= max_retries
      return
    end

    items.each do |item|
      # Pobranie nazwy produktu z aria-label w h2
      title = item.css("h2 span").text.strip
      title = "Brak nazwy" if title.empty?

      # Pobranie ceny produktu i oczyszczenie z "zł" oraz spacji
      price = item.css("span.a-offscreen").text.strip
      price = clean_price(price)

      # Pobranie linku do produktu
      url = item.css("a.a-link-normal.s-line-clamp-4.s-link-style.a-text-normal").attr("href")&.value
      next if url.nil? || url.include?("sspa") # Pomija produkty sponsorowane
      url = "#{BASE_URL}#{url}"

      details = scrape_details(url)

      @products << { title: title, price: price, url: url, details: details }

      Product.create(title: title, price: price, url: url, details: details)
    end
  end

  private

  def fetch_page(url)
    max_retries = 99
    retries = 0

    begin
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = random_user_agent

      response = http.request(request)

      case response.code.to_i
      when 200
        return Nokogiri::HTML(response.body)
      when 429
        wait_time = 2**retries
        puts "Zbyt wiele żądań. Czekam #{wait_time} sekundy..."
        sleep(wait_time)
        raise "Too Many Requests"
      else
        raise "Błąd HTTP: #{response.code}"
      end
    rescue StandardError => e
      retries += 1
      puts "Błąd pobierania strony: #{e.message} (Próba: #{retries})"
      sleep(rand(1..3)) # Losowy czas oczekiwania
      retry if retries < max_retries
      return nil
    end
  end

  def scrape_details(url)
    max_retries = 99
    retries = 0
    begin
      doc = fetch_page(url)
      details = doc.at_css("div#feature-bullets")&.text

      if details.nil? || details.strip.empty?
        raise "Brak danych, ponawiam próbę" if retries < max_retries
        return "Brak danych"
      end

      clean_details(details)
    rescue StandardError => e
      retries += 1
      puts "Błąd pobierania szczegółów: #{e.message} (Próba: #{retries})"
      retry if retries <= max_retries
      "Brak danych"
    end
  end

  def clean_details(text)
    text.gsub(/\s+/, " ").strip # Usuwa wielokrotne spacje, nowe linie i przycina tekst
  end

  def clean_price(price)
    return "Brak ceny" if price.empty?

    price.gsub(/[^\d,]/, "") # Usuwa wszystko poza cyframi i przecinkami
  end
end

def random_user_agent
  user_agents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
  ]
  user_agents.sample
end

if __FILE__ == $0
  category = "/b/?_encoding=UTF8&ie=UTF8&node=20657432031&ref_=topnav_storetab_electronics"
  keyword = "Klawiatura"

  # scraper = AmazonScraper.new(category)
  # scraper.scrape
  # puts "Finished scraping category"

  scraper2 = AmazonScraper.new(keyword)
  scraper2.scrapeSearch
  puts "Finished scraping keyword"

end
