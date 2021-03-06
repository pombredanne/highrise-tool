$ ->
  [shortName, apikey, prj] = \
    [window.user.effective.shortName, window.user.effective.apiKey, window.box]
  boxurl = "#{window.boxServer}/#{window.box}"

  $('#import').on 'click', ->
    hr_user = $('#username').val()
    hr_pwd = $('#password').val()
    hr_domain = $('#domain').val()
    cmd = "cd ~/highrise; ./setup  #{hr_user} #{hr_pwd} #{hr_domain}"

    $(@).attr 'disabled', yes
    $(@).addClass 'loading'
    $(@).html 'Importing&hellip;'

    $.ajax
      url: "#{boxurl}/exec"
      type: 'POST'
      data:
        apikey: apikey
        cmd: cmd
      success: (text) =>
        data = JSON.parse String(text)
        if data.error is ''
          Backbone.trigger 'tool:installed'
        else
          $('#highrise-setup .alert').remove()
          $('#highrise-setup').prepend """
            <div class="alert alert-error">
              <strong>Oh noes!</strong> #{data.error}
            </div>
          """
          $(@).attr 'disabled', no
          $(@).removeClass 'loading'

      error: (jqXHR, textStatus, errorThrown) =>
        $(@).attr 'disabled', no
        $(@).removeClass 'loading'
        $('#highrise-setup').prepend('<div class="alert alert-error"><strong>On noes!</strong> ' + jqXHR.responseText)
