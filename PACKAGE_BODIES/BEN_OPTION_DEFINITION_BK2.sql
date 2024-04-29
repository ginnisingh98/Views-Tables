--------------------------------------------------------
--  DDL for Package Body BEN_OPTION_DEFINITION_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPTION_DEFINITION_BK2" as
/* $Header: beoptapi.pkb 120.0 2005/05/28 09:56:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:02 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_OPTION_DEFINITION_A
(P_OPT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_NAME in VARCHAR2
,P_CMBN_PTIP_OPT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OPT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_OPT_ATTRIBUTE1 in VARCHAR2
,P_OPT_ATTRIBUTE2 in VARCHAR2
,P_OPT_ATTRIBUTE3 in VARCHAR2
,P_OPT_ATTRIBUTE4 in VARCHAR2
,P_OPT_ATTRIBUTE5 in VARCHAR2
,P_OPT_ATTRIBUTE6 in VARCHAR2
,P_OPT_ATTRIBUTE7 in VARCHAR2
,P_OPT_ATTRIBUTE8 in VARCHAR2
,P_OPT_ATTRIBUTE9 in VARCHAR2
,P_OPT_ATTRIBUTE10 in VARCHAR2
,P_OPT_ATTRIBUTE11 in VARCHAR2
,P_OPT_ATTRIBUTE12 in VARCHAR2
,P_OPT_ATTRIBUTE13 in VARCHAR2
,P_OPT_ATTRIBUTE14 in VARCHAR2
,P_OPT_ATTRIBUTE15 in VARCHAR2
,P_OPT_ATTRIBUTE16 in VARCHAR2
,P_OPT_ATTRIBUTE17 in VARCHAR2
,P_OPT_ATTRIBUTE18 in VARCHAR2
,P_OPT_ATTRIBUTE19 in VARCHAR2
,P_OPT_ATTRIBUTE20 in VARCHAR2
,P_OPT_ATTRIBUTE21 in VARCHAR2
,P_OPT_ATTRIBUTE22 in VARCHAR2
,P_OPT_ATTRIBUTE23 in VARCHAR2
,P_OPT_ATTRIBUTE24 in VARCHAR2
,P_OPT_ATTRIBUTE25 in VARCHAR2
,P_OPT_ATTRIBUTE26 in VARCHAR2
,P_OPT_ATTRIBUTE27 in VARCHAR2
,P_OPT_ATTRIBUTE28 in VARCHAR2
,P_OPT_ATTRIBUTE29 in VARCHAR2
,P_OPT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RQD_PERD_ENRT_NENRT_UOM in VARCHAR2
,P_RQD_PERD_ENRT_NENRT_VAL in NUMBER
,P_RQD_PERD_ENRT_NENRT_RL in NUMBER
,P_INVK_WV_OPT_FLAG in VARCHAR2
,P_SHORT_NAME in VARCHAR2
,P_SHORT_CODE in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_LEGISLATION_SUBGROUP in VARCHAR2
,P_GROUP_OPT_ID in NUMBER
,P_COMPONENT_REASON in VARCHAR2
,P_MAPPING_TABLE_NAME in VARCHAR2
,P_MAPPING_TABLE_PK_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_OPTION_DEFINITION_BK2.UPDATE_OPTION_DEFINITION_A', 10);
hr_utility.set_location(' Leaving: BEN_OPTION_DEFINITION_BK2.UPDATE_OPTION_DEFINITION_A', 20);
end UPDATE_OPTION_DEFINITION_A;
procedure UPDATE_OPTION_DEFINITION_B
(P_OPT_ID in NUMBER
,P_NAME in VARCHAR2
,P_CMBN_PTIP_OPT_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OPT_ATTRIBUTE_CATEGORY in VARCHAR2
,P_OPT_ATTRIBUTE1 in VARCHAR2
,P_OPT_ATTRIBUTE2 in VARCHAR2
,P_OPT_ATTRIBUTE3 in VARCHAR2
,P_OPT_ATTRIBUTE4 in VARCHAR2
,P_OPT_ATTRIBUTE5 in VARCHAR2
,P_OPT_ATTRIBUTE6 in VARCHAR2
,P_OPT_ATTRIBUTE7 in VARCHAR2
,P_OPT_ATTRIBUTE8 in VARCHAR2
,P_OPT_ATTRIBUTE9 in VARCHAR2
,P_OPT_ATTRIBUTE10 in VARCHAR2
,P_OPT_ATTRIBUTE11 in VARCHAR2
,P_OPT_ATTRIBUTE12 in VARCHAR2
,P_OPT_ATTRIBUTE13 in VARCHAR2
,P_OPT_ATTRIBUTE14 in VARCHAR2
,P_OPT_ATTRIBUTE15 in VARCHAR2
,P_OPT_ATTRIBUTE16 in VARCHAR2
,P_OPT_ATTRIBUTE17 in VARCHAR2
,P_OPT_ATTRIBUTE18 in VARCHAR2
,P_OPT_ATTRIBUTE19 in VARCHAR2
,P_OPT_ATTRIBUTE20 in VARCHAR2
,P_OPT_ATTRIBUTE21 in VARCHAR2
,P_OPT_ATTRIBUTE22 in VARCHAR2
,P_OPT_ATTRIBUTE23 in VARCHAR2
,P_OPT_ATTRIBUTE24 in VARCHAR2
,P_OPT_ATTRIBUTE25 in VARCHAR2
,P_OPT_ATTRIBUTE26 in VARCHAR2
,P_OPT_ATTRIBUTE27 in VARCHAR2
,P_OPT_ATTRIBUTE28 in VARCHAR2
,P_OPT_ATTRIBUTE29 in VARCHAR2
,P_OPT_ATTRIBUTE30 in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_RQD_PERD_ENRT_NENRT_UOM in VARCHAR2
,P_RQD_PERD_ENRT_NENRT_VAL in NUMBER
,P_RQD_PERD_ENRT_NENRT_RL in NUMBER
,P_INVK_WV_OPT_FLAG in VARCHAR2
,P_SHORT_NAME in VARCHAR2
,P_SHORT_CODE in VARCHAR2
,P_LEGISLATION_CODE in VARCHAR2
,P_LEGISLATION_SUBGROUP in VARCHAR2
,P_GROUP_OPT_ID in NUMBER
,P_COMPONENT_REASON in VARCHAR2
,P_MAPPING_TABLE_NAME in VARCHAR2
,P_MAPPING_TABLE_PK_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_OPTION_DEFINITION_BK2.UPDATE_OPTION_DEFINITION_B', 10);
hr_utility.set_location(' Leaving: BEN_OPTION_DEFINITION_BK2.UPDATE_OPTION_DEFINITION_B', 20);
end UPDATE_OPTION_DEFINITION_B;
end BEN_OPTION_DEFINITION_BK2;

/