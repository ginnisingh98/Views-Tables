--------------------------------------------------------
--  DDL for Package Body BEN_VPR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_VPR_RKI" as
/* $Header: bevprrhi.pkb 120.0.12010000.2 2008/08/05 15:45:28 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_VRBL_RT_PRFL_RL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_VRBL_RT_PRFL_ID in NUMBER
,P_FORMULA_ID in NUMBER
,P_ORDR_TO_APLY_NUM in NUMBER
,P_DRVBL_FCTR_APLS_FLAG in VARCHAR2
,P_VPR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VPR_ATTRIBUTE1 in VARCHAR2
,P_VPR_ATTRIBUTE2 in VARCHAR2
,P_VPR_ATTRIBUTE3 in VARCHAR2
,P_VPR_ATTRIBUTE4 in VARCHAR2
,P_VPR_ATTRIBUTE5 in VARCHAR2
,P_VPR_ATTRIBUTE6 in VARCHAR2
,P_VPR_ATTRIBUTE7 in VARCHAR2
,P_VPR_ATTRIBUTE8 in VARCHAR2
,P_VPR_ATTRIBUTE9 in VARCHAR2
,P_VPR_ATTRIBUTE10 in VARCHAR2
,P_VPR_ATTRIBUTE11 in VARCHAR2
,P_VPR_ATTRIBUTE12 in VARCHAR2
,P_VPR_ATTRIBUTE13 in VARCHAR2
,P_VPR_ATTRIBUTE14 in VARCHAR2
,P_VPR_ATTRIBUTE15 in VARCHAR2
,P_VPR_ATTRIBUTE16 in VARCHAR2
,P_VPR_ATTRIBUTE17 in VARCHAR2
,P_VPR_ATTRIBUTE18 in VARCHAR2
,P_VPR_ATTRIBUTE19 in VARCHAR2
,P_VPR_ATTRIBUTE20 in VARCHAR2
,P_VPR_ATTRIBUTE21 in VARCHAR2
,P_VPR_ATTRIBUTE22 in VARCHAR2
,P_VPR_ATTRIBUTE23 in VARCHAR2
,P_VPR_ATTRIBUTE24 in VARCHAR2
,P_VPR_ATTRIBUTE25 in VARCHAR2
,P_VPR_ATTRIBUTE26 in VARCHAR2
,P_VPR_ATTRIBUTE27 in VARCHAR2
,P_VPR_ATTRIBUTE28 in VARCHAR2
,P_VPR_ATTRIBUTE29 in VARCHAR2
,P_VPR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_VALIDATION_START_DATE in DATE
,P_VALIDATION_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: ben_vpr_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: ben_vpr_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end ben_vpr_RKI;

/