package Player;

import java.util.ArrayList;
import java.util.Vector;
import java.util.Random;

import Platform.Utilities;
import Units.Base;
import Units.Marine;
import Units.Unit;


public class HeuristicPlayer implements AbstractPlayer
{

  private int id;
  private int startX;
  private int startY;

  ArrayList<Unit> units = new ArrayList<Unit>();

  public HeuristicPlayer (Integer pid)
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
    return "Heuristic";
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
  
  
  // TODO
  public void chooseCorridor (ArrayList<Marine> marines)
  {
	  double moveToFirst = 0; // Stores the result of the first evaluation
	  double moveToSecond = 0; // Stores the result of the second evaluation
	  double moveToThird = 0; // Stores the result of the third evaluation
	  double bestEvaluation = 0; // Stores maximum evaluation
	  int bestMovement = 0; // Stores the best movement 
	  
	  
	  
	  if (marines.size() == 3) //Checking if this array is the initial one (with the 3 units)
	  {
//		  Random generator = new Random();
//		  bestMovement = generator.nextInt(3);
		  for (Marine marine : marines)
		  {
			  
			  marine.movingToCorridor(0);
			 
		  }  
	  } 
	  else
	  {	  
		  for (Marine marine : marines)
		  {		 		 	
	
			  moveToFirst =  evaluate(0);
			  moveToSecond =  evaluate(1);
			  moveToThird = evaluate(2);

			  bestEvaluation = moveToFirst;
			 
			  //Simple max algorithm
			  if (bestEvaluation < moveToSecond)
			  {
				 
				  bestEvaluation = moveToSecond;
				  bestMovement = 1;
		 
			  }
			  if (bestEvaluation < moveToThird)
			  {
				 
				  bestEvaluation = moveToThird;
				  bestMovement = 2;
				 
			  }
			 
			  marine.movingToCorridor(bestMovement); // Using the object's function movingToCorridor to send the marine to the best lane 
		 }	  		  
	  }	  
  }

