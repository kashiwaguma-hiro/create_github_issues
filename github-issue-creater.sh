#/bin/sh
set -eu

function usage {
  echo "使い方: ./github-issue-creater.sh -o owner -r repo -f filepath"
  echo "-o owner_name      : issue発行先のリポジトリの所有者."
  echo "-r repository_name : issue発行先のリポジトリ名."
  echo "-f filepath        : issueのタイトルリストのファイルパス."
  echo "-d debug           : デバッグモードで実行します.curlが失敗する際の原因究明にご利用ください."
  echo "-h                 : 本メッセージを出力."
  echo ""
}

DEBUG=false

while getopts ho:r:f:d OPT
do
  case $OPT in
     o ) OWNER=$OPTARG;;
     r ) REPO=$OPTARG;;
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
LOGFILE="created_issues_`date +"%Y%m%d%k%M%S"`.log"

if [ "${DEBUG}" = "true" ]; then
   CURL_OPTS="--silent --show-error" # デバッグモードがONの場合、 --failオプションで失敗させずエラーレスポンスを表示できるようにする
   LOGFILE="/dev/stdout"             # ファイルに出力せず標準出力でエラーレスポンスを表示
fi

printf "Create issue"
cat $FILE | while read LINE || [ -n "${LINE}" ]; do

  RESULT=$(curl -X POST https://api.github.com/repos/$OWNER/$REPO/issues \
      $CURL_OPTS \
      -H "Authorization: token $GITHUB_PERSONAL_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -d "{
        \"title\": $LINE,
        \"body\" :\"$(sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\\n/g' ./body_template.txt)\"
      }")
  echo $RESULT | jq -r "if .html_url? then .html_url else . end" >> $LOGFILE # issueのURLまたはリクエスト失敗時のbodyをまるごと出力

  printf "." # progress message.
  sleep 3
done

echo "done!"