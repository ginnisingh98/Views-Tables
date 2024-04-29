--------------------------------------------------------
--  DDL for Package Body PAY_PL_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PL_UTILITY" as
/* $Header: pyplutil.pkb 120.3 2006/03/01 22:09 mseshadr noship $ */
--------------------------------------------------------------------------------
-- FUNCTION pay_pl_nip_format
--------------------------------------------------------------------------------
FUNCTION pay_pl_nip_format(p_nip IN NUMBER
              ) RETURN VARCHAR2
IS
  l_nip_format VARCHAR2(15);
BEGIN
 if p_nip is not null then
  l_nip_format:= substr(p_nip,1,3)||'-'||substr(p_nip,4,3)||'-'||substr(p_nip,7,2)||'-'||substr(p_nip,9);
 end if;
  return l_nip_format;
exception when others then
return null;
END pay_pl_nip_format;

FUNCTION  pl_get_sii_details(
                          p_assignment_id             number,
                          p_date_earned               date  ,
                          p_payroll_id                number,
                          p_active_term_flag          out nocopy varchar2,
                          p_sii_code                  out nocopy varchar2,
                          p_old_age_contrib           out nocopy varchar2,
                          p_pension_contrib           out nocopy varchar2,
                          p_sickness_contrib          out nocopy varchar2,
                          p_work_injury_contrib       out nocopy varchar2,
                          p_labor_contrib             out nocopy varchar2,
                          p_unemployment_contrib      out nocopy varchar2,
                          p_health_contrib            out nocopy varchar2,
                          p_term_sii_code             out nocopy varchar2,
                          p_term_old_age_contrib      out nocopy varchar2,
                          p_term_pension_contrib      out nocopy varchar2,
                          p_term_sickness_contrib     out nocopy varchar2,
                          p_term_work_injury_contrib  out nocopy varchar2,
                          p_term_labor_contrib        out nocopy varchar2,
                          p_term_unemployment_contrib out nocopy varchar2,
                          p_term_health_contrib       out nocopy varchar2
                                                    ) return number is

cursor csr_payroll_end_date is
  select end_date from per_time_periods where
  payroll_id = p_payroll_id
  and p_date_earned between start_date and end_date;

cursor  csr_date_terminated is
        select paaf1.effective_end_date,nvl(paaf1.payroll_id,-1)
         from  per_all_assignments_f       paaf1,
               per_assignment_status_types past1,
               per_all_assignments_f       paaf2,
               per_assignment_status_types past2,
               pay_all_payrolls_f          papf,
               per_time_periods            ptp
         where past1.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
         and   paaf1.assignment_status_type_id=past1.assignment_status_type_id
         and   paaf1.assignment_id=p_assignment_id
         and   past2.per_system_status ='TERM_ASSIGN'
         and   paaf2.assignment_id=p_assignment_id
         and   paaf2.assignment_status_type_id=past2.assignment_status_type_id
         and   paaf1.effective_end_date+1=paaf2.effective_start_date
         and   paaf2.effective_start_date >ptp.start_date --not >=
         and   paaf2.effective_start_date<=ptp.end_date
         and   papf.payroll_id= paaf2.payroll_id
         and   p_date_earned between papf.effective_start_date and papf.effective_end_date
         and   papf.payroll_id=ptp.payroll_id
         and   p_date_earned between ptp.start_date and ptp.end_date;

--cursor duplicated in pl_get_tax_details
cursor csr_contract_assgt_type(r_date date) is
select kyflx.segment3,past.per_system_status,paaf.person_id
from   hr_soft_coding_keyflex kyflx,
       per_assignment_status_types past,
       per_all_assignments_f paaf
where  paaf.assignment_id=p_assignment_id
 and   r_date between paaf.effective_start_date and paaf.effective_end_date
 and   paaf.soft_coding_keyflex_id=kyflx.soft_coding_keyflex_id
 and   paaf.assignment_status_type_id=past.assignment_status_type_id ;


