--------------------------------------------------------
--  DDL for Package Body PQH_NR_ALIEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_NR_ALIEN_PKG" as
/* $Header: pqhnrinf.pkb 115.1 2002/04/23 13:15:10 pkm ship        $ */

function get_count_nr_alien( p_person_id number ,p_report_date date)
return varchar2
is

  cursor c1(cp_person_id number, cp_report_date date)
  is

   select 1 from per_people_extra_info pei
   where pei.information_type = 'PER_US_VISA_DETAILS'
   and pei.person_id = cp_person_id
   and fnd_date.date_to_canonical(cp_report_date)between pei_information7 and pei_information8
   and pei_information9 in ('04','05','06','07','12');

   l_count_nra varchar2(10);

begin

   open c1(p_person_id, p_report_date);

   fetch c1 into l_count_nra;

   close c1;

   return l_count_nra;
end;

end;

/
