  'use strict';
  
  # get a reference to the iframe that holds the app
  iframe = document.getElementById('iframe');

  # initialize the pkg plugin
  $.pkg.init iframe.contentWindow;

  # subscribe to the /select/image message and return an image using
  # the native api file picker in chrome packaged apps
  $.pkg.listen '/select/file', () ->

    extensions = ['jpg', 'jpeg', 'gif', 'png'] 
    chrome.fileSystem.chooseEntry { type: 'openFile', accepts: [{ extensions: extensions }] }, (entry) ->

      # this gives us a file entry. We just need to read it.
      entry.file (file) ->

        #create a new file reader
        reader = new FileReader();

        #create an event for when the file is done reading
        reader.onloadend = () ->
          # send the file into the sandbox
          $.pkg.send '/file/selected', [this.result]

        # read the file as a data URL
        reader.readAsDataURL file

  $.pkg.listen '/contextMenu/item/add', (title, type) ->
    # add a new context menu item
    chrome.contextMenus.create { id: title, title: title, type: type }, () ->
      if chrome.runtime.lastError
        $.pkg.send '/contextMenu/item/created', [ true, chrome.runtime.lastError.message ]
      else
        $.pkg.send '/contextMenu/item/created', [ false, "Context menu item created with id of '" + title + "'" ]

  chrome.contextMenus.onClicked.addListener (item) ->
    console.log "You clicked #{item.id}"

  notId = 1;
  $.pkg.listen '/notifications/create', (title, message) ->
    chrome.notifications.create "1" +notId++, { type: "basic", title: title, message: message, iconUrl: "icon_64.png" }, () ->


  # attach to idle query
  chrome.idle.setDetectionInterval 15

  chrome.idle.onStateChanged.addListener (state) ->
    $.pkg.send "/idle/event", [state]

  # listen for a request to get all the TTS voices
  $.pkg.listen "/tts/get/voices", () ->
    chrome.tts.getVoices (voices) -> 
      $.pkg.send "/tts/voices", [ voices ]

  # listen for the tts event
  $.pkg.listen '/say', (message, voice, rate, pitch) ->
    chrome.tts.speak message, { voiceName: voice, rate: rate, pitch: pitch }

  class GalleryDirectory
    constructor = (@name) ->
      @subDirectories = []
      @files = []

  class GalleryFile
    constructor = (@name) ->

  window.galleries = []

  # recursive function to read the tree
  # readEntries = (directory, entry) ->
  #   reader = directory.root.createReader()
  #   reader.readEntries((results) ->
      
  #     for subEntry in i..results.length
  #       do ->
  #         if entry.isDirectory
  #           subDirectory = new GalleryDirectory subEntry.name
  #           readEntries(subDirectory, subEntry)
  #         }
  #         else {
  #           directory.files.push(new GalleryFile(subEntry.name));
  #         }
  #       }());
  #     }
  #   });
  # };

  # # media galleries
  # $.pkg.listen('/mediaGalleries/get', function() {});
  #   chrome.mediaGalleries.getMediaFileSystems(function(results) {
  #     var length = results.length;
  #     for (var i = 0; i < length; i++) {
  #       var entry = results[i];
  #       # add an item to the galleries result object
  #       galleries.push(new GalleryDirectory(entry.name));
  #       # read any entries this guy has
  #       readEntries(results[i]);
  #       #$.pkg.send('/mediaGalleries/results', results[0]);
  #     }
  #   });
  # });

  # subscribe to the camera off event
  # $.pkg.listen('/camera/off', function() {
  #   camera = false;
  #   video.src = undefined;
  # });

  # # attach to idle query
  # $.pkg.listen('/idle/setInterval', function(wait) {
  #   chrome.idle.setDetectionInterval(wait);
  # });

  # bluetooth get devices
  $.pkg.listen "/bluetooth/startDiscovery", () ->
    chrome.bluetooth.startDiscovery({ 
      deviceCallback: (device) ->
        $.pkg.send "/bluetooth/device", [ device ]
      }, () ->
    )

  $.pkg.listen "/bluetooth/stopDiscovery", () ->
    chrome.bluetooth.stopDiscovery()