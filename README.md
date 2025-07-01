## Quiche

Assuming Docker Desktop is running, the Quiche server can be started using:
```bat
python setup_server.py
```



## Chrome for HTTP/3 Testing

This project assumes you have **Chrome Canary** (SxS) installed. You can get it from:

https://www.google.com/chrome/canary/

> [!NOTE]
> You can use any other HTTP/3 clients, Chrome Canary is just easy because it allows you to keep normal Chrome running.

Once installed, the launcher script (`launch-chrome.ps1`) should work out of the box.



The `launch-chrome.ps1` file includes a flag like this:

```
--ignore-certificate-errors-spki-list=MCFtYhgL/+T4kkcV64TQTTAw0Q5Gq2360530xEr9lFs=
```

If you're wondering what this is: it's a base64-encoded SHA-256 hash of the certificate's public key (also called an SPKI fingerprint). Chrome uses it to allow self-signed certificates when testing QUIC (HTTP/3). Without it, Chrome may reject the connection even if other certificate warnings are ignored.

You can generate this value from the certificate you're using with the following OpenSSL command (run in WSL or Linux shell):

```bash
openssl x509 -in apps/src/bin/cert.crt -noout -pubkey \
| openssl pkey -pubin -outform DER \
| openssl dgst -sha256 -binary \
| base64
```
If the cert ever changes (or you generate a new one), you'll need to rerun this command and update the value in your `chrome.bat`.
