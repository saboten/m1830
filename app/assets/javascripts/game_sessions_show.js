function game_sessions_show() {
  //Bind Events
  $(document).on('keydown', function (e) {
    var code = e.keyCode || e.which;
     if(code == 27) {
       clearSelected();
     }
  });
  $('.transaction_input').on('keydown', function (e) {
    var code = e.keyCode || e.which;
    if(code == 13) {
      $(this).trigger('click');
      return false;
    }
  });
  $('#command').on('keydown', function (e) {
    var code = e.keyCode || e.which;
     if(code == 13) {
       postCommand($(this).val(), true);
     }
  });
  $('.player_block').click( function(e) {
    setSelectedPlayer($(this).data("id"));
  });
  $('.content_block').click( function(e) {
    var game = GameState.getInstance();
    if(game.selectedPlayer >= 0) {
      showBlock($(this).data("id"),"buy_sell");
    } else if(!$(this).hasClass("shaded")) {
      showBlock($(this).data("id"),"run");
    }  
  });
  $('.transaction_title').click( function(e) {
    var game = GameState.getInstance();
    game.selectedCorporation = -1;
    $(this).parent().slideUp('fast');
  });
  $('.company_name').click( function(e) {    
    setSelectedCompany($(this).data("initials"));
  });
  //Bind Control buttons
  $('#private_income_button').click( function(e) {
    postCommand("company_payout", false);
    return false
  });
  $('#final_scores_button').click( function(e) {
    var game = GameState.getInstance();
    if (game.enteringFinalScores) {
      game.enteringFinalScores = false;
      postFinalScore();
    } else {
      game.enteringFinalScores = true;
      showBlocks();
    }
    return false
  });
  $('#sell_company_button').click( function(e) {
    sellCompany();
    return false;
  });
  $('#remove_company_button').click( function(e) {
    removeCompany();
    return false;
  });
  $('#undo_button').click( function(e) {
    postCommand("undo", false);
    return false
  });
}

function setSelectedPlayer(playerId) {
  var game = GameState.getInstance();
  if(game.selectedPlayer != playerId) {
    clearSelected();
    game.selectedPlayer = playerId;
    game.selectedPlayerName = $('#player_name_' + game.selectedPlayer).html().toLowerCase();
    $('#player_' + game.selectedPlayer).addClass("selected");
  } else {
    clearSelected();
  }
}

function setSelectedCompany(initials) {
  var game = GameState.getInstance();
  if(game.selectedCompany != initials) {
    clearSelected();
    game.selectedCompany = initials;
    $('#company_name_' + game.selectedCompany).addClass("selected_company");
  } else {
    clearSelected();
  }
}

function showBlocks() {
  var game = GameState.getInstance();
  clearSelected();
  $('.transaction_block').each(function(index) {   
    $('#transaction_controls_' + $(this).data('id')).html(tableInteriorHtml.FINAL_SCORE);
    $(this).find('.transaction_input').attr('id','transaction_input_'+$(this).data('id'));
    if(index == 0) {
      //TODO Figure out why this doesn't work
      //$('#transaction_input_'+$(this).data('id')).focus();
    };
  });
  $('.transaction_block').slideDown('fast');
}

function showBlock(corporationId, transaction_type) {
  var game = GameState.getInstance();
  if(game.selectedCorporation != corporationId) {
    hideBlock(game.selectedCorporation);
    game.selectedCorporation = corporationId;
    switch (transaction_type) {
    case "buy_sell":
      $('#transaction_controls_' + game.selectedCorporation).html(tableInteriorHtml.BUY_SELL);
      setupTransactionControls('buy_sell');
      break;
    case "run":
      $('#transaction_controls_' + game.selectedCorporation).html(tableInteriorHtml.RUN);
      setupTransactionControls('run');
      break;
    }
    $('#transaction_block_' + game.selectedCorporation).slideDown('fast', function() {
      switch (transaction_type) {
      case "buy_sell":
        $('#share_quantity').focus();
        break;
      case "run":
        $('#run_value').focus();
        break;
      }
    });
  } else {
    hideBlock(game.selectedCorporation)
    game.selectedCorporation = -1;
  }
}

function hideBlock(corporationId) {
  $('#transaction_block_' + corporationId).slideUp('fast');
  $('#transaction_controls_' + corporationId).html("");
}

