--------------------------------------------------------
--  DDL for Package Body BEN_XCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_XCL_RKD" as
/* $Header: bexclrhi.pkb 115.7 2002/12/24 21:28:21 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:02:22 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_EXT_CHG_EVT_LOG_ID in NUMBER
,P_CHG_EVT_CD_O in VARCHAR2
,P_CHG_EFF_DT_O in DATE
,P_CHG_USER_ID_O in NUMBER
,P_PRMTR_01_O in VARCHAR2
,P_PRMTR_02_O in VARCHAR2
,P_PRMTR_03_O in VARCHAR2
,P_PRMTR_04_O in VARCHAR2
,P_PRMTR_05_O in VARCHAR2
,P_PRMTR_06_O in VARCHAR2
,P_PRMTR_07_O in VARCHAR2
,P_PRMTR_08_O in VARCHAR2
,P_PRMTR_09_O in VARCHAR2
,P_PRMTR_10_O in VARCHAR2
,P_PERSON_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_xcl_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_xcl_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_xcl_RKD;

/