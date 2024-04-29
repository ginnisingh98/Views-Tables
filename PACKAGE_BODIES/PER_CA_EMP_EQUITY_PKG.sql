--------------------------------------------------------
--  DDL for Package Body PER_CA_EMP_EQUITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CA_EMP_EQUITY_PKG" AS
/* $Header: perhrcaempequity.pkb 120.0 2006/05/25 06:36:55 ssmukher noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : per_ca_emp_equity_pkg

    Description : This package is used for generating the employee.txt
                  promot.txt ,term.txt and excep.txt tab delimited
                  text file for Employment Equity report.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    28-Apr-2005 ssmukher   115.0            Created.
    04-Jul-2005 ssmukher   115.1            Removed the cursor cur_term_asg
                                            Modified the CMA code values in the
                                            cursor cur_emp_cma, added another delete
                                            stmt at the start of the procedure to
                                            remove records from per_ca_ee_report_lines
                                            table,added an additional check before
                                            inserting temporary employees as well as
                                            Promoted employee details.
    05-Jul-2005 ssmukher   115.2            Modified the cursor c_promo.
                                            Modified the effective end date condition for
                                            per_all_people_f and per_all_assignments_f
                                            table
    05-Jul-2005 ssmukher   115.3            Modified the code so that if the designated
                                            code is not specified for an employee then
                                            record is not inserted into the exception
                                            report
    07-Jul-2005 ssmukher                    Added check for secure user.
    08-Jul-2005 ssmukher   115.4            Fix for Bug 4480102
    13-Jul-2005 ssmukher   115.5            Bug 4488375 :Modified the length of Last name
                                            and First name in cur_emp_categ_person cursor
                                            to 20 and 15 respectively.
    14-Jul-2005 ssmukher   115.6            Bug 4490792 : Modified the cursor c_total_salary
                                            Bug 4493278 fix is also included in it.
    20-Jul-2005 ssmukher   115.7   4501549  Modified the cursor  cur_emp_categ_naic_asg and
                                            cur_emp_categ_asg to include the maximum effective
                                            start date check.
    27-Jul-2005 ssmukher   115.8   4500929  Modified the cursor c_total_salary.
  ******************************************************************************/

/********* Procedure to create the employee.txt file ***************/
/**************** Start of Procedure   ******************************/

v_person_type_temp    person_type_tab;
v_person_type         person_type_tab;
v_job_id_temp         job_id_tab;
v_job_id              job_id_tab;
v_job_noc_temp        job_noc_tab;
v_job_noc             job_noc_tab;

