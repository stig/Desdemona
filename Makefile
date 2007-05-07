NAME=Desdemona
VERSION=0.3.1

INSTALLPATH=/tmp/$(NAME).dst/Users/stig/Applications/$(NAME).app
RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg
URL=http://code.brautaset.org/files/$(DMG)
SCPUP=stig@brautaset.org:code/files/$(DMG)

enclosure: $(DMG)
	@echo    "<pubDate>`date +"%a, %b %e %Y %H:%M:%S %Z"`</pubDate>";
	@echo    "<enclosure url='$(URL)' "
	@echo -n "    length='`stat $(DMG) | cut -d" "  -f8`'"
	@echo    ' type="application/octet-stream"/>'


site: Site/index.html Site/appcast.xml
	rm -rf _site; cp -r Site _site
	perl -pi -e 's{\@URL\@}{$(URL)}g' _site/*.html
	perl -pi -e 's{\@VERSION\@}{$(VERSION)}g' _site/*.html

upload-site: site
	rsync -e ssh -ruv --delete _site/ stig@brautaset.org:code/$(NAME)/

install: *.m
	setCFBundleVersion.pl $(VERSION)
	xcodebuild -target $(NAME) install

$(DMG): dmg
dmg: install
	rm -rf $(DMG)
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder $(INSTALLPATH) $(DMG)

upload-dmg: dmg
	curl --head $(URL) 2>/dev/null | grep -q "200 OK" && echo "$(DMG) already uploaded" || scp $(DMG) $(SCPUP)

