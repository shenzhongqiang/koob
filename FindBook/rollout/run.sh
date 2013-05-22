#!/bin/bash

dir=`pwd`
js_script="$dir/compressjs.sh"
css_script="$dir/compresscss.sh"

js_dir="$dir/../root/static/js"
js_files=(book.js search.js tag.js feedback.js);
css_dir="$dir/../root/static/css"
css_files=(style.css)

js_cmd="$js_script "
for i in ${js_files[*]}
do
    js_file="$js_dir/$i"
    js_cmd="$js_cmd $js_file"
done

css_cmd="$css_script"
for i in ${css-files[*]}
do
    css_file="$css_dir/$i"
    css_cmd="$css_cmd $css_file"
done

`$js_cmd 2>&-`
echo "compressed js files"
`$css_cmd 2>&-`
echo "compressed css files"

mv *.css $css_dir
mv *.js $js_dir
echo "rollout completed"