/* Function for checking if a particular job id exists*/
FUNCTION job_exists (p_job_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
     IF v_job_id.COUNT > 0 THEN
         IF v_job_id.EXISTS(p_job_id) THEN
              RETURN v_job_noc(p_job_id);
         END IF;
     END IF;

     RETURN NULL;

END  job_exists;

/* Function for checking if the person type exists */
FUNCTION person_type_exists (p_person_type IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
     IF v_person_type.COUNT > 0 THEN
         IF v_person_type.EXISTS(p_person_type) THEN
              RETURN 'Y';
         END IF;
     END IF;

     RETURN NULL;

END  person_type_exists;

/* Procedure  for printing  employee details */
procedure employee_dtls (errbuf    out nocopy varchar2,
               retcode             out nocopy number,
               p_business_group_id in number,
               p_year              in varchar2,
               p_naic_code         in varchar2)
is
/* Initialising the variables */
   v_year_start date;
   v_year_end   date ;
   l_file_name  varchar2(50);

/*Cursor for checking the validity of Job code assigned to an employee */
  cursor cur_jobs is
  select job_id,
         job_information7
  from per_jobs,
       hr_lookups
  where lookup_type = 'EEOG'
  and   upper(ltrim(rtrim(lookup_code)))
           =upper(ltrim(rtrim(job_information1)))
  and   upper(ltrim(rtrim(job_information_category))) = 'CA'
  and   business_group_id = p_business_group_id;

/*Cursor for checking the validity of person type for an employee */
  cursor cur_person_types is
  select person_type_id
  from  per_person_types
  where  upper(ltrim(rtrim(system_person_type)))='EMP'
  and    business_group_id = p_business_group_id;

/*Cursor for checking the NAIC code validation */
  cursor cur_naic_code (p_keyflex_id number) is
  select hl.lookup_code
  from   hr_lookups hl,
         hr_soft_coding_keyflex hsck
  where  hsck.soft_coding_keyflex_id = p_keyflex_id and
         hl.lookup_type = 'NAIC' and
      (
            (
                hsck.segment6 is not null and
                hl.lookup_code = hsck.segment6
            )
           OR
           (
               hsck.segment6 is null and
	       exists
	       ( select 1
	         from   hr_organization_information hoi
		 where  hoi.org_information8 is not null and
                        hl.lookup_code=hoi.org_information8 and
                        hsck.segment1 = to_char(hoi.organization_id) and
                        hoi.org_information_context = 'Canada Employer Identification'
	       )
           )
      );

  /* Cursor for fetching the distinct person id and person deatils for Permanent,Temporary employees
     with NAIC code not been specified in the concurrent program */

   cursor cur_emp_categ_person ( p_start_date date) is
    select
      distinct(ppf.person_id) l_person_id,
      ppf.employee_number emp_no,
      substr(ppf.first_name,1,15) first_name,
      substr(ppf.last_name,1,20)  last_name,
      ppf.sex    gender,
      nvl(ppf.per_information5,'N') desg_abor,
      nvl(ppf.per_information6,'N') desg_vminor,
      nvl(ppf.per_information7,'N') desg_disab,
      trunc(ppf.original_date_of_hire) date_of_hire
    from
      per_all_people_f ppf
    where person_type_exists(ppf.person_type_id) is not null and
      ppf.effective_end_date >= p_start_date and
      ppf.business_group_id = p_business_group_id
  order by l_person_id,emp_no;

/* Cursor for fetching all the primary assignment details corresponding to the person fetched
   from the cursor cur_emp_categ_person*/
/* Bug 4501549 Added the check for maximum effective start date  */
  cursor cur_emp_categ_asg ( p_person_id number,
                             p_start_date date) is
    select paf.assignment_id asg_id,
      job_exists(paf.job_id)   noc_code,
      decode (substr(NVL(paf.employment_category,'-1'),1,2),'FR','01','PR','02','PT','03','FT','03','-1','-1','04') employment_category,
      paf.location_id loc_id,
      paf.soft_coding_keyflex_id  flex_id,
      paf.effective_start_date st_dt
    from
      per_all_assignments_f paf
    where  paf.person_id = p_person_id and
      paf.effective_end_date >= p_start_date  and
      paf.business_group_id = p_business_group_id and
      paf.primary_flag = 'Y' and
      job_exists(paf.job_id) is not null and
      paf.effective_start_date = (select max(effective_start_date)
                                      from per_all_assignments_f paf1
                                      where paf1.business_group_id = p_business_group_id
                                       and  paf1.assignment_id = paf.assignment_id
                                       and  paf1.person_id = p_person_id);

/* Cursor for fetching all the primary assignment details corresponding to the person fetched
   from the cursor cur_emp_categ_naic_person */
/* Bug 4501549 Added the check for maximum effective start date  */

    cursor cur_emp_categ_naic_asg ( p_person_id number,
                                    p_start_date date ) is
    select paf.assignment_id  asg_id,
      job_exists(paf.job_id)      noc_code,
      decode (substr(NVL(paf.employment_category,'-1'),1,2),'FR','01','PR','02','PT','03','FT','03','-1','-1','04')  employment_category,
      paf.location_id loc_id,
      paf.effective_start_date st_dt
    from
      per_all_assignments_f paf,
      hr_soft_coding_keyflex hsck,
      hr_lookups hl
    where paf.person_id = p_person_id and
      paf.business_group_id = p_business_group_id and
      paf.effective_end_date >= p_start_date and
      paf.primary_flag = 'Y' and
      job_exists(paf.job_id) is not null and
      hl.lookup_type = 'NAIC' and
      paf.effective_start_date = (select max(effective_start_date)
                                      from per_all_assignments_f paf1
                                      where paf1.business_group_id = p_business_group_id
                                       and  paf1.assignment_id = paf.assignment_id
                                       and  paf1.person_id = p_person_id) and
      hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
      (
            (
                hsck.segment6 is not null and
                hl.lookup_code = hsck.segment6 and
                hl.lookup_code = p_naic_code
            )
           OR
           (
               hsck.segment6 is null and
	       exists
	       ( select 1
	         from   hr_organization_information hoi
		 where  hoi.org_information8 is not null and
                        hl.lookup_code=hoi.org_information8 and
                        hsck.segment1 = to_char(hoi.organization_id) and
                        hoi.org_information8 = p_naic_code and
                        hoi.org_information_context = 'Canada Employer Identification'
	       )
           )
      );


 /*  Cursor to fetch the terminated Permanent as well as temporary employees person id and details with
     the NAIC code not been specified  in the concurrent request parameter */

 cursor cur_term_date ( p_person_id number,
                          p_start_date date,
			  p_end_date  date) is
 select  trunc(ppos.actual_termination_date) term_date,
      trunc(ppos.projected_termination_date) end_dt
    from
      per_all_people_f ppf,
      per_periods_of_service ppos
    where person_type_exists(ppf.person_type_id) is not null and
      ppos.actual_termination_date between
          ppf.effective_start_date and
          ppf.effective_end_date   and
      ppf.business_group_id=p_business_group_id and
      ppf.person_id = p_person_id and
      ppf.person_id=ppos.person_id and
      ppos.actual_termination_date is not null and
      ppos.actual_termination_date >= p_start_date and
      ppos.actual_termination_date <=  p_end_date;

/* Term dare details for the Temporary Employees */
 cursor cur_temp_term_date ( p_person_id number,
                             p_start_date date,
                             p_end_date  date) is
 select  max(paf.effective_start_date) start_dt,
         trunc(ppos.actual_termination_date) term_date,
         trunc(ppos.projected_termination_date) end_dt
    from
      per_all_people_f ppf,
      per_all_assignments_f paf,
      per_periods_of_service ppos
    where person_type_exists(ppf.person_type_id) is not null and
      paf.person_id = ppf.person_id and
      ppos.actual_termination_date between
          ppf.effective_start_date and
          ppf.effective_end_date   and
      ppos.actual_termination_date between
          paf.effective_start_date and
          paf.effective_end_date   and
      paf.effective_end_date = ppos.actual_termination_date and
      ppf.business_group_id=p_business_group_id and
      ppf.person_id = p_person_id and
      ppf.person_id=ppos.person_id and
      ppos.actual_termination_date is not null and
      ppos.actual_termination_date >= p_start_date and
      ppos.actual_termination_date <=  p_end_date
 group by trunc(ppos.actual_termination_date) ,
         trunc(ppos.projected_termination_date);


/* Cursor to fetch the Salary for the employee */
/* Bug 4500929 fix : Modified the query for checking the maximum effective start date
   for the assignment  */
cursor c_total_salary (p_person_id number) is
select  sum(trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor) salary
from     per_pay_bases ppb,
         per_all_assignments_f paf,
         per_all_people_f ppf,
         per_pay_proposals_v2 pppv,
         per_assignment_status_types past,
         hr_lookups hrl
where    paf.pay_basis_id      = ppb.pay_basis_id and
         paf.person_id=ppf.person_id and
         past.assignment_status_type_id = paf.assignment_status_type_id and
         pppv.assignment_id = paf.assignment_id and
         hrl.lookup_type ='PER_ASS_SYS_STATUS' and
         hrl.lookup_code = past.per_system_status and
         hrl.lookup_code = 'ACTIVE_ASSIGN' and
         ppf.current_emp_or_apl_flag = 'Y' and
         ppb.business_group_id = p_business_group_id and
         paf.person_id = p_person_id and
         paf.assignment_id=pppv.assignment_id and
         paf.effective_start_date = ( select max(effective_start_date)
                                      from  per_all_assignments_f paf1,
                                            per_assignment_status_types past1,
                                            hr_lookups hrl1
                                      where paf1.business_group_id = p_business_group_id
                                       and  paf1.assignment_id = pppv.assignment_id
                                       and  paf1.person_id = p_person_id
                                       and  past1.assignment_status_type_id = paf1.assignment_status_type_id
                                       and  hrl1.lookup_type ='PER_ASS_SYS_STATUS'
                                       and  hrl1.lookup_code = past1.per_system_status
                                       and  hrl1.lookup_code = 'ACTIVE_ASSIGN'
                                     ) and
         ppf.effective_start_date = ( select max(effective_start_date)
                                      from   per_all_people_f ppf1
                                      where  ppf1.person_id = ppf.person_id
                                       and   ppf1.business_group_id = p_business_group_id
                                       and   ppf1.current_emp_or_apl_flag = 'Y'
                                    ) and
         pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <= v_year_end
                        )
group by ppf.person_id;

/* Cursor to fetch the Province code for the employee */
  cursor cur_emp_prov (p_location_code number) is
  select  decode( hl1.lookup_code,'ON','10',
                                  'QC','11',
                                  'NS','12',
                                  'NB','13',
                                  'MB','14',
                                  'BC','15',
                                  'PE','16',
                                  'SK','17',
                                  'AB','18',
                                  'NF','19',
                                  'YT','20',
                                  'NT','21',
                                  'NU','22',
                                       '98')
  from    hr_locations_all hloc,
          hr_lookups hl1
  where   hloc.location_id = p_location_code
  and     hl1.lookup_code = hloc.region_1
  and     hl1.lookup_type = 'CA_PROVINCE';

/* Cursor to fetch the CMA code for the employee */
  cursor cur_emp_cma (p_location_code number) is
  SELECT  decode(ltrim(rtrim(hl1.lookup_code)),
          'CALGARY' ,'01', 'EDMONTON','02','HALIFAX','03',
          'MONTREAL','04', 'REGINA','05', 'TORONTO','06',
          'VANCOUVER','07', 'WINNEPEG','08' ,'ST JOHNS','50',
          'SAINT JOHN','52','CHICOUTIMI','53',
          'QUEBEC','54','SHERBROOKE','55','TROIS RIVIERES','56',
          'KINGSTON NEW','57','OTTOWA HULL','58','OSHAWA','59',
          'HAMILTON','61','ST CATHARINES NIAGARA','62',
          'KITCHENER','63','LONDON','64','WINDSOR','65','SUDBURY','66',
          'THUNDER BAY','67','SASKATOON','70','ABBOTSFORD NEW','72',
          'VICTORIA','74','ALBERTA LESS CMA','85',
          'BRITISH COLUMBIA LESS CMA','86','MANITOBA LESS CMA','87',
          'NEW BRUNSWICK LESS CMA','88','NOVA SCOTIA LESS CMA','89',
          'NORTH WEST TERRITORIES','90','NEWFOUNDLAND LESS CMA','91',
          'NUNAVUT','92','ONTORIA LESS CMA','93','PRINCE EDWARD ISLAND','94',
          'QUEBEC LESS CMA','95','SASKATCHEWAN LESS CMA','96','YUKON TERRITORY','97')
  FROM    hr_lookups hl1,
          hr_locations_all hloc
  WHERE   hloc.location_id = p_location_code
  AND     hloc.region_2 = hl1.lookup_code
  AND     hl1.lookup_type = 'CA_CMA';

/* Cursor for the counting the number of promotion  */
     cursor c_promo ( p_person_id number,
                      p_start_date date,
                      p_end_date date) is
     select distinct ppp.assignment_id asg_id,
            TRUNC(ppp.change_date) promo_date
     from per_pay_proposals_v2 ppp,
          per_all_people_f ppf,
          per_all_assignments_f  paf
     where ppf.person_id = paf.person_id and
           ppf.person_id = p_person_id and
           paf.assignment_id =  ppp.assignment_id and
           ppf.effective_end_date >  p_start_date  and
           paf.effective_end_date >  p_start_date  and
           ppp.business_group_id = p_business_group_id and
           ppp.proposal_reason = 'PROM' and
           ppp.change_date BETWEEN p_start_date AND p_end_date and
           ppp.approved       = 'Y';

/* Cursor to check if the user isa secure user or not */
   cursor c_person_exists( p_person_id number) is
   select 'Y'
   from   per_people_f
   where person_id = p_person_id;

/*Declaration of local variables */
    table_date    per_fastformula_events_utility.date_tab;

    l_output_txt  varchar2(1000);
    l_org_info hr_organization_information.org_information1%type;
    l_personid    per_all_people_f.person_id%type;
    l_emp_no      per_all_people_f.employee_number%type;
    l_first_name  per_all_people_f.first_name%type;
    l_last_name   per_all_people_f.last_name%type;
    l_employment_category varchar2(5);
    l_gender      per_all_people_f.sex%type;
    l_loc_id      per_all_assignments_f.location_id%type;
    l_asg_id      per_all_assignments_f.assignment_id%type;
    l_province    varchar2(5);
    l_desg_abor   per_all_people_f.per_information5%type;
    l_desg_vminor per_all_people_f.per_information6%type;
    l_desg_disab  per_all_people_f.per_information7%type;
    l_naics_no    hr_organization_information.org_information8%type;
    l_naics_no_gre hr_organization_information.org_information8%type;
    l_hire_date   date;
    l_term_date   date;
    l_promo_date  date;
    l_st_date     date;
    l_start_date  date;
    l_end_dt      date;
    l_cma_code    varchar2(5);
    l_keyflex_id  hr_soft_coding_keyflex.soft_coding_keyflex_id%type;
    l_noc_code    per_jobs.job_information7%type;
    l_salary      number;
    l_flag        char(1);
    l_cnt_flag    char(1);
    l_tmp_cnt     number;
    l_promo_cnt   number;
    l_excep_cnt   number;
    l_promo_no    number;
    l_person_exists char(1);
    l_asgchk_flag   char(1);
Begin

    --hr_utility.trace_on(null,'EQUITY');
    v_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
    v_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;
    l_excep_cnt := 0;

/* Added by ssmukher for Bug            */
   l_asgchk_flag := 'Y';

/* Added by ssmukher in v115.1
   Removing the records from per_ca_ee_report_lines table
   before running any new report  */
   delete
   from per_ca_ee_report_lines
   where request_id in (10,20,30);

/* Caching data from per_jobs and per_person_types tables */

   open cur_jobs;
   fetch cur_jobs bulk collect into
   v_job_id_temp,
   v_job_noc_temp;

   close cur_jobs;

   if v_job_id_temp.count > 0 then
       for i in v_job_id_temp.first..v_job_id_temp.last LOOP
            v_job_id(v_job_id_temp(i))  := v_job_id_temp(i);
            v_job_noc(v_job_id_temp(i)) := v_job_noc_temp(i);
       end loop;
   end if;

   open cur_person_types;
   fetch cur_person_types bulk collect into
   v_person_type_temp;
   close cur_person_types;

   if v_person_type_temp.count > 0 then
       for i in v_person_type_temp.first..v_person_type_temp.last LOOP
            v_person_type(v_person_type_temp(i)) := v_person_type_temp(i);
       end loop;
   end if;


   open cur_emp_categ_person(v_year_start);

   hr_utility.trace('The value of l_asgchk_flag is '||l_asgchk_flag);
   loop

     hr_utility.trace('Inside the first loop');
     fetch cur_emp_categ_person
     into  l_personid,
           l_emp_no,
           l_first_name,
           l_last_name,
           l_gender,
           l_desg_abor ,
           l_desg_vminor,
           l_desg_disab,
           l_hire_date;
      hr_utility.trace('Outside the first fetch statement');
      hr_utility.trace('Person Id :'||l_personid);
      if cur_emp_categ_person%notfound then
         exit;
      end if;

/* Added code for checking the secure user */
   open c_person_exists(l_personid);
   fetch c_person_exists
   into  l_person_exists;

   if c_person_exists%notfound then
      close c_person_exists;
      hr_utility.set_message(800,'PAY_74160_SUPER_USER');
      pay_core_utils.push_message(800,'PAY_74160_SUPER_USER','P');
      hr_utility.raise_error;
   else
      close c_person_exists;
   end if;

    l_term_date := null;
    l_end_dt :=  null;
    if p_naic_code is null then
      open cur_emp_categ_asg(l_personid,v_year_start) ;
    else
      open cur_emp_categ_naic_asg(l_personid,v_year_start) ;
    end if;


        if p_naic_code is null then
           hr_utility.trace('Inside the first loop');
           fetch cur_emp_categ_asg
           into  l_asg_id,
                 l_noc_code,
                 l_employment_category,
                 l_loc_id,
                 l_keyflex_id,
                 l_st_date;

           hr_utility.trace('Outside the first fetch statement');
           hr_utility.trace('Assignment Id :'||l_asg_id);

       else
           fetch cur_emp_categ_naic_asg
           into  l_asg_id,
                 l_noc_code,
                 l_employment_category,
                 l_loc_id,
                 l_st_date;

       end if;
/* Added by ssmukher for Bug 4493278  */
    if p_naic_code is null then
       if cur_emp_categ_asg%notfound then
                l_asgchk_flag := 'N';
          else
                l_asgchk_flag := 'Y';
       end if;
       close cur_emp_categ_asg ;
    else
       hr_utility.trace('Code is null');
       if cur_emp_categ_naic_asg%notfound then
                hr_utility.trace('No record found for the person in cur_emp_categ_naic_asg cursor');
                l_asgchk_flag := 'N';
          else
                l_asgchk_flag := 'Y';
       end if;
           close cur_emp_categ_naic_asg ;
    end if;

/* Added by ssmukher for Bug 4493278  checking if the assignment corresponding to the
   person is fetched or not */
hr_utility.trace('The value of l_asgchk_flag after all check '||l_asgchk_flag);
 if l_asgchk_flag = 'Y'  then

    l_flag :='Y';
    l_cnt_flag := 'N';

     hr_utility.trace('The hire date is '||to_char(l_hire_date,'YYYY-MM-DD'));
     open cur_emp_prov(l_loc_id);
     fetch cur_emp_prov
     into  l_province;
        if cur_emp_prov%notfound then
           l_province := '-99';
        end if;
     hr_utility.trace('the province value is '||l_province||'for location id'||l_loc_id||'Naics code '||l_naics_no);
     close cur_emp_prov;

     open cur_emp_cma(l_loc_id);
     fetch cur_emp_cma
     into  l_cma_code;
        if cur_emp_cma%notfound then
	     l_cma_code := '-99';
        end if;
     close  cur_emp_cma;

    if p_naic_code is null then
       open   cur_naic_code(l_keyflex_id);
       fetch  cur_naic_code
       into   l_naics_no;
          if cur_naic_code%notfound then
             l_naics_no := '-999';
          else
             l_naics_no := lpad(l_naics_no,4,'0');
          end if;
       close  cur_naic_code;

       hr_utility.trace('The NAIC code for GRE is '||l_naics_no);
    else
   /* Added by ssmukher for Bug 4501549 */
       open   cur_naic_code(l_keyflex_id);
       fetch  cur_naic_code
       into   l_naics_no;
          if cur_naic_code%found then
             l_naics_no := lpad(l_naics_no,4,'0');
          else
             l_naics_no := lpad(p_naic_code,4,'0');
          end if;
       close  cur_naic_code;
    end if;

/* Code for reporting the employees in Exception file for Missing Information
   into the table */

    if l_province = -99 then
       l_flag :='N';
    end if;

    if  l_naics_no = '-999' then
        l_flag :='N';
    end if;

    if l_cma_code = '-99' then
       l_flag :='N';
    end if;

    if l_employment_category = '-1' then
       l_flag := 'N';
    end if;


     open c_total_salary(l_personid);
     fetch c_total_salary
     into  l_salary;
        if c_total_salary%notfound then
	     l_salary := 0;
        end if;
     close c_total_salary;

    if l_salary = 0 then
         l_flag := 'N';
    end if;

/* Storing the employee records with incomplete information for generating
   the exception report */

   if l_flag = 'N'  then
      l_excep_cnt := l_excep_cnt + 1;
      insert into
      per_ca_ee_report_lines (REQUEST_ID ,
                              LINE_NUMBER,
                              CONTEXT,
                              SEGMENT1,
                              SEGMENT2,
                              SEGMENT3,
                              SEGMENT4,
                              SEGMENT5,
                              SEGMENT6)
                     select   30,
                              l_excep_cnt,
                              'EXCEP',
                              l_emp_no,
                              decode(l_province,'-99','Province Code'),
                              decode(l_naics_no ,'-999','NAIC Code'),
                              decode (l_cma_code,'-99','CMA Code'),
                              decode (l_employment_category,'-1','Employment Category'),
                              decode(l_salary,0,'Salary')
                     from     dual;

   end if;

 if l_employment_category in ('01','02') then
   begin
     open cur_term_date( l_personid,v_year_start,v_year_end);
     fetch cur_term_date
     into  l_term_date,
           l_end_dt;
     if cur_term_date%found then
        l_cnt_flag := 'Y';
     end if;
     close  cur_term_date;
   exception
        when others then
            l_term_date := null;
            l_end_dt := null;
            close cur_term_date;
   end ;
 end if;

 /* Inserting the Temporary Employee record into the table */
 /* Checking firstly if the employee details are correct */
 /* Added by ssmukher in v115.1 */
  if l_flag = 'Y' then
   if  l_employment_category = '03' then
    l_tmp_cnt := 0;
    open cur_temp_term_date( l_personid,v_year_start,v_year_end);
    loop

     fetch cur_temp_term_date
     into  l_start_date,
           l_term_date,
           l_end_dt;
     if cur_temp_term_date%found then
        l_cnt_flag := 'Y';
     else
        exit;
     end if;

      if l_cnt_flag = 'Y' then
        l_tmp_cnt := l_tmp_cnt + 1;
      end if;
       insert into
       per_ca_ee_report_lines (REQUEST_ID ,
                               LINE_NUMBER,
                               CONTEXT,
                               SEGMENT1,
                               SEGMENT2,
                               SEGMENT3,
                               SEGMENT4)
                   values     (10,
                               l_tmp_cnt,
                               'TMP',
                               l_emp_no,
                               to_char(l_start_date,'YYYY/MM/DD'),
                               to_char(l_end_dt,'YYYY/MM/DD'),
                               to_char(l_term_date,'YYYY/MM/DD'));
     end loop;
     close cur_temp_term_date;
    end if;
   end if;
   if l_flag = 'Y' then
     if l_employment_category in ('01','02') then
         l_output_txt  :=  l_emp_no|| fnd_global.local_chr(9)||l_cma_code||fnd_global.local_chr(9)||l_province ||fnd_global.local_chr(9)
                           ||l_noc_code||fnd_global.local_chr(9)||l_naics_no||fnd_global.local_chr(9)||l_employment_category
                           ||fnd_global.local_chr(9)||fnd_global.local_chr(9)||l_gender||fnd_global.local_chr(9)||l_last_name
                           ||fnd_global.local_chr(9)||l_first_name||fnd_global.local_chr(9)||l_salary||fnd_global.local_chr(9)
                           ||l_desg_abor||fnd_global.local_chr(9)||l_desg_vminor||fnd_global.local_chr(9)||l_desg_disab
                           ||fnd_global.local_chr(9)||to_char(l_hire_date,'YYYY/MM/DD')||fnd_global.local_chr(9)
                           ||to_char(l_term_date,'YYYY/MM/DD')||fnd_global.local_chr(9)||fnd_global.local_chr(9)
                           ||fnd_global.local_chr(9)||fnd_global.local_chr(9);
     else

       if l_tmp_cnt > 0 then
         l_output_txt  :=  l_emp_no|| fnd_global.local_chr(9)||l_cma_code||fnd_global.local_chr(9)||l_province
                           ||fnd_global.local_chr(9)||l_noc_code||fnd_global.local_chr(9)||l_naics_no||fnd_global.local_chr(9)
                           ||l_employment_category||fnd_global.local_chr(9)||fnd_global.local_chr(9)
                           ||l_gender||fnd_global.local_chr(9)||l_last_name || fnd_global.local_chr(9)||l_first_name
                           ||fnd_global.local_chr(9)||l_salary||fnd_global.local_chr(9)||l_desg_abor||fnd_global.local_chr(9)||l_desg_vminor
                           ||fnd_global.local_chr(9)||l_desg_disab||fnd_global.local_chr(9)||to_char(l_hire_date,'YYYY/MM/DD')
                           ||fnd_global.local_chr(9)||fnd_global.local_chr(9)||fnd_global.local_chr(9)||fnd_global.local_chr(9)
                           ||fnd_global.local_chr(9)||fnd_global.local_chr(9)||to_char(l_tmp_cnt,'09');
       else
                  l_output_txt  :=  l_emp_no|| fnd_global.local_chr(9)||l_cma_code||fnd_global.local_chr(9)||l_province
                           ||fnd_global.local_chr(9)||l_noc_code||fnd_global.local_chr(9)||l_naics_no
                           ||fnd_global.local_chr(9)||l_employment_category||fnd_global.local_chr(9)||fnd_global.local_chr(9)
                           ||l_gender||fnd_global.local_chr(9)||l_last_name || fnd_global.local_chr(9)||l_first_name
                           ||fnd_global.local_chr(9)||l_salary||fnd_global.local_chr(9)||l_desg_abor||fnd_global.local_chr(9)||l_desg_vminor
                           ||fnd_global.local_chr(9)||l_desg_disab||fnd_global.local_chr(9)||to_char(l_hire_date,'YYYY/MM/DD')
                           ||fnd_global.local_chr(9)||fnd_global.local_chr(9)||fnd_global.local_chr(9)||fnd_global.local_chr(9)
                           ||fnd_global.local_chr(9)||fnd_global.local_chr(9);
       end if;
     end if;

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_output_txt);
   end if;