cursor csr_sii_details(r_per_or_asg_id number,r_contract_category varchar2,r_sii_date date) is
select EMP_SOCIAL_SECURITY_INFO,
       old_age_contribution,
       pension_contribution,
       sickness_contribution,
       work_injury_contribution,
       labor_contribution,
       unemployment_contribution,
       health_contribution

from   pay_pl_sii_details_f
where  per_or_asg_id=r_per_or_asg_id
  and  contract_category=r_contract_category
  and  r_sii_date between effective_start_date and effective_end_date ;

l_contract_category  hr_soft_coding_keyflex.segment3%type;
l_per_system_status  per_assignment_status_types.per_system_status%type;
l_join_variable      pay_pl_sii_details_f.per_or_asg_id%type;
l_date_earned        date;
l_date_terminated    date;
l_payroll_id         number;
l_sii_date           date;
l_person_id          number;
l_assignment_id      number;
l_proc               varchar2(33);
l_period_end_date    date;


begin
l_proc:='PAY_PL_UTILITY.PL_GET_SII_DETAILS';
hr_utility.set_location(l_proc,10);
open csr_payroll_end_date;
fetch csr_payroll_end_date into l_period_end_date;
close csr_payroll_end_date;

--fetch person id.It will be reqd later.person id as a context is not available for Oracle Payroll
--check if assgt is term_assign or is in (active_assign or susp_assign)
open  csr_contract_assgt_type(p_date_earned);
fetch csr_contract_assgt_type into l_contract_category,l_per_system_status,l_person_id;
close csr_contract_assgt_type;



if l_per_system_status<>'TERM_ASSIGN' then
   if  l_contract_category='NORMAL'  then
       l_join_variable:=l_person_id;
   else
       l_join_variable:=p_assignment_id;
   end if;

  p_active_term_flag:= 'YN';


  hr_utility.set_location(l_proc,20);
  open  csr_sii_details(l_join_variable,l_contract_category,l_period_end_date);
  fetch csr_sii_details into p_sii_code,
                             p_old_age_contrib,p_pension_contrib,
                             p_sickness_contrib,
                             p_work_injury_contrib,p_labor_contrib,
                             p_unemployment_contrib,p_health_contrib;

   close csr_sii_details;
   hr_utility.set_location(l_proc,30);



else  --per_system_status =term_assign?

--the employee has been terminated
--check if he was terminated in the current
--payroll period or some other previous period
 hr_utility.set_location(l_proc,40);

  open  csr_date_terminated;
  fetch csr_date_terminated into l_date_terminated,l_payroll_id;

   if   csr_date_terminated%found then
      --employee has been terminated in current period only...
      --so he has both active and term sii details in the tables
       hr_utility.set_location(l_proc,50);
       p_active_term_flag:= 'YY';
       close csr_date_terminated;

        if  l_contract_category='NORMAL'  then
            l_join_variable:=l_person_id;
            open  csr_sii_details(l_join_variable,l_contract_category,l_period_end_date);
            fetch csr_sii_details into p_sii_code,
                                 p_old_age_contrib,p_pension_contrib,
                                 p_sickness_contrib,
                                 p_work_injury_contrib,p_labor_contrib,
                                 p_unemployment_contrib,p_health_contrib;
            close csr_sii_details;

        else
             l_join_variable:=p_assignment_id;
             open  csr_sii_details(l_join_variable,l_contract_category,l_date_terminated);
             fetch csr_sii_details into p_sii_code,
                                        p_old_age_contrib,p_pension_contrib,
                                        p_sickness_contrib,
                                        p_work_injury_contrib,p_labor_contrib,
                                        p_unemployment_contrib,p_health_contrib;
             close csr_sii_details;
         end if;
       --processing finished for active assign in this period
       --before being terminated

      hr_utility.set_location(l_proc,60);

      if l_contract_category='NORMAL' then
         l_contract_category:='TERM_NORMAL';
      end if;
          l_join_variable:=p_assignment_id;

      open  csr_sii_details(l_join_variable,l_contract_category,l_period_end_date);
      fetch csr_sii_details into p_term_sii_code,
                                 p_term_old_age_contrib,p_term_pension_contrib,
                                 p_term_sickness_contrib,
                                 p_term_work_injury_contrib,p_term_labor_contrib,
                                 p_term_unemployment_contrib,p_term_health_contrib;
       close csr_sii_details;

       hr_utility.set_location(l_proc,70);
  else --csr_date_terminated%found ?
       hr_utility.set_location(l_proc,80);
     close csr_date_terminated;
      p_active_term_flag:= 'NY';
    --employee has been terminated in some other period and in this period he has been
    --terminated throughout
          if l_contract_category='NORMAL' then
             l_contract_category:='TERM_NORMAL';
          end if;

           l_join_variable:=p_assignment_id;

           open  csr_sii_details(l_join_variable,l_contract_category,l_period_end_date);
           fetch csr_sii_details into p_term_sii_code,
                                 p_term_old_age_contrib,p_term_pension_contrib,
                                 p_term_sickness_contrib,
                                 p_term_work_injury_contrib,p_term_labor_contrib,
                                 p_term_unemployment_contrib,p_term_health_contrib;
           close csr_sii_details;

          hr_utility.set_location(l_proc,90);
  end if;--csr_date_terminated%found?
