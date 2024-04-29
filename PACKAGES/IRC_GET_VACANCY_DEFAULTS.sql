--------------------------------------------------------
--  DDL for Package IRC_GET_VACANCY_DEFAULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_GET_VACANCY_DEFAULTS" AUTHID CURRENT_USER as
/* $Header: irvacdft.pkh 120.0 2005/07/26 15:19:01 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                    Global Record Type Specification                      |
-- ----------------------------------------------------------------------------
--
Type g_rec_type Is Record
 (ORG_INFORMATION_ID                NUMBER
 ,ORG_INFORMATION_CONTEXT           VARCHAR2(40)
 ,ORGANIZATION_ID                   NUMBER(15)
 ,ORG_INFORMATION1                  VARCHAR2(150)
 ,ORG_INFORMATION2                  VARCHAR2(150)
 ,ORG_INFORMATION3                  VARCHAR2(150)
 ,ORG_INFORMATION4                  VARCHAR2(150)
 ,ORG_INFORMATION5                  VARCHAR2(150)
 ,ORG_INFORMATION6                  VARCHAR2(150)
 ,ORG_INFORMATION7                  VARCHAR2(150)
 ,ORG_INFORMATION8                  VARCHAR2(150)
 ,ORG_INFORMATION9                  VARCHAR2(150)
 ,ORG_INFORMATION10                 VARCHAR2(150)
 ,ORG_INFORMATION11                 VARCHAR2(150)
 ,ORG_INFORMATION12                 VARCHAR2(150)
 ,ORG_INFORMATION13                 VARCHAR2(150)
 ,ORG_INFORMATION14                 VARCHAR2(150)
 ,ORG_INFORMATION15                 VARCHAR2(150)
 ,ORG_INFORMATION16                 VARCHAR2(150)
 ,ORG_INFORMATION17                 VARCHAR2(150)
 ,ORG_INFORMATION18                 VARCHAR2(150)
 ,ORG_INFORMATION19                 VARCHAR2(150)
 ,ORG_INFORMATION20                 VARCHAR2(150)
);
--
Procedure populate_defaults_rec
 (   p_organization_id      in  varchar2
    ,p_level                in  varchar2
);
--
Procedure get_BG_defaults
 (   p_business_group_id       in  number
    ,p_currency                out nocopy varchar2
    ,p_vacancy_name_is_auto    out nocopy varchar2
    ,p_budget_measurement_type out nocopy varchar2
    ,p_number_of_openings      out nocopy number
    ,p_location_default        out nocopy varchar2
    ,p_organization_default        out nocopy varchar2
 );
--
Function get_currency (p_organization_id in varchar) return varchar2;
--
Function get_vacancy_name_is_auto return varchar2;
--
Function get_number_of_openings return number;
--
Function get_budget_measurement_type return varchar2;
--
Function get_organization_default return varchar2;
--
Function get_location_default return varchar2;
--
end IRC_GET_VACANCY_DEFAULTS;

 

/
