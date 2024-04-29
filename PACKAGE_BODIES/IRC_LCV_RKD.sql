--------------------------------------------------------
--  DDL for Package Body IRC_LCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_LCV_RKD" as
/* $Header: irlcvrhi.pkb 120.0 2005/10/03 14:58:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:06:44 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_LOCATION_CRITERIA_VALUE_ID in NUMBER
,P_SEARCH_CRITERIA_ID_O in NUMBER
,P_DERIVED_LOCALE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: IRC_LCV_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: IRC_LCV_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end IRC_LCV_RKD;

/
