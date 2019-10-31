{-# LANGUAGE EmptyCase #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeFamilies #-}
module Backend where

import Common.Api
import Common.Route
import Control.Concurrent.Async (concurrently_)
import Data.Proxy (Proxy(..))
import Network.Wai.Handler.Warp (run)
import Network.Wai.Middleware.Cors (simpleCors)
import Obelisk.Backend
import Servant.Server

backend :: Backend BackendRoute FrontendRoute
backend = Backend
  { _backend_run = \serve -> concurrently_      
      (serve $ const $ return ())
      (run 8081 $ simpleCors app1)
  , _backend_routeEncoder = backendRouteEncoder
  }

server1 :: Server UserAPI
server1 = return $ User "Isaac Newton23"

users1 :: [User]
users1 =
  [ User "Isaac Newton"
  , User "Albert Einstein"
  ]

userAPI :: Proxy UserAPI
userAPI = Proxy

app1 :: Application
app1 = serve userAPI server1
