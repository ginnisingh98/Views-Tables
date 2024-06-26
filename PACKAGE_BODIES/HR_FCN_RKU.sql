--------------------------------------------------------
--  DDL for Package Body HR_FCN_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FCN_RKU" as
/* $Header: hrfcnrhi.pkb 115.3 2002/12/03 10:18:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:30:55 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_FORM_CANVAS_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_FORM_WINDOW_ID in NUMBER
,P_CANVAS_NAME in VARCHAR2
,P_CANVAS_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FORM_WINDOW_ID_O in NUMBER
,P_CANVAS_NAME_O in VARCHAR2
,P_CANVAS_TYPE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: hr_fcn_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: hr_fcn_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end hr_fcn_RKU;

/
