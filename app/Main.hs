module Main where

import Graphics.UI.Gtk
import DomainModel.Core
import DomainModel.SE
import Control.Concurrent.MVar

mainGraphic :: IO ()
mainGraphic = do
  initGUI
  -- Create a new window
  window <- windowNew
  -- Here we connect the "destroy" event to a signal handler.
  -- This event occurs when we call widgetDestroy on the window
  -- or if the user closes the window.
  onDestroy window mainQuit
  hbox    <- hBoxNew True 10
  -- Set the border width and tile of the window. Note that border width
  -- attribute is in 'Container' from which 'Window' is derived.

  -- Creates a new button with the label "Hello World".
  button <- buttonNew
  ledGUI <- labelNew $ Just "Off"
  led <- newMVar initialLedStatus
  set button [ buttonLabel := "Turn On led" ]
  -- When the button receives the "clicked" signal, it will call the
  -- function given as the second argument.
  subject  <- return (Subject () ([]) )
  observer <- return (\_ -> do label <- ledMVarObserver led
                               labelSetText ledGUI label)

  subject <- addObserver subject observer
  onClicked button (do notify subject)
  boxPackStart hbox button PackGrow 0
  boxPackStart hbox ledGUI PackGrow 0
  set window [ containerBorderWidth := 10, windowTitle := "ButtonLed subSystem", containerChild := hbox ]
  -- The final step is to display this newly created widget. Note that this
  -- also allocates the right amount of space to the windows and the button.
  widgetShowAll window
  -- All Gtk+ applications must have a main loop. Control ends here
  -- and waits for an event to occur (like a key press or mouse event).
  -- This function returns if the program should finish.
  mainGUI

ledMain :: Led -> IO ()
ledMain l = do
  putStrLn "press enter to switch the led(ditig x + enter to exit)"
  x <- getChar
  if (x == 'x')
    then return()
    else do
      let l' = switch l
      putStrLn $ show l'
      ledMain l'

main :: IO ()
main = mainGraphic -- ledMain initialLedStatus
