--------------------------------------------------------
--  DDL for Package Body PQH_VER_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_VER_RKD" as
/* $Header: pqverrhi.pkb 115.3 2002/12/05 00:30:42 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:48 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_WRKPLC_VLDTN_VER_ID in NUMBER
,P_WRKPLC_VLDTN_ID_O in NUMBER
,P_VERSION_NUMBER_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_TARIFF_CONTRACT_CODE_O in VARCHAR2
,P_TARIFF_GROUP_CODE_O in VARCHAR2
,P_REMUNERATION_JOB_DESCRIPTI_O in VARCHAR2
,P_JOB_GROUP_ID_O in NUMBER
,P_REMUNERATION_JOB_ID_O in NUMBER
,P_DERIVED_GRADE_ID_O in NUMBER
,P_DERIVED_CASE_GROUP_ID_O in NUMBER
,P_DERIVED_SUBCASGRP_ID_O in NUMBER
,P_USER_ENTERABLE_GRADE_ID_O in NUMBER
,P_USER_ENTERABLE_CASE_GROUP__O in NUMBER
,P_USER_ENTERABLE_SUBCASGRP_I_O in NUMBER
,P_FREEZE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_VER_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_VER_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_VER_RKD;

/