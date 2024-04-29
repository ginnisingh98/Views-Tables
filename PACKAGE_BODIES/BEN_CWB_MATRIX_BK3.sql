--------------------------------------------------------
--  DDL for Package Body BEN_CWB_MATRIX_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_MATRIX_BK3" as
/* $Header: bebcmapi.pkb 115.2 2003/03/10 14:38:58 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:56:18 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_CWB_MATRIX_A
(P_EFFECTIVE_DATE in DATE
,P_CWB_MATRIX_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_CWB_MATRIX_BK3.DELETE_CWB_MATRIX_A', 10);
hr_utility.set_location(' Leaving: BEN_CWB_MATRIX_BK3.DELETE_CWB_MATRIX_A', 20);
end DELETE_CWB_MATRIX_A;
procedure DELETE_CWB_MATRIX_B
(P_CWB_MATRIX_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_CWB_MATRIX_BK3.DELETE_CWB_MATRIX_B', 10);
hr_utility.set_location(' Leaving: BEN_CWB_MATRIX_BK3.DELETE_CWB_MATRIX_B', 20);
end DELETE_CWB_MATRIX_B;
end BEN_CWB_MATRIX_BK3;

/
