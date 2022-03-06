#!/usr/bin/env python3

# ==============================================================================
#
import freeton_utils
from   freeton_utils import *

class BasicToken(BaseContract):
    
    def __init__(self, everClient: TonClient, collectionAddress: str, tokenID: int, signer: Signer = None):
        genSigner = generateSigner() if signer is None else signer
        self.CONSTRUCTOR = {}
        self.INITDATA    = {"_collectionAddress":collectionAddress, "_tokenID":tokenID}
        BaseContract.__init__(self, everClient=everClient, contractName="BasicToken", pubkey=ZERO_PUBKEY, signer=genSigner)

    #========================================
    #
    def setOwner(self, msig: SetcodeMultisig, ownerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setOwner", functionParams={"ownerAddress":ownerAddress}, value=DIME, flags=1)
        return result

    def setAuthority(self, msig: SetcodeMultisig, authorityAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setAuthority", functionParams={"authorityAddress":authorityAddress}, value=DIME, flags=1)
        return result

    #========================================
    #
    def getBasicInfo(self, includeMetadata: bool = True):
        result = self._run(functionName="getBasicInfo", functionParams={"includeMetadata":includeMetadata, "answerId":0})
        return result

# ==============================================================================
# 
