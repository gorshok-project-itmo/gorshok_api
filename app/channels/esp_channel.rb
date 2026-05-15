# app/channels/esp_channel.rb

class EspChannel < ApplicationCable::Channel

  def subscribed
    stream_from "esp_channel"

    puts "ESP connected"
  end

  def unsubscribed
    puts "ESP disconnected"
  end

  # получение сообщений от ESP
  def receive(data)

    puts "DATA FROM ESP:"
    puts data.inspect

    humidity = data["humidity"]
    temperature = data["temperature"]

    puts "Humidity: #{humidity}"
    puts "Temperature: #{temperature}"

    # тут можно сохранить в БД
  end
end
