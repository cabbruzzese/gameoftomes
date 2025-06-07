cd h2
.\hcc.exe
cd ..
echo "Creating mod directory"
$gotPath = ".\gamefiles\got"
$gotMenuPath = "$gotPath\gfx\menu"
if (-not (test-path $gotMenuPath) ) {
    mkdir $gotMenuPath
} else {
    echo "$gotMenuPath already exists"
}

echo "Copying mod files"
COPY -Path ".\h2\progs.dat" -Destination "$gotPath\progs.dat" -Force
COPY -Path ".\assets\gfx\menu\conback.lmp"  -Destination "$gotMenuPath\conback.lmp" -Force
COPY -Path ".\assets\config\autoexec.cfg"  -Destination "$gotPath\autoexec.cfg" -Force

echo "Copying release files"
$releaseFolder = ".\release"
$releasePath = ".\release\got"
$releaseMenuPath = "$releasePath\gfx\menu"
if (-not (test-path $releaseMenuPath) ) {
    mkdir $releaseMenuPath
}
COPY -Path ".\h2\progs.dat" -Destination "$releasePath\progs.dat" -Force
COPY -Path ".\assets\gfx\menu\conback.lmp"  -Destination "$releaseMenuPath\conback.lmp" -Force
COPY -Path ".\assets\config\autoexec.cfg"  -Destination "$releasePath\autoexec.cfg" -Force

$zipDest = "$releaseFolder\got.zip"
$releaseFiles = ".\release\got\*"
echo "Deleting existing release zip file"
if (Test-Path $zipDest) {
    Remove-Item -Path $zipDest -Force
}
echo "Creating release file $zipDest"
Compress-Archive $releaseFiles $zipDest

echo "Complete"