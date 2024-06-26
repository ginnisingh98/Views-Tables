--------------------------------------------------------
--  DDL for Package Body BEN_SCHEDD_ENROLLMENT_RL_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SCHEDD_ENROLLMENT_RL_BK2" as
/* $Header: beserapi.pkb 115.4 2003/01/16 14:36:05 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:55 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_SCHEDD_ENROLLMENT_RL_A
(P_SCHEDD_ENRT_RL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_ORDR_TO_APLY_NUM in NUMBER
,P_ENRT_PERD_ID in NUMBER
,P_FORMULA_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SER_ATTRIBUTE_CATEGORY in VARCHAR2
,P_SER_ATTRIBUTE1 in VARCHAR2
,P_SER_ATTRIBUTE2 in VARCHAR2
,P_SER_ATTRIBUTE3 in VARCHAR2
,P_SER_ATTRIBUTE4 in VARCHAR2
,P_SER_ATTRIBUTE5 in VARCHAR2
,P_SER_ATTRIBUTE6 in VARCHAR2
,P_SER_ATTRIBUTE7 in VARCHAR2
,P_SER_ATTRIBUTE8 in VARCHAR2
,P_SER_ATTRIBUTE9 in VARCHAR2
,P_SER_ATTRIBUTE10 in VARCHAR2
,P_SER_ATTRIBUTE11 in VARCHAR2
,P_SER_ATTRIBUTE12 in VARCHAR2
,P_SER_ATTRIBUTE13 in VARCHAR2
,P_SER_ATTRIBUTE14 in VARCHAR2
,P_SER_ATTRIBUTE15 in VARCHAR2
,P_SER_ATTRIBUTE16 in VARCHAR2
,P_SER_ATTRIBUTE17 in VARCHAR2
,P_SER_ATTRIBUTE18 in VARCHAR2
,P_SER_ATTRIBUTE19 in VARCHAR2
,P_SER_ATTRIBUTE20 in VARCHAR2
,P_SER_ATTRIBUTE21 in VARCHAR2
,P_SER_ATTRIBUTE22 in VARCHAR2
,P_SER_ATTRIBUTE23 in VARCHAR2
,P_SER_ATTRIBUTE24 in VARCHAR2
,P_SER_ATTRIBUTE25 in VARCHAR2
,P_SER_ATTRIBUTE26 in VARCHAR2
,P_SER_ATTRIBUTE27 in VARCHAR2
,P_SER_ATTRIBUTE28 in VARCHAR2
,P_SER_ATTRIBUTE29 in VARCHAR2
,P_SER_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_SCHEDD_ENROLLMENT_RL_BK2.UPDATE_SCHEDD_ENROLLMENT_RL_A', 10);
hr_utility.set_location(' Leaving: BEN_SCHEDD_ENROLLMENT_RL_BK2.UPDATE_SCHEDD_ENROLLMENT_RL_A', 20);
end UPDATE_SCHEDD_ENROLLMENT_RL_A;
procedure UPDATE_SCHEDD_ENROLLMENT_RL_B
(P_SCHEDD_ENRT_RL_ID in NUMBER
,P_ORDR_TO_APLY_NUM in NUMBER
,P_ENRT_PERD_ID in NUMBER
,P_FORMULA_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_SER_ATTRIBUTE_CATEGORY in VARCHAR2
,P_SER_ATTRIBUTE1 in VARCHAR2
,P_SER_ATTRIBUTE2 in VARCHAR2
,P_SER_ATTRIBUTE3 in VARCHAR2
,P_SER_ATTRIBUTE4 in VARCHAR2
,P_SER_ATTRIBUTE5 in VARCHAR2
,P_SER_ATTRIBUTE6 in VARCHAR2
,P_SER_ATTRIBUTE7 in VARCHAR2
,P_SER_ATTRIBUTE8 in VARCHAR2
,P_SER_ATTRIBUTE9 in VARCHAR2
,P_SER_ATTRIBUTE10 in VARCHAR2
,P_SER_ATTRIBUTE11 in VARCHAR2
,P_SER_ATTRIBUTE12 in VARCHAR2
,P_SER_ATTRIBUTE13 in VARCHAR2
,P_SER_ATTRIBUTE14 in VARCHAR2
,P_SER_ATTRIBUTE15 in VARCHAR2
,P_SER_ATTRIBUTE16 in VARCHAR2
,P_SER_ATTRIBUTE17 in VARCHAR2
,P_SER_ATTRIBUTE18 in VARCHAR2
,P_SER_ATTRIBUTE19 in VARCHAR2
,P_SER_ATTRIBUTE20 in VARCHAR2
,P_SER_ATTRIBUTE21 in VARCHAR2
,P_SER_ATTRIBUTE22 in VARCHAR2
,P_SER_ATTRIBUTE23 in VARCHAR2
,P_SER_ATTRIBUTE24 in VARCHAR2
,P_SER_ATTRIBUTE25 in VARCHAR2
,P_SER_ATTRIBUTE26 in VARCHAR2
,P_SER_ATTRIBUTE27 in VARCHAR2
,P_SER_ATTRIBUTE28 in VARCHAR2
,P_SER_ATTRIBUTE29 in VARCHAR2
,P_SER_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_SCHEDD_ENROLLMENT_RL_BK2.UPDATE_SCHEDD_ENROLLMENT_RL_B', 10);
hr_utility.set_location(' Leaving: BEN_SCHEDD_ENROLLMENT_RL_BK2.UPDATE_SCHEDD_ENROLLMENT_RL_B', 20);
end UPDATE_SCHEDD_ENROLLMENT_RL_B;
end BEN_SCHEDD_ENROLLMENT_RL_BK2;

/
