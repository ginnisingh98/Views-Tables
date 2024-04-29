--------------------------------------------------------
--  DDL for Package Body BEN_XDD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XDD_RKD" as
/* $Header: bexddrhi.pkb 120.1 2005/06/08 13:09:46 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:09 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EXT_DATA_ELMT_DECD_ID in NUMBER
,P_VAL_O in VARCHAR2
,P_DCD_VAL_O in VARCHAR2
,P_CHG_EVT_SOURCE_O in VARCHAR2
,P_EXT_DATA_ELMT_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_xdd_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_xdd_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_xdd_RKD;

/