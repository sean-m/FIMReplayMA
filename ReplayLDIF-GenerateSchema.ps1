PARAM(
    [string]$schemaFile = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\FIM MA\schema.ldif",
    [string]$MAFile = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\FIM MA\FIMMA.Schema.xml",
    $excludeTypes = @("SynchronizationRule","ExpectedRuleEntry","DetectedRuleEntry")
)
cls

# Usage:
# $schemaFile = full path and filename of target LDIF file to be generated from this script
# $MAFile = full path and filename of exported MA (e.g. FIM MA) xml file from the FIM Sync Server (or ILM2007 FP1)
# $excludeTypes = string array of object types to be excluded from the generated LDIF

# Copyright (c) 2012, Unify Solutions Pty Ltd
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#----------------------------------------------------------------------------------------------------------
 Function LDIFPair
 {
    Param([string]$item1, [string]$item2)
    End
    {
      [string]$LDIFPair = $item1 + ": " + $item2
      $LDIFPair
    }
 }
#----------------------------------------------------------------------------------------------------------

if (Test-Path $schemaFile) {Remove-Item -Path $schemaFile}

[xml]$maConfig = Get-Content $MAFile

$schema = $maconfig."export-ma"."ma-data"."private-configuration"."fimma-configuration"."mms-info"

foreach ($objType in $schema."column-info")
{
  $objTypeName = $objType.name
  if (!($excludeTypes -Contains $objTypeName))
  {
    LDIFPair "dn" $objTypeName | Add-Content -Path $schemaFile
    LDIFPair "objectClass" $objTypeName | Add-Content -Path $schemaFile

    $Attributes = @{}

    foreach ($attr in $objType.column)
    {
      $attrName = $attr.name
      $isMV = "yes"
      if ($attr.ismultivalued -eq 0){$isMV = "no"}
      $Attributes.Add($attrName, $isMV)
    }  
    
    $SortedAttributes = $Attributes.Keys | sort-object
    foreach ($attrName in $SortedAttributes)
    {
      if ($Attributes.Item($attrName) -eq "no")
      {
        LDIFPair $attrName "dummy1" | Add-Content -Path $schemaFile
      }
      else
      {
        LDIFPair $attrName "dummy1" | Add-Content -Path $schemaFile
        LDIFPair $attrName "dummy2" | Add-Content -Path $schemaFile
      }
    }
    Add-Content -Path $schemaFile -Value `n
  }
}
#------------------------------------------------------------------------------------------------------
 trap
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit
 }
#------------------------------------------------------------------------------------------------------
