RESTORECON := $(shell command -v restorecon 2> /dev/null)

all: host1_server_certificate.pem host1_server_key.pem host2_server_certificate.pem host2_server_key.pem clientcert.pem
	@echo "Installation instructions:"
	@echo
	@echo "CA:"
	@echo "	make install-ca"
	@echo
	@echo "Destop:"
	@echo "	make install-client"
	@echo
	@echo "Server 1:"
	@echo "	mkdir -p /etc/pki/libvirt/private"
	@echo "	chmod 755 /etc/pki/libvirt"
	@echo "	chmod 750 /etc/pki/libvirt/private"
	@echo "	mv $(word 1,$^) /etc/pki/libvirt/servercert.pem"
	@echo "	mv $(word 2,$^) /etc/pki/libvirt/private/serverkey.pem"
	@echo "	chgrp qemu /etc/pki/libvirt /etc/pki/libvirt/servercert.pem /etc/pki/libvirt/private /etc/pki/libvirt/private/serverkey.pem"
	@echo "	chmod 440 /etc/pki/libvirt/servercert.pem /etc/pki/libvirt/private/serverkey.pem"
	@echo "	restorecon -R /etc/pki/libvirt /etc/pki/libvirt/private"
	@echo
	@echo "Server 2:"
	@echo "	mkdir -p /etc/pki/libvirt/private"
	@echo "	chmod 755 /etc/pki/libvirt"
	@echo "	chmod 750 /etc/pki/libvirt/private"
	@echo "	mv $(word 3,$^) /etc/pki/libvirt/servercert.pem"
	@echo "	mv $(word 4,$^) /etc/pki/libvirt/private/serverkey.pem"
	@echo "	chgrp qemu /etc/pki/libvirt /etc/pki/libvirt/servercert.pem /etc/pki/libvirt/private /etc/pki/libvirt/private/serverkey.pem"
	@echo "	chmod 440 /etc/pki/libvirt/servercert.pem /etc/pki/libvirt/private/serverkey.pem"
	@echo "	restorecon -R /etc/pki/libvirt /etc/pki/libvirt/private"

certificate_authority_key.pem:
	(umask 277 && certtool --generate-privkey > certificate_authority_key.pem)

cacert.pem: certificate_authority_key.pem
	certtool \
		--generate-self-signed \
		--template certificate_authority_template.info \
		--load-privkey $< \
		--outfile $@

.PHONY: install-ca
install-ca: cacert.pem
	@mkdir -p /etc/pki/CA
	install -m0444 $< /etc/pki/CA/cacert.pem
ifdef RESTORECON
	restorecon /etc/pki/CA/cacert.pem
endif


host1_server_key.pem:
	(umask 277 && certtool --generate-privkey > $@)

host1_server_certificate.pem: host1_server_key.pem cacert.pem certificate_authority_key.pem
	certtool \
		--generate-certificate \
		--template host1_server_template.info \
		--load-privkey $< \
		--load-ca-certificate $(word 2,$^) \
		--load-ca-privkey $(word 3,$^) \
		--outfile $@


host2_server_key.pem:
	(umask 277 && certtool --generate-privkey > $@)

host2_server_certificate.pem: host2_server_key.pem cacert.pem certificate_authority_key.pem
	certtool \
		--generate-certificate \
		--template host1_server_template.info \
		--load-privkey $< \
		--load-ca-certificate $(word 2,$^) \
		--load-ca-privkey $(word 3,$^) \
		--outfile $@


clientkey.pem:
	(umask 277 && certtool --generate-privkey > $@)

clientcert.pem: clientkey.pem cacert.pem certificate_authority_key.pem
	certtool \
		--generate-certificate \
		--template client_template.info \
		--load-privkey $< \
		--load-ca-certificate $(word 2,$^) \
		--load-ca-privkey $(word 3,$^) \
		--outfile $@

.PHONY:install-client
install-client: clientcert.pem clientkey.pem
	@mkdir -p /etc/pki/libvirt/private
	install -m0400 $< /etc/pki/libvirt/
	install -m0400 $(word 2,$^) /etc/pki/libvirt/private
ifdef RESTORECON
	restorecon /etc/pki/libvirt/clientcert.pem /etc/pki/libvirt/private/clientkey.pem
endif
