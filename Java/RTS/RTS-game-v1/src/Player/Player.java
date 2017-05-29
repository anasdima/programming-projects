package Player;

import java.util.ArrayList;
import java.util.Vector;
import java.util.Random;

import Platform.Utilities;
import Units.Base;
import Units.Marine;
import Units.Unit;

public class Player implements AbstractPlayer
{

  private String name;
  private int id;
  private int startX;
  private int startY;

  ArrayList<Unit> units = new ArrayList<Unit>();

  // (Integer pid)

  public Player (Integer pid) { // Class' constructor, sets player's variables

	  if (pid == Utilities.PLAYERA_ID) { // Using the Utilities' class variable PLAYERA_ID to check the given pid
		  
		  setStartX(Utilities.PLAYERA_STARTX); 	// Setting the appropriate coordinates for playerA from Utilities
		  setStartY(Utilities.PLAYERA_STARTY);
		  setName ("playerA");					// Setting player's name
		  id = pid;
		  
	  }
	  
	  else if (pid == Utilities.PLAYERB_ID) {	// Using the Utilities' class variable PLAYERB_ID to check the given pid
		  
		  setStartX(Utilities.PLAYERB_STARTX);	// Setting the appropriate coordinates for playerB from Utilities
		  setStartY(Utilities.PLAYERB_STARTY);
		  setName("playerB");					// Setting player's name
		  id = pid;
		  
	  }
  }

  public void setId(int pid) {	// Sets the player's pid
	  
	  id = pid;
  }
  
  public void setName(String playerName) { // Sets the player's name
	  
	  name = playerName;
  }
  
  public void setStartX (int x) {  // Sets the X coordinate
	  
	  startX = x;
  }
  
  public void setStartY (int y) { // Sets the Y coordinate
	  
	  startY = y; 
  }
  
  public int getId () { // Returns player id
	  
	  return id;
  }
  
  public int getStartX () { // Returns coordinate X
	  
	  return startX;
  }
  
  public int getStartY () { // Returns coordinate Y
	  
	  return startY;
  } 
  
  public String getName() { // Returns player's name
	  
	  return name;
	  
  }

  
  public void initialize (int startMarines)
  {
    units.clear();

    units.add(createInitialBase(Utilities.unitID));
    Utilities.unitID++;
    for (int i = 0; i < startMarines; i++) {

      units.add(createInitialMarine(Utilities.unitID));
      Utilities.unitID++;
    }

  }

  // TODO
  Base createInitialBase (int unitId)	// Creates an initial Base
  { 
	  Base initialBase = new Base(unitId,id,startX,startY); 
	  return initialBase;

  }

  void createBase (int id, int ownerID, int startingX, int startingY)
  {
    Base base = new Base(id, ownerID, startingX, startingY); // Using Base's constructor to create an initial Base
    Utilities.unitID++;
    units.add(base);

  }

  public void createBase ()
  {
    createBase(Utilities.unitID, id, startX, startY);

  }

  // TODO
  Marine createInitialMarine (int unitId)	// Creates an initial marine
  {
	  Marine initialMarine = new Marine(unitId, id , startX, startY); // Using Marine's constructor to create an initial Marine
	  return initialMarine;
  }

  void createMarine (int id, int ownerID, int startingX, int startingY)
  {
    Marine marine = new Marine(id, ownerID, startingX, startingY);
    Utilities.unitID++;
    units.add(marine);

  }

  public void createMarine ()
  {
    createMarine(Utilities.unitID, id, startX, startY);
  }

  public ArrayList<Unit> getUnits ()
  {
    return units;

  }

  public ArrayList<Unit> getOwnUnits ()
  {
    ArrayList<Unit> ownUnits = new ArrayList<Unit>();
    for (Unit uni: units) {
      if (uni.getOwner() == id)
        ownUnits.add(uni);
    }
    return ownUnits;

  }

  public void setUnits (ArrayList<Unit> unitlist)
  {
    units = unitlist;
  }

  public void chooseCorridor (ArrayList<Unit> units)
  {

    for (Unit uni: units) {

      if (uni.getCorridor() == -1 && uni.getType() == "marine"
          && uni.getOwner() == id) {

        // For these units choose the corridor in which they will move
        uni.setCorridor(chooseRandomCorridor());
        // uni.corridor=0;
        uni.setStatus(Unit.Moving);
        uni.setPrevStatus(Unit.Standing);

      }
    }

  }

  // redesign resolveAttacking for unit to attack the weakest available unit
  // System.out.println(uni.getOwner()+" "+enemyuni.getOwner()+" "+uni.getType()+" "+id+" "+Utilities.getDistance(uni,
  // enemyuni)+ " "+uni.attack_range);

