--------------------------------------------------------
--  DDL for Package Body PER_US_VETS_100A_CONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_VETS_100A_CONS_PKG" as
/* $Header: pervetsc100a.pkb 120.0.12010000.16 2009/10/30 08:27:39 emunisek noship $ */

function check_recent_or_not(l_person_id IN per_all_people_f.person_id%TYPE,
                             l_report_end_date IN date)
return number
is
l_count number;
begin
select count(person_id) into l_count
         from PER_PEOPLE_EXTRA_INFO  ppei where
         l_person_id = ppei.person_id
         and ppei.information_type ='VETS 100A'
         and pei_information1 is not null
         and
    ( months_between(l_report_end_date,add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),0)) between 0 and 12
     or
     months_between(l_report_end_date,add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),12)) between 0 and 12
     or
     months_between(l_report_end_date,add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),24)) between 0 and 12
     or
     months_between(l_report_end_date,(add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),36)-2)) between 0 and 12
     );
return l_count;
exception
when others then
return 0;
end;

procedure GET_VETS100A_DATA (
           errbuf                       out nocopy varchar2,
           retcode                      out nocopy number,
           p_business_group_id          in  number,
           p_hierarchy_id               in  number,
           p_hierarchy_version_id       in  number,
           p_date_start                 in  varchar2,
           p_date_end                   in  varchar2,
           p_state                      in  varchar2,
           p_show_new_hires             in  varchar2,
           p_show_totals                in  varchar2,
           p_audit_report               in  varchar2) is

cursor c_hier_details is
select
    pgh.name, pgv.version_number, pgn.entity_id, pgn.hierarchy_node_id
from
    per_gen_hierarchy pgh,
    per_gen_hierarchy_versions pgv,
    per_gen_hierarchy_nodes pgn
where
    pgh.hierarchy_id         = p_hierarchy_id
and pgh.hierarchy_id         = pgv.hierarchy_id
and pgv.hierarchy_version_id = p_hierarchy_version_id
and pgn.hierarchy_version_id = pgv.hierarchy_version_id
and pgn.node_type = 'PAR';

cursor c_count_est is
select
    count(pghn.hierarchy_node_id)
from
     per_gen_hierarchy_nodes pghn
where
     pghn.hierarchy_version_id = p_hierarchy_version_id
and  pghn.node_type = 'EST';

cursor c_parent(l_parent_org_id  varchar2)is

select
  upper(hoi1.org_information1)   "Reporting Name"
  ,hoi1.org_information2               "Company Number"
  ,hoi1.org_information3               "Type of Rep Org"
  ,upper(rpad(cloc.address_line_1 ||' '|| cloc.address_line_2 ||' '||
         cloc.address_line_3,35))     "Parent Address"
  ,upper(cloc.town_or_city)          "Parent City"
  ,upper(cloc.region_1)                 "Parent County"
  ,upper(cloc.region_2)                 "Parent State"
  ,upper(cloc.postal_code)           "Parent Zip"
  ,hoi2.org_information17  contact_name
  ,substr(hoi2.org_information18,1,20)  contact_telnum
  ,hoi2.org_information20 contact_email
  ,substr(hoi2.org_information18,1,20) || ' ' ||hoi2.org_information20   contact_telnum_and_email
from
  hr_organization_information      hoi1
 ,hr_locations_all                          cloc
 ,hr_organization_units                hou
 ,hr_organization_information      hoi2
where
    hoi1.organization_id                      = l_parent_org_id
and hoi1.org_information_context  = 'VETS_Spec'
and hoi1.organization_id                  = hou.organization_id
and hou.location_id = cloc.location_id
and hoi2.organization_id = p_business_group_id
and hoi2.org_information_context = 'EEO_REPORT' ;

cursor c_defaults(l_parent_org_id varchar2) is
    select
      org_information1
     ,org_information2
     ,org_information3
     ,org_information4
     ,org_information5
from
     hr_organization_information
where
   organization_id          =  l_parent_org_id
and org_information_context  = 'VETS_EEO_Dup' ;

cursor c_state(l_parent_node_id  varchar2) is
Select
   distinct(eloc.region_2)       "State"
  from
   hr_location_extra_info         hlei1
  ,hr_location_extra_info         hlei2
  ,per_gen_hierarchy_nodes    pghn
  ,hr_locations_all                   eloc
where
pghn.parent_hierarchy_node_id = l_parent_node_id
and pghn.node_type = 'EST'
and eloc.location_id = pghn.entity_id
and hlei1.location_id = pghn.entity_id
and hlei1.location_id = hlei2.location_id
and hlei1.information_type = 'VETS-100 Specific Information'
and hlei1.lei_information_category= 'VETS-100 Specific Information'
and hlei2.information_type = 'Establishment Information'
and hlei2.lei_information_category= 'Establishment Information'
and hlei2.lei_information10 = 'N'
and eloc.region_2 = nvl(P_STATE,eloc.region_2);

cursor c_job_categories is
SELECT
decode(lookup_code,1,2,2,3,3,4,4,5,5,6,6,7
                   ,7,8,8,9,9,10,10,1) diplay_order,
lookup_code,
upper(rpad(meaning,26,'.'))||lookup_code cons_job_category_name,
lookup_code cons_job_category_code,
decode(lookup_code,'8','LABORERS/HELPERS'
                  ,upper(meaning)) job_category_name
FROM    hr_lookups
WHERE   lookup_type = 'US_EEO1_JOB_CATEGORIES'
ORDER BY diplay_order ;

cursor c_est_entity(p_state in varchar2) is
   select
      pghn1.entity_id
     ,pghn1.hierarchy_node_id
   from
      per_gen_hierarchy_nodes    pghn1
     ,hr_location_extra_info     hlei1
     ,hr_location_extra_info     hlei2
     ,hr_locations_all           eloc
   where
       pghn1.hierarchy_version_id = P_HIERARCHY_VERSION_ID
   and pghn1.node_type = 'EST'
   and eloc.location_id = pghn1.entity_id
   and hlei1.location_id = pghn1.entity_id
   and hlei1.location_id = hlei2.location_id
   and hlei1.information_type = 'VETS-100 Specific Information'
   and hlei1.lei_information_category= 'VETS-100 Specific Information'
   and hlei2.information_type = 'Establishment Information'
   and hlei2.lei_information_category= 'Establishment Information'
   and hlei2.lei_information10 = 'N'
   and eloc.region_2 = p_state;

cursor c_tot_emps(l_est_node_id in varchar2,l_month_end_date in date) is
     select count(distinct asg.person_id)
     from
       per_all_assignments_f               asg
      ,per_gen_hierarchy_nodes pgn
      ,per_periods_of_service pps --8667924
     where
     asg.business_group_id  =  P_BUSINESS_GROUP_ID
     and asg.person_id = pps.person_id
     and asg.business_group_id = pps.business_group_id
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and asg.effective_start_date = (select max(paf2.effective_start_date)
                                     from   per_all_assignments_f paf2
                                     where  paf2.person_id = asg.person_id
                                     and    paf2.primary_flag = 'Y'
                                     and    paf2.assignment_type = 'E'
                                     and    paf2.effective_start_date
                                            <=  l_month_end_date)
     AND
     (EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE  TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    asg.employment_category        = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories'
              AND    hoi1.organization_id  =  hoi2.organization_id
              )
        OR /*8667924*/
      months_between(l_month_end_date,pps.actual_termination_date) between 0 and 12 )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC');


--Variable Declaration
l_business_group_name varchar2(240); --Increased variable size for Bug#9038285
lc_state varchar2(3);

