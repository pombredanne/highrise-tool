console.log 'executed coffeescript'

$ ->
  console.log 'document ready'
  [user, apikey, box] = \
    [window.user, window.apikey, window.box]

  $('#import').on 'click', ->
    console.log 'import clicked'
    highrise_user = $('#username').val()
    highrise_pwd = $('#password').val()

    $.ajax
      url: "http://boxecutor-dev-1.scraperwiki.net/#{user}/#{box}/exec"
      type: 'POST'
      data:
        apikey: apikey
        cmd:  "cd ~/highrise; ./setup  #{highrise_user} #{highrise_pwd}"
      success: ->
          alert 'success?'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log jqXHR.responseText
