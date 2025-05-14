import subprocess
import os
import sys

def run_make_command(target, **kwargs):
    """Constructs a make command with the provided parameters and prints it without executing."""
    command = ["make", target]
    for key, value in kwargs.items():
        command.extend([f"{key.upper()}={value}"])
    print("Command to be executed:", " ".join(command))

def get_user_input(prompt, default=None):
    """Helper function to get user input with a default value."""
    if default:
        return input(f"{prompt} [default: {default}]: ") or default
    return input(f"{prompt}: ")

def main():
    # Collecting user inputs
    account_name = get_user_input("Enter the account name for deployment", "beam-test-1")
    name = get_user_input("Enter the name of the token (e.g., BEAMLINK)","Test")
    symbol = get_user_input("Enter the symbol of the token (e.g., BMLINK)","TS")
    delegate = get_user_input("Enter the delegate address","0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87")
    percentage = get_user_input("Enter the bridge fee percentage. 100% would be 1Mil, 10% is 100k, 1% is 10k...", "10000")
    rpc_url_b = get_user_input("Enter RPC URL for the chain where to deploy BeamOFTAdapter. It is the \"starting chain\" of the token to bridge","https://ethereum-sepolia-rpc.publicnode.com")
    chain_id_b = int(get_user_input("Enter Chain ID for the chain where to deploy BeamOFTAdapter. It is the \"starting chain\" of the token to bridge",11155111))
    token = get_user_input("Enter the address of the token to bridge","0x779877A7B0D9E8603169DdbD7836e478b4624789")
    rpc_url_a = get_user_input("Enter RPC URL for the chain to deploy OFT on. It is the \"destination\" chain of the token to bridge","https://build.onbeam.com/rpc/testnet")
    chain_id_a = int(get_user_input("for the chain to deploy OFT on. It is the \"destination\" chain of the token to bridge",13337))
    sharedDecimals = int(get_user_input("just needed if the token maxsupply exceeds 18.45T",6))
    

    # Construct environment variables from user inputs
    env = {
        "ACCOUNT_NAME": account_name,
        "NAME": name,
        "SYMBOL": symbol,
        "DELEGATE": delegate,
        "PERCENTAGE": percentage,
        "RPC_URL_A": rpc_url_a,
        "CHAIN_ID_A": str(chain_id_a),
        "RPC_URL_B": rpc_url_b,
        "CHAIN_ID_B": str(chain_id_b),
        "TOKEN": token,
        "SHARED_DECIMALS": sharedDecimals
    }

    # Print the make command instead of executing it
    run_make_command("deploy-oft-bridge", **env)

if __name__ == "__main__":
    main()