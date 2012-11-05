console.log 'executed coffeescript'

$ ->
  [user, apikey, box] = \
    [window.user, window.apikey, window.box]

  $('#domain').val 'scraperwiki.highrisehq.com'

  $('#import').on 'click', ->
    user = $('#username').val()
    pwd = $('#password').val()
    domain = $('#domain').val()
    cmd = "cd ~/highrise; ./setup  #{user} #{pwd} #{domain}"

    $.ajax
      url: "http://boxecutor-dev-1.scraperwiki.net/#{user}/#{box}/exec"
      type: 'POST'
      data:
        apikey: apikey
        cmd: cmd
      success: (text) ->
          $('#output').text text
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR.responseText
