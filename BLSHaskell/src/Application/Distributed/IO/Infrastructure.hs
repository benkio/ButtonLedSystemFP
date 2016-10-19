module Application.Distributed.IO.Infrastructure(runNode) where

import Pure.Data
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Network.Transport.TCP

createLocalNode :: String -> String -> IO LocalNode
createLocalNode host port = do Right transport <- createTransport host port defaultTCPParameters
                               newLocalNode transport initRemoteTable

runNode :: String -> String -> Process() -> IO ()
runNode host port spawnFunc = createLocalNode host port >>= (\node -> runProcess node  (spawnFunc))