/* Inserting the Promotion details in the table */
begin
  l_promo_cnt := 0;
  hr_utility.trace('The value of  the person id is '||l_personid);
  /* Added by ssmukher in v115.1 */
  /* Checking firstly if the employee details are correct */
  if l_flag = 'Y' then

   open c_promo(l_personid,
                v_year_start,
                v_year_end);

   loop

     fetch c_promo
     into  l_asg_id,
           l_promo_date ;

     if c_promo%notfound then
         exit;
     end if;
       l_promo_cnt := l_promo_cnt + 1;

       insert into
       per_ca_ee_report_lines (REQUEST_ID ,
                               LINE_NUMBER,
                               CONTEXT,
                               SEGMENT1,
                               SEGMENT2)
                   values     (20,
                               l_promo_cnt,
                               'PROMO',
                               l_emp_no,
                               to_char(l_promo_date,'YYYY/MM/DD'));

   end loop;
   close c_promo;
   hr_utility.trace('The Person id is '||l_personid);
   l_promo_no := PER_FASTFORMULA_EVENTS_UTILITY.per_fastformula_event('PROMOTION',
                                                                      'Promotion',
                                                                       p_business_group_id,
                                                                       l_personid,
                                                                       v_year_start,
                                                                       v_year_end,
                                                                       table_date);
  end if;

 hr_utility.trace('The value of promotion number is '||l_promo_no);
 hr_utility.trace('The first record in the plsql table is '||nvl(table_date.count,0));
 hr_utility.trace('The person_id been checked is '||l_personid);

