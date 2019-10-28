[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="Enter your config name defined in developers.json: ")][string]$configName,
    $skipBuild
)

$environment = Get-Content 'developers.json' | Out-String | ConvertFrom-Json
$stageEnvironment = Get-Content 'stage.json' | Out-String | ConvertFrom-Json

$config = $environment.$configName
$stageConfig = $stageEnvironment.Parameters

$developerPrefix = $config.Prefix

Write-Host "`Parameters from " -NoNewline
Write-Host "developers.json:`n" -ForegroundColor Cyan
Write-Host "`tdeveloperPrefix: `t`t $developerPrefix" -ForegroundColor Yellow

$sourceFile = "samTemplate.yaml"
$localFileName = "$sourceFile.local"
Write-Host "`nCreating/updating $localFileName based on $sourceFile..."

Copy-Item samTemplate.yaml $localFileName

if ($config.Prefix) # Is a Developer
{  
    Write-Host "`n`tDeveloper config selected" -ForegroundColor Yellow

    (Get-Content $localFileName) `
        -replace 'pecuniary-', "$developerPrefix-pecuniary-" `
        -replace 'Name: pecuniary', "Name: $developerPrefix-pecuniary" |
    Out-File $localFileName -Encoding utf8
}

Write-Host "`nDone! $localFileName updated. Please use this file when deploying to our own AWS stack.`n"

if (!$config.Prefix) { exit 0 } # Is Staging or Production

Write-Host "Press [enter] to continue deploying stack to AWS (Ctrl+C to exit)" -NoNewline -ForegroundColor Green
Read-Host

$samTemplate = 'samTemplate.yaml.local'

if ($skipBuild)
{
    Write-Host "Skipping build"
}
else
{
    Write-Host "`n`nPrebuild:"
    
    dotnet restore Pecuniary.Security.Events/Pecuniary.Security.Events.csproj
    dotnet restore Pecuniary.Security.Query/Pecuniary.Security.Query.csproj
    
    Write-Host "`n`nBuild:"
    
    dotnet publish Pecuniary.Security.Events/Pecuniary.Security.Events.csproj
    dotnet publish Pecuniary.Security.Query/Pecuniary.Security.Query.csproj
}
  
Write-Host "`n`nDeploy:"

dotnet-lambda deploy-serverless `
    --stack-name $developerPrefix-pecuniary-securityquery-stack `
    --template $samTemplate `
    --region us-west-2 `
    --s3-prefix $developerPrefix- `
    --s3-bucket pecuniary1-deployment-artifacts

# Get the API Gateway Base URL
$stack = aws cloudformation describe-stacks --stack-name $developerPrefix-pecuniary-securityquery-stack | ConvertFrom-Json
$outputKey = $stack.Stacks.Outputs.OutputKey.IndexOf("PecuniaryApiGatewayBaseUrl")
$apiGatewayBaseUrl = $stack.Stacks.Outputs[$outputKey].OutputValue

# Add scopes
Write-Host "`n`Adding Scopes to $apiGatewayBaseUrl"
aws lambda invoke `
    --function-name "$developerPrefix-pecuniary-AddScopes" `
    --payload """{ """"ApiGatewayBaseUrl"""": """"$apiGatewayBaseUrl"""" }""" `
    outfile.json
Remove-Item outfile.json

Write-Host "`n`n YOUR STACK NAME IS:   $developerPrefix-pecuniary-securityquery-stack   `n`n"