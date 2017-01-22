docker run -it --rm -p 8000:8000 -v $PWD/index.html:/reveal.js/index.html:ro \
-v $PWD/media:/reveal.js/media:ro -v $PWD/content.md:/reveal.js/content.md:ro -v $PWD/custom.css:/reveal.js/css/theme/custom.css:ro \
-v $PWD/menu:/reveal.js/plugin/menu:ro nbrown/revealjs