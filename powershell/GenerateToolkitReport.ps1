# ===========================================
# Engineering Support Automation Toolkit
# Generate Toolkit Report
# ===========================================

Clear-Host

Write-Host ""
Write-Host "==============================================" -ForegroundColor DarkGray
Write-Host " Engineering Support Automation Toolkit" -ForegroundColor Cyan
Write-Host " Generate Toolkit Report" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor DarkGray
Write-Host ""

# --------------------------------------------------
# Start Time
# --------------------------------------------------

$StartTime = Get-Date

Write-Host "Started :" -ForegroundColor Yellow -NoNewline
Write-Host " $StartTime"

# --------------------------------------------------
# Project Root
# --------------------------------------------------

$ProjectRoot = Split-Path $PSScriptRoot -Parent

# --------------------------------------------------
# Folder Paths
# --------------------------------------------------

$PdfFolder      = Join-Path $ProjectRoot "excel\Workbook\pdf"
$ReportsFolder  = Join-Path $ProjectRoot "reports"
$LogsFolder     = Join-Path $ProjectRoot "logs"

# --------------------------------------------------
# Create Required Folders
# --------------------------------------------------

New-Item -ItemType Directory -Force -Path $ReportsFolder | Out-Null
New-Item -ItemType Directory -Force -Path $LogsFolder | Out-Null

# --------------------------------------------------
# Display Environment
# --------------------------------------------------

Write-Host ""
Write-Host "Project Root" -ForegroundColor Cyan
Write-Host "-------------"
Write-Host $ProjectRoot

Write-Host ""
Write-Host "Source PDF Folder" -ForegroundColor Cyan
Write-Host "-----------------"
Write-Host $PdfFolder

# --------------------------------------------------
# Validate PDF Folder
# --------------------------------------------------

if (-not (Test-Path $PdfFolder))
{
    Write-Host ""
    Write-Host "ERROR: Excel PDF folder was not found." -ForegroundColor Red
    exit
}

# --------------------------------------------------
# Find Latest Dashboard Report
# --------------------------------------------------

$LatestPdf = Get-ChildItem `
    -Path $PdfFolder `
    -Filter "*.pdf" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if ($null -eq $LatestPdf)
{
    Write-Host ""
    Write-Host "ERROR: No dashboard reports were found." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Latest Dashboard Report" -ForegroundColor Green
Write-Host "-----------------------"
Write-Host $LatestPdf.Name

# --------------------------------------------------
# Create Report Archive Folder
# --------------------------------------------------

$TodayFolder = Join-Path `
    $ReportsFolder `
    (Get-Date -Format "yyyy-MM-dd")

New-Item `
    -ItemType Directory `
    -Force `
    -Path $TodayFolder | Out-Null

# --------------------------------------------------
# Copy Report
# --------------------------------------------------

$DestinationFile = Join-Path `
    $TodayFolder `
    $LatestPdf.Name

Copy-Item `
    -Path $LatestPdf.FullName `
    -Destination $DestinationFile `
    -Force

Write-Host ""
Write-Host "Dashboard report archived successfully." -ForegroundColor Green

Write-Host ""
Write-Host "Destination" -ForegroundColor Cyan
Write-Host "-----------"
Write-Host $DestinationFile

# --------------------------------------------------
# Create Log
# --------------------------------------------------

$LogFile = Join-Path `
    $LogsFolder `
    ("ToolkitLog_" + (Get-Date -Format "yyyyMMdd") + ".txt")

$Log = @"
==============================================
Engineering Support Automation Toolkit
==============================================

Date:
$(Get-Date)

Latest Report:
$($LatestPdf.Name)

Source:
$($LatestPdf.FullName)

Destination:
$DestinationFile

Status:
SUCCESS

"@

$Log | Out-File `
    $LogFile `
    -Encoding UTF8

Write-Host ""
Write-Host "Log file created." -ForegroundColor Green
Write-Host $LogFile

# --------------------------------------------------
# Open Report Folder
# --------------------------------------------------

Start-Process $TodayFolder

# --------------------------------------------------
# Finish
# --------------------------------------------------

$EndTime = Get-Date

Write-Host ""
Write-Host "==============================================" -ForegroundColor DarkGray
Write-Host " Report Package Completed Successfully!" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor DarkGray

Write-Host ""
Write-Host "Finished :" -ForegroundColor Yellow -NoNewline
Write-Host " $EndTime"

Write-Host ""