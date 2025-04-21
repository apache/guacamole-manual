:::{warning}
If you will be configuring Guacamole to consider users' IP addresses, **it is
important to make sure that Guacamole is receiving correct IP address
information for all clients**.

If Guacamole is behind a reverse proxy, such as for SSL termination, the IP
addresses of all users will appear to be the IP address of the proxy unless
additional configuration steps are taken. **Be sure to follow [the
documentation for configuring forwarding of client IP
information](reverse-proxy)!**
:::
