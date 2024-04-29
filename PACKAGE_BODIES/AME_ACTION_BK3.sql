--------------------------------------------------------
--  DDL for Package Body AME_ACTION_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_ACTION_BK3" as
/* $Header: amatyapi.pkb 120.0 2005/09/02 03:52:24 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:32 (YYYY/MM/DD HH24:MI:SS)
procedure CREATE_AME_REQ_ATTRIBUTE_A
(P_ATTRIBUTE_ID in NUMBER
,P_ACTION_TYPE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_START_DATE in DATE
,P_END_DATE in DATE
)is
begin
hr_utility.set_location('Entering: AME_ACTION_BK3.CREATE_AME_REQ_ATTRIBUTE_A', 10);
hr_utility.set_location(' Leaving: AME_ACTION_BK3.CREATE_AME_REQ_ATTRIBUTE_A', 20);
end CREATE_AME_REQ_ATTRIBUTE_A;
procedure CREATE_AME_REQ_ATTRIBUTE_B
(P_ATTRIBUTE_ID in NUMBER
,P_ACTION_TYPE_ID in NUMBER
)is
begin
hr_utility.set_location('Entering: AME_ACTION_BK3.CREATE_AME_REQ_ATTRIBUTE_B', 10);
hr_utility.set_location(' Leaving: AME_ACTION_BK3.CREATE_AME_REQ_ATTRIBUTE_B', 20);
end CREATE_AME_REQ_ATTRIBUTE_B;
end AME_ACTION_BK3;

/
