{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE OverloadedStrings #-}

module Language.PlutusCore.Lexer.Type ( BuiltinName (..)
                                      , Version (..)
                                      , Keyword (..)
                                      , Special (..)
                                      , Token (..)
                                      , TypeBuiltin (..)
                                      , prettyBytes
                                      ) where

import qualified Data.ByteString.Lazy               as BSL
import qualified Data.Text                          as T
import           Data.Text.Encoding                 (decodeUtf8)
import           Data.Text.Prettyprint.Doc.Internal (Doc (Text))
import           Language.Haskell.TH.Syntax         (Lift)
import           Language.PlutusCore.Name
import           Language.PlutusCore.PrettyCfg
import           Numeric                            (showHex)
import           PlutusPrelude

-- | A builtin type
data TypeBuiltin = TyByteString -- FIXME these should take integer/naturals
                 | TyInteger
                 | TySize
                 deriving (Show, Eq, Ord, Generic, NFData, Lift)

-- | Builtin functions
data BuiltinName = AddInteger
                 | SubtractInteger
                 | MultiplyInteger
                 | DivideInteger
                 | RemainderInteger
                 | LessThanInteger
                 | LessThanEqInteger
                 | GreaterThanInteger
                 | GreaterThanEqInteger
                 | EqInteger
                 | ResizeInteger
                 | IntToByteString
                 | Concatenate
                 | TakeByteString
                 | DropByteString
                 | ResizeByteString
                 | SHA2
                 | SHA3
                 | VerifySignature
                 | EqByteString
                 | TxHash
                 | BlockNum
                 | BlockTime
                 deriving (Show, Eq, Ord, Generic, NFData, Lift)

-- | Version of Plutus Core to be used for the program.
data Version a = Version a Natural Natural Natural
               deriving (Show, Eq, Functor, Generic, NFData, Lift)

-- | A keyword in Plutus Core.
data Keyword = KwAbs
             | KwLam
             | KwFix
             | KwFun
             | KwAll
             | KwByteString
             | KwInteger
             | KwSize
             | KwType
             | KwProgram
             | KwCon
             | KwWrap
             | KwUnwrap
             | KwError
             deriving (Show, Eq, Generic, NFData)

-- | A special character. This type is only used internally between the lexer
-- and the parser.
data Special = OpenParen
             | CloseParen
             | OpenBracket
             | CloseBracket
             | Dot
             | Exclamation
             | OpenBrace
             | CloseBrace
             deriving (Show, Eq, Generic, NFData)

-- | A token generated by the lexer.
data Token a = LexName { loc        :: a
                       , name       :: BSL.ByteString
                       , identifier :: Unique -- ^ A 'Unique' assigned to the identifier during lexing.
                       }
             | LexInt { loc :: a, tkInt :: Integer }
             | LexBS { loc :: a, tkBytestring :: BSL.ByteString }
             | LexBuiltin { loc :: a, tkBuiltin :: BuiltinName }
             | LexNat { loc :: a, tkNat :: Natural }
             | LexKeyword { loc :: a, tkKeyword :: Keyword }
             | LexSpecial { loc :: a, tkSpecial :: Special }
             | EOF { loc :: a }
             deriving (Show, Eq, Generic, NFData)

asBytes :: Word8 -> Doc a
asBytes = Text 2 . T.pack . ($ mempty) . showHex

prettyBytes :: BSL.ByteString -> Doc a
prettyBytes b = "#" <> fold (asBytes <$> BSL.unpack b)

instance Pretty Special where
    pretty OpenParen    = "("
    pretty CloseParen   = ")"
    pretty OpenBracket  = "["
    pretty CloseBracket = "]"
    pretty Dot          = "."
    pretty Exclamation  = "!"
    pretty OpenBrace    = "{"
    pretty CloseBrace   = "}"

instance Pretty Keyword where
    pretty KwAbs        = "abs"
    pretty KwLam        = "lam"
    pretty KwFix        = "fix"
    pretty KwFun        = "fun"
    pretty KwAll        = "forall"
    pretty KwByteString = "bytestring"
    pretty KwInteger    = "integer"
    pretty KwSize       = "size"
    pretty KwType       = "type"
    pretty KwProgram    = "program"
    pretty KwCon        = "con"
    pretty KwWrap       = "wrap"
    pretty KwUnwrap     = "unwrap"
    pretty KwError      = "error"

instance PrettyCfg (Token a) where
    prettyCfg _  (LexName _ n _)    = pretty (decodeUtf8 (BSL.toStrict n))
    prettyCfg _  (LexInt _ i)       = pretty i
    prettyCfg _  (LexNat _ n)       = pretty n
    prettyCfg _  (LexBS _ bs)       = prettyBytes bs
    prettyCfg cfg (LexBuiltin _ bn) = prettyCfg cfg bn
    prettyCfg _  (LexKeyword _ kw)  = pretty kw
    prettyCfg _  (LexSpecial _ s)   = pretty s
    prettyCfg _  EOF{}              = mempty

instance PrettyCfg BuiltinName where
    prettyCfg _ AddInteger           = "addInteger"
    prettyCfg _ SubtractInteger      = "subtractInteger"
    prettyCfg _ MultiplyInteger      = "multiplyInteger"
    prettyCfg _ DivideInteger        = "divideInteger"
    prettyCfg _ RemainderInteger     = "remainderInteger"
    prettyCfg _ LessThanInteger      = "lessThanInteger"
    prettyCfg _ LessThanEqInteger    = "lessThanEqualsInteger"
    prettyCfg _ GreaterThanInteger   = "greaterThanInteger"
    prettyCfg _ GreaterThanEqInteger = "greaterThanEqualsInteger"
    prettyCfg _ EqInteger            = "equalsInteger"
    prettyCfg _ ResizeInteger        = "resizeInteger"
    prettyCfg _ IntToByteString      = "intToByteString"
    prettyCfg _ Concatenate          = "concatenate"
    prettyCfg _ TakeByteString       = "takeByteString"
    prettyCfg _ DropByteString       = "dropByteString"
    prettyCfg _ ResizeByteString     = "resizeByteString"
    prettyCfg _ EqByteString         = "equalsByteString"
    prettyCfg _ SHA2                 = "sha2_256"
    prettyCfg _ SHA3                 = "sha3_256"
    prettyCfg _ VerifySignature      = "verifySignature"
    prettyCfg _ TxHash               = "txhash"
    prettyCfg _ BlockNum             = "blocknum"
    prettyCfg _ BlockTime            = "blocktime"

instance Pretty TypeBuiltin where
    pretty TyInteger    = "integer"
    pretty TyByteString = "bytestring"
    pretty TySize       = "size"

instance Pretty (Version a) where
    pretty (Version _ i j k) = pretty i <> "." <> pretty j <> "." <> pretty k
