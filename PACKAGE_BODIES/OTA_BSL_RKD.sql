--------------------------------------------------------
--  DDL for Package Body OTA_BSL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_BSL_RKD" as
/* $Header: otbslrhi.pkb 115.1 2003/04/24 17:27:36 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:03 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_BOOKING_STATUS_TYPE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_NAME_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_BSL_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_BSL_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_BSL_RKD;

/
