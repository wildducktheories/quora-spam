# NAME

quora-spam - a tool for dealing with Quora upvote spam, one notification at a time

# SYNOPSIS
```sh
pbpaste | quora-spam har save   # on OSX, or,
quora-spam har save < saved.har # on other platforms that don't have pbpaste
quora-spam login
quora-spam loop process sweet-hot-girls
```
# DESCRIPTION

In July 2022, a spammer started generating large amounts of quora "upvote" spam that resulted in Quora authors being subjected to 10s of notifications each day containing upvotes from spammy profiles that contain deceptive "sweethotgirls" links that presumably link to a porn site or the promise of a porn site. It is unknown if the resources referenced by these links also contain malware but, based on the deceptive nature of the links themselves, it is best to assume that they do.

The volume of such notifications makes reporting each and everyone of them quite tedious if done manually.

We decided to automate the process of reporting this spam by reverse-engineering the Quora API calls required to identify, report mute and block spammy upvotes thereby making our lives more pleasant.

We are offering the tool to others who are annoyed by such spam and who would like to report it, but don't appreciate the hassle of doing so.

# INSTALLATION (MacOS, Linux)

Running directly from a clone of the GitHub repo is probably the easiest way:

```sh
mkdir -p ~/git/wildducktheories &&
cd ~/git/wildducktheories &&
git clone git@github.com:wildducktheories/quora-spam.git quora-spam &&
cd quora-spam
```

If you want to run the quora-spam script locally, you should run this command to use brew to install the necessary pre-requisites.

	./quora-spam install pre-reqs && make

# INSTALLATION (Windows)

If you only have a Windows machine, the easiest way to use this is to install [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/) and download the docker image.

	docker pull wildducktheories/quora-spam

# RUNNING (Mac, Linux)

The following command sets up a shell which is always guaranteed to contain the necessary commands

	./quora-spam shell                    # locally, or,
	docker-compose run quora-spam shell # inside a docker container

For more information about what to do once you have started a quora-spam shell,
refer to the EXAMPLES section below.

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

Alternatively, if you know what you are doing you can install `bash`, `jq`, `curl`, `make` locally and run `quora-spam` in your local environment. If you discover something that doesn't work properly under Windows feel to submit a PR for my consideration.

For more information about what to do once you have started a quora-spam shell,
refer to the EXAMPLES section below.

# COMMANDS

The `quora-spam` command is a wrapper for a large number of functions that can be used individually to achieve different ends. For the purposes of this document, we are going to describe the commands that are sufficient to perform the basic spam reporting function for the current sweet-hot-girls spam epidemic. If new variants emerge, we may release updates to deal with the variants.

## har save

	pbpaste | quora-spam har save # or,
	quora-spam har save < saved.har

This command reads a HAR file from stdin. A HAR file is an archive of requests your browser has sent to and responses received from the Internet. We need to analyze this file so that we can extract the headers we need to login to Quora on your behalf. See the SECURITY note, below.

These instructions assume you are using Chrome as your browser. You can probably find information about similar tools for your browser of choice.

