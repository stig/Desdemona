NAME=Desdemona
VERSION=0.3.2

INSTALLPATH=/tmp/$(NAME).dst$(HOME)/Applications/$(NAME).app
RELEASENAME=$(NAME)_$(VERSION)
DMG=$(RELEASENAME).dmg
DMGURL=http://code.brautaset.org/$(NAME)/files/$(DMG)
SCPUP=stig@brautaset.org:code/$(NAME)/files/$(DMG)

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


site: Site/style.css Site/index.html Site/appcast.xml
	rm -rf _site; cp -r Site _site
	perl -pi -e 's{__DMGURL__}{$(DMGURL)}g' _site/*.html
	perl -pi -e 's{__VERSION__}{$(VERSION)}g' _site/*.html

upload-site: site
	rsync -e ssh -ruv --delete _site/ --exclude files stig@brautaset.org:code/$(NAME)/

install: *.m
	setCFBundleVersion.pl $(VERSION)
	xcodebuild -target $(NAME) install

$(DMG): dmg
dmg: install
	rm -rf $(DMG)
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder $(INSTALLPATH) $(DMG)

upload-dmg: 
	curl --head $(URL) 2>/dev/null | grep -q "200 OK" && echo "$(DMG) already uploaded"
	scp $(DMG) $(SCPUP)

