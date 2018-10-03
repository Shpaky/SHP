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
	## perl universal_searcher.pl -c 'print_list_projects' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --filter day=60 day=old --filter substr='lang=\"[a-z]{2}[q]\"' substr=! 	--out file=OUT mode='>' frmt=json
	## perl universal_searcher.pl -c 'reassemble_info_xml' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --copy --filter substr=invers substr='lang=\"[a-z]{2}[q]\"'
	## perl universal_searcher.pl -c 'reassemble_info_xml' --file "info.xml" --type 'f' -d '/home/tvzavr_d' --copy --force --filter substr='lang=\"[a-z]{2}[q]\"'
	## perl universal_searcher.pl -c 'print_list_projects' --file '.ism' 	 --type 'f' -d '/home/ftp-root/ftpusr010/return_Trailer'
	## perl universal_searcher.pl -c 'print_list_projects' --file '.ism' 	 --type 'f' -d '/home/ftp-root/ftpusr010/return_Trailer' --extra target=directory path=1
	## perl universal_searcher.pl -c 'change_paths_to_ism' --file '.ism' 	 --type 'f' -d '/home/ftp-root/ftpusr010/return_Trailer' --extra target=file --copy
	## perl universal_searcher.pl -c 'print_list_projects' --file "v.hi.und.mp4" --type 'f' -d '/home/tvzavr_old_projects' --extra target=file --filter resolution=640 resolution=less 	--out file=OUT mode='>' frmt=json
	##
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.lw.und.mp4 files=v.nr.und.mp4 --type 'f' -d '/home/tvzavr_old_projects' --extra path=1 --filter resolution=640 resolution=equal 	--out file=OUT frmt=json
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.lw.und.mp4 files=v.nr.und.mp4 --type 'f' -d '/home/tvzavr_old_projects' --extra path=1
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.lw.und.mp4 files=v.nr.und.mp4 match='||' --type 'f' -d '/home/tvzavr_old_projects'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success --type 'f' -d '/home/tvzavr_old_projects'			--out file=OUT mode='>'
	##
	## perl universal_searcher.pl -c 'print_list_projects' --file 'v.nr.und.mp4' --type 'f' -d '/home/tvzavr_old_projects' --extra path=1 nest='3' 			--out file=OUT mode='>' frmt=json path=path nest=1
	## perl universal_searcher.pl -c 'print_list_projects' --file 'v.nr.und.mp4' --type 'f' -d '/home/tvzavr_old_projects' --extra nest='1..3' 			--out file=OUT mode='>' --nest '2'
	##
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects'		--out file=OUT mode='>' --nest '2'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='&&' --type 'f' -d '/home/tvzavr_old_projects'		--out file=OUT mode='>' --nest '2'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='&&' --type 'f' -d '/home/tvzavr_old_projects' 		--out file=OUT mode='>' --nest '3'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' 		--out file=OUT mode='>' --nest '3' --extra nest=2
	##
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' --extra nest=2    path=0 	--out file=OUT mode='>'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' --extra nest=2..3 path=0 	--out file=OUT mode='>' --nest '3'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='&&' --type 'f' -d '/home/tvzavr_old_projects' --extra nest=2-3  path=0  	--out file=OUT mode='>' --nest '4'
	##
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' --extra path=0 		--out file=OUT mode='>' --nest '3'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' --extra path=0 nest=1..2 	--out file=OUT mode='>' --nest '3'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' --extra path=0 nest=1-3	--out file=OUT mode='>' --nest '3'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=success match='||' --type 'f' -d '/home/tvzavr_old_projects' --extra path=0 nest=4 	--out file=OUT mode='>' --nest '3'
	##
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=v.lw.und.mp4 match='||' inversion=1 --type 'f' -d '/home/tvzavr' --extra nest=3 --nest '3' --exclude='addons'
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.nr.und.mp4 files=v.lw.und.mp4 match='||' inversion=1 --type 'f' -d '/home/tvzavr' --extra nest=3 --nest '3' --exclude='addons' --out file='PUT' mode='>'
	##
	## perl universal_searcher.pl -c 'convert_low_quality' --exist files=v.nr.und.mp4 files=v.lw.und.mp4 match='||' inversion=1 --type 'f' -d '/home/tvzavr' --extra nest=2 --nest '2'
	## perl universal_searcher.pl -c 'convert_low_quality' --exist files=v.nr.und.mp4 files=v.lw.und.mp4 match='||' inversion=1 --type 'f' -d '/home/tvzavr' --extra nest=3 --nest '3' --exclude='addons'
	##
	## perl universal_searcher.pl -c 'print_list_projects' --exist files=v.ec4 --type 'f' -d '/home/tvzavr' --nest 3 --exclude='addons'
	## perl universal_searcher.pl -c 'print_list_projects' --file 'v.ec4' --type 'f' -d '/home/tvzavr' --nest 3 --exclude 'addons'
	##
	## perl universal_searcher.pl -c 'print_list_projects' --file 'v.ec4' --type 'f' -d '/home/tvzavr' --nest 3 --exclude='addons' --out unix=/tmp/server-unix-socket/socket
	##
	my $result = GetOptions 
	( 
		'file|f:s' => \$file, 
		'type|t:s' => \$type,
		'nest|n:i' => \$nest,
		'directories|d:s@{,}' => \$directories, 
		'exist:s%{,}' => sub {push(@{$exist->{$_[1]}}, $_[2])},
		'exclude:s'=> \$exclude,
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
	##	$type|t=type								default|f|
	##	$nest|n=nest								default|unlimited|
	##	$directory|d=directories
	##	$exclude								default|empty|
	##	$exist =
	##	{
	##		files 	  => [ file1, file2, file3 ]				default|empty|
	##		.....
	##		match 	  => [ &&||| ]						default|AND|
	##		.....
	##		inversion => [ 1|0 ]						default|0|
	##		.........
	##	}
	##	.............................................
	##      options 'file' and 'exist' exclude each other
	##      options 'file' and 'exist' may use optionally
	##	option 'directory' may contain multiple paths
	##	option 'directory' must setted
	##
	##	search mode
	##	***********
	##	$recursion+								default|disabled|
	##	$sinlge+								default|multiple|
	##
	##	handler options
	##	===============
	##	$extra =
	##	{
	##		target=file							default|search file|
	##		path=0|1|2|							default|0|
	##		nest=[0-9]+							default|ALL|
	##		except=file							|in developing|
	##		route=route							default|empty|
	##	}
	##	$command|c=command
	##	$copy+									default|disabled|
	##	$force+									default|disabled|
	##
	##	output options
	##	~~~~~~~~~~~~~~
	##	$out = 
	##	{
	##		path=path							default|target path|
	##		nest=nest							default|0|
	##		mode='>>'							default|>|
	##		file=file							default|STDOUT|
	##		frmt=json							default|list string|
	##		mail=email							|in developing|
	##		unix=socket							default|STDOUT|
	##		inet=socket							|in developing|
	##		blnk=escape							default|disabled|
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
	##	say Data::Dumper->Dump([$exist],['exist']);
	##	say Data::Dumper->Dump([$filter],['filter']);

	&PROCESSING::export_name($command);
	&PROCESSING::export_name('check_resolution');

	$file and my $re = &processing_to_re($file);
	$exclude and my $ex = &processing_to_re($exclude);
	$extra->{'except'} and my $except = &collect_exceptions($extra->{'except'});

	my $projects;
	for my $pwd ( @$directories )
	{
		&set_nest_check and &nest_re($pwd);
		&read_dir($pwd);
	}

	given( $command )
	{
		when('print_list_projects') { &print_list_projects($projects) }
		when('reassemble_info_xml') { &reassemble_info_xml($projects) }
		when('change_paths_in_ism') { &change_paths_in_ism($projects) }
		when('get_resolution_file') { &get_resolution_file($projects) }
		when('convert_low_quality') { &convert_low_quality($projects) }
	}

	sub read_dir
	{
		my ( $path ) = @_;
		my ( $list ) = {};

		@$list{@{$exist->{'files'}}} = ( 1 ) x scalar @{$exist->{'files'}};

		opendir RD, $path;
		for( readdir(RD) )
		{
			$exclude and /$ex/ and next;
			if ( $type eq 'd' )
			{
				-d $path.'/'.$_
				and $file ? /$re/ : 1
				and $filter->{'day'} ? &cmp_date($path.'/'.$_,$filter->{'day'}) : 1

				and @{$exist->{files}} ? $extra->{'nest'}
						       ? &nest_handler_check($path,$extra->{'nest'})
						       ? $exist->{'match'}->[0] eq '||' ? delete($list->{$_}) ? !$exist->{'inversion'}->[0] ? ($list = {}) ? push ( @$projects, split_path($path,$extra) ) ? 1 : 1 : 1 : 1 : 1
											: delete($list->{$_}) ? scalar keys %{$list} == 0 ? !$exist->{'inversion'}->[0] ? push ( @$projects, split_path($path,$extra) ) ? 1 : 1 : 1 : 1 : 1
						       : 1
						       : $exist->{'match'}->[0] eq '||' ? delete($list->{$_}) ? !$exist->{'inversion'}->[0] ? ($list = {}) ? push ( @$projects, split_path($path,$extra) ) ? 1 : 1 : 1 : 1 : 1												     	     : delete($list->{$_}) ? scalar keys %{$list} == 0 ? !$exist->{'inversion'}->[0] ? push ( @$projects, split_path($path,$extra) ) ? 1 : 1 : 1 : 1 : 1
						       : 1

				and ! scalar @{$exist->{files}} ? $extra->{'nest'} ? &nest_handler_check($path,$extra->{'nest'})
										   ? push ( @$projects, $extra->{'target'} eq 'directory' ? split_path($path,$extra) : $path.'/'.$_ ) : 1
										   : push ( @$projects, $extra->{'target'} eq 'directory' ? split_path($path,$extra) : $path.'/'.$_ )
								: 1

				and $single ? last : $recursion ? 1 : next;
			}
			else
			{
				-f $path.'/'.$_
				and $file ? /$re/ : 1
				and $filter->{'day'} ? &cmp_date($path.'/'.$_,$filter->{'day'}) : 1
				and $filter->{'substr'} ? &find_substr($path.'/'.$_,$filter->{'substr'}) : 1
				and $filter->{'resolution'} ? &check_resolution($path.'/'.$_,$filter->{'resolution'}) : 1

				and @{$exist->{files}} ? $extra->{'nest'}
						       ? &nest_handler_check($path,$extra->{'nest'})
						       ? $exist->{'match'}->[0] eq '||' ? delete($list->{$_}) ? !$exist->{'inversion'}->[0] ? ($list = {}) ? push ( @$projects, split_path($path,$extra) ) ? next : next : next : next : next
											: delete($list->{$_}) ? scalar keys %{$list} == 0 ? !$exist->{'inversion'}->[0] ? push ( @$projects, split_path($path,$extra) ) ? next : next : next : next : next
						       : next
						       : $exist->{'match'}->[0] eq '||' ? delete($list->{$_}) ? !$exist->{'inversion'}->[0] ? ($list = {}) ? push ( @$projects, split_path($path,$extra) ) ? next : next : next : next : next											     : delete($list->{$_}) ? scalar keys %{$list} == 0 ? !$exist->{'inversion'}->[0] ? push ( @$projects, split_path($path,$extra) ) ? next : next : next : next : next
						       : 1

				and $extra->{'nest'} ? &nest_handler_check($path,$extra->{'nest'})
						     ? push ( @$projects, $extra->{'target'} eq 'directory' ? split_path($path,$extra) : $path.'/'.$_ ) : next ## may be use 'last' think about !may be specified most nesting!
						     : push ( @$projects, $extra->{'target'} eq 'directory' ? split_path($path,$extra) : $path.'/'.$_ )

				and $single ? last : next;
			}
			-d $path.'/'.$_ and /^[^\.]/ and $nest ? &nest_search_check($path.'/'.$_,$nest) ? &read_dir($path.'/'.$_) : next : &read_dir($path.'/'.$_);
		}
#		scalar @$exist > 0 and $inversion and $extra->{'nest'} ? &nest_handler_check($path,$extra->{'nest'})
#								       ? $extra->{'match'} eq '||' ? scalar keys %{$list} ? push ( @$projects, split_path($path,$extra) ) : undef
#												   : scalar keys %{$list} == scalar @$exist ? push ( @$projects, split_path($path,$extra) ) : undef
#								       : undef
#								       : $extra->{'match'} eq '||' ? scalar keys %{$list} ? push ( @$projects, split_path($path,$extra) ) : undef
#												   : scalar keys %{$list} == scalar @$exist ? push ( @$projects, split_path($path,$extra) ) : undef;

		scalar @{$exist->{'files'}} and $exist->{'inversion'}->[0] and $exist->{'match'}->[0] eq '||' ? scalar keys %{$list} ? $extra->{'nest'} ? &nest_handler_check($path,$extra->{'nest'})
																     ? push ( @$projects, split_path($path,$extra) ) : undef
														                     : push ( @$projects, split_path($path,$extra) )
																     : undef

													      : scalar keys %{$list} == scalar @{$exist->{'files'}} ? $extra->{'nest'} ? &nest_handler_check($path,$extra->{'nest'})
																				    ? push ( @$projects, split_path($path,$extra) ) : undef
																				    : push ( @$projects, split_path($path,$extra) )
																				    : undef;
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
		chomp($file);
		my $re = qr|$file$|;

		return $re;
	}
	sub split_path
	{
		my ( $path, $nest ) = @_;

		$nest = ref($nest) eq 'HASH' ? $nest->{'path'} : $nest;
	
		$path =~ s/(.*)\/.+$/\1/ for ( 1..$nest );
		 
		return $path;
	}
	sub shielding_blank
	{
		my ( $path ) = @_;
		
		$path =~ s/(\s)/\\\1/g;
		
		return $path;
	}

	sub set_nest_check
	{
		return
		( ( $nest and $nest =~ /[0-9]+/ ) or ( $extra->{'nest'} and $extra->{'nest'} =~ /[0-9]+|[0-9]+([\.]{2}|[-])[0-9]+/ ) )
		? 1
		: 0;
	}

	sub nest_re
	{
		my ( $path ) = @_;

		our $re1 = qr!$path!;
		our $re2 = qr!/\S[^\/]+!;
	}

	sub nest_search_check
	{
		my ( $path, $nest ) = @_;
		my ( $q );

		( $q ) = $path =~ s/$re1|$re2//g and return $nest < ( $q - 1 ) ? undef : 1;
	}

	sub nest_handler_check
	{
		my ( $path, $nest ) = @_;
		my ( $q );

		$nest =~ s/[\.]+/-/;
		$nest =~ /^[0-9]+$/
		? ( ( $q ) = $path =~ s/$re1|$re2//g ) && return ( $nest != ( $q - 1 ) ) ? undef : 1									## for specific level
		: ( ( $q ) = $path =~ s/$re1|$re2//g ) && return ( (split(/[-]/,$nest))[0] <= ( $q - 1 ) and (split(/[-]/,$nest))[1] >= ( $q - 1 ) ) ? 1 : undef;	## for levels range
	}

	sub collect_exceptions
	{
		my ( $exceptions ) = @_;
		my ( $e, %e, $f );

		map {
			( -f $_ and $f = $_ ) ||
			( -f $ENV{'PWD'}.'/'.$_ and $f = $ENV{'PWD'}.'/'.$_ ) ||
			( -d $_ and $f = $_ ) and
			-d $f
			? ( push @{$e}, $f )
			: ( open RF, $f and map { push @{$e}, $_ } grep {chomp} <RF> and close RF )
		} @{$exceptions} and @e{@$e} = ( 1 ) x scalar @$e;

		return $e;
	}
