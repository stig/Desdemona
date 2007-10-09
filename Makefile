NAME=Desdemona
VERSION=0.4.1

INSTALLEDAPP=/tmp/$(NAME).dst$(HOME)/Applications/$(NAME).app
RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg
DMGURL=http://code.brautaset.org/$(NAME)/files/$(DMG)


enclosure: $(DMG)
	@echo    "<item>"
	@echo 	 "    <title>$(NAME) $(VERSION)</title>"
	@echo 	 "    <description><![CDATA["
	@echo 	 "    ]]></description>"
	@echo    "    <pubDate>`date +"%a, %b %e %Y %H:%M:%S %Z"`</pubDate>"
	@echo    "    <enclosure url='$(DMGURL)' "
	@echo -n "        length='`stat $(DMG) | cut -d" "  -f8`'"
	@echo    ' type="application/octet-stream"/>'
	@echo 	 "</item>"

_site: Site/* Makefile
	rm -rf _site; cp -r Site _site
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' _site/*
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' _site/*

site: _site

upload-site: _site
	rsync -e ssh -ruv --delete _site/ --exclude files stig@brautaset.org:code/$(NAME)/


$(INSTALLEDAPP): *.m vendor/*/*.m Makefile
	setCFBundleVersion.pl $(VERSION)
	-chmod -R +w /tmp/Frameworks ; rm -rf /tmp/Frameworks
	-chmod -R +w /tmp/$(NAME).dst ; rm -rf /tmp/$(NAME).dst
	xcodebuild -target $(NAME) clean install

install: $(INSTALLEDAPP)

$(DMG): $(INSTALLEDAPP) 
	-rm -rf $(DMG)
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder $(INSTALLEDAPP) $(DMG)

dmg: $(DMG)

upload-dmg: $(DMG)
	curl --head $(DMGURL) 2>/dev/null | grep -q "404 Not Found" || false
	scp $(DMG) stig@brautaset.org:code/$(NAME)/files/$(DMG)

