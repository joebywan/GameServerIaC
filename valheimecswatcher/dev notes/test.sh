

SUBTEXT='"numplayers":'
TEXT2='{"name":"My Server","map":"My Server","password":true,"raw":{"protocol":17,"folder":"valheim","game":"","appId":892970,"numplayers":10,"numbots":0,"listentype":"d","environment":"l","secure":0,"version":"1.0.0.0","steamid":"90156483945497603","tags":["0.206.5"]},"maxplayers":64,"players":[],"bots":[],"connect":"13.236.183.43:2456","ping":17}'
TEXT=$(gamedig --type valheim 54.252.205.183 2457)

FILTERED=${TEXT#*'"numplayers":'}
CUT=$(cut -d',' -f-1 <<< $FILTERED)
echo "----- Full Text -----"
echo $TEXT
echo "----- End Text -----"
echo "FILTERED"
echo $FILTERED

echo "player count is: $CUT"