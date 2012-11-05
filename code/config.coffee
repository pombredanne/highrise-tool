$ ->
  [user, apikey, box] = \
    [window.user, window.apikey, window.box]

  $('#import').on 'click', ->
    hr_user = $('#username').val()
    hr_pwd = $('#password').val()
    hr_domain = $('#domain').val()
    cmd = "cd ~/highrise; ./setup  #{hr_user} #{hr_pwd} #{hr_domain}"

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
