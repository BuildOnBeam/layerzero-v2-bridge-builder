-include .env

# script paths
SET_PEER_SCRIPT_PATH = lz-scripts/SetPeers.s.sol
GET_INFO_SCRIPT_PATH = lz-scripts/GetInfos.s.sol
BRIDGE_SCRIPT_PATH = lz-scripts/BridgeToken.s.sol
DEPLOY_OFT_SCRIPT_PATH = deploy/foundry/DeployBeamOFT.s.sol
DEPLOY_OFT_ADAPTER_SCRIPT_PATH = deploy/foundry/DeployBeamOFTAdapter.s.sol
SET_LIBS_SCRIPT_PATH = lz-scripts/SetLibraries.s.sol

# script signatures
SET_PEER_SIG = runSetPeer(uint256,address,address)
GET_INFOS_SIG = getInfos(address,uint32)
BRIDGE_TOKEN_SIG = bridgeToken(uint256,address)
DEPLOY_OFT_SCRIPT_SIG = deployBeamOFT(string,string,uint256,address)
DEPLOY_OFT_ADAPTER_SCRIPT_SIG = deployBeamOFTAdapter(uint256,address,address)
SET_LIBS_SIG = setLibraries(address,uint256,uint256)



###########################################################
############# 		DEPLOY BRIDGE IN ONE COMMAND	#######
###########################################################

# RPC_URL_A: starting chain rpc url
# CHAIN_ID_A: starting chain id
# RPC_URL_B:destination chain rpc url
# CHAIN_ID_B: destination chain id
# NAME: name of the OFT token
# SYMBOL: symbol of the OFT token
# ACCOUNT_NAME: the account you'll sign the tx
# DELEGATE: the owner of the contract
# TOKEN:ERC20 address to bridge

#  make deploy-bridge RPC_URL_A=https://build.onbeam.com/rpc/testnet CHAIN_ID_A=13337 ACCOUNT_NAME=beam-test-1 NAME=BEAMLINK SYMBOL=BMLINK  DELEGATE=0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 RPC_URL_B=https://ethereum-sepolia-rpc.publicnode.com CHAIN_ID_B=11155111 TOKEN=0x779877A7B0D9E8603169DdbD7836e478b4624789
deploy-bridge:
	$(MAKE) run-deploy-beam-oft \
		RPC_URL=${RPC_URL_A} \
		ACCOUNT_NAME=${ACCOUNT_NAME} \
		NAME=$(NAME) SYMBOL=$(SYMBOL) \
		CHAIN_ID=$(CHAIN_ID_A) \
		DELEGATE=$(DELEGATE)
	$(MAKE) run-deploy-beam-oft-adapter \
		RPC_URL=${RPC_URL_B} \
		ACCOUNT_NAME=${ACCOUNT_NAME} \
		CHAIN_ID=$(CHAIN_ID_B) \
		DELEGATE=$(DELEGATE) \
		TOKEN=$(TOKEN)


###########################################################
############# 	WIRE BRIDGE IN ONE COMMAND	###############
###########################################################


#  make wire-bridge RPC_URL_A=https://build.onbeam.com/rpc/testnet CHAIN_ID_A=13337 ACCOUNT_NAME=beam-test-1 RPC_URL_B=https://ethereum-sepolia-rpc.publicnode.com CHAIN_ID_B=11155111 PEER_A=0xe5EC27e0D0E96418C23e47C6129eC68EbDb530fc  PEER_B=0xD329EeBEeC589bc06B63669a9dFf5F39801e18E1
wire-bridge:
	$(MAKE) add-peer \
		ACCOUNT_NAME=${ACCOUNT_NAME} \
		RPC_URL=${RPC_URL_A} \
		CHAIN_ID=${CHAIN_ID_B} \
		CONTRACT=${PEER_A} \
		PEER=${PEER_B} 
	$(MAKE) add-peer \
		ACCOUNT_NAME=${ACCOUNT_NAME} \
		RPC_URL=${RPC_URL_B} \
		CHAIN_ID=${CHAIN_ID_A} \
		CONTRACT=${PEER_B} \
		PEER=${PEER_A} 
	


###########################################################
############# 		SPECIFIC COMMANDS	      	###########
###########################################################

###########################################################
############# 		DEPLOY BRIDGE	      	    ###########
###########################################################

