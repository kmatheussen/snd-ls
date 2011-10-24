
#include "snd-10/mus-config.h"

#ifndef MUS_JACK
#  error "Jack not found."
#endif
#ifndef HAVE_FFTW3
#  error "fftw3 not found."
#endif
#ifndef HAVE_GUILE
#  error "guile not found."
#endif
#ifndef HAVE_EXTENSION_LANGUAGE
#  error "Extension language not found."
#endif
#ifndef USE_GTK
#  error "Gtk not found."
#endif
#ifdef USE_MOTIF
#  error "Motif is not supported."
#endif
#ifndef HAVE_LADSPA
#  error "Ladspa not found."
#endif
#ifndef HAVE_STATIC_XM
#  error "Does not have static xg."
#endif
#ifndef WITH_RUN
#  error "Not configured with \"WITH_RUN\". To old Guile?"
#endif
#ifndef USE_SND
# error "Not configured with \"USE_SND\". Thats strange."
#endif
#ifndef WITH_RT
# error "Rollendurchmesserzeitsammler not found."
#endif

int main(void){
  return 0;
}
