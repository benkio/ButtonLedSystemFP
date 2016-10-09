module Application.Local where

import Graphics.UI.Gtk
import Control.Concurrent.MVar
import Pure.Data
import Pure.Behaviours
import Control.Concurrent.MVar
import Control.Monad.State.Lazy as S

ledMVarObserver :: MVar Led -> IO String
ledMVarObserver led = do  tryLedCurrentStatus <- tryTakeMVar led
                          case tryLedCurrentStatus of
                            Just l -> do putStrLn $ show l
                                         updateLed <- tryPutMVar led (switch l)
                                         if (updateLed)
                                           then if (getLedStatus (switch l)) then return "On" else return "Off"
                                           else error "error in led update"
                            Nothing -> error "error in led Read"

mainGraphic :: IO ()
mainGraphic = do
  initGUI
  window <- windowNew
  onDestroy window mainQuit
  hbox    <- hBoxNew True 10
  button <- buttonNew
  ledGUI <- labelNew $ Just "Off"
  led <- newMVar initialLedStatus
  set button [ buttonLabel := "Turn On led" ]
  subject  <- return (Subject () ([]) )
  observer <- return (\_ -> do (label,l) <- ledMVarObserver led >>= (\x -> logBLS x "Led Observer executed!!")
                               labelSetText ledGUI label
                               putStrLn l)

  subject <- addObserver subject observer
  onClicked button (do notify subject)
  boxPackStart hbox button PackGrow 0
  boxPackStart hbox ledGUI PackGrow 0
  set window [ containerBorderWidth := 10, windowTitle := "ButtonLed subSystem", containerChild := hbox ]
  widgetShowAll window
  mainGUI

mainConsole :: IO ()
mainConsole = runStateT mainConsole' initialLedStatus >> return ()

mainConsole' :: StateT Led IO Led
mainConsole' = do
  l <- S.get
  liftIO $ putStrLn "press enter to switch the led(ditig x + enter to exit)"
  x <- liftIO $ getChar
  if (x == 'x')
    then return l
    else do
      modify switch
      l' <- S.get
      liftIO $ putStrLn $ "current led State: " ++ show l'
      mainConsole'

