NAME=AlphaBeta
VERSION=0.3

RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg

UP=stig@brautaset.org:code/files/
DMGURL=http://code.brautaset.org/files/$(DMG)

site:
	rm -rf build/html
	doxygen 
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' build/html/*.html
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' build/html/*.html

upload-site: site
	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK" 
	rsync -ruv --delete build/html/ stig@brautaset.org:code/$(NAME)/

dmg: 	
	rm -rf build/tmp/ $(DMG)
	setCFBundleVersion.pl $(VERSION)
	xcodebuild -target $(NAME) clean
	xcodebuild -target Tests
	xcodebuild -target $(NAME) install
	mkdir -p build/tmp
	mv /tmp/Frameworks/$(NAME).framework build/tmp
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder build/tmp $(DMG)

upload-dmg: dmg
	curl --head $(DMGURL) 2>/dev/null | grep -q "200 OK" && echo "$(DMG) already uploaded" && false
	scp $(DMG) $(UP)

