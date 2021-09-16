
$(workdir)%.tab.h $(workdir)%.tab.c: %.y
        echo "<**yacc**> $(@F)"
        cd $(workdir); $(YACC) -d $(curdir)/$<)

include SoftRelTools/arch_spec_yacc.mk
