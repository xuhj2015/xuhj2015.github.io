git add .
git commit -m init
git push -u origin master

echo 'hexo......'
hexo clean
hexo g
hexo d
