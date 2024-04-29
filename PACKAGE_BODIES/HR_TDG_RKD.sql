--------------------------------------------------------
--  DDL for Package Body HR_TDG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TDG_RKD" as
/* $Header: hrtdgrhi.pkb 115.3 2002/12/03 10:33:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TEMPLATE_DATA_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_FORM_TEMPLATE_ID_O in NUMBER
,P_FORM_DATA_GROUP_ID_O in NUMBER
)is
begin
hr_utility.set_location('Entering: hr_tdg_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: hr_tdg_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end hr_tdg_RKD;

/
