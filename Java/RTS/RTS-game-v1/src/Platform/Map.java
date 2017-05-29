package Platform;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Stroke;
import java.util.ArrayList;

import javax.swing.JPanel;

import Units.Unit;

public class Map extends JPanel
{

  private int WIDTH;
  private int HEIGHT;
  private ArrayList<Unit> units;

  public Map ()
  {
    WIDTH = 800;
    HEIGHT = 300;

  }

  public Map (int maze_Width, int maze_Height, ArrayList<Unit> unitsList)
  {
    WIDTH = maze_Width;
    HEIGHT = maze_Height;
    units = unitsList;

  }

  public void setUnits (ArrayList<Unit> unitlist)
  {
    units = unitlist;
  }

  public void paintComponent (Graphics g)
  {
    super.paintComponent(g);
    Graphics2D g2 = (Graphics2D) g;

    g2.setColor(Color.black);
    g2.fillRect(0, 0, 800, 300);
    g2.setColor(Color.WHITE);

    Stroke Stroke =
      new BasicStroke(2, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 0,
                      new float[] { (float) 0.5 }, 0);
    g2.setStroke(Stroke);
    g2.drawLine(100, 100, 700, 100);
    g2.drawLine(100, 200, 700, 200);

    for (Unit uni: units) {
      if (uni.getOwner() == 1 && uni.getType() == "base") {
        Color col =
          new Color((float) 0.0, (float) 1.0, (float) 1.0,
                    (float) ((float) uni.getCurrentHP() / (float) uni
                            .getMaxHP()));
        g2.setColor(col);
        g2.fillOval(uni.getX() - uni.getRadius() / 2,
                    uni.getY() - uni.getRadius() / 2, uni.getRadius(),
                    uni.getRadius());

      }

      if (uni.getOwner() == 2 && uni.getType() == "base") {
        Color col =
          new Color((float) 1.0, (float) 0.1568, (float) 0.4313,
                    (float) ((float) uni.getCurrentHP() / (float) uni
                            .getMaxHP()));
        g2.setColor(col);
        g2.fillOval(uni.getX() - uni.getRadius() / 2,
                    uni.getY() - uni.getRadius() / 2, uni.getRadius(),
                    uni.getRadius());
      }
      if (uni.getOwner() == 1 && uni.getType() == "marine") {
        Color col =
          new Color((float) 0.0, (float) 0.0, (float) 1.0,
                    (float) ((float) uni.getCurrentHP() / (float) uni
                            .getMaxHP()));
        // Color col = new Color(0,0,255);
        g2.setColor(col);
        g2.fillOval(uni.getX() - uni.getRadius() / 2,
                    uni.getY() - uni.getRadius() / 2, uni.getRadius(),
                    uni.getRadius());

        if (uni.getPrevStatus() == Unit.Attacking) {

          g2.setColor(Color.blue);
          float theta = 0;
          if ((uni.getTargetX() - uni.getX()) == 0
              && (uni.getTargetY() - uni.getY()) > 0) {
            theta = (float) Math.atan(Double.POSITIVE_INFINITY);

          }
          else if ((uni.getTargetX() - uni.getX()) == 0
                   && (uni.getTargetY() - uni.getY()) <= 0) {
            theta = (float) Math.atan(Double.NEGATIVE_INFINITY);
          }
          else {
            theta =
              (float) Math.atan((uni.getTargetY() - uni.getY())
                                / (uni.getTargetX() - uni.getX()));
          }

          g2.fillOval((int) (uni.getX() + 10 * Math.cos(theta)),
                      (int) (uni.getY() + 10 * Math.sin(theta) - 3), 6, 6);
          g2.fillOval((int) (uni.getX() + 15 * Math.cos(theta)),
                      (int) (uni.getY() + 15 * Math.sin(theta) - 3), 6, 6);
          g2.fillOval((int) (uni.getX() + 20 * Math.cos(theta)),
                      (int) (uni.getY() + 20 * Math.sin(theta) - 3), 6, 6);

        }
      }
      if (uni.getOwner() == 2 && uni.getType() == "marine") {
        Color col =
          new Color((float) 1.0, (float) 0.0, (float) 0.0,
                    (float) ((float) uni.getCurrentHP() / (float) uni
                            .getMaxHP()));
        // Color col = new Color(255,0,0);
        g2.setColor(col);
        g2.fillOval(uni.getX() - uni.getRadius() / 2,
                    uni.getY() - uni.getRadius() / 2, uni.getRadius(),
                    uni.getRadius());

        if (uni.getPrevStatus() == Unit.Attacking) {

          g2.setColor(Color.red);
          float theta = 0;
          if ((uni.getTargetX() - uni.getX()) == 0
              && (uni.getTargetY() - uni.getY()) > 0) {
            theta = (float) Math.atan(Double.POSITIVE_INFINITY);

          }
          else if ((uni.getTargetX() - uni.getX()) == 0
                   && (uni.getTargetY() - uni.getY()) < 0) {
            theta = (float) Math.atan(Double.NEGATIVE_INFINITY);
          }
          else {
            theta =
              (float) Math.atan((uni.getTargetY() - uni.getY())
                                / (uni.getTargetX() - uni.getX()));
          }

          g2.fillOval((int) (uni.getX() - 10 * Math.cos(theta)),
                      (int) (uni.getY() - 10 * Math.sin(theta) - 3), 6, 6);
          g2.fillOval((int) (uni.getX() - 15 * Math.cos(theta)),
                      (int) (uni.getY() - 15 * Math.sin(theta) - 3), 6, 6);
          g2.fillOval((int) (uni.getX() - 20 * Math.cos(theta)),
                      (int) (uni.getY() - 20 * Math.sin(theta) - 3), 6, 6);

        }
      }

    }
  }

  public Dimension getPreferredSize ()
  {
    return new Dimension(WIDTH, HEIGHT);
  }

}
