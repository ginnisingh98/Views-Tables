--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_GOODS_SERVICES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_GOODS_SERVICES_BK2" as
/* $Header: bevgsapi.pkb 120.0 2005/05/28 12:03:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:59 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PLAN_GOODS_SERVICES_A
(P_PL_GD_OR_SVC_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_BUSINESS_GROUP_ID in NUMBER
,P_PL_ID in NUMBER
,P_GD_OR_SVC_TYP_ID in NUMBER
,P_ALW_RCRRG_CLMS_FLAG in VARCHAR2
,P_GD_OR_SVC_USG_CD in VARCHAR2
,P_VGS_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VGS_ATTRIBUTE1 in VARCHAR2
,P_VGS_ATTRIBUTE2 in VARCHAR2
,P_VGS_ATTRIBUTE3 in VARCHAR2
,P_VGS_ATTRIBUTE4 in VARCHAR2
,P_VGS_ATTRIBUTE5 in VARCHAR2
,P_VGS_ATTRIBUTE6 in VARCHAR2
,P_VGS_ATTRIBUTE7 in VARCHAR2
,P_VGS_ATTRIBUTE8 in VARCHAR2
,P_VGS_ATTRIBUTE9 in VARCHAR2
,P_VGS_ATTRIBUTE10 in VARCHAR2
,P_VGS_ATTRIBUTE11 in VARCHAR2
,P_VGS_ATTRIBUTE12 in VARCHAR2
,P_VGS_ATTRIBUTE13 in VARCHAR2
,P_VGS_ATTRIBUTE14 in VARCHAR2
,P_VGS_ATTRIBUTE15 in VARCHAR2
,P_VGS_ATTRIBUTE16 in VARCHAR2
,P_VGS_ATTRIBUTE17 in VARCHAR2
,P_VGS_ATTRIBUTE18 in VARCHAR2
,P_VGS_ATTRIBUTE19 in VARCHAR2
,P_VGS_ATTRIBUTE20 in VARCHAR2
,P_VGS_ATTRIBUTE21 in VARCHAR2
,P_VGS_ATTRIBUTE22 in VARCHAR2
,P_VGS_ATTRIBUTE23 in VARCHAR2
,P_VGS_ATTRIBUTE24 in VARCHAR2
,P_VGS_ATTRIBUTE25 in VARCHAR2
,P_VGS_ATTRIBUTE26 in VARCHAR2
,P_VGS_ATTRIBUTE27 in VARCHAR2
,P_VGS_ATTRIBUTE28 in VARCHAR2
,P_VGS_ATTRIBUTE29 in VARCHAR2
,P_VGS_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_GD_SVC_RECD_BASIS_CD in VARCHAR2
,P_GD_SVC_RECD_BASIS_DT in DATE
,P_GD_SVC_RECD_BASIS_MO in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PLAN_GOODS_SERVICES_BK2.UPDATE_PLAN_GOODS_SERVICES_A', 10);
hr_utility.set_location(' Leaving: BEN_PLAN_GOODS_SERVICES_BK2.UPDATE_PLAN_GOODS_SERVICES_A', 20);
end UPDATE_PLAN_GOODS_SERVICES_A;
procedure UPDATE_PLAN_GOODS_SERVICES_B
(P_PL_GD_OR_SVC_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_PL_ID in NUMBER
,P_GD_OR_SVC_TYP_ID in NUMBER
,P_ALW_RCRRG_CLMS_FLAG in VARCHAR2
,P_GD_OR_SVC_USG_CD in VARCHAR2
,P_VGS_ATTRIBUTE_CATEGORY in VARCHAR2
,P_VGS_ATTRIBUTE1 in VARCHAR2
,P_VGS_ATTRIBUTE2 in VARCHAR2
,P_VGS_ATTRIBUTE3 in VARCHAR2
,P_VGS_ATTRIBUTE4 in VARCHAR2
,P_VGS_ATTRIBUTE5 in VARCHAR2
,P_VGS_ATTRIBUTE6 in VARCHAR2
,P_VGS_ATTRIBUTE7 in VARCHAR2
,P_VGS_ATTRIBUTE8 in VARCHAR2
,P_VGS_ATTRIBUTE9 in VARCHAR2
,P_VGS_ATTRIBUTE10 in VARCHAR2
,P_VGS_ATTRIBUTE11 in VARCHAR2
,P_VGS_ATTRIBUTE12 in VARCHAR2
,P_VGS_ATTRIBUTE13 in VARCHAR2
,P_VGS_ATTRIBUTE14 in VARCHAR2
,P_VGS_ATTRIBUTE15 in VARCHAR2
,P_VGS_ATTRIBUTE16 in VARCHAR2
,P_VGS_ATTRIBUTE17 in VARCHAR2
,P_VGS_ATTRIBUTE18 in VARCHAR2
,P_VGS_ATTRIBUTE19 in VARCHAR2
,P_VGS_ATTRIBUTE20 in VARCHAR2
,P_VGS_ATTRIBUTE21 in VARCHAR2
,P_VGS_ATTRIBUTE22 in VARCHAR2
,P_VGS_ATTRIBUTE23 in VARCHAR2
,P_VGS_ATTRIBUTE24 in VARCHAR2
,P_VGS_ATTRIBUTE25 in VARCHAR2
,P_VGS_ATTRIBUTE26 in VARCHAR2
,P_VGS_ATTRIBUTE27 in VARCHAR2
,P_VGS_ATTRIBUTE28 in VARCHAR2
,P_VGS_ATTRIBUTE29 in VARCHAR2
,P_VGS_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
,P_GD_SVC_RECD_BASIS_CD in VARCHAR2
,P_GD_SVC_RECD_BASIS_DT in DATE
,P_GD_SVC_RECD_BASIS_MO in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PLAN_GOODS_SERVICES_BK2.UPDATE_PLAN_GOODS_SERVICES_B', 10);
hr_utility.set_location(' Leaving: BEN_PLAN_GOODS_SERVICES_BK2.UPDATE_PLAN_GOODS_SERVICES_B', 20);
end UPDATE_PLAN_GOODS_SERVICES_B;
end BEN_PLAN_GOODS_SERVICES_BK2;

/