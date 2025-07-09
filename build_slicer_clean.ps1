# Slicer Build Script for Windows
# This script automates the Slicer build process following the official instructions

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Release", "Debug")]
    [string]$BuildType = "Release",
    
    [Parameter(Mandatory=$false)]
    [string]$SourceDir = "C:\D\S",
    
    [Parameter(Mandatory=$false)]
    [string]$BuildDir = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Qt5Dir = "C:\Qt\5.15.2\msvc2019_64\lib\cmake\Qt5",
    
    [Parameter(Mandatory=$false)]
    [string]$CMakePath = "C:\Program Files\CMake\bin\cmake.exe"
)

# Set default build directory based on build type
if ([string]::IsNullOrEmpty($BuildDir)) {
    if ($BuildType -eq "Release") {
        $BuildDir = "C:\D\SR"
    } else {
        $BuildDir = "C:\D\SD"
    }
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Slicer Build Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build Type: $BuildType" -ForegroundColor Yellow
Write-Host "Source Directory: $SourceDir" -ForegroundColor Yellow
Write-Host "Build Directory: $BuildDir" -ForegroundColor Yellow
Write-Host "Qt5 Directory: $Qt5Dir" -ForegroundColor Yellow
Write-Host "CMake Path: $CMakePath" -ForegroundColor Yellow
Write-Host ""

# Function to check if a path exists
function Test-PathExists {
    param([string]$Path, [string]$Description)
    
    if (Test-Path $Path) {
        Write-Host "✓ $Description found: $Path" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ $Description not found: $Path" -ForegroundColor Red
        return $false
    }
}

# Function to create directory if it doesn't exist
function New-DirectoryIfNotExists {
    param([string]$Path)
    
    if (!(Test-Path $Path)) {
        Write-Host "Creating directory: $Path" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

$allPrereqsOk = $true
$allPrereqsOk = (Test-PathExists $CMakePath "CMake") -and $allPrereqsOk
$allPrereqsOk = (Test-PathExists $Qt5Dir "Qt5") -and $allPrereqsOk

# Check for Git
try {
    $gitVersion = git --version
    Write-Host "✓ Git found: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ Git not found in PATH" -ForegroundColor Red
    $allPrereqsOk = $false
}

# Check for Visual Studio
$vsWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vsWhere) {
    $vsInstances = & $vsWhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($vsInstances) {
        Write-Host "✓ Visual Studio found: $vsInstances" -ForegroundColor Green
    } else {
        Write-Host "✗ Visual Studio with C++ tools not found" -ForegroundColor Red
        $allPrereqsOk = $false
    }
} else {
    Write-Host "⚠ Visual Studio Installer not found - please ensure Visual Studio 2022 is installed" -ForegroundColor Yellow
}

if (!$allPrereqsOk) {
    Write-Host ""
    Write-Host "Please install missing prerequisites before proceeding:" -ForegroundColor Red
    Write-Host "1. CMake version 3.20.6 or higher but less than 4.0" -ForegroundColor Red
    Write-Host "2. Git version 1.7.10 or higher" -ForegroundColor Red
    Write-Host "3. Visual Studio 2022 with C++ Desktop Development" -ForegroundColor Red
    Write-Host "4. Qt 5.15.2 with MSVC2019 64-bit component" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "All prerequisites found!" -ForegroundColor Green
Write-Host ""

# Create directories
Write-Host "Setting up directories..." -ForegroundColor Cyan
New-DirectoryIfNotExists "C:\D"
New-DirectoryIfNotExists $SourceDir
New-DirectoryIfNotExists $BuildDir

# Check if source code exists
if (!(Test-Path "$SourceDir\CMakeLists.txt")) {
    Write-Host "Source code not found. Cloning Slicer repository..." -ForegroundColor Cyan
    Set-Location $SourceDir
    git clone https://github.com/Slicer/Slicer.git .
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to clone Slicer repository" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Repository cloned successfully!" -ForegroundColor Green
} else {
    Write-Host "Source code already exists in $SourceDir" -ForegroundColor Green
}

# Configure for development (optional)
$setupDev = Read-Host "Do you want to configure the repository for development? (y/N)"
if ($setupDev -eq "y" -or $setupDev -eq "Y") {
    Write-Host "Configuring repository for development..." -ForegroundColor Cyan
    Set-Location "$SourceDir\Utilities"
    
    # Check if we're in a Git Bash compatible environment
    try {
        bash -c "./SetupForDevelopment.sh"
        Write-Host "Development setup completed!" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not run SetupForDevelopment.sh automatically." -ForegroundColor Yellow
        Write-Host "Please run it manually from Git Bash in the Utilities folder." -ForegroundColor Yellow
    }
}

# Configure the build
Write-Host ""
Write-Host "Configuring Slicer build..." -ForegroundColor Cyan
Set-Location "C:\D"

$configureArgs = @(
    "-G", "Visual Studio 17 2022"
    "-A", "x64"
    "-DQt5_DIR:PATH=$Qt5Dir"
    "-S", $SourceDir
    "-B", $BuildDir
)

Write-Host "Running CMake configure..." -ForegroundColor Yellow
Write-Host "Command: `"$CMakePath`" $($configureArgs -join ' ')" -ForegroundColor Gray

& $CMakePath @configureArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "CMake configuration failed!" -ForegroundColor Red
    exit 1
}

Write-Host "CMake configuration completed successfully!" -ForegroundColor Green

# Build Slicer
Write-Host ""
Write-Host "Building Slicer in $BuildType mode..." -ForegroundColor Cyan
Write-Host "This will take several hours - 3 to 4 hours on desktop, 8 to 12 hours on laptop" -ForegroundColor Yellow
Write-Host "Build requires:" -ForegroundColor Yellow
if ($BuildType -eq "Release") {
    Write-Host "- Disk space: approximately 15GB" -ForegroundColor Yellow
} else {
    Write-Host "- Disk space: approximately 60GB" -ForegroundColor Yellow
}

$proceed = Read-Host "Do you want to start the build now? (Y/n)"
if ($proceed -eq "n" -or $proceed -eq "N") {
    Write-Host ""
    Write-Host "Build configuration completed. To build later, run:" -ForegroundColor Green
    Write-Host "`"$CMakePath`" --build $BuildDir --config $BuildType" -ForegroundColor Cyan
    exit 0
}

$buildArgs = @(
    "--build", $BuildDir
    "--config", $BuildType
)

Write-Host ""
Write-Host "Starting build..." -ForegroundColor Yellow
$buildStartTime = Get-Date

& $CMakePath @buildArgs

$buildEndTime = Get-Date
$buildDuration = $buildEndTime - $buildStartTime

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    Write-Host "Build duration: $($buildDuration.ToString('hh\:mm\:ss'))" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "BUILD COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Build duration: $($buildDuration.ToString('hh\:mm\:ss'))" -ForegroundColor Yellow
Write-Host ""
Write-Host "To run Slicer:" -ForegroundColor Cyan
Write-Host "$BuildDir\Slicer-build\Slicer.exe" -ForegroundColor White
Write-Host ""
Write-Host "To run tests:" -ForegroundColor Cyan
Write-Host "$BuildDir\Slicer-build\Slicer.exe --VisualStudioProject" -ForegroundColor White
Write-Host "Then build the RUN_TESTS project in Visual Studio" -ForegroundColor White
Write-Host ""
Write-Host "To create installer package:" -ForegroundColor Cyan
Write-Host "$BuildDir\Slicer-build\Slicer.exe --VisualStudioProject" -ForegroundColor White
Write-Host "Then build the PACKAGE project in Visual Studio Release mode only" -ForegroundColor White
