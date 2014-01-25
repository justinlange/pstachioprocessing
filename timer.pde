class Timer 
{
  int timeEllapsedBeforeStart;
  int countdown;

  Timer(int _countdown) {
    timeEllapsedBeforeStart = millis();
    countdown = _countdown;
  } 

  boolean isTimeUp() {
    if ((millis() - timeEllapsedBeforeStart) > countdown) {
      return true;
    }   
    //println("false, " + ((countdown - millis()) - timeEllapsedBeforeStart) + " millis left"); 
    return false;
  }
}

