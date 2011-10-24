

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Start editing from here ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "config.scm")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Stop editing here ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define snd-ls-version 90701)

(use-modules (ice-9 rdelim))


(define <-> string-append)

(if (not (char=? #\/ (car (reverse (string->list prefix)))))
    (set! prefix (<-> prefix "/")))


(define (get-system-output command)
  (let ((logfilename "/tmp/snd-ls-logtemp"))
    (system (<-> command " > " logfilename))
    (let* ((ret "")
	   (fd (open-file logfilename "r"))
	   (line (read-line fd)))
      (while (not (eof-object? line))
	     (set! ret (<-> ret line))
	     (set! line (read-line fd)))
      (close fd)
      (system (<-> "rm " logfilename))
      ret)))


(if (string=? "" guile-bin-dir)
    (if (not (= 0 (system "which guile-config >/dev/null 2>/dev/null")))
	(begin
	  (display "The program \"guile-config\" was not in PATH. Perhaps you need the guile-devel package?")(newline)
	  (quit))
	(let ((which (get-system-output "which guile-config")))
	  (set! guile-bin-dir (substring which 0 (- (string-length which) (string-length "guile-config")))))))

(if (not (char=? #\/ (car (reverse (string->list guile-bin-dir)))))
    (set! guile-bin-dir (<-> guile-bin-dir "/")))



(define (listop daslist)
  (if (null? daslist)
      #t
      (if ((car daslist))
	  (listop (cddr daslist))
	  (begin
	    (newline)
	    (display (cadr daslist))
	    (newline)
	    #f))))



(define (system2 . commands)
  (= 0 (system (apply <-> commands))))

(define (system3 . commands)
  (display (<-> "Executing command \"" (apply <-> commands) "\""))(newline)
  (= 0 (system (apply <-> commands))))

(define (make-system2 . commands)
  (lambda ()
    (apply system2 commands)))

(define (atleast1.8.0?)
  (let ((version (map string->number
		      (string-split (get-system-output (<-> guile-bin-dir "guile-config info guileversion")) #\.))))
    (or (> (car version) 1)
	(and (= 1 (car version))
	     (or (> (cadr version) 8)
		 (and (= 8 (cadr version))
		      (>= (caddr version) 0)))))))

(define (atleast1.6.4?)
  (let ((version (map string->number
		      (string-split (get-system-output (<-> guile-bin-dir "guile-config info guileversion")) #\.))))
    (or (> (car version) 1)
	(and (= 1 (car version))
	     (or (> (cadr version) 6)
		 (and (= 6 (cadr version))
		      (>= (caddr version) 4)))))))

(define (before1.8?)
  (let ((version (map string->number
		      (string-split (get-system-output (<-> guile-bin-dir "guile-config info guileversion")) #\.))))
    (and (= 1 (car version))
	 (< (cadr version) 8))))

(define (get-CFLAGS)
  (if (getenv "CFLAGS") (getenv "CFLAGS") ""))
(define (get-LDFLAGS)
  (if (getenv "LDFLAGS") (getenv "LDFLAGS") ""))

(define (get-gcc-command)
  (<-> " gcc " (get-CFLAGS) " " (get-LDFLAGS) " "))

(define buildlist (list
		   
		   atleast1.8.0?
		   "Need guile V1.8.0 or newer"

		   ;before1.8?
		   ;"Guile 1.8 (and possible later versions) will crash snd-ls. Not supported."

		   (lambda () (access? (<-> guile-bin-dir "/guile-config") X_OK))
		   "Could not find the guile-config program. Perhaps you need the guile-devel package?"
		   
		   (make-system2 "gcc -v 2>/dev/null")
		   "Could not find gcc."
		   
		   (make-system2 "bzip2 -h 2>/dev/null")
		   "Could not find bzip2."

		   (make-system2 (get-gcc-command) "checkgtk.c " (string #\`) "pkg-config --cflags gtk+-2.0" (string #\`))
		   "Something went wrong when trying to compile a gtk+-2.0 program."

		   (make-system2 (get-gcc-command) "checklrdf.c -llrdf")
		   "Could not find lrdf.h or liblrdf.so. Perphaps the liblrdf-devel package is missing?"
		   
		   (make-system2 (get-gcc-command) "checkalsa.c -lasound")
		   "Could not find alsa/asoundlib.h or libasound.so. (required for midi). Perphaps the alsa-lib-devel package is missing?"
		   
		   (make-system2 (get-gcc-command) "checklibsndfile.c -lsndfile")
		   "Could not find sndfile.h or libsndfile.so. Perphaps you are missing either the libsndfile or the libsndfile-devel package?"
		   
		   (make-system2 (get-gcc-command) "checklibsamplerate.c -lsamplerate")
		   "Could not find samplerate.h or libsamplerate.so. Perphaps you are missing the libsamplerate-devel package?"
		   
		   (make-system2 "bzip2 -dc snd-10.tar.bz2 |tar xv-")
		   "Something went wrong when unpacking Snd."
		   
		   (make-system2 "cd snd-10 ; patch -p1 <../changes.diff")
		   "Something went wrong when patching Snd"
		   
		   (make-system2 "cd snd-10 ; cp ../new_files/* .")
		   "Something went wrong when copying new files into snd-10"
		   
		   (make-system2 "cd snd-10 ; ./configure " configure-options " GUILE_CONFIG_path=" guile-bin-dir " ")
		   "Something went wrong when configuring Snd"

;;                   (make-system2 "echo '#undef HAVE_GTK_LINK_BUTTON_NEW' >>snd-10/mus-config.h")
;;                   "strange bug in build system"

;;                   (make-system2 "echo '#define HAVE_GTK_LINK_BUTTON_NEW 0' >>snd-10/mus-config.h")
;;                   "strange bug in build system 2"

;;                   (make-system2 "echo '#undef HAVE_GTK_LABEL_GET_LINE_WRAP_MODE' >>snd-10/mus-config.h")
;;                   "strange bug in build system 3"

;;                   (make-system2 "echo '#define HAVE_GTK_LABEL_GET_LINE_WRAP_MODE 0' >>snd-10/mus-config.h")
;;                   "strange bug in build system 4"

		   (make-system2 "cd snd-10 ; gcc ../checkconf.c")
		   "Snd not configured properly."
		   
		   (make-system2 "cd snd-10 ; make")
		   "Something went wrong when making Snd"

		   (make-system2 "chmod -R a+r *")
		   "Unable to set read-permission for all files."

		   ))



(define installdir (<-> prefix "snd-ls"))

(define (create-init.scm)
  (let ((fd (open-file (<-> installdir "/init.scm") "w")))
    (for-each (lambda (s)
		(display s fd)
		(newline fd))
	      (list
	       (<-> "(set! %load-path (cons \"" installdir "/snd-10\" %load-path))")
	       ""
	       "(set! (ladspa-dir) (if (getenv \"LADSPA_PATH\")"
	       "                       (getenv \"LADSPA_PATH\")"
	       "                       \"/usr/lib/ladspa\"))"
	       (<-> "(define snd-ls-version " (number->string snd-ls-version) ")")
	       "(use-modules (ice-9 stack-catch))"
	       ""
	       "(stack-catch #t"
	       "	     (lambda ()"
	       "               (if (access? (string-append (getenv \"HOME\") \"/.snd-ls\") R_OK)"
	       "                  (load  (string-append (getenv \"HOME\") \"/.snd-ls\"))"
	       "                  (load-from-path \"snd_conffile.scm\")))"
	       "	     (lambda args"
	       "	       (display args)(newline)"
	       "	       (newline)"
	       "	       (backtrace)"
	       "	       (newline)"
	       "	       (display \"ERROR! Snd-ls did not start correctly. Please report this bug to k.s.matheussen@notam02.no and bil@ccrma.stanford.edu\")(newline)"
	       "               (display \"(and please include the terminal output in the mail, Thanks.)\")"
	       "	       (newline)"
	       "	       (newline)"
	       "	       (exit)))"
	       ))
    (close fd)))


(define (create-startup-script)
  (let* ((exename (<-> prefix "bin/snd-ls"))
	 (fd (open-file exename "w")))
    (for-each (lambda (s)
		(display s fd)
		(newline fd))
	      (list
	       "#!/bin/sh"
	       (let ((guile-lib-dir (get-system-output (<-> guile-bin-dir "guile-config info libdir"))))
		 (if (string=? guile-lib-dir "/usr/lib")
		     ""
		     (<-> "export LD_LIBRARY_PATH=" guile-lib-dir ":$LD_LIBRARY_PATH")))
	       (<-> installdir "/snd-10/snd -noglob -noinit -l " installdir "/init.scm $@")))
    (close fd)
    (system (<-> "chmod a+rx " exename))))



(define installlist (list

		     (lambda () (system3 (<-> "mkdir -p " installdir)))
		     "Could not create install directory"

		     (lambda () (system3 (<-> "mkdir -p " prefix "bin")))
		     "Could not create binary directory"

		     (lambda () (system3 (<-> "cp -a snd-10 " installdir "/")))
		     "Could not copy files to install directory"
		     
		     (lambda () (create-init.scm))
		     "Something went wrong when trying to create init.scm"

		     (lambda () (create-startup-script))
		     "Something went wrong when trying to create bin/snd-ls"

		     ))


(define (build)
  (if (listop buildlist)
      (begin
	(newline)
	(display "Snd-ls build OK. Now run ./install as root")
	(newline))))

(define (install)
  (if (listop installlist)
      (begin
	(newline)
	(display "Snd-ls installed OK. Now run snd-ls to start Snd.")
	(newline))))

(define (uninstall)
  (system (<-> "rm " prefix "bin/snd-ls"))
  (system (<-> "rm -fr " installdir)))



(cond ((defined? 'build2)
       (build))
      ((defined? 'install)
       (install))
      ((defined? 'uninstall)
       (uninstall))
      (else "Hmm?"))




