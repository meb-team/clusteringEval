set -e 

function usage(){
	echo "bash preprocessing_stats.sh <raw fastq file>" 
}	

if [[ $# -ne 1 ]]; then 
	usage
	exit
fi 	

fastq=$1

BIN=$(echo $0 | rev | cut -f 2- -d "/" | rev)
if [[ $BIN == $0 ]]; then 
	BIN=. 
fi 
BIN=$(readlink -f $BIN) 

prefix=$(echo $fastq | rev | cut -f 2- -d "." | rev) 
stats=$prefix.preprocessing_stats.tsv 

initial_reads=$(($(wc -l $fastq | cut -f 1 -d " ")/4))

echo -e "\n -- CHIMERAS REMOVAL --" 
no_chimeras=$prefix.noChimeras.fastq
python3 $BIN/exclude_chimeras.py $fastq $no_chimeras

reads_after_chimeras=$(($(wc -l $no_chimeras | cut -f 1 -d " ")/4)) 

echo -e "\n -- DEREPLICATION --" 
derep=$prefix.noChimeras.derep
vsearch --derep_fulllength $no_chimeras --output $derep.fasta --threads 8 --sizeout --uc $derep.uc 

reads_after_derep=$(grep "^>" -c $derep.fasta) 

echo -e "\n -- TAXONOMY --" 
grep "reference=" $no_chimeras > $no_chimeras.headers 
python3 bin/frogs_taxo.py $no_chimeras.headers $derep.fasta $prefix.noChimeras.derep.abundance.tsv $prefix.noChimeras.derep.taxo.tsv 

number_strains=$(($(wc -l $prefix.noChimeras.derep.abundance.tsv | cut -f 1 -d " ") - 1)) 

echo -e "Sample\tRaw reads\tAfter chimeras removal\tAfter dereplication\tNumber of strains" > $stats
echo -e "$(echo $prefix | rev | cut -f 1 -d "/" | rev)\t$initial_reads\t$reads_after_chimeras\t$reads_after_derep\t$number_strains" >> $stats 
