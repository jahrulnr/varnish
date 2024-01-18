## sample `make clear path=/home`
clear:
	varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban "req.url == $(path)"

## sample `make purge path=/home`
purge:
	varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban "req.url ~ $(path)"
