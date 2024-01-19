vcl 4.0;
import directors;
import std;

backend backend {
  .host = "--host--";
  .port = "--port--";
  .connect_timeout = 900s;
  .first_byte_timeout = 900s;
  .between_bytes_timeout = 900s;
}

sub vcl_init {
  new apache = directors.round_robin();
  apache.add_backend(backend);
}

acl purge {
  "172.0.0.0/8";
  "--host--";
}

sub vcl_recv {
  if (req.url ~ "^/healt$" ){
    return(synth(200, "Varnish Heathly"));
  }

  if (req.http.url ~ "^/auth"
   || req.http.url ~ "^/backend"
  ) {
    return (pass);
  }

  if (req.method == "BAN") {
    if (!client.ip ~ purge) {
      return (synth(405, "Not allowed."));
    }
    if (req.http.Purge) {
      ban("req.url ~ " + req.http.Purge);
      return (synth(200, "Ban added."));
    }else {
      ban("req.url == " + req.url);
      return (synth(200, "Ban added."));
    }
  }
  if (req.method != "GET" && req.method != "HEAD") {
    return (pass);
  }

}

sub vcl_backend_response {
  if ( bereq.url ~ "^/auth" 
    || bereq.url ~ "^/backend"
  ) {
    return (pass);
  }

  if ( beresp.status == 500
    || beresp.status == 503
    || beresp.status == 502
    || beresp.status == 504
  ) {
    return (retry);
  }

  if (beresp.http.X-Cache == "1"){
    unset beresp.http.Set-Cookie;
  }

  set beresp.http.X-Url = bereq.url;
  set beresp.http.X-Host = bereq.http.host;
  set beresp.grace = 2h;
  set beresp.ttl = 2w;

  if (bereq.url ~ "\.(js|css)$"){
    if (beresp.status == 404){
      set beresp.ttl = 3s;
    }
  }
}

sub vcl_deliver {
  unset resp.http.X-Url;
  unset resp.http.X-Host;
  unset resp.http.X-Powered-By;
  unset resp.http.Server;

  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }
  set resp.http.X-Frame-Options = "SAMEORIGIN";
}