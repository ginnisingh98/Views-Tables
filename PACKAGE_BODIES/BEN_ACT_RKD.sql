--------------------------------------------------------
--  DDL for Package Body BEN_ACT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACT_RKD" as
/* $Header: beactrhi.pkb 120.0 2005/05/28 00:20:33 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_PERSON_ACTION_ID in NUMBER
,P_PERSON_ID_O in NUMBER
,P_LER_ID_O in NUMBER
,P_BENEFIT_ACTION_ID_O in NUMBER
,P_ACTION_STATUS_CD_O in VARCHAR2
,P_CHUNK_NUMBER_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: ben_act_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: ben_act_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end ben_act_RKD;

/