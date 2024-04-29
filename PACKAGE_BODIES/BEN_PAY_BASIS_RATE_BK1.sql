--------------------------------------------------------
--  DDL for Package Body BEN_PAY_BASIS_RATE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAY_BASIS_RATE_BK1" as
/* $Header: bepbrapi.pkb 115.3 2002/12/16 09:37:16 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:06 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_PAY_BASIS_RATE_A
(P_PY_BSS_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_VRBL_RT_PRFL_ID in NUMBER
,P_PAY_BASIS_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PBR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PBR_ATTRIBUTE1 in VARCHAR2
,P_PBR_ATTRIBUTE2 in VARCHAR2
,P_PBR_ATTRIBUTE3 in VARCHAR2
,P_PBR_ATTRIBUTE4 in VARCHAR2
,P_PBR_ATTRIBUTE5 in VARCHAR2
,P_PBR_ATTRIBUTE6 in VARCHAR2
,P_PBR_ATTRIBUTE7 in VARCHAR2
,P_PBR_ATTRIBUTE8 in VARCHAR2
,P_PBR_ATTRIBUTE9 in VARCHAR2
,P_PBR_ATTRIBUTE10 in VARCHAR2
,P_PBR_ATTRIBUTE11 in VARCHAR2
,P_PBR_ATTRIBUTE12 in VARCHAR2
,P_PBR_ATTRIBUTE13 in VARCHAR2
,P_PBR_ATTRIBUTE14 in VARCHAR2
,P_PBR_ATTRIBUTE15 in VARCHAR2
,P_PBR_ATTRIBUTE16 in VARCHAR2
,P_PBR_ATTRIBUTE17 in VARCHAR2
,P_PBR_ATTRIBUTE18 in VARCHAR2
,P_PBR_ATTRIBUTE19 in VARCHAR2
,P_PBR_ATTRIBUTE20 in VARCHAR2
,P_PBR_ATTRIBUTE21 in VARCHAR2
,P_PBR_ATTRIBUTE22 in VARCHAR2
,P_PBR_ATTRIBUTE23 in VARCHAR2
,P_PBR_ATTRIBUTE24 in VARCHAR2
,P_PBR_ATTRIBUTE25 in VARCHAR2
,P_PBR_ATTRIBUTE26 in VARCHAR2
,P_PBR_ATTRIBUTE27 in VARCHAR2
,P_PBR_ATTRIBUTE28 in VARCHAR2
,P_PBR_ATTRIBUTE29 in VARCHAR2
,P_PBR_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PAY_BASIS_RATE_BK1.CREATE_PAY_BASIS_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_PAY_BASIS_RATE_BK1.CREATE_PAY_BASIS_RATE_A', 20);
end CREATE_PAY_BASIS_RATE_A;
procedure CREATE_PAY_BASIS_RATE_B
(P_VRBL_RT_PRFL_ID in NUMBER
,P_PAY_BASIS_ID in NUMBER
,P_EXCLD_FLAG in VARCHAR2
,P_ORDR_NUM in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PBR_ATTRIBUTE_CATEGORY in VARCHAR2
,P_PBR_ATTRIBUTE1 in VARCHAR2
,P_PBR_ATTRIBUTE2 in VARCHAR2
,P_PBR_ATTRIBUTE3 in VARCHAR2
,P_PBR_ATTRIBUTE4 in VARCHAR2
,P_PBR_ATTRIBUTE5 in VARCHAR2
,P_PBR_ATTRIBUTE6 in VARCHAR2
,P_PBR_ATTRIBUTE7 in VARCHAR2
,P_PBR_ATTRIBUTE8 in VARCHAR2
,P_PBR_ATTRIBUTE9 in VARCHAR2
,P_PBR_ATTRIBUTE10 in VARCHAR2
,P_PBR_ATTRIBUTE11 in VARCHAR2
,P_PBR_ATTRIBUTE12 in VARCHAR2
,P_PBR_ATTRIBUTE13 in VARCHAR2
,P_PBR_ATTRIBUTE14 in VARCHAR2
,P_PBR_ATTRIBUTE15 in VARCHAR2
,P_PBR_ATTRIBUTE16 in VARCHAR2
,P_PBR_ATTRIBUTE17 in VARCHAR2
,P_PBR_ATTRIBUTE18 in VARCHAR2
,P_PBR_ATTRIBUTE19 in VARCHAR2
,P_PBR_ATTRIBUTE20 in VARCHAR2
,P_PBR_ATTRIBUTE21 in VARCHAR2
,P_PBR_ATTRIBUTE22 in VARCHAR2
,P_PBR_ATTRIBUTE23 in VARCHAR2
,P_PBR_ATTRIBUTE24 in VARCHAR2
,P_PBR_ATTRIBUTE25 in VARCHAR2
,P_PBR_ATTRIBUTE26 in VARCHAR2
,P_PBR_ATTRIBUTE27 in VARCHAR2
,P_PBR_ATTRIBUTE28 in VARCHAR2
,P_PBR_ATTRIBUTE29 in VARCHAR2
,P_PBR_ATTRIBUTE30 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PAY_BASIS_RATE_BK1.CREATE_PAY_BASIS_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_PAY_BASIS_RATE_BK1.CREATE_PAY_BASIS_RATE_B', 20);
end CREATE_PAY_BASIS_RATE_B;
end BEN_PAY_BASIS_RATE_BK1;

/