--------------------------------------------------------
--  DDL for Package Body PAY_BCT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BCT_RKU" as
/* $Header: pybctrhi.pkb 120.0.12000000.4 2007/08/20 08:21:49 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2008/10/18 16:42:43 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_UPDATE
(P_SESSION_DATE in DATE
,P_BATCH_CONTROL_ID in NUMBER
,P_CONTROL_STATUS in VARCHAR2
,P_CONTROL_TOTAL in VARCHAR2
,P_CONTROL_TYPE in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_BATCH_ID_O in NUMBER
,P_CONTROL_STATUS_O in VARCHAR2
,P_CONTROL_TOTAL_O in VARCHAR2
,P_CONTROL_TYPE_O in VARCHAR2
,P_OBJECT_VERSION_NUMBER_O in NUMBER
)is
begin
hr_utility.set_location('Entering: PAY_BCT_RKU.AFTER_UPDATE', 10);
hr_utility.set_location(' Leaving: PAY_BCT_RKU.AFTER_UPDATE', 20);
end AFTER_UPDATE;
end PAY_BCT_RKU;

/