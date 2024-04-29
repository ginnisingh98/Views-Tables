--------------------------------------------------------
--  DDL for Package Body HR_TIP_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIP_RKD" as
/* $Header: hrtiprhi.pkb 115.4 2002/12/03 12:59:50 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TEMPLATE_ITEM_TAB_PAGE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_TEMPLATE_ITEM_ID_O in NUMBER
,P_TEMPLATE_TAB_PAGE_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: hr_tip_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: hr_tip_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end hr_tip_RKD;

/