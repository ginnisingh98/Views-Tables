--------------------------------------------------------
--  DDL for Package Body PER_SSB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSB_RKD" as
/* $Header: pessbrhi.pkb 115.1 2003/08/06 01:25:57 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:19 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_SETUP_SUB_TASK_CODE in VARCHAR2
,P_SETUP_TASK_CODE_O in VARCHAR2
,P_SETUP_SUB_TASK_SEQUENCE_O in NUMBER
,P_SETUP_SUB_TASK_STATUS_O in VARCHAR2
,P_SETUP_SUB_TASK_TYPE_O in VARCHAR2
,P_SETUP_SUB_TASK_DATA_PUMP_L_O in VARCHAR2
,P_SETUP_SUB_TASK_ACTION_O in VARCHAR2
,P_SETUP_SUB_TASK_CREATION_DA_O in DATE
,P_SETUP_SUB_TASK_LAST_MOD_DA_O in DATE
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_SSB_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_SSB_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_SSB_RKD;

/
