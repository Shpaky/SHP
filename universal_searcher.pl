#!/usr/lib/perl

	## application fething by ready projects
	
	use feature qw|say switch|;	
	use Getopt::Long;
	use Data::Dumper;
	use File::Copy;

	use lib '../../HPVF/share/perl5/vendor_perl';
	use avcdn::functions;
	
	use PROCESSING;

	## perl universal_searcher.pl -c 'print_list_projects' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --filter day=60 day=old --filter substr='lang=\"[a-z]{2}[q]\"'
	## perl universal_searcher.pl -c 'reassemble_info_xml' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --filter day=60 day=new --filter substr='lang=\"[a-z]{2}[q]\"'
	## perl universal_searcher.pl -c 'print_list_projects' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --filter day=60 day=old --filter substr='lang=\"[a-z]{2}[q]\"' substr=! --out file=OUT mode='>' frmt=json
	## perl universal_searcher.pl -c 'reassemble_info_xml' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --copy --filter substr=invers substr='lang=\"[a-z]{2}[q]\"'
	## perl universal_searcher.pl -c 'reassemble_info_xml' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --copy --force --filter substr='lang=\"[a-z]{2}[q]\"'
	## perl universal_searcher.pl -c 'print_list_projects' --file '.ism' 	 --type 'f' -d '/home/ftp-root/ftpusr010/return_Trailer'
	## perl universal_searcher.pl -c 'print_list_projects' --file '.ism' 	 --type 'f' -d '/home/ftp-root/ftpusr010/return_Trailer' --extra target=directory nest=1
	## perl universal_searcher.pl -c 'change_paths_to_ism' --file '.ism' 	 --type 'f' -d '/home/ftp-root/ftpusr010/return_Trailer' --extra target=file --copy
	## perl universal_searcher.pl -c 'print_list_projects' --file "v.hi.und.mp4" --type 'f' -d '/home/tvzavr_old_projects' --extra target=file --filter resolution=640 resolution=less --out file=OUT mode='>' frmt=json
	## 
	my $result = GetOptions 
	( 
		'file|f:s' => \$file, 
		'type|t:s' => \$type, 
		'directories|d:s@{,}' => \$directories, 
		'recursion+' => \$recursion,
		'single+' => \$single, 
		'extra|e:s%{,}' => \$extra, 
		'command|c=s' => \$command, 
		'copy+' => \$copy, 
		'force+' => \$force, 
		'out|o:s%{,}' => \$out, 
		'filter:s%{,}' => sub {push(@{$filter->{$_[1]}}, $_[2])} 
	) or die;
	##	
	##	search options
	##	++++++++++++++
	##	$file|f=file	
	##	$type|t=type		default|f|
	##	$directory|d=directories
	##
	##	search mode
	##	***********
	##	$recursion+		default|disabled|
	##	$sinlge+		default|multiple|
	##
	##	handler options
	##	===============
	##	$extra =
	##	{
	##		target=file	default|search file|
	##		nest=0|1|2|	default|0|
	##	}
	##	$command|c=command	
	##	$copy+			default|disabled|
	##	$force+			default|disabled|
	##
	##	output options
	##	~~~~~~~~~~~~~~
	##	$out = 
	##	{
	##		path=path	default|target path|
	##		nest=nest	default|0|
	##		frmt=json	default|list string|
	##		mode='>>'	default|>|
	##		file=file	default|STDOUT|
	##	}
	##
	##	filters options
	##	---------------
	##	$filter = 
	##	{
	##		resolution => [ width, more|less|equal, height, >|<|== ] 	default|==|
	##		..........
	##		day	   => [ days, old|new ]					default|new|
	##		..........
	##		substr	   => [ substring, inverse(0|1) ]			default|0|
	##	}				
	##
	##	say Data::Dumper->Dump([$extra],['extra']);
	##	say Data::Dumper->Dump([$filter],['filter']);

	&PROCESSING::export_name($command);
	&PROCESSING::export_name('check_resolution');

	my $re = &processing_to_re($file);	

	my $projects;
	for my $pwd ( @$directories )
	{
		&read_dir($pwd,$re,$type);
	}
	
	given( $command )
	{
		when('print_list_projects') { &print_list_projects($projects) }
		when('reassemble_info_xml') { &reassemble_info_xml($projects) }
		when('change_paths_in_ism') { &change_paths_in_ism($projects) }
		when('get_resolution_file') { &get_resolution_file($projects) }
	}

	sub read_dir
	{
		my ( $path, $re, $type ) = @_;

		opendir RD, $path;
		for( readdir(RD) )
		{
			if ( $type eq 'd' )
			{
				-d $path.'/'.$_ and /$re/ and $filter->{'day'} ? &cmp_date($path.'/'.$_,$filter->{'day'}) : 1 and push @$projects, $extra->{'target'} eq 'directory' ? split_path($path,$extra) : $path.'/'.$_ and $single ? last : $recursion ? 1 : next;
			}
			else
			{
				-f $path.'/'.$_ and /$re/ and $filter->{'day'} ? &cmp_date($path.'/'.$_,$filter->{'day'}) : 1 and $filter->{'substr'} ? &find_substr($path.'/'.$_,$filter->{'substr'}) : 1 and $filter->{'resolution'} ? &check_resolution($path.'/'.$_,$filter->{'resolution'}) : 1 and push @$projects, $extra->{'target'} eq 'directory' ? split_path($path,$extra) : $path.'/'.$_ and $single ? last : next;
			}
			-d $path.'/'.$_ and /^[^\.]/ and &read_dir($path.'/'.$_,$re,$type);
		}
		closedir(RD);
	}
	
	sub find_substr
	{
		my ( $file, $substr ) = @_;					## on input substring - RE
		
		open  RF, $file;
		map { /$substr->[0]/ and $substr->[1] eq '!' ? return undef : return $file } <RF>;
		close RF;

		$substr->[1] eq '!'
		? return 1 : return 0;
	}
	sub cmp_date
	{
		my ( $file, $date ) = @_;

		my ( $cy, $cd ) = (localtime(time))[5,7];
		my ( $fy, $fd ) = (localtime((stat($file))[9]))[5,7];

		for ( 0..($cy - $fy - 1) )
		{
			( $fy + $_ ) % 4
			? ( $cd += 365 )
			: ( $cd += 366 );
		}
	
		return $date->[1] eq 'old'
		? ( $cd - $date->[0] ) >= $fd
		: ( $cd - $date->[0] ) <= $fd;
	}
	sub processing_to_re
	{
		my ( $file ) = @_;
		
		$file =~ s/([._])/\\\1/g;
		
		$re = $file.'$';

		return $re;
	}
	sub split_path
	{
		my ( $path, $nest ) = @_;

		$nest = ref($nest) eq 'HASH' ? $nest->{'nest'} : $nest;
	
		$path =~ s/(.*)\/.+$/\1/ for ( 1..$nest );
		 
		return $path;
	}
	sub shielding_blank
	{
		my ( $path ) = @_;
		
		$path =~ s/(\s)/\\\1/g;
		
		return $path;
	}
