--------------------------------------------------------
--  DDL for Package Body BEN_BATCH_PARAMETER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BATCH_PARAMETER_BK1" as
/* $Header: bebbpapi.pkb 115.3 2002/12/13 06:52:52 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:37:34 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_BATCH_PARAMETER_A
(P_BATCH_PARAMETER_ID in NUMBER
,P_BATCH_EXE_CD in VARCHAR2
,P_THREAD_CNT_NUM in NUMBER
,P_MAX_ERR_NUM in NUMBER
,P_CHUNK_SIZE in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_BATCH_PARAMETER_BK1.CREATE_BATCH_PARAMETER_A', 10);
hr_utility.set_location(' Leaving: BEN_BATCH_PARAMETER_BK1.CREATE_BATCH_PARAMETER_A', 20);
end CREATE_BATCH_PARAMETER_A;
procedure CREATE_BATCH_PARAMETER_B
(P_BATCH_EXE_CD in VARCHAR2
,P_THREAD_CNT_NUM in NUMBER
,P_MAX_ERR_NUM in NUMBER
,P_CHUNK_SIZE in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: BEN_BATCH_PARAMETER_BK1.CREATE_BATCH_PARAMETER_B', 10);
hr_utility.set_location(' Leaving: BEN_BATCH_PARAMETER_BK1.CREATE_BATCH_PARAMETER_B', 20);
end CREATE_BATCH_PARAMETER_B;
end BEN_BATCH_PARAMETER_BK1;

/