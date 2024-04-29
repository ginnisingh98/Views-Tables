--------------------------------------------------------
--  DDL for Package Body PSP_PERIOD_FREQUENCY_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PERIOD_FREQUENCY_BK3" as
/* $Header: PSPFBAIB.pls 120.0 2005/06/02 15:59 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:37:10 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_PERIOD_FREQUENCY_A
(P_PERIOD_FREQUENCY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_API_WARNING in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PSP_PERIOD_FREQUENCY_BK3.DELETE_PERIOD_FREQUENCY_A', 10);
hr_utility.set_location(' Leaving: PSP_PERIOD_FREQUENCY_BK3.DELETE_PERIOD_FREQUENCY_A', 20);
end DELETE_PERIOD_FREQUENCY_A;
procedure DELETE_PERIOD_FREQUENCY_B
(P_PERIOD_FREQUENCY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PSP_PERIOD_FREQUENCY_BK3.DELETE_PERIOD_FREQUENCY_B', 10);
hr_utility.set_location(' Leaving: PSP_PERIOD_FREQUENCY_BK3.DELETE_PERIOD_FREQUENCY_B', 20);
end DELETE_PERIOD_FREQUENCY_B;
end PSP_PERIOD_FREQUENCY_BK3;

/
