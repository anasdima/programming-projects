package Units;

import java.util.ArrayList;

public abstract class Unit implements Cloneable
{
  final static public int Standing = 0;
  final static public int Moving = 1;
  final static public int Attacking = 2;
  final static public int marineDamage = 3;
  final static public int marineAttackSpeed = 2;

  int id;

  int owner;

  int x, y, radius, sight_range, currentHP, maxHP, armor;

  int attackRange, damage, attackSpeed;

  int speed, corridor;

  int status;

  int destX, destY;
  int damageSuffered;

  int prevStatus;

  int targetX, targetY;

  public int getX ()
  {
    return x;
  }

  public int getY ()
  {
    return y;
  }

  public int getDamage ()
  {

    return damage;

  }

  public int getDestX ()
  {
    return destX;
  }

  public int getDestY ()
  {
    return destY;
  }

  public int getTargetX ()
  {
    return targetX;
  }

  public int getTargetY ()
  {
    return targetY;
  }

  public int getId ()
  {
    return id;
  }

  public int getOwner ()
  {
    return owner;
  }

  public int getDamageSuffered ()
  {
    return damageSuffered;
  }

  public int getAttackRange ()
  {
    return attackRange;
  }

  public int getAttackSpeed ()
  {
    return attackSpeed;
  }

  public int getCurrentHP ()
  {
    return currentHP;
  }

  public int getStatus ()
  {
    return status;
  }

  public int getCorridor ()
  {
    return corridor;
  }

  public int getPrevStatus ()
  {
    return prevStatus;
  }

  public int getMaxHP ()
  {
    return maxHP;
  }

  public int getRadius ()
  {
    return radius;
  }

  public int getSpeed ()
  {
    return speed;
  }

  public void setDestX (int destX)
  {
    this.destX = destX;
  }

  public void setDestY (int destY)
  {
    this.destY = destY;
  }

  public void setX (int x)
  {
    this.x = x;
  }

  public void setY (int y)
  {
    this.y = y;
  }

  public void setTargetX (int x)
  {
    this.targetX = x;
  }

  public void setTargetY (int y)
  {
    this.targetY = y;
  }

  public void setStatus (int status)
  {
    this.status = status;
  }

  public void setPrevStatus (int prevStatus)
  {
    this.prevStatus = prevStatus;
  }

  public void setCorridor (int corridor)
  {
    this.corridor = corridor;
  }

  public void setDamageSuffered (int damageSuffered)
  {
    this.damageSuffered = damageSuffered;
  }

  public void setCurrentHP (int hp)
  {
    this.currentHP = hp;
  }

  public abstract String getType ();

  public static ArrayList<Unit> cloneList (ArrayList<Unit> list)
  {
    ArrayList<Unit> clone = new ArrayList<Unit>(list.size());
    for (Unit item: list)
      try {
        clone.add((Unit) item.clone());
      }
      catch (CloneNotSupportedException e) {
        // TODO Auto-generated catch block
        e.printStackTrace();
      }
    return clone;
  }

}