  // TODO
  private double evaluate (int corridor)
  {
	
	// Initial variables and arrays that will store information through the algorithm
	// Most of them are self explanatory
	  
	double evaluation = 0;	// The evaluation result will be stored here
	int[] laneEnemies = new int[Utilities.NUMBER_OF_CORRIDORS]; // Number of lane enemies (corridor enemies)
	int[] attackingBaseEnemies = new int[Utilities.NUMBER_OF_CORRIDORS]; // Number of enemies that are attacking the base
	int[] closeEnemies = new int[Utilities.NUMBER_OF_CORRIDORS]; // Number of enemies that are close to the base
	int[] laneAllies = new int[Utilities.NUMBER_OF_CORRIDORS]; // Number of lane allies (corridor allies)
	int[] closeToOurBaseAllies = new int[Utilities.NUMBER_OF_CORRIDORS]; // Number of allies that are close to our base
	ArrayList<Unit> findTheStack = new ArrayList<Unit>(); // ArrayList that will store the enemy units in the game in order to find if some of them are stacked
	

	// Gathering information
	
	
	// Loop that counts all the units in the game and categorizes them
	for (Unit uni : units) 
	{	
		for (int i = 0; i < Utilities.NUMBER_OF_CORRIDORS; i++)
		{

			if (uni.getOwner() != id && uni.isMarine() == true && uni.getCorridor() == i)
			{							
				
				findTheStack.add(uni); 
				laneEnemies[i]++;				
				if (Utilities.getDistance(uni.getX(),uni.getY(),startX,startY) < 200) // Using the Utilities.getDistance function to calculate the distance between a unit and the base
				{					
					closeEnemies[i]++;						
					if (uni.isAttackingBase() == true)
					{	
						
						attackingBaseEnemies[i]++;
						
					} 							
				}
			}
			else if (uni.getOwner() == id && uni.isMarine() == true && uni.getCorridor() == i) 		
			{
				
				laneAllies[i]++;
				
				if (Utilities.getDistance(uni.getX(),uni.getY(),startX,startY) < 200) // Using the Utilities.getDistance function to calculate the distance between a unit and the base	
				{
					
					closeToOurBaseAllies[i]++;
					
				}	
			}		
		}
	}
	
	double minDistance = 900; // In order to find the minimum distance among distances we set the first min to 900 units. 
							  // This is because the map is 800x200 so there is no way that a distance will exceed the limit of 900
	double currentUnitDistance = 0; // Variable that stores the distance between the base and a unit
	// Simple min algorithm
	for (int i = 0; i < findTheStack.size(); i++) 
	{
		currentUnitDistance =  Utilities.getDistance(findTheStack.get(i).getX(),findTheStack.get(i).getY(),startX,startY);
		if (findTheStack.get(i).getCorridor() == corridor && minDistance > currentUnitDistance)
		{
				
			minDistance = currentUnitDistance;
				
		}		
	}
			
	int stackedUnits = 0; // Variable to count the stacked Units
	// Simple loop to count
	for (int i = 0; i < findTheStack.size(); i++) 
	{
		currentUnitDistance =  Utilities.getDistance(findTheStack.get(i).getX(),findTheStack.get(i).getY(),startX,startY);
		if (findTheStack.get(i).getCorridor() == corridor && minDistance == currentUnitDistance)
		{
				
			stackedUnits++;
				
		}		
	}

	int losingMultipleLanes = 0; // Variable that counts the lanes that we are losing
	// Simple loop to count
	for (int i = 0; i < Utilities.NUMBER_OF_CORRIDORS; i++)
	{
		
		if (laneEnemies[i] > laneAllies[i])
		{
			
			losingMultipleLanes++;
			
		}		
	}
	
	// Evaluation Algorithm
	// This section is the least commented since there is a detailed explanation in the report of what's going on
	
	if (stackedUnits > 1)
	{
			
		evaluation +=50;
			
	}
	else
	{
		
		if (laneAllies[corridor] > 0 && laneEnemies[corridor] > 0)
		{
			
			if (laneAllies[corridor] > laneEnemies[corridor])
			{
				
				evaluation += 1*(laneAllies[corridor]-laneEnemies[corridor]);
				
			}
			else if (laneAllies[corridor] == laneEnemies[corridor])
			{
				if (laneEnemies[corridor] >= 2) // Obviously laneAllies[corridor] >= 2 too
				{
					
					evaluation += 0;
					
				}
				else
				{
					
					for (int i = 0 ; i < Utilities.NUMBER_OF_CORRIDORS ; i++)
					{
							
						if (i != corridor && (laneAllies[i] - laneEnemies[i]) > 0 && laneEnemies[i] != 0)
						{
							
							{
								
								evaluation -= 1*(laneAllies[i]-laneEnemies[i]); 	
								
							}
							
						}
						else if (i != corridor && (laneAllies[i] - laneEnemies[i] > 3) && laneEnemies[i] == 0)
						{
							
							evaluation += 1;
							
						}
					}					
				}
			}
			else
			{
				for (int i = 0; i < Utilities.NUMBER_OF_CORRIDORS; i++)
				{
					
					if (laneEnemies[i]-laneAllies[i] > (laneEnemies[corridor] - laneAllies[corridor]))
					{
						
						evaluation += 1.05*(laneEnemies[i]-laneAllies[i]);
						
					}
					else
					{
						
						evaluation += 0;
						
					}
					
				}								
			}		
		}
		else if (laneAllies[corridor] > 0 && laneEnemies[corridor] == 0)
		{
			
			boolean flag = false; // Using a flag to check if two corridors are in the same state
			for (int i = 0 ; i < Utilities.NUMBER_OF_CORRIDORS ; i++)
			{
				
				if ((i != corridor) && (laneAllies[i] - laneEnemies[i]) > 2 && flag == false)
				{
					
					if (closeToOurBaseAllies[corridor] > 0)
					{
						
						evaluation += 1.2*(laneAllies[i]-laneEnemies[i]);
						
					}
					else
					{
						
						evaluation += 1.1*(laneAllies[i]-laneEnemies[i]);
						
					}
					
					flag = true;
						
				}
				else if ((i != corridor) && (laneEnemies[i] - laneAllies[i]) > 2 && losingMultipleLanes == 1)
				{
					
					evaluation += 1*(laneEnemies[i]-laneAllies[i]);
					
				}
				else if (i != corridor && (laneEnemies[i] - laneAllies[i] == 1) && laneAllies[i] != 0)
				{
					
					evaluation += 1;
					
				}
				else if ((i != corridor) && laneEnemies[i] == laneAllies[i] && laneAllies[i] != 0) // Obviously if laneAllies[i] !=0 then enemies[i] != 0 too
				{
					
					evaluation += 1;
					
				}
			}
		}
		else if (laneEnemies[corridor] > 0 && laneAllies[corridor] == 0)
		{
			
			if (laneEnemies[corridor] > 4)
			{
				
				evaluation += 1*laneEnemies[corridor] + 7*closeEnemies[corridor] + 5*attackingBaseEnemies[corridor];
				
			}
			else if (laneEnemies[corridor] <= 4)
			{

				evaluation += 7*closeEnemies[corridor] + 5*attackingBaseEnemies[corridor];
				
			}		
		}
		else if (laneAllies[corridor] == 0 && laneEnemies[corridor] == 0)
		{
			
			
			boolean flag = false; // Using a flag to check if two corridors are in the same state
			for (int i = 0 ; i < Utilities.NUMBER_OF_CORRIDORS ; i++)
			{
				
				if ((i != corridor) && (laneAllies[i] - laneEnemies[i]) > 2 && flag == false) 
				{
					
					evaluation += 1.1*(laneAllies[i]-laneEnemies[i]);
					flag = true;
					
				}
				else if ((i != corridor) && laneAllies[i] == laneEnemies[i] && laneAllies[i] != 0) // Obviously if laneAllies[i] !=0 then enemies[i] != 0 too
				{
		
					evaluation += 1;
		
				}
				else if ((i != corridor) && laneAllies[i] == 0 && laneEnemies[i] == 0)
				{
					
					evaluation += 0.5;
					
				}
				else if ((i != corridor) && (laneEnemies[i] - laneAllies[i]) > 1 && losingMultipleLanes == 1)
				{
					
					evaluation += 1*(laneEnemies[i]-laneAllies[i]);
					
				}
			}		
		}
	}
    return evaluation;   
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

}
