--------------------------------------------------------
--  DDL for Package Body OTA_ANNOUNCEMENT_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ANNOUNCEMENT_BK3" as
/* $Header: otancapi.pkb 115.1 2003/12/30 17:46:26 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:19:02 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_ANNOUNCEMENT_A
(P_ANNOUNCEMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_ANNOUNCEMENT_BK3.DELETE_ANNOUNCEMENT_A', 10);
hr_utility.set_location(' Leaving: OTA_ANNOUNCEMENT_BK3.DELETE_ANNOUNCEMENT_A', 20);
end DELETE_ANNOUNCEMENT_A;
procedure DELETE_ANNOUNCEMENT_B
(P_ANNOUNCEMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: OTA_ANNOUNCEMENT_BK3.DELETE_ANNOUNCEMENT_B', 10);
hr_utility.set_location(' Leaving: OTA_ANNOUNCEMENT_BK3.DELETE_ANNOUNCEMENT_B', 20);
end DELETE_ANNOUNCEMENT_B;
end OTA_ANNOUNCEMENT_BK3;

/