l_est_no number;
l_hierarchy_name per_gen_hierarchy.name%type;
l_hierarchy_version_num per_gen_hierarchy_versions.VERSION_NUMBER%type;
l_parent_org_id varchar2(20);
l_parent_node_id varchar2(20);

l_reporting_name hr_organization_information.org_information1%type;
l_company_number hr_organization_information.org_information2%type;
l_type_of_rep_org hr_organization_information.org_information3%type;
l_parent_address long;
l_parent_city  hr_locations_all.town_or_city%type;
l_parent_county  hr_locations_all.region_1%type;
l_parent_state  hr_locations_all.region_2%type;
l_parent_zip hr_locations_all.postal_code%type;
l_contact_name hr_organization_information.org_information17%type;
l_contact_telnum hr_organization_information.org_information18%type;
l_contact_email hr_organization_information.org_information20%type;
l_contact_telnum_and_email hr_organization_information.org_information20%type;

l_state hr_locations_all.region_2%type;
l_state_meaning varchar2(20);

l_def_sic varchar2(20);
l_def_naics varchar2(20);
l_def_gre varchar2(20);
l_def_duns varchar2(20);
l_def_gov_con varchar2(20);

l_display_order varchar2(2);
l_job_code varchar2(2);
l_cons_job_category_name  varchar2(50);
l_cons_job_category_code  varchar2(50);
l_job_category_name  varchar2(50);

cp_prime_contractor varchar2(10);
cp_sub_contractor varchar2(10);

CS_NO_DIS_VETS number :=0;
CS_NO_OTHER_VETS number :=0;
CS_NO_ARMED_VETS number :=0;
CS_NO_RECSEP_VETS number:=0;
CS_NO_TOT_VETS number:=0;
CS_NH_DIS_VETS number :=0;
CS_NH_OTHER_VETS number :=0;
CS_NH_ARMED_VETS number :=0;
CS_NH_RECSEP_VETS number:=0;
CS_NH_TOT_VETS number :=0;

CP_MSC number;

l_xml_string clob :='';
P_DATE_END1 varchar2(10);

l_buffer varchar2(200);
g_delimiter varchar2(10) := ',' ;
g_eol varchar2(1) := fnd_global.local_chr(10);

function count_locsFormula(state in varchar2 , p_parent_node_id varchar2) return Number is

no_ests number := 0;
est_id  number;
no_tot_emps number := 0;
ent_id number;
no_loc_emps number;


cursor c_locs(est_id number ) is
select entity_id
from
per_gen_hierarchy_nodes
where
(hierarchy_node_id = est_id
or parent_hierarchy_node_id = est_id)
and hierarchy_version_id = p_hierarchy_version_id;


cursor c_ests is
select
  pghn.hierarchy_node_id
from
   hr_location_extra_info         hlei1
  ,hr_location_extra_info         hlei2
  ,per_gen_hierarchy_nodes        pghn
  ,hr_locations_all               eloc
where
    pghn.hierarchy_version_id = p_hierarchy_version_id
and pghn.parent_hierarchy_node_id = p_parent_node_id
and eloc.location_id = pghn.entity_id
and hlei1.location_id = pghn.entity_id
and hlei1.location_id = hlei2.location_id
and hlei1.information_type = 'VETS-100 Specific Information'
and hlei1.lei_information_category= 'VETS-100 Specific Information'
and hlei2.information_type = 'Establishment Information'
and hlei2.lei_information_category= 'Establishment Information'
and hlei2.lei_information10 = 'N'
and eloc.region_2 = state;

begin
open c_ests;
loop
fetch c_ests into est_id;
exit when c_ests%notfound;

  open c_locs(est_id);
  loop
  fetch c_locs into ent_id;
  exit when c_locs%notfound;

     select count(distinct asg.person_id)
      into no_loc_emps
      from per_all_assignments_f         asg
      , per_periods_of_service pps
     where
       asg.assignment_type = 'E'
       and asg.primary_flag = 'Y'
       and pps.person_id=asg.person_id
       and pps.business_group_id =  asg.business_group_id
       and P_DATE_END1 between asg.effective_start_date and asg.effective_end_date
       and asg.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_all_assignments_f paf2
                                        where paf2.person_id = asg.person_id
                                          and paf2.primary_flag = 'Y'
                                          and paf2.assignment_type = 'E'
                                          and paf2.effective_start_date
                                              <= P_DATE_END1
                                              )
     and asg.business_group_id = P_BUSINESS_GROUP_ID
     AND
     ( EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context    = 'Reporting Statuses'
              AND hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND asg.employment_category         =  hoi2.org_information1
              AND hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context    = 'Reporting Categories'
              AND hoi1.organization_id            =  hoi2.organization_id)
        OR
        months_between(P_DATE_END1,pps.actual_termination_date) between 0 and 12 /*8667924*/

        )
     and asg.location_id = ent_id;

     no_tot_emps := no_tot_emps + no_loc_emps;

   end loop;
   close c_locs;

   if no_tot_emps between 0 and 50 then
     no_ests := no_ests + 1;

   end if;
   no_tot_emps := 0;
   no_loc_emps := 0;
end loop;
close c_ests;

return (no_ests);

end count_locsFormula;

procedure min_max(p_state varchar2)  is

   cursor C_MINMAX_EMPS(l_est_node_id varchar2,l_month_start_date date,l_month_end_date date) is
    select count('asg')
      from per_all_assignments_f         asg
          ,per_gen_hierarchy_nodes pgn
     where asg.assignment_type = 'E'
       and asg.primary_flag = 'Y'
        --9011580
        --AND  l_month_start_date between asg.effective_start_date and asg.effective_end_date
        and  asg.effective_end_date >= l_month_start_date
        AND  l_month_end_date between asg.effective_start_date and asg.effective_end_date
        and asg.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_all_assignments_f paf2
                                        where paf2.person_id = asg.person_id
                                          and paf2.primary_flag = 'Y'
                                          and paf2.assignment_type = 'E'
                                          and paf2.effective_start_date
                                              <= l_month_end_date)
     and asg.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context    = 'Reporting Statuses'
              AND hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND asg.employment_category         = hoi2.org_information1
              AND hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context    = 'Reporting Categories'
              AND hoi1.organization_id            = hoi2.organization_id)
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC');

l_est_entity   number := 0;
l_est_node_id	 number := 0;
l_no_est_emps  number := 0;
l_month_number number :=0;

l_month_start_date date;
l_month_end_date       date := P_DATE_END1;
l_period_end_date      date := P_DATE_END1;

l_emps_this_month_n number:= 0;
l_estab_min_for_year number := 0;
l_state_min_for_year number := 0;

l_emps_this_month_x number:= 0;
l_estab_max_for_year number := 50;
l_state_max_for_year number := 0;

begin

open c_est_entity(p_state);

