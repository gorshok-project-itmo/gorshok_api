class Esp32WebsocketMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    if Faye::WebSocket.websocket?(env) && env['PATH_INFO'] == '/esp32'
      ws = Faye::WebSocket.new(env)
      handler = Esp32::MessageHandler.new(ws)

      ws.on :open do |event|
        Rails.logger.info "[ESP32] New WebSocket connection"
      end

      ws.on :message do |event|
        handler.handle(event.data)
      end

      ws.on :close do |event|
        Rails.logger.info "[ESP32] WebSocket closed: #{event.code} #{event.reason}"
        # ConnectionManager.unregister будет вызван через handler
      end

      # Return async Rack response
      ws.rack_response
    else
      @app.call(env)
    end
  end
end