if l_flag = 'Y' then
   if l_promo_no <>  0 then

     for i in nvl(table_date.first,0)..nvl(table_date.last,-1)
     loop
         hr_utility.trace('Inside the PLSQl table ');
         hr_utility.trace('The value of the date fetched is '||table_date(i));
         l_promo_cnt := l_promo_cnt + 1;
          insert into
          per_ca_ee_report_lines (REQUEST_ID ,
                                  LINE_NUMBER,
                                  CONTEXT,
                                  SEGMENT1,
                                  SEGMENT2)
                           values (20,
                                  l_promo_cnt,
                                  'PROMO',
                                  l_emp_no,
                                  to_char(table_date(i),'YYYY/MM/DD'));
     end loop;
   end if;
end if;
end;
 end if; /* Added by ssmukher for Bug No 4493278 */
   end loop;

hr_utility.trace('Outside the cur_emp_categ cursor ');
close cur_emp_categ_person;


COMMIT;
End;


/**************** End of Procedure   ******************************/

/************* Start of procedure emp_promotion *******************/
procedure emp_promotions (errbuf             out nocopy varchar2,
                          retcode            out nocopy number,
                          p_business_group_id in number,
                          p_year             in varchar2,
                          p_naic_code        in varchar2,
                          p_start_date       in date,
                          p_end_date         in date ) is

