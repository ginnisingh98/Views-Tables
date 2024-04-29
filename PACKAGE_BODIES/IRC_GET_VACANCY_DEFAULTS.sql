--------------------------------------------------------
--  DDL for Package Body IRC_GET_VACANCY_DEFAULTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_GET_VACANCY_DEFAULTS" as
/* $Header: irvacdft.pkb 120.2 2005/08/09 04:10:10 cnholmes noship $ */
--
-- ----------------------------------------------------------------------------
-- |                                                                          |
-- | IRC_GET_VACANCY_DEFAULTS package gives us access to the configurable     |
-- | defaults. We can then set the currentRow attributes to these values:     |
-- |                                                                          |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  IRC_GET_VACANCY_DEFAULTS.';  -- Global package name
g_defaults g_rec_type;
--
--
Procedure populate_defaults_rec
 (
     p_organization_id      in  varchar2
    ,p_level                in  varchar2
) is
BEGIN
--
hr_utility.trace('Entering populate_defaults_rec');
--
  g_defaults.ORG_INFORMATION1  := '';
  g_defaults.ORG_INFORMATION2  := '';
  g_defaults.ORG_INFORMATION3  := '';
  g_defaults.ORG_INFORMATION4  := '';
  g_defaults.ORG_INFORMATION5  := '';
  g_defaults.ORG_INFORMATION6  := '';
  g_defaults.ORG_INFORMATION7  := '';
  g_defaults.ORG_INFORMATION8  := '';
  g_defaults.ORG_INFORMATION9  := '';
  g_defaults.ORG_INFORMATION10 := '';
  g_defaults.ORG_INFORMATION11 := '';
  g_defaults.ORG_INFORMATION12 := '';
  g_defaults.ORG_INFORMATION13 := '';
  g_defaults.ORG_INFORMATION14 := '';
  g_defaults.ORG_INFORMATION15 := '';
  g_defaults.ORG_INFORMATION16 := '';
  g_defaults.ORG_INFORMATION17 := '';
  g_defaults.ORG_INFORMATION18 := '';
  g_defaults.ORG_INFORMATION19 := '';
  g_defaults.ORG_INFORMATION20 := '';
--
 SELECT
       ORG_INFORMATION1
      ,ORG_INFORMATION2
      ,ORG_INFORMATION3
      ,ORG_INFORMATION4
      ,ORG_INFORMATION5
      ,ORG_INFORMATION6
      ,ORG_INFORMATION7
      ,ORG_INFORMATION8
      ,ORG_INFORMATION9
      ,ORG_INFORMATION10
      ,ORG_INFORMATION11
      ,ORG_INFORMATION12
      ,ORG_INFORMATION13
      ,ORG_INFORMATION14
      ,ORG_INFORMATION15
      ,ORG_INFORMATION16
      ,ORG_INFORMATION17
      ,ORG_INFORMATION18
      ,ORG_INFORMATION19
      ,ORG_INFORMATION20
  INTO
       g_defaults.ORG_INFORMATION1
      ,g_defaults.ORG_INFORMATION2
      ,g_defaults.ORG_INFORMATION3
      ,g_defaults.ORG_INFORMATION4
      ,g_defaults.ORG_INFORMATION5
      ,g_defaults.ORG_INFORMATION6
      ,g_defaults.ORG_INFORMATION7
      ,g_defaults.ORG_INFORMATION8
      ,g_defaults.ORG_INFORMATION9
      ,g_defaults.ORG_INFORMATION10
      ,g_defaults.ORG_INFORMATION11
      ,g_defaults.ORG_INFORMATION12
      ,g_defaults.ORG_INFORMATION13
      ,g_defaults.ORG_INFORMATION14
      ,g_defaults.ORG_INFORMATION15
      ,g_defaults.ORG_INFORMATION16
      ,g_defaults.ORG_INFORMATION17
      ,g_defaults.ORG_INFORMATION18
      ,g_defaults.ORG_INFORMATION19
      ,g_defaults.ORG_INFORMATION20
  FROM HR_ORGANIZATION_INFORMATION
 WHERE
       ORG_INFORMATION_CONTEXT = p_level
   AND
       ORGANIZATION_ID         = p_organization_id;
