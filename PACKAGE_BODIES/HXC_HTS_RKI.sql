--------------------------------------------------------
--  DDL for Package Body HXC_HTS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_HTS_RKI" as
/* $Header: hxchtsrhi.pkb 120.2 2005/09/23 07:49:02 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:58:01 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_EFFECTIVE_DATE in DATE
,P_TIME_SOURCE_ID in NUMBER
,P_NAME in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: HXC_HTS_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HXC_HTS_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HXC_HTS_RKI;

/
