--------------------------------------------------------
--  DDL for Package Body BEN_CWG_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWG_RKI" as
/* $Header: becwgrhi.pkb 120.0 2005/05/28 01:29:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:26 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_CWB_WKSHT_GRP_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PL_ID in NUMBER
,P_ORDR_NUM in NUMBER
,P_WKSHT_GRP_CD in VARCHAR2
,P_LABEL in VARCHAR2
,P_CWG_ATTRIBUTE_CATEGORY in VARCHAR2
,P_CWG_ATTRIBUTE1 in VARCHAR2
,P_CWG_ATTRIBUTE2 in VARCHAR2
,P_CWG_ATTRIBUTE3 in VARCHAR2
,P_CWG_ATTRIBUTE4 in VARCHAR2
,P_CWG_ATTRIBUTE5 in VARCHAR2
,P_CWG_ATTRIBUTE6 in VARCHAR2
,P_CWG_ATTRIBUTE7 in VARCHAR2
,P_CWG_ATTRIBUTE8 in VARCHAR2
,P_CWG_ATTRIBUTE9 in VARCHAR2
,P_CWG_ATTRIBUTE10 in VARCHAR2
,P_CWG_ATTRIBUTE11 in VARCHAR2
,P_CWG_ATTRIBUTE12 in VARCHAR2
,P_CWG_ATTRIBUTE13 in VARCHAR2
,P_CWG_ATTRIBUTE14 in VARCHAR2
,P_CWG_ATTRIBUTE15 in VARCHAR2
,P_CWG_ATTRIBUTE16 in VARCHAR2
,P_CWG_ATTRIBUTE17 in VARCHAR2
,P_CWG_ATTRIBUTE18 in VARCHAR2
,P_CWG_ATTRIBUTE19 in VARCHAR2
,P_CWG_ATTRIBUTE20 in VARCHAR2
,P_CWG_ATTRIBUTE21 in VARCHAR2
,P_CWG_ATTRIBUTE22 in VARCHAR2
,P_CWG_ATTRIBUTE23 in VARCHAR2
,P_CWG_ATTRIBUTE24 in VARCHAR2
,P_CWG_ATTRIBUTE25 in VARCHAR2
,P_CWG_ATTRIBUTE26 in VARCHAR2
,P_CWG_ATTRIBUTE27 in VARCHAR2
,P_CWG_ATTRIBUTE28 in VARCHAR2
,P_CWG_ATTRIBUTE29 in VARCHAR2
,P_CWG_ATTRIBUTE30 in VARCHAR2
,P_STATUS_CD in VARCHAR2
,P_HIDDEN_CD in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_cwg_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_cwg_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_cwg_RKI;

/
