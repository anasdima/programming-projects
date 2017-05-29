package Platform;

import java.util.Vector;

import Units.Unit;

public class Utilities
{

  public static final int NUMBER_OF_CORRIDORS = 3;
  public static final int PLAYERA_ID = 1;
  public static final int PLAYERB_ID = 2;
  public static final int PLAYERA_STARTX = 10;
  public static final int PLAYERA_STARTY = 150;
  public static final int PLAYERB_STARTX = 790;
  public static final int PLAYERB_STARTY = 150;

  public static int unitID = 0;

  // TODO
  public static double getDistance (int x1, int y1, int x2, int y2)
  {
	  double result = 0;

	    result = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));

	    return result;
  }

  // TODO
  public static double getDistance (Unit a, Unit b)
  {

	    double result = 0;

	    result = getDistance(a.getX(), a.getY(), b.getX(), b.getY());

	    return result;
  }

  public static void setFirstDestination (Unit uni)
  {
    if (uni.getDestX() == -1) {
      if (uni.getCorridor() == 0) {
        if (uni.getOwner() == 1) {
          uni.setDestX(100);
          uni.setDestY(50);
        }
        if (uni.getOwner() == 2) {
          uni.setDestX(700);
          uni.setDestY(50);
        }
      }

      if (uni.getCorridor() == 1) {
        if (uni.getOwner() == 1) {
          uni.setDestX(100);
          uni.setDestY(150);
        }
        if (uni.getOwner() == 2) {
          uni.setDestX(700);
          uni.setDestY(150);
        }
      }
      if (uni.getCorridor() == 2) {
        if (uni.getOwner() == 1) {
          uni.setDestX(100);
          uni.setDestY(250);
        }
        if (uni.getOwner() == 2) {
          uni.setDestX(700);
          uni.setDestY(250);
        }
      }

    }
  }

  public static void setDestination (Unit uni)
  {
    if (uni.getOwner() == 1) {
      if (uni.getX() == 100 && uni.getY() == 50) {
        uni.setDestX(700);
        uni.setDestY(50);
      }
      if (uni.getX() == 100 && uni.getY() == 150) {
        uni.setDestX(700);
        uni.setDestY(150);
      }
      if (uni.getX() == 100 && uni.getY() == 250) {
        uni.setDestX(700);
        uni.setDestY(250);
      }
      if (uni.getX() == 700 && uni.getY() == 50) {
        uni.setDestX(790);
        uni.setDestY(150);
      }
      if (uni.getX() == 700 && uni.getY() == 150) {
        uni.setDestX(790);
        uni.setDestY(150);
      }
      if (uni.getX() == 700 && uni.getY() == 250) {
        uni.setDestX(790);
        uni.setDestY(150);
      }
    }
    if (uni.getOwner() == 2) {
      if (uni.getX() == 100 && uni.getY() == 50) {
        uni.setDestX(10);
        uni.setDestY(150);
      }
      if (uni.getX() == 100 && uni.getY() == 150) {
        uni.setDestX(10);
        uni.setDestY(150);
      }
      if (uni.getX() == 100 && uni.getY() == 250) {
        uni.setDestX(10);
        uni.setDestY(150);
      }
      if (uni.getX() == 700 && uni.getY() == 50) {
        uni.setDestX(100);
        uni.setDestY(50);
      }
      if (uni.getX() == 700 && uni.getY() == 150) {
        uni.setDestX(100);
        uni.setDestY(150);
      }
      if (uni.getX() == 700 && uni.getY() == 250) {
        uni.setDestX(100);
        uni.setDestY(250);
      }
    }
  }

  public static Vector<Integer>
    findTheWeakest (Vector<Vector<Integer>> targets)
  {
    // int leasthp = targets.get(0).get(1);
    int leasthp = 10001;
    int leastid = -1;
    int leastX = 0;
    int leastY = 0;
    Vector<Integer> weakest = new Vector<Integer>();

    for (int i = 0; i < targets.size(); i++) {
      if (targets.get(i).get(1) < leasthp) {
        leasthp = targets.get(i).get(1);
        leastid = targets.get(i).get(0);

        leastX = targets.get(i).get(2);
        leastY = targets.get(i).get(3);
      }
    }

    weakest.add(leastid);
    weakest.add(leasthp);
    weakest.add(leastX);
    weakest.add(leastY);
    return weakest;
  }

}
