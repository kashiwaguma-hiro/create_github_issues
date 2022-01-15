#/bin/sh
set -eu

function usage {
  echo "使い方: ./github-issue-creater.sh -o owner -r repo -f filepath"
  echo "-o owner_name      : issue発行先のリポジトリの所有者."
  echo "-r repository_name : issue発行先のリポジトリ名."
  echo "-f filepath        : issueのタイトルリストのファイルパス."
  echo "-h                 : 本メッセージを出力."
  echo ""
}

while getopts ho:r:f: OPT
do
  case $OPT in
     o ) OWNER=$OPTARG;;
     r ) REPO=$OPTARG;;
     f ) FILE=$OPTARG;;
     ? | h) usage; exit 1;;
  esac
done

if [ ! -e "$FILE" ];then
  echo "$FILE: No such file."
  echo ""
  usage
  exit 2
fi

LOGFILE="created_issues_`date +"%Y%m%d%k%M%S"`.log"

printf "Create issue"
cat $FILE | while read LINE || [ -n "${LINE}" ]; do
  curl -X POST \
      --silent \
      -H "Authorization: token $GITHUB_PERSONAL_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/repos/$OWNER/$REPO/issues \
      -d "{
        \"title\": $LINE,
        \"body\" :\"`sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\\n/g' ./body_template.txt`\"
      }" | jq -r .html_url >> $LOGFILE
  printf "." # progress message.
  sleep 3
done

echo "done!"