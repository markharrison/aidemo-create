# Create AI Demo Environment 

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


# --- Azure Login ----
Write-Host "Authenticating ..."

$account_info = az account show --query "{user: user.name, subscriptionName: name, subscriptionId: id}" -o tsv 2>$null

if (-not $account_info) {
    Write-Host "Please log in."
    az login --use-device-code
    $account_info = az account show --query "{user: user.name, subscriptionName: name, subscriptionId: id}" -o tsv 2>$null
    if (-not $account_info) {
        Write-Host "$([char]0x2717) Login failed. Exiting..."  -ForegroundColor Red
        exit 1
    }
}

$user_name, $subscription_name, $subscription_id = $account_info -split "`t"
Write-Host "Logged in as: " -NoNewline
Write-Host "$user_name" -ForegroundColor Cyan
Write-Host "Subscription Name: " -NoNewline
Write-Host "$subscription_name" -ForegroundColor Cyan
Write-Host "Subscription ID: " -NoNewline
Write-Host "$subscription_id" -ForegroundColor Cyan

$choice = Read-Host "Do you want to continue with this subscription? (y/n)"
if ($choice -notmatch "^[yY]$") {
    $choice = Read-Host "Do you want to log out? (y/n)"
    if ($choice -match "^[yY]$") {
        Write-Host "Logging out..." 
        az logout
    }
    Write-Host "$([char]0x2717) Stopping script." -ForegroundColor Red
    exit 1
}

# --- Create Resource Group ----

Write-Host "`nCreating Resource Group ..."

$rgExists = az group exists --name $resourceGroup

