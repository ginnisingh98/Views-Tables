--------------------------------------------------------
--  DDL for Package Body AME_CVL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_CVL_RKI" as
/* $Header: amcvlrhi.pkb 120.1 2006/01/03 02:46 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 08:30:35 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_VARIABLE_NAME in VARCHAR2
,P_LANGUAGE in VARCHAR2
,P_SOURCE_LANG in VARCHAR2
,P_USER_CONFIG_VAR_NAME in VARCHAR2
,P_DESCRIPTION in VARCHAR2
)is
begin
hr_utility.set_location('Entering: AME_CVL_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: AME_CVL_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end AME_CVL_RKI;

/
