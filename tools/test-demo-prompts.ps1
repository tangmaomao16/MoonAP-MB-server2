param(
  [string]$BaseUrl = "http://127.0.0.1:3000"
)

$ErrorActionPreference = "Stop"

$cases = @(
  @{ Prompt = "Build an app where the user enters a Celsius temperature and gets the Fahrenheit temperature."; ExpectContract = $true },
  @{ Prompt = "Build an APP which can convert minutes into seconds, or vice versa."; ExpectContract = $true },
  @{ Prompt = "Build an app where the user enters two numbers and gets the sum."; ExpectContract = $true },
  @{ Prompt = "Build a BMI calculator using weight in kg and height in meters."; ExpectContract = $true },
  @{ Prompt = "Build a circle calculator that computes area and circumference from radius."; ExpectContract = $true },
  @{ Prompt = "Build a loan payment calculator using principal, annual interest rate, and months."; ExpectContract = $true },
  @{ Prompt = "Build a tip calculator with bill amount, tip percent, and number of people."; ExpectContract = $true },
  @{ Prompt = "Build a JSON formatter and validator."; ExpectContract = $true; ExpectText = "json-formatter" },
  @{ Prompt = "Build a text analyzer that counts characters, words, lines, and estimated reading time."; ExpectContract = $true; ExpectText = "text-analysis" },
  @{ Prompt = "Build a CSV analyzer that reports row count, column names, missing values, and numeric column summaries."; ExpectContract = $true; ExpectText = "csv-summary" },
  @{ Prompt = "Build a large FastQ file generator that creates a 1GB FASTQ file in the browser."; ExpectContract = $false; ExpectText = "FastQ" },
  @{ Prompt = "Build a large FastQ analyzer that reads a FastQ file in chunks and reports read count, base count, A C G T N, read length, and malformed records."; ExpectContract = $false; ExpectText = "FastQ" }
)

foreach ($case in $cases) {
  $requestJson = @{
    model = "gpt-5.4"
    messages = @(
      @{ role = "system"; content = "You only write MoonBit code." },
      @{ role = "user"; content = $case.Prompt }
    )
  } | ConvertTo-Json -Depth 8 -Compress

  $proxyBody = "URL`tmoonap://llm-sim/chat/completions`nHEADER`tcontent-type`tapplication/json`nBODY`n$requestJson"
  $response = Invoke-RestMethod -Method Post -Uri "$BaseUrl/api/llm/proxy" -Body $proxyBody -ContentType "text/plain"
  $content = [string]$response.choices[0].message.content

  $hasContract = $content.Contains("MOONAP_RUNTIME_SPEC_BEGIN")
  if ($hasContract -ne [bool]$case.ExpectContract) {
    throw "Unexpected runtime contract state for prompt: $($case.Prompt)"
  }
  if ($case.ContainsKey("ExpectText") -and !$content.Contains([string]$case.ExpectText)) {
    throw "Expected generated source to contain '$($case.ExpectText)' for prompt: $($case.Prompt)"
  }

  $compile = Invoke-RestMethod -Method Post -Uri "$BaseUrl/api/llm-sim/process-latest-response" -Body "" -ContentType "text/plain"
  if ($compile.ok -ne $true) {
    throw "Compile failed for prompt: $($case.Prompt). Status: $($compile.stage)"
  }

  [pscustomobject]@{
    ok = $true
    prompt = $case.Prompt
    has_contract = $hasContract
    stage = $compile.stage
  } | ConvertTo-Json -Compress
}
