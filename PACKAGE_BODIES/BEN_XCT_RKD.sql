--------------------------------------------------------
--  DDL for Package Body BEN_XCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCT_RKD" as
/* $Header: bexctrhi.pkb 115.12 2002/12/31 20:39:06 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EXT_CRIT_TYP_ID in NUMBER
,P_CRIT_TYP_CD_O in VARCHAR2
,P_EXT_CRIT_PRFL_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_EXCLD_FLAG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_xct_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_xct_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_xct_RKD;

/
