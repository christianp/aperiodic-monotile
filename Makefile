upload:
	python3 make-index.py
	rsync -avz . root@clpland:/var/www/somethingorotherwhatever.com/secret/laser-cutter
