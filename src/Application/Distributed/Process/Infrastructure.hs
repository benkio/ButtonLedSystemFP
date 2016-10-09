module Application.Distributed.Process.Infrastructure where

import Pure.Data
import Pure.Behaviours
import Application.Distributed.ServerAction.MessageHandlers
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Data.ByteString.Char8 (pack)
import Control.Monad.RWS.Strict
import Network.Transport     (EndPointAddress(EndPointAddress))


registerProcess :: NodeType -> Process()
registerProcess registeredName = do
  pid      <- getSelfPid
  node     <- getSelfNode
  let name = show registeredName
  registerRemoteAsync node name pid
  liftIO (putStrLn ("Registered: " ++ name ++ " in node: " ++ show node))

resolveAddressIds :: [(String, NodeType)] -> Process [ProcessId]
resolveAddressIds addrs = do
  addrsId <- sequence $ map (\(a,nt) -> addressToProcessId a (show nt)) addrs
  liftIO (putStrLn (  "referenceIds" ++ (foldr (\i idstring -> show i ++  " - " ++ idstring) "" addrsId) ))
  return addrsId

spawnReceiveSendingProcess :: [(String, NodeType)] -> NodeType -> ([ProcessId] -> ProcessId -> Process ()) -> (NodeState -> Process ())  -> Process ()
spawnReceiveSendingProcess addrs nodeType initialProcessWork postReceiveWork = (spawnLocal (do
  registerProcess nodeType
  addrsId <- resolveAddressIds addrs
  pid     <- getSelfPid
  initialProcessWork addrsId pid
  runClient (nodeConfigBuilder pid) (nodeStateBuilder addrsId nodeType) postReceiveWork))
  >> return ()

spawnExternalProcess :: [(String, NodeType)] -> SendOnlyNT -> ([ProcessId] -> ProcessId -> Process ()) -> Process ()
spawnExternalProcess  addrs sendNodeType senderWork = (spawnLocal (do
  registerProcess $ NT' sendNodeType
  addrsId <- resolveAddressIds addrs
  pid     <- getSelfPid
  forever (do senderWork addrsId pid)))
  >> return ()

runClient ::  NodeConfig -> NodeState -> (NodeState -> Process ()) -> Process ()
runClient config s postReceiveWork = do
    liftIO (putStrLn "runClient")
    let run handler msg = return $ execRWS (runAction $ handler msg) config s
    let msgHandler = getNodeHandler s
    liftIO (putStrLn "startListening")
    (state', outputMessages) <- receiveWait [
            match $ run msgHandler]
    liftIO (putStrLn "new message arrived")
    postReceiveWork state'
    _ <-mapM (\x -> send (recipientOf x) x) outputMessages
    runClient config state' postReceiveWork

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
    Just (WhereIsReply n msid) -> case msid of
                                    Just sid -> if (n == serverName) then return sid else discoverServer srvID serverName inputAddr
                                    Nothing  -> discoverServer srvID serverName inputAddr
    Nothing                    -> discoverServer srvID serverName inputAddr

sendTo :: ProcessId -> [(ProcessId, [MessageContent])] -> Process ()
sendTo sender receiverMsg = do
  mapM_ (\(receiver, msgs) -> do
    mapM_ (\m -> send receiver (Envelop sender sender m)) msgs
    return ()) receiverMsg
