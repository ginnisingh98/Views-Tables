--------------------------------------------------------
--  DDL for Package Body BEN_DSQ_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DSQ_RKU" as
/* $Header: bedsqrhi.pkb 115.7 2002/12/09 12:49:41 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:38:34 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_DED_SCHED_PY_FREQ_ID in NUMBER
,P_PY_FREQ_CD in VARCHAR2
,P_DFLT_FLAG in VARCHAR2
,P_ACTY_RT_DED_SCHED_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_DSQ_ATTRIBUTE_CATEGORY in VARCHAR2
,P_DSQ_ATTRIBUTE1 in VARCHAR2
,P_DSQ_ATTRIBUTE2 in VARCHAR2
,P_DSQ_ATTRIBUTE3 in VARCHAR2
,P_DSQ_ATTRIBUTE4 in VARCHAR2
,P_DSQ_ATTRIBUTE5 in VARCHAR2
,P_DSQ_ATTRIBUTE6 in VARCHAR2
,P_DSQ_ATTRIBUTE7 in VARCHAR2
,P_DSQ_ATTRIBUTE8 in VARCHAR2
,P_DSQ_ATTRIBUTE9 in VARCHAR2
,P_DSQ_ATTRIBUTE10 in VARCHAR2
,P_DSQ_ATTRIBUTE11 in VARCHAR2
,P_DSQ_ATTRIBUTE12 in VARCHAR2
,P_DSQ_ATTRIBUTE13 in VARCHAR2
,P_DSQ_ATTRIBUTE14 in VARCHAR2
,P_DSQ_ATTRIBUTE15 in VARCHAR2
,P_DSQ_ATTRIBUTE16 in VARCHAR2
,P_DSQ_ATTRIBUTE17 in VARCHAR2
,P_DSQ_ATTRIBUTE18 in VARCHAR2
,P_DSQ_ATTRIBUTE19 in VARCHAR2
,P_DSQ_ATTRIBUTE20 in VARCHAR2
,P_DSQ_ATTRIBUTE21 in VARCHAR2
,P_DSQ_ATTRIBUTE22 in VARCHAR2
,P_DSQ_ATTRIBUTE23 in VARCHAR2
,P_DSQ_ATTRIBUTE24 in VARCHAR2
,P_DSQ_ATTRIBUTE25 in VARCHAR2
,P_DSQ_ATTRIBUTE26 in VARCHAR2
,P_DSQ_ATTRIBUTE27 in VARCHAR2
,P_DSQ_ATTRIBUTE28 in VARCHAR2
,P_DSQ_ATTRIBUTE29 in VARCHAR2
,P_DSQ_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_PY_FREQ_CD_O in VARCHAR2
,P_DFLT_FLAG_O in VARCHAR2
,P_ACTY_RT_DED_SCHED_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DSQ_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_DSQ_ATTRIBUTE1_O in VARCHAR2
,P_DSQ_ATTRIBUTE2_O in VARCHAR2
,P_DSQ_ATTRIBUTE3_O in VARCHAR2
,P_DSQ_ATTRIBUTE4_O in VARCHAR2
,P_DSQ_ATTRIBUTE5_O in VARCHAR2
,P_DSQ_ATTRIBUTE6_O in VARCHAR2
,P_DSQ_ATTRIBUTE7_O in VARCHAR2
,P_DSQ_ATTRIBUTE8_O in VARCHAR2
,P_DSQ_ATTRIBUTE9_O in VARCHAR2
,P_DSQ_ATTRIBUTE10_O in VARCHAR2
,P_DSQ_ATTRIBUTE11_O in VARCHAR2
,P_DSQ_ATTRIBUTE12_O in VARCHAR2
,P_DSQ_ATTRIBUTE13_O in VARCHAR2
,P_DSQ_ATTRIBUTE14_O in VARCHAR2
,P_DSQ_ATTRIBUTE15_O in VARCHAR2
,P_DSQ_ATTRIBUTE16_O in VARCHAR2
,P_DSQ_ATTRIBUTE17_O in VARCHAR2
,P_DSQ_ATTRIBUTE18_O in VARCHAR2
,P_DSQ_ATTRIBUTE19_O in VARCHAR2
,P_DSQ_ATTRIBUTE20_O in VARCHAR2
,P_DSQ_ATTRIBUTE21_O in VARCHAR2
,P_DSQ_ATTRIBUTE22_O in VARCHAR2
,P_DSQ_ATTRIBUTE23_O in VARCHAR2
,P_DSQ_ATTRIBUTE24_O in VARCHAR2
,P_DSQ_ATTRIBUTE25_O in VARCHAR2
,P_DSQ_ATTRIBUTE26_O in VARCHAR2
,P_DSQ_ATTRIBUTE27_O in VARCHAR2
,P_DSQ_ATTRIBUTE28_O in VARCHAR2
,P_DSQ_ATTRIBUTE29_O in VARCHAR2
,P_DSQ_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_dsq_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: ben_dsq_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end ben_dsq_RKU;

/
