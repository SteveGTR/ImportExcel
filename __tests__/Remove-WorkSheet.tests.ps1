﻿#Requires -Modules Pester
Import-Module $PSScriptRoot\..\ImportExcel.psd1 -Force
if (-not $env:TEMP) {$env:TEMP = [IO.Path]::GetTempPath() -replace "/$","" }

Describe "Remove Worksheet" {
    Context "Remove a worksheet output" {
        BeforeEach {
            # Create three sheets
            $data = ConvertFrom-Csv @"
Name,Age
Jane,10
John,20
"@
            $xlFile1 = Join-Path $Env:TEMP "removeWorsheet1.xlsx"
            Remove-Item $xlFile1 -ErrorAction SilentlyContinue

            $data | Export-Excel -Path $xlFile1 -WorksheetName Target1
            $data | Export-Excel -Path $xlFile1 -WorksheetName Target2
            $data | Export-Excel -Path $xlFile1 -WorksheetName Target3
            $data | Export-Excel -Path $xlFile1 -WorksheetName Sheet1

            $xlFile2 = Join-Path $Env:TEMP "removeWorsheet2.xlsx"
            Remove-Item $xlFile2 -ErrorAction SilentlyContinue

            $data | Export-Excel -Path $xlFile2 -WorksheetName Target1
            $data | Export-Excel -Path $xlFile2 -WorksheetName Target2
            $data | Export-Excel -Path $xlFile2 -WorksheetName Target3
            $data | Export-Excel -Path $xlFile2 -WorksheetName Sheet1
        }

        it "Should throw about the Path".PadRight(87)  {
            {Remove-WorkSheet} | Should throw 'Remove-WorkSheet requires the and Excel file'
        }

        it "Should delete Target2".PadRight(87)  {
            Remove-WorkSheet -Path $xlFile1 -WorksheetName Target2

            $actual = Get-ExcelSheetInfo -Path $xlFile1

            $actual.Count   | Should Be 3
            $actual[0].Name | Should Be "Target1"
            $actual[1].Name | Should Be "Target3"
            $actual[2].Name | Should Be "Sheet1"
        }

        it "Should delete Sheet1".PadRight(87)  {
            Remove-WorkSheet -Path $xlFile1

            $actual = Get-ExcelSheetInfo -Path $xlFile1

            $actual.Count   | Should Be 3
            $actual[0].Name | Should Be "Target1"
            $actual[1].Name | Should Be "Target2"
            $actual[2].Name | Should Be "Target3"
        }

        it "Should delete multiple sheets".PadRight(87)  {
            Remove-WorkSheet -Path $xlFile1 -WorksheetName Target1, Sheet1

            $actual = Get-ExcelSheetInfo -Path $xlFile1

            $actual.Count   | Should Be 2
            $actual[0].Name | Should Be "Target2"
            $actual[1].Name | Should Be "Target3"
        }

        it "Should delete sheet from multiple workbooks".PadRight(87)  {

            Get-ChildItem (Join-Path $Env:TEMP "removeWorsheet*.xlsx") | Remove-WorkSheet

            $actual = Get-ExcelSheetInfo -Path $xlFile1

            $actual.Count   | Should Be 3
            $actual[0].Name | Should Be "Target1"
            $actual[1].Name | Should Be "Target2"
            $actual[2].Name | Should Be "Target3"
        }
    }
}