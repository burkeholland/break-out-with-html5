// Generated by CoffeeScript 1.3.3
(function() {
  'use strict';

  var GalleryDirectory, GalleryFile, iframe, notId;

  iframe = document.getElementById('iframe');

  $.pkg.init(iframe.contentWindow);

  $.pkg.listen('/select/file', function() {
    var extensions;
    extensions = ['jpg', 'jpeg', 'gif', 'png'];
    return chrome.fileSystem.chooseEntry({
      type: 'openFile',
      accepts: [
        {
          extensions: extensions
        }
      ]
    }, function(entry) {
      return entry.file(function(file) {
        var reader;
        reader = new FileReader();
        reader.onloadend = function() {
          return $.pkg.send('/file/selected', [this.result]);
        };
        return reader.readAsDataURL(file);
      });
    });
  });

  $.pkg.listen('/contextMenu/item/add', function(title, type) {
    return chrome.contextMenus.create({
      id: title,
      title: title,
      type: type
    }, function() {
      if (chrome.runtime.lastError) {
        return $.pkg.send('/contextMenu/item/created', [true, chrome.runtime.lastError.message]);
      } else {
        return $.pkg.send('/contextMenu/item/created', [false, "Context menu item created with id of '" + title + "'"]);
      }
    });
  });

  chrome.contextMenus.onClicked.addListener(function(item) {
    return console.log("You clicked " + item.id);
  });

  notId = 1;

  $.pkg.listen('/notifications/create', function(title, message) {
    return chrome.notifications.create("1" + notId++, {
      type: "basic",
      title: title,
      message: message,
      iconUrl: "icon_64.png"
    }, function() {});
  });

  chrome.idle.setDetectionInterval(15);

  chrome.idle.onStateChanged.addListener(function(state) {
    return $.pkg.send("/idle/event", [state]);
  });

  $.pkg.listen("/tts/get/voices", function() {
    return chrome.tts.getVoices(function(voices) {
      return $.pkg.send("/tts/voices", [voices]);
    });
  });

  $.pkg.listen('/say', function(message, voice, rate, pitch) {
    return chrome.tts.speak(message, {
      voiceName: voice,
      rate: rate,
      pitch: pitch
    });
  });

  GalleryDirectory = (function() {
    var constructor;

    function GalleryDirectory() {}

    constructor = function(name) {
      this.name = name;
      this.subDirectories = [];
      return this.files = [];
    };

    return GalleryDirectory;

  })();

  GalleryFile = (function() {
    var constructor;

    function GalleryFile() {}

    constructor = function(name) {
      this.name = name;
    };

    return GalleryFile;

  })();

  window.galleries = [];

  $.pkg.listen("/bluetooth/startDiscovery", function() {
    return chrome.bluetooth.startDiscovery({
      deviceCallback: function(device) {
        return $.pkg.send("/bluetooth/device", [device]);
      }
    }, function() {});
  });

  $.pkg.listen("/bluetooth/stopDiscovery", function() {
    return chrome.bluetooth.stopDiscovery();
  });

}).call(this);
