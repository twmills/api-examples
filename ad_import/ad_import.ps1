#
# PowerShell script to import users from Active Directory into PagerDuty
# This script has been tested with Windows Server 2008 R2
#
# Copyright (c) 2013, PagerDuty, Inc. <info@pagerduty.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of PagerDuty Inc nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL PAGERDUTY INC BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Import-Module ActiveDirectory
#Import users via the PD API, echo results function POST_Request ($url,$parameters, $api_key) {     $http_request = New-Object -ComObject Msxml2.XMLHTTP     $http_request.open('POST', $url, $false)     $http_request.setRequestHeader("Content-type", "application/json")     $token = "Token token=" + $api_key     $http_request.setRequestHeader("Authorization", $token)     $http_request.setRequestHeader("Content-length", $parameters.length)     $http_request.setRequestHeader("Connection", "close")     $http_request.send($parameters)     Write-Host "Server Response:" $http_request.statusText  }
$ad_group = Read-Host "Enter AD Group Name:"
#Pull all users from the specified group within Active Directory Get-ADGroup $ad_group | % {      $users = "Name,Email`r`n";     $_ | Get-ADGroupMember | % {          $user = Get-ADUser $_ -Properties *         $users += $user.Name + "," + $user.EmailAddress + "`r`n"     } }
#Get the authentication information and add each users via POST_Request $subdomain = Read-Host "Enter subdomain" $api_key = Read-Host "Enter API key" $requester_id = Read-Host "Enter Requester ID" $url = "https://" + $subdomain + ".pagerduty.com/api/v1/users" $parameters = New-Object Collections.Specialized.NameValueCollection; $users = ConvertFrom-Csv $users $users | % {      Write-Host "Importing user:" $_.Name     $parameters = "{`"requester_id`":`"" + $requester_id + "`",`"name`":`"" + $_.Name + "`",`"email`":`"" + $_.Email + "`"}"     POST_Request $url $parameters $api_key }
