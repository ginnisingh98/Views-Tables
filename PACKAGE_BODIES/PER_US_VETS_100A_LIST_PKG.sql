--------------------------------------------------------
--  DDL for Package Body PER_US_VETS_100A_LIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_VETS_100A_LIST_PKG" as
/* $Header: pervetsl100a.pkb 120.0.12010000.15 2009/10/30 08:28:30 emunisek noship $ */

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

cursor c_parent(l_parent_org_id  varchar2,l_parent_node_id varchar2)is
select
   l_parent_node_id,
   hoi1.org_information1              "Par Report Name"
from
   hr_organization_information hoi1
where
        hoi1.organization_id = l_parent_org_id
and hoi1.org_information_context = 'VETS_Spec' ;

cursor c_establishment(l_parent_node_id varchar2) is
Select
   pghn.hierarchy_node_id         "Est_Node_Id"
  ,pghn.parent_hierarchy_node_id  "Parent Node Id"
  ,upper(hlei1.lei_information1)  "Est_Rep_Name"
  ,hlei2.lei_information10        "Headquarters"
  ,upper(ltrim(rtrim(eloc.address_line_1))||' '||
         ltrim(rtrim(eloc.address_line_2))||' '||
         ltrim(rtrim(eloc.address_line_3))||', '||
         ltrim(rtrim(eloc.town_or_city))||', '||
         ltrim(rtrim(eloc.region_1))||', '||
         ltrim(rtrim(eloc.region_2))||' '||
         ltrim(rtrim(eloc.postal_code))) "Estab Address"
from
   hr_location_extra_info                hlei1
  ,hr_location_extra_info                hlei2
  ,per_gen_hierarchy_nodes         pghn
  ,hr_locations_all                           eloc
where
(hlei1.information_type = 'VETS-100 Specific Information'
and hlei1.lei_information_category= 'VETS-100 Specific Information')
and  (hlei2.information_type = 'Establishment Information'
and hlei2.lei_information_category= 'Establishment Information')
and hlei1.location_id = hlei2.location_id
and hlei1.location_id = pghn.entity_id
and pghn.parent_hierarchy_node_id = l_parent_node_id
and pghn.node_type = 'EST'
and eloc.location_id = pghn.entity_id;

l_business_group_name varchar2(240); --Increased variable size for Bug#9038285
c_date_end date;
l_hierarchy_name per_gen_hierarchy.name%type;
l_hierarchy_version_num per_gen_hierarchy_versions.VERSION_NUMBER%type;
l_parent_org_id varchar2(20);
l_parent_node_id per_gen_hierarchy_nodes.parent_hierarchy_node_id%type;
l_parent_node_id1 per_gen_hierarchy_nodes.parent_hierarchy_node_id%type;
l_est_no number;

l_reporting_name hr_organization_information.org_information1%type;
l_Est_Node_Id per_gen_hierarchy_nodes.hierarchy_node_id%type;
l_Est_Rep_Name hr_location_extra_info.lei_information1%type;
l_Headquarters hr_location_extra_info.lei_information10%type;
l_est_add long;
l_report_date varchar2(11);

l_xml_string clob :='';

l_buffer varchar2(200);
g_delimiter varchar2(10) := ',' ;
g_eol varchar2(1) := fnd_global.local_chr(10);

procedure C_tot_actFormula(l_est_node_id varchar2,l_Est_Rep_Name in varchar2) is

l_count_emps number := 0;
l_end_date   date := fnd_date.canonical_to_date(P_DATE_END);
TOT_COUNT_EMPS number := 0;

cursor c_vets is

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
from    per_all_people_f         	peo,
	per_all_assignments_f           asg,
        per_jobs_vl                     job
