###########
# include #   refresh.mk
###########

# to refresh a library on demand :

# 1) add this to GNUmakefile, after the include of standard.mk :
#        include SoftRelTools/refresh.mk
# 2) add a  .refresh file to directory containing GNUmakefile
# 3) update .refresh file to trigger a rebuild (in future)


# refresh.mk screams and aborts if 
#     $(staticlib_o_dir) or $(sharedlib_o_dir) have only slashes, 
#     to avoid removing all files under /
# It is ok for these to be absent, due to gmake clean

codegen: checkdirs 

ifdef STATICLIB

codegen: $(workdir)/.refresh.$(notdir $(STATICLIB))

$(workdir)/.refresh.$(notdir $(STATICLIB)): .refresh ;\
if [   -d  "$(staticlib_o_dir)" ] ;\
then  \
    if [ -n "`echo $(staticlib_o_dir) | tr -d /`" ] ;\
    then \
	echo                    "Refreshing $(notdir $(STATICLIB) )" ;\
	touch	        $(workdir)/.refresh.$(notdir $(STATICLIB)) ;\
	/bin/rm  -f	$(STATICLIB)	   ;\
	/bin/rm  -f	$(workdir)*.o	   ;\
	chmod  -R 755	$(staticlib_o_dir) ;\
	/bin/rm    -r	$(staticlib_o_dir) ;\
	/bin/mkdir -p	$(staticlib_o_dir) ;\
    else \
	echo "  " ;\
	echo " Catastrophic error in refresh.mk for $(STATICLIB) " ;\
	echo "     staticlib_o_dir is $(staticlib_o_dir) " ;\
	echo "  " ;\
    fi ;\
fi

endif #STATICLIB

ifdef SHAREDLIB

codegen: $(workdir)/.refresh.$(notdir $(SHAREDLIB))

$(workdir)/.refresh.$(notdir $(SHAREDLIB)): .refresh ;\
if [ -d "$(sharedlib_o_dir)" ] ;\
then \
    if [ -n "`echo $(sharedlib_o_dir) | tr -d /`" ] ;\
    then \
	echo                   "Refreshing $(notdir $(SHAREDLIB) )" ;\
	touch	       $(workdir)/.refresh.$(notdir $(SHAREDLIB)) ;\
	/bin/rm  -f    $(SHAREDLIB)	  ;\
	/bin/rm  -f    $(workdir)/*.o	  ;\
	chmod  -R 755  $(sharedlib_o_dir) ;\
	/bin/rm    -r  $(sharedlib_o_dir) ;\
	/bin/mkdir -p  $(sharedlib_o_dir) ;\
    else \
	echo "  " ;\
	echo " Catastrophic error in refresh.mk for $(SHAREDLIB) " ;\
	echo "     sharedlib_o_dir is $(sharedlib_o_dir) " ;\
	echo "  " ;\
    fi ;\
fi

endif #SHAREDLIB
