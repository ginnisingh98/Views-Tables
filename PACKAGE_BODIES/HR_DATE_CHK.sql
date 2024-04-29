--------------------------------------------------------
--  DDL for Package Body HR_DATE_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DATE_CHK" as
/* $Header: pehchchk.pkb 120.1 2006/01/13 13:52:37 irgonzal noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_date_chk  (BODY)

 Description : This package declares procedures required to test when
               the period of service and application start dates changes
               are valid. If they are valid then database items which
               must have the same dates are updated.
*/
/*
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    23-MAY-93 Tmathers             Date Created
 70.1    01-JUN-93 Tmathers             Changed updates to Per_people_f.
 70.4    18-OCT-93 TMathers             Changed updates to per_people_f to
 80.1                                   update all rows for a person rather than
                                        those affected by start and end dates.
 70.5    21-DEC-93 PShergill            Improved speed of check_for_entries
 70.6    18-FEB-94 TMathers             Fixed BUG B385.
 70.7    14-JUL-94 TMathers             Fixed BUG WW225779 and 225558
 70.9    23-Oct-94 TMathers             Fixed BUG WW245159.
                                        Added extrajoin to check_for_entries
                                        to stop errors when entries exist
                                        between new and old hire dates.
 70.10   15-Feb-95 TMathers             Fixed BUG WW264072 , added extra check
                                        to check_sp_placements, and added
                                        spinal points to lock_row
                                       and update hire rows.
 70.11   29-APR-95 TMathers   275487    Added check for supervisor/Payroll
                              276867    not existing, removed check_for_entries
                                        when changing hire date.
 70.12   13-Jul-95 TMathers             Added check_for_cost_alloc for
                              292807
 70.13   25-JUL-95 AForte		Changed tokenised message
					HR_7474_EMP_SUP_PAY_NOT_EXIST
					to hard coded messages
					HR_7679_EMP_SUP_PAY_NOT_EXIST and
					HR_7680_EMP_SUP_PAY_NOT_EXIST
 70.14   19-Sep-95 TMathers             Fixed 308000 removed select
                                        and join on minimum date.
 70.16   25-Nov-96 VTreiger   401587	Added check for completed payroll
 					actions beteween the old and new hire dates.
 			      399253	Added check for contiguous periods
 			      		of service.
 70.17   27-Jan-97 VTreiger   399253    Check for contiguous periods of
                                        service now works for any change of
                                        the hire date value.
 110.1   28-JUL-97 Mbocutt    N/A       Changed to use language independent
					date format mask in check_for_contig_pos
 110.2   14-Oct-97 rfine      563034    Changed modified table names to
                                        include _ALL

 110.3   06-nov-97 achauhan             Added the update of the tax tables in the
                                        update_hire_records, in case of 'US Payroll'
                                        installed and change in hire date.

 110.5  8-MAY-1998 SASmith              Due to the date tracking of per_assignment_budget_values_f.
                                        Add the update to this table in case there are changes in the
                                        hire date then there will be a required change in the
                                        assignment budget values.

 110.6  22-MAY-98 Asahay     638603     modified update_hire_records
                                        to update per_applications table
                                        with DATE_END for those applicants
                                        who are hired as EMPLOYEE and not
                                        EMPLOYEE and APPLICANT.

 110.7  23-MAR-99 F.Duchene             Added a call to hr_contract_api.maintain_contracts
                                        in update_hire_records and update_appl_records
                                        to keep CTR start-dates in synch with PER and ASG

 110.8  29-FEB-2000 tclewis             removed check to determine if payroll is installed.
                                        this check is now performed in the
                                        pay_us_emp_dt_tax_rules.default_tax_with_validation
                                        procedure.

 115.7  02-SEP-2002 vramanai 2403885    Modified the cursor defination of 'pay' to enhance the
                                        performance of the query.

 115.8  23-MAY-2003 vramanai 2947287    Modified the cursor app in procedure update_hire_records
 				        to fetch only those records which donot have
 				        current_applicant_flag set

 115.9  26-MAY-2003 vramanai 2947287  	Corrected gscc warnings.
 115.10 13-Jan-2006 irgonzal 4894555    Perf changes. Modified update statement in
                                        update_appl_records procedure.


*/
procedure lock_row(p_person_id NUMBER
                   ,p_person_type VARCHAR2) is
l_dummy VARCHAR2(30);
cursor add is
    select 'address'
    from per_addresses pa
    where pa.person_id = p_person_id
    for update of person_id;
