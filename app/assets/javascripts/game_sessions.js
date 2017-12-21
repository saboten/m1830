$(document).on("ready page:load", function() {
  switch($("body").prop("id")) {
  case "game_sessions_new":
    game_sessions_new();
    break;
  case "game_sessions_show":
    game_sessions_show();
    break;
  }
});