end if; --per_system_status =term_assign?
hr_utility.set_location(l_proc,95);
return 1;
Exception
when others then
hr_utility.set_location(l_proc,99);
hr_utility.raise_error;

end pl_get_sii_details; --end of function pl_get_sii_details
-- Start of function Get Rate of Tax
FUNCTION GET_RATE_OF_TAX(p_date_earned    IN DATE,
				 p_taxable_base   IN NUMBER,
				 p_rate_of_tax 	  IN VARCHAR2,
				 p_spouse_or_child_flag IN VARCHAR2,
 				 p_tax_percentage OUT NOCOPY NUMBER) RETURN NUMBER is

cursor csr_level is select ci.value from
	pay_user_column_instances_f ci,
	pay_user_columns c,
	pay_user_rows_f r,
	pay_user_tables t
 where r.user_table_id = t.user_table_id
	and c.user_table_id = t.user_table_id
	and ci.user_row_id = r.user_row_id
	and ci.user_column_id = c.user_column_id
	and t.legislation_code = 'PL'
	and c.user_column_name = 'Level'
	and t.user_table_name = 'PL_NORMAL_TAX'
	and p_date_earned between ci.effective_start_date and ci.effective_end_date
	and round(p_taxable_base,2) between r.row_low_range_or_name and r.row_high_range;

cursor csr_rate_of_tax(p_level number) is select ci.value
from
	pay_user_column_instances_f ci,
	pay_user_column_instances_f cilvl,
	pay_user_rows_f r,
	pay_user_rows_f rlvl,
	pay_user_columns c,
	pay_user_columns clvl,
	pay_user_tables t
where c.user_table_id = t.user_table_id
and r.user_table_id = t.user_table_id
and ci.user_row_id = r.user_row_id
and ci.user_column_id = c.user_column_id
and clvl.user_table_id = t.user_table_id
and rlvl.user_table_id = t.user_table_id
and cilvl.user_row_id = rlvl.user_row_id
and cilvl.user_column_id = clvl.user_column_id
and t.legislation_code = 'PL'
and c.user_column_name = 'Standard'
and t.user_table_name = 'PL_NORMAL_TAX'
and r.row_low_range_or_name = rlvl.row_low_range_or_name
and p_date_earned between ci.effective_start_date and ci.effective_end_date
and p_date_earned between cilvl.effective_start_date and cilvl.effective_end_date
and cilvl.value = p_level;
 l_row_level pay_user_column_instances_f.value%type;

