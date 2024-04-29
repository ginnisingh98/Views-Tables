--------------------------------------------------------
--  DDL for Package Body PSP_PFT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PFT_RKD" as
/* $Header: PSPFTRHB.pls 120.0 2005/06/02 15:43 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:37:11 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PERIOD_FREQUENCY_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_PERIOD_FREQUENCY_O in VARCHAR2
,P_SOURCE_LANGUAGE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PSP_PFT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PSP_PFT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PSP_PFT_RKD;

/
