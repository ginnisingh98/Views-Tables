--------------------------------------------------------
--  DDL for Package Body PAY_ES_NIE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_NIE_UPDATE" as
/* $Header: peesnieu.pkb 120.0.12010000.1 2008/10/14 04:32:04 parusia noship $ */
PROCEDURE qualify_nie_update(
            p_person_id number
          , p_qualifier	out nocopy varchar2) AS

cursor get_NIE_value is
   select per_information2 identifier_type,
          per_information3 identifier_value
   from   hr_organization_information org, per_all_people_f p
   where p.person_id = p_person_id
    and  org.organization_id = p.business_group_id
    and org.org_information_context = 'Business Group Information'
    and org.org_information9 = 'ES';

l_identifier_type varchar2(150);
l_identifier_value varchar2(150);
v_nie_return varchar2(10);

BEGIN
     p_qualifier := 'N';
     for person_rec in get_NIE_value
     loop
        l_identifier_type := person_rec.identifier_type;
        l_identifier_value := person_rec.identifier_value;

        if l_identifier_type = 'NIE' and l_identifier_value is not null then
            v_nie_return :=
hr_ni_chk_pkg.chk_nat_id_format(substr(l_identifier_value,1,30),'ADDDDDDDA');
            if (v_nie_return='0') then
                   p_qualifier := 'N';
            else
                   p_qualifier := 'Y';
                   return ;
            end if;
         end if ;
     end loop ;

END qualify_nie_update;

-------------

PROCEDURE update_NIE(p_person_id number) IS
cursor get_NIE_value is
   select per_information2 identifier_type,
          per_information3 identifier_value,
          effective_start_date, effective_end_date
   from per_all_people_f
   where person_id = p_person_id ;

CURSOR get_legislation_code IS
  select org_information9
  from   hr_organization_information org, per_all_people_f p
  where  org.org_information_context = 'Business Group Information'
    and  org.organization_id = p.business_group_id
    and  p.person_id = p_person_id ;

l_identifier_value varchar2(150);
l_updated_NIE varchar2(150);
v_nie_return varchar2(10);
l_qualifier varchar2(1) ;
l_leg_code varchar2(10);
BEGIN
   open get_legislation_code ;
   fetch get_legislation_code into l_leg_code;
   close get_legislation_code ;

   if l_leg_code = 'ES' then
   for NIE_rec in  get_NIE_value
   loop
       l_identifier_value := NIE_rec.identifier_value;
       if NIE_rec.identifier_type = 'NIE' and l_identifier_value is not null
then
           v_nie_return :=
hr_ni_chk_pkg.chk_nat_id_format(substr(l_identifier_value,1,30),'ADDDDDDDA');
           if (v_nie_return='0') THEN
              l_qualifier := 'N';
           else
              l_qualifier := 'Y';
           end if ;

        if l_qualifier = 'Y' then
            l_updated_NIE := substr(l_identifier_value,1,1)
                          || '0'
                          || substr(l_identifier_value,2);
            update per_all_people_f
            set per_information3 = l_updated_NIE
            where person_id = p_person_id
              and effective_start_date = NIE_rec.effective_start_date
              and effective_end_date = NIE_rec.effective_end_date ;
        end if ;
   end if ;
   end loop ;
   end if ;
END update_NIE;

END pay_es_nie_update ;

/
