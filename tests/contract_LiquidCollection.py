#!/usr/bin/env python3

# ==============================================================================
#
import freeton_utils
from   freeton_utils import *

class LiquidCollection(BaseContract):
    
    def __init__(
            self, 
            everClient: TonClient, nonce: str,
            ownerAddress: str,
            creatorAddress: str,
            collectionMetadata: str,
            tokenPrimarySaleHappened: bool,
            tokenMetadataIsMutable: bool,
            tokenMasterEditionMaxSupply: int,
            tokenMasterEditionPrintLocked: bool,
            tokenCreatorsPercent: int,
            tokenCreatorsShares,
            signer: Signer = None):

        genSigner = generateSigner() if signer is None else signer
        self.CONSTRUCTOR = {"ownerAddress":                  ownerAddress, 
                            "creatorAddress":                creatorAddress,
                            "metadata":                      collectionMetadata,
                            "tokenPrimarySaleHappened":      tokenPrimarySaleHappened,
                            "tokenMetadataIsMutable":        tokenMetadataIsMutable,
                            "tokenMasterEditionMaxSupply":   tokenMasterEditionMaxSupply,
                            "tokenMasterEditionPrintLocked": tokenMasterEditionPrintLocked,
                            "tokenCreatorsPercent":          tokenCreatorsPercent,
                            "tokenCreatorsShares":           tokenCreatorsShares}
        self.INITDATA    = {"_nonce":nonce, "_tokenCode":getCodeFromTvc("../bin/LiquidToken.tvc")}
        BaseContract.__init__(self, everClient=everClient, contractName="LiquidCollection", pubkey=ZERO_PUBKEY, signer=genSigner)

    #========================================
    #
    def setOwner(self, msig: SetcodeMultisig, ownerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setOwner", functionParams={"ownerAddress":ownerAddress}, value=DIME, flags=1)
        return result

    def createToken(self, msig: SetcodeMultisig, ownerAddress: str, creatorAddress: str, metadata: str, metadataAuthorityAddress: str):
        params = {
            "ownerAddress":             ownerAddress, 
            "creatorAddress":           creatorAddress, 
            "metadata":                 metadata, 
            "metadataAuthorityAddress": metadataAuthorityAddress
        }
        result = self._callFromMultisig(msig=msig, functionName="createToken", functionParams=params, value=EVER, flags=1)
        return result

    def createTokenExtended(
            self, msig: SetcodeMultisig, 
            ownerAddress: str, 
            creatorAddress: str, 
            primarySaleHappened: bool,
            metadata: str, 
            metadataIsMutable: bool,
            metadataAuthorityAddress: str,
            masterEditionMaxSupply: str,
            masterEditionPrintLocked: bool,
            creatorsPercent: int,
            creatorsShares):

        params = {
            "ownerAddress":             ownerAddress, 
            "creatorAddress":           creatorAddress, 
            "primarySaleHappened":      primarySaleHappened,
            "metadata":                 metadata, 
            "metadataIsMutable":        metadataIsMutable,
            "metadataAuthorityAddress": metadataAuthorityAddress,
            "masterEditionMaxSupply":   masterEditionMaxSupply,
            "masterEditionPrintLocked": masterEditionPrintLocked,
            "creatorsPercent":          creatorsPercent,
            "creatorsShares":           creatorsShares
        }

        result = self._callFromMultisig(msig=msig, functionName="createTokenExtended", functionParams=params, value=EVER, flags=1)
        return result

    #========================================
    #
    def getBasicInfo(self, includeMetadata: bool = True, includeTokenCode: bool = False):
        result = self._run(functionName="getBasicInfo", functionParams={"includeMetadata":includeMetadata, "includeTokenCode":includeTokenCode})
        return result

    def getInfo(self, includeMetadata: bool = True, includeTokenCode: bool = False):
        result = self._run(functionName="getInfo", functionParams={"includeMetadata":includeMetadata, "includeTokenCode":includeTokenCode})
        return result

# ==============================================================================
# 
