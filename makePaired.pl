use strict;
my $fastqFileList = "/srv/local/kendell/GM12878/fastqs/usedFastqs_R1.txt";
open IN, $fastqFileList or die $1;
my @fastqs = ();
while (my $line = <IN>)
{
	chomp $line;
	push @fastqs, $line;

}

open OUT, ">paired-fastq-to-unmapped-bam.inputs.json" or die $!;
my @rgs = ();
my @fastqR1s = ();
my @fastqR2s = ();

my %idBits = ();
my $count = 0;
foreach my $fastq (@fastqs)
{
	next if $fastq eq "";
	if ($fastq =~ /.*\/Sample_(.*)\//)
	{
		my $idBit = "$1_$count";
		if ($idBits{$idBit})
		{
			die "multiple id bits: $idBit\n";
		}
		$idBits{$idBit} = 1;

		push @rgs, "NA12878_$idBit";
		push @fastqR1s, $fastq;
		die "can't find f1 $fastq" unless -e $fastq;
		$fastq =~ s/_R1_00/_R2_00/;
		push @fastqR2s, $fastq;
		die "can't find f2 $fastq" unless -e $fastq;

	}
	elsif ($fastq =~ /partial_U5b_AGTTCC_L002_R1_005.fastq.gz/)
	{
		push @rgs, "NA12878_U5b_partial";
		push @fastqR1s, $fastq;
		die "can't find f1 $fastq" unless -e $fastq;
		$fastq =~ s/_R1_00/_R2_00/;
		push @fastqR2s, $fastq;
		die "can't find f2 $fastq" unless -e $fastq;
	}
	else
	{
		die "couldn't parse $fastq\n";
	}
	$count++;
}
my $samCount = @rgs;
my @sampleNames = ("NA12878") x $samCount;
my @libs = ("Solexa-NA12878")x $samCount;
my @platforms = ("BH814YADXX")x $samCount;
my @dates = ("2016-09-01T02:00:00+0200")x $samCount;
my @pnames = ("illumina")x $samCount;
my @sc = ("BI")x $samCount;

print OUT '
{
  "##_Comment1": "Inputs",
  "ConvertPairedFastQsToUnmappedBamWf.readgroup_name": ["'.join('","',@rgs).'"],
  "ConvertPairedFastQsToUnmappedBamWf.sample_name": ["'.join('","',@sampleNames).'"],
  "ConvertPairedFastQsToUnmappedBamWf.fastq_1": ["'.join('","',@fastqR1s).'"],
  "ConvertPairedFastQsToUnmappedBamWf.fastq_2": ["'.join('","',@fastqR2s).'"],
  "ConvertPairedFastQsToUnmappedBamWf.library_name": ["'.join('","',@libs).'"],
  "ConvertPairedFastQsToUnmappedBamWf.platform_unit": ["'.join('","',@platforms).'"],
  "ConvertPairedFastQsToUnmappedBamWf.run_date": ["'.join('","',@dates).'"],
  "ConvertPairedFastQsToUnmappedBamWf.platform_name": ["'.join('","',@pnames).'"],
  "ConvertPairedFastQsToUnmappedBamWf.sequencing_center": ["'.join('","',@sc).'"],

  "##_Comment2": "Output ubam list",
  "ConvertPairedFastQsToUnmappedBamWf.ubam_list_name": "NA12878_unmapped_bam"

}
';
