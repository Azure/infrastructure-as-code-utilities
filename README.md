# Terraform Utilities

This repository contains a collection of utilities for working with Terraform.

## Utilities

The utilities available in this repository are:

### Bootstrap

Utility scripts for bootstrapping a Terraform environment by installing the required tooling.
    
#### `terraform-bootstrap/Install-ToolsForWindows.ps1

This script installs the base set of tools required for Terraform on Windows.

It includes the following tools:

* git CLI
* Terraform CLI
* Azure CLI
* Visual Studio Code extensions for Azure Terraform

How to run:

```powershell
$temporaryPath = "~/temp-tools/Install-ToolsForWindows.ps1"
New-Item -ItemType "file" $temporaryPath -Force
(Invoke-WebRequest "https://raw.githubusercontent.com/Azure/terraform-utilities/refs/heads/main/terraform-bootstrap/Install-ToolsForWindows.ps1").Content | Out-File $temporaryPath -Force
Invoke-Expression $temporaryPath
#Remove-Item $temporaryPath
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
