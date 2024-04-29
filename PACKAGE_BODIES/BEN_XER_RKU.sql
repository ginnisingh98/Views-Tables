--------------------------------------------------------
--  DDL for Package Body BEN_XER_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XER_RKU" as
/* $Header: bexerrhi.pkb 120.1 2006/03/22 13:57:32 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:11 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EXT_DATA_ELMT_IN_RCD_ID in NUMBER
,P_SEQ_NUM in NUMBER
,P_STRT_POS in NUMBER
,P_DLMTR_VAL in VARCHAR2
,P_RQD_FLAG in VARCHAR2
,P_SPRS_CD in VARCHAR2
,P_ANY_OR_ALL_CD in VARCHAR2
,P_EXT_DATA_ELMT_ID in NUMBER
,P_EXT_RCD_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_HIDE_FLAG in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_SEQ_NUM_O in NUMBER
,P_STRT_POS_O in NUMBER
,P_DLMTR_VAL_O in VARCHAR2
,P_RQD_FLAG_O in VARCHAR2
,P_SPRS_CD_O in VARCHAR2
,P_ANY_OR_ALL_CD_O in VARCHAR2
,P_EXT_DATA_ELMT_ID_O in NUMBER
,P_EXT_RCD_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_LEGISLATION_CODE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_HIDE_FLAG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: ben_xer_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_xer_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_xer_RKU;

/