if ($rgExists -eq "true") {
    Write-Host "Resource Group already exists: " -NoNewline
    Write-Host "$resourceGroup" -ForegroundColor Cyan
    $choice = Read-Host "Do you want to delete it? (y/n)"
    if ($choice -match "^[yY]$") {

        Write-Host "Deleting Resource Group ..."  

        $openAIAccounts = az cognitiveservices account list --resource-group $resourceGroup `
            --query "[?kind=='ComputerVision' || kind=='OpenAI' || kind=='FormRecognizer'].{name:name, resourceGroup:resourceGroup, location:location}" -o json | ConvertFrom-Json        
        foreach ($account in $openAIAccounts) {
            az cognitiveservices account delete --name $account.name --resource-group $account.resourceGroup 
            az cognitiveservices account purge --name $account.name --resource-group $account.resourceGroup --location $account.location  
        }

        az group delete --name $resourceGroup --yes  
        Write-Host "Resource Group deleted."  
    } 
    Write-Host "$([char]0x2717) Stopping script." -ForegroundColor Red
    exit 1
}

az group create --location $location --resource-group $resourceGroup --output none

if ($LASTEXITCODE -ne 0) {
    Write-Host "$([char]0x2717) Failed to create Resource Group." -ForegroundColor Red
    exit 1
}

Write-Host "$([char]0x2713) Resource Group created. " -ForegroundColor Green  
Write-Host "Name: "  -NoNewline
Write-Host "$resourceGroup " -ForegroundColor Cyan -NoNewline
Write-Host "Location: "  -NoNewline
Write-Host "$location " -ForegroundColor Cyan 

# --- Create Azure OpenAI Account ----

if ($csAzOpenAICreate) {

    Write-Host "`nCreating Azure OpenAI Account ..."

    az cognitiveservices account create `
        --name $csAzOpenAIName `
        --resource-group $resourceGroup `
        --location $csAzOpenAILocation `
        --kind OpenAI `
        --sku S0 `
        --yes `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Azure OpenAI Account." -ForegroundColor Red
        exit 1
    }

    Write-Host "$([char]0x2713) Azure OpenAI Account created. " -ForegroundColor Green  
    Write-Host "Name: " -NoNewline
    Write-Host "$csAzOpenAIName " -ForegroundColor Cyan -NoNewline
    Write-Host "Location: " -NoNewline
    Write-Host "$csAzOpenAILocation " -ForegroundColor Cyan -NoNewline

    $csAzOpenAIEndpoint = az cognitiveservices account show `
        --name $csAzOpenAIName `
        --resource-group $resourceGroup `
        --query properties.endpoint `
        --output tsv 

    $csAzOpenAIApiKey = az cognitiveservices account keys list `
        --name $csAzOpenAIName `
        --resource-group $resourceGroup `
        --query key1 `
        --output tsv 

    Write-Host "Endpoint: "  -NoNewline
    Write-Host "$csAzOpenAIEndpoint  " -ForegroundColor Cyan -NoNewline
    Write-Host "APIKey: "  -NoNewline
    Write-Host "$csAzOpenAIApiKey " -ForegroundColor Cyan  

    Write-Host "Models Available:" 

    az cognitiveservices account list-models -n $csAzOpenAIName -g $resourceGroup -o table 

}

# --- Create Chat Completion Model ----

if ($modelChatCompletionCreate) {

    Write-Host "`nCreating Chat Completion Model ..."

    az cognitiveservices account deployment create `
        --resource-group $resourceGroup `
        --name $csAzOpenAIName `
        --deployment-name $modelChatCompletionDeploymentName `
        --model-name $modelChatCompletionName `
        --model-version $modelChatCompletionVersion `
        --model-format $modelChatCompletionFormat `
        --sku-name $modelChatCompletionScaleType `
        --sku-capacity $modelChatCompletionSkuCapacity `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Chat Completion Model." -ForegroundColor Red
        exit 1
    }

    Write-Host "$([char]0x2713) Chat Completion Model created. " -ForegroundColor Green  
    Write-Host "Deployment Name: " -NoNewline
    Write-Host "$modelChatCompletionDeploymentName " -ForegroundColor Cyan -NoNewline
    Write-Host "Model: " -NoNewline
    Write-Host "$modelChatCompletionName " -ForegroundColor Cyan -NoNewline
    Write-Host "Version: "  -NoNewline
    Write-Host "$modelChatCompletionVersion" -ForegroundColor Cyan
}

# --- Create Text Embedding Model ----

if ($modelEmbeddingCreate) {
    Write-Host "`nCreating Text Embedding Model ..."


    az cognitiveservices account deployment create `
        --resource-group $resourceGroup `
        --name $csAzOpenAIName `
        --deployment-name $modelEmbeddingDeploymentName `
        --model-name $modelEmbeddingName `
        --model-version $modelEmbeddingVersion `
        --model-format $modelEmbeddingFormat `
        --sku-name $modelEmbeddingScaleType `
        --sku-capacity $modelEmbeddingSkuCapacity `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Text Embedding Model." -ForegroundColor Red
        exit 1
    }

    Write-Host "$([char]0x2713) Text Embedding Model created. " -ForegroundColor Green 
    Write-Host "Deployment: " -NoNewline
    Write-Host "$modelEmbeddingDeploymentName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Model: " -NoNewline
    Write-Host "$modelEmbeddingName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Version: " -NoNewline
    Write-Host "$modelEmbeddingVersion " -ForegroundColor Cyan  
}


# --- Create Dall-E Model ----

if ($modelImageGenCreate) {
    Write-Host "`nCreating Dall-E Model ..."

    az cognitiveservices account deployment create `
        --resource-group $resourceGroup `
        --name $csAzOpenAIName `
        --deployment-name $modelImageGenDeploymentName `
        --model-name $modelImageGenName `
        --model-version $modelImageGenVersion `
        --model-format $modelImageGenFormat `
        --sku-name $modelImageGenScaleType `
        --sku-capacity $modelImageGenSkuCapacity `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Dall-E Model." -ForegroundColor Red
        exit 1
    }

    Write-Host "$([char]0x2713) Dall-E Model created. " -ForegroundColor Green  
    Write-Host "Deployment Name: " -NoNewline
    Write-Host "$modelImageGenDeploymentName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Model:" -NoNewline
    Write-Host "$modelImageGenName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Version: " -NoNewline
    Write-Host "$modelImageGenVersion " -ForegroundColor Cyan 
}

# --- Create AI Vision Service ----

if ($csVisionCreate) {
    Write-Host "`nCreating AI Vision Service ..."

    az cognitiveservices account create `
        --name $csVisionName `
        --resource-group $resourceGroup `
        --location $csVisionLocation `
        --kind ComputerVision `
        --sku $csVisionSku `
        --yes `
        --output none 

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create AI Vision Service." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "$([char]0x2713) AI Vision Service created. " -ForegroundColor Green 
    Write-Host "Name: " -NoNewline
    Write-Host "$csVisionName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Location: " -NoNewline
    Write-Host "$csVisionLocation " -ForegroundColor Cyan  -NoNewline
    Write-Host "Sku: " -NoNewline
    Write-Host "$csVisionSku " -ForegroundColor Cyan  -NoNewline

    $csVisionEndpoint = az cognitiveservices account show `
        --name $csVisionName `
        --resource-group $resourceGroup `
        --query properties.endpoint `
        --output tsv 

    $csVisionApiKey = az cognitiveservices account keys list `
        --name $csVisionName `
        --resource-group $resourceGroup `
        --query key1 `
        --output tsv 

    Write-Host "Endpoint: " -NoNewline
    Write-Host "$csVisionEndpoint " -ForegroundColor Cyan  -NoNewline
    Write-Host "APIKey: " -NoNewline
    Write-Host "$csVisionApiKey " -ForegroundColor Cyan  
}

# --- Create Azure AI Search ----

if ($aiSearchCreate ) {
    Write-Host "`nCreating Azure AI Search ..."

    az search service create `
        --name $aiSearchName `
        --resource-group $resourceGroup `
        --location $aiSearchLocation `
        --sku $aiSearchSku `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Azure AI Search." -ForegroundColor Red
        exit 1
    }

    Write-Host "$([char]0x2713) Azure AI Search created. " -ForegroundColor Green 
    Write-Host "Name: " -NoNewline
    Write-Host "$aiSearchName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Location: " -NoNewline
    Write-Host "$aiSearchLocation " -ForegroundColor Cyan  -NoNewline
    Write-Host "Sku: " -NoNewline
    Write-Host "$aiSearchSku " -ForegroundColor Cyan   -NoNewline

    $aiSearchEndpoint = "https://$aiSearchName.search.windows.net"

    $aiSearchApiKey = az search admin-key show `
        --resource-group $resourceGroup `
        --service-name $aiSearchName `
        --query primaryKey `
        --output tsv 

    Write-Host "Endpoint: " -NoNewline
    Write-Host "$aiSearchEndpoint " -ForegroundColor Cyan  -NoNewline
    Write-Host "APIKey: " -NoNewline
    Write-Host "$aiSearchApiKey " -ForegroundColor Cyan  
}

# --- Create Document Intelligence ----

if ($csDocIntelliCreate) {
    Write-Host "`nCreating Document Intelligence Service ..."

    az cognitiveservices account create `
        --name $csDocIntelliName `
        --resource-group $resourceGroup `
        --kind FormRecognizer `
        --sku $csDocIntelliSku `
        --location $csDocIntelliLocation `
        --yes `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Document Intelligence Service." -ForegroundColor Red
        exit 1
    }

    Write-Host "$([char]0x2713) Document Intelligence Service created. " -ForegroundColor Green 
    Write-Host "Name: " -NoNewline
    Write-Host "$csDocIntelliName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Location: " -NoNewline
    Write-Host "$csDocIntelliLocation " -ForegroundColor Cyan  -NoNewline
    Write-Host "Sku: " -NoNewline
    Write-Host "$csDocIntelliSku " -ForegroundColor Cyan  -NoNewline


    $csDocIntelliApiKey = az cognitiveservices account keys list `
        --name $csDocIntelliName `
        --resource-group $resourceGroup `
        --query key1 `
        --output tsv
 
    $csDocIntelliEndpoint = az cognitiveservices account show `
        --name $csDocIntelliName `
        --resource-group $resourceGroup `
        --query properties.endpoint `
        --output tsv

    Write-Host "Endpoint: " -NoNewline
    Write-Host "$csDocIntelliEndpoint " -ForegroundColor Cyan  -NoNewline
    Write-Host "APIKey: " -NoNewline
    Write-Host "$csDocIntelliApiKey " -ForegroundColor Cyan  
}
# --- Create Storage Account --- 

if ($stgCreate) {
    Write-Host "`nCreating Storage Account ..."

    az storage account create `
        --name $stgName `
        --resource-group $resourceGroup `
        --location $stgLocation `
        --sku $stgSku `
        --kind StorageV2 `
        --https-only true `
        --access-tier Hot `
        --output none

    if ($LASTEXITCODE -ne 0) {
        Write-Host "$([char]0x2717) Failed to create Document Intelligence Service." -ForegroundColor Red
        exit 1
    }    

    Write-Host "$([char]0x2713) Storage Account created. " -ForegroundColor Green 
    Write-Host "Name: " -NoNewline
    Write-Host "$stgName " -ForegroundColor Cyan  -NoNewline
    Write-Host "Location: " -NoNewline
    Write-Host "$stgLocation " -ForegroundColor Cyan  -NoNewline

    $stgConnectionString = az storage account show-connection-string `
        --name $stgName `
        --resource-group $resourceGroup `
        --query connectionString `
        --output tsv 

    Write-Host "ConnectionString: " -NoNewline
    Write-Host "$stgConnectionString " -ForegroundColor Cyan     
}

# --- Store configuration  ----

Write-Host "`nCreating Configuration file ..."
 
$configurationFile = "./Configuration/application.env"
New-Item -Name $configurationFile -ItemType File -Force  > $null

function Set-ConfigurationFileVariable($configurationFile, $variableName, $variableValue) {
    if (Select-String -Path $configurationFile -Pattern $variableName) {
        (Get-Content $configurationFile) | Foreach-Object {
            $_ -replace "$variableName = .*", "$variableName = $variableValue"
        } | Set-Content $configurationFile
    } else {
        Add-Content -Path $configurationFile -value "$variableName = $variableValue"
    }
}

Set-ConfigurationFileVariable $configurationFile "resourceGroup" $resourceGroup
Set-ConfigurationFileVariable $configurationFile "location" $location 
Set-ConfigurationFileVariable $configurationFile "csAzOpenAIName" ($prefix + "-azopenai-" + $random)
Set-ConfigurationFileVariable $configurationFile "csAzOpenAIApiKey" $csAzOpenAIApiKey 
Set-ConfigurationFileVariable $configurationFile "csAzOpenAIEndpoint" $csAzOpenAIEndpoint
Set-ConfigurationFileVariable $configurationFile "modelChatCompletionDeploymentName" $modelChatCompletionDeploymentName
Set-ConfigurationFileVariable $configurationFile "modelEmbeddingDeploymentName" $modelEmbeddingDeploymentName
Set-ConfigurationFileVariable $configurationFile "modelImageDeploymentName" $modelImageGenDeploymentName
Set-ConfigurationFileVariable $configurationFile "csVisionName" ($prefix + "-aivision-" + $random)
Set-ConfigurationFileVariable $configurationFile "csVisionApiKey" $csVisionApiKey
Set-ConfigurationFileVariable $configurationFile "csVisionEndpoint" $csVisionEndpoint
Set-ConfigurationFileVariable $configurationFile "csDocIntelliName" ($prefix + "-docintelli-" + $random)
Set-ConfigurationFileVariable $configurationFile "csDocIntelliApiKey" $csDocIntelliApiKey
Set-ConfigurationFileVariable $configurationFile "csDocIntelliEndpoint" $csDocIntelliEndpoint
Set-ConfigurationFileVariable $configurationFile "aiSearchName" ($prefix + "-aisearch-" + $random)
Set-ConfigurationFileVariable $configurationFile "aiSearchApiKey" $aiSearchApiKey
Set-ConfigurationFileVariable $configurationFile "aiSearchEndpoint" $aiSearchEndpoint
Set-ConfigurationFileVariable $configurationFile "stgName" ($prefix + "storage" + $random)
Set-ConfigurationFileVariable $configurationFile "stgConnectionString" $stgConnectionString

# Set-ConfigurationFileVariable $configurationFile "CFG_ASSETS_FOLDER" "../../assets"
 
Write-Host "$([char]0x2713) Configuration file created."  -ForegroundColor Green
Write-Host "File location: " -NoNewline
Write-Host "$configurationFile" -ForegroundColor Cyan -NoNewline
