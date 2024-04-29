--------------------------------------------------------
--  DDL for Package Body BEN_PSG_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PSG_RKU" as
/*  $Header: bepsgrhi.pkb 120.0 2005/09/29 06:19:33 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:40:41 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_PIL_ASSIGNMENT_ID in NUMBER
,P_PER_IN_LER_ID in NUMBER
,P_APPLICANT_ASSIGNMENT_ID in NUMBER
,P_OFFER_ASSIGNMENT_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_PER_IN_LER_ID_O in NUMBER
,P_APPLICANT_ASSIGNMENT_ID_O in NUMBER
,P_OFFER_ASSIGNMENT_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: BEN_PSG_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: BEN_PSG_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end BEN_PSG_RKU;

/
