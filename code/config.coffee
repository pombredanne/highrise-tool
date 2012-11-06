$ ->
  [user, apikey, box] = \
    [window.user, window.apikey, window.box]

  $('#import').on 'click', ->
    hr_user = $('#username').val()
    hr_pwd = $('#password').val()
    hr_domain = $('#domain').val()
    cmd = "cd ~/highrise; ./setup  #{hr_user} #{hr_pwd} #{hr_domain}"

    $(@).attr 'disabled', yes
    $(@).addClass 'loading'

    $.ajax
      url: "http://boxecutor-dev-1.scraperwiki.net/#{user}/#{box}/exec"
      type: 'POST'
      data:
        apikey: apikey
        cmd: cmd
      success: (text) =>
        data = JSON.parse text
        if data.error is ''
          $('#highrise-setup').html """
            <div class="alert alert-success">
              <strong>Great!</strong> 
              Your data has been imported. 
              <a href="#">Take a look &rarr;</a>
            </div>
          """
          $.cookie 'datasets', 'highrise'
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