BEGIN
 open csr_level;
  fetch csr_level into l_row_level;
 close csr_level;

 if p_rate_of_tax = 'N02' then
    if l_row_level < 3 then
     l_row_level:= l_row_level +1;
    end if;
 elsif p_rate_of_tax = 'N03' then
    if l_row_level < 2 then
        l_row_level:= l_row_level +1;
    end if;
 elsif p_rate_of_tax = 'N04' then
     l_row_level:= 3;
 end if;

 if p_spouse_or_child_flag = 'Y' then
  if l_row_level > 1 then
      l_row_level:= l_row_level -1;
  end if;
 end if;
 open csr_rate_of_tax(l_row_level);
  fetch csr_rate_of_tax into p_tax_percentage;
 close csr_rate_of_tax;

 return l_row_level;

END GET_RATE_OF_TAX;
-- End of function GET_RATE_OF_TAX
-- Start of function pl_get_tax_details
Function pl_get_tax_details(
                          p_assignment_id                                number,
                          p_date_earned                                  date  ,
                          p_payroll_id                                   number,
                          p_sii_code                          out nocopy varchar2,
                          p_spouse_or_child_flag              out nocopy varchar2,
                          p_income_reduction                  out nocopy varchar2,
                          p_tax_reduction                     out nocopy varchar2,
                          p_income_reduction_amount           out nocopy NUMBER,
                          p_rate_of_tax                       out nocopy varchar2,
                          p_contract_category                 out nocopy varchar2,
                          p_contract_type                     out nocopy varchar2,
                          p_ir_flag                           out nocopy varchar2
                              ) return number is
cursor  csr_payroll_end_date is
 select end_date
  from  per_time_periods
  where payroll_id = p_payroll_id
  and   p_date_earned between start_date and end_date;

cursor  csr_date_terminated is
        select paaf1.effective_end_date terminated_date,nvl(paaf1.payroll_id,-1) payroll_id
         from  per_all_assignments_f       paaf1,
               per_assignment_status_types past1,
               per_all_assignments_f       paaf2,
               per_assignment_status_types past2,
               pay_all_payrolls_f          papf,
               per_time_periods            ptp
         where past1.per_system_status in ('ACTIVE_ASSIGN','SUSP_ASSIGN')
         and   paaf1.assignment_status_type_id=past1.assignment_status_type_id
         and   paaf1.assignment_id=p_assignment_id
         and   past2.per_system_status ='TERM_ASSIGN'
         and   paaf2.assignment_id=p_assignment_id
         and   paaf2.assignment_status_type_id=past2.assignment_status_type_id
         and   paaf1.effective_end_date+1=paaf2.effective_start_date
         and   paaf2.effective_start_date >ptp.start_date --not >=
         and   paaf2.effective_start_date<=ptp.end_date
         and   papf.payroll_id= paaf2.payroll_id
         and   p_date_earned between papf.effective_start_date and papf.effective_end_date
         and   papf.payroll_id=ptp.payroll_id
         and   p_date_earned between ptp.start_date and ptp.end_date;

cursor csr_payroll_run  (r_assignment_id number,r_date date,r_payroll_id number,r_less_than_date date) is
select 'Y' payroll_run,paa.assignment_action_id ,ppa.date_earned
from   pay_payroll_actions         ppa,
       pay_Assignment_actions      paa,
       per_time_periods            ptp,
       pay_all_payrolls_f          papf,
       pay_run_results             prr,
       pay_element_types_f         petf
 where paa.source_action_id is not null
  and  paa.assignment_id=r_assignment_id
  and  paa.action_status='C'
  and  ppa.action_type in ('R','Q')
  and  ppa.payroll_action_id=paa.payroll_action_id
  and  ppa.date_earned between ptp.start_date and ptp.end_date
  and  ptp.payroll_id = r_payroll_id
  and  papf.payroll_id=ptp.payroll_id
  and  r_date  between ptp.start_date and ptp.end_date
  and  ppa.date_earned<=r_less_than_date
  and  prr.assignment_action_id=paa.assignment_action_id
  and  petf.legislation_code='PL'
  and  petf.element_name ='Tax'
  and  r_date between petf.effective_start_date and petf.effective_end_date
  and  prr.status='P'
  and  prr.element_type_id=petf.element_type_id;
  --didnot use order by as
  -- all payroll runs will have same sii code
  --if need arises to order payroll runs,order by ppa.date_earned

