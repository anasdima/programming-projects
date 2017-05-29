package Units;

public class Marine extends Unit
{

  public String getType ()
  {

    return "marine";
  }
  
  public boolean isMarine(){
	  return true;
  }

  public Marine ()
  {
  }

  public Marine (int uid, int pid, int x, int y)
  {
    id = uid;
    owner = pid;
    this.x = x;
    this.y = y;
    radius = 20;
    sight_range = 64;
    currentHP = 50;
    maxHP = 50;
    armor = 0;
    attackRange = 101;
    damage = 3;
    attackSpeed = 1;
    speed = 2;
    corridor = -1;
    status = Standing;

    destX = -1;
    destY = -1;
    damageSuffered = 0;
    prevStatus = -1;
    targetX = -1;
    targetY = -1;
    

  }
}
