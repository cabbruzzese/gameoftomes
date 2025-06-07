cd h2
.\hcc.exe
cd ..
echo "Creating mod directory"
$gotPath = ".\gamefiles\got"
if (-not (test-path $gotPath) ) {
    mkdir $gotPath
    mkdir "$gotPath\gfx\menu"
} else {
    echo "$gotPath already exists"
}
echo "Copying mod files"
COPY -Path ".\h2\progs.dat" -Destination ".\gamefiles\got\progs.dat" -Force
COPY -Path ".\assets\gfx\menu\conback.lmp"  -Destination ".\gamefiles\got\gfx\menu\conback.lmp" -Force
COPY -Path ".\assets\config\autoexec.cfg"  -Destination ".\gamefiles\got\autoexec.cfg" -Force
echo "Complete"