loop
   fetch c_est_entity into l_est_entity,l_est_node_id;
    exit when c_est_entity%notfound;
      l_emps_this_month_n := 0;
      l_estab_min_for_year := 0;
      l_emps_this_month_x := 0;
      l_estab_max_for_year := 0;

      open c_tot_emps(l_est_node_id,l_month_end_date);
         fetch c_tot_emps into l_no_est_emps;
      close c_tot_emps;

      if l_no_est_emps < 50
      then
        l_emps_this_month_n := 0;
        l_estab_min_for_year := 50;

        for l_month_number in 1 .. 12
         loop

             --9000119
            l_month_start_date := ADD_MONTHS(l_period_end_date,-l_month_number)+1;
            l_month_end_date := ADD_MONTHS(l_month_start_date,1)-1;

            open c_minmax_emps(l_est_node_id,l_month_start_date,l_month_end_date);
               fetch c_minmax_emps into l_emps_this_month_n;

  		        if (l_emps_this_month_n  is null  or l_emps_this_month_n = 0)   then
                     l_emps_this_month_n := 0;
                     l_estab_min_for_year := 0;
              else
		          if l_estab_min_for_year > l_emps_this_month_n  then
		                 l_estab_min_for_year := l_emps_this_month_n;
		          end if;
              end if;

            close c_minmax_emps;

         end loop;

      l_state_min_for_year := l_state_min_for_year + l_estab_min_for_year;

       for l_month_number in 1 .. 12
        loop

            --9000119
            l_month_start_date := ADD_MONTHS(l_period_end_date,-l_month_number)+1;
            l_month_end_date := ADD_MONTHS(l_month_start_date,1)-1;

             open c_minmax_emps(l_est_node_id,l_month_start_date,l_month_end_date);
               fetch c_minmax_emps into l_emps_this_month_x;
               if l_emps_this_month_x > l_estab_max_for_year
               then
                  l_estab_max_for_year := l_emps_this_month_x;
               end if;
            close c_minmax_emps;
         end loop;

     l_state_max_for_year := l_state_max_for_year + l_estab_max_for_year;

   end if;

end loop;
close c_est_entity;

l_xml_string := l_xml_string ||'<LIST_G_6>';
l_xml_string := l_xml_string ||'<G_6>';
l_xml_string := l_xml_string ||convert_into_xml('CP_MIN_EMPS',l_state_min_for_year,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_MAX_EMPS',l_state_max_for_year,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NO_EST_EMPS',l_no_est_emps,'D');
l_xml_string := l_xml_string ||'</G_6>';
l_xml_string := l_xml_string ||'</LIST_G_6>';

end min_max;


procedure vets_data(p_state varchar2,p_job_code varchar2,p_job_category_name varchar2)  is

l_month_end_date date := P_DATE_END1;

cursor c_audit_report_emps(l_est_node_id in varchar2) is

SELECT
 peo.person_id
,peo.last_name
,peo.first_name
,peo.employee_number
,peo.per_information25 veteran
,job.job_information1 job_category
,asg.assignment_id
,decode(peo.per_information25,'NOTVET',' ','VET',' ')||
decode(peo.per_information25,'VETDIS','L','AFSMNSDIS','L','OTEDV','L','AFSMDIS','L','NSDIS','L','AFSMDISOP','L','AFSMNSDISOP','L','NSDISOP','L')||
decode(peo.per_information25,'OTEV','M','OTEDV','M','AFSMDISOP','M','AFSMNSDISOP','M','AFSMOP','M','NSOP','M','AFSMNSOP','M','NSDISOP','M')||
decode(peo.per_information25,'AFSM','N','AFSMNSDIS','N','AFSMDIS','N','AFSMDISOP','N','AFSMNSDISOP','N','AFSMOP','N','AFSMNSOP','N','AFSMNS','N') veteran_category

  from
     per_all_people_f                    peo,
     per_all_assignments_f               asg,
     per_jobs_vl                         job
    ,per_gen_hierarchy_nodes pgn
  where
     peo.person_id = asg.person_id
     and l_month_end_date between peo.effective_start_date and peo.effective_end_date
     and peo.current_employee_flag = 'Y'
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and peo.effective_start_date = (select max(peo2.effective_start_date)
                                       from   per_all_people_f peo2
                                       where  peo2.person_id = peo.person_id
                                        and   peo2.current_employee_flag = 'Y'
                                       and    peo2.effective_start_date <= l_month_end_date )
     and  asg.effective_start_date = (select max(paf2.effective_start_date)
                                       from   per_all_assignments_f paf2
                                       where  paf2.person_id = asg.person_id
                                       and    paf2.primary_flag = 'Y'
                                       and    paf2.assignment_type = 'E'
                                       and    paf2.effective_start_date <= l_month_end_date)
     and  job.job_id = asg.job_id
     and  job.job_information_category = 'US'
     and  l_month_end_date between job.date_from and nvl(job.date_to,l_month_end_date)
     AND  job.job_information1 = p_job_code
     and  asg.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  job.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
              AND asg.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         = hoi2.organization_id
              )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC')


union

SELECT
 peo.person_id
,peo.last_name
,peo.first_name
,peo.employee_number
,peo.per_information25 veteran
,job.job_information1 job_category
,asg.assignment_id
,decode(peo.per_information25,'NS','O','AFSMNSDIS','O','NSDIS','O','AFSMNSDISOP','O', 'NSOP','O','AFSMNSOP','O','AFSMNS','O','NSDISOP','O') veteran_category

  from
     per_all_people_f                    peo,
     per_all_assignments_f               asg,
     per_jobs_vl                         job
    ,per_gen_hierarchy_nodes pgn
  where
     peo.person_id = asg.person_id
     and l_month_end_date between peo.effective_start_date and peo.effective_end_date
     and peo.current_employee_flag = 'Y'
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and peo.effective_start_date = (select max(peo2.effective_start_date)
                                       from   per_all_people_f peo2
                                       where  peo2.person_id = peo.person_id
                                        and   peo2.current_employee_flag = 'Y'
                                       and    peo2.effective_start_date <= l_month_end_date )
     and  asg.effective_start_date = (select max(paf2.effective_start_date)
                                       from   per_all_assignments_f paf2
                                       where  paf2.person_id = asg.person_id
                                       and    paf2.primary_flag = 'Y'
                                       and    paf2.assignment_type = 'E'
                                       and    paf2.effective_start_date <= l_month_end_date)
     and  job.job_id = asg.job_id
     and  job.job_information_category = 'US'
     and  l_month_end_date between job.date_from and nvl(job.date_to,l_month_end_date)
     AND  job.job_information1 = p_job_code
     and  asg.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  job.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
              AND asg.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         = hoi2.organization_id
              )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC')
    and peo.per_information25 in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
     and check_recent_or_not(peo.person_id,l_month_end_date) > 0 ;

 cursor c_audit_report_nh(l_est_node_id in varchar2) is
     SELECT
   peo.person_id
	,peo.last_name
	,peo.first_name
	,peo.employee_number
	,peo.per_information25 veteran
	,job.job_information1 job_category
	,asg.assignment_id
	,decode(peo.per_information25,'NOTVET',' ','VET',' ')||
  decode(peo.per_information25,'VETDIS','Q','AFSMNSDIS','Q','OTEDV','Q','AFSMDIS','Q','NSDIS','Q','AFSMDISOP','Q','AFSMNSDISOP','Q','NSDISOP','Q')||
  decode(peo.per_information25,'OTEV','R','OTEDV','R','AFSMDISOP','R','AFSMNSDISOP','R','AFSMOP','R','NSOP','R','AFSMNSOP','R','NSDISOP','R')||
  decode(peo.per_information25,'AFSM','S','AFSMNSDIS','S','AFSMDIS','S','AFSMDISOP','S','AFSMNSDISOP','S','AFSMOP','S','AFSMNSOP','S','AFSMNS','S') veteran_category

      FROM    per_all_people_f             peo,
              per_all_assignments_f        asg,
              per_jobs_vl                  job,
	      per_gen_hierarchy_nodes      pgn,
              per_periods_of_service       pps
      WHERE   pps.person_id = peo.person_id
      AND     peo.person_id  = asg.person_id
      AND     pps.business_group_id = P_BUSINESS_GROUP_ID
      AND     peo.business_group_id = P_BUSINESS_GROUP_ID
      AND     asg.business_group_id = P_BUSINESS_GROUP_ID
      AND     job.business_group_id = P_BUSINESS_GROUP_ID
      AND     peo.current_employee_flag  = 'Y'
      AND     asg.assignment_type        = 'E'
      AND     asg.primary_flag           = 'Y'
      and     asg.effective_start_date <= l_month_end_date
      AND     asg.effective_start_date = (select max(paf2.effective_start_date)
                                           from per_all_assignments_f paf2
                                           where paf2.person_id = asg.person_id
                                           AND paf2.assignment_id = asg.assignment_id
                                           AND paf2.effective_start_date = peo.effective_start_date
                                           AND paf2.business_group_id = P_BUSINESS_GROUP_ID
                                           AND paf2.primary_flag = 'Y'
                                           AND paf2.assignment_type = 'E'
                                           AND paf2.effective_start_date <= l_month_end_date)
      AND months_between(l_month_end_date,pps.date_start) <= 12
      AND months_between(l_month_end_date,pps.date_start) >= 0
      AND peo.effective_start_date = pps.date_start

      AND EXISTS (
                 SELECT 'X'
                   FROM HR_ORGANIZATION_INFORMATION  HOI1,
                        HR_ORGANIZATION_INFORMATION HOI2
                  WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
                    AND hoi1.org_information_context = 'Reporting Statuses'
                    AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
                    AND asg.employment_category      = hoi2.org_information1
                    AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
                    AND hoi2.org_information_context = 'Reporting Categories'
                    AND hoi1.organization_id         =  hoi2.organization_id)
      AND     asg.job_id  = job.job_id
      AND     job.job_information_category  = 'US'
      AND     l_month_end_date between job.date_from and nvl(job.date_to, l_month_end_date)
      AND  job.job_information1 = p_job_code
      and asg.location_id = pgn.entity_id
      and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
      and pgn.node_type in ('EST','LOC')

