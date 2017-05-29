package Player;

import java.util.ArrayList;
import java.util.Vector;

import Platform.Utilities;
import Units.Base;
import Units.Marine;
import Units.Unit;

public class RandomPlayer implements AbstractPlayer
{

  private int id;
  private int startX;
  private int startY;

  ArrayList<Unit> units = new ArrayList<Unit>();

  public RandomPlayer (Integer pid)
  {
    id = pid;
    if (pid == Utilities.PLAYERA_ID) {
      startX = Utilities.PLAYERA_STARTX;
      startY = Utilities.PLAYERA_STARTY;
    }
    else {
      startX = Utilities.PLAYERB_STARTX;
      startY = Utilities.PLAYERB_STARTY;

    }
  }

  public int getId ()
  {
    return id;
  }

  public int getStartX ()
  {
    return startX;
  }

  public int getStartY ()
  {
    return startY;
  }

  public void setId (int id)
  {
    this.id = id;
  }

  public void setStartX (int startX)
  {
    this.startX = startX;
  }

  public void setStartY (int startY)
  {
    this.startX = startY;
  }

  public String setName ()
  {
    return "Random";
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

  Base createInitialBase (int unitId)
  {
    return new Base(unitId, id, startX, startY);
  }

  void createBase (int id, int ownerID, int startingX, int startingY)
  {
    Base base = new Base(id, ownerID, startingX, startingY);
    Utilities.unitID++;
    units.add(base);

  }

  public void createBase ()
  {
    createBase(Utilities.unitID, id, startX, startY);

  }

  Marine createInitialMarine (int unitId)
  {
    return new Marine(unitId, id, startX, startY);

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

  public ArrayList<Marine> getStationaryMarines ()
  {
    ArrayList<Marine> ownUnits = new ArrayList<Marine>();
    for (Unit uni: units) {
      if (uni.getOwner() == id && uni.isMarine() && uni.getCorridor() == -1)
        ownUnits.add((Marine) uni);
    }
    return ownUnits;

  }

  public void setUnits (ArrayList<Unit> unitlist)
  {
    units = unitlist;
  }

  public void chooseCorridor (ArrayList<Marine> marines)
  {

   for (Marine marine: marines)
      marine.movingToCorridor(chooseRandomCorridor());

  }

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

  public int chooseRandomCorridor ()
  {

    return (int) (Math.random() * Utilities.NUMBER_OF_CORRIDORS);
  }

}