1. navigate to Quora with Chome and login
2. [open Chrome DevTools](https://developer.chrome.com/docs/devtools/open/)
3. refresh the Quora page you are on
4. navigate to the "Network" tab of the devtools window and select a request to quora.com
5. select "Copy > Copy all as HAR" from the context menu

Your clipboard now contains a HAR which contains, amongst other things, headers that can be used to login to Quora. Now run the `quora-spam har save` command with the contents of your clipboard piped to stdin.

For example, on OSX, you can run:

	pbpaste | quora-spam har save

on other operating systems you need to run a similar command to paste the contents of the clipboard to stdout or you need to save the clipboard to a file (say: `saved.har`) and then run:

	quora-spam har save < saved.har

Now, you can run `quora-spam login` to create a login shell that can be used to exercise the spam reporting functions.

## install pre-reqs

Installs all the commands required to run `quora-spam` locally. You do not need to use this command if you decide to use `docker-compose run quora-spam shell` (or equivalent) to run the `quora-spam` command.

On OSX, runs `brew install` to install any missing commands. On other environments, simply reports the names of commands that must be installed.

## login

This command assumes that `quora-spam har save` has been run previously.

It checks the Quora credentials are available and then starts a new shell. Once this shell exits the `quora-spam logout` command is executed to delete sensitive files from ~/.quora-spam.

Remember to either delete or secure any other copy of the HAR file you might have saved.

See the EXAMPLES section for what to do next.

## logout

This command purges the files saved with `quora-spam har save` including the credentials file extracted from that file.

This command is also run automatically when the shell created by `quora-spam login` exits.

## loop process sweet-hot-girls

This command loops every 15 minutes then runs the `process sweet-hot-girls` command. To run on a different schedule, say every 30 minutes, change the command to:

```sh
LOOP_DELAY=1800 quora-spam process sweet-hot-girls
```

## process sweet-hot-girls

This command reviews recent upvote notifications and checks the user profile associated with each notification. If it finds a supposed link to sweet-hot-girls.com, it raises a spam report against the user if this has no already been done. It also mutes the user and marks the notification as read.

This command is equivalent to:

	quora-spam query hot-sweet-girls | quora-spam report hot-sweet-girls

## query self

Generate a simplified profile record for the logged in user.

This command is mainly useful as a simple test that should always report the profile of the logged in user. If it doesn't work, something has probably gone wrong
with the login process.

## query busy-profiles

Generates a list of upvote notifications associated with profiles which have generated more than 10 upvotes per hour of activity.

## query adult-dating

Generates a list of upvote notifications that reference an adultdating.quora.com post.

Note: the spammer is now no longer generating upvotes from profiles that reference posts on the adultdating.quora.com space so this query will likely not yield too many useful hits.

# query explode-adult-dating

Generates a list of all the profiles that share posts on the adultdating.quora.com site.

Note: this relies on 'query adult-dating' yielding some profiles howver, since the spammer is no longer using such profiles &/or Quora is automatically banning these so this won't be useful.

## query sweet-hot-girls

Generates a list of upvote notifications that were generated by spammy sweet-hot-girls profiles.

This command can be used to see which profiles `quore-spam process sweet-hot-girls` would report without actually making those reports.

Note: this functionality is no longer useful as the spammer changed tactics and started to generate adult-dating spam.

## report sweet-hot-girls

Iterates over spammy upvote notifications read from stdin (for example, as generated by `quora-spam query sweet-hot-girls`) and files a spam report for each. Care is taken not make a report if the current user has already made a report. The profiles must also be marked with a true `isSpam` property which will generally only happen if the profile has been positively identified as spam by `quora-spam query sweet-hot-girls`

# EXAMPLES

Once you have logged in with `quora-spam login`, run:

	quora-spam query sweet-hot-girls

to analyse recent upvotes and find the ones that are sweethotgirls spam.

To report these, run:

	quora-spam query sweet-hot-girls | quora-spam report sweet-hot-girls

or, more simply:

	quora-spam process sweet-hot-girls

To run the command repeatedly in a 15-minute loop, simply run:

```sh
quora-spam loop process sweet-hot-girls
````

# SUBMITTING PROFILE REPORTS TO profilereports.quora.com

profilereports.quora.com is a Quora space dedicated to collating profile reports
generated by this tool to provide visibilty of spammy accounts to others to allow them to use this information to pre-emptively report and block the accounts before being spammed by them.

To enable this functionality, you must enable this functionality by running:

	quora-spam config set enable-submit:true

Now, if you run the `quora-spam file-profile-report` command (or commands that call it, like `quora-spam process sweet-hot-girls` or `quora-spam report sweet-hot-girls`), then every time you report a profile to Quora a report will also be filed to the profilereports.quora.com space where it can be seen by other Quora users.

# SECURITY

This command makes use of a HAR file that contains sensitive credentials that are used to autheticate your browser's access to Quora (and perhaps other sites). The `quora-spam` command needs to use these credentials to perform spam reporting functions on your behalf. The `quora-spam` script DOES send these credentials back to quora.com, but does not send them anywhere else.

However, if you cannot verify the `quora-spam` script is not malicious then you not use the script without being fully aware of the risks of doing so. A malicious variant of this script (perhaps created by others) could steal your Quora credentials (and perhaps credentials from other sites) and use them to impersonate your Quora identity which may ultimately result in your Quora account being banned or worse.

In order to mitigate the risk of leaving Quora credentials sitting on your harddrive, the credentials, including credentials and .har file saved with `quora-spam har save` are deleted each time a `quora-spam login` shell is closed. If you save the .har file you capture from the browser prior to calling `quora-spam har save` then you ensure that this file is stored in a secure place or delete it after use.

# RELEASE NOTES
- 2002-07-20 - v1.7
	+ enhance query simple-profile output
	+ invalidate cache after mutation
	+ split out 'query explode-adult-dating'
	+ change 'process explode-adult-dating' to block the matched profiles
	+ add 'query young-profiles' and 'query busy-profiles'

- 2002-07-18 - v1.6
	+ add support for 'adult-dating' alternative to 'sweet-hot-girls' to deal with a new variant of the spam in which profiles don't have spammy links but link instead to a post that contains spammy links
	+ added caching support to avoid repeated executions of same curl request
	+ add explode-adult-dating to generate a upvote activity summary for all sharers of a spammy post. warning: this command is expensive in terms of curl requests, network, CPU and disk

- 2002-07-16 - v1.5
	+ replaced 'template' with 'explode' and 'explodeable'
	+ reworked all curl calls to use 'explode'
	+ whitespace fixes

- 2002-07-15 - v1.4
	+ adjusted spam filter to deal with emerging variants
	+ cope with non-ASCII characters in profile URLs

- 2002-07-14 - v1.3
	+ versions prior to v1.2 had a hard-coded (and sensitive) quora-formkey header which prevented the software working for anyone but me
	+ this key has now been invalidated, to prevent mis-use.
	+ the git history prior to v1.3 has been rewritten to replace the sensitve value with rubbish
	+ updated the filter to include additional spam detection expressions

- 2002-07-13 - v1.2
	+ add support for generating an activity summary for a profile
	+ add support for submitting profile reports to profilereports.quora.com
	+ replace 'cookies' file with 'credentials' file which includes quora-formkey header
	+ add support for separate 'submit-credential' to allow submitting profile reports to profilereports.quora.com with a different Quora userid

- 2022-07-07 - v1.1
	+ README updates
	+ use 'uid' rather than 'id' in profile objects for better consistency with Quora
	+ rename 'profiles' commands to 'simple-notifications' to better reflect semantics
	+ auto-generate command lists from source

- 2022-07-07 - v1.0
	+ initial release

# DISCLAIMER


While we have taken some care to ensure that this software does not abuse Quora's API, we make no claims as to whether use of this software complies with Quora's terms of service. Users concerned about this should do their own research and refrain from use of this software if they have any concerns.

WARNING: On July 12, I observed that the https://www.quora.com/notifications/ page stopped being populated with the results of a graphql query. This also ulimately causes the mobile-web and mobile-app notifications function to stop working. On the web app, the I was still able to access https://www.quora.com/notifications/upvotes and https://www.quora.com/notifications/write. The problem did eventually rectify itself, so I am not 100% sure why this occurred and I don't know whether it was related to my use of this software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# COPYRIGHT

Copyright (C) 2022 Wild Duck Theories Australia Pty Ltd.
Portions Copyright (C) 2022 UPowr Pty Ltd.

# LICENSE

Unless otherwise specified, all source code in the quora-spam project is licensed under GPLv2:

```text
GNU GENERAL PUBLIC LICENSE

Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.
51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA

Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.
```

The **\_ju** function in quora-spam has the following MIT license.

```text
Copyright (C) 2022 UPowr Pty Ltd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