cursor pay is
    select 'pay'
    from pay_personal_payment_methods_f pa
    where   pa.assignment_id IN (select a.assignment_id
	    from per_assignments_f a
	    where a.assignment_type = 'E'
	    and   a.person_id = p_person_id)
    for update of pa.assignment_id;
--
cursor ssp is
select 'ssp'
from   per_spinal_point_placements_f sp
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = 'E')
for update of effective_start_date;
--
cursor cost is
select 'cost'
from   pay_cost_allocations_f cost
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = 'E')
for update of effective_start_date;
--
cursor ass is
    select 'assignment'
    from per_assignments_f pa
    where pa.person_id = p_person_id
    for update of person_id;
cursor app is
    select 'application'
    from per_applications pa
    where pa.person_id = p_person_id
    for update of person_id;
cursor per is
    select 'person'
    from per_people_f pa
    where pa.person_id = p_person_id
    for update of person_id;
begin
  hr_utility.set_location('hr_date_chk.lock_row',1);
  open add;
  loop
   fetch add into l_dummy;
   exit when add%NOTFOUND;
   end loop;
  close add;
--
hr_utility.set_location('hr_date_chk.lock_row',2);
  if (p_person_type = 'E') then
   begin
    open pay;
    loop
     fetch pay into l_dummy;
     exit when pay%NOTFOUND;
     end loop;
    close pay;
   end;
   begin
    open ssp;
    loop
     fetch ssp into l_dummy;
     exit when ssp%NOTFOUND;
     end loop;
    close ssp;
   end;
   begin
    open cost;
    loop
     fetch cost into l_dummy;
     exit when cost%NOTFOUND;
     end loop;
    close cost;
   end;
  end if;
--
hr_utility.set_location('hr_date_chk.lock_row',3);
  open ass;
  loop
   fetch ass into l_dummy;
   exit when ass%NOTFOUND;
   end loop;
   if ass%ROWCOUNT < 1 then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE', 'lock_row');
     hr_utility.set_message_token('STEP', '1');
     hr_utility.raise_error;
   end if;
  close ass;
--
hr_utility.set_location('hr_date_chk.lock_row',4);
  open app;
  loop
   fetch app into l_dummy;
   exit when app%NOTFOUND;
   end loop;
  close app;
--
hr_utility.set_location('hr_date_chk.lock_row',5);
  open per;
  loop
   fetch per into l_dummy;
   exit when per%NOTFOUND;
   end loop;
   if per%ROWCOUNT < 1 then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE', 'lock_row');
     hr_utility.set_message_token('STEP', '2');
     hr_utility.raise_error;
   end if;
  close per;
--
end;
------------------------- BEGIN :check_for_compl_actions -----------------
procedure check_for_compl_actions(p_person_id NUMBER
                        ,p_s_start_date DATE
                        ,p_start_date DATE) is
l_act_chk VARCHAR2(1) := 'N';
begin
-- VT 11/22/96 #401587 check previous completed actions
    BEGIN
      SELECT 'Y'
      INTO l_act_chk
      FROM sys.dual
      WHERE EXISTS
        (SELECT NULL
         FROM pay_payroll_actions pac,
              pay_assignment_actions act,
              per_assignments_f asg
         WHERE asg.person_id = p_person_id
           AND act.assignment_id = asg.assignment_id
           AND pac.payroll_action_id = act.payroll_action_id
           AND pac.action_status = 'C'
           AND ((pac.effective_date BETWEEN p_s_start_date AND p_start_date)
            OR  (pac.date_earned BETWEEN p_s_start_date AND p_start_date)));
      EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
    END;
    IF l_act_chk = 'Y' THEN
        hr_utility.set_message(801,'HR_51810_EMP_COMPL_ACTIONS');
        hr_utility.raise_error;
    END IF;
--
end;
--
------------------------- BEGIN :check_for_contig_pos --------------------
procedure check_for_contig_pos(p_person_id NUMBER
                        ,p_s_start_date DATE
                        ,p_start_date DATE) is
-- VT 11/25/96 #399253
l_action_chk VARCHAR2(1) := 'N';
l_prev_end_date DATE;
l_date_start DATE;
l_act_term_date DATE;
--
cursor pps
is
select date_start
  ,actual_termination_date
