--------------------------------------------------------
--  DDL for Package Body PAY_PCT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PCT_RKD" as
/* $Header: pypctrhi.pkb 120.0 2005/05/29 07:25:45 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:06 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_DELETE
(P_USER_COLUMN_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG_O in VARCHAR2
,P_USER_COLUMN_NAME_O in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_PCT_RKD.AFTER_DELETE', 10);
hr_utility.set_location(' Leaving: PAY_PCT_RKD.AFTER_DELETE', 20);
end AFTER_DELETE;
end PAY_PCT_RKD;

/