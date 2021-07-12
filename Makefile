.PHONY: clean zcad checkpcp checkos

ZCVERSION:=$(shell git describe --tags)

OSDETECT:=
ifeq ($(OS),Windows_NT)
	OSDETECT:=WIN32
else
	UNAME_S:=$(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSDETECT=LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSDETECT:=OSX
	endif
endif

CPUDETECT:=
ifeq ($(OS),Windows_NT)
	ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		CPUDETECT=AMD64
	endif
	ifeq ($(PROCESSOR_ARCHITECTURE),x86)
		CPUDETECT=IA32
	endif
else
	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		CPUDETECT=AMD64
	endif
		ifneq ($(filter %86,$(UNAME_P)),)
	CPUDETECT+=IA32
		endif
	ifneq ($(filter arm%,$(UNAME_P)),)
		CPUDETECT=ARM
	endif
endif

PATHDELIM:=
ifeq ($(OSDETECT),WIN32)
	PATHDELIM =\\
else
	PATHDELIM =/
endif


PCP:=
ifeq ($(OSDETECT),WIN32)
	PCP =$(LOCALAPPDATA)\lazarus
else
	ifeq ($(OSDETECT),LINUX)
		PCP =~/.lazarus
	else
		ifeq ($(OSDETECT),OSX)
			PCP =~/.lazarus
		else
			PCP =~/.lazarus
		endif

	endif
endif

LP:=
ifeq ($(OSDETECT),WIN32)
	LP =C:\lazarus$(PATHDELIM)
else
	ifeq ($(OSDETECT),LINUX)
		PCP =~/lazarus/
	else
		ifeq ($(OSDETECT),OSX)
			PCP =~/lazarus/
		else
			PCP =~/lazarus/
		endif

	endif
endif

checkallvars: checkvars
	@echo OSDETECT=$(OSDETECT)
	@echo CPUDETECT=$(CPUDETECT)

checkvars:
	@echo PCP=$(PCP) (Lazarus Primary Config Path)
	@echo LP=$(LP) (Lazarus path)

clean:
	rm -rf cad_source/autogenerated/*
	rm -r cad_source/autogenerated
	rm -rf cad/*
	rm -r cad
	rm -rf lib/*

zcadenv: checkvars
	mkdir cad
	mkdir $(subst /,$(PATHDELIM),cad_source/autogenerated)
	cp -r environment/runtimefiles/common/* cad
	cp -r environment/runtimefiles/zcad/* cad
	echo create_file>cad_source/autogenerated/buildmode.inc
	rm -r cad_source/autogenerated/buildmode.inc
	echo {DEFINE ELECTROTECH}>cad_source/autogenerated/buildmode.inc

zcadelectrotechenv: checkvars
	mkdir cad
	mkdir $(subst /,$(PATHDELIM),cad_source/autogenerated)
	cp -r environment/runtimefiles/common/* cad
	cp -r environment/runtimefiles/zcadelectrotech/* cad
	echo create_file>cad_source/autogenerated/buildmode.inc
	rm -r cad_source/autogenerated/buildmode.inc
	echo {$$DEFINE ELECTROTECH}>cad_source/autogenerated/buildmode.inc
version:
	@echo ZCAD Version: $(ZCVERSION)
	@echo '$(ZCVERSION)' > cad_source/zcadversion.inc
	
zcad: checkvars version
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) cad_source/utils/typeexporter.lpi
	environment/typeexporter/typeexporter pathprefix=cad_source/ outputfile=cad/rtl/system.pas processfiles=environment/typeexporter/zcad.files
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) cad_source/zcad.lpi

zcadelectrotech: checkvars version
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) cad_source/utils/typeexporter.lpi
	environment/typeexporter/typeexporter pathprefix=cad_source/ outputfile=cad/rtl/system.pas processfiles=environment/typeexporter/zcad.files;environment/typeexporter/zcadelectrotech.files
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) cad_source/zcad.lpi

installpkgstolaz: checkvars
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\other\AGraphLaz\lazarus\ag_graph.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\other\AGraphLaz\lazarus\ag_math.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\other\AGraphLaz\lazarus\ag_vectors.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\other\uniqueinstance\uniqueinstance_package.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\other\laz.virtualtreeview_package\laz.virtualtreeview_package.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zebase\zebase.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zcontainers\zcontainers.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zcontrols\zcontrols.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zmacros\zmacros.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zmath\zmath.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zobjectinspector\zobjectinspector.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zscriptbase\zscriptbase.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zscript\zscript.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\ztoolbars\ztoolbars.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) --add-package cad_source\components\zundostack\zundostack.lpk
	$(LP)$(PATHDELIM)lazbuild --pcp=$(PCP) -B -r --build-ide=