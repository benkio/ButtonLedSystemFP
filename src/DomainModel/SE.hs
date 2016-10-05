module DomainModel.SE where

import Control.Concurrent.MVar
import DomainModel.Core

ledMVarObserver :: MVar Led -> IO String
ledMVarObserver led = do  tryLedCurrentStatus <- tryTakeMVar led
                          case tryLedCurrentStatus of
                            Just l -> do putStrLn $ show l
                                         updateLed <- tryPutMVar led (switch l)
                                         if (updateLed)
                                           then if (getLedStatus (switch l)) then return "On" else return "Off"
                                           else error "error in led update"
                            Nothing -> error "error in led Read"
