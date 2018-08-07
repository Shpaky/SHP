#!/usr/lib/perl

	package PROCESSING;
	
	use JSON;
	use File::Copy;
	use FindBin qw|$Bin|;
	use feature 'say';

	$PROCESSING::EXPORT = 
	{
		print_list_projects => 'subroutine',
		check_resolution    => 'filter',
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

	sub reassemble_info_xml
	{
		my ( $projects ) = @_;

		my $pack = caller(1);
		my $copy = eval('$'.$pack.'::'.'copy') ? 1 : 0;
#		my $copy = ${$pack.'::'.'copy'} ? 1 : 0;
		
		if ( ref($projects) eq 'ARRAY' )
		{
			for my $project ( @$projects )
			{
				$copy && copy($project.'/addons/info.xml',$project.'/addons/info.xml_old');
				open  INFOXML,'>',$project.'/addons/info.xml';
				${$pack.'::'.'force'} 
				? print INFOXML eval{avcdn::functions::create_info_xml($project)}
				: print INFOXML avcdn::functions::create_info_xml($project);
				close INFOXML;
			}
		}
		else
		{
			$copy && copy($projects.'/addons/info.xml',$projects.'/addons/info.xml_old');
			open  INFOXML,'>',$projects.'/addons/info.xml';
			${$pack.'::'.'force'} 
			? print INFOXML eval{avcdn::functions::create_info_xml($projects)}
			: print INFOXML avcdn::functions::create_info_xml($projects);
			close INFOXML;
		}
	}

	sub print_list_projects
	{
		my ( $projects ) = @_;
		
		&import_name('split_path','shielding_blank');

		my $pack = caller(1);
		
		my $frmt = eval('$'.$pack.'::'.'out'.'->'.'{'.'frmt'.'}') and my $hash = {};
		my $path = eval('$'.$pack.'::'.'out'.'->'.'{'.'path'.'}') and my $nest = eval('$'.$pack.'::'.'out'.'->'.'{'.'nest'.'}');
		my $file = eval('$'.$pack.'::'.'out'.'->'.'{'.'file'.'}') and my $mode = eval('$'.$pack.'::'.'out'.'->'.'{'.'mode'.'}');
		( $file  =~ /\/[\w]+/ or $file = $Bin.'/'.$file ) and -f $file and open STDOUT, $mode ? $mode : '>', $file;

		if ( ref($projects) eq 'ARRAY' ) 
		{
			for my $project ( @$projects )
			{
				lc($frmt) eq 'json' ? $path eq 'directory' ? $hash->{shielding_blank(split_path($project,$nest))} = 1 : $hash->{shielding_blank($project)} = 1 : say $path ? &shielding_blank(split_path($project,$nest)) : &shielding_blank($project);
			}
			lc($frmt) eq 'json' and say encode_json($hash);
		}
		else
		{
			lc($frmt) eq 'json' ? $path eq 'directory' ? $hash->{shielding_blank(split_path($projects,$nest))} = 1 : $hash->{shielding_blank($projects)} = 1 : say $path ? &shielding_blank(split_path($projects,$nest)) : &shielding_blank($projects);
			lc($frmt) eq 'json' and say encode_json($hash);
		}
	}

	sub change_substr_files
	{
		my ( $projects, $re1, $re2 ) = @_;
		
		my $pack = caller(1);
		my $copy = eval('$'.$pack.'::'.'copy') ? 1 : 0;

		if ( ref($projects) eq 'ARRAY' )
		{
			for my $project ( @$projects )
			{
				copy($project,$project.'_old');

				open RF, '<', $project.'_old';
				open WF, '>', $project;
				for (<RF>)
				{
					s/$re1/$re2/g;
					print WF;	
				}
				close WF;
				close RF;

				$copy || unlink $project.'_old';
			}
		}
		else
		{
			copy($projects,$projects.'_old');

			open RF, '<', $projects.'_old';
			open WF, '>', $projects;
			for (<RF>)
			{
				s/$re1/$re2/g;
				print WF;	
			}
			close WF;
			close RF;

			$copy || unlink $projects.'_old';
		}
	}
	sub change_paths_in_ism
	{
		my ( $projects ) = @_;
		
		my $pack = caller(1);
		my $copy = eval('$'.$pack.'::'.'copy') ? 1 : 0;

		if ( ref($projects) eq 'ARRAY' )
		{
			for my $project ( @$projects )
			{
				copy($project,$project.'_old');

				$project =~ /([a-zA-Z]+)\/([a-zA-Z-]+)\/([a-zA-Z0-9]+)\/([a-zA-Z_]+)\/([a-zA-Z_-]+)\/([a-zA-Z_0-9-]+)\/([a-zA-Z0-9-_]+).*\.ism$/;
				my ( $h, $o, $r, $p ) = ( $1, $5, $6, $7 );

				open RF, '<', $project.'_old';
				open WF, '>', $project;
				for (<RF>)
				{
					s/\/$h\/$o\/([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]+)/\/$h\/$o\/$r\/$p/;
					print WF;	
				}
				close WF;
				close RF;

				$copy || unlink $project.'_old';
			}
		}
		else
		{
			copy($projects,$projects.'_old');

			$projects =~ /([a-zA-Z]+)\/([a-zA-Z-]+)\/([a-zA-Z0-9]+)\/([a-zA-Z_]+)\/([a-zA-Z_-]+)\/([a-zA-Z_0-9-]+)\/([a-zA-Z0-9-_]+).*\.ism$/;
			my ( $h, $o, $r, $p ) = ( $1, $5, $6, $7 );

			open RF, '<', $projects.'_old';
			open WF, '>', $projects;
			for (<RF>)
			{
				s/\/$h\/$o\/([a-zA-Z0-9_-]+)\/([a-zA-Z0-9_-]+)/\/$h\/$o\/$r\/$p/;
				print WF;	
			}
			close WF;
			close RF;
			$copy || unlink $projects.'_old';
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
	1;
