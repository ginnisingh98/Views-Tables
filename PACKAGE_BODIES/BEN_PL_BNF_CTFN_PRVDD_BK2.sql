--------------------------------------------------------
--  DDL for Package Body BEN_PL_BNF_CTFN_PRVDD_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PL_BNF_CTFN_PRVDD_BK2" as
/* $Header: bepbcapi.pkb 120.1 2006/05/03 01:19:31 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:05 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PL_BNF_CTFN_PRVDD_A
(P_PL_BNF_CTFN_PRVDD_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BNF_CTFN_TYP_CD in VARCHAR2
,P_BNF_CTFN_RECD_DT in DATE
,P_BNF_CTFN_RQD_FLAG in VARCHAR2
,P_PL_BNF_ID in NUMBER
,P_PRTT_ENRT_ACTN_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PBC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PBC_ATTRIBUTE1 in VARCHAR2
,P_PBC_ATTRIBUTE2 in VARCHAR2
,P_PBC_ATTRIBUTE3 in VARCHAR2
,P_PBC_ATTRIBUTE4 in VARCHAR2
,P_PBC_ATTRIBUTE5 in VARCHAR2
,P_PBC_ATTRIBUTE6 in VARCHAR2
,P_PBC_ATTRIBUTE7 in VARCHAR2
,P_PBC_ATTRIBUTE8 in VARCHAR2
,P_PBC_ATTRIBUTE9 in VARCHAR2
,P_PBC_ATTRIBUTE10 in VARCHAR2
,P_PBC_ATTRIBUTE11 in VARCHAR2
,P_PBC_ATTRIBUTE12 in VARCHAR2
,P_PBC_ATTRIBUTE13 in VARCHAR2
,P_PBC_ATTRIBUTE14 in VARCHAR2
,P_PBC_ATTRIBUTE15 in VARCHAR2
,P_PBC_ATTRIBUTE16 in VARCHAR2
,P_PBC_ATTRIBUTE17 in VARCHAR2
,P_PBC_ATTRIBUTE18 in VARCHAR2
,P_PBC_ATTRIBUTE19 in VARCHAR2
,P_PBC_ATTRIBUTE20 in VARCHAR2
,P_PBC_ATTRIBUTE21 in VARCHAR2
,P_PBC_ATTRIBUTE22 in VARCHAR2
,P_PBC_ATTRIBUTE23 in VARCHAR2
,P_PBC_ATTRIBUTE24 in VARCHAR2
,P_PBC_ATTRIBUTE25 in VARCHAR2
,P_PBC_ATTRIBUTE26 in VARCHAR2
,P_PBC_ATTRIBUTE27 in VARCHAR2
,P_PBC_ATTRIBUTE28 in VARCHAR2
,P_PBC_ATTRIBUTE29 in VARCHAR2
,P_PBC_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PL_BNF_CTFN_PRVDD_BK2.UPDATE_PL_BNF_CTFN_PRVDD_A', 10);
hr_utility.set_location(' Leaving: BEN_PL_BNF_CTFN_PRVDD_BK2.UPDATE_PL_BNF_CTFN_PRVDD_A', 20);
end UPDATE_PL_BNF_CTFN_PRVDD_A;
procedure UPDATE_PL_BNF_CTFN_PRVDD_B
(P_PL_BNF_CTFN_PRVDD_ID in NUMBER
,P_BNF_CTFN_TYP_CD in VARCHAR2
,P_BNF_CTFN_RECD_DT in DATE
,P_BNF_CTFN_RQD_FLAG in VARCHAR2
,P_PL_BNF_ID in NUMBER
,P_PRTT_ENRT_ACTN_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PBC_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PBC_ATTRIBUTE1 in VARCHAR2
,P_PBC_ATTRIBUTE2 in VARCHAR2
,P_PBC_ATTRIBUTE3 in VARCHAR2
,P_PBC_ATTRIBUTE4 in VARCHAR2
,P_PBC_ATTRIBUTE5 in VARCHAR2
,P_PBC_ATTRIBUTE6 in VARCHAR2
,P_PBC_ATTRIBUTE7 in VARCHAR2
,P_PBC_ATTRIBUTE8 in VARCHAR2
,P_PBC_ATTRIBUTE9 in VARCHAR2
,P_PBC_ATTRIBUTE10 in VARCHAR2
,P_PBC_ATTRIBUTE11 in VARCHAR2
,P_PBC_ATTRIBUTE12 in VARCHAR2
,P_PBC_ATTRIBUTE13 in VARCHAR2
,P_PBC_ATTRIBUTE14 in VARCHAR2
,P_PBC_ATTRIBUTE15 in VARCHAR2
,P_PBC_ATTRIBUTE16 in VARCHAR2
,P_PBC_ATTRIBUTE17 in VARCHAR2
,P_PBC_ATTRIBUTE18 in VARCHAR2
,P_PBC_ATTRIBUTE19 in VARCHAR2
,P_PBC_ATTRIBUTE20 in VARCHAR2
,P_PBC_ATTRIBUTE21 in VARCHAR2
,P_PBC_ATTRIBUTE22 in VARCHAR2
,P_PBC_ATTRIBUTE23 in VARCHAR2
,P_PBC_ATTRIBUTE24 in VARCHAR2
,P_PBC_ATTRIBUTE25 in VARCHAR2
,P_PBC_ATTRIBUTE26 in VARCHAR2
,P_PBC_ATTRIBUTE27 in VARCHAR2
,P_PBC_ATTRIBUTE28 in VARCHAR2
,P_PBC_ATTRIBUTE29 in VARCHAR2
,P_PBC_ATTRIBUTE30 in VARCHAR2
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PL_BNF_CTFN_PRVDD_BK2.UPDATE_PL_BNF_CTFN_PRVDD_B', 10);
hr_utility.set_location(' Leaving: BEN_PL_BNF_CTFN_PRVDD_BK2.UPDATE_PL_BNF_CTFN_PRVDD_B', 20);
end UPDATE_PL_BNF_CTFN_PRVDD_B;
end BEN_PL_BNF_CTFN_PRVDD_BK2;

/