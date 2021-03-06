VERSION := latest

dirname = $(shell basename $(1))


lc = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))

IMAGE_BUILD = docker build --rm \
		-f ./Dockerfiles/$1.Dockerfile \
		--build-arg $2="$3" \
		-t $(call lc,$4):$(VERSION) \
		./Dockerfiles \
		&& \
		docker tag $(call lc,$4):$(VERSION) $(call lc,$4):latest

IMAGE_BUILD_2 = docker build --rm \
		-f ./Dockerfiles/$1.Dockerfile \
		--build-arg repo_url="$2" \
        --build-arg branch_or_tag="$3" \
		-t $(call lc,$4):$(VERSION) \
		. && \
		docker tag $(call lc,$4):$(VERSION) $(call lc,$4):latest

checkCompHost:
	@if [ "`docker image ls | awk '{ print $$1 }' | grep componenthost`" = "" ]; then echo "A componenthost image does not exist please first run 'make componentHost'"; exit 1; fi

checkDirectory:
	@if [ "`ls -A ./Dockerfiles/rhSharedLibrary/components/`" = ".gitignore"  ]; then echo "The ./Dockerfiles/rhSharedLibrary/components/ is empty please add shared library components"; exit 1; fi

checkCompsExist:
	@for i in ${CUSTOM}; do if [ ! -d "./Dockerfiles/rhSharedLibrary/components/$${i}" ]; then echo "$${i} does not exist!"; exit 1; fi; done

gnuradio:
	../gr-component_converter/converter/run.py ./Dockerfiles/tmpCustom/${GRC}.grc ./Dockerfiles/tmpCustom
	$(call IMAGE_BUILD,$@,gnu_asset,${GRC},${GRC})

custom:
	cp -rf ${CUSTOM} ./Dockerfiles/tmpCustom/
	$(call IMAGE_BUILD,$@,custom_asset,$(call dirname,$(CUSTOM)),$(call dirname,$(CUSTOM)))
	rm -rf ./Dockerfiles/tmpCustom/$(call dirname,$(CUSTOM))

rhAsset:
	$(call IMAGE_BUILD,$@,rh_asset,${ASSET},rh.${ASSET})

componentHost:
	$(call IMAGE_BUILD_2,$@,${repo_url},${branch_or_tag},rh.$@)

sharedCustom: checkCompHost checkDirectory checkCompsExist
	$(call IMAGE_BUILD,$@,shared_asset,${CUSTOM},sharedmakefile)
	docker tag sharedmakefile:$(VERSION) rh.componenthost:$(VERSION)
	docker tag sharedmakefile:latest rh.componenthost:latest
	docker image rm -f sharedmakefile

sharedRhAsset: checkCompHost
	$(call IMAGE_BUILD,$@,shared_asset,${ASSET},sharedmakefile)
	docker tag sharedmakefile:$(VERSION) rh.componenthost:$(VERSION)
	docker tag sharedmakefile:latest rh.componenthost:latest
	docker image rm -f sharedmakefile

clean:
	rm -rf ./Dockerfiles/tmpCustom/*
	rm -rf ./Dockerfiles/rhSharedLibrary/root/*
	rm -rf ./Dockerfiles/rhSharedLibrary/components/*
