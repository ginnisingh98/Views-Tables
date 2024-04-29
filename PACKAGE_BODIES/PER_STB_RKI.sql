--------------------------------------------------------
--  DDL for Package Body PER_STB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_STB_RKI" as
/* $Header: pestbrhi.pkb 115.0 2003/07/03 06:26:56 generated noship $ */ --
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_SETUP_TASK_CODE in VARCHAR2
,P_WORKBENCH_ITEM_CODE in VARCHAR2
,P_SETUP_TASK_SEQUENCE in NUMBER
,P_SETUP_TASK_STATUS in VARCHAR2
,P_SETUP_TASK_CREATION_DATE in DATE
,P_SETUP_TASK_LAST_MODIFIED_DAT in DATE
,P_SETUP_TASK_TYPE in VARCHAR2
,P_SETUP_TASK_ACTION in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_STB_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PER_STB_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PER_STB_RKI;

/