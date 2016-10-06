{-# LANGUAGE DeriveDataTypeable #-}
module Application.Distributed where

import DomainModel.MessageBSL
import Data.Binary
import Data.Typeable
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import DomainModel.Core

button  :: SendPort MessageBSL -> Process ()
button sMsg  = do  (sPong, rPong) <- newChan
                   sendChan sMsg (Ping sPong)
                   liftIO $ putStrLn "Sent a ping!"
                   Pong <- receiveChan rPong
                   liftIO $ putStrLn "Got a pong!"
                   client sMsg

led     :: ReceivePort MessageBSL -> SendPort MessageBSL -> Process ()
led sMsg     = do  (sPong, rPong) <- newChan
                   sendChan sMsg (Ping sPong)
                   liftIO $ putStrLn "Sent a ping!"
                   Pong <- receiveChan rPong
                   liftIO $ putStrLn "Got a pong!"
                   client sMsg

control :: ReceivePort MessageBSL -> Process ()
control rMsg = do Ping sPong <- receiveChan rPing
                  liftIO $ putStrLn "Got a ping!"
                  sendChan sPong Pong
                  liftIO $ putStrLn "Sent a pong!"
                  control rMsg

ignition :: Process ()
ignition = do
    -- start the server
    sMsg <- spawnChannelLocal server
    -- start the button
    spawnLocal $ button sMsg
    spawnLocal $ led sMsg
    liftIO $ threadDelay 100000 -- wait a while

main :: IO ()
main = do
    Right transport <- createTransport "127.0.0.1" "8080"
			    defaultTCPParameters
    node <- newLocalNode transport initRemoteTable
    runProcess node ignition
