function game_sessions_new() {
  var number_of_players = 0;
  
  //Update cash displays and player select boxes when a player name is added
  $('.player_name_input').change(function() {
    number_of_players = 0;
    $('.player_name_input').each(function(index) {
      if($(this).val() != '') {
        number_of_players += 1;
        $(paired_money_input($(this).prop("id"))).data("player", $(this).val());
      }
      else {
        $(paired_money_input($(this).prop("id"))).data("player", "");
      }
    });
    update_player_money();
    $('.company_owner_select option[value="'+player_id($(this).prop("id"))+'"]').text($(this).val());
  });
  
  //Returns a value that can be used to link player name input, player money input, and company select
  function player_id(player_input_id) {
    //This is not a good way to do this. The function is parsing the id generated by Rails to find
    //the matching id for the player money input.
    return player_input_id.split("_")[4];
  }
  
  //Returns the money input paired with a given player name input
  function paired_money_input(player_input_id) {
    return '#game_session_players_attributes_'+player_id(player_input_id)+'_money';
  }
  
  //Refreshes all in-use player money inputs
  function update_player_money() {
    $('.player_money_input').each(function(index) {
      if($(this).data("player") != "") {
        var p_id = player_id($(this).prop("id"));
        var total_money_spent = 0;
        $('.company_owner_select').each(function(index) {
          if($(this).find(":selected").prop("value") == p_id) {
            total_money_spent += +$(this).data('price');
          }
        });
        $(this).val((2400 / number_of_players) - total_money_spent);
      }
      else {
        $(this).val('');
      }
    });
  }
  
  //Shows or hides optional private companies
  $('.company_checkbox').click(function(event) {
    if($(this).is(':checked')) {
      $('#company_row_'+$(this).data("initials")).removeAttr("hidden");
    }
    else {
      $('#company_row_'+$(this).data("initials")).attr('hidden', 'hidden');
      $('#company_purchase_'+$(this).data("initials")).data('price','0');
    }
  });
  
  $('.company_owner_select').change(function() {
    update_player_money();
  });   
  
  $('.company_price_input').change(function() {
    $('#company_owner_'+$(this).data("initials")).data('price',$(this).val());
    update_player_money();
  });
}