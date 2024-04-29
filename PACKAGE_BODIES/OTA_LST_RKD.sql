--------------------------------------------------------
--  DDL for Package Body OTA_LST_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_LST_RKD" as
/* $Header: otlstrhi.pkb 120.0 2005/05/29 07:25:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:20 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_LEARNING_PATH_SECTION_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_NAME_O in VARCHAR2
,P_DESCRIPTION_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: OTA_LST_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: OTA_LST_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end OTA_LST_RKD;

/
