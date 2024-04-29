--------------------------------------------------------
--  DDL for Package Body FF_GLOBALS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_GLOBALS_BK2" as
/* $Header: fffglapi.pkb 120.0.12010000.2 2008/08/05 10:20:50 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 21:57:11 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_GLOBAL_A
(P_EFFECTIVE_DATE in DATE
,P_GLOBAL_ID in NUMBER
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_VALUE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_START_DATE in DATE
,P_EFFECTIVE_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: FF_GLOBALS_BK2.UPDATE_GLOBAL_A', 10);
hr_utility.set_location(' Leaving: FF_GLOBALS_BK2.UPDATE_GLOBAL_A', 20);
end UPDATE_GLOBAL_A;
procedure UPDATE_GLOBAL_B
(P_EFFECTIVE_DATE in DATE
,P_GLOBAL_ID in NUMBER
,P_DATETRACK_UPDATE_MODE in VARCHAR2
,P_VALUE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: FF_GLOBALS_BK2.UPDATE_GLOBAL_B', 10);
hr_utility.set_location(' Leaving: FF_GLOBALS_BK2.UPDATE_GLOBAL_B', 20);
end UPDATE_GLOBAL_B;
end FF_GLOBALS_BK2;

/
