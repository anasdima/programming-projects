package Units;

public class Base extends Unit
{

  public String getType ()
  {

    return "base";
  }
  
  public boolean isBase(){
	  return true;
  }

  public Base (int uid, int pid, int x, int y)
  {
    id = uid;
    owner = pid;
    this.x = x;
    this.y = y;
    radius = 48;
    sight_range = 1000;
    currentHP = 10000;
    maxHP = 10000;
    armor = 0;
    attackRange = 0;
    damage = 0;
    attackSpeed = 0;
    speed = 0;
    corridor = -1;
    status = Standing;
    damageSuffered = 0;
    

  }

}
