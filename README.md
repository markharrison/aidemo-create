# AIDemo Create

## Intro

Uses Azure CLI to create:

- Resource Group
- Azure Open AI
- Model deployments
  - Chat completion
  - Text embedding
  - Image generation
- AI Search
- Computer Vision
- Document Intelligence
- Storage Account

## How to setup

Set values at top of script - for example:

```powershell
$prefix = "mark"
$random = Get-Random -Minimum 1000 -Maximum 9999

$resourceGroup = $prefix + "-aidemo-rg" 
$location = "swedencentral"

$csAzOpenAICreate = $true
    $csAzOpenAIName = $prefix + "-azopenai-" + $random
    $csAzOpenAILocation = $location 

$modelChatCompletionCreate = $true
    $modelChatCompletionFormat = "OpenAI"
    $modelChatCompletionDeploymentName = "gpt-4o"
    $modelChatCompletionName = "gpt-4o"
    $modelChatCompletionVersion = "2024-05-13"
    $modelChatCompletionScaleType = "Standard"
    $modelChatCompletionSkuCapacity = 25

$modelEmbeddingCreate = $true 
    $modelEmbeddingFormat = "OpenAI"
    $modelEmbeddingDeploymentName = "textembedding-ada-002"
    $modelEmbeddingName = "text-embedding-ada-002"
    $modelEmbeddingVersion = "2"
    $modelEmbeddingScaleType = "Standard"
    $modelEmbeddingSkuCapacity = 100

$modelImageGenCreate = $false
    $modelImageGenFormat = "OpenAI"
    $modelImageGenDeploymentName = "dall-e-3"
    $modelImageGenName = "dall-e-3"
    $modelImageGenVersion = "3.0"
    $modelImageGenScaleType = "Standard"
    $modelImageGenSkuCapacity = "Standard"

$aiSearchCreate = $true
    $aiSearchName = $prefix + "-aisearch-" + $random
    $aiSearchSku = "Basic"
    $aiSearchLocation = $location

$csVisionCreate = $false
    $csVisionName = $prefix + "-aivision-" + $random
    $csVisionSku = "F0"   # F0=Free, S1=Standard
    $csVisionLocation = $location

$csDocIntelliCreate = $false
    $csDocIntelliName = $prefix + "-docintelli-" + $random
    $csDocIntelliSku = "F0"   # F0=Free, S0=Standard
    $csDocIntelliLocation = $location
 
$stgCreate = $false 
    $stgName = $prefix + "storage" + $random
    $stgSku = "Standard_LRS"
    $stgLocation = $location
```

## How to run

```powershell
..\createenv.ps1
```

## Output

Generated file `application.env` contains:

```text
resourceGroup = mark-aidemo-rg
location = swedencentral
csAzOpenAIName = mark-azopenai-8929
csAzOpenAIApiKey = xxx
csAzOpenAIEndpoint = https://xxxx
modelChatCompletionDeploymentName = gpt-4o
modelEmbeddingDeploymentName = textembedding-ada-002
modelImageDeploymentName = dall-e-3
csVisionName = mark-aivision-8929
csVisionApiKey = 
csVisionEndpoint = https://xxxx
csDocIntelliName = mark-docintelli-8929
csDocIntelliApiKey = 
csDocIntelliEndpoint = https://xxxx
aiSearchName = mark-aisearch-8929
aiSearchApiKey = xxx
aiSearchEndpoint = https://xxxx
stgName = markstorage8929
stgConnectionString = 
```