function setSourceText() {
  var game = GameState.getInstance();
  var button = $('#source_button');
  if(game.fromBankPool) {
    button.html('Bank Pool')
  } else {
    button.html('Initial Offering')
  }
}

function setupTransactionControls(type) {
  var game = GameState.getInstance();
  switch(type) {
  case "buy_sell":
    setSourceText();
    $('#source_button').click( function(e) {
      var game = GameState.getInstance();
      game.fromBankPool = !game.fromBankPool;
      setSourceText();
      return false;
    });
    $('#buy_button').click( function(e) {
      processShare(true);
      return false;
    });
    $('#sell_button').click( function(e) {
      processShare(false);
      return false;
    });
    $('#share_value').on('keydown', function (e) {
      var code = e.keyCode || e.which;
       if(code == 66) {
         processShare(true);
         return false;
       }
       if(code == 83) {
         processShare(false);
         return false;
       }
    });
    break;
  case "run":
    $('#pay_button').click( function(e) {
      runTrains(false);
      return false;
    });
    $('#withhold_button').click( function(e) {
      runTrains(true);
      return false;
    });
    $('#run_value').on('keydown', function (e) {
      var code = e.keyCode || e.which;
       if(code == 80) {
         runTrains(false);
         return false;
       }
       if(code == 87) {
         runTrains(true);
         return false;
       }
    });
    $('#run_value').focus(function() {
      $(this).select();
    });
    break;
  case "final_score":
    break;
  }
}

function clearSelected() {
  var game = GameState.getInstance();
  $('#player_' + game.selectedPlayer).removeClass("selected");
  $('#company_name_' + game.selectedCompany).removeClass("selected_company");
  $('#final_scores_button').html("Final Scores");
  game.selectedPlayer = -1;
  game.selectedPlayerName = "";
  game.selectedCompany = "";
  $('.transaction_block').slideUp('fast');
  game.selectedCorporation = -1;
  game.fromBankPool = false;
}

function processShare(buy) {
  var game = GameState.getInstance();
  var quantity = $('#share_quantity').val();
  var value = $('#share_value').val();
  var commandString;
  if(buy) {
    commandString = "buy ";
  } else {
    commandString = "sell ";
  }
  commandString += " -v" + value + " -q" + quantity + " -p" + game.selectedPlayerName + " -s" + game.selectedCorporation;
  if(game.fromBankPool) {
    commandString += " -b";
  }
  postCommand(commandString, false);
}

function runTrains(withhold) {
  var game = GameState.getInstance();
  var commandString = "run " + game.selectedCorporation + " -v" + $('#run_value').val();
  if(withhold) {
    commandString += " -w"
  }
  postCommand(commandString, false);
}

function sellCompany() {
  var game = GameState.getInstance();
  var commandString = "sell_company " + game.selectedCompany + " -v" + $('#company_value').val() + " -c" + $('#new_company_owner').val();
  postCommand(commandString, false);
}

function removeCompany() {
  var game = GameState.getInstance();
  var commandString = "remove " + game.selectedCompany;
  postCommand(commandString, false);
}

function postFinalScore() {
  var share_values = {};
  $('.transaction_block').each(function(index) {
    share_values[$(this).data('id')] = $('#transaction_input_' + $(this).data('id')).val();
  });
  $.post($("body").data("score-url"), {share_values: share_values}, function(data) {
    $("body").html(data);
    game_sessions_show();
  });
}

function postCommand(commandString, fromCommandLine) {
  $.post($("body").data("command-url"), {command: commandString}, function(data) {
    $("body").html(data);
    game_sessions_show();
    clearSelected();
    flashMoneyChange();
    if(fromCommandLine) {
      $('#command').focus();
      var image;
      if($('#console_output').data('error')) {
        image = $('#error_image')
      } else {
        image = $('#success_image')
      }
      image.show().delay(600).fadeOut("slow");
    }
  });
}

function flashMoneyChange() {
  $('.money_change').each(function() {
    $(this).data("normalText",$(this).html());
    if($(this).data("change") > 0) {
      $(this).css("color","#0C0");
      $(this).html("+$" + $(this).data("change"));
    } else {
      $(this).css("color","#C00");
      $(this).html("-$" + ($(this).data("change")*-1));
    }
  });
  window.setTimeout(function () {
    $('.money_change').each(function() {
      $(this).css("color","#FFF");
      $(this).html($(this).data("normalText"));
    });
  }, 3000);
}