cursor csr_run_result_values(r_assignment_action_id number,r_element varchar2) is
  select pivf.name,result_value,petf.element_name
  from pay_run_results        prr,
       pay_run_result_values  prrv,
       pay_element_types_f    petf,
       pay_input_values_f     pivf
 where prr.assignment_action_id=r_assignment_action_id
  and  petf.legislation_code='PL'
  and  pivf.legislation_code='PL'
  and  petf.element_name =r_element
  and  petf.element_type_id=pivf.element_type_id
  and  p_date_earned between pivf.effective_start_date and pivf.effective_end_date
  and  p_date_earned between petf.effective_start_date and petf.effective_end_date
  and  prr.status='P'
  and  prr.element_type_id=petf.element_type_id
  and  prr.run_result_id=prrv.run_result_id
  and  pivf.input_value_id=prrv.input_value_id;

cursor csr_contract_assgt_type(r_date date) is
select kyflx.segment3,kyflx.segment4,past.per_system_status,paaf.person_id
from   hr_soft_coding_keyflex kyflx,
       per_assignment_status_types past,
       per_all_assignments_f paaf
where  paaf.assignment_id=p_assignment_id
 and   r_date between paaf.effective_start_date and paaf.effective_end_date
 and   paaf.soft_coding_keyflex_id=kyflx.soft_coding_keyflex_id
 and   paaf.assignment_status_type_id=past.assignment_status_type_id ;

cursor csr_normal_assignments(r_person_id number) is
select assignment_id
from   per_all_assignments_f paaf,hr_soft_coding_keyflex kyflex
where  paaf.person_id=r_person_id
and    payroll_id= p_payroll_id
and    kyflex.segment3='NORMAL'
and    p_date_earned between paaf.effective_start_date and paaf.effective_end_date
and    kyflex.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id;

cursor csr_other_normal_contracts(r_person_id number) is
select 'Y'
from   per_all_assignments_f paaf
      ,hr_soft_coding_keyflex kyflex
      ,per_assignment_status_types past
where  paaf.person_id=r_person_id
and    paaf.assignment_id<>p_assignment_id
and    p_date_earned between paaf.effective_start_date and paaf.effective_end_date
and    kyflex.segment3='NORMAL'
and    kyflex.soft_coding_keyflex_id=paaf.soft_coding_keyflex_id;


cursor csr_get_tax_details(r_per_or_asg_id number,r_contract_category varchar2,r_date date ) is
select TAX_REDUCTION,TAX_CALC_WITH_SPOUSE_CHILD,INCOME_REDUCTION,
       INCOME_REDUCTION_AMOUNT,RATE_OF_TAX,EMP_SOCIAL_SECURITY_INFO
from   pay_pl_paye_details_f pppdf,
       pay_pl_sii_details_f  ppsdf
where  pppdf.per_or_asg_id =r_per_or_asg_id
and    r_date between pppdf.effective_start_date and pppdf.effective_end_date
and    pppdf.contract_category=r_contract_category
and    ppsdf.per_or_asg_id =r_per_or_asg_id
and    ppsdf.contract_category=r_contract_category
and    r_date between ppsdf.effective_start_date and ppsdf.effective_end_date;

TYPE run_result_table IS TABLE OF csr_run_result_values%ROWTYPE;

l_run_result_table     run_result_table;
l_csr_date_terminated  csr_date_terminated%rowtype;
l_csr_payroll_run      csr_payroll_run%rowtype;
l_per_system_status    per_assignment_status_types.per_system_status%type;
l_person_id            number;
l_other_normal         varchar2(1);--'Y' or 'N'
l_payroll_end_date     date;
l_payroll_run          varchar2(1);--'Y' or 'N'
l_assignment_action_id number;

/* The 3 variables needed to fetch tax params from pay_pl_paye_details_f*/
l_join_variable            pay_pl_sii_details_f.per_or_asg_id%type;
l_paye_table_date          date;
l_paye_contract_category   pay_pl_paye_details_f.contract_category%type;