  public void resolveAttacking (ArrayList<Unit> unitlist)
  {
    for (Unit uni: unitlist) {
      Vector<Vector<Integer>> targets = new Vector<Vector<Integer>>();

      for (Unit enemyuni: unitlist) {
        // && uni.corridor == enemyuni.corridor
        if (uni.getOwner() == id && uni.getStatus() != Unit.Attacking
            && uni.getType() == "marine" && enemyuni.getOwner() != id
            && Utilities.getDistance(uni, enemyuni) <= uni.getAttackRange()
            && uni.getCorridor() == enemyuni.getCorridor()
            || uni.getOwner() == id && uni.getStatus() != Unit.Attacking
            && uni.getType() == "marine" && enemyuni.getOwner() != id
            && Utilities.getDistance(uni, enemyuni) <= uni.getAttackRange()
            && enemyuni.getType() == "base") {

          Vector<Integer> target = new Vector<Integer>();
          target.add(enemyuni.getId());
          target.add(enemyuni.getCurrentHP());
          target.add(enemyuni.getX());
          target.add(enemyuni.getY());

          targets.add(target);

        }
      }
      if (!targets.isEmpty()) {
        Vector<Integer> weakest = Utilities.findTheWeakest(targets);

        uni.setStatus(Unit.Attacking);
        uni.setTargetX(weakest.get(2));
        uni.setTargetY(weakest.get(3));
        uni.setPrevStatus(Unit.Moving);

        for (Unit enemyuni: unitlist) {
          if (enemyuni.getId() == weakest.get(0)) {
            enemyuni.setDamageSuffered(enemyuni.getDamageSuffered()
                                       + (uni.getAttackSpeed() * uni
                                               .getDamage()));
          }
        }
      }

    }
  }

  public Vector<Vector<Integer>> sendDamages (ArrayList<Unit> unitlist)
  {
    Vector<Vector<Integer>> damages = new Vector<Vector<Integer>>();

    int i = 0, j = 0;
    for (Unit uni: unitlist) {
      if (uni.getOwner() != id && uni.getDamageSuffered() > 0) {
        Vector<Integer> dam = new Vector<Integer>();
        dam.add(uni.getId());
        dam.add(uni.getDamageSuffered());
        damages.add(dam);

      }
    }
    if (damages.size() == 0) {
      Vector<Integer> dam = new Vector<Integer>();
      dam.add(-1);
      dam.add(0);
      damages.add(dam);
    }

    return damages;
  }

  public void receiveDamages (Vector<Vector<Integer>> damages)
  {
    while (!damages.isEmpty()) {
      Vector<Integer> dam = new Vector<Integer>();
      dam = damages.remove(0);
      for (Unit uni: units) {
        if (uni.getId() == dam.get(0))
          uni.setDamageSuffered(dam.get(1));
      }
    }
  }

  public void resolveDamages (ArrayList<Unit> unitlist)
  {

    int i = unitlist.size() - 1;
    while (i >= 0) {
      if (unitlist.get(i).getOwner() == id) {
        if (unitlist.get(i).getCurrentHP() > unitlist.get(i)
                .getDamageSuffered()) {
          unitlist.get(i).setCurrentHP(unitlist.get(i).getCurrentHP()
                                               - unitlist.get(i)
                                                       .getDamageSuffered());
          unitlist.get(i).setDamageSuffered(0);
        }
        else {
          unitlist.remove(i);

        }
      }
      i--;

    }

  }

  public void moveUnits (ArrayList<Unit> units)
  {

    for (Unit uni: units) {
      if (uni.getOwner() == id && uni.getStatus() == Unit.Moving) {

        if (uni.getDestX() == -1)
          Utilities.setFirstDestination(uni);
        if (uni.getDestX() == uni.getX() && uni.getDestY() == uni.getY())
          Utilities.setDestination(uni);
        if (uni.getX() > uni.getDestX())
          uni.setX(uni.getX() - uni.getSpeed());
        if (uni.getX() < uni.getDestX())
          uni.setX(uni.getX() + uni.getSpeed());
        if (uni.getY() > uni.getDestY())
          uni.setY(uni.getY() - uni.getSpeed());
        if (uni.getY() < uni.getDestY())
          uni.setY(uni.getY() + uni.getSpeed());
        uni.setPrevStatus(Unit.Moving);

      }
      if (uni.getOwner() == id && uni.getStatus() == Unit.Attacking) {
        uni.setStatus(Unit.Moving);
        uni.setPrevStatus(Unit.Attacking);
      }
    }

  }

  // TODO
  public int chooseRandomCorridor () // Generates a random number
  {
	  Random generator = new Random(); 
	  int roll = generator.nextInt(3); // Using the Random class' nextInt() method to generate a random number between 0 and 2;
	  return roll;
	  
  }

}
