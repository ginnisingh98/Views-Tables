--------------------------------------------------------
--  DDL for Package Body PAY_PTT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PTT_RKD" as
/* $Header: pypttrhi.pkb 120.0 2005/05/29 07:56:54 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_USER_TABLE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_USER_TABLE_NAME_O in VARCHAR2
,P_USER_ROW_TITLE_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_PTT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PTT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PTT_RKD;

/
