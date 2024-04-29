--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_BNFTS_BAL_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_BNFTS_BAL_BK3" as
/* $Header: bepbbapi.pkb 115.3 2002/12/16 09:36:54 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:05 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PERSON_BNFTS_BAL_A
(P_PER_BNFTS_BAL_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PERSON_BNFTS_BAL_BK3.DELETE_PERSON_BNFTS_BAL_A', 10);
hr_utility.set_location(' Leaving: BEN_PERSON_BNFTS_BAL_BK3.DELETE_PERSON_BNFTS_BAL_A', 20);
end DELETE_PERSON_BNFTS_BAL_A;
procedure DELETE_PERSON_BNFTS_BAL_B
(P_PER_BNFTS_BAL_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PERSON_BNFTS_BAL_BK3.DELETE_PERSON_BNFTS_BAL_B', 10);
hr_utility.set_location(' Leaving: BEN_PERSON_BNFTS_BAL_BK3.DELETE_PERSON_BNFTS_BAL_B', 20);
end DELETE_PERSON_BNFTS_BAL_B;
end BEN_PERSON_BNFTS_BAL_BK3;

/