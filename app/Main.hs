module Main where


import DomainModel.Core
import Application.Local
import Application.Distributed

-- mainConsole
-- mainGraphic
main :: IO ()
main = mainDistributed
