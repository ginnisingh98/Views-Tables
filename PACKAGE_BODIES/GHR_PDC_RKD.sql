--------------------------------------------------------
--  DDL for Package Body GHR_PDC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDC_RKD" as
/* $Header: ghpdcrhi.pkb 120.0.12010000.3 2009/05/27 05:40:10 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/30 11:35:42 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PD_CLASSIFICATION_ID in NUMBER
,P_POSITION_DESCRIPTION_ID_O in NUMBER
,P_CLASS_GRADE_BY_O in VARCHAR2
,P_OFFICIAL_TITLE_O in VARCHAR2
,P_PAY_PLAN_O in VARCHAR2
,P_OCCUPATIONAL_CODE_O in VARCHAR2
,P_GRADE_LEVEL_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: GHR_PDC_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: GHR_PDC_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end GHR_PDC_RKD;

/