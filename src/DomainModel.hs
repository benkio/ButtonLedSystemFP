module DomainModel
    ( switch
    ) where

type Led = Bool

switch :: Led -> Led
switch l = not l
