--------------------------------------------------------
--  DDL for Package Body PAY_IVT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IVT_RKD" as
/* $Header: pyivtrhi.pkb 120.1 2005/10/04 23:01:29 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:02 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_INPUT_VALUE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_NAME_O in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_IVT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_IVT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_IVT_RKD;

/