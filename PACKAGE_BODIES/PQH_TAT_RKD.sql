--------------------------------------------------------
--  DDL for Package Body PQH_TAT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TAT_RKD" as
/* $Header: pqtatrhi.pkb 120.2 2005/10/12 20:19:38 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:43 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_TEMPLATE_ATTRIBUTE_ID in NUMBER
,P_REQUIRED_FLAG_O in VARCHAR2
,P_VIEW_FLAG_O in VARCHAR2
,P_EDIT_FLAG_O in VARCHAR2
,P_ATTRIBUTE_ID_O in NUMBER
,P_TEMPLATE_ID_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_TAT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PQH_TAT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PQH_TAT_RKD;

/