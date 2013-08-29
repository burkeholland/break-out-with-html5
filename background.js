chrome.app.runtime.onLaunched.addListener(function() {

  'use strict';

  window.APP = window.APP || {};

  // create a new window and position it with a fixed size
  window.APP.win = chrome.app.window.create('main.html', {
    width: 1170,
    height: 768
  }, function(appWindow) {
    
  });

});

