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

The code is [Z6RVGKD](https://my.roku.com/add/Z6RVGKD).

**The Private Channel Code Doesn’t Work**

There seems to be some oddness about this. I have tried to allow the code to work in all regions. But apparently Roku blocks private channels in some regions.

If you are unable to add the private channel then please submit a GitHub issue with your Roku region information.

**How does Roku determine my region?**

The region is associated with your account and is set when you created your account based on the IP address used at that time.

**Why not have it in the Roku channel Store?**

Short answer is we cannot.

The longer answer is that Roku’s certification and developer’s terms are incompatible with a generic channel accessing an arbitrary server. Since we have no control over what PeerTube instance you decide to connect to we cannot:
1. Guarantee that the time from when PeerVue start until all content is displayed and available meets Roku’s standards. The instance server might not be provisioned properly for the load it is carrying.
2. Guarantee that the time from when play is pressed until the video starts meets Roku’s standards. Again, server might be improperly provisioned for the load.
3. Guarantee that the video quality meets Roku’s standards. The content creator may have only uploaded a low resolution copy or the PeerTube instance administrator may not have enabled transcoding to resolutions usable by Roku.
4. Guarantee that all videos can play. Again, transcoding settings by the administrator may not have created a version that is playable by all Roku devices.
5. Guarantee that all content available for viewing meets Roku’s standards with respect to “adult content”. There is only a loose correlation between Roku’s standards and PeerTube’s “not suitable for work” (NSFW) tagging. And tagging a video as NSFW is on an honor system so PeerVue cannot be guaranteed to follow Roku’s requirements.
