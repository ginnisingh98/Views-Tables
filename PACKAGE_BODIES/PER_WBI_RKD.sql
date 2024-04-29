--------------------------------------------------------
--  DDL for Package Body PER_WBI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_WBI_RKD" as
/* $Header: pewbirhi.pkb 115.0 2003/07/03 05:55:25 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:33:28 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_WORKBENCH_ITEM_CODE in VARCHAR2
,P_MENU_ID_O in NUMBER
,P_WORKBENCH_ITEM_SEQUENCE_O in NUMBER
,P_WORKBENCH_PARENT_ITEM_CODE_O in VARCHAR2
,P_WORKBENCH_ITEM_CREATION_DA_O in DATE
,P_WORKBENCH_ITEM_TYPE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_WBI_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PER_WBI_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PER_WBI_RKD;

/