#/bin/sh
set -e -u -o pipefail

function usage {
  echo "使い方: ./convert_to_epic.sh -r repo_id -f filepath"
  echo "-r repo_id  : ZenhubのリポジトリIDを指定."
  echo "-f filepath : 変換対象の issue の URL."
  echo "-d debug    : デバッグモードで実行します.curlが失敗する際の原因究明にご利用ください."
  echo "-h          : 本メッセージを出力."
  echo ""
}

DEBUG=false

while getopts r:f:dh OPT
do
  case $OPT in
     r ) ZENHUB_REPO_ID=$OPTARG;;
     f ) FILE=$OPTARG;;
     d ) DEBUG=true;;
     ? | h) usage; exit 1;;
  esac
done

if [ ! -e "$FILE" ];then
  echo "$FILE: No such file."
  echo ""
  usage
  exit 2
fi

CURL_OPTS="--silent --show-error --fail"
LOGFILE="converted_epics_`date +"%Y%m%d%k%M%S"`.log"

if [ "${DEBUG}" = "true" ]; then
   CURL_OPTS="--silent --show-error" # デバッグモードがONの場合、 --failオプションで失敗させずエラーレスポンスを表示できるようにする
   LOGFILE="/dev/stdout"             # ファイルに出力せず標準出力でエラーレスポンスを表示
fi

printf "Issue concert to epic"
cat $FILE | while read LINE || [ -n "${LINE}" ]; do

  TARGET_ISSUE_ID=$(echo $LINE | cut -d "/" -f7)
  curl -X POST https://api.zenhub.com/p1/repositories/$ZENHUB_REPO_ID/issues/$TARGET_ISSUE_ID/convert_to_epic \
      $CURL_OPTS \
      -H "X-Authentication-Token:$ZENHUB_TOKEN" \
      -H 'Content-Type: application/json' \
      -d '{ "issues": []}' >> $LOGFILE

  printf "." # progress message.
  sleep 3
done

echo "done!"
