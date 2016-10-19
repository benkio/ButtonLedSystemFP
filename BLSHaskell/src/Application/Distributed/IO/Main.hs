{-# LANGUAGE DeriveDataTypeable #-}
module Application.Distributed.IO.Main where

import Pure.Data
import Application.Distributed.IO.Infrastructure
import Application.Distributed.Process.Specific
import System.Environment(getArgs)

-- based on this: http://stackoverflow.com/questions/28366736/cloud-haskell-hanging-forever-when-sending-messages-to-managedprocess
-- and this: https://github.com/wyager/Example-Distributed-App/blob/master/Distributed.hs

mainDistributed :: IO ()
mainDistributed = do
    args <- getArgs

    case args of
      ["control", host, port, ledAddr, loggerAddr, buttonAddr]                ->
        runNode host port (spawnControl [(ledAddr,LedNT), (loggerAddr, (NT LogNT)), (buttonAddr, ButtonNT)])
      ["button", host, port]                                      ->
        runNode host port (spawnBasic [] ButtonNT)
      ["led", host, port]                                         -> do
        runNode host port (spawnBasic [] LedNT)
      ["logger", host, port]                                      -> do
        runNode host port (spawnLogger [])
      ["sender", host, port, buttonAddr] -> do
        runNode host port (spawnSender [(buttonAddr,ButtonNT)])
      x -> putStrLn ("usupported distributed part: " ++ (foldr (++) "" x))

    putStrLn "Push enter to exit"
    _ <- getLine
    return ()
