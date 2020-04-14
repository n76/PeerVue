**PeerVue - Frequently Asked Questions (FAQ)**

This FAQ will be updated to accommodate new information with respect to updates and changes.

**What is PeerVue?**

PeerVue is an “channel” (a.k.a. app) for a [Roku Media Streaming player](https://en.wikipedia.org/wiki/Roku#Roku_streaming_players). With it you can watch content being servered from a [PeerTube instance](https://joinpeertube.org/).

**How Do I Install It**
Roku provides three ways that a channel can be installed:

1. Through their channel store.
2. Via a private/uncertified channel code.
3. By setting the device into “developer mode” and side loading.

We support adding PeerVue via side loading and with a private channel code.

**What is the private channel code?**

The code is [PEERVUE](https://my.roku.com/add/PEERVUE).

**The Private Channel Code Doesn’t Work**

There seems to be some oddness about this. I have tried to allow the code to work in all regions. But apparently Roku blocks private channels in some regions.

If you are unable to add the private channel then please submit a GitHub issue with your Roku region information.

**How does Roku determine my region?**

The region is associated with your account and is set when you created your account based on the IP address used at that time.

**Why not have it in the Roku channel Store?**

Short answer is we cannot.

The longer answer is that Roku’s certification and developer’s terms are incompatible with a generic channel accessing a server not controlled by the channel author. Since we have little control over what PeerTube instance you decide to connect to we cannot:
* Guarantee the videos meet Roku’s technical quality standards (resolution, closed captioning, speed of loading, etc.)
* Guarantee the videos meet Roku’s content standards (family friendly, honoring copyrights, etc.)

The only way we could meet Roku’s requirements would be to lock this channel to a single PeerTube instance controlled by the PeerVue author, tightly control the videos on that server and probably not have it federated with any other instance.

**Why I can’t just type the URL in the PeerTube instance URL?**

My reading of the Roku developer agreement forbids a channel or app from allowing the end user to type in a URL.

**The PeerTube instance I want to connect to is not listed**

Either it is new and I've not rebuilt the list (create an issue on GitHub to get my attention).

Or that is an instance that I’ve decided not so support. If you don’t like it, you can fork this project and side load your own channel app.

**When I connect to an instance I don’t see any videos**

It could be the server is down. Or it could be that there is an issue with the definition for that server in PeerVue. Submit an issue on GitHub against PeerVue to notify me of the problem and name of instance and I will investigate it.
