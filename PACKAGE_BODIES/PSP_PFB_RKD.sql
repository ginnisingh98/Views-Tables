--------------------------------------------------------
--  DDL for Package Body PSP_PFB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PFB_RKD" as
/* $Header: PSPFBRHB.pls 120.0 2005/06/02 15:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:37:10 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PERIOD_FREQUENCY_ID in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
,P_START_DATE_O in DATE
,P_UNIT_OF_MEASURE_O in VARCHAR2
,P_PERIOD_DURATION_O in NUMBER
,P_REPORT_TYPE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PSP_PFB_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PSP_PFB_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PSP_PFB_RKD;

/
