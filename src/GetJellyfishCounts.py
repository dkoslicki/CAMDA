import os
import sys
import subprocess
jellyfish_loc = "/home/pi/koslickd/jellyfish-2.2.3/bin/./jellyfish"
metagenome_bloom_filter = sys.argv[1]
count_out_file = os.path.abspath('../data/' + os.path.basename(metagenome_bloom_filter) + '-distinctKmers.txt')

# Get the number of unique k-mers in the metagenome
cmd = jellyfish_loc + " stats " + metagenome_bloom_filter
res = subprocess.check_output(cmd, shell=True)
num_kmers = int(res.split()[3])
fid = open(count_out_file, 'w')
fid.write("%d" % num_kmers)
fid.close()
