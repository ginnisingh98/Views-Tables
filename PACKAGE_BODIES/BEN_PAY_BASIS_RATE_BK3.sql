--------------------------------------------------------
--  DDL for Package Body BEN_PAY_BASIS_RATE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PAY_BASIS_RATE_BK3" as
/* $Header: bepbrapi.pkb 115.3 2002/12/16 09:37:16 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:06 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PAY_BASIS_RATE_A
(P_PY_BSS_RT_ID in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PAY_BASIS_RATE_BK3.DELETE_PAY_BASIS_RATE_A', 10);
hr_utility.set_location(' Leaving: BEN_PAY_BASIS_RATE_BK3.DELETE_PAY_BASIS_RATE_A', 20);
end DELETE_PAY_BASIS_RATE_A;
procedure DELETE_PAY_BASIS_RATE_B
(P_PY_BSS_RT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_DATETRACK_MODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: BEN_PAY_BASIS_RATE_BK3.DELETE_PAY_BASIS_RATE_B', 10);
hr_utility.set_location(' Leaving: BEN_PAY_BASIS_RATE_BK3.DELETE_PAY_BASIS_RATE_B', 20);
end DELETE_PAY_BASIS_RATE_B;
end BEN_PAY_BASIS_RATE_BK3;

/