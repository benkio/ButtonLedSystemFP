{-# LANGUAGE DeriveDataTypeable #-}
module Application.Distributed where

import Control.Concurrent ( threadDelay )
import DomainModel.MessageBSL
import Data.Binary
import Data.Typeable
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import DomainModel.Core

button  :: SendPort MessageBSL -> Process ()
button sendServerMsg  = do  (sButton, rButton) <- newChan
                            sendChan sendServerMsg (NotifyPush sButton)
                            liftIO $ putStrLn "Sent a Notify! Button"
                            NotifyPush sendServerMsg' <- receiveChan rButton
                            liftIO $ putStrLn "Got a Notify! Button"
                            button sendServerMsg

led     :: SendPort MessageBSL -> Process ()
led sendServerMsg  = do  (sLed, rLed) <- newChan
                         sendChan sendServerMsg (NotifyPush sLed)
                         liftIO $ putStrLn "Sent a Notify! Led"
                         NotifyPush sendServerMsg' <- receiveChan rLed
                         liftIO $ putStrLn "Got a Notify! Led"
                         led sendServerMsg

control :: ReceivePort MessageBSL -> Process ()
control receiveBSLMsg = do receivedMsg <- receiveChan receiveBSLMsg
                           let sendControlPort = getSendPort receivedMsg
                           liftIO $ putStrLn "Got a Notify! Control"
                           sendChan sendControlPort (NotifyPush sendControlPort)
                           liftIO $ putStrLn "Sent a Notify! Control"
                           control receiveBSLMsg

ignition :: Process ()
ignition = do
    -- start the server
    sendServerMsg <- spawnChannelLocal control
    -- start the button
    spawnLocal $ button sendServerMsg
    spawnLocal $ led sendServerMsg
    liftIO $ threadDelay 100000 -- wait a while

mainDistributed :: IO ()
mainDistributed = do
    Right transport <- createTransport "127.0.0.1" "8080" defaultTCPParameters
    node <- newLocalNode transport initRemoteTable
    runProcess node ignition
