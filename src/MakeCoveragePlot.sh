#!/bin/bash
set -e

# This script will demonstrate how to call SNAP and samtools to generate the coverage figure
# window size for coverage plot
windowSize=10
# truncate the coverage plot to the following coverage (must be a power of two)
truncateTo=8
# bottom tells where to start the inner ring of the plot
bottom=35
srcDir=`pwd`
dataDir="../data/SNAP/"
plotDir="../data/Output/"
paperDir="../data/Output/"
metagenome=$1
metagenomeBasename=`basename $metagenome`
foundGenome=`cat ../data/Output/${metagenomeBasename}.21.jf-FoundOrganismFileName.txt`


# Make the index
snap-aligner index ${foundGenome} ${dataDir} -s 16 -large

# Align the paired reads, only output aligned, allow larger edit distance to get more candidate alignment locations
snap-aligner paired ${dataDir} ${metagenome} -F a -hp -mrl 40 -xf 1.2 -d 40 -o -sam ${dataDir}${metagenomeBasename}.21.jf-aligned.sam > ${dataDir}${metagenomeBasename}.21.jf-alignment-stats.txt

# Sort the output
samtools sort --output-fmt sam ${dataDir}${metagenomeBasename}.21.jf-aligned.sam > ${dataDir}${metagenomeBasename}.21.jf-aligned.sorted.sam

# Windowed coverage information, only use MAPQ quality >= 20
samtools depth -q 20 -a --reference ${foundGenome} ${dataDir}${metagenomeBasename}.21.jf-aligned.sorted.sam | python GetCoverage.py $windowSize /dev/fd/0 ${dataDir}${metagenomeBasename}.21.jf-coverage_${windowSize}.txt

# Make the plot
python CoveragePlot.py -i ${dataDir}${metagenomeBasename}.21.jf-coverage_${windowSize}.txt -o ${plotDir}${metagenomeBasename}.21.jf-CoveragePlot.png -t ${truncateTo} -u bp -b ${bottom}

# Trim the white space in the figure
convert ${plotDir}${metagenomeBasename}.21.jf-CoveragePlot.png -trim ${plotDir}${metagenomeBasename}.21.jf-CoveragePlot.png

# Save the number of reads that aligned and other stats
sed -n 4p ${dataDir}alignment-stats.txt | cut -d' ' -f6 > ${paperDir}${metagenomeBasename}.21.jf-NumReadsAligned.txt
echo $windowSize > ${paperDir}${metagenomeBasename}.21.jf-WindowSize.txt
echo truncateTo > ${paperDir}${metagenomeBasename}.21.jf-TruncateTo.txt
# Save average coverage
cat ${dataDir}coverage_${windowSize}.txt | cut -f 4 | awk '{sum+=$1}END{printf "%1.3f", sum / NR}' > ${paperDir}${metagenomeBasename}.21.jf-MeanCoverage.txt
