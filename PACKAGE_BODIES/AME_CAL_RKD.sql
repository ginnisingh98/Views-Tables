--------------------------------------------------------
--  DDL for Package Body AME_CAL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CAL_RKD" as
/* $Header: amcalrhi.pkb 120.2 2006/01/03 22:52 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:34 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_APPLICATION_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_APPLICATION_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: AME_CAL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: AME_CAL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end AME_CAL_RKD;

/
