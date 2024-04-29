--------------------------------------------------------
--  DDL for Package Body PER_PERSON_ANALYSES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERSON_ANALYSES_PKG" as
/* $Header: pepea01t.pkb 115.6 2003/09/03 02:36:29 smparame ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
/*
|
| 07/07/2000 C.Simpson Modified single_info_type to compensate for change in
|                      base view PER_SPECIAL_INFO_TYPES_V where INFO_EXISTS
|                      is no longer populated, in r115 only.  Broken dual
|                      maintenance on this file as a result. #1347225.
|
|
*/
-------------------------------------------------------------------------
-- CHECK_FOR_DUPLICATES
--
--    Looks for duplicate person analyses records for the current person
--    on the same start and end dates
-------------------------------------------------------------------------
--
procedure check_for_duplicates(p_bg_id number
                              ,p_id_flex_num number
                              ,p_analysis_criteria_id number
                              ,p_end_of_time date
                              ,p_date_from date
                              ,p_date_to date
                              ,p_person_id number
                              ,p_rowid varchar2) is
cursor c is
select 'x'
from per_person_analyses pa
,    per_analysis_criteria ac
where pa.analysis_criteria_id = p_analysis_criteria_id
and   pa.business_group_id + 0 = p_bg_id
and   pa.analysis_criteria_id = ac.analysis_criteria_id
and   ac.id_flex_num = p_id_flex_num
and   nvl(pa.date_to,p_end_of_time) =
      nvl(p_date_to,p_end_of_time)
and   pa.date_from = p_date_from
and   pa.person_id = p_person_id
and  (p_rowid is null or
     (p_rowid is not null and
      pa.rowid <> chartorowid(p_rowid)));
--
l_exists varchar2(1);
begin
hr_utility.set_location('per_person_analyses_pkg.check_for_duplicates',1);
   open c;
   fetch c into l_exists;
   if c%found then
      close c;
      hr_utility.set_message(801,'HR_6012_ROW_INSERTED');
      hr_utility.raise_error;
   end if;
   close c;
end check_for_duplicates;
--
-------------------------------------------------------------------------
-- GET_UNIQUE_ID
--
--    Returns next unique ID for Person Analyses
-------------------------------------------------------------------------
--
function get_unique_id return number is
l_id number;
cursor c is
select per_person_analyses_s.nextval
from sys.dual;
--
begin
   open c;
   fetch c into l_id;
   close c;
   return(l_id);
end get_unique_id;
--
-------------------------------------------------------------------------
-- SINGLE_INFO_TYPE
--
--   Determines whether the Customization specifies that only one
--   INFO_TYPE should be displayed.
--
-------------------------------------------------------------------------
--
procedure single_info_type(p_bg_id number
                          ,p_person_id number
                          ,p_customized_restriction_id number
                          ,p_count_info_type IN OUT NOCOPY number  ) is
                         -- ,p_info_exist IN OUT varchar2
                         -- ,p_id_flex_num IN OUT number) is
--
begin
--
   select count(customized_restriction_id)
   into   p_count_info_type
   from   pay_restriction_values
   where  restriction_code = 'INFO_TYPE'
   and    customized_restriction_id = p_customized_restriction_id;
--
end single_info_type;
--
------------------------------------------------------------------------
--
-- UNIQUE CASE NUMBER
--
-- determines if the Case Number specified for an OSHA person analysis
-- record is unique within the business group
--
procedure unique_case_number (p_business_group_id in number,
                              p_legislation_code  in varchar2,
                              p_id_flex_num       in number,
                              p_segment1          in varchar2) is
--
  -- cursor to check if the special information being entered is OSHA
  --
  cursor c_osha is
    select 'X'
    from pay_legislation_rules
    where legislation_code = p_legislation_code
      and rule_type = 'OSHA'
      and rule_mode = to_char(p_id_flex_num);
--
  cursor c_duplicate_case is
    select 'X'
    from per_person_analyses pa,
         per_analysis_criteria ac
    where pa.business_group_id + 0 = p_business_group_id
      and pa.analysis_criteria_id = ac.analysis_criteria_id
      and ac.id_flex_num = p_id_flex_num
      and ac.segment1 = p_segment1;
--
  l_dummy varchar2(1);
--
begin
--
  open c_osha;
  fetch c_osha into l_dummy;
  if c_osha%FOUND then
  --
    close c_osha;
    --
    open c_duplicate_case;
    fetch c_duplicate_case into l_dummy;
    if c_duplicate_case%FOUND then
    --
      close c_duplicate_case;
      --
      hr_utility.set_message(801,'HR_7443_PA_UNIQUE_CASE_NUMBER');
      hr_utility.raise_error;
      --
    --
    end if;
    --
    close c_duplicate_case;
  --
  else
    --
    close c_osha;
    --
  end if;
--
end;

--
------------------------------------------------------------------------
--
-- POPULATE_INFO_EXISTS
--
-- function accepts flex structure id, person_id, and business group and
-- returns 'Y' if a per_person_analyses record exists.
--
FUNCTION populate_info_exists
  ( p_id_flex_num   in per_person_analyses.id_flex_num%TYPE
  , p_person_id     in per_person_analyses.person_id%TYPE
  , p_business_group_id in per_person_analyses.business_group_id%TYPE
  ) RETURN VARCHAR2 IS
--
 -- Bug fix 2863766
 -- where clause to check the id_flex_num in per_analysis_criteria table
 -- added to the cursor c_ppa.
 cursor c_ppa is
  select 'Y'
  from per_person_analyses ppa,per_analysis_criteria pac
  where ppa.id_flex_num = p_id_flex_num
  and ppa.person_id = p_person_id
  and ppa.business_group_id = p_business_group_id
  and pac.analysis_criteria_id = ppa.analysis_criteria_id
  and pac.id_flex_num = ppa.id_flex_num;
--
l_return varchar2(1) := 'N';
--
BEGIN
--
  open c_ppa;
  fetch c_ppa into l_return;
  close c_ppa;

  return l_return;

END populate_info_exists;
--
END PER_PERSON_ANALYSES_PKG;

/
