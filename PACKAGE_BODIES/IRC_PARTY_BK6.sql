--------------------------------------------------------
--  DDL for Package Body IRC_PARTY_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PARTY_BK6" as
/* $Header: irhzpapi.pkb 120.30.12010000.24 2010/05/17 08:33:06 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:54 (YYYY/MM/DD HH24:MI:SS)
procedure SELF_REGISTER_USER_A
(P_CURRENT_EMAIL_ADDRESS in VARCHAR2
,P_RESPONSIBILITY_ID in NUMBER
,P_RESP_APPL_ID in NUMBER
,P_SECURITY_GROUP_ID in NUMBER
,P_FIRST_NAME in VARCHAR2
,P_LAST_NAME in VARCHAR2
,P_MIDDLE_NAMES in VARCHAR2
,P_PREVIOUS_LAST_NAME in VARCHAR2
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_NATIONAL_IDENTIFIER in VARCHAR2
,P_DATE_OF_BIRTH in DATE
,P_EMAIL_ADDRESS in VARCHAR2
,P_HOME_PHONE_NUMBER in VARCHAR2
,P_WORK_PHONE_NUMBER in VARCHAR2
,P_ADDRESS_LINE_1 in VARCHAR2
,P_MANAGER_LAST_NAME in VARCHAR2
,P_ALLOW_ACCESS in VARCHAR2
,P_LANGUAGE in VARCHAR2
,P_USER_NAME in VARCHAR2
)is
l_commit_unit_number number;
l_legislation_code   varchar2(30);
begin
hr_utility.set_location('Entering: IRC_PARTY_BK6.SELF_REGISTER_USER_A', 10);
l_commit_unit_number := hr_api.return_commit_unit;
if hr_api.call_app_hooks then
irc_party_be6.SELF_REGISTER_USER_A
(P_CURRENT_EMAIL_ADDRESS => P_CURRENT_EMAIL_ADDRESS
,P_RESPONSIBILITY_ID => P_RESPONSIBILITY_ID
,P_RESP_APPL_ID => P_RESP_APPL_ID
,P_SECURITY_GROUP_ID => P_SECURITY_GROUP_ID
,P_FIRST_NAME => P_FIRST_NAME
,P_LAST_NAME => P_LAST_NAME
,P_MIDDLE_NAMES => P_MIDDLE_NAMES
,P_PREVIOUS_LAST_NAME => P_PREVIOUS_LAST_NAME
,P_EMPLOYEE_NUMBER => P_EMPLOYEE_NUMBER
,P_NATIONAL_IDENTIFIER => P_NATIONAL_IDENTIFIER
,P_DATE_OF_BIRTH => P_DATE_OF_BIRTH
,P_EMAIL_ADDRESS => P_EMAIL_ADDRESS
,P_HOME_PHONE_NUMBER => P_HOME_PHONE_NUMBER
,P_WORK_PHONE_NUMBER => P_WORK_PHONE_NUMBER
,P_ADDRESS_LINE_1 => P_ADDRESS_LINE_1
,P_MANAGER_LAST_NAME => P_MANAGER_LAST_NAME
,P_ALLOW_ACCESS => P_ALLOW_ACCESS
,P_LANGUAGE => P_LANGUAGE
,P_USER_NAME => P_USER_NAME
);
end if;
hr_multi_message.end_validation_set;
hr_api.validate_commit_unit(l_commit_unit_number, 'SELF_REGISTER_USER', 'AP');
hr_utility.set_location(' Leaving: IRC_PARTY_BK6.SELF_REGISTER_USER_A', 20);
end SELF_REGISTER_USER_A;
procedure SELF_REGISTER_USER_B
(P_CURRENT_EMAIL_ADDRESS in VARCHAR2
,P_RESPONSIBILITY_ID in NUMBER
,P_RESP_APPL_ID in NUMBER
,P_SECURITY_GROUP_ID in NUMBER
,P_FIRST_NAME in VARCHAR2
,P_LAST_NAME in VARCHAR2
,P_MIDDLE_NAMES in VARCHAR2
,P_PREVIOUS_LAST_NAME in VARCHAR2
,P_EMPLOYEE_NUMBER in VARCHAR2
,P_NATIONAL_IDENTIFIER in VARCHAR2
,P_DATE_OF_BIRTH in DATE
,P_EMAIL_ADDRESS in VARCHAR2
,P_HOME_PHONE_NUMBER in VARCHAR2
,P_WORK_PHONE_NUMBER in VARCHAR2
,P_ADDRESS_LINE_1 in VARCHAR2
,P_MANAGER_LAST_NAME in VARCHAR2
,P_ALLOW_ACCESS in VARCHAR2
,P_LANGUAGE in VARCHAR2
,P_USER_NAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: IRC_PARTY_BK6.SELF_REGISTER_USER_B', 10);
hr_utility.set_location(' Leaving: IRC_PARTY_BK6.SELF_REGISTER_USER_B', 20);
end SELF_REGISTER_USER_B;
end IRC_PARTY_BK6;

/