# utun

## Preparation

Create system user for running services:

```
(root)# useradd -U -m -r -s /usr/bin/nologin utun
```

-U, --user-group\
-m, --create-home\
-r, --system\
-s, --shell

Add remote server IPs to local server's `/etc/hosts` and `/usr/local/etc/utun.nft`.

## Dependencies

[nftables](https://wiki.nftables.org/)
, [smartdns](https://github.com/pymumu/smartdns)
, [go-gost/gost](https://github.com/go-gost/gost)
, [klzgrad/naiveproxy](https://github.com/klzgrad/naiveproxy)
, [17mon/china_ip_list](https://github.com/17mon/china_ip_list)
, [xjasonlyu/tun2socks](https://github.com/xjasonlyu/tun2socks)