union

SELECT
  peo.person_id
	,peo.last_name
	,peo.first_name
	,peo.employee_number
	,peo.per_information25 veteran
	,job.job_information1 job_category
	,asg.assignment_id
	,decode(peo.per_information25,'NS','T','AFSMNSDIS','T','NSDIS','T','AFSMNSDISOP','T', 'NSOP','T','AFSMNSOP','T','AFSMNS','T','NSDISOP','T') veteran_category

      FROM    per_all_people_f             peo,
              per_all_assignments_f        asg,
              per_jobs_vl                  job,
	      per_gen_hierarchy_nodes      pgn,
              per_periods_of_service       pps
      WHERE   pps.person_id = peo.person_id
      AND     peo.person_id  = asg.person_id
      AND     pps.business_group_id = P_BUSINESS_GROUP_ID
      AND     peo.business_group_id = P_BUSINESS_GROUP_ID
      AND     asg.business_group_id = P_BUSINESS_GROUP_ID
      AND     job.business_group_id = P_BUSINESS_GROUP_ID
      AND     peo.current_employee_flag  = 'Y'
      AND     asg.assignment_type        = 'E'
      AND     asg.primary_flag           = 'Y'
      and     asg.effective_start_date <= l_month_end_date
      AND     asg.effective_start_date = (select max(paf2.effective_start_date)
                                           from per_all_assignments_f paf2
                                           where paf2.person_id = asg.person_id
                                           AND paf2.assignment_id = asg.assignment_id
                                           AND paf2.effective_start_date = peo.effective_start_date
                                           AND paf2.business_group_id = P_BUSINESS_GROUP_ID
                                           AND paf2.primary_flag = 'Y'
                                           AND paf2.assignment_type = 'E'
                                           AND paf2.effective_start_date <= l_month_end_date)
      AND months_between(l_month_end_date,pps.date_start) <= 12
      AND months_between(l_month_end_date,pps.date_start) >= 0
      AND peo.effective_start_date = pps.date_start

      AND EXISTS (
                 SELECT 'X'
                   FROM HR_ORGANIZATION_INFORMATION  HOI1,
                        HR_ORGANIZATION_INFORMATION HOI2
                  WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
                    AND hoi1.org_information_context = 'Reporting Statuses'
                    AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
                    AND asg.employment_category      = hoi2.org_information1
                    AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
                    AND hoi2.org_information_context = 'Reporting Categories'
                    AND hoi1.organization_id         =  hoi2.organization_id)
      AND     asg.job_id  = job.job_id
      AND     job.job_information_category  = 'US'
      AND     l_month_end_date between job.date_from and nvl(job.date_to, l_month_end_date)
      AND  job.job_information1 = p_job_code
      and asg.location_id = pgn.entity_id
      and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
      and pgn.node_type in ('EST','LOC')
      and peo.per_information25  in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
      and check_recent_or_not(peo.person_id,l_month_end_date) > 0 ;


cursor c_emps(l_est_node_id in varchar2)  is

select A.loc_no_dis_vets, A.loc_no_other_vets,A.loc_no_armed_vets,B.loc_no_recsep_vets,A.loc_no_not_vets
FROM
(
 SELECT
 count(decode(peo.per_information25,'VETDIS',1,'AFSMNSDIS',1,'OTEDV',1,'AFSMDIS',1,'NSDIS',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'NSDISOP',1,null)) loc_no_dis_vets,
 count(decode(peo.per_information25,'OTEV',1,'OTEDV',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'AFSMOP',1,'NSOP',1,'AFSMNSOP',1,'NSDISOP',1,null)) loc_no_other_vets,
 count(decode(peo.per_information25,'AFSM',1,'AFSMNSDIS',1,'AFSMDIS',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'AFSMOP',1,'AFSMNSOP',1,'AFSMNS',1,null)) loc_no_armed_vets,
 null loc_no_recsep_vets,
 count(decode(peo.per_information25,'NOTVET',1,NULL,1,'VET',1,null)) loc_no_not_vets

  from
     per_all_people_f                    peo,
     per_all_assignments_f               asg,
     per_jobs_vl                         job
    ,per_gen_hierarchy_nodes pgn
  where
     peo.person_id = asg.person_id
     and l_month_end_date between peo.effective_start_date and peo.effective_end_date
     and peo.current_employee_flag = 'Y'
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and peo.effective_start_date = (select max(peo2.effective_start_date)
                                       from   per_all_people_f peo2
                                       where  peo2.person_id = peo.person_id
                                        and   peo2.current_employee_flag = 'Y'
                                       and    peo2.effective_start_date <=  l_month_end_date)
     and  asg.effective_start_date = (select max(paf2.effective_start_date)
                                       from   per_all_assignments_f paf2
                                       where  paf2.person_id = asg.person_id
                                       and    paf2.primary_flag = 'Y'
                                       and    paf2.assignment_type = 'E'
                                       and    paf2.effective_start_date <= l_month_end_date)

     and  job.job_id = asg.job_id
     and  job.job_information_category = 'US'
     and  l_month_end_date between job.date_from and nvl(job.date_to,l_month_end_date)
     AND  job.job_information1 = p_job_code
     and  asg.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  job.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
              AND asg.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         = hoi2.organization_id
              )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
        or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC')) A
