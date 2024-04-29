--------------------------------------------------------
--  DDL for Package Body BEN_PPL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPL_RKD" as
/* $Header: bepplrhi.pkb 120.0.12000000.3 2007/02/08 07:41:23 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/10/10 13:32:32 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PTNL_LER_FOR_PER_ID in NUMBER
,P_CSD_BY_PTNL_LER_FOR_PER_ID_O in NUMBER
,P_LF_EVT_OCRD_DT_O in DATE
,P_TRGR_TABLE_PK_ID_O in NUMBER
,P_PTNL_LER_FOR_PER_STAT_CD_O in VARCHAR2
,P_PTNL_LER_FOR_PER_SRC_CD_O in VARCHAR2
,P_MNL_DT_O in DATE
,P_ENRT_PERD_ID_O in NUMBER
,P_NTFN_DT_O in DATE
,P_DTCTD_DT_O in DATE
,P_PROCD_DT_O in DATE
,P_UNPROCD_DT_O in DATE
,P_VOIDD_DT_O in DATE
,P_MNLO_DT_O in DATE
,P_LER_ID_O in NUMBER
,P_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_REQUEST_ID_O in NUMBER
,P_PROGRAM_APPLICATION_ID_O in NUMBER
,P_PROGRAM_ID_O in NUMBER
,P_PROGRAM_UPDATE_DATE_O in DATE
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_ppl_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_ppl_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_ppl_RKD;

/
