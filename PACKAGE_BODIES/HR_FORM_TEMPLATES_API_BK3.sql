--------------------------------------------------------
--  DDL for Package Body HR_FORM_TEMPLATES_API_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_TEMPLATES_API_BK3" as
/* $Header: hrtmpapi.pkb 120.0 2005/05/31 03:20:53 generated noship $ */
-- Code generated by the Oracle HRMS API Hook Pre-processor
-- Created on 2007/01/04 09:31:24 (YYYY/MM/DD HH24:MI:SS)
procedure DELETE_TEMPLATE_A
(P_FORM_TEMPLATE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DELETE_CHILDREN_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_FORM_TEMPLATES_API_BK3.DELETE_TEMPLATE_A', 10);
hr_utility.set_location(' Leaving: HR_FORM_TEMPLATES_API_BK3.DELETE_TEMPLATE_A', 20);
end DELETE_TEMPLATE_A;
procedure DELETE_TEMPLATE_B
(P_FORM_TEMPLATE_ID in NUMBER
,P_OBJECT_VERSION_NUMBER in NUMBER
,P_DELETE_CHILDREN_FLAG in VARCHAR2
)is
begin
hr_utility.set_location('Entering: HR_FORM_TEMPLATES_API_BK3.DELETE_TEMPLATE_B', 10);
hr_utility.set_location(' Leaving: HR_FORM_TEMPLATES_API_BK3.DELETE_TEMPLATE_B', 20);
end DELETE_TEMPLATE_B;
end HR_FORM_TEMPLATES_API_BK3;

/
