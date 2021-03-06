#%powershell1.0%
#
# File: summarize-results.ps1
# Description:
#
# Example Usage:
# c:\> summarize-results.ps1 -PHP1 5.3.8 -PHP2 5.4.0B2 -VIRTUAL "8,16,32"
#

Param( $PHP1="", $PHP2="", $VIRTUAL="8,16,32" )

Set-Location c:\wcat
$results = 'c:\wcat\results\'
$errlog = ""
$VIRTUAL = $VIRTUAL.split(',')

$php1wincache = $php2wincache = 'Wincache'
$php1apachecache = $php2apachecache = 'APC'
if ( ($PHP1 -match '5.5') -or ($PHP1 -match 'master') )  {
	$php1wincache = 'Opcache'
	$php1apachecache = 'Opcache'
}
if ( ($PHP2 -match '5.5') -or ($PHP2 -match 'master') )  {
	$php2wincache = 'Opcache'
	$php2apachecache = 'Opcache'
}

Function initvars  {
	$script:appnames = @("Helloworld", "Drupal", "Mediawiki", "Wordpress", "Joomla", "Symfony")
	$script:data = @{}

	Foreach ($app in $appnames) {
		$script:data.add($app, "")
		$script:data[$app] = @{	"IIS" = 
								@{	"nocache" = 
									@{	"php1" =
										@{	"tps$($VIRTUAL[0])" = [int]0;
											"tps$($VIRTUAL[1])" = [int]0;
											"tps$($VIRTUAL[2])" = [int]0;
											"err$($VIRTUAL[0])" = [int]0;
											"err$($VIRTUAL[1])" = [int]0;
											"err$($VIRTUAL[2])" = [int]0;
										};
									"php2" =
										@{	"tps$($VIRTUAL[0])" = [int]0;
											"tps$($VIRTUAL[1])" = [int]0;
											"tps$($VIRTUAL[2])" = [int]0;
											"err$($VIRTUAL[0])" = [int]0;
											"err$($VIRTUAL[1])" = [int]0;
											"err$($VIRTUAL[2])" = [int]0;
										}
									};
									"cache" = 
									@{	"php1" =
										@{	"tps$($VIRTUAL[0])" = [int]0;
											"tps$($VIRTUAL[1])" = [int]0;
											"tps$($VIRTUAL[2])" = [int]0;
											"err$($VIRTUAL[0])" = [int]0;
											"err$($VIRTUAL[1])" = [int]0;
											"err$($VIRTUAL[2])" = [int]0;
										};
									"php2" =
										@{	"tps$($VIRTUAL[0])" = [int]0;
											"tps$($VIRTUAL[1])" = [int]0;
											"tps$($VIRTUAL[2])" = [int]0;
											"err$($VIRTUAL[0])" = [int]0;
											"err$($VIRTUAL[1])" = [int]0;
											"err$($VIRTUAL[2])" = [int]0;
										}
									}
								};
								"Apache" = 
								@{	"nocache" = 
									@{	"php1" =
										@{	"tps$($VIRTUAL[0])" = [int]0;
											"tps$($VIRTUAL[1])" = [int]0;
											"tps$($VIRTUAL[2])" = [int]0;
											"err$($VIRTUAL[0])" = [int]0;
											"err$($VIRTUAL[1])" = [int]0;
											"err$($VIRTUAL[2])" = [int]0;
											};
										"php2" =
											@{	"tps$($VIRTUAL[0])" = [int]0;
												"tps$($VIRTUAL[1])" = [int]0;
												"tps$($VIRTUAL[2])" = [int]0;
												"err$($VIRTUAL[0])" = [int]0;
												"err$($VIRTUAL[1])" = [int]0;
												"err$($VIRTUAL[2])" = [int]0;
											}
									};
									
									"cachenoigbinary" =
									@{	"php1" =
											@{	"tps$($VIRTUAL[0])" = [int]0;
												"tps$($VIRTUAL[1])" = [int]0;
												"tps$($VIRTUAL[2])" = [int]0;
												"err$($VIRTUAL[0])" = [int]0;
												"err$($VIRTUAL[1])" = [int]0;
												"err$($VIRTUAL[2])" = [int]0;
											};
										"php2" =
											@{	"tps$($VIRTUAL[0])" = [int]0;
												"tps$($VIRTUAL[1])" = [int]0;
												"tps$($VIRTUAL[2])" = [int]0;
												"err$($VIRTUAL[0])" = [int]0;
												"err$($VIRTUAL[1])" = [int]0;
												"err$($VIRTUAL[2])" = [int]0;
											}
									};
									
									"cachewithigbinary" =
									@{	"php1" =
											@{	"tps$($VIRTUAL[0])" = [int]0;
												"tps$($VIRTUAL[1])" = [int]0;
												"tps$($VIRTUAL[2])" = [int]0;
												"err$($VIRTUAL[0])" = [int]0;
												"err$($VIRTUAL[1])" = [int]0;
												"err$($VIRTUAL[2])" = [int]0;
											};
										"php2" =
											@{	"tps$($VIRTUAL[0])" = [int]0;
												"tps$($VIRTUAL[1])" = [int]0;
												"tps$($VIRTUAL[2])" = [int]0;
												"err$($VIRTUAL[0])" = [int]0;
												"err$($VIRTUAL[1])" = [int]0;
												"err$($VIRTUAL[2])" = [int]0;
											}
									}
								}
							}
	}  ## End Foreach
}  ## End Function


