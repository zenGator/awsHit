::20190412:zg

::ToDo:  add switch for selecting gzip level
::ToDO:  add better command-line parser (use real switches)
::ToDo:  add means to select just a certain segment (for do-overs)
::ToDo:  build in logging
::ToDo:  more-verbose in-process messaging (segment #, start, end, output name
::ToDo:  name should use 3-digit numbers (.001, .002, etc)
::ToDo:  summarize results at conclusion



@echo off
SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

set /a disksize=%1
set /a rawsegsize=%2
set user=%3
set host=%4
set volume=%5
set key=%6
set output=%7
set extra=%8


::sanity checks

if defined extra (
	echo.
	echo ERROR:  %me%: Too many parameters
	CALL :usage
	exit /b 2
)

if defined output (
	:: We have everything we need
	echo.
) else (
	echo.
	echo ERROR:  %me%: Missing something
	CALL :usage
	exit /b 1
)

set /a ddblocks=%rawsegsize%/4
set /a segcount=(%disksize%/%rawsegsize%)+1

echo With disksize of %disksize% and segments of %rawsegsize% we will have %segcount% segments.
echo Basic command we will be running is:
echo     ssh -i %key% %user%@%host% "sudo dd if=/dev/xvd%volume% bs=4096 skip=[%ddblocks%*##] count=%ddblocks% | gzip -2"  
echo The files will be saved as %output%.dd.[##].gz 
echo.
for /L %%c IN (1,1,%segcount%) do CALL :pullseg %%c

exit /b 0




:: for loop functionality
:pullseg
set /a segnum=%1
echo Grabbing segment # %segnum%
set /a skipper=(%segnum%-1)*(%rawsegsize%/4)
ssh -i %key% %user%@%host% "sudo dd if=/dev/xvd%volume% bs=4096 skip=%skipper% count=%ddblocks% | gzip -2" > %output%.dd.%segnum%.gz 
exit /b 0


:usage
echo.
echo usage:
echo    %me% disksize segmentsize user host volume keyfile output
echo.
echo where disksize and segmentsize need to be in kilobytes
echo the volume should just be the final letter ^(e.g., the "f" in /dev/xvdf^)
echo and the output should be the path and base filename 
echo     ^(e.g., "e:\vol-08f171c44faddc239" will result in segment files named e:\vol-08f171c44faddc239.dd.##.gz^)
exit /b 0
