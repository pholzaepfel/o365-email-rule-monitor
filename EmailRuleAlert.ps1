Param(
		[string]$officeusername
     )

#extract password from credential file 
	$PwdSecureString = Get-Content "$($env:USERPROFILE)\temp.cred" | ConvertTo-SecureString
	$Credential = New-Object System.Management.Automation.PSCredential -ArgumentList $officeusername, $PwdSecureString

	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Credential -Authentication Basic -AllowRedirection
	Import-PSSession $Session

	$startDate=$(Get-Date).ToUniversalTime().AddMinutes(-30).ToString()
	$endDate=$(Get-Date).ToUniversalTime().AddHours(24).ToString()

#generate header with search date/time
	$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
	echo "Search time:" >header.log
	Get-Date >>header.log
	echo "Date range:" >>header.log
	echo "$startDate $endDate" >>header.log
	type header.log >monitor.log

#execute search for new inbox rules
	Search-UnifiedAuditLog -StartDate $startDate -EndDate $endDate -FreeText "New-InboxRule" -SessionId "New-InboxRule $startDate $endDate" -SessionCommand ReturnLargeSet >rules.log

#if there are new inbox rules, email to alert

	if( (Get-ChildItem "rules.log").length -ne 0) {
		type rules.log >>monitor.log
			$emailBody = (Get-Content -Path "monitor.log" | Out-String)
			$recipients = $officeusername
			$Params = @{                                            
				'From' = $officeusername
					'To' = $officeusername
					'Subject' = 'Mail Rule Alert - New Rule Created'      
					'SmtpServer' = 'smtp.office365.com'     
					'Port' = '587'                          
					'Body' = $emailBody                     
					'Credential' = $Credential
			}                                                       
		Send-MailMessage @Params -UseSsl                 
	}       

#generate a history file for diagnostics
type monitor.log >>"monitor-history.log"
