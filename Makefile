NAME=Fourier-Series
AUTHOR=Zach Hagelberg
HOST=zacherson@zach.hagelb.org

fourier.love: main.lua
	zip -r -q -9 -X $@ $^

fourier/Fourier-Series-web.zip: fourier.love
	love-js/love-js.sh $< "$(NAME)" -a="$(AUTHOR)" -o=fourier

run: ; love .

clean:
	rm -f fourier/Fourier-Series-web.zip fourier.love

upload: fourier/Fourier-Series-web.zip
	scp $< "$(HOST):"
	ssh $(HOST) "unzip Fourier-Series-web.zip && \
		mv fourier/Fourier-Series-web/ zach.hagelb.org/fourier &&\
		rm -rf Fourier-Series-web.zip fourier"

check: ; luacheck --std luajit+love main.lua

.PHONY: clean upload check run
