define [
  'order!../components/jquery/jquery.min'
  'order!../components/pkg/pkg'
  'order!../components/kendo-ui/js/kendo.web.min'
], () ->

  # get the current date/time
  now = kendo.toString new Date(), "G"

  # set up the pkg plugin
  $.pkg.init window.top

  # set up the listeners
  $.pkg.listen "/file/selected", (img) ->
    viewModel.set "fileSystem.selected", img

  $.pkg.listen "/contextMenu/item/created", (error, message) ->
    viewModel.set "contextMenu.message", message
    if error
      viewModel.set "contextMenu.error", true
    else viewModel.set "contextMenu.error", false      

  $.pkg.listen "/mediaGalleries/results", (items) ->
    viewModel.set "mediaGalleries.items", items

  $.pkg.listen "/idle/event", (e) ->
    viewModel.get("idle.events").unshift({ time: kendo.toString(new Date(), "G"), status: e });

  $.pkg.listen "/tts/voices", (voices) ->
    viewModel.set "tts.voices", voices

  $.pkg.listen "/bluetooth/device", (device) ->
    viewModel.get("bluetooth.devices").push device

  viewModel = kendo.observable({
    
    fileSystem:
      selected: "",
      click: () ->
        $.pkg.send "/select/file"
    
    contextMenu:
      error: false
      message: "Everything looks good!"
      item: ""
      type: null
      add: () ->
        # clear out the success and error message boxes
        $(".msg").empty()
        $.pkg.send "/contextMenu/item/add", [ @get("contextMenu.item"), @get("contextMenu.type.value") ],

    mediaGalleries:
      get: () ->
        $.pkg.send "/mediaGalleries/get"
      items: []

    notifications:
      title: ""
      message: ""
      create: () ->
        $.pkg.send "/notifications/create", [ @get("notifications.title"), @get("notifications.message") ]

    idle:
      events: [{ time: now, status: "active" }] 

    bluetooth:
      devices: []
      disovering: false
      get: () ->
        discovering = @get "bluetooth.discovering"
        if not discovering
          @set "bluetooth.devices", []
          @set "bluetooth.discovering", true
          $.pkg.send "/bluetooth/startDiscovery"
        else
          $.pkg.send "/bluetooth/stopDiscovery"
          @set "bluetooth.discovering", false

    tts:
      rate: 1
      pitch: 1
      currentVoice: ""
      voices: []
      selected: null
      say: () ->

        message = @get "tts.selected"
        
        if $.type(message) != "string" 
          message = message.text
        
        $.pkg.send "/say", [ message, @get("tts.currentVoice"), @get("tts.rate"), @get("tts.pitch") ]

  })

  # get the available voices for tts
  $.pkg.send "/tts/get/voices"

  # bind the demos to the slides
  kendo.bind document.body, viewModel