--
hr_utility.trace('Exiting populate_defaults_rec');
--
EXCEPTION
WHEN OTHERS THEN
--
hr_utility.trace('Error occured in populate_defaults_rec');
--
return;
--
end populate_defaults_rec;
--
Procedure get_BG_defaults
 (   p_business_group_id       in  number
    ,p_currency                out nocopy varchar2
    ,p_vacancy_name_is_auto    out nocopy varchar2
    ,p_budget_measurement_type out nocopy varchar2
    ,p_number_of_openings      out nocopy number
    ,p_location_default        out nocopy varchar2
    ,p_organization_default        out nocopy varchar2
 ) is
--
begin
--
hr_utility.trace('Entering get_BG_defaults with business_group_id :'
              || to_char(p_business_group_id) || ':');
--
    populate_defaults_rec
    (p_organization_id     => p_business_group_id
    ,p_level               => 'BG Recruitment');
--
hr_utility.trace('defaults record populated');
--
    p_currency                 :=
      get_currency(p_organization_id => p_business_group_id);
--
hr_utility.trace('p_currency is :' || p_currency || ':');
--
    p_vacancy_name_is_auto     := get_vacancy_name_is_auto;
--
hr_utility.trace('p_vacancy_name_is_auto is :' || p_vacancy_name_is_auto || ':');
--
    p_budget_measurement_type  := get_budget_measurement_type;
--
hr_utility.trace('p_budget_measurement_type is :' || p_budget_measurement_type || ':');
--
    p_number_of_openings       := get_number_of_openings;
--
hr_utility.trace('p_number_of_openings is :' || to_char(p_number_of_openings) || ':');
--
    p_location_default         := get_location_default;
--
hr_utility.trace('p_location_default is :' || p_location_default || ':');
--
    p_organization_default     := get_organization_default;
--
hr_utility.trace('p_organization_default is :' || p_organization_default || ':');
--
hr_utility.trace('Exiting get_BG_defaults');
--
end get_BG_defaults;
--
Function get_currency (p_organization_id in varchar)
return varchar2 is
--
l_currency varchar2(250);
--
begin
--
hr_utility.trace('Entering get_currency');
--
 SELECT ORG_INFORMATION10
   INTO l_currency
   FROM HR_ORGANIZATION_INFORMATION
  WHERE
        ORG_INFORMATION_CONTEXT = 'Business Group Information'
    AND
        ORGANIZATION_ID         = p_organization_id;
--
hr_utility.trace('Exiting get_currency returning :' || l_currency || ':');
--
  return l_currency;
--
end get_currency;
--
Function get_vacancy_name_is_auto return varchar2 is
--
begin
--
hr_utility.trace('Entering get_vacancy_name');
--
  if (g_defaults.ORG_INFORMATION1 is null) then
--
hr_utility.trace('Exiting get_vacancy_name null found so returning N');
--
    return 'N';
  end if;
--
  if (g_defaults.ORG_INFORMATION1 = 'ID') then
--
hr_utility.trace('Exiting get_vacancy_name ID found so returning Y');
--
    return 'Y';
  end if;
--
hr_utility.trace('Exiting get_vacancy_name wiht default value N');
--
  return 'N';
--
end get_vacancy_name_is_auto;
--
Function get_number_of_openings return number is
begin
--
hr_utility.trace('Executing get_number_of_openings');
--
  return nvl(fnd_number.canonical_to_number(g_defaults.ORG_INFORMATION3), 1);
--
end get_number_of_openings;
--
Function get_budget_measurement_type return varchar2 is
begin
--
hr_utility.trace('Executing get_budget_measurement_type');
--
  return nvl(g_defaults.ORG_INFORMATION6, 'FTE');
--
end get_budget_measurement_type;
--
Function get_organization_default return varchar2 is
begin
--
hr_utility.trace('Executing get_organization_default');
--
  return nvl(g_defaults.ORG_INFORMATION4, 'MANAGER');
--
end get_organization_default;
--
Function get_location_default return varchar2 is
begin
--
hr_utility.trace('Executing get_location_default');
--
  return nvl(g_defaults.ORG_INFORMATION5, 'MANAGER');
--
end get_location_default;
--
end IRC_GET_VACANCY_DEFAULTS;

/
