// Όνομα: Δημανίδης Αναστάσιος
// ΑΕΜ: 7422
// email: anasdima@auth.gr
// Τηλέφωνο: 6982023258

// Όνομα: Δοξόπουλος Παναγιώτης
// ΑΕΜ: 7601
// email: doxopana@auth.gr
// Τηλέφωνο: 6976032566

package Platform;

import java.awt.BorderLayout;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.StringTokenizer;
import java.util.Vector;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JSlider;

import Player.AbstractPlayer;
import Units.Unit;

public class MainPlatform
{

  protected static JFrame frame;
  private static JComboBox teamOne;
  private static JComboBox teamTwo;
  private static JButton generateMap;
  private static JButton play;
  private static JButton quit;
  private static JSlider gamespeed;
  protected static Map map;
  static ArrayList<Unit> allUnits = new ArrayList<Unit>();
  static int time = 0;
  static int timestep = 150;

  private static AbstractPlayer playerA;
  private static AbstractPlayer playerB;

  private static String PlayerOne = "Player.Player";
  private static String PlayerTwo = "Player.Player";

  private static String[] teamNames = { "Team 0.00" };
  private static String[] teamClasses = { "Player.Player" };

  // static State state = new State();

  private static String showScore ()
  {
    // Retrieve all Elements, for transformation
    Vector prey_number = new Vector(1, 1);
    Vector prey_AEM = new Vector(1, 1);
    Vector prey_Score = new Vector(1, 1);
    Vector predator_number = new Vector(1, 1);
    Vector predator_AEM = new Vector(1, 1);
    Vector predator_Score = new Vector(1, 1);
    Vector number_of_steps = new Vector(1, 1);

    File inputFile = new File("GameLog.txt");
    try {
      BufferedReader r =
        new BufferedReader(
                           new InputStreamReader(new FileInputStream(inputFile)));
      String line;
      while ((line = r.readLine()) != null) {
        // For each line, retrieve the elements...
        StringTokenizer parser = new StringTokenizer(line, "\t");
        String str_prey_number = parser.nextToken();
        String str_prey_AEM = parser.nextToken();
        String str_prey_Score = parser.nextToken();
        String str_predator_number = parser.nextToken();
        String str_predator_AEM = parser.nextToken();
        String str_predator_Score = parser.nextToken();
        String str_number_of_steps = parser.nextToken();

        if (prey_number.contains(str_prey_number)) {
          int prey_pos = prey_number.indexOf(str_prey_number);
          float previous_score =
            (float) (Float
                    .parseFloat(prey_Score.elementAt(prey_pos).toString()));
          float current_score = (float) (Float.parseFloat(str_prey_Score));
          float final_score = previous_score + current_score;
          prey_Score.removeElementAt(prey_pos);
          prey_Score.insertElementAt(final_score + "", prey_pos);
        }
        else {
          prey_number.add(str_prey_number);
          prey_AEM.add(str_prey_AEM);
          prey_Score.add(str_prey_Score);
        }

        if (predator_number.contains(str_predator_number)) {
          int predator_pos = predator_number.indexOf(str_predator_number);
          float previous_score =
            (float) (Float.parseFloat(predator_Score.elementAt(predator_pos)
                    .toString()));
          float current_score = (float) (Float.parseFloat(str_predator_Score));
          float final_score = previous_score + current_score;
          predator_Score.removeElementAt(predator_pos);
          predator_Score.insertElementAt(final_score + "", predator_pos);
        }
        else {
          predator_number.add(str_predator_number);
          predator_AEM.add(str_predator_AEM);
          predator_Score.add(str_predator_Score);
        }
        number_of_steps.add(str_number_of_steps);
      }
    }
    catch (IOException ioException) {
      System.out.println(ioException);
    }

    String output =
      " TEAM No         TEAM Name          FINAL \n=======================================================\n";

    for (int i = 0; i < prey_number.size(); i++) {
      String pr_team_number = prey_number.elementAt(i).toString();
      float pr_score =
        (float) (Float.parseFloat(prey_Score.elementAt(i).toString()));
      float pd_score = 0;
      int other_pos = predator_number.indexOf(pr_team_number);
      if (other_pos != -1) {
        pd_score =
          (float) (Float.parseFloat(predator_Score.elementAt(other_pos)
                  .toString()));
      }
      float score = pr_score + pd_score;

      output +=
        pr_team_number + "       " + prey_AEM.elementAt(i).toString()
                + "           ";
      output += "           " + score + "\n";
    }

    for (int i = 0; i < predator_number.size(); i++) {
      String pd_team_number = predator_number.elementAt(i).toString();
      if (prey_number.contains(pd_team_number)) {

      }
      else {
        float pd_score =
          (float) (Float.parseFloat(predator_Score.elementAt(i).toString()));
        float pr_score = 0;
        int other_pos = prey_number.indexOf(pd_team_number);
        if (other_pos != -1) {
          pr_score =
            (float) (Float.parseFloat(prey_Score.elementAt(other_pos)
                    .toString()));
        }
        float score = pr_score + pd_score;

        output +=
          pd_team_number + "       " + predator_AEM.elementAt(i).toString()
                  + "           ";
        output += "                        " + score + "\n";
      }
    }
    return output;

  }

