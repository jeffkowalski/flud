REMOTE_MACHINE=flud
REMOTE_USER=pi

all:

.PHONY: install uninstall purge remote-install remote-uninstall remote-purge

install:
	bundle install
	-service flud stop
	cp flud patch.rb /usr/sbin
	chmod 0755 /usr/sbin/flud /usr/sbin/patch.rb
	cp logrotate.d-flud /etc/logrotate.d/flud
	chmod 0644 /etc/logrotate.d/flud
	cp init.d-flud /etc/init.d/flud
	chmod 0755 /etc/init.d/flud
	-cp flud.yml /etc/flud.yml
	-chmod 0644 /etc/flud.yml
	-mkdir -d ~root/.credentials
	-cp ~${REMOTE_USER}/.credentials/flud.yaml /.credentials/flud.yaml
	-chmod 0600 /.credentials/flud.yaml
	insserv --verbose flud
	service flud start

uninstall:
	-service flud stop
	-insserv --verbose --remove flud
	-rm -f /etc/init.d/flud
	-rm -f /etc/logrotate.d/flud
	-rm -f /usr/sbin/flud
	-rm -f /var/log/flud.log*
	-rm -f /var/run/flud.pid

purge: uninstall
	-rm -f /etc/flud.yml
	-rm -f /.credentials/flud.yaml

remote-install:
	( cd .. ; \
	  tar cvf - \
	    flud/client_secret.json \
	    flud/init.d-flud \
	    flud/logrotate.d-flud \
	    flud/flud \
            `test -f flud/flud.yml && echo flud/flud.yml` \
	    flud/patch.rb \
	    flud/Gemfile \
	    flud/Makefile \
	  | ssh $(REMOTE_USER)@$(REMOTE_MACHINE) tar xvf - )
	ssh $(REMOTE_USER)@$(REMOTE_MACHINE) "cd ~/flud; sudo make install"

remote-uninstall:
	ssh $(REMOTE_USER)@$(REMOTE_MACHINE) "cd ~/flud; sudo make uninstall"

remote-purge:
	ssh $(REMOTE_USER)@$(REMOTE_MACHINE) "cd ~/flud; sudo make purge"
