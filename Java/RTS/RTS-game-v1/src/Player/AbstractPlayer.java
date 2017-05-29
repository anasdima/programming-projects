package Player;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Vector;

import Units.Unit;

public interface AbstractPlayer
{

  Collection<? extends Unit> units = null;

  public String getName ();

  public int getId ();

  public int getStartX ();

  public int getStartY ();
  
  public void setName (String playerName);

  public void setId (int id);

  public void setStartX (int startX);

  public void setStartY (int startY);

  public void initialize (int startMarines);

  public ArrayList<Unit> getUnits ();

  public ArrayList<Unit> getOwnUnits ();

  public void setUnits (ArrayList<Unit> unitlist);

  public void chooseCorridor (ArrayList<Unit> units);

  public void resolveAttacking (ArrayList<Unit> unitlist);

  public void resolveDamages (ArrayList<Unit> unitlist);

  public Vector<Vector<Integer>> sendDamages (ArrayList<Unit> unitlist);

  public void receiveDamages (Vector<Vector<Integer>> damages);

  public void moveUnits (ArrayList<Unit> units);

  public void createMarine ();

  public void createBase ();

}
