#!/usr/bin/env python3

# ==============================================================================
# 
from importlib.metadata import distribution
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
from   contract_Distributor      import Distributor
from   contract_LiquidToken      import LiquidToken
from   contract_LiquidCollection import LiquidCollection
from   contract_DistributorDebot import DistributorDebot

#SERVER_ADDRESS = "https://net.ton.dev"
SERVER_ADDRESS = "https://gql.custler.net"

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
    "symbol": "TST",
    "description": "Test description",
    "seller_fee_basis_points": 1000,
    "image": "image.png",
    "external_url": "",
    "collection": {},
    "attributes": [],
    "properties": {
        "files": [
            {"uri": "image.png","type": "image/png"}
        ],
        "category": "image"
    }
}


defaultCollectionMeta = {
    "name"  : "Name",
    "symbol": "",
    "description": "Description",
    "seller_fee_basis_points": 1000,
    "image": "image.png",
    "external_url": "",
    "collection": {},
    "attributes": [],
    "properties": {
        "files": [
            {"uri": "image.png","type": "image/png"}
        ],
        "category": "image"
    }
}

# ==============================================================================
# 
print("DEPLOYING CONTRACTS...")


# MSIGS
msigRand  = Multisig(everClient=getClient())
authority = Multisig(everClient=getClient())

nonce = hex(random.randint(0, 0xFFFFFFFFFFFFFFFFFFFFFFFF))
print(nonce)

distributor = Distributor(everClient                    = getClient(), 
                          nonce                         = nonce, 
                          creatorAddress                = authority.ADDRESS,
                          ownerAddress                  = authority.ADDRESS,
                          ownerPubkey                   = "0x" + str(authority.PUBKEY),
                          treasuryAddress               = authority.ADDRESS,
                          presaleStartDate              = getNowTimestamp() - 1000,
                          saleStartDate                 = getNowTimestamp(),
                          price                         = EVER,
                          collectionMetadata            = "",
                          tokenPrimarySaleHappened      = True,
                          tokenMetadataIsMutable        = True,
                          tokenMasterEditionMaxSupply   = 0,
                          tokenMasterEditionPrintLocked = True,
                          tokenCreatorsPercent          = 500,
                          tokenCreatorsShares           = [{"creatorAddress":authority.ADDRESS, "creatorShare":10000}],
                          signer                        = authority.SIGNER)

collection = LiquidCollection(everClient=getClient(), nonce=nonce, 
                                                        creatorAddress                = authority.ADDRESS,
                                                        ownerAddress                  = authority.ADDRESS,
                                                        collectionMetadata            = "",
                                                        tokenPrimarySaleHappened      = True,
                                                        tokenMetadataIsMutable        = True,
                                                        tokenMasterEditionMaxSupply   = 0,
                                                        tokenMasterEditionPrintLocked = True,
                                                        tokenCreatorsPercent          = 500,
                                                        tokenCreatorsShares           = [{"creatorAddress":authority.ADDRESS, "creatorShare":100}])

debot = DistributorDebot(getClient(), authority.ADDRESS, distributor.ADDRESS)

"""
print(" MSIG:",  authority.ADDRESS)
print("COLCT:",  collection.ADDRESS)

#input("Press Enter to continue...")

#giverGive(getClient(), collection.ADDRESS, DIME * 3)
giverGive(getClient(), authority.ADDRESS, EVER * 100)

authority.deploy()


authority.sendTransaction(addressDest=collection.ADDRESS, value=EVER)
print("balance:", authority.getBalance())
result = collection.deploy()
_unwrapMessages(result)
print("balance:", authority.getBalance())

result = collection.createNFT(msig=authority, 
                              ownerAddress=authority.ADDRESS, 
                              creatorAddress=authority.ADDRESS, 
                              metadata=json.dumps(defaultMeta), 
                              metadataAuthorityAddress=authority.ADDRESS)

_unwrapMessages(result)
print("balance:", authority.getBalance())
"""



print(" MSIG:",  authority.ADDRESS)
print("DISTR:",  distributor.ADDRESS)
print("COLCT:",  collection.ADDRESS)
print("DEBOT:",  debot.ADDRESS)

#input("Press Enter to continue...")

giverGive(getClient(), distributor.ADDRESS, DIME * 3)
giverGive(getClient(), authority.ADDRESS, EVER * 100)
giverGive(getClient(), debot.ADDRESS, DIME * 3)

authority.deploy()
result = distributor.deploy()
#debot.deploy()
#debot.setABI(msig=authority, value=DIME)


#msgArray = unwrapMessages(getClient(), result[0].transaction["out_msgs"], _getAbiArray())
#pprint(msgArray)
#pprint(result[0].transaction["id"])

#pprint(distributor.getInfo(True, False))
#collection.ADDRESS = distributor.getInfo(False, False)["collectionAddress"]
#pprint(collection.getInfo(False, False))

metaList = []
for i in range(0, 20):
    meta = defaultMeta.copy()
    meta["name"] = meta["name"] + str(i)
    metaList.append(json.dumps(meta))

#print(metaList)

distributor.addTokens(authority, metaList)
distributor.lockTokens(authority)
pprint(distributor.getInfo(True, False))

#result = distributor.mintInternal(authority, authority.ADDRESS)
result = distributor.mintInternal(authority, authority.ADDRESS)
#_unwrapMessagesAndPrint(result)
result = distributor.mintInternal(authority, authority.ADDRESS)
#_unwrapMessagesAndPrint(result)
result = distributor.mintInternal(authority, authority.ADDRESS)
#_unwrapMessagesAndPrint(result)
#_unwrapMessagesAndPrint(result)

token = LiquidToken(everClient=getClient(), collectionAddress=collection.ADDRESS, tokenID=0, editionNumber=0)
print(token.getBasicInfo())

pprint(distributor.getInfo(True, False))

"""
# ==============================================================================
# 
unittest.main()
"""