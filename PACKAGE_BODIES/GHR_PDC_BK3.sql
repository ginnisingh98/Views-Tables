--------------------------------------------------------
--  DDL for Package Body GHR_PDC_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDC_BK3" as
/* $Header: ghpdcapi.pkb 115.5 99/10/14 12:10:59 generated ship  $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:53:05 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PDC_A
(P_PD_CLASSIFICATION_ID in NUMBER
,P_PDC_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_PDC_BK3.DELETE_PDC_A', 10);
hr_utility.set_location(' Leaving: GHR_PDC_BK3.DELETE_PDC_A', 20);
end DELETE_PDC_A;
procedure DELETE_PDC_B
(P_PD_CLASSIFICATION_ID in NUMBER
,P_PDC_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_PDC_BK3.DELETE_PDC_B', 10);
hr_utility.set_location(' Leaving: GHR_PDC_BK3.DELETE_PDC_B', 20);
end DELETE_PDC_B;
end GHR_PDC_BK3;

/
