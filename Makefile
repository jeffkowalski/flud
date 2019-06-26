REMOTE_MACHINE=flud
REMOTE_USER=pi

all:

.PHONY: install uninstall purge remote-copy remote-install remote-uninstall remote-purge

install:
	PATH="/home/${REMOTE_USER}/.rbenv/shims:${PATH}" bundle install
	-sudo systemctl daemon-reload
	-sudo service flud stop
	sudo cp flud patch.rb /usr/sbin
	sudo chmod 0755 /usr/sbin/flud /usr/sbin/patch.rb
	sudo cp logrotate.d-flud /etc/logrotate.d/flud
	sudo chmod 0644 /etc/logrotate.d/flud
	sudo cp init.d-flud /etc/init.d/flud
	sudo chmod 0755 /etc/init.d/flud
	sudo mkdir -p /etc/flud
	sudo chmod 0755 /etc/flud
	-sudo cp client_secret.json /etc/flud/client_secret.json
	-sudo cp flud.yml /etc/flud/flud.yml
	-sudo chmod 0600 /etc/flud/client_secret.json
	-sudo chmod 0644 /etc/flud/flud.yml
	-sudo mkdir -p ~root/.credentials
	-sudo cp ~${REMOTE_USER}/.credentials/flud.yaml ~root/.credentials/flud.yaml
	-sudo chmod 0600 ~root/.credentials/flud.yaml
	sudo insserv --verbose flud
	-sudo systemctl daemon-reload
	sudo service flud start

uninstall:
	-sudo service flud stop
	-sudo insserv --verbose --remove flud
	-sudo rm -f /etc/init.d/flud
	-sudo rm -f /etc/logrotate.d/flud
	-sudo rm -f /usr/sbin/flud
	-sudo rm -f /var/log/flud.log*
	-sudo rm -f /var/run/flud.pid

purge: uninstall
	-sudo rm -f /etc/flud.yml
	-sudo rm -f ~root/.credentials/flud.yaml

remote-copy:
	( cd .. ; \
	  tar cvf - \
	    flud/dirtmon/listen.rb \
	    flud/dirtmon/Gemfile \
	    flud/client_secret.json \
	    flud/init.d-flud \
	    flud/logrotate.d-flud \
	    flud/flud \
            `test -f flud/flud.yml && echo flud/flud.yml` \
	    flud/patch.rb \
	    flud/Gemfile \
	    flud/Makefile \
	  | ssh $(REMOTE_USER)@$(REMOTE_MACHINE) tar xvf - )

remote-install: remote-copy
	ssh $(REMOTE_USER)@$(REMOTE_MACHINE) "cd ~/flud; make install"

remote-uninstall:
	ssh $(REMOTE_USER)@$(REMOTE_MACHINE) "cd ~/flud; make uninstall"

remote-purge:
	ssh $(REMOTE_USER)@$(REMOTE_MACHINE) "cd ~/flud; make purge"
