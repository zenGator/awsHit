::20190412:zg

SETLOCAL ENABLEEXTENSIONS
SET me=%~n0
SET parent=%~dp0

@echo off
set /a disksize=%1
set /a segsize=%2
set volume=%3
set host=%4
set user=%5
set key=%6
set output=%7

::sanity check
if defined output (echo we have everything we need)else (echo Missing something
echo usage:
echo    %me% disksize segmentsize volume host user keyfile output
echo where disksize and segmentsize need to be in kilobytes
echo the volume should just be the final letter ^(e.g., the "f" in /dev/xvdf^)
echo and the output should be the path and base filename 
echo     ^(e.g., "e:\vol-08f171c44faddc239" will result in segment files named e:\vol-08f171c44faddc239.dd.##.gz^)
exit /b 1)


set /a segcount=(%disksize%/%segsize%)+1

@echo With disksize of %disksize% and segments of %segsize%:
@echo 	we will have %segcount% segments
for /L %%c IN (1,1,%segcount%) do CALL :pullseg %%c


exit /b 0


:: for loop function
:pullseg
set /a segnum=%1
@echo Grabbing segment # %segnum%
set /a skipper=(%segnum%-1)*%segsize%
ssh -i %key% %user%@%host% "sudo dd if=/dev/xvd%volume% bs=1024 skip=%skipper% count=%segsize%| gzip -2" > %output%.dd.%segnum%.gz 
exit /b 0
