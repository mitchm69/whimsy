#!/usr/bin/env ruby
PAGETITLE = "Unlisted CLAS" # Wvisible:officers
$LOAD_PATH.unshift '/srv/whimsy/lib'

require 'wunderbar'
require 'wunderbar/bootstrap'
require 'whimsy/asf'
require 'whimsy/asf/forms'
require 'whimsy/asf/rack'

user = ASF::Auth.decode({})
unless user.asf_chair_or_member?
  print "Status: 401 Unauthorized\r\n"
  print "WWW-Authenticate: Basic realm=\"ASF Members and Officers\"\r\n\r\n"
  exit
end

def emit_form(search=nil, value=nil)
  _whimsy_panel('Search for ICLA', style: 'panel-success') do
    _form.form_horizontal method: 'post' do
      _whimsy_forms_subhead(label: 'Enter search term')
      field = 'search'
      _whimsy_forms_input(label: 'Search for', name: field, id: field,
        value: search, helptext: 'Enter email address. Must match the field on the ICLA exactly.'
      )
      if value
        field = 'match'
        _whimsy_forms_input(label: 'ICLA from', name: field, id: field,
          value: value
        )
      end
      _whimsy_forms_submit(value: 'Search')
    end
  end
end

# Produce HTML
_html do
  _body? do # The ? traps errors inside this block
    _whimsy_body( # This emits the entire page shell: header, navbar, basic styles, footer
      title: PAGETITLE,
      subtitle: 'About This Script',
      relatedtitle: 'More Useful Links',
      related: {
        "/committers/tools" => "Whimsy Tool Listing",
        "https://community.apache.org/" => "Get Community Help",
        "https://github.com/apache/whimsy/blob/master/www#{ENV['SCRIPT_NAME']}" => "See This Source Code"
      },
      helpblock: -> {
        _p %{
          This script allows officers and members to search for CLAs from prospective committers.
          You can only search by email address, as names are not unique.
        }
      },
    ) do

      _div id: 'query-form' do
        if _.post?
          search = _.params['search'].first
          value = ASF::ICLA.find_by_email(search)
          if value and value.id == 'notinavail'
            name = value.name
          else
            name = 'Not found or already a committer'
          end
          emit_form(search, name) # redisplay with the info
        else
          emit_form
        end
      end
    end
  end
end