,
(SELECT
   null loc_no_dis_vets,
   null loc_no_other_vets,
   null loc_no_armed_vets,
   count(decode(peo.per_information25,'NS',1,'AFSMNSDIS',1,'NSDIS',1,'AFSMNSDISOP',1,'NSOP',1,'AFSMNSOP',1,'AFSMNS',1,'NSDISOP',1,null)) loc_no_recsep_vets,
   null  loc_no_not_vets
  from
     per_all_people_f                    peo,
     per_all_assignments_f               asg,
     per_jobs_vl                         job
    ,per_gen_hierarchy_nodes pgn
  where
     peo.person_id = asg.person_id
     and l_month_end_date between peo.effective_start_date and peo.effective_end_date
     and peo.current_employee_flag = 'Y'
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and peo.effective_start_date = (select max(peo2.effective_start_date)
                                       from   per_all_people_f peo2
                                       where  peo2.person_id = peo.person_id
                                        and   peo2.current_employee_flag = 'Y'
                                       and    peo2.effective_start_date <=  l_month_end_date)
     and  asg.effective_start_date = (select max(paf2.effective_start_date)
                                       from   per_all_assignments_f paf2
                                       where  paf2.person_id = asg.person_id
                                       and    paf2.primary_flag = 'Y'
                                       and    paf2.assignment_type = 'E'
                                       and    paf2.effective_start_date <= l_month_end_date)

     and  job.job_id = asg.job_id
     and  job.job_information_category = 'US'
     and  l_month_end_date between job.date_from and nvl(job.date_to,l_month_end_date)
     AND  job.job_information1 = p_job_code
     and  asg.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  job.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
              AND asg.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         = hoi2.organization_id
              )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
        or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC')
    and peo.per_information25  in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
      and check_recent_or_not(peo.person_id,l_month_end_date) > 0

) B;

cursor c_nh(l_est_node_id in varchar2)  is

select A.loc_nh_dis_vets,A.loc_nh_other_vets, A.loc_nh_armed_vets,B.loc_nh_recsep_vets,A.loc_nh_not_vets
FROM
(
SELECT
 count(decode(peo.per_information25,'VETDIS',1,'AFSMNSDIS',1,'OTEDV',1,'AFSMDIS',1,'NSDIS',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'NSDISOP',1,null)) loc_nh_dis_vets,
 count(decode(peo.per_information25,'OTEV',1,'OTEDV',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'AFSMOP',1,'NSOP',1,'AFSMNSOP',1,'NSDISOP',1,null)) loc_nh_other_vets,
 count(decode(peo.per_information25,'AFSM',1,'AFSMNSDIS',1,'AFSMDIS',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'AFSMOP',1,'AFSMNSOP',1,'AFSMNS',1,null)) loc_nh_armed_vets,
 NULL loc_nh_recsep_vets,
 count(decode(peo.per_information25,'NOTVET',1,NULL,1,'VET',1,null))  loc_nh_not_vets
      FROM    per_all_people_f             peo,
              per_all_assignments_f        asg,
              per_jobs_vl                  job,
              per_gen_hierarchy_nodes      pgn,
              per_periods_of_service       pps
      WHERE   peo.person_id  = asg.person_id
      AND     peo.person_id  = pps.person_id
      AND     peo.business_group_id = P_BUSINESS_GROUP_ID
      AND     asg.business_group_id = P_BUSINESS_GROUP_ID
      AND     job.business_group_id = P_BUSINESS_GROUP_ID
      AND     pps.business_group_id = P_BUSINESS_GROUP_ID
      AND     peo.current_employee_flag  = 'Y'
      AND     asg.assignment_type        = 'E'
      AND     asg.primary_flag           = 'Y'
      and     asg.effective_start_date <= l_month_end_date
      AND     asg.effective_start_date = (select max(paf2.effective_start_date)
                                           from per_all_assignments_f paf2
                                          where paf2.person_id = asg.person_id
                                            and paf2.assignment_id = asg.assignment_id
                                            and paf2.effective_start_date = peo.effective_start_date
                                            and paf2.primary_flag = 'Y'
                                            and paf2.assignment_type = 'E'
                                            and paf2.effective_start_date <= l_month_end_date)
      AND months_between (l_month_end_date,pps.date_start) <= 12
      AND months_between (l_month_end_date,pps.date_start) >= 0
      AND peo.effective_start_date     = pps.date_start
      AND EXISTS (
                 SELECT 'X'
                   FROM HR_ORGANIZATION_INFORMATION  HOI1,
                        HR_ORGANIZATION_INFORMATION HOI2
                  WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
                    AND hoi1.org_information_context = 'Reporting Statuses'
                    AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
                    AND asg.employment_category      = hoi2.org_information1
                    AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
                    AND hoi2.org_information_context = 'Reporting Categories'
                    AND hoi1.organization_id         =  hoi2.organization_id)
      AND     asg.job_id  = job.job_id
      AND     job.job_information_category  = 'US'
      AND     l_month_end_date between job.date_from and nvl(job.date_to, l_month_end_date)
      AND  job.job_information1 = p_job_code
      and asg.location_id = pgn.entity_id
      and (pgn.hierarchy_node_id = l_est_node_id
         or pgn.parent_hierarchy_node_id = l_est_node_id)
      and pgn.node_type in ('EST','LOC')) A
 ,
 (
 SELECT
 NULL loc_nh_dis_vets,
 NULL loc_nh_other_vets,
 NULL loc_nh_armed_vets,
 count(decode(peo.per_information25,'NS',1,'AFSMNSDIS',1,'NSDIS',1,'AFSMNSDISOP',1,'NSOP',1,'AFSMNSOP',1,'AFSMNS',1,'NSDISOP',1,null)) loc_nh_recsep_vets,
 NULL loc_nh_not_vets

      FROM    per_all_people_f             peo,
              per_all_assignments_f        asg,
              per_jobs_vl                  job,
              per_gen_hierarchy_nodes      pgn,
              per_periods_of_service       pps
      WHERE   peo.person_id  = asg.person_id
      AND     peo.person_id  = pps.person_id
      AND     peo.business_group_id = P_BUSINESS_GROUP_ID
      AND     asg.business_group_id = P_BUSINESS_GROUP_ID
      AND     job.business_group_id = P_BUSINESS_GROUP_ID
      AND     pps.business_group_id = P_BUSINESS_GROUP_ID
      AND     peo.current_employee_flag  = 'Y'
      AND     asg.assignment_type        = 'E'
      AND     asg.primary_flag           = 'Y'
      and     asg.effective_start_date <= l_month_end_date
      AND     asg.effective_start_date = (select max(paf2.effective_start_date)
                                           from per_all_assignments_f paf2
                                          where paf2.person_id = asg.person_id
                                            and paf2.assignment_id = asg.assignment_id
                                            and paf2.effective_start_date = peo.effective_start_date
                                            and paf2.primary_flag = 'Y'
                                            and paf2.assignment_type = 'E'
                                            and paf2.effective_start_date <= l_month_end_date)
      AND months_between (l_month_end_date,pps.date_start) <= 12
      AND months_between (l_month_end_date,pps.date_start) >= 0
      AND peo.effective_start_date     = pps.date_start
      AND EXISTS (
                 SELECT 'X'
                   FROM HR_ORGANIZATION_INFORMATION  HOI1,
                        HR_ORGANIZATION_INFORMATION HOI2
                  WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
                    AND hoi1.org_information_context = 'Reporting Statuses'
                    AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
                    AND asg.employment_category      = hoi2.org_information1
                    AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
                    AND hoi2.org_information_context = 'Reporting Categories'
                    AND hoi1.organization_id         =  hoi2.organization_id)
      AND     asg.job_id  = job.job_id
      AND     job.job_information_category  = 'US'
      AND     l_month_end_date between job.date_from and nvl(job.date_to, l_month_end_date)
      AND  job.job_information1 = p_job_code
      and asg.location_id = pgn.entity_id
      and (pgn.hierarchy_node_id = l_est_node_id
         or pgn.parent_hierarchy_node_id = l_est_node_id)
      and pgn.node_type in ('EST','LOC')
      and peo.per_information25  in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
      and check_recent_or_not(peo.person_id,l_month_end_date) > 0
 )B;

 cursor c_nonreported(l_est_node_id in varchar2)  is

    SELECT
 peo.person_id
