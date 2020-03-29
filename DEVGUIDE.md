# JellyFin Roku Development
###### The Ramblings of a Learning Man

#### The GIT Portion
1.  Install git
2.  Fork [PeerTubeRoku](https://github.com/jellyfin/PeerTubeRoku) repo to your own.  
3.  Clone your repo to local  
  3a.  ````git clone ssh://github.com/username/PeerTubeRoku.git````
4.  Create a branch for your fix  
  4a.  ````git checkout -B issue007````
5.  Set remote repo so you can stay current with other dev changes  
  5a.  ````git remote add upstream https://github.com/jellyfin/PeerTubeRoku.git````
6.  Fetch remote changes from other devs often  
  6a.  ````git fetch upstream````
7.  After making changes, push local branch to github repo  
  7a.  ````git add --all````  
  7b.  ````git commit -m "description of changes for commit"````  
  7c.  ````git push -u origin issue007````  

Congrats, you are now forked and ready to perform pull requests.  You can do so via [github webui](https://help.github.com/en/articles/creating-a-pull-request-from-a-fork)

#### The Roku Portion  
*  Put your Roku in [Dev Mode](https://blog.roku.com/developer/developer-setup-guide)
*  I use [Atom](https://atom.io).
*  I installed [roku-develop](https://atom.io/packages/roku-develop) for Atom.
*  Read the [Roku Developer Docs](https://developer.roku.com/docs/developer-program/getting-started)

###### Instructions:  
*  Install [ImageMagick](https://www.imagemagick.org/script/download.php).  
*  Install [wget](https://www.gnu.org/software/wget/).  
*  Install [make](https://www.gnu.org/software/make/).  
*  Install [nodejs and npm](https://www.npmjs.com/get-npm).  
*  Ensure npm requirements are installed:
````
cd /path/to/git/repo/  
npm install  
````  
*  Update branding images from PeerTube repo:  
 ````make get_images````  
  You should see something similar to the following:  
````
echo "Downloading SVG source files from https://raw.githubusercontent.com/Chocobozzz/PeerTube/develop/client/src/assets/images"
Downloading SVG source files from https://raw.githubusercontent.com/Chocobozzz/PeerTube/develop/client/src/assets/images
rm -f logo.svg* logo.svg*
--2020-02-06 11:26:47--  https://raw.githubusercontent.com/Chocobozzz/PeerTube/develop/client/src/assets/images/logo.svg
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.192.133, 151.101.0.133, 151.101.64.133, ...
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.192.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3153 (3.1K) [text/plain]
Saving to: ‘logo.svg’

logo.svg                   100%[========================================>]   3.08K  --.-KB/s    in 0s      

2020-02-06 11:26:47 (9.96 MB/s) - ‘logo.svg’ saved [3153/3153]

echo "Finished downloading SVG files"
Finished downloading SVG files
echo "Creating image files"
Creating image files
echo "Finished creating image files"
Finished creating image files
````  

#### Actual Build and Deploy to Roku:  
````  
cd /path/to/local/git/repo
make install  
````
