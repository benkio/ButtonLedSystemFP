{-# LANGUAGE DeriveDataTypeable #-}
module Application.Distributed where

import Control.Concurrent ( threadDelay )
import Data.Binary
import Data.Typeable
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import DomainModel.Core
import DomainModel.MessageBSL
import System.Environment (getArgs)
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Monad (forever, forM_)
import Control.Lens
import System.Environment
import Data.ByteString.Char8 (pack)
import Control.Monad.RWS.Strict
import Network.Transport     (EndPointAddress(EndPointAddress))

-- based on this: http://stackoverflow.com/questions/28366736/cloud-haskell-hanging-forever-when-sending-messages-to-managedprocess
-- and this: https://github.com/wyager/Example-Distributed-App/blob/master/Distributed.hs

mainDistributed :: IO ()
mainDistributed = do
    prog <- getProgName
    args <- getArgs

    case args of
      ["control", host, port, ledAddr, loggerAddr]                -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode $ ((spawnControl ledAddr loggerAddr))
      ["button", host, port, controlAddress]                      -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode (spawnButton controlAddress)
      ["led", host, port]                                         -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode spawnLed
      ["logger", host, port]                                      -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode spawnLogger

    putStrLn "Push enter to exit"
    getLine
    return ()

spawnControl :: String -> String -> Process ()
spawnControl ledAddr loggerAddr = (spawnLocal (do
  pid <- getSelfPid
  ledId <- addressToProcessId ledAddr
  loggerId <- addressToProcessId loggerAddr
  runClient  (NodeConfig{myId=pid}) (ControlServerState{_led=ledId, _logger=loggerId})))
  >> return ()

spawnButton :: String -> Process ()
spawnButton controlAddress = (spawnLocal (do
  pid <- getSelfPid
  addr <- addressToProcessId controlAddress
  runClient (NodeConfig{myId=pid}) ButtonServerState{_observers=[addr]}))
  >> return ()

spawnLed :: Process ()
spawnLed = (spawnLocal ( do
  pid <- getSelfPid
  runClient (NodeConfig{myId=pid}) LedServerState{_ledStatus=Led{status=False}}))
  >> return ()

spawnLogger :: Process()
spawnLogger = (spawnLocal ( do
  pid <- getSelfPid
  runClient (NodeConfig{myId=pid}) LogServerState{_logMsg=""}))
  >> return ()

runClient ::  NodeConfig -> NodeState -> Process ()
runClient config state = do
    let run handler msg = return $ execRWS (runAction $ handler msg) config state
    let msgHandler = getNodeHandler state
    (state', outputMessages) <- receiveWait [
            match $ run msgHandler]
    case state' of
      (LogServerState{_logMsg=l}) -> liftIO $ putStrLn $ "/n --------------------START LOGGER------------- /n " ++ l ++ "/n --------------------END LOGGER------------- /n "
      _                            -> say $ "Current state: " ++ show state'
    mapM (\msg -> send (recipientOf msg) msg) outputMessages
    runClient config state'

addressToProcessId :: String -> Process ProcessId
addressToProcessId inputAddr = do
  let endpoint = EndPointAddress (pack inputAddr)
  let node = NodeId endpoint
  discoverServer node

discoverServer :: NodeId -> Process ProcessId
discoverServer srvID = do
  whereisRemoteAsync srvID "serverPID"
  reply <- expectTimeout 100 :: Process (Maybe WhereIsReply)
  case reply of
    Just (WhereIsReply _ msid) -> case msid of
                                    Just sid -> return sid
                                    Nothing  -> discoverServer srvID
    Nothing                    -> discoverServer srvID

getNodeHandler :: NodeState -> (Envelop -> ServerAction())
getNodeHandler (ButtonServerState _)    = buttonMsgHandler
getNodeHandler (LedServerState _)       = ledMsgHandler
getNodeHandler (LogServerState _)       = logMsgHandler
getNodeHandler (ControlServerState _ _) = controlMsgHandler

logMsgHandler :: Envelop -> ServerAction()
logMsgHandler (Envelop sender recipient ButtonPressed)            = do
  l  <- use logMsg
  l' <- logBLS () "ButtonPressed"
  logMsg .= l ++ (snd l')
logMsgHandler (Envelop sender recipient (LedStatusChanged b))     = do
  l  <- use logMsg
  l' <- logBLS () ("Led Status changed to " ++ (show b))
  logMsg .= l ++ (snd l')

ledMsgHandler :: Envelop -> ServerAction()
ledMsgHandler (Envelop sender recipient LedSwitch)                = do 
  prevLedStatus <- _1  %~ switch $ ledStatus
  ledStatus .= prevLedStatus
ledMsgHandler (Envelop sender recipient LedStatus)                = do
  status <- _1  %~  id $ ledStatus
  sendTo sender (LedStatusChanged status)

controlMsgHandler :: Envelop -> ServerAction()
controlMsgHandler (Envelop sender recipient NotifyPush)           = do
  log <- use logger
  l <- use led
  sendTo log (ButtonPressed)
  sendTo l (LedSwitch)
controlMsgHandler (Envelop sender recipient (LedStatusChanged b)) = do
  log <- use logger
  sendTo log (LedStatusChanged b)

buttonMsgHandler :: Envelop -> ServerAction()
buttonMsgHandler (Envelop sender recipient RemoveObserver)        = do
  obs <- use observers
  observers .= (filter (\x -> x /= sender) obs)
buttonMsgHandler (Envelop sender recipient RegisterObserver)      = do
  obs <- use observers
  if (sender `elem` obs)
    then observers .= (sender : obs)
    else return ()

sendTo :: ProcessId -> MessageContent -> ServerAction ()
sendTo recipient content = do
    NodeConfig myId <- ask
    tell [Envelop myId recipient content]
