--------------------------------------------------------
--  DDL for Package Body BEN_EXT_DATA_ELMT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_DATA_ELMT_BK3" as
/* $Header: bexelapi.pkb 120.1 2005/06/08 13:17:21 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:41:10 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_EXT_DATA_ELMT_A
(P_EXT_DATA_ELMT_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_EXT_DATA_ELMT_BK3.DELETE_EXT_DATA_ELMT_A', 10);
hr_utility.set_location(' Leaving: BEN_EXT_DATA_ELMT_BK3.DELETE_EXT_DATA_ELMT_A', 20);
end DELETE_EXT_DATA_ELMT_A;
procedure DELETE_EXT_DATA_ELMT_B
(P_EXT_DATA_ELMT_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_EXT_DATA_ELMT_BK3.DELETE_EXT_DATA_ELMT_B', 10);
hr_utility.set_location(' Leaving: BEN_EXT_DATA_ELMT_BK3.DELETE_EXT_DATA_ELMT_B', 20);
end DELETE_EXT_DATA_ELMT_B;
end BEN_EXT_DATA_ELMT_BK3;

/
