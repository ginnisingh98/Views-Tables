--------------------------------------------------------
--  DDL for Package Body HR_QSF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSF_RKI" as
/* $Header: hrqsfrhi.pkb 115.11 2003/08/27 00:16:45 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:17 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_FIELD_ID in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID in NUMBER
,P_NAME in VARCHAR2
,P_TYPE in VARCHAR2
,P_HTML_TEXT in VARCHAR2
,P_SQL_REQUIRED_FLAG in VARCHAR2
,P_SQL_TEXT in VARCHAR2
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: HR_QSF_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HR_QSF_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HR_QSF_RKI;

/
