#!/usr/bin/env python3

# ==============================================================================
#
import freeton_utils
from   freeton_utils import *

class LiquidToken(BaseContract):
    
    def __init__(self, tonClient: TonClient, collectionAddress: str, tokenID: int, editionNumber: int, signer: Signer = None):
        genSigner = generateSigner() if signer is None else signer
        self.CONSTRUCTOR = {}
        self.INITDATA    = {"_collectionAddress":collectionAddress, "_tokenID":tokenID, "_editionNumber":editionNumber}
        BaseContract.__init__(self, tonClient=tonClient, contractName="LiquidToken", pubkey=ZERO_PUBKEY, signer=genSigner)

    #========================================
    #
    def setOwner(self, msig: SetcodeMultisig, ownerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setOwner", functionParams={"ownerAddress":ownerAddress}, value=DIME, flags=1)
        return result

    def setOwnerWithPrimarySale(self, msig: SetcodeMultisig, ownerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="setOwnerWithPrimarySale", functionParams={"ownerAddress":ownerAddress}, value=DIME, flags=1)
        return result

    def setMetadata(self, msig: SetcodeMultisig, metadata: str):
        result = self._callFromMultisig(msig=msig, functionName="setMetadata", functionParams={"metadata":metadata}, value=DIME, flags=1)
        return result

    def lockMetadata(self, msig: SetcodeMultisig):
        result = self._callFromMultisig(msig=msig, functionName="lockMetadata", functionParams={}, value=DIME, flags=1)
        return result

    def printCopy(self, msig: SetcodeMultisig, targetOwnerAddress: str):
        result = self._callFromMultisig(msig=msig, functionName="printCopy", functionParams={"targetOwnerAddress":targetOwnerAddress}, value=DIME, flags=1)
        return result

    def lockPrint(self, msig: SetcodeMultisig):
        result = self._callFromMultisig(msig=msig, functionName="lockPrint", functionParams={}, value=DIME, flags=1)
        return result
    
    #========================================
    #
    def getBasicInfo(self, includeMetadata: bool = True):
        result = self._run(functionName="getBasicInfo", functionParams={"includeMetadata":includeMetadata})
        return result

    def getInfo(self, includeMetadata: bool = True):
        result = self._run(functionName="getInfo", functionParams={"includeMetadata":includeMetadata})
        return result

# ==============================================================================
# 
