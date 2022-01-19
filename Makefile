build:
	buildah bud --layers --tag openldap:latest .

run:
	# password is `test`
	podman run -it --rm \
		--env ADMIN_PASSWORD="{SSHA}762HEu27M2eG/T0kTjBS+tibMH434g2T" \
		--env LDAP_SUFFIX="dc=example,dc=ruck,dc=io" \
		--env LDAP_PORT="1389" \
		--env DEBUG=0 \
		--publish 1389:1389 \
		--mount "type=bind,src=${PWD}/sample,target=/ldifs/object" \
		--name openldap \
		openldap:latest

test:
	ldapsearch -H ldap://localhost:1389 -D "cn=admin,dc=example,dc=ruck,dc=io" -w test -x -b "dc=example,dc=ruck,dc=io"
