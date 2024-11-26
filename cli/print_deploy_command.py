from colorama import Fore, Style, init

# Initialize colorama for cross-platform colored terminal text
init()

def run_make_command(target, **kwargs):
    """Constructs a make command with the provided parameters and prints it in color without executing."""
    command = ["make", target]
    for key, value in kwargs.items():
        command.extend([f"{key.upper()}={value}"])
    colored_command = f"{Fore.CYAN}{' '.join(command)}{Style.RESET_ALL}"
    print(f"Command to be executed:\n{colored_command}")

def get_user_input(prompt, default=None):
    """Helper function to get user input with a default value."""
    if default:
        return input(f"{prompt} [default: {default}]: ") or default
    return input(f"{prompt}: ")

def main():
    # Collecting user inputs
    account_name = get_user_input("Enter the account name for deployment", "beam-test-1")
    rpc_url_a = get_user_input("Enter RPC URL for the source chain (where the token exists)", "https://ethereum-sepolia-rpc.publicnode.com")
    chain_id_a = int(get_user_input("Enter Chain ID for the source chain (where the token exists)", "11155111"))
    rpc_url_b = get_user_input("Enter RPC URL for the destination chain (usually Beam)", "https://build.onbeam.com/rpc/testnet")
    chain_id_b = int(get_user_input("Enter Chain ID for the destination chain (usually Beam)", "13337"))
    peer_a = get_user_input("Enter the peer address for the source chain")
    peer_b = get_user_input("Enter the peer address for the destination chain (Beam)")

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

    # Print the make command
    run_make_command("wire-bridge", **env)

    # Print instructions
    print("\n")
    print(f"{Fore.GREEN}The above command has been printed but not executed. Please copy and run it manually.{Style.RESET_ALL}")
    print(f"{Fore.GREEN}After running the command, proceed by wiring the bridge with:{Style.RESET_ALL}")
    print(f"{Fore.YELLOW}python3 cli/wire_bridge_deployer.py{Style.RESET_ALL}")

if __name__ == "__main__":
    main()