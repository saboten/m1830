var GameState = (function () {
  var instance;
  
  function Singleton() {
    this.selectedPlayer = -1;
    this.selectedPlayerName = "";
    this.selectedCorporation = -1;
    this.selectedCompany = "";
    this.fromBankPool = false;
    this.enteringFinalScores = false;
  }
  
  return {
    getInstance: function() {
      if(!instance) {
        instance = new Singleton();
      }
      return instance;
    }
  }
  
}) ();