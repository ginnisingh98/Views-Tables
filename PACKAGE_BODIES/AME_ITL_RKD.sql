--------------------------------------------------------
--  DDL for Package Body AME_ITL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ITL_RKD" as
/* $Header: amitlrhi.pkb 120.0 2005/09/02 04:01 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:37 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ITEM_CLASS_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_USER_ITEM_CLASS_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: AME_ITL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: AME_ITL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end AME_ITL_RKD;

/