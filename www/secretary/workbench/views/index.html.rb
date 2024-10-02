require 'whimsy/asf/status'

_html do
  if ENV['RACK_BASE_URI'].to_s + '/' == _.env['REQUEST_URI']
    # not sure why Passenger/rack is eating the trailing slash here.
    # add it back in.
    _base href: _.env['REQUEST_URI']
  end

  unavailable = Status.updates_disallowed_reason # are updates disallowed?
  noticetext, noticepath = Status.notice

  _title 'ASF Secretary Mail'
  _link rel: 'stylesheet', type: 'text/css', href: "secmail.css?#{@cssmtime}"

  _header_ do
    _h1.bg_success do
      _a 'ASF Secretary Mail', href: '.'
      if unavailable
        _span.small unavailable
      elsif noticetext
        _span.small do
          _a noticetext, href: noticepath
        end
      end
    end
    _a 'Deleted messages', href: 'deleted'
    _ '-'
    _a 'All messages', href: 'all'
    _ '-'
    _a 'Pending messages', href: 'pending'
  end

  _div_.index!

  _script src: "./app.js?#{@appmtime}"
  _.render '#index', timeout: 1 do
    _Index mbox: @mbox, messages: @messages
  end
end
