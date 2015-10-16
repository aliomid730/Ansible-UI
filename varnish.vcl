# This is a basic VCL configuration file for varnish.  See the vcl(7)
# man page for details on VCL syntax and semantics.
#
# Default backend definition.  Set this to point to your content
# server.
#

# define backend
backend default {
    # host - just 127.0.0.1 usually for one machine setup
    .host = "127.0.0.1";
    # port - point varnish to what port your backend (webserver) is listening on
    .port = "8080";
}


# beggining of varnish request
sub vcl_recv {
      unset req.http.Accept-Encoding;
      set req.grace = 15s;
  # what files to cache (lookup) - just add if needed
  if (req.url ~ "(?i)\.(jpeg|jpg|png|gif|ico|webp|js|css|txt|pdf|gz|zip|lzma|bz2|tgz|tbz|html|htm)$") {
      return(lookup);
  }
}

# after retrieval from webserver
sub vcl_fetch {
    # what files to handle (the cached ones)  - just add if needed
      if (req.url ~ "(?i)\.(jpeg|jpg|png|gif|ico|webp|js|css|txt|pdf|gz|zip|lzma|bz2|tgz|tbz|html|htm)$") {
        # unset cookies in fetch
        unset beresp.http.Set-Cookie;
        # save cache for 1 hour
        set beresp.ttl = 1h;
        set beresp.grace = 30m;
  }
}

# how to deliver the output (manipulate output)
sub vcl_deliver {
    # if a varnish object hits, send X-cache header with HIT
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    # otherwise, send X-cache header with MISS
    } else {
        set resp.http.X-Cache = "MISS";
    }
}

sub vcl_error {
   # handle errors - could eg. be redirect on a specific status code
}

sub vcl_hash {
   #
}