from per_periods_of_service
WHERE PERSON_ID = P_PERSON_ID
ORDER BY date_start;
--
begin
    l_action_chk := 'N';
    BEGIN
      OPEN pps;
      l_prev_end_date := to_date('01/01/0001','DD/MM/YYYY');
      LOOP
         FETCH pps INTO l_date_start,l_act_term_date;
         EXIT WHEN pps%NOTFOUND;
         IF (l_date_start - 1 = l_prev_end_date) AND
            (p_s_start_date = l_date_start) THEN
           l_action_chk := 'Y';
           EXIT;
         END IF;
         l_prev_end_date := l_act_term_date;
      END LOOP;
      CLOSE pps;
      IF l_action_chk = 'Y' THEN
        hr_utility.set_message(801,'HR_51811_EMP_CONTIG_POS');
        hr_utility.raise_error;
      END IF;
    END;
end;
--
------------------------- BEGIN :check_supe_pay --------------------------
procedure check_supe_pay(p_period_of_service_id NUMBER
                        ,p_start_date DATE) is
l_payroll_id number;
l_supervisor_id number;
l_temp varchar2(1);
--
-- Cannot move start date if there are assignment changes
-- only need to test the first assignment  row
--
cursor assignment is
select a.payroll_id , a.supervisor_id
from   per_assignments_f a,
       per_periods_of_service p
where  a.period_of_service_id = p.period_of_service_id
and    p.period_of_service_id = p_period_of_service_id
and    p.date_start = a.effective_start_date;
--
begin
  open assignment;
   fetch assignment into l_payroll_id,l_supervisor_id;
  close assignment;
  --
  if l_payroll_id is not null then
    begin
     select '1'
     into l_temp
     from   sys.dual
     where exists ( select payroll_id
                    from pay_payrolls_f
                    where payroll_id = l_payroll_id
                    and p_start_date between
                     effective_start_date and effective_end_date
                   );
     exception
       when no_data_found then
        hr_utility.set_message('801','HR_7679_EMP_SUP_PAY_NOT_EXIST');
        hr_utility.raise_error;
    end;
  end if;
  if l_supervisor_id is not null then
    begin
     select '1'
     into l_temp
     from   sys.dual
     where exists ( select person_id
                    from per_people_f
                    where person_id = l_supervisor_id
                    and   current_employee_flag = 'Y'
                    and  p_start_date between
                     effective_start_date and effective_end_date
                  );
     exception
       when no_data_found then
        hr_utility.set_message('801','HR_7680_EMP_SUP_PAY_NOT_EXIST');
        hr_utility.raise_error;
    end;
  end if;
end;
--
------------------------- BEGIN : check_for_entries --------------------------
procedure check_for_entries (p_person_id NUMBER
                            ,p_period_of_service_id NUMBER
                            ,p_start_date DATE) is
v_dummy number;
begin
    hr_utility.set_location('hr_date_chk.check_for_entries',1);
    select 1
    into   v_dummy
    from sys.dual
    where exists (select null
                  from   pay_element_entries_f n,
                         per_periods_of_service p,
                         per_assignments_f a
                  where a.person_id = p_person_id
                  and   a.period_of_service_id = p_period_of_service_id
                  and   p.period_of_service_id = p_period_of_service_id
                  and   n.assignment_id = a.assignment_id
                  and   n.effective_start_date > p.date_start
                  and   n.effective_start_date < p_start_date);
    hr_utility.set_message(801,'HR_6836_EMP_REF_DATE_CHG');
    hr_utility.raise_error;
--
   exception
     when NO_DATA_FOUND then null;
     when others then raise;
end;
--
------------------------- BEGIN : check_for_sp_placements ---------------------
procedure check_for_sp_placements(p_person_id NUMBER
                            ,p_period_of_service_id NUMBER
                            ,p_start_date DATE) is
v_dummy number;
--
begin
   hr_utility.set_location('hr_date_chk.check_sp_placement',1);
   select 1
   into   v_dummy
   from sys.dual
    where exists (select 1
                 from per_spinal_point_placements_f sp,
                      per_periods_of_service p,
                      per_assignments_f a
                  where a.person_id = p_person_id
                  and   a.period_of_service_id = p_period_of_service_id
                  and   p.period_of_service_id = p_period_of_service_id
                  and   a.assignment_id = sp.assignment_id
                  and   sp.effective_start_date > p.date_start
                  and   sp.effective_start_date < p_start_date
                );
--
   hr_utility.set_message(801,'HR_6837_EMP_REF_DATE_CHG');
   hr_utility.raise_error;
--
exception
   when NO_DATA_FOUND then null;
   when others then raise;
--
end;
--
------------------------- BEGIN : check_for_cost_alloc ---------------------
procedure check_for_cost_alloc(p_person_id NUMBER
                            ,p_period_of_service_id NUMBER
                            ,p_start_date DATE) is
