(function ($) {

var UNSTARTED = -1;
var ENDED = 0;
var PLAYING = 1;
var PAUSED = 2;
var BUFFERING = 3;
var VIDEO_CUED = 5;
var OVERUNDERWEIGHT = 100;

var genreSongLists = {};
var genreSongListsClean = {};
var genres = {};

var playlist = [];

var player;
var playerState = UNSTARTED;

// Called when the YouTube player is ready to do work.
// playerId is the HTML ID of the player as a string.
function onYouTubePlayerReady(playerId) {
  player = swfobject.getObjectById(playerId);
  
  //Create arrays for each genre inside the genreSongLists object.
  $("#sliders .slider").each(function() {
    var name = $(this).data("name");
    genreSongLists[name] = [];
    genreSongListsClean[name] = [];
  });

  //Get the list of songs from the library on the playlist page and sort them into genre arrays.
  addSongsToPlaylist($("#explicit"), genreSongLists);
  addSongsToPlaylist($("#clean"), genreSongListsClean);

  $("#controls").delegate("a", "click", function (e) {
    e.preventDefault();
    
    //If all the percentage points aren't allocated prevent player from playing and warn user. 
    if ($("#controls").hasClass("disabled")) {
      alert("Make sure your playlist is 100% complete to start playing songs.")
    } else {
      //the link
      var anchor = $(this);
      //from the anchor link, the number of time of the requested playlist in seconds
      var targetDuration = parseInt(anchor.data("duration"), 10);
      var currentDuration = 0;
      //Choose which song list we're going to use based off the explicit checkbox
      var selectedSongLists = $("#explicit-selector").is(":checked") ? genreSongLists : genreSongListsClean;
      var selectedSongListsCopy = $.extend(true, {}, selectedSongLists);
      var song;
      //Creates a list of genres that stores target duration and current duration for each genre.
      $("#sliders .slider").map(function () {
        var genre = $(this);
        genres[genre.data("name")] = {
          name: genre.data("name"),
          targetGenreDuration: parseInt(Math.floor(($(this).slider("value") * 0.01) * targetDuration))
        };
      });
          
      playlist = [];
      var genreList = [];
      var totalDuration = 0;
      //Go through all the genres
      for (var key in genres) {
        var genreSongsLength = selectedSongListsCopy[key].length;
        var targetGenreDuration = genres[key].targetGenreDuration;
        var currentGenreDuration = 0;
        //Make sure user wants songs in a genre.
        if (targetGenreDuration > 0) {
          //Check to make sure genre song list isn't empty. 
          if (genreSongsLength > 0) {
            //All genres playlists are going to run a little long, so we'll subtract about a half song length to even things out.
            while (currentGenreDuration < (targetGenreDuration - OVERUNDERWEIGHT)) {
              //Checks to make sure we haven't run out of songs in the genre to add.
              if (selectedSongListsCopy[key].length > 0) {
                var chosenIndex = Math.floor(Math.random() * selectedSongListsCopy[key].length);
                //pick a random song from genreSongList
                song = selectedSongListsCopy[key][chosenIndex];
                
                genreList.push(song.genre);
                totalDuration += song.duration;
                
                playlist.push(song.id);
                currentDuration += song.duration;
                currentGenreDuration += song.duration;
                selectedSongListsCopy[key].splice([chosenIndex], 1);
              } else {
                //If there isn't enough songs to fill the requirement, add random songs from the original genreSongList until quota is met. 
                var chosenIndex = Math.floor(Math.random() * genreSongsLength);
                //pick a random song from genreSongList
                song = selectedSongLists[key][chosenIndex];
                
                genreList.push(song.genre);
                totalDuration += song.duration;
                
                playlist.push(song.id);
                currentDuration += song.duration;
                currentGenreDuration += song.duration;
              }
            }
          } else {
            //If there isn't any songs in the genre, then flash a warning.
            alert("Warning: There are no songs in the " + key + " genre to add to your playlist.");
          }
        }
      }
      //Randomize playlist
      playlist.sort(function() { return 0.5 - Math.random(); });

      if (player && playlist.length) {
        player.stopVideo();
        player.loadVideoById(playlist[0]);
      }
    }
  });

  $("#jukebox .shim").click(function (e) {
    e.preventDefault();

    if (player) {
      switch (playerState) {
      case UNSTARTED:
        break;
      case PLAYING:
        player.pauseVideo();
        break;
      case ENDED:
      case PAUSED:
      case BUFFERING:
      case VIDEO_CUED:
        player.playVideo();
        break;
      }
    }
  });

  player.addEventListener("onStateChange", "onYouTubePlayerStateChange");
  player.addEventListener("onError", "onYouTubePlayerError");
  $("#controls").fadeIn("fast");
}

//Put songs into different genre playlists
function addSongsToPlaylist(playlist, songContainer) {
  playlist.children().map(function () {
    var song = $(this);
    var songObj = { 
      duration: parseInt(song.data("duration"), 10),
      genre: song.data("genre"),
      id: song.data("video-id")
    };

    songContainer[songObj.genre].push(songObj);
  });
}

// Called when the YouTube player changes state (eg: playing -> paused).
function onYouTubePlayerStateChange(newState) {
  playerState = newState;

  switch (newState) {
  case UNSTARTED:
    break;
  case ENDED:
    gotoAndPlayNextSong();
    break;
  case PLAYING:
  case PAUSED:
  case BUFFERING:
  case VIDEO_CUED:
    break;
  }
}

//Called when the YouTube player throws and error (video removed)
function onYouTubePlayerError(error)  {
  /* Checking if the song is in the DOM is a good way to make sure we don't flag a song twice
     since we remove songs from the DOM that were already flagged. */
  var song = $(".library .song[data-video-id=" + playlist[0] + "]");
  
  if (song.length) {
    //Flag song in db
    $.ajax("/songs/flag", {
      cache: false,
      complete: function (jqXHR, status) {
        //regardless of success or fail, skip song and queue up next
        gotoAndPlayNextSong();
      },
      data: {
        _method: "POST",
        video_id: playlist[0]
      },
      success: function (jqXHR, status) {
        //Find and remove tracks from the DOM
        song.remove();
      },
      type: "POST"
    });
  } 
  //Don't need to log it, but still need to skip the song.
  else {
    gotoAndPlayNextSong();
  }
}

//Pops playlist and plays next track
function gotoAndPlayNextSong() {
  if (playlist.length > 1) {
    playlist.shift();
    player.loadVideoById(playlist[0]);
  } else {
    player.clearVideo();
  }
}

// Embed the YouTube player.
$(function () {
  var YOUTUBE_PLAYER_ID = "youtube-player";
  var params = { allowScriptAccess: "always", wmode: "transparent" };
  var attributes = { id: YOUTUBE_PLAYER_ID };

  swfobject.embedSWF("http://www.youtube.com/apiplayer?enablejsapi=1&playerapiid=" + YOUTUBE_PLAYER_ID + "&version=3",
                     "minimum-requirements", "854", "480", "8", null, null,
                     params, attributes);
});

// Export YouTube player event handlers.
$(function () {
  window.onYouTubePlayerReady = onYouTubePlayerReady;
  window.onYouTubePlayerStateChange = onYouTubePlayerStateChange;
  window.onYouTubePlayerError = onYouTubePlayerError;
});

// Make pages sortable via drag and drop.
$(function () {
  var container = $("#pages tbody");

  container.sortable({
    update: function (event, ui) {
      var pages = container.children();
      var page = $(ui.item);

      $.ajax(page.data("reposition-path"), {
        cache: false,
        data: {
          _method: "PUT",
          position: (pages.index(page) + 1)
        },
        success: function (jqXHR, status) {},
        type: "POST"
      });
    }
  });

  container.disableSelection();
});

//Sliders Logic
$(function() {
  var TOTAL_PERCENTAGE = 100;
  
  var sliders = $("#sliders .slider");
  var availablePercentageSelection = $("#percent-complete");
  var pointBasedElements = $(".point-based");
  var explicitSelector = $("#explicit-selector");
  
  var percentageUsed = 0;
  var availablePercentage = 0;
  
  function updateSliders() {
    percentageUsed = 0;
    
    sliders.each(function() {
      percentageUsed += $(this).slider("value");
    });
    
    availablePercentage = TOTAL_PERCENTAGE - percentageUsed;
    availablePercentageSelection.text(percentageUsed + "%");
    
    sliders.each(function() {
      var sliderValue = $(this).slider("value");
      var availableSliderPercentage = sliderValue + availablePercentage;

      $(this).width(availableSliderPercentage + "%");
      $(this).slider("option", "max", availableSliderPercentage);
      $(this).slider("option", "min", 0);
      $(this).slider("value", sliderValue);
    });
    
    if (availablePercentage == 0) {
      pointBasedElements.removeClass("disabled");
    } else {
      pointBasedElements.not(".disabled").addClass("disabled");
    }
  }
  
  sliders.slider({
    slide: updateSliders,
    stop: updateSliders,
    step: 5
  });
});
  
})(jQuery);
