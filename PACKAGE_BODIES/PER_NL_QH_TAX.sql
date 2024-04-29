--------------------------------------------------------
--  DDL for Package Body PER_NL_QH_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_NL_QH_TAX" as
/* $Header: penlqhtx.pkb 115.9 2003/02/25 17:01:37 pgdavies noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_nl_qh_tax.';
--
procedure update_nl_tax_data
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
) is
  l_proc varchar2(72) := g_package||'update_nl_tax_data';
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_legislation_code='NL' then
    --
         update per_all_people_f
	 set per_information1 = p_rec.tax_field1
	    ,per_information2 = p_rec.tax_field25
	    ,per_information3 = p_rec.tax_field26
	    ,per_information4 = p_rec.tax_field27
	    ,per_information5 = p_rec.tax_field23
	    ,per_information6 = p_rec.tax_field24
	    ,per_information7 = p_rec.tax_field28
	    ,per_information8 = p_rec.tax_field20
	    ,per_information10 = p_rec.tax_field29
	    ,per_information11 = p_rec.tax_field30
	    ,per_information12 = p_rec.tax_field31
	    ,first_name = p_rec.tax_field22
	    ,middle_names = p_rec.tax_field7
         where person_id = p_person_id
         and   p_effective_date between effective_start_date and effective_end_date;
         if p_rec.tax_field21 is null then
           update per_all_people_f
	   set country_of_birth = null
           where person_id = p_person_id
           and   p_effective_date between effective_start_date and effective_end_date;
         end if;
  End if;
--
  hr_utility.set_location('Leaving:'|| l_proc, 1000);
--
end update_nl_tax_data;
--
--

procedure nl_tax_query
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
) is
  l_proc varchar2(72) := g_package||'nl_tax_query';

  Function nl_mand_lookup_meanings(p_lookup_type in varchar2, p_lookup_code in varchar2) return varchar2 is
     l_lookup_meaning hr_lookups.meaning%type;
     begin
       select meaning
       into   l_lookup_meaning
       from   hr_lookups
       where  lookup_type = p_lookup_type
       and    lookup_code = p_lookup_code;
       return l_lookup_meaning;
     exception
       when no_data_found then
         fnd_message.set_name('PER','HR_NL_EMP_INVALID_LOOKUP');
         fnd_message.set_token('LOOKUP',p_lookup_type);
         fnd_message.raise_error;
         return l_lookup_meaning;
     end;

  Function nl_lookup_meanings(p_lookup_type in varchar2, p_lookup_code in varchar2) return varchar2 is
     l_lookup_meaning hr_lookups.meaning%type;
     begin
       select meaning
       into   l_lookup_meaning
       from   hr_lookups
       where  lookup_type = p_lookup_type
       and    lookup_code = p_lookup_code;
       return l_lookup_meaning;
     exception
       when no_data_found then
         return null;
     end;

  Function nl_get_territory(p_territory_code in varchar2) return varchar2 is
     l_territory_name   fnd_territories_vl.territory_short_name%type;
     begin
       select territory_short_name
       into   l_territory_name
       from   fnd_territories_vl
       where  territory_code = p_territory_code;
       return l_territory_name;
     exception
       when no_data_found then
         return null;
     end;

--
begin
--
  if p_legislation_code='NL' then
    hr_utility.set_location('Entering:'|| l_proc, 10);

    Begin
     select per_information1
           ,per_information2
           ,per_information3
           ,per_information4
           ,per_information5
           ,per_information6
           ,per_information7
           ,per_information8
           ,per_information10
           ,per_information11
           ,per_information12
           ,middle_names
           ,country_of_birth
           ,first_name
           ,full_name
     into   p_rec.tax_field1
           ,p_rec.tax_field25
           ,p_rec.tax_field26
           ,p_rec.tax_field27
           ,p_rec.tax_field23
           ,p_rec.tax_field24
           ,p_rec.tax_field28
           ,p_rec.tax_field20
           ,p_rec.tax_field29
           ,p_rec.tax_field30
           ,p_rec.tax_field31
           ,p_rec.tax_field7
           ,p_rec.tax_field32
           ,p_rec.tax_field22
           ,p_rec.tax_field5
     from   per_all_people_f
     where  person_id = p_person_id
     and    p_effective_date between effective_start_date and effective_end_date
     and    rownum = 1;
    Exception
      when no_data_found then
        null;
    End;
    p_rec.tax_field10 := nl_lookup_meanings('HR_NL_SPECIAL_TITLE',p_rec.tax_field25);
    p_rec.tax_field8 := nl_lookup_meanings('HR_NL_SUB_ACADEMIC_TITLE',p_rec.tax_field26);
    p_rec.tax_field4 := nl_lookup_meanings('HR_NL_FULL_NAME_FORMAT',p_rec.tax_field27);
    p_rec.tax_field15 := nl_lookup_meanings('HR_NL_Y_N',p_rec.tax_field28);
    p_rec.tax_field6 := nl_lookup_meanings('HR_NL_ACADEMIC_TITLE',p_rec.tax_field29);
    p_rec.tax_field16 := nl_get_territory(p_rec.tax_field30);
    p_rec.tax_field12 := nl_get_territory(p_rec.tax_field31);

    Begin
     select territory_short_name into p_rec.tax_field21
     from   fnd_territories_vl
     where  territory_code = p_rec.tax_field32;
    Exception
      when no_data_found then
        null;
    End;

  end if;
--
  hr_utility.set_location('Leaving:'|| l_proc, 1000);
--
end nl_tax_query;

end per_nl_qh_tax;

/
