NAME=AlphaBeta
VERSION=0.3

RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg

UP=stig@brautaset.org:code/files/
DMGURL=http://code.brautaset.org/files/$(DMG)
FRAMEWORK=/tmp/Frameworks/$(NAME).framework

_site: Docs/* Makefile
	rm -rf _site ; mkdir _site
	cp Docs/*.html Docs/*.css _site
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' _site/*
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' _site/*
	perl -pi -e 's{__CODE__}{http://code.brautaset.org}g' _site/*
	perl -pi -e 's{__URL__}{http://code.brautaset.org/$(NAME)}g' _site/*

site: _site

upload-site: _site
#	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK"
	rsync -ruv --delete _site/ --exclude files stig@brautaset.org:code/$(NAME)/

install: $(FRAMEWORK)

$(FRAMEWORK): *.m Makefile
	setCFBundleVersion.pl $(VERSION)
	-chmod -R +w .fwk ; rm -rf .fwk
	-chmod -R +w /tmp/Frameworks ; rm -rf /tmp/Frameworks
	-chmod -R +w /tmp/$(NAME).dst ; rm -rf /tmp/$(NAME).dst
	xcodebuild -target Tests
	xcodebuild -target $(NAME) install
	mkdir .fwk ; cp -rp $(FRAMEWORK) .fwk
	

$(DMG): $(FRAMEWORK) 
	-rm -rf $(DMG)
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder .fwk $(DMG)

dmg: $(DMG)

upload-dmg: $(DMG)
	curl --head $(DMGURL) 2>/dev/null | grep -q "404 Not Found" || false
	scp $(DMG) stig@brautaset.org:code/$(NAME)/files/$(DMG)

