--------------------------------------------------------
--  DDL for Package Body PQH_RNG_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RNG_RKD" as
/* $Header: pqrngrhi.pkb 115.18 2004/06/24 16:51:43 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:40 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_ATTRIBUTE_RANGE_ID in NUMBER
,P_APPROVER_FLAG_O in VARCHAR2
,P_ENABLE_FLAG_O in VARCHAR2
,P_DELETE_FLAG_O in VARCHAR2
,P_ASSIGNMENT_ID_O in NUMBER
,P_ATTRIBUTE_ID_O in NUMBER
,P_FROM_CHAR_O in VARCHAR2
,P_FROM_DATE_O in DATE
,P_FROM_NUMBER_O in NUMBER
,P_POSITION_ID_O in NUMBER
,P_RANGE_NAME_O in VARCHAR2
,P_ROUTING_CATEGORY_ID_O in NUMBER
,P_ROUTING_LIST_MEMBER_ID_O in NUMBER
,P_TO_CHAR_O in VARCHAR2
,P_TO_DATE_O in DATE
,P_TO_NUMBER_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_RNG_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_RNG_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_RNG_RKD;

/