--------------------------------------------------------
--  DDL for Package Body BEN_XCC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCC_RKD" as
/* $Header: bexccrhi.pkb 120.1 2005/10/31 11:39:19 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:08 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EXT_CRIT_CMBN_ID in NUMBER
,P_CRIT_TYP_CD_O in VARCHAR2
,P_OPER_CD_O in VARCHAR2
,P_VAL_1_O in VARCHAR2
,P_VAL_2_O in VARCHAR2
,P_EXT_CRIT_VAL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_xcc_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_xcc_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_xcc_RKD;

/