,peo.last_name
,peo.first_name
,peo.employee_number
,peo.per_information25 veteran
,job.job_information1 job_category
,asg.assignment_id

  from
     per_all_people_f                    peo,
     per_all_assignments_f               asg,
     per_jobs_vl                         job
    ,per_gen_hierarchy_nodes pgn
  where
     peo.person_id = asg.person_id
     and l_month_end_date between peo.effective_start_date and peo.effective_end_date
     and peo.current_employee_flag = 'Y'
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and peo.effective_start_date = (select max(peo2.effective_start_date)
                                       from   per_all_people_f peo2
                                       where  peo2.person_id = peo.person_id
                                        and   peo2.current_employee_flag = 'Y'
                                       and    peo2.effective_start_date <= l_month_end_date )
     and  asg.effective_start_date = (select max(paf2.effective_start_date)
                                       from   per_all_assignments_f paf2
                                       where  paf2.person_id = asg.person_id
                                       and    paf2.primary_flag = 'Y'
                                       and    paf2.assignment_type = 'E'
                                       and    paf2.effective_start_date <= l_month_end_date)
     and  job.job_id = asg.job_id
     and  job.job_information_category = 'US'
     and  l_month_end_date between job.date_from and nvl(job.date_to,l_month_end_date)
     AND  job.job_information1 = p_job_code
     and  asg.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  job.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
              AND asg.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         = hoi2.organization_id
              )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC')
    and peo.per_information25 in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')

MINUS

SELECT
 peo.person_id
,peo.last_name
,peo.first_name
,peo.employee_number
,peo.per_information25 veteran
,job.job_information1 job_category
,asg.assignment_id

  from
     per_all_people_f                    peo,
     per_all_assignments_f               asg,
     per_jobs_vl                         job
    ,per_gen_hierarchy_nodes pgn
  where
     peo.person_id = asg.person_id
     and l_month_end_date between peo.effective_start_date and peo.effective_end_date
     and peo.current_employee_flag = 'Y'
     and asg.assignment_type = 'E'
     and asg.primary_flag = 'Y'
     and l_month_end_date between asg.effective_start_date and asg.effective_end_date
     and peo.effective_start_date = (select max(peo2.effective_start_date)
                                       from   per_all_people_f peo2
                                       where  peo2.person_id = peo.person_id
                                        and   peo2.current_employee_flag = 'Y'
                                       and    peo2.effective_start_date <= l_month_end_date )
     and  asg.effective_start_date = (select max(paf2.effective_start_date)
                                       from   per_all_assignments_f paf2
                                       where  paf2.person_id = asg.person_id
                                       and    paf2.primary_flag = 'Y'
                                       and    paf2.assignment_type = 'E'
                                       and    paf2.effective_start_date <= l_month_end_date)
     and  job.job_id = asg.job_id
     and  job.job_information_category = 'US'
     and  l_month_end_date between job.date_from and nvl(job.date_to,l_month_end_date)
     AND  job.job_information1 = p_job_code
     and  asg.business_group_id = P_BUSINESS_GROUP_ID
     and  peo.business_group_id = P_BUSINESS_GROUP_ID
     and  job.business_group_id = P_BUSINESS_GROUP_ID
     AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = P_BUSINESS_GROUP_ID
              AND asg.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = P_BUSINESS_GROUP_ID
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         = hoi2.organization_id
              )
     and asg.location_id = pgn.entity_id
     and (pgn.hierarchy_node_id = l_est_node_id
          or pgn.parent_hierarchy_node_id = l_est_node_id)
     and pgn.node_type in ('EST','LOC')
    and peo.per_information25 in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
    and check_recent_or_not(peo.person_id,l_month_end_date) > 0 ;



l_est_entity           number := 0;
l_est_node_id	         number := 0;
l_no_est_emps          number := 0;

loc_no_tot_emps number  := 0;
loc_no_dis_vets number    := 0;
loc_no_other_vets number   := 0;
loc_no_armed_vets number  := 0;
loc_no_recsep_vets number  := 0;
loc_no_not_vets  number :=0;

state_no_dis_vets number    := 0;
state_no_other_vets number   := 0;
state_no_armed_vets number  := 0;
state_no_recsep_vets number  := 0;
state_no_tot_emps number  := 0;

loc_no_tot_nh   number :=0;
loc_nh_dis_vets  number :=0;
loc_nh_other_vets  number :=0;
loc_nh_armed_vets  number :=0;
loc_nh_recsep_vets  number :=0;
loc_nh_not_vets  number :=0;

state_nh_dis_vets     number := 0;
state_nh_other_vets      number := 0;
state_nh_armed_vets     number := 0;
state_nh_recsep_vets    number := 0;
state_nh_tot_vets number := 0;

begin

open c_est_entity(p_state);

loop
   fetch c_est_entity into l_est_entity,l_est_node_id;
    exit when c_est_entity%notfound;

      l_no_est_emps := 0;

      loc_no_tot_emps := 0;
      loc_no_dis_vets := 0;
      loc_no_other_vets := 0;
      loc_no_armed_vets := 0;
      loc_no_recsep_vets := 0;
      loc_no_not_vets  := 0;

      loc_no_tot_nh   := 0;
      loc_nh_dis_vets  := 0;
      loc_nh_other_vets := 0;
      loc_nh_armed_vets  := 0;
      loc_nh_recsep_vets  := 0;
      loc_nh_not_vets  := 0;


      open c_tot_emps(l_est_node_id,l_month_end_date);
         fetch c_tot_emps into l_no_est_emps;
      close c_tot_emps;

      if l_no_est_emps < 50
      then

      open c_emps(l_est_node_id);
      fetch c_emps
      into  loc_no_dis_vets,loc_no_other_vets, loc_no_armed_vets,loc_no_recsep_vets,loc_no_not_vets;

     loc_no_tot_emps := loc_no_dis_vets + loc_no_other_vets + loc_no_armed_vets + loc_no_recsep_vets + loc_no_not_vets;

     state_no_dis_vets := state_no_dis_vets + loc_no_dis_vets;
     state_no_other_vets := state_no_other_vets + loc_no_other_vets;
     state_no_armed_vets := state_no_armed_vets + loc_no_armed_vets;
     state_no_recsep_vets := state_no_recsep_vets + loc_no_recsep_vets;
     state_no_tot_emps := state_no_tot_emps + loc_no_tot_emps;

     close c_emps;



   open c_nh(l_est_node_id);
     fetch c_nh
       INTO  loc_nh_dis_vets,
              loc_nh_other_vets,
              loc_nh_armed_vets,
              loc_nh_recsep_vets,
              loc_nh_not_vets ;

     loc_no_tot_nh := loc_nh_dis_vets+loc_nh_other_vets+loc_nh_armed_vets+loc_nh_recsep_vets+loc_nh_not_vets;

     state_nh_dis_vets       := state_nh_dis_vets + loc_nh_dis_vets;
     state_nh_other_vets     := state_nh_other_vets + loc_nh_other_vets ;
     state_nh_armed_vets     := state_nh_armed_vets + loc_nh_armed_vets ;
     state_nh_recsep_vets    := state_nh_recsep_vets + loc_nh_recsep_vets ;
     state_nh_tot_vets       := state_nh_tot_vets + loc_no_tot_nh ;

     close c_nh;

     if P_AUDIT_REPORT = 'Y' then
          for per in c_audit_report_emps(l_est_node_id)
          loop
              l_buffer := per.person_id || g_delimiter ||
                  		  	 per.last_name || g_delimiter ||
                  			   nvl(per.first_name,' ') || g_delimiter ||
                  			   nvl(per.employee_number,' ') || g_delimiter ||
                  			   per.veteran || g_delimiter ||
                  			   per.veteran_category || g_delimiter ||
                  			   p_job_category_name || g_delimiter ||
                  			   per.assignment_id || g_delimiter ||
                  			   p_state ||
            			         g_eol;
	              write_audit.put(l_buffer);
         end loop;
      end if;
    if P_AUDIT_REPORT = 'Y'  and P_SHOW_NEW_HIRES = 'Y' then
          for per in c_audit_report_nh(l_est_node_id)
          loop
              l_buffer := per.person_id || g_delimiter ||
                    			per.last_name || g_delimiter ||
                    			nvl(per.first_name,' ') || g_delimiter ||
                    			nvl(per.employee_number,' ') || g_delimiter ||
                    			per.veteran || g_delimiter ||
                    			per.veteran_category || g_delimiter ||
                    			p_job_category_name || g_delimiter ||
                    			per.assignment_id || g_delimiter ||
                    			p_state		||
                    			g_eol;
	             write_audit.put(l_buffer);
           end loop;
    end if;

      for per in c_nonreported(l_est_node_id)
          loop
               l_buffer := per.person_id || g_delimiter ||
                    			per.last_name || g_delimiter ||
                    			nvl(per.first_name,' ') || g_delimiter ||
                    			nvl(per.employee_number,' ') || g_delimiter ||
                    			per.veteran || g_delimiter ||
                    			p_job_category_name || g_delimiter ||
                    			per.assignment_id || g_delimiter ||
                    			p_state		||
                    			g_eol;
	            write_to_concurrent_log(l_buffer);
          end loop;
   end if;