cursor c_promo_details is
select  to_number(segment1) emp_no,
        segment2 promo_dt
from    per_ca_ee_report_lines pcer
where   pcer.context = 'PROMO' and
        pcer.request_id = 20
order by emp_no,promo_dt;

l_emp_no per_all_people_f.employee_number%type;
l_prev_emp  per_all_people_f.employee_number%type;
l_promo_dt  varchar2(10);
l_promo_cnt number;
l_output varchar2(1000);
begin
       l_prev_emp := -999;
       open c_promo_details;
       loop
          fetch c_promo_details
          into  l_emp_no,
                l_promo_dt;
          if c_promo_details%notfound then
             exit;
          end if;
          if l_prev_emp <> l_emp_no then
             l_promo_cnt := 1;
          else
             l_promo_cnt := l_promo_cnt + 1;
          end if;
          l_output := l_emp_no ||fnd_global.local_chr(9)||l_promo_cnt || fnd_global.local_chr(9) || l_promo_dt;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_output);
          l_prev_emp := l_emp_no;
      end loop;
/* Deleteing the promotion records from per_ca_ee_report_lines table */
   delete from
   per_ca_ee_report_lines
   where request_id = 20 and context = 'PROMO';
   commit;
end ;
/*************** End of Procedure to print the Promotion details list *****/

