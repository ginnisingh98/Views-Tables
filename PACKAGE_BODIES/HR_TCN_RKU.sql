--------------------------------------------------------
--  DDL for Package Body HR_TCN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TCN_RKU" as
/* $Header: hrtcnrhi.pkb 115.5 2002/12/03 10:00:59 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_TEMPLATE_CANVAS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_TEMPLATE_WINDOW_ID in NUMBER
,P_FORM_CANVAS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_TEMPLATE_WINDOW_ID_O in NUMBER
,P_FORM_CANVAS_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: hr_tcn_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: hr_tcn_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end hr_tcn_RKU;

/