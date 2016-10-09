module Application.Distributed.Process.Specific where

import Pure.Data
import Control.Distributed.Process
import Application.Distributed.Process.Infrastructure
import Control.Concurrent (threadDelay)

spawnControl :: [(String, NodeType)] -> Process ()
spawnControl addr = do
  spawnReceiveSendingProcess addr ControlNT (\pids pid-> send (last pids) (Envelop pid pid RegisterObserver)) (\_ -> return ())

spawnSender :: [(String, NodeType)] -> Process ()
spawnSender addr = do
  spawnExternalProcess addr PressButtonNT (\pids pid -> do
                                            liftIO $ threadDelay (10000000)
                                            liftIO $ putStrLn "button Pressed"
                                            send (head pids) (Envelop pid pid ButtonPressed))

spawnLogger :: [(String, NodeType)] -> Process ()
spawnLogger addr = do
  spawnReceiveSendingProcess addr (NT LogNT) (\_ _ -> return ()) (\s -> do
                                                               case s of
                                                                 LogServerState{_logMsg=l} -> liftIO (putStrLn l)
                                                                 _ -> return()
                                                            )

-- Led and Button
spawnBasic :: [(String, NodeType)] -> NodeType -> Process ()
spawnBasic addr nodeType = do
  spawnReceiveSendingProcess addr nodeType (\_ _ -> return ()) (\_ -> return ())

