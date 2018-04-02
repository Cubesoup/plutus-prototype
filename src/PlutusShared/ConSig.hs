{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS -Wall #-}







-- | This module implements constructor signatures, for data declarations.

module PlutusShared.ConSig where

import Utils.ABTs.ABT
import Utils.ABTs.Pretty (pretty)
import Utils.ABTs.Vars
import PlutusShared.Type

import Data.List (intercalate)
import GHC.Generics







-- | A constructor signature in this variant is simply a list of argument
-- types and a return type.

data ConSig = ConSig [Scope TypeF] (Scope TypeF)
  deriving (Generic)


instance Show ConSig where
  show (ConSig as r) =
    "["
    ++ intercalate "," (names r)
    ++ "]("
    ++ intercalate "," (map (pretty.body) as)
    ++ ")"
    ++ pretty (body r)


conSigH :: [String] -> [Type] -> Type -> ConSig
conSigH ns as r = ConSig (map (scope ns) as) (scope ns r)

substMetasConSig :: [(MetaVar,Type)] -> ConSig -> ConSig
substMetasConSig subs (ConSig ascs bsc) =
  ConSig (map (under (substMetas subs)) ascs)
         (under (substMetas subs) bsc)