--------------------------------------------------------
--  DDL for Package Body PER_CNF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CNF_RKU" as
/* $Header: pecnfrhi.pkb 120.0 2005/05/31 06:47 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:49 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_CONFIGURATION_CODE in VARCHAR2
,P_CONFIGURATION_TYPE in VARCHAR2
,P_CONFIGURATION_STATUS in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_CONFIGURATION_TYPE_O in VARCHAR2
,P_CONFIGURATION_STATUS_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PER_CNF_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PER_CNF_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PER_CNF_RKU;

/