  private static void createAndShowGUI ()
  {

    JFrame.setDefaultLookAndFeelDecorated(false);
    frame = new JFrame("MAZE");
    frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    map = new Map();
    JPanel buttonPanel = new JPanel();
    BoxLayout horizontal = new BoxLayout(buttonPanel, BoxLayout.X_AXIS);
    JPanel teamsPanel = new JPanel();
    JPanel centerPanel = new JPanel();
    generateMap = new JButton("Generate Map");
    play = new JButton("Play");
    quit = new JButton("Quit");

    gamespeed = new JSlider(JSlider.HORIZONTAL, 1, 150, 50);
    gamespeed.addChangeListener(new SliderListener());

    gamespeed.setMajorTickSpacing(10);
    gamespeed.setPaintTicks(true);
    Font font = new Font("Serif", Font.ITALIC, 15);
    gamespeed.setFont(font);
    Hashtable labelTable = new Hashtable();
    labelTable.put(new Integer(1), new JLabel("Fast"));
    labelTable.put(new Integer(150), new JLabel("Slow"));
    gamespeed.setLabelTable(labelTable);

    gamespeed.setPaintLabels(true);

    teamOne = new JComboBox(teamNames);
    teamTwo = new JComboBox(teamNames);
    teamOne.setSelectedIndex(0);
    teamTwo.setSelectedIndex(0);
    JLabel label = new JLabel("THE RTS-lite GAME!!!", JLabel.CENTER);

    centerPanel.setLayout(new BorderLayout());
    centerPanel.add("North", label);
    centerPanel.add("Center", gamespeed);

    teamsPanel.setLayout(new BorderLayout());
    teamsPanel.add("West", teamOne);
    teamsPanel.add("East", teamTwo);

    // teamsPanel.add("Center", label);
    // teamsPanel.add(gamespeed);
    teamsPanel.add("Center", centerPanel);
    teamsPanel.add("South", buttonPanel);

    buttonPanel.add(generateMap);
    buttonPanel.add(play);
    buttonPanel.add(quit);

    frame.setLayout(new BorderLayout());
    frame.add("Center", teamsPanel);
    frame.add("South", buttonPanel);

    frame.pack();
    frame.setVisible(true);

    quit.addActionListener(new ActionListener() {
      public void actionPerformed (ActionEvent evt)
      {
        System.exit(0);
      }
    });

    generateMap.addActionListener(new ActionListener() {
      public void actionPerformed (ActionEvent evt)
      {
        play.setEnabled(false);
        generateMap.setEnabled(false);

        frame.repaint();
        frame.remove(map);
        PlayerOne = teamClasses[teamOne.getSelectedIndex()];
        PlayerTwo = teamClasses[teamTwo.getSelectedIndex()];

        playerA = null;
        try {
          Class playerAClass = Class.forName(PlayerOne);
          Class partypes[] = new Class[1];
          partypes[0] = Integer.class;
          //partypes[1] = Integer.class;
          //partypes[2] = Integer.class;

          Constructor playerAArgsConstructor =
            playerAClass.getConstructor(partypes);
          Object arglist[] = new Object[1];
          // arglist[0] = 1;
          // arglist[1] = 10;
          // arglist[2] = 150;
          arglist[0] = new Integer(1);
          //arglist[1] = new Integer(10);
          //arglist[2] = new Integer(150);
          Object playerObject = playerAArgsConstructor.newInstance(arglist);

          playerA = (AbstractPlayer) playerObject;
          // prey = new AbstractCreature(true);
        }
        catch (ClassNotFoundException ex) {
          ex.printStackTrace();
        }
        catch (IllegalAccessException ex) {
          ex.printStackTrace();
        }
        catch (InstantiationException ex) {
          ex.printStackTrace();
        }
        catch (NoSuchMethodException ex) {
          ex.printStackTrace();
        }
        catch (InvocationTargetException ex) {
          ex.printStackTrace();
        }

        playerB = null;
        try {
          Class playerBClass = Class.forName(PlayerTwo);
          Class partypes[] = new Class[1];
          partypes[0] = Integer.class;
          //partypes[1] = Integer.class;
          //partypes[2] = Integer.class;

          Constructor playerBArgsConstructor =
            playerBClass.getConstructor(partypes);
          Object arglist[] = new Object[1];
          // arglist[0] = 1;
          // arglist[1] = 10;
          // arglist[2] = 150;
          arglist[0] = new Integer(2);
          //arglist[1] = new Integer(790);
          //arglist[2] = new Integer(150);
          Object playerObject = playerBArgsConstructor.newInstance(arglist);

          playerB = (AbstractPlayer) playerObject;
          // prey = new AbstractCreature(true);
        }
        catch (ClassNotFoundException ex) {
          ex.printStackTrace();
        }
        catch (IllegalAccessException ex) {
          ex.printStackTrace();
        }
        catch (InstantiationException ex) {
          ex.printStackTrace();
        }
        catch (NoSuchMethodException ex) {
          ex.printStackTrace();
        }
        catch (InvocationTargetException ex) {
          ex.printStackTrace();
        }

        time = 0;
        Utilities.unitID = 0;
        allUnits.clear();
        
        playerA.initialize(3);
        playerB.initialize(3);

        allUnits.addAll(playerA.getUnits());
        allUnits.addAll(playerB.getUnits());

        map = new Map(800, 300, allUnits);
        frame.add("North", map);
        frame.pack();
        play.setEnabled(true);
        generateMap.setEnabled(false);
      }
    });

    play.addActionListener(new ActionListener() {
      public void actionPerformed (ActionEvent evt)
      {
        play.setEnabled(false);
        generateMap.setEnabled(false);

        Thread t = new Thread(new Runnable() {
          public void run ()
          {

            int notwinner = 0;

            while (notwinner < 10000) {
              frame.remove(map);
              boolean end = false;

              if (time % 40 == 0 && time != 0) {
                playerA.createMarine();
                playerB.createMarine();
                allUnits.clear();
                allUnits.addAll(playerA.getOwnUnits());
                allUnits.addAll(playerB.getOwnUnits());
              }

              // Before this step apply fog of war (in the future)
              ArrayList<Unit> unitsforA = new ArrayList<Unit>();
              ArrayList<Unit> unitsforB = new ArrayList<Unit>();
              // for (int i= 0 ; i < allUnits.size(); i ++){

              unitsforA = Unit.cloneList(allUnits);
              unitsforB = Unit.cloneList(allUnits);

              playerA.setUnits(unitsforA);
              playerB.setUnits(unitsforB);

              playerA.chooseCorridor(playerA.getUnits());
              playerB.chooseCorridor(playerB.getUnits());

              allUnits.clear();
              allUnits.addAll(playerA.getOwnUnits());
              allUnits.addAll(playerB.getOwnUnits());

              unitsforA = Unit.cloneList(allUnits);
              unitsforB = Unit.cloneList(allUnits);
              playerA.setUnits(unitsforA);
              playerB.setUnits(unitsforB);

              playerA.resolveAttacking(playerA.getUnits());
              playerB.resolveAttacking(playerB.getUnits());

              // for (Unit uni : playerB.getUnits())
              // {

              // System.out.println(uni.id+" "+uni.hp+" "+uni.damageSuffered);
              // }
              // System.out.println("====");

              playerA.receiveDamages(playerB.sendDamages(playerB.getUnits()));
              playerB.receiveDamages(playerA.sendDamages(playerA.getUnits()));

              allUnits.clear();
              allUnits.addAll(playerA.getOwnUnits());
              allUnits.addAll(playerB.getOwnUnits());

              for (Unit uni: allUnits) {
                if (uni.getType() == "base"
                    && uni.getCurrentHP() <= uni.getDamageSuffered())
                  end = true;
              }

              if (end)
                break;

              unitsforA = Unit.cloneList(allUnits);
              unitsforB = Unit.cloneList(allUnits);
              playerA.setUnits(unitsforA);
              playerB.setUnits(unitsforB);

              playerA.resolveDamages(playerA.getUnits());
              playerB.resolveDamages(playerB.getUnits());

              allUnits.clear();
              allUnits.addAll(playerA.getOwnUnits());
              allUnits.addAll(playerB.getOwnUnits());

              unitsforA = Unit.cloneList(allUnits);
              unitsforB = Unit.cloneList(allUnits);
              playerA.setUnits(unitsforA);
              playerB.setUnits(unitsforB);

              playerA.moveUnits(playerA.getUnits());
              playerB.moveUnits(playerB.getUnits());

              allUnits.clear();
              allUnits.addAll(playerA.getOwnUnits());
              allUnits.addAll(playerB.getOwnUnits());

              notwinner++;

              System.out.println("time= " + time);
              frame.add("North", map);
              frame.validate();
              frame.pack();
              frame.repaint();

              timestep = gamespeed.getValue();

              try {
                Thread.sleep(timestep);
              }
              catch (InterruptedException e) {
              }
              time++;
              if (time == 10000)
                break;

              play.setEnabled(false);
              generateMap.setEnabled(false);

            }

            try {
              BufferedWriter out =
                new BufferedWriter(new FileWriter("GameLog.txt", true));
              int winner = 0;
              int baseAhp = 0;
              int baseBhp = 0;

              for (Unit uniA: allUnits) {
                for (Unit uniB: allUnits) {
                  if (winner == 0 && uniA.getType() == "base"
                      && uniA.getOwner() == 1 && uniB.getType() == "base"
                      && uniB.getOwner() == 2) {
                    baseAhp = uniA.getCurrentHP();
                    baseBhp = uniB.getCurrentHP();
                    if (uniA.getCurrentHP() > uniB.getCurrentHP())
                      winner = uniA.getOwner();
                    else if (uniA.getCurrentHP() < uniB.getCurrentHP())
                      winner = uniB.getOwner();
                    else
                      winner = 3;

                  }
                }

              }

              // System.out.println(winner+" "+ baseAhp + " "+ baseBhp);

              if (winner == 1) {
                out.write(teamNames[teamOne.getSelectedIndex()] + "\t"
                          + playerA.getName() + "\t1\t"
                          + teamNames[teamTwo.getSelectedIndex()] + "\t"
                          + playerB.getName() + "\t0\t" + time + "\n");
                // System.out.println("NO WINNER (TIE)!!!   Number of Steps: "
                // + limit);
                // , new ImageIcon(preyIcon)
                JOptionPane.showMessageDialog(null, "WINNER IS BLUE PLAYER : "
                                                    + playerA.getName()
                                                    + "   Number of Steps: "
                                                    + time, "Results...",
                                              JOptionPane.INFORMATION_MESSAGE);
              }
              else if (winner == 2) {
                out.write(teamNames[teamOne.getSelectedIndex()] + "\t"
                          + playerA.getName() + "\t0\t"
                          + teamNames[teamTwo.getSelectedIndex()] + "\t"
                          + playerB.getName() + "\t1\t" + time + "\n");
                // System.out.println("WINNER IS (predator): " +
                // predator.setName() + "   Number of Steps: " +
                // limit);
                // , new ImageIcon(predatorIcon)
                JOptionPane.showMessageDialog(null, "WINNER IS RED PLAYER: "
                                                    + playerB.getName()
                                                    + "   Number of Steps: "
                                                    + time, "Results...",
                                              JOptionPane.INFORMATION_MESSAGE);

              }
              else if (winner == 3) {
                out.write(teamNames[teamOne.getSelectedIndex()] + "\t"
                          + playerA.getName() + "\t0\t"
                          + teamNames[teamTwo.getSelectedIndex()] + "\t"
                          + playerB.getName() + "\t0\t" + time + "\n");

                JOptionPane.showMessageDialog(null, "WE HAVE A DRAW: ",
                                              "Results...",
                                              JOptionPane.INFORMATION_MESSAGE);

              }
              out.close();
            }
            catch (IOException ioExc) {

            }
            play.setEnabled(true);
            generateMap.setEnabled(true);
            JOptionPane.showMessageDialog(null, showScore(), "SCORE TABLE",
                                          JOptionPane.INFORMATION_MESSAGE);

          }
        });
        t.start();

      }

    });

  }

  /**
   * @param args
   */
  public static void main (String[] args)
  {
    // TODO Auto-generated method stub

    javax.swing.SwingUtilities.invokeLater(new Runnable() {
      public void run ()
      {
        createAndShowGUI();
      }
    });

  }

}
