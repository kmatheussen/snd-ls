
VERSION=0.9.9.2_beta
NAME=snd-ls-$(VERSION)


all:
	./do_build


install:
	./do_install


dist:
# mv_changes.diff changes.diff
	rm -fr snd-10 snd-10-new a.out *~

	cp -f config.scm config.scm.old
	cp -f config.scm.dist config.scm

	rm -fr /tmp/$(NAME)
	rm -fr $(NAME)
	mkdir /tmp/$(NAME)
	cp -a * /tmp/$(NAME)/
	mv /tmp/$(NAME) .
	tar cvf $(NAME).tar $(NAME)
	gzip $(NAME).tar
	marcel_upload_snd $(NAME).tar.gz
	ls -la $(NAME)
	rm -fr $(NAME)

mv_changes.diff:
	mv -f changes.diff changes.diff.old

changes.diff:
	sh -c 'cd snd-10 && make clean'

	mv snd-10 snd-10-new

	tar xvjf snd-10.tar.bz2

	diff -ur snd-10 snd-10-new >changes.diff