/*************** Start of Procedure to print the terminated employee list *****/
procedure count_term(errbuf      out nocopy varchar2,
                     retcode     out nocopy number,
                     p_business_group_id in number,
                     p_year      in varchar2,
                     p_naic_code in varchar2) is

cursor c_term_details is
select  to_number(segment1) emp_no,
        segment2 start_dt,
        segment3 end_dt,
        segment4 term_dt
from    per_ca_ee_report_lines pcer
where   pcer.context = 'TMP' and
        pcer.request_id = 10
order by emp_no;

l_emp_no per_all_people_f.employee_number%type;
l_term_cnt  number;
l_start_dt  varchar2(10);
l_end_dt    varchar2(10);
l_term_dt   varchar2(10);
l_output varchar2(1000);
l_prev_emp per_all_people_f.employee_number%type;
BEGIN
     l_prev_emp := -999;
     open c_term_details;
     loop
         fetch c_term_details
         into  l_emp_no ,
               l_start_dt,
               l_end_dt ,
               l_term_dt;
	 if  c_term_details%notfound then
	     exit;
	 end if;

         if l_term_dt is not null then
            if l_emp_no <> l_prev_emp then
               l_term_cnt :=  1;
            else
               l_term_cnt := l_term_cnt + 1;
            end if;
         else

            l_term_cnt := 0;
         end if;
         if l_term_cnt > 0 then
           if l_end_dt <> l_term_dt then
             l_output := l_emp_no ||fnd_global.local_chr(9)||l_term_cnt||fnd_global.local_chr(9)||l_start_dt
                         ||fnd_global.local_chr(9)||l_end_dt||fnd_global.local_chr(9)||l_term_dt;
	   else
	     l_output := l_emp_no ||fnd_global.local_chr(9)||l_term_cnt||fnd_global.local_chr(9)
                         ||l_start_dt||fnd_global.local_chr(9)||l_end_dt;
	   end if;
         else
           l_output := l_emp_no ||fnd_global.local_chr(9)||fnd_global.local_chr(9)||l_start_dt||fnd_global.local_chr(9)
                       ||l_end_dt||fnd_global.local_chr(9)||l_term_dt;
         end if;
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_output);
         l_prev_emp := l_emp_no;
     end loop;
