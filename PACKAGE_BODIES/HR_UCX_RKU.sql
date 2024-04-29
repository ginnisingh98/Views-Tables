--------------------------------------------------------
--  DDL for Package Body HR_UCX_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UCX_RKU" as
/* $Header: hrucxrhi.pkb 120.0 2005/05/31 03:38:00 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:26 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_UI_CONTEXT_ID in NUMBER
,P_UI_CONTEXT_KEY in VARCHAR2
,P_USER_INTERFACE_ID in NUMBER
,P_LABEL in VARCHAR2
,P_LOCATION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_UI_CONTEXT_KEY_O in VARCHAR2
,P_USER_INTERFACE_ID_O in NUMBER
,P_LABEL_O in VARCHAR2
,P_LOCATION_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: HR_UCX_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: HR_UCX_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end HR_UCX_RKU;

/
