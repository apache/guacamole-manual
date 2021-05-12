FAQ
===

**Q:** Where does the name "Guacamole" come from?

**A:** The name was chosen arbitrarily from a random utterance in a
conversation with a member of the project.

When the project reached the point where it was growing out of the
proof-of-concept phase, and needed a real home on the internet, we needed to
think of a name to register the project under.

Several acronyms were toyed with and discarded. We tried anagrams, but all were
too wordy and complex. We considered naming the project after a fish or an
animal, and after suggesting the guanaco, James Muehlner, a developer of the
project, suggested (randomly): "guacamole".

The name had a nice ring, we weren't embarrassed to use it, and it stuck.

**Q:** What does "clientless" mean?

**A:** The term "clientless" means that no specific client is needed. A
Guacamole user needs only have an HTML5 web browser installed, which is
exceedingly common; virtually all modern computers and mobile devices have such
a browser installed by default.

In this sense, Guacamole is "clientless" in that it does not require any
additional software to be installed beyond what is considered standard for any
computer.

**Q:** Does Guacamole use WebSocket?

**A:** Guacamole uses either WebSocket or plain HTTP, whichever is supported by
both the browser and your servlet container. If WebSocket cannot be used for
any reason, Guacamole will fall back to using HTTP.

Historically, Guacamole had no WebSocket support at all. This was due to a lack
of browser support and lack of a true standard. Overall, it didn't matter as
there really wasn't any need: the tunnel used by Guacamole when WebSocket is
not available is largely equivalent to WebSocket in terms of efficiency and
latency, and is more compatible with proxies and existing browsers.

**Q:** I have Tomcat (or some other servlet container) set up behind a proxy
(like mod_proxy) and cannot connect to Guacamole. Why? How do I solve this?

**A:** You need to enable automatic flushing of the proxy's buffer as it
receives packets.

Most proxies, including mod_proxy, buffer data received from the server, and
will not flush this data in real-time. Each proxy has an option to force
flushing of each packet automatically, as this is necessary for streaming
applications like Guacamole, but this is usually not enabled by default.

Because Guacamole depends on streaming to function, a proxy configured to not
automatically flush packets will disrupt the stream to the point that the
connection seems unreasonably slow, or just fails to establish altogether.

In the case of mod_proxy, this option is `flushpackets=on`.

**Q:** I connect to the internet through a web proxy, and cannot connect to
Guacamole. I cannot reconfigure the proxy. How do I solve this?

**A:** You need to enable automatic flushing of your proxy's buffer to avoid
disrupting the stream used by Guacamole.

If you cannot change the settings of your proxy, using HTTPS instead of HTTP
should solve the problem. Proxies are required to stream HTTPS because of the
nature of SSL. Using HTTPS will allow Guacamole traffic to stream through
proxies unencumbered, even if you cannot access the proxy settings directly.

**Q:** Can I buy special licensing of the Guacamole code base, such that I can
use it in my own product, without providing the source to my users, without
contributing back, and without acknowledging the project?

**A:** Usually, no. Previous requests for such licensing have been very
one-sided and there would be no direct or indirect benefit to the community and
the project. That said, we handle requests for licensing on a case-by-case
basis. In general, any special licensing has to somehow provide for the
community and the open-source project.

**Q:** Can I pay for custom Guacamole work, or for help integrating Guacamole
into my product, if the open source nature and licenses are preserved?

**A:** Yes. We love to be paid to work on Guacamole, especially if that work
remains open source.

**Q:** How can I contribute to the project?

**A:** If you are a programmer and want to contribute code, Guacamole is
open-source and you are welcome to do so! Just send us your patches.  There is
no guarantee that your patch will be added to the upstream source, and all
changes are carefully reviewed.

If you are not a programmer, but want to help out, feel free to look through
the documentation or try installing Guacamole and test it out.  General
editing, documentation contributions, and testing are always helpful.

**Q:** How can I become an official member of the project?

**A:** The short answer is: "by being asked."

People are only added as official members of the Guacamole project after their
work has been proven. This usually means you will have contributed code in the
form of patches before, or we know you from extensive testing work, or you
frequently help with documentation, and we are impressed enough that we want
you as part of the project.

All that said, you do not need to be a member of the project to help out. Feel
free to contribute anything.

**Q:** I think I've found a bug. How do I report it?

**A:** The project tracks in-progress tasks and bugs via the JIRA instance
hosted by the Apache Software Foundation:

<https://issues.apache.org/jira/browse/GUACAMOLE/>

All bugs should be reported there as new issues. This is also where you would
request a new feature. If the bug you found is security-related, we would
prefer to be contacted personally via email, such that the bug can be fixed
before becoming dangerously widely known.

**Q:** I need help! Where can I find some?

**A:** If you would like help with Apache Guacamole, or wish to help others, we
highly recommend sending an email to the one of the project’s [mailing
lists](http://guacamole.apache.org/support/#mailing-lists). *You will need to
subscribe prior to sending email to any list.* All mailing lists are actively
filtered for spam, and any email not originating from a subscriber will bounce.

There are two primary mailing lists:

user@guacamole.apache.org
: The user list is intended for general questions and discussions which
  do not necessarily pertain to development. This list replaces the old
  [SourceForge forums](https://sourceforge.net/p/guacamole/discussion/) used by
  Guacamole prior to its acceptance into the Apache Software Foundation.

  *If you're not sure which mailing list to use, the user list is probably the
  correct choice.*

dev@guacamole.apache.org
: The development list is for development-related discussion involving people
  who are contributors to the Apache Guacamole project (or who wish to become
  contributors).

