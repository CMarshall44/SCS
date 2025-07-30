Function Add-TempMaintenanceWindow{
	#TODO add checks on the policy
	$Schedule = "007B88EC020080000"
	Set-WmiInstance -Class CCM_ServiceWindow -Namespace 'ROOT\ccm\Policy\Machine\RequestedConfig' -PutType 'CreateOnly' -argument @{PolicySource = 'LOCAL'; PolicyRuleID = 'NONE'; PolicyVersion = '1.0'; Schedules = $Schedule; ServiceWindowType = 1; ServiceWindowID = '00000000-0000-0000-0000-000000000001'; PolicyID = '00000000-0000-0000-0000-000000000001'; PolicyInstanceID = '00000000-0000-0000-0000-000000000001'};$a.ServiceWindowID
}