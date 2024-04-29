--------------------------------------------------------
--  DDL for Package Body PER_SST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SST_RKD" as
/* $Header: pesstrhi.pkb 120.1 2005/06/01 12:05:44 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_SETUP_SUB_TASK_CODE in VARCHAR2
,P_LANGUAGE_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_SETUP_SUB_TASK_NAME_O in VARCHAR2
,P_SETUP_SUB_TASK_DESCRIPTION_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PER_SST_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_SST_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_SST_RKD;

/