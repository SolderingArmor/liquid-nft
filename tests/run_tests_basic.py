#!/usr/bin/env python3

# ==============================================================================
# 
import freeton_utils
from   freeton_utils import *
import binascii
import unittest
import time
import sys
import os
import random
from   pathlib import Path
from   pprint import pprint
from   contract_BasicToken      import BasicToken
from   contract_BasicCollection import BasicCollection
from   contract_BasicStaking    import BasicStaking

SERVER_ADDRESS = "https://net.ton.dev"

# ==============================================================================
#
def getClient():
    return TonClient(config=ClientConfig(network=NetworkConfig(server_address=SERVER_ADDRESS)))

# ==============================================================================
# 
# Parse arguments and then clear them because UnitTest will @#$~!
for _, arg in enumerate(sys.argv[1:]):
    if arg == "--disable-giver":
        
        freeton_utils.USE_GIVER = False
        sys.argv.remove(arg)

    if arg == "--throw":
        
        freeton_utils.THROW = True
        sys.argv.remove(arg)

    if arg.startswith("http"):
        
        SERVER_ADDRESS = arg
        sys.argv.remove(arg)

    if arg.startswith("--msig-giver"):
        
        freeton_utils.MSIG_GIVER = arg[13:]
        sys.argv.remove(arg)

# ==============================================================================
# EXIT CODE FOR SINGLE-MESSAGE OPERATIONS
# we know we have only 1 internal message, that's why this wrapper has no filters
def _getAbiArray():
    files = []
    for file in os.listdir("../bin"):
        if file.endswith(".abi.json"):
            files.append(os.path.join("../bin", file))
    return files

def _unwrapMessages(result):
    return unwrapMessages(getClient(), result["result"].transaction["out_msgs"], _getAbiArray())

def _unwrapMessagesAndPrint(result):
    msgs = _unwrapMessages(result)
    pprint(msgs)

def _getExitCode(msgIdArray):
    msgArray     = unwrapMessages(getClient(), msgIdArray, _getAbiArray())
    if msgArray != "":
        realExitCode = msgArray[0]["TX_DETAILS"]["compute"]["exit_code"]
    else:
        realExitCode = -1
    return realExitCode   

# ==============================================================================
# 
defaultMeta = {
    "name"  : "Degen test #",
    "description": "Test description",
    "preview": {"uri": "image.png","type": "image/png"},
    "external_url": "",
    "files": [{"uri": "image.png","type": "image/png"}]
}


defaultCollectionMeta = {
    "name"  : "Name",
    "description": "Description",
    "preview": {"uri": "image.png","type": "image/png"},
    "external_url": "",
    "files": [{"uri": "image.png","type": "image/png"}]
}

# ==============================================================================
# 
print("DEPLOYING CONTRACTS...")


# MSIGS
msigRand  = Multisig(everClient=getClient())
authority = Multisig(everClient=getClient())

nonce = hex(random.randint(0, 0xFFFFFFFFFFFFFFFFFFFFFFFF))
print(nonce)

collection = BasicCollection(everClient=getClient(), nonce=nonce, ownerAddress=authority.ADDRESS, initiatorAddress=authority.ADDRESS, metadata="{}")
staker     = BasicStaking   (everClient=getClient(), nonce=nonce, ownerAddress=authority.ADDRESS, initiatorAddress=authority.ADDRESS, collectionAddress=collection.ADDRESS)

print("  MSIG:",  authority.ADDRESS )
print("COLLCT:",  collection.ADDRESS)
print("STAKER:",  staker.ADDRESS    )

giverGive(getClient(), authority.ADDRESS, EVER * 10)

authority.deploy()
authority.sendTransaction(collection.ADDRESS, EVER)
authority.sendTransaction(staker.ADDRESS,     EVER)
result = collection.deploy()
result = staker.deploy()

metaList = []
for i in range(0, 20):
    meta = defaultMeta.copy()
    meta["name"] = meta["name"] + str(i)
    metaList.append(json.dumps(meta))

#print(metaList)

result = collection.createToken(msig=authority, ownerAddress=authority.ADDRESS, authorityAddress=authority.ADDRESS, initiatorAddress=authority.ADDRESS, metadata=metaList[0])
#_unwrapMessagesAndPrint(result)

token = BasicToken(everClient=getClient(), collectionAddress=collection.ADDRESS, tokenID=0)
pprint(token.getBasicInfo())

result = token.setAuthority(msig=authority, authorityAddress=staker.ADDRESS, payload="")

result = staker.unstake(msig=authority, tokenAddress=token.ADDRESS)
_unwrapMessagesAndPrint(result)

pprint(token.getBasicInfo())
pprint(staker.getInfo())

"""
# ==============================================================================
# 
unittest.main()
"""