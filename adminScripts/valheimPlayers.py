from matplotlib.pyplot import pause
import a2s

server_IP = "52.62.208.62"

info = a2s.info((server_IP, 2457)).player_count
print(info)
pause

# https://www.reddit.com/r/discordapp/comments/m8jo2v/ondemand_serverless_valheim_server_setup_with_aws/grj42wu/
# python3 -c "import a2s; print(a2s.info(('<SERVER OR IP ADDRESS>', 2457)).player_count)"