v_dummy number;
--
begin
   hr_utility.set_location('hr_date_chk.check_sp_placement',1);
   select 1
   into   v_dummy
   from sys.dual
    where exists (select 1
                 from PAY_COST_ALLOCATIONS_F ca,
                      per_periods_of_service p,
                      per_assignments_f a
                  where a.person_id = p_person_id
                  and   a.period_of_service_id = p_period_of_service_id
                  and   p.period_of_service_id = p_period_of_service_id
                  and   a.assignment_id = ca.assignment_id
                  and   ca.effective_start_date > p.date_start
                  and   ca.effective_start_date < p_start_date
                );
--
   hr_utility.set_message(801,'HR_7860_EMP_REF_DATE_CHG');
   hr_utility.raise_error;
--
exception
   when NO_DATA_FOUND then null;
   when others then raise;
--
end;
--
------------------------- BEGIN : check_people_changes -----------------------
procedure check_people_changes(p_person_id NUMBER
                            ,p_earlier_date DATE
                            ,p_later_date DATE
                            ,p_start_date DATE) is
v_dummy number;
--
begin
   hr_utility.set_location('hr_date_chk.check_people_changes',1);
   select 1
   into   v_dummy
   from sys.dual
   where exists (select 1
		 from per_people_f p
		 where p.effective_start_date between p_earlier_date
					      and     p_later_date
		 and   p.effective_start_date <> p_start_date
		 and p.person_id = p_person_id
		);
--
   hr_utility.set_message(801,'HR_6841_EMP_REF_DATE_CHG');
   hr_utility.raise_error;
--
exception
   when NO_DATA_FOUND then null;
   when others then raise;
--
end;
--
------------------------- BEGIN : check_for_ass_st_chg -----------------------
procedure check_for_ass_st_chg(p_person_id NUMBER
                            ,p_earlier_date DATE
                            ,p_later_date DATE
                            ,p_assignment_type VARCHAR2
                            ,p_start_date DATE) is
v_dummy number;
--
begin
   hr_utility.set_location('hr_date_chk.check_for_ass_st_chg',1);
   select 1
   into   v_dummy
   from sys.dual
   where exists (select 1
		 from per_assignments a
		 ,per_assignments_f f
		 where f.effective_start_date between  p_earlier_date
					       and     p_later_date
		 and   f.effective_start_date <> p_start_date
		 and   f.assignment_id = a.assignment_id
		 and   a.assignment_type = p_assignment_type
		 and   f.assignment_status_type_id <>
                       a.assignment_status_type_id
                 and f.person_id = a.person_id
		 and   a.person_id = p_person_id
		);
--
   hr_utility.set_message(801,'HR_6838_EMP_REF_DATE_CHG');
   hr_utility.raise_error;
--
exception
   when NO_DATA_FOUND then null;
   when others then raise;
--
end;
--
------------------------- BEGIN : check_for_ass_chg --------------------------
procedure check_for_ass_chg(p_person_id NUMBER
                            ,p_earlier_date DATE
                            ,p_later_date DATE
                            ,p_assignment_type VARCHAR2
                            ,p_s_start_date DATE
                            ,p_start_date DATE) is
v_dummy number;
--
begin
   hr_utility.set_location('hr_date_chk.check_for_ass_chg',1);
   select 1
   into   v_dummy
   from sys.dual
   where exists (select 1
		 from per_assignments_f f
		 where f.effective_start_date between  p_earlier_date
					       and     p_later_date
		 and   f.effective_start_date <> p_s_start_date
--		 and   f.assignment_type =p_assignment_type
		 and   f.person_id = p_person_id
		);
--
   hr_utility.set_message(801,'HR_6839_EMP_REF_DATE_CHG');
   hr_utility.raise_error;
--
exception
   when NO_DATA_FOUND then null;
   when others then raise;
--
end;
------------------------- BEGIN : check_for_prev_emp_ass ----------------------
procedure check_for_prev_emp_ass(p_person_id NUMBER
                            ,p_assignment_type VARCHAR2
                            ,p_s_start_date DATE
                            ,p_start_date DATE) is
v_dummy number;
--
begin
   hr_utility.set_location('hr_date_chk.check_for_prev_emp_ass',1);
   select 1
   into   v_dummy
   from sys.dual
   where exists (select 1
		 from per_assignments_f f
		 where f.effective_start_date >= p_start_date
		 and   f.effective_start_date < p_s_start_date
		 and   f.assignment_type =p_assignment_type
		 and   f.person_id = p_person_id
		);
