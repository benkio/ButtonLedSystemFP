{-# LANGUAGE DeriveDataTypeable #-}
module DomainModel.MessageBSL where

import Data.Binary
import Data.Typeable
import Control.Distributed.Process

data MessageBSL = NotifyPush
                    | ButtonPressed
                    | Switch
                    | LedStatus
                    | LedStatusChanged  Bool
                    | RemoveObserver    ProcessId
                    | RegisterObserver  ProcessId
                    | Log               String
                    deriving Typeable

instance Binary (MessageBSL) where
  put NotifyPush                 = putWord8 1
  put ButtonPressed              = putWord8 2
  put Switch                     = putWord8 3
  put LedStatus                  = putWord8 4
  put (LedStatusChanged  l)      = put (5 :: Word8) >> put l
  put (RemoveObserver    o)      = put (6 :: Word8) >> put o
  put (RegisterObserver  o)      = put (7 :: Word8) >> put o
  put (Log               s)      = put (8 :: Word8) >> put s
  get                            = do t <- get :: Get Word8
                                      case t of
                                           1 -> return (NotifyPush)
                                           2 -> return (ButtonPressed)
                                           3 -> return (Switch)
                                           4 -> return (LedStatus)
                                           5 -> get >>= (\l -> return (LedStatusChanged l))
                                           6 -> get >>= (\o -> return (RemoveObserver   o))
                                           7 -> get >>= (\o -> return (RegisterObserver o))
                                           8 -> get >>= (\s -> return (Log s))