## Initialize hash table
## $data[App_Name][Apache|IIS][cache|nocache|cachenoigbinary|cachewithigbinary][php1|php2][tps8|tps16|tps32]
initvars

Get-ChildItem -recurse $results | Where-Object { $_.Name -match '\.dat' } | ForEach-Object  {

	## Determine web server, cache/nocache and application from file name
	## i.e. Apache-PHP5.4.0B2-Apache-Cache-Drupal.summary.dat
	$dname = $_.Name.split("-")
	$websvr = $dname[0]
	$phpver = $dname[1] -ireplace "PHP", ""
	$cache = $dname[3].tolower()
	$appname = $dname[4] -ireplace "\.\w+", ""

	if ( $phpver -eq $PHP1 )  {  $phpver = "php1"  }
	elseif ( $phpver -eq $PHP2 )  {  $phpver = "php2"  }
	else  {  continue  }

	$contents = (get-content $_.FullName)

	Foreach ( $line in $contents )  {
		if ( $line -match "\.xml" )  {
			##																		  tps,  kcpt, bpt,   cpu, err
			## i.e. php-web01-Apache-2clnt-08vrtu-PHP5.4.0B2-Apache-Cache-Drupal.xml, 40.7, 0.0,  10670, 0.0, 0
			$line = $line.split(",")
			$tps = $line[1].trim()
			$err = $line[5].trim()
			$virt = $line[0].split("-")
			$virt = $virt[4]
			$virt = $virt -ireplace "vrtu", ""
			$virt = $virt -ireplace "^0", ""

			#write-host "$appname $websvr $cache $phpver tps$virt"
			$data[$appname][$websvr][$cache][$phpver]["tps$virt"] = $tps
			$data[$appname][$websvr][$cache][$phpver]["err$virt"] = $err
			#write-host "$appname, $websvr, $cache, $phpver, "$data[$appname][$websvr][$cache][$phpver]["tps$virt"]

			if ( $err -gt 0 )  {
				$logfile = "c:/wcat/autocat-log.txt"
				$msg = (get-date -format "yyyy-MM-dd HH:mm:ss")+" $appname, $websvr, $cache, $dname[1]`: $err"
				$msg | Out-File -Encoding ASCII -Append $logfile
				$errlog += "$appname, $websvr, $cache, "+$dname[1]+": $err <br/>`n"
			}
		}
	}
}

## Finally, output the results template
. ".\results-template.ps1"

