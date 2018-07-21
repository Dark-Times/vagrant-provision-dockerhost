$Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
$VagrantFile = Write-Output @'
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.network :forwarded_port, guest: 22, host: 22, auto_correct: true
    config.vm.provider "virtualbox" do |vb|
        vb.name = "docker-host"
        vb.memory = "2048"
        vb.cpus = "2"
    end
end
'@
$vagrantPath = (Get-Item -Path ".\" -Verbose).FullName | Join-Path -ChildPath 'VagrantFile'
[System.IO.File]::WriteAllLines($vagrantPath, $VagrantFile, $Utf8NoBomEncoding)

$Setup = Write-Output @'
sudo apt-get update
sudo apt-get install git -y
git clone https://github.com/Dark-Times/docker-host.git
cd docker-host/
sudo apt-get update
sudo apt-get install dos2unix -y
sudo dos2unix setup-docker-host.sh
sudo chmod a+x setup-docker-host.sh
sudo ./setup-docker-host.sh
'@
$setupPath = (Get-Item -Path ".\" -Verbose).FullName | Join-Path -ChildPath 'Setup'
[System.IO.File]::WriteAllLines($setupPath, $Setup, $Utf8NoBomEncoding)

vagrant up
Write-Output y | plink -ssh 127.0.0.1 -l vagrant -pw vagrant -m Setup
Write-Host "Setup complete. Machine is now rebooting..."