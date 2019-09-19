require 'sinatra/base'

class LighthouseApi < Sinatra::Base
  set :bind, '0.0.0.0'

  get '/' do
    uri = URI.parse(request.params['url']) rescue ''

    case
    when URI::HTTP === uri
      msg = `lighthouse --chrome-flags="--headless --disable-gpu --no-sandbox" #{uri.to_s} --output json`
      { status: 'success', msg: msg.force_encoding('utf-8') }.to_json
    else
      { status: 'error', msg: 'no valid url provided' }.to_json
    end
  end

  get '/help' do
    'on progress'
  end
end

LighthouseApi.run!

