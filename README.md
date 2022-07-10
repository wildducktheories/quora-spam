# NAME

quora-spam - a tool for dealing with Quora upvote spam, one notification at a time

# SYNOPSIS

	pbpaste | quora-spam har save # Mac
	quora-spam har save < saved.har # on platforms that don't have pbpaste
	quora-spam login
	quora-spam loop process sweet-hot-girls

# DESCRIPTION

In July 2022, a commercial spammer started generating large amounts of quora "upvote" spam that resulted in Quora authors being subjected to 10s of notifications each day containing upvotes from spammy profiles that contain deceptive "sweethotgirls" links that presumably link to a porn site or the promise of a porn site. It is unknown if the resources referenced by these links also contain malware, but based on the deceptive nature of the links themselves it is best to assume that they do.

The volume of such notifications makes reporting each and everyone of them quite tedious if done manually.

I decided to automate the process of reporting this spam by reverse-engineering the Quora API calls required to identify, report mute and block spammy upvotes thereby making my life more pleasant.

I am offering the tool to others who are annoyed by such spam, would like to report it, but don't appreciate hassle of doing so.

# INSTALLATION (MacOS, Linux)

Running directly from a clone of the GitHub repo is probably the easiest way:

	mkdir -p ~/git/wildducktheories &&
	cd ~/git/wildducktheories &&
	git clone git@github.com:wildducktheories/quora-spam.git quora-spam &&
	cd quora-spam

If you want to run the quora-spam script locally, you should run this command to use brew to install the necessary pre-requisites.

	./quora-spam install pre-reqs && make

# INSTALLATION (Windows)

If you only have a Windows machine, the easiest way to use this is to install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/) and download the docker image.

	docker pull wildducktheories/quora-spam

# RUNNING (Mac, Linux)

	quora-spam shell # locally
	docker-compose run quora-spam shell #inside docker

# RUNNING (Windows - Docker)

Use the public docker image:

	docker run -it \
		-rm \
		-v %CD%:/home/quora-spam/host \
		-v %UserProfile%\.quora-spam:/home/quora-spam/.quora-spam \
		wildducktheories/quora-spam shell

If you are able to clone the git repo and install docker-compose, you can instead run:

	docker-compose run shell

If you want to run the build environment inside docker, you need to run as the root user in a privileged docker container, so:

	docker run -it \
		-rm \
		-v %CD%:/home/quora-spam/host \
		-v %UserProfile%\.quora-spam:/home/quora-spam/.quora-spam \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-u root \
		--privileged \
		wildducktheories/quora-spam shell

or, with docker-compose installed locally:

	docker-compose run privileged

Alternatively, if you know what you are doing you can install make, bash, jq and curl, make locally and run quora-spam in your local environment. If you discover something that doesn't work properly under Windows feel to submit a PR for my consideration.

# COMMANDS

The quora-spam command is a wrapper for a large number of functions that can be used individually to achieve different ends. For the purposes of this document, I am going to describe commands that are enough to perform the basic spam reporting function.

## har save

	pbpaste | quora-spam har save # or,
	quora-spam har save < saved.har

This command reads a HAR file from stdin. A HAR file is an archive of requests your browser has sent to the Internet. We need to analyze this file so that we can extract a cookie we need to login to Quora on your behalf.

These instructions assume you are using Chrome as your browser. You can probably find information about similar tools for your browser of choice.

1. navigate to Quora with Chome and login
2. [open Chrome DevTools](https://developer.chrome.com/docs/devtools/open/)
3. refresh the Quora page you are on
4. navigate to the "Network" tab of the devtools window and select a request to quora.com
5. select "Copy > Copy all as HAR" from the context menu

Your clipboard now contains a HAR which contains, amongst other things, cookies that can be used to login to Quora. Now run the quora-spam har save command with the contents of your clipboard.

On OSX, you can run:

	pbpaste | quora-spam har save

on other operating systems you need to run a similar command to paste the contents of the clipboard to stdout or you need to save the clipboard to a file, say, `saved.har` then run:

	quora-spam har save < saved.har

Now, you can run `quora-spam login`.

## install pre-reqs

Installs all the commands required to run `quora-spam` locally. You do not need to use this command if you decide to use `docker-compose run quora-spam shell` (or equivalent) to run the `quora-spam` command.

On OSX, runs `brew install` to install any missing commands. On other environments, simply reports the names of commands that must be installed.

## login

This command assumes that `quora-spam har save` has been run previously.

It checks the Quora cookies are available and then starts a new shell. Once this shell exits the `quora-spam logout` command is executed to delete sensitive files from ~/.quora-spam.

Remember to either delete or secure any other copy of the HAR file you might have saved.

## logout

This command purges the files saved with `quora-spam har save` including the cookie file extracted from that file.

This command is also run automatically when the shell created by `quora-spam login` exits.

## loop process sweet-hot-girls

This command loops every 15 minutes then runs the `process sweet-hot-girls` command. To run on a different schedule, say every 30 minutes, change the command to:

	LOOP_DELAY=1800 quora-spam process sweet-hot-girls

## process sweet-hot-girls

This command reviews recent upvote notifications and checks the user profile associated with each notification. If it finds a supposed link to sweet-hot-girls.com, it raises a spam report against the user if this has no already been done. It also mutes the user and marks the notification as read.

This command is equivalent to:

	quora-spam query hot-sweet-girls | quora-spam report hot-sweet-girls

## query self

Generate a simplified profile record for the logged in user. This command can be used to test that your Quora cookies credentials have been captured correctly.

## query sweet-hot-girls

Generates a list of upvote notifications that were generated by spammy sweet-hot-girls profiles.

This command can be used to see which profiles `process sweet-hot-girls` would report without actually making those reports.

## report sweet-hot-girls

Iterates over spammy upvote notifications and generates a report for each. Care is taken not make a report if the report has already been made. The profiles must also be marked with a true isSpam attribute which will generally only happen if the profile has been positively identified as spam

# SECURITY

This command makes use of a HAR file that contains sensitive cookies that are used to autheticate your browser's access to Quora. The `quora-spam` needs to use these credentials to perform spam reporting functions on your behalf. The `quora-spam`script DOES send these credentials back to quora.com, but does not send them anywhere else.

However, if you cannot verify the `quora-spam` script is not malicious then you not use the script without being fully aware of the risks of doing so. A malicious variant of this script (perhaps created by others) could steal your Quora credentials and use them to impersonate your Quora identity which may ultimately result in your Quora account being banned.

In order to mitigate the risk of leaving Quora cookies sitting on your harddrive, the credentials, including cookies and .har file saved with `quora-spam har save` are deleted each time a `quora-spam login` shell is closed. If you save the .har file you capture from the browser prior to calling `quora-spam har save` then you ensure that this file is stored in a secure place or delete it after use.

# DISCLAIMER

While I have taken some care to ensure that this command does not place unreasonable demands on Quora's infrastructure. I make no claims about whether use of this command complies with Quora's terms of service. Use at your own discretion and only if you accept whatever risks that use of this command might entail including, but not limited to being banned from Quora.



