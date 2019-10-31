{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}
module Common.Api where

import Data.Aeson
import Data.Text
import GHC.Generics (Generic)
import Servant.API

commonStuff :: String
commonStuff = "Here is a string defined in Common.Api234"

data User = User Text deriving (Eq, Show, Generic)
instance ToJSON User
instance FromJSON User

type UserAPI = "users" :> Get '[JSON] User
