--------------------------------------------------------
--  DDL for Package Body PQH_ATTRIBUTES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATTRIBUTES_BK1" as
/* $Header: pqattapi.pkb 115.13 2003/03/25 04:16:57 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:01 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_ATTRIBUTE_A
(P_ATTRIBUTE_ID in NUMBER
,P_ATTRIBUTE_NAME in VARCHAR2
,P_MASTER_ATTRIBUTE_ID in NUMBER
,P_MASTER_TABLE_ROUTE_ID in NUMBER
,P_COLUMN_NAME in VARCHAR2
,P_COLUMN_TYPE in VARCHAR2
,P_ENABLE_FLAG in VARCHAR2
,P_WIDTH in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_REGION_ITEMNAME in VARCHAR2
,P_ATTRIBUTE_ITEMNAME in VARCHAR2
,P_DECODE_FUNCTION_NAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_ATTRIBUTES_BK1.CREATE_ATTRIBUTE_A', 10);
hr_utility.set_location(' Leaving: PQH_ATTRIBUTES_BK1.CREATE_ATTRIBUTE_A', 20);
end CREATE_ATTRIBUTE_A;
procedure CREATE_ATTRIBUTE_B
(P_ATTRIBUTE_NAME in VARCHAR2
,P_MASTER_ATTRIBUTE_ID in NUMBER
,P_MASTER_TABLE_ROUTE_ID in NUMBER
,P_COLUMN_NAME in VARCHAR2
,P_COLUMN_TYPE in VARCHAR2
,P_ENABLE_FLAG in VARCHAR2
,P_WIDTH in NUMBER
,P_EFFECTIVE_DATE in DATE
,P_REGION_ITEMNAME in VARCHAR2
,P_ATTRIBUTE_ITEMNAME in VARCHAR2
,P_DECODE_FUNCTION_NAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PQH_ATTRIBUTES_BK1.CREATE_ATTRIBUTE_B', 10);
hr_utility.set_location(' Leaving: PQH_ATTRIBUTES_BK1.CREATE_ATTRIBUTE_B', 20);
end CREATE_ATTRIBUTE_B;
end PQH_ATTRIBUTES_BK1;

/
