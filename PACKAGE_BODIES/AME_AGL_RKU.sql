--------------------------------------------------------
--  DDL for Package Body AME_AGL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_AGL_RKU" as
/* $Header: amaglrhi.pkb 120.0 2005/09/02 03:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:29 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_APPROVAL_GROUP_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_USER_APPROVAL_GROUP_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_USER_APPROVAL_GROUP_NAME_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: AME_AGL_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: AME_AGL_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end AME_AGL_RKU;

/
