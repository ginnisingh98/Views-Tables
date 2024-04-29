--------------------------------------------------------
--  DDL for Package Body PQH_RATE_MATRIX_NODES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RATE_MATRIX_NODES_BK1" as
/* $Header: pqrmnapi.pkb 120.1 2005/07/13 04:52:50 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:37 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_RATE_MATRIX_NODE_A
(P_EFFECTIVE_DATE in DATE
,P_RATE_MATRIX_NODE_ID in NUMBER
,P_SHORT_CODE in VARCHAR2
,P_PL_ID in NUMBER
,P_LEVEL_NUMBER in NUMBER
,P_CRITERIA_SHORT_CODE in VARCHAR2
,P_NODE_NAME in VARCHAR2
,P_PARENT_NODE_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RATE_MATRIX_NODES_BK1.CREATE_RATE_MATRIX_NODE_A', 10);
hr_utility.set_location(' Leaving: PQH_RATE_MATRIX_NODES_BK1.CREATE_RATE_MATRIX_NODE_A', 20);
end CREATE_RATE_MATRIX_NODE_A;
procedure CREATE_RATE_MATRIX_NODE_B
(P_EFFECTIVE_DATE in DATE
,P_SHORT_CODE in VARCHAR2
,P_PL_ID in NUMBER
,P_LEVEL_NUMBER in NUMBER
,P_CRITERIA_SHORT_CODE in VARCHAR2
,P_NODE_NAME in VARCHAR2
,P_PARENT_NODE_ID in NUMBER
,P_ELIGY_PRFL_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_LEGISLATION_CODE in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_RATE_MATRIX_NODES_BK1.CREATE_RATE_MATRIX_NODE_B', 10);
hr_utility.set_location(' Leaving: PQH_RATE_MATRIX_NODES_BK1.CREATE_RATE_MATRIX_NODE_B', 20);
end CREATE_RATE_MATRIX_NODE_B;
end PQH_RATE_MATRIX_NODES_BK1;

/
