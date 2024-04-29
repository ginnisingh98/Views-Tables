--------------------------------------------------------
--  DDL for Package Body BEN_EXT_RCD_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_RCD_BK3" as
/* $Header: bexrcapi.pkb 115.4 2003/05/14 01:17:27 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:12 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_EXT_RCD_A
(P_EXT_RCD_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_EXT_RCD_BK3.DELETE_EXT_RCD_A', 10);
hr_utility.set_location(' Leaving: BEN_EXT_RCD_BK3.DELETE_EXT_RCD_A', 20);
end DELETE_EXT_RCD_A;
procedure DELETE_EXT_RCD_B
(P_EXT_RCD_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_EXT_RCD_BK3.DELETE_EXT_RCD_B', 10);
hr_utility.set_location(' Leaving: BEN_EXT_RCD_BK3.DELETE_EXT_RCD_B', 20);
end DELETE_EXT_RCD_B;
end BEN_EXT_RCD_BK3;

/