l_proc_name            varchar2(33);

begin

l_proc_name:='PAY_PL_UTILITY.PL_GET_TAX_DETAILS';

hr_utility.set_location(l_proc_name,10);
open  csr_contract_assgt_type(p_date_earned);
fetch csr_contract_assgt_type into
                      p_contract_category,
                      p_contract_type,
                      l_per_system_status,
                      l_person_id;
close csr_contract_assgt_type;

l_payroll_run:='N';

if p_contract_category='NORMAL' then
   for i in csr_normal_assignments(l_person_id) loop
      for j in csr_payroll_run(i.assignment_id,p_date_earned,p_payroll_id,p_date_earned-1) loop
          l_payroll_run:=j.payroll_run;
          l_assignment_action_id:=j.assignment_action_id;
          if l_payroll_run='Y' then
            goto end_of_loop;
          end if;
       end loop;
   end loop;
  <<end_of_loop>>

   if l_payroll_run='Y' then
   --payroll run for this or some other normal contract of this person
   --with same payroll_id
   hr_utility.set_location(l_proc_name,20);
       open   csr_run_result_values(l_assignment_action_id,'Tax Details');
       fetch  csr_run_result_values bulk collect into l_run_result_table;
       close  csr_run_result_values;
       FOR indx IN l_run_result_table.FIRST .. l_run_result_table.LAST loop
          case l_run_result_table(indx).name
           when 'SII Code'                then p_sii_code               :=l_run_result_table(indx).result_value;
           when 'Spouse or Child Flag'    then p_spouse_or_child_flag   :=l_run_result_table(indx).result_value;
           when 'Income Reduction'        then p_income_reduction       :=l_run_result_table(indx).result_value;
           when 'Tax Reduction'           then p_tax_reduction          :=l_run_result_table(indx).result_value;
           when 'Rate of Tax'             then p_rate_of_tax            :=l_run_result_table(indx).result_value;
           when 'Contract Category'       then p_contract_category      :=l_run_result_table(indx).result_value;
           when 'Contract Type'           then p_contract_type          :=l_run_result_table(indx).result_value;
           when 'IR Flag'                 then p_ir_flag                :=l_run_result_table(indx).result_value;
           when 'Income Reduction Amount' then p_income_reduction_amount:=l_run_result_table(indx).result_value;
          end case;
        end loop;
    hr_utility.set_location(l_proc_name,30);
    else--l_payroll_run='Y'?
    hr_utility.set_location(l_proc_name,40);
      open csr_payroll_end_date;
      fetch  csr_payroll_end_date into l_payroll_end_date;
      close csr_payroll_end_date;

   --No payroll has been run for any Normal Contract of this person in the current payroll period
    if l_per_system_status<>'TERM_ASSIGN' then
       --Active Normal Contract,
       --pick up_values from pay_pl_paye_details_f with person_id and date as of ptp.end_date

     l_join_variable :=l_person_id;
     l_paye_contract_category:='NORMAL';
     l_paye_table_date:=l_payroll_end_date;

    else--l_per_system_status<>'TERM_ASSIGN'
      --Assignment is terminated.
      --Find out if it has been terminated in current Payroll period
      hr_utility.set_location(l_proc_name,50);
       open csr_date_terminated ;
       fetch csr_date_terminated into l_csr_date_terminated;
      --this is the last date as active/susp assign.
      --Pass next date for getting terminated sii/tax record
         if csr_date_terminated%found then
             close csr_date_terminated ;
            open csr_other_normal_contracts(l_person_id);
            fetch csr_other_normal_contracts into l_other_normal;
                  if csr_other_normal_contracts%found then
                     l_join_variable         :=l_person_id;
                     l_paye_contract_category:='NORMAL';
                     l_paye_table_date       :=l_payroll_end_date;
                  else
                    l_join_variable           :=p_assignment_id;
                    l_paye_contract_category  :='TERM_NORMAL';--corrected in 115.7
                    l_paye_table_date         :=l_csr_date_terminated.terminated_date+1;
                  end if;
            close csr_other_normal_contracts;
         else
             close csr_date_terminated ;
             l_join_variable           :=p_assignment_id;
             l_paye_contract_category  :='TERM_NORMAL';
             l_paye_table_date         :=l_payroll_end_date;
       end if;--csr_date_terminated%found
    end if;--l_per_system_status<>'TERM_ASSIGN'

    open csr_get_tax_details(l_join_variable,l_paye_contract_category,l_paye_table_date);
    fetch csr_get_tax_details into       p_tax_reduction,p_spouse_or_child_flag,p_income_reduction,
                                         p_income_reduction_amount,p_rate_of_tax,p_sii_code;
    close csr_get_tax_details;

   hr_utility.set_location(l_proc_name,60);
  end if;--l_payroll_run='Y'?
