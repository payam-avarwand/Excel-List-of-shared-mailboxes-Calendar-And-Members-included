# This Script creates an excel list of all enabled shared mailboxes in all our foreign offices with three parameters per record: Name + WhenCreated + Members

############################################################
#Create a session to Exchange Server

$Session=New-PSSession -ConfigurationName microsoft.exchange -ConnectionUri http://EXCHANGEServerNAME/powershell
Import-PSSession $Session

############################################################
#Create_the_Excel_Object

$excel_Obj = New-Object -ComObject Excel.Application
$excel_Obj.visible = $false
$workbook = $excel_Obj.Workbooks.Add()
$Sheet= $workbook.Worksheets.Item(1)

$D = Get-Date -Format 'dd-MM-yyyy'
$Sheet.Name = "SharedMailbxes"

############################################################
#Titles
                            $Sheet.Cells.Item(1,2) = "Shared mailbox name"
                            $Sheet.Cells.Item(1,3) = "Creation date"

############################################################
#Get_the_Office_Names
$i1=2

Import-Csv H:\CSV-Lists\Cities.csv | ForEach-Object {
$City0= $_.City0
$City1= $_.City1
$City2= $_.City2
                            $Sheet.Cells.Item($i1,1) = $City0

############################################################
#Get_Shared_Mailboxes:
        $i1=$i1+1

        $List= Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | Where-Object {($_.Name -like "*$City0*") -or ($_.Name -like "*$City1*") -or ($_.Name -like ".$City2*")} | select name | Sort-Object -Property name
            $K0=1
            foreach ($SH1 in $List){
            $SH_Names=$SH1.name
            $Sheet.Cells.Item($i1,1) = $K0
            $Sheet.Cells.Item($i1,2) = $SH_Names

############################################################
#Creation_Date
                $DAT = Get-Mailbox -Identity $SH_Names -RecipientTypeDetails SharedMailbox | select whenCreated -ExpandProperty whenCreated
                $Sheet.Cells.Item($i1,3) = $DAT

############################################################
#Members
                $Members=Get-MailboxPermission $SH_Names | Where-Object {($_.IsInherited -eq $False) -and -not ($_.User -like "*NT*AUT*") -and -not ($_.User -like "*Exchange*") -and -not ($_.User -like "*Backup*") -and -not ($_.User -like "*5-21-*") | Select user -ExpandProperty user | Sort-Object -Property name
                
                $i1++
                $j1 = $i1
                
                foreach ($M1 in $Members){
                    $M2=$M1.Remove(0,4)
                    $Sheet.Cells.Item($j1,2) = $M2
                    $j1++
                }
            $i1 = $j1
            $K0++
            }
    }

############################################################
# Format and Save the List + Close the File 

$usedRange = $Sheet.UsedRange                                                                                              
$usedRange.EntireColumn.AutoFit()
$workbook.SaveAs("F:\ExcelList\ShMbxs_$D.xlsx")
$excel_Obj.Quit()

#Created_by_Payam.Avarwand
#Payam_avar@yahoo.com
