#!/usr/bin/perl

	package PROCESSING;
	
	use JSON;
	use File::Copy;
	use IO::Socket;
	use FindBin qw|$Bin|;
	use feature 'say';

	$PROCESSING::EXPORT = 
	{
		print_list_projects => 'subroutine',
		check_resolution    => 'filter',
		check_integrity_symlink => 'filter',
		find_substr => 'filter',
		cmp_date => 'filter'
	};

	sub export_name
	{
		my $pack = caller;
		map { $PROCESSING::EXPORT->{$_} and local *myglob = eval('$'.__PACKAGE__.'::'.'{'.$_.'}'); *{$pack.'::'.$_} = *myglob } @_;
	}
	
	sub import_name
	{
		my $pack = caller(1);
		map { local *myglob = eval('$'.$pack.'::'.'{'.$_.'}'); *{__PACKAGE__.'::'.$_} = *myglob; } @_;
	}

	sub print_list_projects
	{
		my ( $projects ) = @_;
		
		&import_name('split_path','shielding_blank');

		my $pack = caller(1);

		my $unix = eval('$'.$pack.'::'.'out'.'->'.'{'.'unix'.'}');
		my $blnk = eval('$'.$pack.'::'.'out'.'->'.'{'.'blnk'.'}');
		my $frmt = eval('$'.$pack.'::'.'out'.'->'.'{'.'frmt'.'}') and my $hash = {};
		my $path = eval('$'.$pack.'::'.'out'.'->'.'{'.'path'.'}') and my $nest = eval('$'.$pack.'::'.'out'.'->'.'{'.'nest'.'}');
		my $file = eval('$'.$pack.'::'.'out'.'->'.'{'.'file'.'}') and my $mode = eval('$'.$pack.'::'.'out'.'->'.'{'.'mode'.'}');

		( $file  =~ /\/[\w]+/ or $file = $Bin.'/'.$file ) and -f $file and open STDOUT, $mode ? $mode : '>', $file;
		( -S $unix and my $route = eval('$'.$pack.'::'.'extra'.'->'.'{'.'route'.'}'));
		( -S $unix and my $extra = eval('$'.$pack.'::'.'extra'.'->'.'{'.'data'.'}'));


		if ( ref($projects) eq 'ARRAY' ) 
		{
			for my $project ( @$projects )
			{
				$unix and $client = IO::Socket::UNIX->new(Type => SOCK_STREAM(),Peer => $unix) and say {$client} encode_json(
				{
					'argv' => [ $path eq 'directory' ? $blnk ? shielding_blank(split_path($project,$nest)) : split_path($project,$nest) : $blnk ? shielding_blank($project) : $project ],
					'route'=> $route,
					'extra'=> { 'data' => [$extra] }
				}) and close $client and next;
				lc($frmt) eq 'json' ? $path eq 'directory' ?
				$blnk ? $hash->{shielding_blank(split_path($project,$nest))} = 1 : $hash->{split_path($project,$nest)} = 1 :
				$blnk ? $hash->{shielding_blank($project)} = 1 : $hash->{$project} = 1 :
				say $path ? $blnk ? &shielding_blank(split_path($project,$nest)) : split_path($project,$nest) : $blnk ? &shielding_blank($project) : $project;
			}
			lc($frmt) eq 'json' and say encode_json($hash);
		}
		else
		{
			$unix and $client = IO::Socket::UNIX->new(Type => SOCK_STREAM(),Peer => $unix) and say {$client} encode_json(
			{
				'argv' => [ $path eq 'directory' ? $blnk ? shielding_blank(split_path($projects,$nest)) : split_path($projects,$nest) : $blnk ? shielding_blank($projects) : $projects ],
				'route'=> $route,
				'extra'=> { 'data' => [$extra] }
			}) and close $client and return;
			lc($frmt) eq 'json' ? $path eq 'directory' ? $hash->{shielding_blank(split_path($projects,$nest))} = 1 : $hash->{shielding_blank($projects)} = 1 : say $path ? &shielding_blank(split_path($projects,$nest)) : &shielding_blank($projects);
			lc($frmt) eq 'json' and say encode_json($hash);
		}
	}
	## filters
	sub check_resolution
	{
		my ( $file, $filter ) = @_;

		## this call necessary replace to accordance module of interaction with 'ffmpeg' and 'ffmprob'
		my $resp = `ffprobe -v error -select_streams v:0 -show_entries stream=height,width -of csv=s=x:p=0 '$file' 2> /dev/null`;
		my ( $w, $h ) = split(/x/,$resp);

		$filter->[0] and $filter->[1] = $filter->[1] eq 'less' ? '<' : $filter->[1] eq 'more' ? '>' : $filter->[1] eq 'equal' ? '==' : $filter->[1] ? $filter->[1] : '==';
		$filter->[2] and $filter->[3] = $filter->[3] eq 'less' ? '<' : $filter->[3] eq 'more' ? '>' : $filter->[3] eq 'equal' ? '==' : $filter->[3] ? $filter->[3] : '==';

		## resolution => [ width, more|less|equal, height, >|==|< ]
		eval("($w $filter->[1] $filter->[0])") and $filter->[2] ? eval("$h $filter->[3] $filter->[2]") : 1 and return $file; 
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

	sub check_integrity_symlink
	{
		my ( $symlink, $condition ) = @_;

		my $target = $condition->[1] =~ /^(r|relation)$/ ? join('/',(split('/',$symlink))[0..scalar(split('/',$symlink))-2]).'/'.readlink($symlink) : readlink($symlink);

		given($condition->[0])
		{
		##	when(/^(e|any|all)$/)	{ return -e $target ? $condition->[2] =~ /(\+|whole|entiry)/ ? 1 : 0 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
		##	when(/^(f|file)$/)	{ return -f $target ? $condition->[2] =~ /(\+|whole|entiry)/ ? 1 : 0 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
		##	when(/^(d|directory)$/) { return -d $target ? $condition->[2] =~ /(\+|whole|entiry)/ ? 1 : 0 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
		##	default 		{ return -e $target ? $condition->[2] =~ /(\+|whole|entiry)/ ? 1 : 0 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }

			when(/^(e|any|all)$/)	{ return -e $target ? $condition->[2] =~ /(\-|broken|crash)/ ? 0 : 1 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
			when(/^(f|file)$/)	{ return -f $target ? $condition->[2] =~ /(\-|broken|crash)/ ? 0 : 1 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
			when(/^(d|directory)$/) { return -d $target ? $condition->[2] =~ /(\-|broken|crash)/ ? 0 : 1 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
			default 		{ return -e $target ? $condition->[2] =~ /(\-|broken|crash)/ ? 0 : 1 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0 }
		}
	}

	sub check_integrity_symlink_1
	{
		my ( $symlink, $condition ) = @_;

		my $target = $condition->[1] =~ /^(r|relation)$/ ? join('/',(split('/',$symlink))[0..scalar(split('/',$symlink))-2]).'/'.readlink($symlink) : readlink($symlink);

	##	eval("&convert_condition_check_file($condition->[0])") ? $condition->[1] =~ /(\+|whole|entiry)/ ? 1 : 0 : $condition->[1] =~ /(\-|broken|crash)/ ? 1 : 0;
		eval("&convert_condition_check_file($condition->[0])") ? $condition->[2] =~ /(\-|broken|crash)/ ? 0 : 1 : $condition->[2] =~ /(\-|broken|crash)/ ? 1 : 0;
	}

	sub convert_condition_check_file
	{
		my ( $condition ) = @_;

		given($condition)
		{
			when(/^(e|any|all)$/)	{return '-e'}
			when(/^(f|file)$/)	{return '-f'}
			when(/^(d|directory)$/) {return '-d'}
			default 		{return '-e'}
		}
	}
	1;
