package Platform;

import javax.swing.JSlider;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

class SliderListener implements ChangeListener
{
  public void stateChanged (ChangeEvent e)
  {
    JSlider source = (JSlider) e.getSource();
    if (!source.getValueIsAdjusting()) {
      // int fps = (int)source.getValue();

    }
  }
}