where   peo.person_id = asg.person_id
and     job.job_information_category   = 'US'
and     l_end_date between job.date_from and nvl(job.date_to,l_end_date)
and     job.job_information1             is not null
and     asg.job_id                     = job.job_id
and     asg.business_group_id          = P_BUSINESS_GROUP_ID
and     asg.assignment_type            = 'E'
and     asg.primary_flag               = 'Y'
and exists (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND    hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    asg.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories' )
and asg.effective_start_date =
   (select max(ass1.effective_start_date)
      from   per_all_assignments_f ass1
     where   l_end_date between ass1.effective_start_date and ass1.effective_end_date
       and   asg.person_id = ass1.person_id
       and   ass1.assignment_type  = 'E'
       and   ass1.primary_flag     = 'Y'
    )
and l_end_date between asg.effective_start_date and asg.effective_end_date
and l_end_date between peo.effective_start_date and peo.effective_end_date
and asg.location_id in
 (select distinct pgn.entity_id
          from per_gen_hierarchy_nodes pgn
          where  pgn.hierarchy_version_id = p_hierarchy_version_id
          AND    (
                pgn.hierarchy_node_id =  l_est_node_id
               OR   pgn.parent_hierarchy_node_id =  l_est_node_id)
          and   pgn.node_type in  ('EST','LOC')
  )

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
from    per_all_people_f         	peo,
      	per_all_assignments_f           asg,
        per_jobs_vl                     job
where   peo.person_id = asg.person_id
and     job.job_information_category   = 'US'
and     l_end_date between job.date_from and nvl(job.date_to,l_end_date)
and     job.job_information1             is not null
and     asg.job_id                     = job.job_id
and     asg.business_group_id          = P_BUSINESS_GROUP_ID
and     asg.assignment_type            = 'E'
and     asg.primary_flag               = 'Y'
and exists (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND    hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    asg.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories' )
and asg.effective_start_date =
   (select max(ass1.effective_start_date)
      from   per_all_assignments_f ass1
     where   l_end_date between ass1.effective_start_date and ass1.effective_end_date
       and   asg.person_id = ass1.person_id
       and   ass1.assignment_type  = 'E'
       and   ass1.primary_flag     = 'Y'
    )
and l_end_date between asg.effective_start_date and asg.effective_end_date
and l_end_date between peo.effective_start_date and peo.effective_end_date
and asg.location_id in
 (select distinct pgn.entity_id
          from per_gen_hierarchy_nodes pgn
          where  pgn.hierarchy_version_id = p_hierarchy_version_id
          AND    (
                pgn.hierarchy_node_id =  l_est_node_id
               OR   pgn.parent_hierarchy_node_id =  l_est_node_id)
          and   pgn.node_type in  ('EST','LOC')
        )
and peo.per_information25  in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
and check_recent_or_not(peo.person_id,l_end_date) > 0 ;

cursor c_nonreported is

   SELECT
 peo.person_id
,peo.last_name
,peo.first_name
,peo.employee_number
,peo.per_information25 veteran
,asg.assignment_id

from    per_all_people_f         	peo,
      	per_all_assignments_f           asg,
        per_jobs_vl                     job
where   peo.person_id = asg.person_id
and     job.job_information_category   = 'US'
and     l_end_date between job.date_from and nvl(job.date_to,l_end_date)
and     job.job_information1             is not null
and     asg.job_id                     = job.job_id
and     asg.business_group_id          = P_BUSINESS_GROUP_ID
and     asg.assignment_type            = 'E'
and     asg.primary_flag               = 'Y'
and exists (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND    hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    asg.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories' )
and asg.effective_start_date =
   (select max(ass1.effective_start_date)
      from   per_all_assignments_f ass1
     where   l_end_date between ass1.effective_start_date and ass1.effective_end_date
       and   asg.person_id = ass1.person_id
       and   ass1.assignment_type  = 'E'
       and   ass1.primary_flag     = 'Y'
    )
and l_end_date between asg.effective_start_date and asg.effective_end_date
and l_end_date between peo.effective_start_date and peo.effective_end_date
and asg.location_id in
 (select distinct pgn.entity_id
          from per_gen_hierarchy_nodes pgn
          where  pgn.hierarchy_version_id = p_hierarchy_version_id
          AND    (
                pgn.hierarchy_node_id =  l_est_node_id
               OR   pgn.parent_hierarchy_node_id =  l_est_node_id)
          and   pgn.node_type in  ('EST','LOC')
        )
and peo.per_information25  in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')

MINUS

SELECT
 peo.person_id
,peo.last_name
,peo.first_name
,peo.employee_number
,peo.per_information25 veteran
,asg.assignment_id
from    per_all_people_f         	peo,
      	per_all_assignments_f           asg,
        per_jobs_vl                     job
where   peo.person_id = asg.person_id
and     job.job_information_category   = 'US'
and     l_end_date between job.date_from and nvl(job.date_to,l_end_date)
and     job.job_information1             is not null
and     asg.job_id                     = job.job_id
and     asg.business_group_id          = P_BUSINESS_GROUP_ID
and     asg.assignment_type            = 'E'
and     asg.primary_flag               = 'Y'
and exists (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND    hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    asg.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories' )
and asg.effective_start_date =
   (select max(ass1.effective_start_date)
      from   per_all_assignments_f ass1
     where   l_end_date between ass1.effective_start_date and ass1.effective_end_date
       and   asg.person_id = ass1.person_id
       and   ass1.assignment_type  = 'E'
       and   ass1.primary_flag     = 'Y'
    )
and l_end_date between asg.effective_start_date and asg.effective_end_date
and l_end_date between peo.effective_start_date and peo.effective_end_date
and asg.location_id in
 (select distinct pgn.entity_id
          from per_gen_hierarchy_nodes pgn
          where  pgn.hierarchy_version_id = p_hierarchy_version_id
          AND    (
                pgn.hierarchy_node_id =  l_est_node_id
               OR   pgn.parent_hierarchy_node_id =  l_est_node_id)
          and   pgn.node_type in  ('EST','LOC')
        )
and peo.per_information25  in ('NS','AFSMNSDIS','NSDIS','AFSMNSDISOP','NSOP','AFSMNSOP','AFSMNS','NSDISOP')
and check_recent_or_not(peo.person_id,l_end_date) > 0 ;


begin

--Made fix for 8724355 - Removed the join condition with per_jobs_vl
select
        count(distinct asg.person_id)
into    l_count_emps
from    per_all_assignments_f          asg,
        per_periods_of_service         pps  /*8667924*/
where
 asg.business_group_id          = P_BUSINESS_GROUP_ID
and     asg.assignment_type            = 'E'
and     asg.primary_flag               = 'Y'
and asg.person_id = pps.person_id
and asg.business_group_id = pps.business_group_id
and
(
exists (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(asg.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND    hoi1.org_information_context    = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    asg.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories' )
    or
months_between(l_end_date,pps.actual_termination_date) between 0 and 12 /*8667924*/
)
and asg.effective_start_date =
   (select max(ass1.effective_start_date)
      from   per_all_assignments_f ass1
     where   l_end_date between ass1.effective_start_date and ass1.effective_end_date
       and   asg.person_id = ass1.person_id
       and   ass1.assignment_type  = 'E'
       and   ass1.primary_flag     = 'Y'
    )
and  l_end_date between asg.effective_start_date and asg.effective_end_date
and asg.location_id in
    (select distinct pgn.entity_id
          from per_gen_hierarchy_nodes pgn
          where  pgn.hierarchy_version_id = p_hierarchy_version_id
          AND    (
                pgn.hierarchy_node_id =  l_est_node_id
               OR   pgn.parent_hierarchy_node_id =  l_est_node_id)
          and   pgn.node_type in  ('EST','LOC')
    );


IF l_count_emps between 0 and 50 THEN
  TOT_COUNT_EMPS := nvl(TOT_COUNT_EMPS,0)+l_count_emps;

  if P_AUDIT_REPORT = 'Y' then
     for per in c_vets
          loop
             l_buffer := per.person_id || g_delimiter ||
			per.last_name || g_delimiter ||
			nvl(per.first_name,' ') || g_delimiter ||
			nvl(per.employee_number,' ') || g_delimiter ||
			per.veteran || g_delimiter ||
			per.veteran_category || g_delimiter ||
			per.job_category || g_delimiter ||
			per.assignment_id || g_delimiter ||
			l_Est_Rep_Name ||
			g_eol;
	    write_audit.put(l_buffer);
          end loop;
    end if;

    for per in c_nonreported
          loop
               l_buffer := per.person_id || g_delimiter ||
                    			per.last_name || g_delimiter ||
                    			nvl(per.first_name,' ') || g_delimiter ||
                    			nvl(per.employee_number,' ') || g_delimiter ||
                    			per.veteran || g_delimiter ||
                    			per.assignment_id || g_delimiter ||
                    			l_Est_Rep_Name		||
                    			g_eol;

	            write_to_concurrent_log(l_buffer);
          end loop;

END IF;

l_xml_string := l_xml_string ||convert_into_xml('C_TOT_EMPS',l_count_emps,'D');

end C_tot_actFormula;

begin

l_business_group_name := hr_reports.get_business_group(p_business_group_id);
C_DATE_END    := fnd_date.canonical_to_date(P_DATE_END);

select sysdate
into l_report_date
from dual;

open c_hier_details;
  fetch c_hier_details into
  l_hierarchy_name, l_hierarchy_version_num, l_parent_org_id, l_parent_node_id ;
close c_hier_details;

open c_count_est;
  fetch c_count_est into l_est_no;
close c_count_est;

l_xml_string := '<?xml version="1.0"?>';
l_xml_string := l_xml_string||'<PERUSVEL_100A>';
l_xml_string := l_xml_string ||convert_into_xml('C_BUSINESS_GROUP_NAME',l_business_group_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_HIERARCHY_NAME',l_hierarchy_name,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_HIERARCHY_VERSION_NUM',l_hierarchy_version_num,'D');
l_xml_string := l_xml_string ||convert_into_xml('C_DATE_END',C_DATE_END,'D');
l_xml_string := l_xml_string ||convert_into_xml('CP_REPORT_DATE',l_report_date,'D');
l_xml_string := l_xml_string||'<LIST_G_PARENT_NODE_ID>';

write_to_concurrent_out(l_xml_string);
l_xml_string :='';

if P_AUDIT_REPORT = 'Y' then
         write_audit.open('PERUSVEL_100A');

           l_buffer :=  'Person Id'  || g_delimiter ||
 	                      'Last Name' || g_delimiter ||
	                      'First Name'  || g_delimiter ||
                    		'Employee Number' || g_delimiter ||
                    		'Veteran Status' || g_delimiter ||
                    		'Veteran Category' || g_delimiter ||
                    		'Job Category' || g_delimiter ||
                    		'Assignment Id' || g_delimiter ||
                    		'Reporting Name' ||
                    		 g_eol;

        write_audit.put(l_buffer);
end if;

write_to_concurrent_log('Please find the Employee details who are not counted under Recently Seperated Veteran Category.Please Correct them');

  l_buffer := 'Person Id'  || g_delimiter ||
 		'Last Name' || g_delimiter ||
		'First Name'  || g_delimiter ||
		'Employee Number' || g_delimiter ||
		'Veteran Status' || g_delimiter ||
		'Assignment Id' || g_delimiter ||
		'Reporting Name' ||
		 g_eol;
write_to_concurrent_log(l_buffer);

open c_parent(l_parent_org_id,l_parent_node_id);
  fetch c_parent into l_parent_node_id,l_reporting_name ;

l_xml_string := l_xml_string||'<G_PARENT_NODE_ID>';

l_xml_string := l_xml_string ||convert_into_xml('PARENT_NODE_ID',l_parent_node_id,'D');
l_xml_string := l_xml_string ||convert_into_xml('PAR_REPORT_NAME',l_reporting_name,'D');
l_xml_string := l_xml_string||'<LIST_G_ESTABLISHMENT>';

write_to_concurrent_out(l_xml_string);
l_xml_string :='';

  open c_establishment(l_parent_node_id );
    loop
      fetch c_establishment into l_Est_Node_Id , l_parent_node_id1 , l_Est_Rep_Name,
      l_Headquarters , l_est_add ;
      exit when c_establishment%notfound;

      l_xml_string := l_xml_string||'<G_ESTABLISHMENT>';

      l_xml_string := l_xml_string ||convert_into_xml('EST_NODE_ID',l_Est_Node_Id,'D');
      l_xml_string := l_xml_string ||convert_into_xml('PARENT_NODE_ID1',l_parent_node_id1,'D');
      l_xml_string := l_xml_string ||convert_into_xml('EST_REP_NAME',l_Est_Rep_Name,'D');
      l_xml_string := l_xml_string ||convert_into_xml('HEADQUARTERS',l_Headquarters,'D');
      l_xml_string := l_xml_string ||convert_into_xml('ESTB_ADDRESS',l_est_add,'D');

      C_tot_actFormula(l_Est_Node_Id,l_Est_Rep_Name);

      l_xml_string := l_xml_string||'</G_ESTABLISHMENT>';

       write_to_concurrent_out(l_xml_string);
       l_xml_string :='';

    end loop;
  close c_establishment;

l_xml_string := l_xml_string||'</LIST_G_ESTABLISHMENT>';
l_xml_string := l_xml_string||'</G_PARENT_NODE_ID>';

close c_parent;

l_xml_string := l_xml_string||'</LIST_G_PARENT_NODE_ID>';
l_xml_string := l_xml_string||'</PERUSVEL_100A>';

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
  l_convert_data VARCHAR2(200);
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

End per_us_vets_100a_list_pkg ;


/
