{-# LANGUAGE DeriveDataTypeable #-}
module Application.Distributed where

import Network.Transport.TCP (createTransport, defaultTCPParameters)
import DomainModel.Core
import DomainModel.MessageBSL
import System.Environment (getArgs)
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Lens
import Control.Concurrent (threadDelay)
import System.Environment
import Data.ByteString.Char8 (pack)
import Data.List
import Control.Monad.RWS.Strict
import Network.Transport     (EndPointAddress(EndPointAddress))

-- based on this: http://stackoverflow.com/questions/28366736/cloud-haskell-hanging-forever-when-sending-messages-to-managedprocess
-- and this: https://github.com/wyager/Example-Distributed-App/blob/master/Distributed.hs

mainDistributed :: IO ()
mainDistributed = do
    args <- getArgs

    case args of
      ["control", host, port, ledAddr, loggerAddr, buttonAddr]                -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode $ ((spawnControl ledAddr loggerAddr buttonAddr))
      ["button", host, port]                                      -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode (spawnButton)
      ["led", host, port]                                         -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode spawnLed
      ["logger", host, port]                                      -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        runProcess backendNode spawnLogger
      ["sender", host, port, buttonAddr] -> do
        Right transport <- createTransport host port defaultTCPParameters
        backendNode     <- newLocalNode transport initRemoteTable
        putStrLn "perche' non scrive questo?"
        runProcess backendNode (spawnSender buttonAddr)
      x -> putStrLn ("usupported distributed part: " ++ (foldr (++) "" x))

    putStrLn "Push enter to exit"
    _ <- getLine
    return ()

spawnSender :: String -> Process ()
spawnSender buttonAddr = (spawnLocal (do
    myPid <- getSelfPid
    addr <- addressToProcessId buttonAddr "buttonPID"
    liftIO (putStrLn ("buttonId: " ++ show addr))
    forever (do
           liftIO $ threadDelay (1000000)
           liftIO $ putStrLn "sendButtonPressed"
           send addr (Envelop myPid myPid ButtonPressed))))
    >> return ()

spawnControl :: String -> String -> String -> Process ()
spawnControl ledAddr loggerAddr buttonAddr = (spawnLocal (do
  pid <- getSelfPid
  register "controlPID" pid
  liftIO (putStrLn ("controlRegistered, input addr: " ++ ledAddr ++ " " ++ loggerAddr ++ " " ++ buttonAddr))
  ledId <- addressToProcessId ledAddr "ledPID"
  loggerId <- addressToProcessId loggerAddr "loggerPID"
  buttonId <- addressToProcessId buttonAddr "buttonPID"
  liftIO (putStrLn ( "ledId: " ++  show ledId ++ " loggerId: " ++ show loggerId ++ " buttonId: " ++ show buttonId))
  send buttonId (Envelop pid pid RegisterObserver)
  runClient  (NodeConfig{myId=pid}) (ControlServerState{_led=ledId, _logger=loggerId, _button=buttonId})))
  >> return ()

spawnButton :: Process ()
spawnButton = (spawnLocal (do
  pid <- getSelfPid
  register "buttonPID" pid
  liftIO (putStrLn ("buttonRegistered " ++ show pid))
  runClient (NodeConfig{myId=pid}) ButtonServerState{_observers=[]}))
  >> return ()

spawnLed :: Process ()
spawnLed = (spawnLocal ( do
  pid <- getSelfPid
  register "ledPID" pid
  liftIO (putStrLn ("ledRegistered " ++ show pid))
  runClient (NodeConfig{myId=pid}) LedServerState{_ledStatus=Led{status=False}}))
  >> return ()

spawnLogger :: Process()
spawnLogger = (spawnLocal ( do
  pid <- getSelfPid
  register "loggerPID" pid
  liftIO (putStrLn ("loggerRegistered " ++ show pid))
  runClient (NodeConfig{myId=pid}) LogServerState{_logMsg=""}))
  >> return ()

runClient ::  NodeConfig -> NodeState -> Process ()
runClient config s = do
    liftIO (putStrLn "runClient")
    let run handler msg = return $ execRWS (runAction $ handler msg) config s
    let msgHandler = getNodeHandler s
    liftIO (putStrLn "startListening")
    (state', outputMessages) <- receiveWait [
            match $ run msgHandler]
    liftIO (putStrLn "new message arrived")
    case state' of
      (LogServerState{_logMsg=l}) -> liftIO $ putStrLn l
      _                           -> say ("Current state: " ++ (show state'))
                                     >> liftIO ( putStrLn "cicle new messages")
    _ <-mapM (\x -> send (recipientOf x) x) outputMessages
    runClient config state'

addressToProcessId :: String -> String -> Process ProcessId
addressToProcessId inputAddr inputName = do
  let endpoint = EndPointAddress (pack inputAddr)
  let node = NodeId endpoint
  liftIO $ putStrLn $ show node ++ show inputName
  discoverServer node inputName inputAddr

discoverServer :: NodeId -> String -> String -> Process ProcessId
discoverServer srvID serverName inputAddr = do
  whereisRemoteAsync srvID serverName
  reply <- expectTimeout 100 :: Process (Maybe WhereIsReply)
  liftIO $ putStrLn $ show reply
  case reply of
    Just (WhereIsReply _ msid) -> case msid of
                                    Just sid -> if (isInfixOf (show inputAddr) (show sid)) then return sid else discoverServer srvID serverName inputAddr
                                    Nothing  -> discoverServer srvID serverName inputAddr
    Nothing                    -> discoverServer srvID serverName inputAddr

getNodeHandler :: NodeState -> (Envelop -> ServerAction())
getNodeHandler (ButtonServerState _)    = buttonMsgHandler
getNodeHandler (LedServerState _)       = ledMsgHandler
getNodeHandler (LogServerState _)       = logMsgHandler
getNodeHandler (ControlServerState _ _ _) = controlMsgHandler

logMsgHandler :: Envelop -> ServerAction()
logMsgHandler (Envelop _ _ ButtonPressed)            = do
  l  <- use logMsg
  l' <- logBLS () "ButtonPressed"
  logMsg .= l ++ (snd l')
logMsgHandler (Envelop _ _ (LedStatusChanged b))     = do
  l  <- use logMsg
  l' <- logBLS () ("Led Status changed to " ++ (show b))
  logMsg .= l ++ (snd l')
logMsgHandler _ = error "Unhandled Message"

ledMsgHandler :: Envelop -> ServerAction()
ledMsgHandler (Envelop _ _ LedSwitch)                = do 
  prevLedStatus <- preuse ledStatus
  case prevLedStatus of
    Just x  -> ledStatus .= x
    Nothing -> error "Internal Server Error: get led node reference"
ledMsgHandler (Envelop sender _ LedStatus)                = do
  s <- preuse ledStatus
  case s of
    Just x -> sendTo sender (LedStatusChanged x)
    Nothing -> error "Internal Server Error: get led node reference"
ledMsgHandler _ = error "Unhandled Message"

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
controlMsgHandler _ = error "Unhandled Message"

buttonMsgHandler :: Envelop -> ServerAction()
buttonMsgHandler (Envelop sender _ RemoveObserver)        = do
  obs <- use observers
  observers .= (filter (\x -> x /= sender) obs)
buttonMsgHandler (Envelop sender _ RegisterObserver)      = do
  obs <- use observers
  if (sender `elem` obs)
    then observers .= (sender : obs)
    else return ()
buttonMsgHandler (Envelop _ _ ButtonPressed)         = do
  obs <- use observers
  _ <- forM obs (\o -> sendTo o NotifyPush)
  return ()
buttonMsgHandler _ = error "Unhandled Message"

sendTo :: ProcessId -> MessageContent -> ServerAction ()
sendTo recipient content = do
    NodeConfig mId <- ask
    tell [Envelop mId recipient content]
