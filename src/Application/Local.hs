module Application.Local where

import Graphics.UI.Gtk
import Control.Concurrent.MVar
import Pure.Data as D
import Pure.Behaviours
import Control.Concurrent.MVar
import Control.Monad.State.Lazy as S
import Control.Monad
import Control.Monad.Trans.Maybe


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
  observer <- return $ StatelessObs (\_ -> do (label,l) <- ledMVarObserver led >>= (\x -> logBLS x "Led Observer executed!!")
                                              labelSetText ledGUI label
                                              putStrLn l)

  subject <- addObserver subject observer
  onClicked button (do notify subject; return ())
  boxPackStart hbox button PackGrow 0
  boxPackStart hbox ledGUI PackGrow 0
  set window [ containerBorderWidth := 10, windowTitle := "ButtonLed subSystem", containerChild := hbox ]
  widgetShowAll window
  mainGUI

mainConsole :: IO()
mainConsole = runStateT ledStateMachine initialLedStatus >> return ()

ledStateMachine :: StateT Led IO Led
ledStateMachine = do
  l <- S.get
  liftIO $ putStrLn "press enter to switch the led(ditig x + enter to exit)"
  x <- liftIO $ getChar
  if (x == 'x')
    then return l
    else do
      let l' =  execState ledNextState l
      put $ l'
      (l'', log) <- logBLS l' $ "current led State: " ++ show l'
      liftIO $ putStrLn log
      ledStateMachine

mainConsole' = do
  subject <- return $ Subject (Led{D.on=False}) [StatefullObs (\l -> do
                                                                l' <- return $ execState ledNextState l
                                                                (l'', log) <- logBLS l' "Led Observer executed!!"
                                                                putStrLn (show log)
                                                                putStrLn (show l'')
                                                                return l')]
  ledStateMachine' subject

ledStateMachine' :: Subject IO a -> IO()
ledStateMachine' s = do
  putStrLn "press enter to switch the led(ditig x + enter to exit)"
  x <- getChar
  if (x == 'x')
    then return ()
    else do
      l' <- notify s
      s' <- setSubject s (head l')
      ledStateMachine' s'
