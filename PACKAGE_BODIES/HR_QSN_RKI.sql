--------------------------------------------------------
--  DDL for Package Body HR_QSN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSN_RKI" as
/* $Header: hrqsnrhi.pkb 120.4.12010000.3 2008/11/05 09:57:56 generated ship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2013/08/29 22:00:53 (YYYY/MM/DD HH24:MI:SS)
procedure AFTER_INSERT
(P_QUESTIONNAIRE_TEMPLATE_ID in NUMBER
,P_NAME in VARCHAR2
,P_AVAILABLE_FLAG in VARCHAR2
,P_BUSINESS_GROUP_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_EFFECTIVE_DATE in DATE
)is
begin
hr_utility.set_location('Entering: HR_QSN_RKI.AFTER_INSERT', 10);
hr_utility.set_location(' Leaving: HR_QSN_RKI.AFTER_INSERT', 20);
end AFTER_INSERT;
end HR_QSN_RKI;

/