else--l_contract_category='NORMAL'?
    /* ***************Tax Params for Civil Contract,Lump and F_Lump*************** */
       hr_utility.set_location(l_proc_name,70);
   open  csr_payroll_run(p_assignment_id,p_date_earned,p_payroll_id,p_date_earned-1);
   fetch csr_payroll_run into l_csr_payroll_run.payroll_run,l_csr_payroll_run.assignment_action_id,l_csr_payroll_run.date_earned;
    if l_csr_payroll_run.payroll_run='Y' then
       hr_utility.set_location(l_proc_name,20);
       open   csr_run_result_values(l_csr_payroll_run.assignment_action_id,'Tax Details');
       fetch  csr_run_result_values bulk collect into l_run_result_table;
       close  csr_run_result_values;

       FOR indx IN l_run_result_table.FIRST .. l_run_result_table.LAST loop
          case l_run_result_table(indx).name
           when 'SII Code'                then p_sii_code               :=l_run_result_table(indx).result_value;
           when 'Spouse or Child Flag'    then p_spouse_or_child_flag   :=l_run_result_table(indx).result_value;
           when 'Income Reduction'        then p_income_reduction       :=l_run_result_table(indx).result_value;
           when 'Tax Reduction'           then p_tax_reduction          :=l_run_result_table(indx).result_value;
           when 'Rate of Tax'             then p_rate_of_tax            :=l_run_result_table(indx).result_value;
           when 'Contract Category'       then p_contract_category      :=l_run_result_table(indx).result_value;
           when 'Contract Type'           then p_contract_type          :=l_run_result_table(indx).result_value;
           when 'IR Flag'                 then p_ir_flag                :=l_run_result_table(indx).result_value;
           when 'Income Reduction Amount' then p_income_reduction_amount:=l_run_result_table(indx).result_value;
          end case;
        end loop;
       hr_utility.set_location(l_proc_name,80);
    close csr_payroll_run;
  else --l_payroll_run='Y'?
     close csr_payroll_run;
   --No payroll has been run for this Civil Contract,Lump or F_Lump contract
   --in the current payroll period
    hr_utility.set_location(l_proc_name,40);

    open  csr_payroll_end_date;
    fetch csr_payroll_end_date into l_paye_table_date;
    close csr_payroll_end_date;
              --p_contract_category=CIVIL or LUMP or F_LUMP
    open csr_get_tax_details(p_assignment_id,p_contract_category,l_paye_table_date);
    fetch csr_get_tax_details into       p_tax_reduction,p_spouse_or_child_flag,p_income_reduction,
                                         p_income_reduction_amount,p_rate_of_tax,p_sii_code;
    close csr_get_tax_details;

    if p_income_reduction_amount is null then
       p_ir_flag:='N';
       p_income_reduction_amount:=0;
    else
       p_ir_flag:='Y';
    end if;
  end if;--l_payroll_run='Y'?
           hr_utility.set_location(l_proc_name,90);
end if;--l_contract_category='NORMAL'?
hr_utility.set_location(l_proc_name,100);
return 0;
Exception
when others then
hr_utility.set_location(l_proc_name,99);
hr_utility.raise_error;
end pl_get_tax_details; --end of function pl_get_tax_details
END pay_pl_utility;

/