--
   hr_utility.set_message(801,'HR_6840_EMP_ENTER_PERIOD');
   hr_utility.raise_error;
--
exception
   when NO_DATA_FOUND then null;
   when others then raise;
--
end;
--
------------------------- BEGIN : check_hire_ref_int --------------------------
procedure check_hire_ref_int(p_person_id NUMBER
                            ,p_business_group_id NUMBER
                            ,p_period_of_service_id NUMBER
                            ,p_s_start_date DATE
                            ,p_system_person_type VARCHAR2
                            ,p_start_date DATE) is
l_earlier_date DATE;
l_assignment_type VARCHAR2(1);
l_later_date DATE;
--
begin
   l_assignment_type:='E';
   l_later_date:=p_start_date;
   l_earlier_date:=p_s_start_date;
   hr_utility.set_location('hr_date_chk.check_hire_ref_int',1);
--
   if p_start_date > p_s_start_date then
-- VT 11/27/96 #401587
      hr_date_chk.check_for_compl_actions(p_person_id
                         ,p_s_start_date
                         ,p_start_date);
--
-- VT 11/27/96 #399253
      hr_date_chk.check_for_contig_pos(p_person_id
                         ,p_s_start_date
                         ,p_start_date);
--
      hr_date_chk.check_supe_pay(p_period_of_service_id
                         ,p_start_date);
--
/*      hr_date_chk.check_for_entries(p_person_id
                         ,p_period_of_service_id
                         ,p_start_date); */
--
      hr_date_chk.check_for_sp_placements(p_person_id
                            ,p_period_of_service_id
                               ,p_start_date);
--
      hr_date_chk.check_for_cost_alloc(p_person_id
                            ,p_period_of_service_id
                               ,p_start_date);
--
      hr_date_chk.check_for_ass_st_chg(p_person_id
                        ,l_earlier_date
                        ,l_later_date
                        ,l_assignment_type
                        ,p_s_start_date);
--
      hr_date_chk.check_people_changes(p_person_id
                            ,l_earlier_date
                            ,l_later_date
                            ,p_s_start_date);
--
      hr_date_chk.check_for_ass_chg(p_person_id
                       ,l_earlier_date
                       ,l_later_date
                       ,l_assignment_type
                       ,p_s_start_date
                     ,p_start_date);
--
   else
-- VT 01/27/97 #399253
      hr_date_chk.check_for_contig_pos(p_person_id
                         ,p_s_start_date
                         ,p_start_date);
--
      l_later_date:=p_s_start_date;
      l_earlier_date:=p_start_date;

--
      hr_date_chk.check_supe_pay(p_period_of_service_id
                         ,p_start_date);
--
      hr_date_chk.check_people_changes(p_person_id
                            ,l_earlier_date
                            ,l_later_date
                            ,p_s_start_date);
--
      hr_date_chk.check_for_ass_chg(p_person_id
                       ,l_earlier_date
                       ,l_later_date
                       ,l_assignment_type
                       ,p_s_start_date
                     ,p_start_date);
--
      hr_date_chk.check_for_prev_emp_ass(p_person_id
                        ,l_assignment_type
                        ,p_s_start_date
                        ,p_start_date);
   end if;
  hr_date_chk.lock_row(p_person_id =>p_person_id
           ,p_person_type =>l_assignment_type);
   exception
      when others then
   raise;
end;
--
------------------------- BEGIN : update_hire_records -------------------------
procedure update_hire_records(p_person_id NUMBER
			  ,p_app_number VARCHAR2
			  ,p_start_date DATE
			  ,p_s_start_date DATE
			  ,p_user_id NUMBER
			  ,p_login_id NUMBER) is
l_assignment_id NUMBER;
l_application_id NUMBER;
l_sp_id NUMBER;
l_ca_id NUMBER;
l_abv_id NUMBER;
l_pps_id NUMBER;
l_business_group_id  number;
l_ret_code           number;
l_ret_text    varchar2(240);


cursor app_ass is
select assignment_id
from   per_assignments_f a
where  a.effective_end_date   = p_s_start_date - 1
and    a.assignment_type      = 'A'
  and    a.person_id            = p_person_id;
--
cursor app is
select application_id
from  per_applications a
where   a.person_id = p_person_id
and     a.date_received = (
select  max(a2.date_received)
from    per_applications a2
where   a2.person_id = a.person_id
and     a2.date_received < p_start_date)
and not exists(select 1                     --bug#2947287
         from per_people_f peo
         where peo.person_id = p_person_id
         and   peo.person_id  = a.person_id
         and   peo.effective_start_date = p_s_start_date
         and   peo.current_applicant_flag = 'Y');