run-deploy-beam-oft:
	forge script $(DEPLOY_OFT_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--sig "$(DEPLOY_OFT_SCRIPT_SIG)" $(NAME) $(SYMBOL) $(CHAIN_ID) $(DELEGATE) \
		-vvvv --legacy  	

# make deploy-beam-oft RPC_URL=https://eth-sepolia.g.alchemy.com/v2 ACCOUNT_NAME=beam-test-1 NAME=Test SYMBOL=TST CHAIN_ID=11155111 DELEGATE=0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87
deploy-beam-oft: 
	$(MAKE) run-deploy-beam-oft RPC_URL=${RPC_URL} ACCOUNT_NAME=${ACCOUNT_NAME} NAME=$(NAME) SYMBOL=$(SYMBOL)  CHAIN_ID=$(CHAIN_ID) DELEGATE=$(DELEGATE)
	

run-deploy-beam-oft-adapter:
	@forge script $(DEPLOY_OFT_ADAPTER_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--sig "$(DEPLOY_OFT_ADAPTER_SCRIPT_SIG)" $(CHAIN_ID) $(DELEGATE) $(TOKEN) \
		-vvvv --legacy --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

# make deploy-beam-oft-adapter RPC_URL=https://eth-sepolia.g.alchemy.com/v2 ACCOUNT_NAME=beam-test-1 CHAIN_ID=11155111 DELEGATE=0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 TOKEN=0x779877A7B0D9E8603169DdbD7836e478b4624789
deploy-beam-oft-adapter: 
	$(MAKE) run-deploy-beam-oft-adapter RPC_URL=${RPC_URL} ACCOUNT_NAME=${ACCOUNT_NAME} CHAIN_ID=$(CHAIN_ID) DELEGATE=$(DELEGATE) TOKEN=$(TOKEN)
	



###########################################################
############# 		ADD PEERS 				    ###########
###########################################################

# Default target to run the script on Sepolia
run-add-peer:
	@forge script $(SET_PEER_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--sig "$(SET_PEER_SIG)" $(CHAIN_ID) $(CONTRACT) $(PEER) \
		-vvvv --legacy 


# make add-peer ACCOUNT_NAME=beam-test-1   RPC_URL=${RPC_URL} CHAIN_ID=${CHAIN_ID} CONTRACT=${CONTRACT} PEER=0x1c33A56bf6218d3C6F62E5465f3b8d1C97214B72 
add-peer: 
	@$(MAKE) run-add-peer RPC_URL=${RPC_URL} ACCOUNT_NAME=${ACCOUNT_NAME} CHAIN_ID=${CHAIN_ID} CONTRACT=${CONTRACT} PEER=${PEER}


###########################################################
############# 		GET INFO 				    ###########
###########################################################

run-get-info:
	@forge script $(GET_INFO_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--sig "$(GET_INFOS_SIG)" $(CONTRACT) $(EID) \
		-vvvv --legacy 

#  make get-info RPC_URL=https://build.onbeam.com/rpc/testnet  EID=40178 CONTRACT=0xd14c56F867a3FA55AA33FfCB391d1f6972b02630
#  make get-info RPC_URL=https://ethereum-sepolia-rpc.publicnode.com   EID=40161 CONTRACT=0x9870477f93CADa260978Aec3F380f074ECB8697B
get-info:
	$(MAKE) run-get-info RPC_URL=${RPC_URL} EID=${EID} CONTRACT=${CONTRACT}

###########################################################
############# 		BRIDGE TOKENS				###########
###########################################################

run-bridge-token:
	@forge script $(BRIDGE_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--password $(ACCOUNT_PWD) \
		--sig "$(BRIDGE_TOKEN_SIG)"  $(CHAIN_ID) $(CONTRACT) \
		-vvvvvvv --legacy 
	
# make bridge-LINK RPC_URL=https://ethereum-sepolia-rpc.publicnode.com ACCOUNT_NAME=beam-test-1 CONTRACT=0xD329EeBEeC589bc06B63669a9dFf5F39801e18E1 CHAIN_ID=13337
bridge-general: 
	$(MAKE) run-bridge-token RPC_URL=${RPC_URL} ACCOUNT_NAME=${ACCOUNT_NAME} CHAIN_ID=${CHAIN_ID} CONTRACT=$(CONTRACT)



###########################################################
############# 		 SET LIBRARIES     	        ###########
###########################################################

run-set-libraries:
	@forge script $(SET_LIBS_SCRIPT_PATH) \
		--rpc-url $(RPC_URL) \
		--broadcast \
		--account ${ACCOUNT_NAME} \
		--password $(ACCOUNT_PWD)
		--sig "$(SET_LIBS_SIG)" $(OAPP) $(ORIGIN_CHAIN_ID)  $(DESTINATION_CHAIN_ID)  \
		-vvvvvvv --legacy 


# make set-libraries RPC_URL=https://ethereum-sepolia-rpc.publicnode.com  ACCOUNT_NAME=beam-test-1  OAPP=0xD329EeBEeC589bc06B63669a9dFf5F39801e18E1 ORIGIN_CHAIN_ID=11155111 DESTINATION_CHAIN_ID=13337
set-libraries: 
	$(MAKE) run-set-libraries RPC_URL=${RPC_URL} ACCOUNT_NAME=${ACCOUNT_NAME} OAPP=${OAPP} ORIGIN_CHAIN_ID=${ORIGIN_CHAIN_ID} DESTINATION_CHAIN_ID=${DESTINATION_CHAIN_ID}
	
