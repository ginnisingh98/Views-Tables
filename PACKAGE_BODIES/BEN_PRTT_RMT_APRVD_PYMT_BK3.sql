--------------------------------------------------------
--  DDL for Package Body BEN_PRTT_RMT_APRVD_PYMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRTT_RMT_APRVD_PYMT_BK3" as
/* $Header: bepryapi.pkb 120.1 2005/12/19 12:20:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:41 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PRTT_RMT_APRVD_PYMT_A
(P_PRTT_RMT_APRVD_FR_PYMT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PRTT_RMT_APRVD_PYMT_BK3.DELETE_PRTT_RMT_APRVD_PYMT_A', 10);
hr_utility.set_location(' Leaving: BEN_PRTT_RMT_APRVD_PYMT_BK3.DELETE_PRTT_RMT_APRVD_PYMT_A', 20);
end DELETE_PRTT_RMT_APRVD_PYMT_A;
procedure DELETE_PRTT_RMT_APRVD_PYMT_B
(P_PRTT_RMT_APRVD_FR_PYMT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PRTT_RMT_APRVD_PYMT_BK3.DELETE_PRTT_RMT_APRVD_PYMT_B', 10);
hr_utility.set_location(' Leaving: BEN_PRTT_RMT_APRVD_PYMT_BK3.DELETE_PRTT_RMT_APRVD_PYMT_B', 20);
end DELETE_PRTT_RMT_APRVD_PYMT_B;
end BEN_PRTT_RMT_APRVD_PYMT_BK3;

/