
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
    
    rpc_url_b =get_user_input("Enter RPC URL of the chain where you deployed the OFTAdapter", "https://ethereum-sepolia-rpc.publicnode.com")
    chain_id_b = int(get_user_input("Enter Chain ID of the chain where you deployed the OFTAdapter", "11155111"))
    rpc_url_a = get_user_input("Enter RPC URL of the chain where you deployed the OFT", "https://build.onbeam.com/rpc/testnet")
    chain_id_a = int(get_user_input("Enter Chain ID of the chain where you deployed the OFT", "13337"))
    peer_b = get_user_input("Enter the address of the OFTAdapter")
    peer_a = get_user_input("Enter the address of the OFT")

    # Construct environment variables from user inputs
    env = {
        "ACCOUNT_NAME": account_name,
        "RPC_URL_A": rpc_url_a,
        "CHAIN_ID_A": str(chain_id_a),
        "RPC_URL_B": rpc_url_b,
        "CHAIN_ID_B": str(chain_id_b),
        "PEER_A": peer_a,
        "PEER_B": peer_b
    }

    # Print the make command instead of executing it
    run_make_command("wire-bridge", **env)

if __name__ == "__main__":
    main()