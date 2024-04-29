--------------------------------------------------------
--  DDL for Package Body PQH_OPS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_OPS_RKU" as
/* $Header: pqopsrhi.pkb 115.2 2002/12/03 20:41:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:35:25 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_EFFECTIVE_DATE in DATE
,P_WRKPLC_VLDTN_OP_ID in NUMBER
,P_WRKPLC_VLDTN_VER_ID in NUMBER
,P_WRKPLC_OPERATION_ID in NUMBER
,P_BUSINESS_GROUP_ID in NUMBER
,P_DESCRIPTION in VARCHAR2
,P_UNIT_PERCENTAGE in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_WRKPLC_VLDTN_VER_ID_O in NUMBER
,P_WRKPLC_OPERATION_ID_O in NUMBER
,P_BUSINESS_GROUP_ID_O in NUMBER
,P_DESCRIPTION_O in VARCHAR2
,P_UNIT_PERCENTAGE_O in NUMBER
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PQH_OPS_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PQH_OPS_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PQH_OPS_RKU;

/
