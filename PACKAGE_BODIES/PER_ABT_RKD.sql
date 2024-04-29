--------------------------------------------------------
--  DDL for Package Body PER_ABT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABT_RKD" as
/* $Header: peabtrhi.pkb 120.1 2005/10/10 04:12 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ABSENCE_ATTENDANCE_TYPE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_NAME_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_ABT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_ABT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_ABT_RKD;

/
