module Application.Distributed.ServerAction.MessageHandlers(getNodeHandler) where

import Pure.Data
import Pure.Behaviours
import Control.Lens
import Application.Distributed.ServerAction.Infrastructure
import Data.Foldable

getNodeHandler :: NodeState -> (Envelop -> ServerAction())
getNodeHandler (ButtonServerState _)    = buttonMsgHandler
getNodeHandler (LedServerState _)       = ledMsgHandler
getNodeHandler (LogServerState _)       = logMsgHandler
getNodeHandler (ControlServerState _ _ _) = controlMsgHandler

buttonMsgHandler :: Envelop -> ServerAction()
buttonMsgHandler (Envelop sender _ RemoveObserver)        = do
  obs <- use observers
  observers .= (filter (\x -> x /= sender) obs)
buttonMsgHandler (Envelop sender _ RegisterObserver)      = do
  obs <- use observers
  if (sender `elem` obs)
    then return ()
    else observers .= obs ++ [sender]
buttonMsgHandler (Envelop _ _ ButtonPressed)         = do
  obs <- use observers
  forM_ obs (\o -> sendTo o NotifyPush)
  return ()
buttonMsgHandler _ = error "Unhandled Message"

controlMsgHandler :: Envelop -> ServerAction()
controlMsgHandler (Envelop _ _ NotifyPush)           = do
  lg <- preuse logger
  ld <- preuse led
  case lg of
       Just x  -> sendTo x (ButtonPressed)
       Nothing -> error "Internal Server Error: get log node reference"
  case ld of
       Just x  -> sendTo x (LedSwitch) >> sendTo x (LedStatus)
       Nothing -> error "Internal Server Error: get led node reference"
controlMsgHandler (Envelop _ _ (LedStatusChanged b)) = do
  lg <- preuse logger
  case lg of
       Just x  -> sendTo x (LedStatusChanged b)
       Nothing -> error "Internal Server Error: get log node reference"
controlMsgHandler _                                  = error "Unhandled Message"


ledMsgHandler :: Envelop -> ServerAction()
ledMsgHandler (Envelop _ _ LedSwitch)                     = do
  prevLedStatus <- preuse ledStatus
  case prevLedStatus of
    Just x  -> ledStatus .= switch x
    Nothing -> error "Internal Server Error: get led node reference"
ledMsgHandler (Envelop sender _ LedStatus)                = do
  s <- preuse ledStatus
  case s of
    Just x -> sendTo sender (LedStatusChanged x)
    Nothing -> error "Internal Server Error: get led node reference"
ledMsgHandler _ = error "Unhandled Message"

logMsgHandler :: Envelop -> ServerAction()
logMsgHandler (Envelop _ _ ButtonPressed)            = do
  l' <- logBLS () "ButtonPressed"
  logMsg .= snd l'
logMsgHandler (Envelop _ _ (LedStatusChanged b))     = do
  l' <- logBLS () ("Led Status changed to " ++ (show b))
  logMsg .= snd l'
logMsgHandler _ = error "Unhandled Message"
