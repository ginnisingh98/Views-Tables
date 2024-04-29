--------------------------------------------------------
--  DDL for Package Body HR_TIM_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TIM_RKU" as
/* $Header: hrtimrhi.pkb 115.10 2003/10/29 02:53:14 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:21 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_TEMPLATE_ITEM_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_FORM_TEMPLATE_ID in NUMBER
,P_FORM_ITEM_ID in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FORM_TEMPLATE_ID_O in NUMBER
,P_FORM_ITEM_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: hr_tim_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: hr_tim_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end hr_tim_RKU;

/
