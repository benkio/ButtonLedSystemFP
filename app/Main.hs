module Main where


import Application.Local
import Application.Distributed.IO.Main

-- mainConsole
-- mainGraphic
main :: IO ()
main = mainDistributed
