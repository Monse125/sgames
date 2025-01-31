
class ResistanceGameSettings {
  double maxForce;
  int lowerBound;
  int upperBound;
  int amountReps;
  int lengthRep;
  int lengthRest;
  int amountSets;
  int lengthRestSet;

  ResistanceGameSettings({
    this.maxForce = 0.0,
    this.lowerBound = 30,
    this.upperBound = 70,
    this.amountReps = 1,
    this.lengthRep = 5,
    this.lengthRest = 10,
    this.amountSets = 1,
    this.lengthRestSet = 10,
  });

}