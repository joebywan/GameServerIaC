

SUBTEXT='"numplayers":'
TEXT='{"name":"My Server","map":"My Server","password":true,"raw":{"protocol":17,"folder":"valheim","game":"","appId":892970,"numplayers":10,"numbots":0,"listentype":"d","environment":"l","secure":0,"version":"1.0.0.0","steamid":"90156483945497603","tags":["0.206.5"]},"maxplayers":64,"players":[],"bots":[],"connect":"13.236.183.43:2456","ping":17}'
#[[ "$TEXT" == *"$SUBTEXT"* ]] && echo "yay" || echo "boo"


REST=${TEXT#*$SUBTEXT}
CUT=$(cut -d',' -f-1 <<< $REST)
BURP=${REST#*,}
ZOOM=${REST:0:1}
echo "REST"
echo $REST
echo "ZOOM"
echo $ZOOM
echo CUT
echo $CUT