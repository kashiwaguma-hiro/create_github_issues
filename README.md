# github-issue-creater


CSVファイルのタイトルリストをもとに、Github issueを作成するだけのプロダクト.  
Zenhubを使っている場合は対象のファイルをEpicにすることもできる.  

# 動作環境
- Mac OS Big Sur version 11.4
- curl 7.64.1 
- jq 1.6

## 使い方
```
./github-issue-creater.sh -h
使い方: ./github-issue-creater.sh -o owner -r repo -f filepath
-o owner_name      : issue発行先のリポジトリの所有者.
-r repository_name : issue発行先のリポジトリ名.
-f filepath        : issueのタイトルリストのファイルパス.
-d debug           : デバッグモードで実行します.curlが失敗する際の原因究明にご利用ください.
-h                 : 本メッセージを出力.
```

## 例

1. Githubの個人トークンを発行する  
   参考: [個人アクセストークンを使用する
   ](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-token)

1. 発行したいGithub issueのタイトルを記述したファイルを用意  
   例:３つのチケットを作成したい場合
   ```Shell
   $ cat example.csv
   テストissue 1
   test issue 2
   test issue\n3
   ```

1. issueを作成する  
   例: https://github.com/kashiwaguma-hiro/github-issue-creater リポジトリへissueを発行したい場合
   ```Shell
   $ pwd
   /Users/kashiwaguma-hiro/git/github-issue-creater

   $ GITHUB_PERSONAL_TOKEN=1で発行したトークン \
     ./github-issue-creater.sh -o kashiwaguma-hiro -r github-issue-creater -f example.csv
   Create issue...done!

   $ cat created_issues_yyyyMMddhhmmss.log
   https://api.github.com/repos/kashiwaguma-hiro/github-issue-creater/issues/1
   https://api.github.com/repos/kashiwaguma-hiro/github-issue-creater/issues/2
   https://api.github.com/repos/kashiwaguma-hiro/github-issue-creater/issues/3
   ```

## 参考にさせていただいたサイト
- https://docs.github.com/ja/rest/guides/getting-started-with-the-rest-api
- https://docs.github.com/en/rest/reference/issues#create-an-issue
