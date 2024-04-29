--------------------------------------------------------
--  DDL for Package Body BEN_CMD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CMD_RKU" as
/* $Header: becmdrhi.pkb 115.7 2002/12/31 23:57:12 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_CM_DLVRY_MED_TYP_ID in NUMBER
,P_CM_DLVRY_MED_TYP_CD in VARCHAR2
,P_CM_DLVRY_MTHD_TYP_ID in NUMBER
,P_RQD_FLAG in VARCHAR2
,P_DFLT_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_CMD_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CMD_ATTRIBUTE1 in VARCHAR2
,P_CMD_ATTRIBUTE2 in VARCHAR2
,P_CMD_ATTRIBUTE3 in VARCHAR2
,P_CMD_ATTRIBUTE4 in VARCHAR2
,P_CMD_ATTRIBUTE5 in VARCHAR2
,P_CMD_ATTRIBUTE6 in VARCHAR2
,P_CMD_ATTRIBUTE7 in VARCHAR2
,P_CMD_ATTRIBUTE8 in VARCHAR2
,P_CMD_ATTRIBUTE9 in VARCHAR2
,P_CMD_ATTRIBUTE10 in VARCHAR2
,P_CMD_ATTRIBUTE11 in VARCHAR2
,P_CMD_ATTRIBUTE12 in VARCHAR2
,P_CMD_ATTRIBUTE13 in VARCHAR2
,P_CMD_ATTRIBUTE14 in VARCHAR2
,P_CMD_ATTRIBUTE15 in VARCHAR2
,P_CMD_ATTRIBUTE16 in VARCHAR2
,P_CMD_ATTRIBUTE17 in VARCHAR2
,P_CMD_ATTRIBUTE18 in VARCHAR2
,P_CMD_ATTRIBUTE19 in VARCHAR2
,P_CMD_ATTRIBUTE20 in VARCHAR2
,P_CMD_ATTRIBUTE21 in VARCHAR2
,P_CMD_ATTRIBUTE22 in VARCHAR2
,P_CMD_ATTRIBUTE23 in VARCHAR2
,P_CMD_ATTRIBUTE24 in VARCHAR2
,P_CMD_ATTRIBUTE25 in VARCHAR2
,P_CMD_ATTRIBUTE26 in VARCHAR2
,P_CMD_ATTRIBUTE27 in VARCHAR2
,P_CMD_ATTRIBUTE28 in VARCHAR2
,P_CMD_ATTRIBUTE29 in VARCHAR2
,P_CMD_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_CM_DLVRY_MED_TYP_CD_O in VARCHAR2
,P_CM_DLVRY_MTHD_TYP_ID_O in NUMBER
,P_RQD_FLAG_O in VARCHAR2
,P_DFLT_FLAG_O in VARCHAR2
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_CMD_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_CMD_ATTRIBUTE1_O in VARCHAR2
,P_CMD_ATTRIBUTE2_O in VARCHAR2
,P_CMD_ATTRIBUTE3_O in VARCHAR2
,P_CMD_ATTRIBUTE4_O in VARCHAR2
,P_CMD_ATTRIBUTE5_O in VARCHAR2
,P_CMD_ATTRIBUTE6_O in VARCHAR2
,P_CMD_ATTRIBUTE7_O in VARCHAR2
,P_CMD_ATTRIBUTE8_O in VARCHAR2
,P_CMD_ATTRIBUTE9_O in VARCHAR2
,P_CMD_ATTRIBUTE10_O in VARCHAR2
,P_CMD_ATTRIBUTE11_O in VARCHAR2
,P_CMD_ATTRIBUTE12_O in VARCHAR2
,P_CMD_ATTRIBUTE13_O in VARCHAR2
,P_CMD_ATTRIBUTE14_O in VARCHAR2
,P_CMD_ATTRIBUTE15_O in VARCHAR2
,P_CMD_ATTRIBUTE16_O in VARCHAR2
,P_CMD_ATTRIBUTE17_O in VARCHAR2
,P_CMD_ATTRIBUTE18_O in VARCHAR2
,P_CMD_ATTRIBUTE19_O in VARCHAR2
,P_CMD_ATTRIBUTE20_O in VARCHAR2
,P_CMD_ATTRIBUTE21_O in VARCHAR2
,P_CMD_ATTRIBUTE22_O in VARCHAR2
,P_CMD_ATTRIBUTE23_O in VARCHAR2
,P_CMD_ATTRIBUTE24_O in VARCHAR2
,P_CMD_ATTRIBUTE25_O in VARCHAR2
,P_CMD_ATTRIBUTE26_O in VARCHAR2
,P_CMD_ATTRIBUTE27_O in VARCHAR2
,P_CMD_ATTRIBUTE28_O in VARCHAR2
,P_CMD_ATTRIBUTE29_O in VARCHAR2
,P_CMD_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_cmd_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_cmd_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_cmd_RKU;

/
