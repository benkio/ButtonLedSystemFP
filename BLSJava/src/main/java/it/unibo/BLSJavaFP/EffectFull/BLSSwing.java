package it.unibo.BLSJavaFP.EffectFull;

import javax.swing.*;        

public class BLSSwing {
    
    public static final JButton btn = new JButton("Turn on the led");
    public static  final JLabel ledLabel = new JLabel();
    
    /**
     * Create the GUI and show it.  For thread safety,
     * this method should be invoked from the
     * event-dispatching thread.
     */
    private static void createAndShowGUI() {
        // JPanel
        JPanel pnlButton = new JPanel();
        
        JLabel ledStatusDescription = new JLabel("Led Status: ");

        JFrame mainFrame = new JFrame();

        // Adding to JFrame
        pnlButton.add(btn);
        pnlButton.add(ledStatusDescription);
        pnlButton.add(ledLabel);
        mainFrame.add(pnlButton);
        // JFrame properties
        mainFrame.setSize(200, 100);
        mainFrame.setTitle("Button Led Subsystem");
        mainFrame.setLocationRelativeTo(null);
        mainFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        mainFrame.setVisible(true);
    }

    public static void main() {
        //Schedule a job for the event-dispatching thread:
        //creating and showing this application's GUI.
        javax.swing.SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                createAndShowGUI();
            }
        });
    }
}
