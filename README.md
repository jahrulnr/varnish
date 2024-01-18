## Varnish

### Docker run
```terminal
make up
```

### Invalidate cache
#### cURL
Invalidate bulk cache
```bash
curl -X BAN -H 'Purge: /home' http://vsh-bangunsoft:8123
```
Invalidate single cache
```bash
curl -X BAN http://vsh-bangunsoft:8123/home
```

#### Terminal
```bash
docker exec -it vsh-bangunsoft bash
varnishadm -T 127.0.0.1:6082 -S /etc/varnish/secret ban "req.url ~ /home"
```