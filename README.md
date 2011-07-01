Produce a JSON file for crawl2 to consume from the VRTrack database.

* https://github.com/sanger-pathogens/crawl2
* https://github.com/VertebrateResequencing/vr-codebase

Dependancies
------------
* JSON::XS
* YAML::XS
* XML::TreePP

Installation
------------
Checkout a local copy.

		git clone git@github.com:sanger-pathogens/vrtrack_crawl.git
		
Run:

		cd vrtrack_crawl
		make test


Usage 
-----
For testing: 

		./vrtrack_alignments_for_crawl.pl -e test -c local_test
		
Requires a local VRTracking MySQL datdabase.
		
For production to generate prokaryotes:

		./vrtrack_alignments_for_crawl.pl -e production -c prokaryotes
		
File saved in:

		 /lustre/scratch103/pathogen/pathpipe/prokaryotes/alignments.json
		
In production you can also choose (eukaryotes|helminths|metahit|prokaryotes|viruses).