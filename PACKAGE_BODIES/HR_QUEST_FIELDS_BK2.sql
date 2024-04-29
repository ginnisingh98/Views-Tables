--------------------------------------------------------
--  DDL for Package Body HR_QUEST_FIELDS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_FIELDS_BK2" as
/* $Header: hrqsfapi.pkb 120.0 2005/05/31 02:26:58 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:17 (YYYY/MM/DD HH24:MI:SS)
procedure UPDATE_QUEST_FIELDS_A
(P_EFFECTIVE_DATE in DATE
,P_FIELD_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID in NUMBER
,P_NAME in VARCHAR2
,P_TYPE in VARCHAR2
,P_SQL_REQUIRED_FLAG in VARCHAR2
,P_HTML_TEXT in VARCHAR2
,P_SQL_TEXT in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_QUEST_FIELDS_BK2.UPDATE_QUEST_FIELDS_A', 10);
hr_utility.set_location(' Leaving: HR_QUEST_FIELDS_BK2.UPDATE_QUEST_FIELDS_A', 20);
end UPDATE_QUEST_FIELDS_A;
procedure UPDATE_QUEST_FIELDS_B
(P_EFFECTIVE_DATE in DATE
,P_FIELD_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_QUESTIONNAIRE_TEMPLATE_ID in NUMBER
,P_NAME in VARCHAR2
,P_TYPE in VARCHAR2
,P_SQL_REQUIRED_FLAG in VARCHAR2
,P_HTML_TEXT in VARCHAR2
,P_SQL_TEXT in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_QUEST_FIELDS_BK2.UPDATE_QUEST_FIELDS_B', 10);
hr_utility.set_location(' Leaving: HR_QUEST_FIELDS_BK2.UPDATE_QUEST_FIELDS_B', 20);
end UPDATE_QUEST_FIELDS_B;
end HR_QUEST_FIELDS_BK2;

/