void setupFonts(){
  aller = loadFont("Aller-40.vlw");
  allerbold = loadFont("Aller-Bold-40.vlw");
  textAlign(CENTER);
  textLeading(35);
}


void saluteUser(String userName, Float userLikelyhood) {
  String displayName = "";
  String displaySalute = "";
  String displayOffer = "";

  fill(green);
  textFont(allerbold, 40);
  textLeading(35);
  displayName += "Hi " + userName + ",";
  text(displayName, 235, 410);
  
  textFont(aller, 40);
  textLeading(35);
  displaySalute += "your ’stash just\ngot bigger.";
  text(displaySalute, 235, 455);

  fill(red);
  textFont(allerbold, 40);
  textLeading(40);
  displayOffer += rewardPhrases[0];
  text(displayOffer, 235, 570);
}
