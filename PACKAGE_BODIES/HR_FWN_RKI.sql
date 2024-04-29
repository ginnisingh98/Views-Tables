--------------------------------------------------------
--  DDL for Package Body HR_FWN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FWN_RKI" as
/* $Header: hrfwnrhi.pkb 115.4 2002/12/03 13:32:42 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:02 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_FORM_WINDOW_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_APPLICATION_ID in NUMBER
,P_FORM_ID in NUMBER
,P_WINDOW_NAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: hr_fwn_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: hr_fwn_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end hr_fwn_RKI;

/