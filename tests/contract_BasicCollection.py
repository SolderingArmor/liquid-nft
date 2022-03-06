#!/usr/bin/env python3

# ==============================================================================
#
import freeton_utils
from   freeton_utils import *

class BasicCollection(BaseContract):
    
    def __init__(self, everClient: TonClient, nonce: str, ownerAddress: str, initiatorAddress: str, metadata: str, signer: Signer = None):

        genSigner = generateSigner() if signer is None else signer

        self.CONSTRUCTOR = {"ownerAddress": ownerAddress, "initiatorAddress": initiatorAddress, "metadata": metadata}
        self.INITDATA    = {"_nonce":nonce, "_tokenCode":getCodeFromTvc("../bin/BasicToken.tvc")}
        BaseContract.__init__(self, everClient=everClient, contractName="BasicCollection", pubkey=ZERO_PUBKEY, signer=genSigner)

    #========================================
    #
    def setOwner(self, msig: SetcodeMultisig, ownerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setOwner", functionParams={"ownerAddress":ownerAddress}, value=DIME, flags=1)
        return result

    def createToken(self, msig: SetcodeMultisig, ownerAddress: str, authorityAddress: str, initiatorAddress: str, metadata: str):
        params = {
            "ownerAddress":     ownerAddress, 
            "authorityAddress": authorityAddress,
            "initiatorAddress": initiatorAddress,
            "metadata":         metadata
        }
        result = self._callFromMultisig(msig=msig, functionName="createToken", functionParams=params, value=DIME*5, flags=1)
        return result

    #========================================
    #
    def getBasicInfo(self, includeMetadata: bool = True, includeTokenCode: bool = False):
        result = self._run(functionName="getBasicInfo", functionParams={"includeMetadata":includeMetadata, "includeTokenCode":includeTokenCode, "answerId":0})
        return result

# ==============================================================================
# 
