--------------------------------------------------------
--  DDL for Package Body PAY_RTT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RTT_RKI" as
/* $Header: pyrttrhi.pkb 115.4 2003/02/06 17:21:56 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:28:24 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_RUN_TYPE_ID in NUMBER
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_RUN_TYPE_NAME in VARCHAR2
,P_SHORTNAME in VARCHAR2
)is
begin
hr_utility.set_location('Entering: PAY_RTT_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: PAY_RTT_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end PAY_RTT_RKI;

/