--
cursor ssp is
select placement_id
from   per_spinal_point_placements_f sp
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = 'E'
                         and a.effective_start_date = p_s_start_date)
and    sp.effective_start_date = p_s_start_date;
--
cursor cost is
select COST_ALLOCATION_ID
from   PAY_COST_ALLOCATIONS_F pca
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = 'E'
                         and a.effective_start_date = p_s_start_date)
and    pca.effective_start_date = p_s_start_date;
--
cursor pps
is
select period_of_Service_id
from per_periods_OF_SERVICE
WHERE PERSON_ID = P_PERSON_ID
AND DATE_START = P_S_START_DATE;
--
cursor csr_get_bg is
   select business_group_id
   from   per_people_f
   where person_id = p_person_id
   and rownum < 2;
--
cursor abv is
select ASSIGNMENT_BUDGET_VALUE_ID
from   PER_ASSIGNMENT_BUDGET_VALUES_F abv
where  assignment_id in (select a.assignment_id
                         from per_assignments_f a
                         where person_id = p_person_id
                         and a.assignment_type = 'E'
                         and a.effective_start_date = p_s_start_date)
and    abv.effective_start_date = p_s_start_date;
--

begin
   hr_utility.set_location('hr_date_chk.update_hire_records',1);
   -- Update the addresses that start at the old hire date
   -- Providing that the addresses end date is either equal to
   -- the new start date or greater than it.
   update per_addresses a
   set    a.date_from = p_start_date
   where  a.date_from = p_s_start_date
   and    nvl(a.date_to,p_start_date) >= p_start_date
   and    a.person_id = p_person_id;
--
--
   hr_utility.set_location('hr_date_chk.update_hire_records',2);
   update pay_personal_payment_methods_f p
   set    p.effective_start_date = p_start_date
   where  p.effective_start_date = p_s_start_date
   and    p.effective_end_date >= p_start_date
   and    exists (select 1
	    from per_assignments_f a
	    where p.assignment_id = a.assignment_id
	    and   a.assignment_type = 'E'
	    and   a.person_id = p_person_id);
   begin
     open ssp;
      loop
      fetch ssp into l_sp_id;
      exit when ssp%NOTFOUND;
      update per_spinal_point_placements_f
      set effective_start_date = p_start_date
      where effective_start_date = p_s_start_date
      and   placement_id = l_sp_id;
      if sql%rowcount <1 then
          hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
          hr_utility.set_message_token('TABLE','PER_SPINAL_POINT_PLACEMENTS_F');
          hr_utility.raise_error;
      end if;
     end loop;
    close ssp;
   end;
--
   hr_utility.set_location('hr_date_chk.update_hire_records',3);
   begin
     open cost;
      loop
      fetch cost into l_ca_id;
      exit when cost%NOTFOUND;
      update PAY_COST_ALLOCATIONS_F
      set effective_start_date = p_start_date
      where effective_start_date = p_s_start_date
      and   COST_ALLOCATION_ID = l_ca_id;
      if sql%rowcount <1 then
          hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
          hr_utility.set_message_token('TABLE','PAY_COST_ALLOCATIONS_F');
          hr_utility.raise_error;
      end if;
     end loop;
    close cost;
   end;

   -- Update to assignment budget values required as this is now being date tracked.
   -- This code does not deal with ALL possibilities and assumes that the user has created and
   -- immediately changes the hire date.
   -- If date track updates is used prior to changing the hire date then this may cause erroneous rows
   -- on the database.
   -- This is a wider issue and this code will be left like this until all changes are made.
   -- SASMITH 8-MAY-1998
   --

   hr_utility.set_location('hr_date_chk.update_hire_records',5);
   begin
     open abv;
      loop
      fetch abv into l_abv_id;
      exit when abv%NOTFOUND;

      update PER_ASSIGNMENT_BUDGET_VALUES_F
      set effective_start_date         = p_start_date
      where effective_start_date       = p_s_start_date
      and effective_end_date           >= p_start_date
      and   ASSIGNMENT_BUDGET_VALUE_ID = l_abv_id;

      if sql%rowcount <1 then
          null;
      end if;
     end loop;
    close abv;
   end;

--
   hr_utility.set_location('hr_date_chk.update_hire_records',10);