end loop;
close c_est_entity;

l_xml_string := l_xml_string||'<LIST_G_4>';
l_xml_string := l_xml_string||'<G_4>';
l_xml_string := l_xml_string ||convert_into_xml('CP_NO_DIS_VETS',state_no_dis_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NO_OTHER_VETS',state_no_other_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NO_ARMED_VETS',state_no_armed_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NO_RECSEP_VETS',state_no_recsep_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NO_TOT_VETS',state_no_tot_emps,'D');
l_xml_string := l_xml_string||'</G_4>';
l_xml_string := l_xml_string||'</LIST_G_4>';

l_xml_string := l_xml_string||'<LIST_G_5>';
l_xml_string := l_xml_string||'<G_5>';
l_xml_string := l_xml_string ||convert_into_xml('CP_NH_DIS_VETS',state_nh_dis_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NH_OTHER_VETS',state_nh_other_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NH_ARMED_VETS',state_nh_armed_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NH_RECSEP_VETS',state_nh_recsep_vets,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_NH_TOT_VETS',state_nh_tot_vets,'D');
l_xml_string := l_xml_string||'</G_5>';
l_xml_string := l_xml_string||'</LIST_G_5>';


CS_NO_DIS_VETS := CS_NO_DIS_VETS + state_no_dis_vets;
CS_NO_OTHER_VETS := CS_NO_OTHER_VETS + state_no_other_vets;
CS_NO_ARMED_VETS := CS_NO_ARMED_VETS + state_no_armed_vets;
CS_NO_RECSEP_VETS := CS_NO_RECSEP_VETS + state_no_recsep_vets;
CS_NO_TOT_VETS := CS_NO_TOT_VETS + state_no_tot_emps;

CS_NH_DIS_VETS := CS_NH_DIS_VETS + state_nh_dis_vets;
CS_NH_OTHER_VETS := CS_NH_OTHER_VETS + state_nh_other_vets;
CS_NH_ARMED_VETS := CS_NH_ARMED_VETS + state_nh_armed_vets;
CS_NH_RECSEP_VETS := CS_NH_RECSEP_VETS + state_nh_recsep_vets;
CS_NH_TOT_VETS := CS_NH_TOT_VETS + state_nh_tot_vets;

end vets_data;


begin


l_business_group_name := hr_reports.get_business_group(p_business_group_id);
P_DATE_END1 := fnd_date.canonical_to_date(P_DATE_END);

if P_STATE is NULL then
   lc_state := 'All';
else
   lc_state := P_STATE;
end if;

open c_hier_details;
fetch c_hier_details into
l_hierarchy_name, l_hierarchy_version_num, l_parent_org_id, l_parent_node_id ;
close c_hier_details;

open c_count_est;
fetch c_count_est into l_est_no;
close c_count_est;

l_xml_string := '<?xml version="1.0"?>';
l_xml_string := l_xml_string ||'<PERRPVTC_100A>';
l_xml_string := l_xml_string ||convert_into_xml('C_BUSINESS_GROUP_NAME',l_business_group_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_END_OF_TIME',P_DATE_END1,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_HIERARCHY_NAME',l_hierarchy_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_HIERARCHY_VERSION_NUM',l_hierarchy_version_num,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_PARENT_ORG_ID',l_parent_org_id,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_PARENT_NODE_ID',l_parent_node_id,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_NO_OF_ESTABLISHMENTS',l_est_no,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DATE_END',P_DATE_END1,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_SHOW_NEW_HIRES',p_show_new_hires,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_SHOW_TOTALS',p_show_totals,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_STATE',lc_state,'D');
write_to_concurrent_out(l_xml_string);
l_xml_string :='';

 if P_AUDIT_REPORT = 'Y' then
   write_audit.open('PERRPVTC_100A');
    l_buffer := 'Person Id'  || g_delimiter ||
 		'Last Name' || g_delimiter ||
		'First Name'  || g_delimiter ||
		'Employee Number' || g_delimiter ||
		'Veteran Status' || g_delimiter ||
		'Veteran Category' || g_delimiter ||
		'Job Category' || g_delimiter ||
		'Assignment Id' || g_delimiter ||
		'State' ||
		 g_eol;
   write_audit.put(l_buffer);
end if;

write_to_concurrent_log('Please find the Employee details who are not counted under Recently Seperated Veteran Category.Please Correct them');

  l_buffer := 'Person Id'  || g_delimiter ||
 		'Last Name' || g_delimiter ||
		'First Name'  || g_delimiter ||
		'Employee Number' || g_delimiter ||
		'Veteran Status' || g_delimiter ||
		'Job Category' || g_delimiter ||
		'Assignment Id' || g_delimiter ||
		'State' ||
		 g_eol;

write_to_concurrent_log(l_buffer);

l_xml_string := l_xml_string||'<LIST_G_PARENT>';

open c_parent(l_parent_org_id);
fetch c_parent into
l_reporting_name,l_company_number,l_type_of_rep_org,l_parent_address,l_parent_city,
l_parent_county,l_parent_state,l_parent_zip,l_contact_name,l_contact_telnum,l_contact_email,
l_contact_telnum_and_email ;

open c_defaults(l_parent_org_id);
fetch c_defaults into
l_def_sic,l_def_naics,l_def_gre,l_def_duns,l_def_gov_con ;
close c_defaults;


l_xml_string := l_xml_string||'<G_PARENT>';

