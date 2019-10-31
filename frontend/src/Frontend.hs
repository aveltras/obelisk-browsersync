{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
module Frontend where

import Data.Functor (void)
import qualified Data.Text as T
import qualified Data.Text.Encoding as T
import Obelisk.Frontend
import Obelisk.Configs
import Obelisk.Route
import Reflex.Dom.Core

import Common.Api
import Common.Route
import Obelisk.Generated.Static

import Data.Text (pack)
import Data.Proxy (Proxy(..))
import Servant.Reflex

frontend :: Frontend (R FrontendRoute)
frontend = Frontend
  { _frontend_head = do
      el "title" $ text "Obelisk Minimal Example2"
      elAttr "link" (("rel" =: "stylesheet") <> ("href" =: static @"all.css")) $ text ""
  , _frontend_body = do

      
      text "Welcome to Obelisk!"
      void $ prerender (text "loading..") subWidget
      el "p" $ text $ T.pack commonStuff
      elAttr "img" ("src" =: static @"obelisk.jpg") blank
      el "div" $ do
        exampleConfig <- getConfig "common/example"        
        case exampleConfig of
          Nothing -> text "No config file found in config/common/example"
          Just s -> text (T.decodeUtf8 s)
      return ()
  }

subWidget :: forall t m. (PostBuild t m, MonadHold t m, DomBuilder t m, SupportsServantReflex t m) => m ()
subWidget = do
  text "sub"
  let (getusers) = client (Proxy :: Proxy UserAPI)
                              (Proxy :: Proxy m)
                              (Proxy :: Proxy ())
                              (constDyn (BasePath "http://localhost:8081/"))
  intBtn <- button "Get Users"
  res :: Event t (ReqResult () User) <- getusers intBtn
  let ys   = fmapMaybe reqSuccess res
      errs = fmapMaybe reqFailure res

  -- Green <p> tag showing the last good result 
  elAttr "p" ("style" =: "color:green") $ do
    text "Last good result: "
    dynText =<< holdDyn "" (fmap (pack . show) ys)
    
  -- Red <p> tag showing the last error, cleared by a new good value
  elAttr "p" ("style" =: "color:red") $
    dynText =<< holdDyn "" (leftmost [errs, const "" <$> ys])
      
  blank
