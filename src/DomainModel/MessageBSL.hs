{-# LANGUAGE DeriveDataTypeable #-}
module DomainModel.MessageBSL where

import Data.Binary
import Data.Typeable
import Control.Distributed.Process

data MessageBSL = NotifyPush       (SendPort MessageBSL)
                | ButtonPressed    (SendPort MessageBSL)
                | Switch           (SendPort MessageBSL)
                | LedStatus        (SendPort MessageBSL)
                | LedStatusChanged (SendPort MessageBSL)  Bool
                | RemoveObserver   (SendPort MessageBSL)  ProcessId
                | RegisterObserver (SendPort MessageBSL)  ProcessId
                | Log              (SendPort MessageBSL)  String
                deriving Typeable

instance Binary (MessageBSL) where
  put (NotifyPush         p)       = putWord8 1 >> put p
  put (ButtonPressed      p)       = putWord8 2 >> put p
  put (Switch             p)       = putWord8 3 >> put p
  put (LedStatus          p)       = putWord8 4 >> put p
  put (LedStatusChanged  p l)      = put (5 :: Word8) >> put p >> put l
  put (RemoveObserver    p o)      = put (6 :: Word8) >> put p >> put o
  put (RegisterObserver  p o)      = put (7 :: Word8) >> put p >> put o
  put (Log               p s)      = put (8 :: Word8) >> put p >> put s
  get                            = do t <- get :: Get Word8
                                      p <- get :: Get (SendPort MessageBSL)
                                      case t of
                                           1 -> return (NotifyPush p)
                                           2 -> return (ButtonPressed p)
                                           3 -> return (Switch p)
                                           4 -> return (LedStatus p)
                                           5 -> get >>= (\l -> return (LedStatusChanged p l))
                                           6 -> get >>= (\o -> return (RemoveObserver   p o))
                                           7 -> get >>= (\o -> return (RegisterObserver p o))
                                           8 -> get >>= (\s -> return (Log p s))

getSendPort :: MessageBSL -> SendPort MessageBSL
getSendPort (NotifyPush       p)   = p
getSendPort (ButtonPressed    p)   = p
getSendPort (Switch           p)   = p
getSendPort (LedStatus        p)   = p
getSendPort (LedStatusChanged p _) = p
getSendPort (RemoveObserver   p _) = p
getSendPort (RegisterObserver p _) = p
getSendPort (Log              p _) = p
