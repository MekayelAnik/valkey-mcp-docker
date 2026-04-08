#!/usr/bin/env bash
# Standard colors mapped to 8-bit equivalents
ORANGE='\033[38;5;208m'
BLUE='\033[38;5;12m'
ERROR_RED='\033[38;5;9m'
GREEN='\033[38;5;2m'
ASH_GRAY='\033[38;5;250m'
NC='\033[0m'

# Constants
BUILD_TIMESTAMP=$(cat /usr/local/bin/build-timestamp.txt 2>/dev/null || echo "")

# Function to print separator line
print_separator() {
    printf "\n"
    printf "\n______________________________________________________________________________________________________________________________________________"
    printf "\n"
}

# Print ASCII art
print_ascii_art() {
    printf "${GREEN} /VV      /VV         /VV /VV                              /VV      /VV  /VVVVVV  /VVVVVVV         /VVVVVV                                                      ${NC}\n"
    printf "${GREEN} | VV    / VV        | VV| VV                             | VVV    /VVV /VV__  VV| VV__  VV       /VV__  VV                                                     ${NC}\n"
    printf "${GREEN} | VV   / VV  /VVVVVV| VV| VV   /VVVV  /VV   /VV         | VVVV  /VVVV| VV  \\__/| VV  \\ VV      | VV  \\__/  /VVVVVV   /VVVVVV  /VV    /VV /VVVVVV   /VVVVVV    ${NC}\n"
    printf "${GREEN} |  VV / VV/ /VV__  VV| VV| VV  /VV__  VV| VV | VV        | VV VV/VV VV| VV      | VVVVVVV/      |  VVVVVV  /VV__  VV /VV__  VV|  VV  /VV//VV__  VV /VV__  VV   ${NC}\n"
    printf "${GREEN}  \\  VV VV/ | VVVVVVVV| VV| VV | VVVVVVVV| VV | VV        | VV  VVV| VV| VV      | VV____/        \\____  VV| VVVVVVVV| VV  \\__/ \\  VV/VV/| VVVVVVVV| VV  \\__/   ${NC}\n"
    printf "${GREEN}   \\  VVV/  | VV_____/| VV| VV | VV_____/|  VV/ VV/       | VV\\  V | VV| VV    VV| VV             /VV  \\ VV| VV_____/| VV        \\  VVV/ | VV_____/| VV         ${NC}\n"
    printf "${GREEN}    \\  V/   |  VVVVVVV| VV| VV |  VVVVVVV \\  VVVV/        | VV \\/  | VV|  VVVVVV/| VV            |  VVVVVV/|  VVVVVVV| VV         \\  V/  |  VVVVVVV| VV         ${NC}\n"
    printf "${GREEN}     \\_/     \\_______/|__/|__/  \\_______/  \\___/          |__/     |__/ \\______/ |__/             \\______/  \\_______/|__/          \\_/    \\_______/|__/         ${NC}\n"
    printf "\n"
}

# Print Maintainer information
print_maintainer_info() {
    printf "\n"
    printf "${ASH_GRAY} ███╗   ███╗██████╗        ███╗   ███╗███████╗██╗  ██╗ █████╗ ██╗   ██╗███████╗██╗          █████╗ ███╗   ██╗██╗██╗  ██╗                 ${NC}\n"
    printf "${ASH_GRAY} ████╗ ████║██╔══██╗       ████╗ ████║██╔════╝██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔════╝██║         ██╔══██╗████╗  ██║██║██║ ██╔╝                 ${NC}\n"
    printf "${ASH_GRAY} ██╔████╔██║██║  ██║       ██╔████╔██║█████╗  █████╔╝ ███████║ ╚████╔╝ █████╗  ██║         ███████║██╔██╗ ██║██║█████╔╝                  ${NC}\n"
    printf "${ASH_GRAY} ██║╚██╔╝██║██║  ██║       ██║╚██╔╝██║██╔══╝  ██╔═██╗ ██╔══██║  ╚██╔╝  ██╔══╝  ██║         ██╔══██║██║╚██╗██║██║██╔═██╗                  ${NC}\n"
    printf "${ASH_GRAY} ██║ ╚═╝ ██║██████╔╝██╗    ██║ ╚═╝ ██║███████╗██║  ██╗██║  ██║   ██║   ███████╗███████╗    ██║  ██║██║ ╚████║██║██║  ██╗                 ${NC}\n"
    printf "${ASH_GRAY} ╚═╝     ╚═╝╚═════╝ ╚═╝    ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚══════╝╚══════╝    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝                 ${NC}\n"
}

# Print system information
print_system_info() {
    print_separator

    local disp_port="$PORT"
    local display_ip=$(ip route 2>/dev/null | awk '/default/ {print $3}' || echo "unknown")
    local port_display=":$disp_port"
    [[ "$disp_port" == '80' ]] && port_display=""

printf "${GREEN} >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Starting Valkey MCP Server! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< \n${NC}"
printf "${ORANGE} ==================================${NC}\n"
printf "${ORANGE} PUID: %s${NC}\n" "$PUID"
printf "${ORANGE} PGID: %s${NC}\n" "$PGID"
printf "${ORANGE} MCP IP Address: %s\n${NC}" "$display_ip"
printf "${ORANGE} MCP Server PORT: ${GREEN}%s\n${NC}\n" "${disp_port:-80}"
printf "${ORANGE} ==================================${NC}\n"
printf "${ERROR_RED} Note: You may need to change the IP address to your host machine IP\n${NC}"
[[ -n "$BUILD_TIMESTAMP" && -f "$BUILD_TIMESTAMP" ]] && BUILD_TIMESTAMP=$(cat "$BUILD_TIMESTAMP") && printf "${ORANGE}${BUILD_TIMESTAMP}${NC}\n"
    printf "${BLUE}This Container was started on:${NC} ${GREEN}$(date)${NC}\n"
}

# Main execution
main() {
    print_separator
    print_ascii_art
    print_maintainer_info
    print_system_info
}

main
