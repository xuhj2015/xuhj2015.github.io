git add .
echo '请输入代码日志~'
read commitString
git commit -m commitString
git push -u origin master

hexo g
hexo d
