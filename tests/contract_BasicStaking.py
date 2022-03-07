#!/usr/bin/env python3

# ==============================================================================
#
import freeton_utils
from   freeton_utils import *

class BasicStaking(BaseContract):
    
    def __init__(self, everClient: TonClient, nonce: str, ownerAddress: str, initiatorAddress: str, collectionAddress: str, signer: Signer = None):
        genSigner = generateSigner() if signer is None else signer
        self.CONSTRUCTOR = {"ownerAddress":ownerAddress, "initiatorAddress":initiatorAddress}
        self.INITDATA    = {"_nonce":nonce, "_collectionAddress":collectionAddress}
        BaseContract.__init__(self, everClient=everClient, contractName="BasicStaking", pubkey=ZERO_PUBKEY, signer=genSigner)

    #========================================
    #
    def setOwner(self, msig: SetcodeMultisig, ownerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setOwner", functionParams={"ownerAddress":ownerAddress}, value=DIME, flags=1)
        return result

    def unstake(self, msig: SetcodeMultisig, tokenAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="unstake", functionParams={"tokenAddress":tokenAddress}, value=DIME, flags=1)
        return result

    #========================================
    #
    def getInfo(self, includeMetadata: bool = True):
        result = self._run(functionName="getInfo", functionParams={})
        return result

# ==============================================================================
# 
