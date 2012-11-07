$ ->
  [org, apikey, prj] = \
    [window.user, window.apikey, window.box]
  boxname = "#{org}/#{prj}"
  boxurl = "http://boxecutor-dev-1.scraperwiki.net/#{boxname}"

  $('#import').on 'click', ->
    hr_user = $('#username').val()
    hr_pwd = $('#password').val()
    hr_domain = $('#domain').val()
    cmd = "cd ~/highrise; ./setup  #{hr_user} #{hr_pwd} #{hr_domain}"

    $(@).attr 'disabled', yes
    $(@).addClass 'loading'

    $.ajax
      url: "#{boxurl}/exec"
      type: 'POST'
      data:
        apikey: apikey
        cmd: cmd
      success: (text) =>
        data = JSON.parse text
        if data.error is ''
          $.ajax
            url: "#{boxurl}/exec"
            type: 'POST'
            dataType: 'json'
            data:
              apikey: apikey
              cmd: "cat ~/scraperwiki.json"
            success: (data) ->
              boxPublishToken = data.publish_token
              $('#content').html """<iframe style="border:none;width:100%;height:100%" src="#{boxurl}/#{boxPublishToken}/http/spreadsheet-tool/"></iframe>"""
          $.cookie 'datasets', JSON.stringify { highrise: { box: "#{boxname}" } },
            { path: '/' }
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