l_xml_string := l_xml_string ||convert_into_xml('CONTACT_NAME',l_contact_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('CONTACT_TELNUM',l_contact_telnum,'D');
l_xml_string := l_xml_string ||convert_into_xml('CONTACT_EMAIL',l_contact_email,'D');
l_xml_string := l_xml_string ||convert_into_xml('PARENT_NODE_ID',l_parent_node_id,'D');
l_xml_string := l_xml_string ||convert_into_xml('REPORTING_NAME',l_reporting_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('COMPANY_NUMBER',l_company_number,'D');
l_xml_string := l_xml_string ||convert_into_xml('TYPE_OF_REP_ORG',l_type_of_rep_org,'D');
l_xml_string := l_xml_string ||convert_into_xml('PARENT_ADDRESS',l_parent_address,'D');
l_xml_string := l_xml_string ||convert_into_xml('PARENT_CITY',l_parent_city,'D');
l_xml_string := l_xml_string ||convert_into_xml('PARENT_COUNTY',l_parent_county,'D');
l_xml_string := l_xml_string ||convert_into_xml('PARENT_STATE',l_parent_state,'D');
l_xml_string := l_xml_string ||convert_into_xml('PARENT_ZIP',l_parent_zip,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DEF_SIC',l_def_sic,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DEF_NAICS',l_def_naics,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DEF_GRE',l_def_gre,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DEF_DUNS',l_def_duns,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DEF_GOV_CON',l_def_gov_con,'D');

l_xml_string := l_xml_string||'<LIST_G_STATE>';

write_to_concurrent_out(l_xml_string);
l_xml_string :='';

if l_type_of_rep_org = '1P' then
    cp_prime_contractor := '[X]';
    cp_sub_contractor := '[  ]';
  elsif l_type_of_rep_org = '2S' then
    cp_prime_contractor := '[  ]';
    cp_sub_contractor := '[X]';
  elsif l_type_of_rep_org = '3B' then
    cp_prime_contractor := '[X]';
    cp_sub_contractor := '[X]';
  else
    cp_prime_contractor := '[  ]';
    cp_sub_contractor := '[  ]';
  end if;

open c_state(l_parent_node_id);
loop
fetch c_state into l_state;
exit when c_state%notfound;

  select
    meaning
  into l_state_meaning
  from
    hr_lookups
   where
       lookup_type = 'US_STATE'
   and lookup_code = l_state;

CS_NO_DIS_VETS  :=0;
CS_NO_OTHER_VETS  :=0;
CS_NO_ARMED_VETS  :=0;
CS_NO_RECSEP_VETS :=0;
CS_NO_TOT_VETS :=0;
CS_NH_DIS_VETS  :=0;
CS_NH_OTHER_VETS  :=0;
CS_NH_ARMED_VETS  :=0;
CS_NH_RECSEP_VETS :=0;
CS_NH_TOT_VETS  :=0;
CP_MSC := 0;

l_xml_string := l_xml_string||'<G_STATE>';
l_xml_string := l_xml_string ||convert_into_xml('CONTACT_NAME1',l_contact_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('CONTACT_TELNUM_AND_EMAIL',l_contact_telnum,'D');
l_xml_string := l_xml_string ||convert_into_xml('P_DATE_END1',P_DATE_END1,'D');
l_xml_string := l_xml_string ||convert_into_xml('STATE',l_state,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_REP_NAME',l_reporting_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_COMP_NUMBER',l_company_number,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_TYPE_OF_ORG',l_type_of_rep_org,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_ADDRESS',l_parent_address,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_CITY',l_parent_city,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_COUNTY',l_parent_county,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_STATE',l_parent_state,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_ZIP',l_parent_zip,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_REP_STATE',l_state_meaning,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_PRIME_CONTRACTOR',cp_prime_contractor,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_SUB_CONTRACTOR',cp_sub_contractor,'D');
l_xml_string := l_xml_string ||convert_into_xml('SHOW_TOTALS',P_SHOW_TOTALS,'D');

l_xml_string := l_xml_string||'<LIST_G_3>';

write_to_concurrent_out(l_xml_string);
l_xml_string :='';

open c_job_categories;
loop
fetch c_job_categories into l_display_order,l_job_code , l_cons_job_category_name ,
 l_cons_job_category_code , l_job_category_name ;
exit when c_job_categories%notfound;

l_xml_string := l_xml_string||'<G_3>';

l_xml_string := l_xml_string ||convert_into_xml('DISPLAY_ORDER',l_display_order,'D');
l_xml_string := l_xml_string ||convert_into_xml('JOB_CODE',l_job_code,'D');
l_xml_string := l_xml_string ||convert_into_xml('JOB_CATEGORY_NAME',l_job_category_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('CONS_JOB_CATEGORY_NAME',l_cons_job_category_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('CONS_JOB_CATEGORY_CODE',l_cons_job_category_code,'D');
l_xml_string := l_xml_string ||convert_into_xml('SHOW_NEW_HIRES',P_SHOW_NEW_HIRES,'D');

vets_data(l_state,l_job_code,l_job_category_name);

l_xml_string := l_xml_string||'</G_3>';
write_to_concurrent_out(l_xml_string);
l_xml_string :='';

end loop;
close c_job_categories;

l_xml_string := l_xml_string||'</LIST_G_3>';


min_max(l_state);

cp_msc := count_locsFormula(l_state,l_parent_node_id);

l_xml_string := l_xml_string ||convert_into_xml('CP_MSC',cp_msc,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NO_DIS_VETS',CS_NO_DIS_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NO_OTHER_VETS',CS_NO_OTHER_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NO_ARMED_VETS',CS_NO_ARMED_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NO_RECSEP_VETS',CS_NO_RECSEP_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NO_TOT_VETS',CS_NO_TOT_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NH_DIS_VETS',CS_NH_DIS_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NH_OTHER_VETS',CS_NH_OTHER_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NH_ARMED_VETS',CS_NH_ARMED_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NH_RECSEP_VETS',CS_NH_RECSEP_VETS,'D');
l_xml_string := l_xml_string ||convert_into_xml('CS_NH_TOT_VETS',CS_NH_TOT_VETS,'D');

l_xml_string := l_xml_string||'</G_STATE>';

write_to_concurrent_out(l_xml_string);
l_xml_string :='';

end loop;
close c_state;

l_xml_string := l_xml_string||'</LIST_G_STATE>';
l_xml_string := l_xml_string||'</G_PARENT>';

close c_parent;

l_xml_string := l_xml_string||'</LIST_G_PARENT>';
l_xml_string := l_xml_string||'</PERRPVTC_100A>';

write_to_concurrent_out(l_xml_string);
l_xml_string :='';

if P_AUDIT_REPORT = 'Y' then
    write_audit.close;
end if;

End GET_VETS100A_DATA;

FUNCTION convert_into_xml( p_name  IN VARCHAR2,
                           p_value IN VARCHAR2,
                           p_type  IN char)
RETURN VARCHAR2 IS
  l_convert_data VARCHAR2(300);
BEGIN
  IF p_type = 'D' THEN
   l_convert_data := '<'||p_name||'>'||'<![CDATA['||p_value||']]>'||'</'||p_name||'>';
  ELSE
     l_convert_data := '<'||p_name||'>';
  END IF;
  RETURN(l_convert_data);
END convert_into_xml;

PROCEDURE write_to_concurrent_out (p_text VARCHAR2) IS
BEGIN

   fnd_file.put_line(fnd_file.OUTPUT, p_text);

END write_to_concurrent_out;

PROCEDURE write_to_concurrent_log (p_text VARCHAR2) IS
BEGIN

  fnd_file.put_line(fnd_file.LOG, p_text);

END write_to_concurrent_log;


End per_us_vets_100a_cons_pkg ;


/
