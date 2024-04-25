$MAVEN_HOME = "D:\Program Files\maven\apache-maven-3.8.8"
$MVN = Join-Path $MAVEN_HOME "bin\mvn.cmd"

$bin = Split-Path -Parent $MyInvocation.MyCommand.Definition
$bin = (Resolve-Path "$bin\..").Path
$APP_HOME = (Resolve-Path "$bin\..").Path

Write-Host "Deploy the project ..."
Write-Host "Changing version ..."

$SNAPSHOT_VERSION = Get-Content "$APP_HOME\VERSION" -TotalCount 1
$VERSION =$SNAPSHOT_VERSION -replace "-SNAPSHOT", ""
$VERSION | Set-Content "$APP_HOME\VERSION"

Get-ChildItem -Path "$APP_HOME" -Depth 2 -Filter 'pom.xml' -Recurse | ForEach-Object {
  (Get-Content $_.FullName) -replace $SNAPSHOT_VERSION, $VERSION | Set-Content $_.FullName
}

& $MVN deploy -Pplaton-deploy

$exitCode =$LastExitCode
if ($exitCode -eq 0) {
  Write-Host "Build successfully"
} else {
  exit $exitCode
}

Write-Host "Artifacts are staged remotely, you should close and release the staging manually:"
Write-Host "https://oss.sonatype.org/#stagingRepositories"
Write-Host "Hit the following link to check if the artifacts are synchronized to the maven center: "
Write-Host "https://repo1.maven.org/maven2/ai/platon/pulsar"
