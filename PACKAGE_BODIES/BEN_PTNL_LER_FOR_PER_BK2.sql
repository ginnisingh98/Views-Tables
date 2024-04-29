--------------------------------------------------------
--  DDL for Package Body BEN_PTNL_LER_FOR_PER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PTNL_LER_FOR_PER_BK2" as
/* $Header: bepplapi.pkb 120.0 2005/05/28 10:58:30 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:31 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_PTNL_LER_FOR_PER_A
(P_PTNL_LER_FOR_PER_ID in NUMBER
,P_CSD_BY_PTNL_LER_FOR_PER_ID in NUMBER
,P_LF_EVT_OCRD_DT in DATE
,P_TRGR_TABLE_PK_ID in NUMBER
,P_PTNL_LER_FOR_PER_STAT_CD in VARCHAR2
,P_PTNL_LER_FOR_PER_SRC_CD in VARCHAR2
,P_MNL_DT in DATE
,P_ENRT_PERD_ID in NUMBER
,P_LER_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_DTCTD_DT in DATE
,P_PROCD_DT in DATE
,P_UNPROCD_DT in DATE
,P_VOIDD_DT in DATE
,P_MNLO_DT in DATE
,P_NTFN_DT in DATE
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PTNL_LER_FOR_PER_BK2.UPDATE_PTNL_LER_FOR_PER_A', 10);
hr_utility.set_location(' Leaving: BEN_PTNL_LER_FOR_PER_BK2.UPDATE_PTNL_LER_FOR_PER_A', 20);
end UPDATE_PTNL_LER_FOR_PER_A;
procedure UPDATE_PTNL_LER_FOR_PER_B
(P_PTNL_LER_FOR_PER_ID in NUMBER
,P_CSD_BY_PTNL_LER_FOR_PER_ID in NUMBER
,P_LF_EVT_OCRD_DT in DATE
,P_TRGR_TABLE_PK_ID in NUMBER
,P_PTNL_LER_FOR_PER_STAT_CD in VARCHAR2
,P_PTNL_LER_FOR_PER_SRC_CD in VARCHAR2
,P_MNL_DT in DATE
,P_ENRT_PERD_ID in NUMBER
,P_LER_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_DTCTD_DT in DATE
,P_PROCD_DT in DATE
,P_UNPROCD_DT in DATE
,P_VOIDD_DT in DATE
,P_MNLO_DT in DATE
,P_NTFN_DT in DATE
,P_REQUEST_ID in NUMBER
,P_PROGRAM_APPLICATION_ID in NUMBER
,P_PROGRAM_ID in NUMBER
,P_PROGRAM_UPDATE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_PTNL_LER_FOR_PER_BK2.UPDATE_PTNL_LER_FOR_PER_B', 10);
hr_utility.set_location(' Leaving: BEN_PTNL_LER_FOR_PER_BK2.UPDATE_PTNL_LER_FOR_PER_B', 20);
end UPDATE_PTNL_LER_FOR_PER_B;
end BEN_PTNL_LER_FOR_PER_BK2;

/
