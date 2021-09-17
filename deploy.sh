git add .
echo '请输入代码日志~'
read mark
git commit -m mark
git push -u origin master

hexo g
hexo d
