--------------------------------------------------------
--  DDL for Package Body BEN_EPR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPR_RKD" as
/* $Header: beeprrhi.pkb 115.5 2002/12/09 12:52:58 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:39:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ENRT_PREM_ID in NUMBER
,P_VAL_O in NUMBER
,P_UOM_O in VARCHAR2
,P_ELIG_PER_ELCTBL_CHC_ID_O in NUMBER
,P_ENRT_BNFT_ID_O in NUMBER
,P_ACTL_PREM_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_EPR_ATTRIBUTE_CATEGORY_O in VARCHAR2
,P_EPR_ATTRIBUTE1_O in VARCHAR2
,P_EPR_ATTRIBUTE2_O in VARCHAR2
,P_EPR_ATTRIBUTE3_O in VARCHAR2
,P_EPR_ATTRIBUTE4_O in VARCHAR2
,P_EPR_ATTRIBUTE5_O in VARCHAR2
,P_EPR_ATTRIBUTE6_O in VARCHAR2
,P_EPR_ATTRIBUTE7_O in VARCHAR2
,P_EPR_ATTRIBUTE8_O in VARCHAR2
,P_EPR_ATTRIBUTE9_O in VARCHAR2
,P_EPR_ATTRIBUTE10_O in VARCHAR2
,P_EPR_ATTRIBUTE11_O in VARCHAR2
,P_EPR_ATTRIBUTE12_O in VARCHAR2
,P_EPR_ATTRIBUTE13_O in VARCHAR2
,P_EPR_ATTRIBUTE14_O in VARCHAR2
,P_EPR_ATTRIBUTE15_O in VARCHAR2
,P_EPR_ATTRIBUTE16_O in VARCHAR2
,P_EPR_ATTRIBUTE17_O in VARCHAR2
,P_EPR_ATTRIBUTE18_O in VARCHAR2
,P_EPR_ATTRIBUTE19_O in VARCHAR2
,P_EPR_ATTRIBUTE20_O in VARCHAR2
,P_EPR_ATTRIBUTE21_O in VARCHAR2
,P_EPR_ATTRIBUTE22_O in VARCHAR2
,P_EPR_ATTRIBUTE23_O in VARCHAR2
,P_EPR_ATTRIBUTE24_O in VARCHAR2
,P_EPR_ATTRIBUTE25_O in VARCHAR2
,P_EPR_ATTRIBUTE26_O in VARCHAR2
,P_EPR_ATTRIBUTE27_O in VARCHAR2
,P_EPR_ATTRIBUTE28_O in VARCHAR2
,P_EPR_ATTRIBUTE29_O in VARCHAR2
,P_EPR_ATTRIBUTE30_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
)is
begin
hr_utility.set_location('Entering: ben_epr_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_epr_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_epr_RKD;

/