--
-- BUG 308000 removed select min (effective_date) code
-- and it's reference in following code tm 19-sep-1995.
--
   update per_assignments_f a
   set    a.effective_start_date = p_start_date,
	  a.last_update_date     = sysdate,
	  a.last_updated_by      = p_user_id,
	  a.last_update_login    = p_login_id
   where  a.effective_start_date = p_s_start_date
   and    a.assignment_type      = 'E'
   and    a.person_id            = p_person_id;
--
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
      hr_utility.set_message_token('TABLE','PER_ALL_ASSIGNMENTS_F');
      hr_utility.raise_error;
   end if;
   --
   --
   hr_utility.set_location('hr_date_chk.update_hire_records',12);
   -- keep contracts in synch with PER and ASG :
   hr_contract_api.maintain_contracts
     (p_person_id
     ,p_start_date
     ,p_s_start_date);
   --
--
   hr_utility.set_location('hr_date_chk.update_hire_records',15);
--
-- update the tax records and pull back their effective start date if
-- the defaulting tax criteria is met.

--   Checking if payroll installed is now handled in default_tax_with_validation
--   if  hr_utility.chk_product_install(p_product =>'Oracle Payroll', then
      open csr_get_bg;
      fetch csr_get_bg into l_business_group_id;
      if csr_get_bg%NOTFOUND then
         close csr_get_bg;
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE', 'update_hire_records');
         hr_utility.set_message_token('STEP', '1');
         hr_utility.raise_error;
      end if;
      close csr_get_bg;

      pay_us_emp_dt_tax_rules.default_tax_with_validation(p_assignment_id        => null,
                                  p_person_id            => p_person_id,
                                  p_effective_start_date => p_start_date,
                                  p_effective_end_date   => null,
                                  p_session_date         => null,
                                  p_business_group_id    => l_business_group_id,
                                  p_from_form            => 'Person',
                                  p_mode                 => null,
                                  p_location_id          => null,
                                  p_return_code          => l_ret_code,
                                  p_return_text          => l_ret_text);
--   end if;  --end if payroll_installed


   if p_app_number is not null then
      hr_utility.set_location('hr_date_chk.update_hire_records',20);
      begin
        open app_ass;
         loop
         fetch app_ass into l_assignment_id;
         exit when app_ass%NOTFOUND;
              update per_assignments_f a
               set   a.effective_end_date   = p_start_date - 1,
    	             a.last_update_date     = sysdate,
            	     a.last_updated_by      = p_user_id,
        	     a.last_update_login    = p_login_id
              where  a.effective_end_date   =
        	    (select max(a2.effective_end_date)
        	     from   per_assignments_f a2
        	     where  a2.assignment_id = a.assignment_id
        	     and    a2.assignment_type = 'A')
              and    a.assignment_id        = l_assignment_id;
--
         if sql%rowcount <1 then
            hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
            hr_utility.set_message_token('TABLE','PER_ALL_ASSIGNMENTS_F');
            hr_utility.raise_error;
         end if;
       end loop;
       close app_ass;
--
      end;

   begin
     open app;
     loop
      fetch app into l_application_id;
      exit when app%NOTFOUND;
       update  per_applications a1
       set     a1.date_end = p_start_date - 1
       where   a1.application_id = l_application_id
/* Fix for Bug 673066 */
        and not exists (select 1
                        from per_people_f peo
                        where peo.person_id = p_person_id
                        and   a1.person_id  = peo.person_id
                        and   peo.effective_start_date = p_s_start_date
                        and   peo.current_applicant_flag = 'Y');
/* End fix for Bug 673066 */
--
   hr_utility.set_location('hr_date_chk.update_hire_records',25);

       if sql%rowcount <1 then
          hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
          hr_utility.set_message_token('TABLE','PER_APPLICATIONS');
          hr_utility.raise_error;
       end if;
     end loop;
     close app;
   end;
end if;
--
   hr_utility.set_location('hr_date_chk.update_hire_records',30);
   update per_people_f p
   set p.start_date =decode(p.start_date,p_s_start_date, p_start_date,
                           p.start_date),
   p.effective_start_date =decode(p.effective_start_date,
	       p_s_start_date, p_start_date, p.effective_start_date),
   p.effective_end_date =decode(p.effective_end_date,
	       p_s_start_date - 1, p_start_date - 1, p.effective_end_date),
   p.last_update_date     = sysdate,
   p.last_updated_by      = p_user_id,
   p.last_update_login    = p_login_id
   where p.person_id = p_person_id;
--
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
      hr_utility.set_message_token('TABLE','PER_ALL_PEOPLE_F');
      hr_utility.raise_error;
   end if;
--
end;
--
------------------------- BEGIN : check_apl_ref_int --------------------------
procedure check_apl_ref_int(p_person_id NUMBER
                            ,p_business_group_id NUMBER
                            ,p_system_person_type VARCHAR2
                            ,p_s_start_date DATE
                            ,p_start_date DATE) is

l_assignment_type VARCHAR2(1);
l_earlier_date DATE;
l_later_date DATE;
begin
   l_assignment_type:='A';
   l_later_date:=p_start_date;
   l_earlier_date:=p_s_start_date;
   hr_utility.set_location('hr_date_chk.check_apl_ref_int',1);
--
   if p_start_date > p_s_start_date then
--
      hr_date_chk.check_for_ass_st_chg(p_person_id
                        ,l_earlier_date
                        ,l_later_date
                        ,l_assignment_type
                        ,p_s_start_date);
--
      hr_date_chk.check_people_changes(p_person_id
                            ,l_earlier_date
                            ,l_later_date
                            ,p_s_start_date);
--
      hr_date_chk.check_for_ass_chg(p_person_id
                            ,l_earlier_date
                            ,l_later_date
                     ,l_assignment_type
                     ,p_s_start_date
                     ,p_start_date);
--
   else
--
      l_later_date:=p_s_start_date;
      l_earlier_date:=p_start_date;
--
      hr_date_chk.check_people_changes(p_person_id
                            ,l_earlier_date
                            ,l_later_date
                            ,p_s_start_date);
--
      hr_date_chk.check_for_ass_chg(p_person_id
                            ,l_earlier_date
                            ,l_later_date
                     ,l_assignment_type
                     ,p_s_start_date
                     ,p_start_date);
--
   end if;
   hr_date_chk.lock_row(p_person_id =>p_person_id
           ,p_person_type =>l_assignment_type);
   exception
      when others then raise;
end;
--
------------------------- BEGIN : update_appl_records ------------------------
procedure update_appl_records(p_person_id NUMBER
			  ,p_start_date DATE
			  ,p_s_start_date DATE
			  ,p_user_id NUMBER
			  ,p_login_id NUMBER) is
begin
-- Update the addresses that start at the old hire date
-- Providing that the addresses end date is either equal to
-- the new start date or greater than it.
--
   hr_utility.set_location('hr_date_chk.update_appl_records',1);
   update per_addresses a
   set    a.date_from = p_start_date
   where  a.date_from = p_s_start_date
   and    nvl(a.date_to,p_start_date) >= p_start_date
   and    a.person_id = p_person_id;
--
--
   hr_utility.set_location('hr_date_chk.update_appl_records',2);
   update per_assignments_f a
   set    a.effective_start_date = p_start_date,
          a.last_update_date     = sysdate,
	  a.last_updated_by      = p_user_id,
	  a.last_update_login    = p_login_id
   where  a.effective_start_date   = p_s_start_date
   and    a.assignment_type      = 'A'
   and    a.person_id            = p_person_id
   and    EXISTS  -- #4894555
          (select a2.assignment_id
             from   per_assignments_f a2
             where  a2.assignment_id = a.assignment_id
             and    a2.assignment_type = 'A'
             group by a2.assignment_id
             having max(a2.effective_start_date)=  a.effective_start_date);

--
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
      hr_utility.set_message_token('TABLE','PER_ALL_ASSIGNMENTS_F');
      hr_utility.raise_error;
   end if;
   hr_utility.set_location('hr_date_chk.update_appl_records',3);
--
   update per_people_f p
   set p.start_date =decode(p.start_date,p_s_start_date, p_start_date,
                           p.start_date),
   p.effective_start_date =decode(p.effective_start_date,
			p_s_start_date, p_start_date, p.effective_start_date),
   p.effective_end_date =decode(p.effective_end_date,
	       p_s_start_date - 1, p_start_date - 1, p.effective_end_date),
   p.last_update_date     = sysdate,
   p.last_updated_by      = p_user_id,
   p.last_update_login    = p_login_id
   where p.person_id = p_person_id;
--
   if sql%rowcount <1 then
      hr_utility.set_message(801,'HR_6094_ALL_CANT_UPDATE');
      hr_utility.set_message_token('TABLE','PER_ALL_PEOPLE_F');
      hr_utility.raise_error;
   end if;
   --
   -- keep contracts in synch with PER and ASG :
   hr_contract_api.maintain_contracts
     (p_person_id
     ,p_start_date
     ,p_s_start_date);
   --
end;
end hr_date_chk;


/