/* Deleting the temporary employee records from the per_ca_ee_report_lines table */
     delete from
     per_ca_ee_report_lines
     where request_id = 10 and context ='TMP';
     commit;
END ;


/*************** End of Procedure to print the terminated employee list *****/

/*************** Procedure to print the exception report ******************/

procedure excep_report(errbuf           out nocopy varchar2,
                       retcode          out nocopy number,
                       p_business_group_id in number,
                       p_year  in varchar2,
                       p_naic_code in varchar2) is

cursor c_excep_report is
select to_number(segment1) emp_no,
       segment2 prov,
       segment3 naic,
       segment4 cma,
       segment5 emp_catg,
       segment6 sal
from   per_ca_ee_report_lines pcer
where  pcer.request_id =  30 and
       pcer.context = 'EXCEP'
order by emp_no;
l_emp_no per_all_people_f.employee_number%type;
l_prov  varchar2(20);
l_naic  varchar2(20);
l_cma   varchar2(20);
l_emp_catg varchar2(20);
l_sal varchar2(10);
l_flag char(1);
l_output varchar2(1000);
l_count  number;
begin
   --  hr_utility.trace_on(null,'Exception');
     l_flag := 'N';
     open c_excep_report;
     loop
         fetch c_excep_report
         into  l_emp_no,
               l_prov,
               l_naic,
               l_cma,
               l_emp_catg,
               l_sal;
	 if c_excep_report%notfound then
	    exit;
	 end if;
         l_count := 0;
         hr_utility.trace('The value of Employee number is '||l_emp_no);
         l_output := 'Following information are  missing for Employee :'||l_emp_no;
	 if l_prov is not null then
            l_count := l_count + 1;
            l_output := l_output ||fnd_global.local_chr(9)||l_count||')'|| l_prov;
            l_flag := 'Y';
	 end if;

	 if l_naic is not null then
            l_count := l_count + 1;
            l_output := l_output ||fnd_global.local_chr(9)||l_count||')'|| l_naic;
            l_flag := 'Y';
	 end if;

	 if l_cma is not null then
            l_count := l_count + 1;
            l_output := l_output ||fnd_global.local_chr(9)||l_count||')'|| l_cma;
            l_flag :='Y';
	 end if;

	 if l_emp_catg is not null then
            l_count := l_count + 1;
            l_output := l_output || fnd_global.local_chr(9)||l_count||')'||l_emp_catg;
	 end if;

	 if l_sal is not null then
            l_count := l_count + 1;
            l_output := l_output ||fnd_global.local_chr(9)||l_count||')'|| l_sal;
	 end if;

         if  l_flag = 'Y' then
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_output);
         end if;
      end loop;
     close c_excep_report;
/* Delete the Exception employee records from the Temporary tables */
     delete from
     per_ca_ee_report_lines
     where request_id = 30 and
           context = 'EXCEP';
     commit;
end;


/* End Of package */
End;

/
