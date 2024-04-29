--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_BNFT_CERT_INFO_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_BNFT_CERT_INFO_BK1" as
/* $Header: bebciapi.pkb 115.4 2002/12/16 10:30:08 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:18 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_BATCH_BNFT_CERT_INFO_A
(P_BATCH_BENFT_CERT_ID in NUMBER
,P_BENEFIT_ACTION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_ACTN_TYP_ID in NUMBER
,P_TYP_CD in VARCHAR2
,P_ENRT_CTFN_RECD_DT in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_BATCH_BNFT_CERT_INFO_BK1.CREATE_BATCH_BNFT_CERT_INFO_A', 10);
hr_utility.set_location(' Leaving: BEN_BATCH_BNFT_CERT_INFO_BK1.CREATE_BATCH_BNFT_CERT_INFO_A', 20);
end CREATE_BATCH_BNFT_CERT_INFO_A;
procedure CREATE_BATCH_BNFT_CERT_INFO_B
(P_BENEFIT_ACTION_ID in NUMBER
,P_PERSON_ID in NUMBER
,P_ACTN_TYP_ID in NUMBER
,P_TYP_CD in VARCHAR2
,P_ENRT_CTFN_RECD_DT in DATE
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_BATCH_BNFT_CERT_INFO_BK1.CREATE_BATCH_BNFT_CERT_INFO_B', 10);
hr_utility.set_location(' Leaving: BEN_BATCH_BNFT_CERT_INFO_BK1.CREATE_BATCH_BNFT_CERT_INFO_B', 20);
end CREATE_BATCH_BNFT_CERT_INFO_B;
end BEN_BATCH_BNFT_CERT_INFO_BK1;

/
