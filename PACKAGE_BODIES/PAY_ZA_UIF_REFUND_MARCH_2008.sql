--------------------------------------------------------
--  DDL for Package Body PAY_ZA_UIF_REFUND_MARCH_2008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_UIF_REFUND_MARCH_2008" as
/* $Header: pyzauifr.pkb 120.2.12010000.1 2008/09/30 11:17:15 parusia noship $ */
-----------------------------------------------------------------------------------------
-----------------   function to set ZA_PAY_PERIODS_PER_YEAR dbi--------------------------
-----------------------------------------------------------------------------------------
 function get_py_prd_per_yr(p_payroll_action_id number,
                            p_payroll_id number) return number is
 l_py_prd_per_yr   number;
 begin
     select count(ptp.end_date)
     into   l_py_prd_per_yr
     from  per_time_periods PTP
     where ptp.prd_information1 =
       (select tperiod.prd_information1
        from per_time_periods tperiod,
             pay_payroll_actions paction
        where paction.payroll_action_id  = p_payroll_action_id
          and tperiod.time_period_id = paction.time_period_id)
          and ptp.payroll_id = p_payroll_id;

   return l_py_prd_per_yr;

 end get_py_prd_per_yr;

-----------------------------------------------------------------------------------------
-----------------   function to set ZA_PAY_MONTH_PERIOD_NUMBER dbi--------------------------
-----------------------------------------------------------------------------------------
function get_za_pay_mnth_prd_num (p_payroll_action_id number,
                                  p_payroll_id number) return number is
l_za_pay_mnth_prd_num number ;
begin
    select count(ptp.end_date)
    into l_za_pay_mnth_prd_num
    from per_time_periods ptp
    where ptp.pay_advice_date =
          (select tperiod.pay_advice_date
           from per_time_periods tperiod,
                pay_payroll_actions paction
           where paction.payroll_action_id = p_payroll_action_id
             and tperiod.time_period_id = paction.time_period_id
          )
      and ptp.end_date <=
          (select tperiod.end_date
           from per_time_periods tperiod,
                pay_payroll_actions paction
           where paction.payroll_action_id = p_payroll_action_id
             and tperiod.time_period_id = paction.time_period_id
          )
      and ptp.payroll_id = p_payroll_id;

     return l_za_pay_mnth_prd_num ;
end get_za_pay_mnth_prd_num;

-----------------------------------------------------------------------------------------
-----------------   function to set global values  --------------------------------------
-----------------------------------------------------------------------------------------
function get_global_value (p_global_name varchar2, p_effective_date date) return varchar2 is
   l_glb_value  ff_globals_f.global_value%type;
begin
    select global_value
    into   l_glb_value
    from   ff_globals_f
    where  global_name = p_global_name
    and    p_effective_date between effective_start_date
                            and effective_end_date
    and legislation_code = 'ZA';

    return l_glb_value;

end get_global_value;
-----------------------------------------------------------------------------------------
-----------------   function get_balance_value   ----------------------------------------
-----------------------------------------------------------------------------------------
function get_balance_value (p_bal_name varchar2,
                            p_dim_name varchar2,
			                p_asg_act_id number)
                            return number is
 cursor c_get_def_bal_id is
    select pdb.defined_balance_id
    from   pay_balance_types      pbt
        ,  pay_balance_dimensions pbd
        ,  pay_defined_balances    pdb
    where  pbt.balance_name     =  p_bal_name
      and  pbd.dimension_name   =  p_dim_name
      and  pbd.legislation_code =  'ZA'
      and  pdb.balance_type_id  =  pbt.balance_type_id
      and  pdb.balance_dimension_id     =  pbd.balance_dimension_id;

 cursor c_get_bal_value( p_def_bal_id in number) is
 select pay_balance_pkg.get_value(p_def_bal_id, --p_def_bal_id
  p_asg_act_id, --assignment_action_id
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  'TRUE')
 from dual;

l_def_bal_id number;
l_bal_val number;
begin
    open c_get_def_bal_id;
    fetch c_get_def_bal_id into l_def_bal_id ;
    close c_get_def_bal_id ;

    open c_get_bal_value(l_def_bal_id);
    fetch c_get_bal_value into l_bal_val;
    close c_get_bal_value;

return l_bal_val;
end get_balance_value;

-----------------------------------------------------------------------------------------
-----------------   function get_ele_dtls   ---------------------------------------------
-----------------------------------------------------------------------------------------
procedure get_ele_dtls(p_element_name in varchar2,
                      p_effective_date in date,
                      p_ele_type_id out nocopy  number ,
		      p_ip_value_id out nocopy  number)is
cursor c_get_ele_dtls is
select  pet.element_type_id
       , piv.input_value_id
from    pay_element_types_f   pet
      ,  pay_input_values_f    piv
where  pet.element_name            = p_element_name
   and  p_effective_date      between pet.effective_start_date
                                  and pet.effective_end_date
   and  piv.element_type_id         = pet.element_type_id
   and  piv.name                    = 'Pay Value'
   and  p_effective_date      between piv.effective_start_date
                              and piv.effective_end_date;

begin
    open c_get_ele_dtls;
    fetch c_get_ele_dtls into p_ele_type_id,p_ip_value_id;
    close c_get_ele_dtls;
end  get_ele_dtls;


/*******************************************************************************
 ****************        Procedure populate_assact_tab           ***************
 ******************************************************************************/

procedure populate_assact_tab( rec_assact in out nocopy tab_assact,
                               p_assignment_id number,
                               p_assignment_number varchar2,
                               p_rec_count in out nocopy number,
                               l_ee_contr_ele_type_id in number
                              ) is
l_row_found varchar2(1);
l_Oct_act_seq number;
l_Nov_act_seq number;
l_Dec_act_seq number;
l_Jan_act_seq number;
begin
     l_row_found := 'Y';

     -- Oct 2007
     begin
       select max(paa.action_sequence)
       into   l_Oct_act_seq
       from   pay_assignment_actions     paa,
            pay_payroll_actions        ppa,
            per_time_periods ptp
       where  paa.assignment_id = p_assignment_id
       and  paa.payroll_action_id = ppa.payroll_action_id
       and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
       and  paa.action_status ='C'
       and  ppa.time_period_id = ptp.time_period_id
       and  ptp.end_date between to_date('1-10-2007','DD-MM-YYYY')
                                   and to_date('31-10-2007','DD-MM-YYYY')
       and exists (select 1
                   from pay_run_results prr
                   where element_type_id =l_ee_contr_ele_type_id
                     and prr.assignment_action_id = paa.assignment_action_id
                   ) ;
     exception
       when others then
          l_row_found := 'N';
          hr_utility.trace('Row not found for Oct');
     end ;

     if l_row_found = 'Y' and (l_Oct_act_seq is not null) then
         hr_utility.trace('Inserting row for Assignment :'||p_assignment_id||' month :'||'Oct-2007');
         rec_assact(p_rec_count).assignment_id := p_assignment_id;
         rec_assact(p_rec_count).assignment_number := p_assignment_number;
         rec_assact(p_rec_count).month_yr := 'Oct-2007';
         rec_assact(p_rec_count).action_seq := l_Oct_act_seq;
         p_rec_count := p_rec_count + 1 ;
     end if;


     -- Nov 2007
     l_row_found := 'Y';

     begin
        select max(paa.action_sequence)
        into   l_Nov_act_seq
        from   pay_assignment_actions     paa,
            pay_payroll_actions        ppa,
            per_time_periods ptp
        where  paa.assignment_id = p_assignment_id
         and  paa.payroll_action_id = ppa.payroll_action_id
         and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
         and  paa.action_status ='C'
         and  ppa.time_period_id = ptp.time_period_id
         and  ptp.end_date between to_date('1-11-2007','DD-MM-YYYY')
                                   and to_date('30-11-2007','DD-MM-YYYY')
        and exists (select 1
                    from pay_run_results prr
                    where element_type_id =l_ee_contr_ele_type_id
                      and prr.assignment_action_id = paa.assignment_action_id
                    ) ;
     exception
       when others then
          l_row_found := 'N';
          hr_utility.trace('Row not found for Nov');
     end ;

     if l_row_found = 'Y' and (l_Nov_act_seq is not null) then
         hr_utility.trace('Inserting row for Assignment :'||p_assignment_id||' month :'||'Nov-2007');
         rec_assact(p_rec_count).assignment_id := p_assignment_id;
         rec_assact(p_rec_count).assignment_number := p_assignment_number;
         rec_assact(p_rec_count).month_yr := 'Nov-2007';
         rec_assact(p_rec_count).action_seq := l_Nov_act_seq;
         p_rec_count := p_rec_count + 1 ;
     end if;


     -- Dec 2007
     l_row_found := 'Y';

     begin
        select max(paa.action_sequence)
        into   l_Dec_act_seq
        from   pay_assignment_actions     paa,
            pay_payroll_actions        ppa,
            per_time_periods ptp
        where  paa.assignment_id = p_assignment_id
          and  paa.payroll_action_id = ppa.payroll_action_id
          and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
          and  paa.action_status ='C'
          and  ppa.time_period_id = ptp.time_period_id
          and  ptp.end_date between to_date('1-12-2007','DD-MM-YYYY')
                                   and to_date('31-12-2007','DD-MM-YYYY')
          and exists (select 1
                      from pay_run_results prr
                      where element_type_id =l_ee_contr_ele_type_id
                       and prr.assignment_action_id = paa.assignment_action_id
                    ) ;
     exception
       when others then
          l_row_found := 'N';
          hr_utility.trace('Row not found for Dec');
     end ;

     if l_row_found = 'Y' and (l_Dec_act_seq is not null) then
         hr_utility.trace('Inserting row for Assignment :'||p_assignment_id||' month :'||'Dec-2007');
         rec_assact(p_rec_count).assignment_id := p_assignment_id;
         rec_assact(p_rec_count).assignment_number := p_assignment_number;
         rec_assact(p_rec_count).month_yr := 'Dec-2007';
         rec_assact(p_rec_count).action_seq := l_Dec_act_seq;
         p_rec_count := p_rec_count + 1 ;
     end if;

     -- Jan 2008
     l_row_found := 'Y';

     begin
        select max(paa.action_sequence)
        into   l_Jan_act_seq
        from   pay_assignment_actions     paa,
               pay_payroll_actions        ppa,
               per_time_periods ptp
        where  paa.assignment_id = p_assignment_id
          and  paa.payroll_action_id = ppa.payroll_action_id
          and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
          and  paa.action_status ='C'
          and  ppa.time_period_id = ptp.time_period_id
          and  ptp.end_date between to_date('1-01-2008','DD-MM-YYYY')
                                   and to_date('31-01-2008','DD-MM-YYYY')
          and exists (select 1
                      from pay_run_results prr
                      where element_type_id =l_ee_contr_ele_type_id
                       and prr.assignment_action_id = paa.assignment_action_id
                    ) ;
     exception
       when others then
          l_row_found := 'N';
          hr_utility.trace('Row not found for Jan');
     end ;

     if l_row_found = 'Y' and (l_Jan_act_seq is not null) then
         hr_utility.trace('Inserting row for Assignment :'||p_assignment_id||' month :'||'Jan-2007');
         rec_assact(p_rec_count).assignment_id := p_assignment_id;
         rec_assact(p_rec_count).assignment_number := p_assignment_number;
         rec_assact(p_rec_count).month_yr := 'Jan-2008';
         rec_assact(p_rec_count).action_seq := l_Jan_act_seq;
         p_rec_count := p_rec_count + 1 ;
     end if;

     hr_utility.trace('Completed row population for assignment '||p_assignment_id);
end populate_assact_tab;


-----------------------------------------------------------------------------------------
-----------------   function get_rrv_dtls   ---------------------------------------------
-----------------------------------------------------------------------------------------
procedure get_rrv_dtls (p_asg_act_id  number,
	               p_ee_contr_ele_type_id  number     , p_ee_contr_ip_value_id number,
		       p_er_contr_ele_type_id  number     , p_er_contr_ip_value_id number,
                       p_excs_er_contr_ele_type_id  number, p_excs_er_contr_ip_value_id number,
                       p_ee_contr_rrval out nocopy number        , p_ee_contr_ee_id out nocopy number,
                       p_er_contr_rrval out nocopy number        , p_er_contr_ee_id out nocopy number,
                       p_excs_er_contr_rrval out nocopy number   , p_excs_er_contr_ee_id out nocopy number
                      ) is
cursor c_get_rrv_dtls (p_ele_type_id number, p_ip_value_id number) is
select prrv.result_value
     , prr.element_entry_id
from   pay_run_results        prr
    ,  pay_run_result_values  prrv
where  prr.assignment_action_id    = p_asg_act_id
  and  prr.element_type_id         = p_ele_type_id
  and  prrv.run_result_id          = prr.run_result_id
  and  prrv.input_value_id         = p_ip_value_id;

begin
    open c_get_rrv_dtls(p_ee_contr_ele_type_id,p_ee_contr_ip_value_id);
    fetch c_get_rrv_dtls into p_ee_contr_rrval,p_ee_contr_ee_id;
    close c_get_rrv_dtls ;

    open c_get_rrv_dtls(p_er_contr_ele_type_id,p_er_contr_ip_value_id);
    fetch c_get_rrv_dtls into p_er_contr_rrval,p_er_contr_ee_id;
    close c_get_rrv_dtls ;

    open c_get_rrv_dtls(p_excs_er_contr_ele_type_id,p_excs_er_contr_ip_value_id);
    fetch c_get_rrv_dtls into p_excs_er_contr_rrval,p_excs_er_contr_ee_id;
    close c_get_rrv_dtls ;
end get_rrv_dtls;



/*******************************************************************************
 ****************        Procedure calc_UIF_contribution  **********************
 ******************************************************************************/

procedure calc_UIF_contribution (p_payroll_action_id number,
                                 p_payroll_id number,
                                 p_eff_date in date,
				                 p_asact_id in number,
                                 p_pay_value out nocopy number,
                 				 p_empr_contr out nocopy number,
                				 p_ARREAR_UIF out nocopy number,
                                 p_UIF_ee_contr_ASG_TAX_MTD out nocopy number,
                                 p_UIF_er_contr_ASG_TAX_MTD out nocopy number,
                                 p_excs_er_UIF_cntr_ASG_TAX_PTD out nocopy number) is
-- dbis
l_ZA_PAY_MONTH_PERIOD_NUMBER number ;
l_ZA_PAY_PERIODS_PER_YEAR    number ;

-- balances
l_Tot_UIFable_Inc_ASG_TAX_MTD number;
-- l_UIF_ee_contr_ASG_TAX_MTD    number;
l_UIF_ee_contr_ASG_RUN        number;
--l_UIF_er_contr_ASG_TAX_MTD    number;
--l_excs_er_UIF_cntr_ASG_TAX_PTD number;
l_UIF_er_contr_ASG_RUN        number;
l_NET_PAY_ASG_RUN             number;

-- globals
l_ZA_UIF_ANN_LIM number;
l_ZA_UIF_EMPY_PERC           number ;
l_ZA_UIF_EMPR_PERC           number ;

-- variables
l_period_limit number;
l_ee_contr     number;
l_refu_ee_contr number;

begin
-- initialise balances
l_Tot_UIFable_Inc_ASG_TAX_MTD := get_balance_value('Total UIFable Income','_ASG_TAX_MTD',p_asact_id);
p_UIF_ee_contr_ASG_TAX_MTD    := get_balance_value('UIF Employee Contribution','_ASG_TAX_MTD',p_asact_id);
-- l_UIF_ee_contr_ASG_RUN        := get_balance_value('UIF Employee Contribution','_ASG_RUN',p_asact_id);
p_UIF_er_contr_ASG_TAX_MTD    := get_balance_value('UIF Employer Contribution','_ASG_TAX_MTD',p_asact_id);
p_excs_er_UIF_cntr_ASG_TAX_PTD:= get_balance_value('Excess Employer UIF Contrib','_ASG_TAX_PTD',p_asact_id);
-- l_UIF_er_contr_ASG_RUN        := get_balance_value('UIF Employer Contribution','_ASG_RUN',p_asact_id);
l_NET_PAY_ASG_RUN             := get_balance_value('Net Pay','_ASG_RUN',p_asact_id);

-- changed as while testing weekly payrolls, ASG_RUN should be zero.
l_UIF_ee_contr_ASG_RUN := 0;
l_UIF_er_contr_ASG_RUN := 0;

hr_utility.trace('Balances :');
hr_utility.trace('l_Tot_UIFable_Inc_ASG_TAX_MTD :'||l_Tot_UIFable_Inc_ASG_TAX_MTD);
hr_utility.trace('p_UIF_ee_contr_ASG_TAX_MTD :'||p_UIF_ee_contr_ASG_TAX_MTD);
hr_utility.trace('l_UIF_ee_contr_ASG_RUN :'||l_UIF_ee_contr_ASG_RUN);
hr_utility.trace('p_UIF_er_contr_ASG_TAX_MTD :'||p_UIF_er_contr_ASG_TAX_MTD);
hr_utility.trace('p_excs_er_UIF_cntr_ASG_TAX_PTD :'||p_excs_er_UIF_cntr_ASG_TAX_PTD);
hr_utility.trace('l_UIF_er_contr_ASG_RUN :'||l_UIF_er_contr_ASG_RUN);
hr_utility.trace('l_NET_PAY_ASG_RUN :'||l_NET_PAY_ASG_RUN);
hr_utility.trace(' ');


-- initialise dbis
l_ZA_PAY_MONTH_PERIOD_NUMBER := get_za_pay_mnth_prd_num(p_payroll_action_id, p_payroll_id);
l_ZA_PAY_PERIODS_PER_YEAR    := get_py_prd_per_yr(p_payroll_action_id, p_payroll_id) ;
hr_utility.trace('DBIs :');
hr_utility.trace('l_ZA_PAY_MONTH_PERIOD_NUMBER :'||l_ZA_PAY_MONTH_PERIOD_NUMBER);
hr_utility.trace('l_ZA_PAY_PERIODS_PER_YEAR :'||l_ZA_PAY_PERIODS_PER_YEAR);
hr_utility.trace(' ');

-- initialse global values
l_ZA_UIF_ANN_LIM := get_global_value('ZA_UIF_ANN_LIM', p_eff_date);
l_ZA_UIF_EMPY_PERC := get_global_value('ZA_UIF_EMPY_PERC', p_eff_date);
l_ZA_UIF_EMPR_PERC := get_global_value('ZA_UIF_EMPR_PERC', p_eff_date);
hr_utility.trace('Globals :');
hr_utility.trace('l_ZA_UIF_ANN_LIM :'||l_ZA_UIF_ANN_LIM);
hr_utility.trace('l_ZA_UIF_EMPY_PERC :'||l_ZA_UIF_EMPY_PERC);
hr_utility.trace('l_ZA_UIF_EMPR_PERC :'||l_ZA_UIF_EMPR_PERC);
hr_utility.trace(' ');

-- compute UIF contribution
p_ARREAR_UIF := 0 ;

/* periodic limit of UIFable income */
l_period_limit := round(l_ZA_PAY_MONTH_PERIOD_NUMBER * l_ZA_UIF_ANN_LIM / l_ZA_PAY_PERIODS_PER_YEAR,2) ;

if  l_Tot_UIFable_Inc_ASG_TAX_MTD > l_period_limit  then
    /* limit UIFable Income to period limit, and calculate UIF on that */
    l_ee_contr   := round((l_period_limit * l_ZA_UIF_EMPY_PERC) / 100,2);
    p_empr_contr := round((l_period_limit * l_ZA_UIF_EMPR_PERC) / 100,2);
    l_ee_contr   := l_ee_contr - (p_UIF_ee_contr_ASG_TAX_MTD - l_UIF_ee_contr_ASG_RUN);
    p_empr_contr := p_empr_contr - (p_UIF_er_contr_ASG_TAX_MTD - p_excs_er_UIF_cntr_ASG_TAX_PTD -
				l_UIF_er_contr_ASG_RUN);
    hr_utility.trace('1) p_empr_contr = '||p_empr_contr);
else
    /* calculate UIF on the period UIFable income */
    l_ee_contr   := round((l_Tot_UIFable_Inc_ASG_TAX_MTD * l_ZA_UIF_EMPY_PERC) / 100,2);
    p_empr_contr := round((l_Tot_UIFable_Inc_ASG_TAX_MTD * l_ZA_UIF_EMPR_PERC) / 100,2);
    l_ee_contr   := l_ee_contr - (p_UIF_ee_contr_ASG_TAX_MTD - l_UIF_ee_contr_ASG_RUN);
    p_empr_contr := p_empr_contr - (p_UIF_er_contr_ASG_TAX_MTD - p_excs_er_UIF_cntr_ASG_TAX_PTD
				- l_UIF_er_contr_ASG_RUN);
    hr_utility.trace('2) p_empr_contr = '||p_empr_contr);
end if ;

if l_ee_contr > 0 then
   /* check if Net Pay is zero or less */
   if l_NET_PAY_ASG_RUN <= 0 then
       hr_utility.trace('3) Entered '||p_empr_contr);
       p_ARREAR_UIF := l_ee_contr;
       l_ee_contr   := 0;
   else
       /* check if Net Pay is insufficient to deduct the full UIF contribution */
       if l_ee_contr > l_NET_PAY_ASG_RUN then
          hr_utility.trace('4) Entered '||p_empr_contr);
          p_ARREAR_UIF := l_ee_contr - l_NET_PAY_ASG_RUN ;
          l_ee_contr   := l_NET_PAY_ASG_RUN;
       end if ;
    end if ;
else
     /* Maximum refundable SUM for Employee Contribution */
     hr_utility.trace('5) Entered '||p_empr_contr);
     l_refu_ee_contr := p_UIF_ee_contr_ASG_TAX_MTD ;
     /* Check whether current run is to refud and refund limit is more than allowable amount */
     IF (l_ee_contr + l_refu_ee_contr) < 0
     Then
            /* It's refund, thus, it should be negative */
            l_ee_contr := 0 - l_refu_ee_contr ;
      end if;
end if ;

/* Maximum refundable SUM for Employer Contribution */
l_refu_ee_contr := p_UIF_er_contr_ASG_TAX_MTD - p_excs_er_UIF_cntr_ASG_TAX_PTD ;
hr_utility.trace('6) l_refu_ee_contr : '||l_refu_ee_contr);

/* Check whether current run is to refud and refund limit is more than allowable amount */
if (p_empr_contr + l_refu_ee_contr) < 0 then
        /* It's refund, thus, it should be negative */
        p_empr_contr := 0 - l_refu_ee_contr;
        hr_utility.trace('7) p_empr_contr : '||p_empr_contr);
end if;

/* the UIF contribution is deducted, taking into account whether there was enough Net Pay */
p_pay_value := l_ee_contr ;

/* Adjust Excess Employer Contrib already made in the period */
p_ARREAR_UIF := p_ARREAR_UIF  - p_excs_er_UIF_cntr_ASG_TAX_PTD;
hr_utility.trace('8) p_ARREAR_UIF : '||p_ARREAR_UIF);

end calc_UIF_contribution ;




/*******************************************************************************
 ****************        Procedure create_retro_ele_entry  *********************
 ******************************************************************************/
 procedure create_retro_ele_entry (p_ee_contr_ele_type_id number
                                  ,p_retro_ee_contr_ele_type_id number
                                  ,p_retro_ee_contr_ip_value_id number
                                  ,p_payroll_id number
                                  ,p_assact_id number
                                  ,p_asg_id number
                                  ,p_eff_date date
                                  ,p_reflection_date date
                                  ,p_time_prd_id number
                                  ,p_diff_ee_contr number
                                  ,p_ee_contr_ee_id number
                                  ) is

cursor csr_ee_end_date(p_payroll_id number) is
select ptp.end_date
from per_time_periods ptp
where ptp.payroll_id = p_payroll_id
  and p_reflection_date between start_date and end_date ;

cursor csr_ele_link_id (p_ele_type_id number) is
-- Changed for Bug 7229385
-- to pick up element_link more accurately depending on people groups, job, grade
-- organization, etc
        select pel.element_link_id
        from    per_assignments_f ASG,
                pay_element_links_f   PEL
        where   P_REFLECTION_DATE between pel.effective_start_date
                                        and pel.effective_end_date
        and     P_REFLECTION_DATE between asg.effective_start_date
                                        and asg.effective_end_date
        -- and     pel.element_link_id = P_ELEMENT_LINK_ID
        and    pel.element_type_id = P_ELE_TYPE_ID
        and     asg.assignment_id = P_ASG_ID
        and   ((pel.payroll_id is not null
        and     asg.payroll_id = pel.payroll_id)
        or     (pel.link_to_all_payrolls_flag = 'Y'
        and     asg.payroll_id is not null)
        or     (pel.payroll_id is null
        and     pel.link_to_all_payrolls_flag = 'N'))
        and    (pel.organization_id = asg.organization_id
        or      pel.organization_id is null)
        and    (pel.position_id = asg.position_id
        or      pel.position_id is null)
        and    (pel.job_id = asg.job_id
        or      pel.job_id is null)
        and    (pel.grade_id = asg.grade_id
        or      pel.grade_id is null)
        and    (pel.location_id = asg.location_id
        or      pel.location_id is null)
        and    (
                pel.pay_basis_id = asg.pay_basis_id
                or
                --
                -- if EL is associated with a pay basis then this clause fails
                --
                pel.pay_basis_id is null and
                NOT EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = pel.element_type_id
                     and    P_REFLECTION_DATE between
                             iv.effective_start_date and iv.effective_end_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.business_group_id = asg.business_group_id
                    )
                or
                --
                -- if EL is associated with a pay basis then the associated
                -- PB_ID must match the PB_ID on ASG
                --
                pel.pay_basis_id is null and
                EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = pel.element_type_id
                     and    P_REFLECTION_DATE between
                             iv.effective_start_date and iv.effective_end_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.pay_basis_id = asg.pay_basis_id
                    )
                or
                pel.pay_basis_id is null and
                asg.pay_basis_id is null and
                EXISTS
                    (SELECT pb.pay_basis_id
                     FROM   PER_PAY_BASES      pb,
                            PAY_INPUT_VALUES_F iv
                     WHERE  iv.element_type_id = pel.element_type_id
                     and    P_REFLECTION_DATE between
                             iv.effective_start_date and iv.effective_end_date
                     and    pb.input_value_id =
                                              iv.input_value_id
                     and    pb.business_group_id = asg.business_group_id
                    )
               )
        and    (pel.employment_category = asg.employment_category
        or      pel.employment_category is null)
        and    (pel.people_group_id is null
        or     exists
                (select  1
                from    pay_assignment_link_usages_f palu
                where   palu.assignment_id   = P_ASG_ID
                and     palu.element_link_id = pel.element_link_id
                and     P_REFLECTION_DATE between palu.effective_start_date
                                                and palu.effective_end_date))
;


CURSOR c_get_ee_dtls ( p_element_entry_id   IN  number
                      , p_eff_dt             IN date
                      ) is
 SELECT original_entry_id,
       entry_type,
       cost_allocation_keyflex_id,
       updating_action_id,
       updating_action_type,
       comment_id,
       reason,
       target_entry_id,
       subpriority,
       date_earned,
       personal_payment_method_id,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
       attribute16,
       attribute17,
       attribute18,
       attribute19,
       attribute20,
       label_identifier
 FROM    pay_element_entries_f  pee
 WHERE   pee.element_entry_id = p_element_entry_id
   AND   p_eff_dt             BETWEEN pee.effective_start_date
                                  AND pee.effective_end_date;

l_original_entry_id      pay_element_entries_f.original_entry_id%TYPE;
l_entry_type             pay_element_entries_f.entry_type%TYPE;
l_cost_allocation_keyflex_id  pay_element_entries_f.cost_allocation_keyflex_id%TYPE;
l_updating_action_id     pay_element_entries_f.updating_action_id%TYPE;
l_updating_action_type   pay_element_entries_f.updating_action_type%TYPE;
l_comment_id             pay_element_entries_f.comment_id%TYPE;
l_reason                 pay_element_entries_f.reason%TYPE;
l_target_entry_id        pay_element_entries_f.target_entry_id%TYPE;
l_subpriority            pay_element_entries_f.subpriority%TYPE;
l_date_earned            pay_element_entries_f.date_earned%TYPE;
l_personal_payment_method_id pay_element_entries_f.personal_payment_method_id%TYPE;
l_attribute_category     pay_element_entries_f.attribute_category%TYPE;
l_attribute1             pay_element_entries_f.attribute1%TYPE;
l_attribute2             pay_element_entries_f.attribute2%TYPE;
l_attribute3             pay_element_entries_f.attribute3%TYPE;
l_attribute4             pay_element_entries_f.attribute4%TYPE;
l_attribute5             pay_element_entries_f.attribute5%TYPE;
l_attribute6             pay_element_entries_f.attribute6%TYPE;
l_attribute7             pay_element_entries_f.attribute7%TYPE;
l_attribute8             pay_element_entries_f.attribute8%TYPE;
l_attribute9             pay_element_entries_f.attribute9%TYPE;
l_attribute10            pay_element_entries_f.attribute10%TYPE;
l_attribute11            pay_element_entries_f.attribute11%TYPE;
l_attribute12            pay_element_entries_f.attribute12%TYPE;
l_attribute13            pay_element_entries_f.attribute13%TYPE;
l_attribute14            pay_element_entries_f.attribute14%TYPE;
l_attribute15            pay_element_entries_f.attribute15%TYPE;
l_attribute16            pay_element_entries_f.attribute16%TYPE;
l_attribute17            pay_element_entries_f.attribute17%TYPE;
l_attribute18            pay_element_entries_f.attribute18%TYPE;
l_attribute19            pay_element_entries_f.attribute19%TYPE;
l_attribute20            pay_element_entries_f.attribute20%TYPE;
l_label_identifier       pay_element_entries_f.label_identifier%TYPE;

l_rtr_ee_cntr_ele_link_id number;

l_prev_entry_start_date date ;
l_prev_entry_end_date date ;

l_element_entry_id number;
l_ee_end_date  date;

l_reflection_date date;

l_proc_name varchar2(30);
 begin

      l_proc_name := 'create_retro_ele_entry';
      l_reflection_date := p_reflection_date ;

      hr_utility.trace('Entering ' ||l_proc_name);
      hr_utility.trace('p_ee_contr_ele_type_id :' || p_ee_contr_ele_type_id);

      -- get end date of the new element entry
      open csr_ee_end_date (p_payroll_id);
      fetch csr_ee_end_date into l_ee_end_date;
      close csr_ee_end_date;

      hr_utility.trace('End date_earned of new element_link_id entry_type :'||to_char(l_ee_end_date));

      -- get element_link_id for the retro_element
      open csr_ele_link_id (p_retro_ee_contr_ele_type_id);
      fetch csr_ele_link_id into l_rtr_ee_cntr_ele_link_id;
      close csr_ele_link_id;

      hr_utility.trace('Element link id for Retro Element :'||l_rtr_ee_cntr_ele_link_id);

      hr_utility.set_location(l_proc_name,20);

      open c_get_ee_dtls (p_ee_contr_ee_id, p_eff_date);
      fetch c_get_ee_dtls into
		           l_original_entry_id,
                   l_entry_type,
                   l_cost_allocation_keyflex_id,
                   l_updating_action_id,
                   l_updating_action_type,
                   l_comment_id,
                   l_reason,
		           l_target_entry_id,
                   l_subpriority,
    		       l_date_earned,
	    	       l_personal_payment_method_id,
		           l_attribute_category,
                   l_attribute1,
    		       l_attribute2,
	    	       l_attribute3,
		           l_attribute4,
		           l_attribute5,
    		       l_attribute6,
	    	       l_attribute7,
		           l_attribute8,
		           l_attribute9,
    		       l_attribute10,
	    	       l_attribute11,
		           l_attribute12,
		           l_attribute13,
    		       l_attribute14,
	    	       l_attribute15,
		           l_attribute16,
		           l_attribute17,
    		       l_attribute18,
	    	       l_attribute19,
		           l_attribute20,
                   l_label_identifier;
  	   close c_get_ee_dtls;

  	   hr_utility.trace('Values obtained from prev element entry :');
  	   hr_utility.trace('Original_entry_id :'||l_original_entry_id);
  	   hr_utility.trace('entry_type :'||l_entry_type);
  	   hr_utility.trace('updating_action_id :'||l_updating_action_id);
  	   hr_utility.trace('target_entry_id :'||l_target_entry_id);
  	   hr_utility.trace('date_earned :'||to_char(l_date_earned));

       if l_entry_type in ('R','A') then
           -- Replacement or Additive Adjustment done to element entry
           raise excp_uif_manipulated ;
       end if ;
  	   hr_utility.set_location(l_proc_name,30);

       hr_utility.trace('Creating element entry ');
       hr_entry_api.insert_element_entry(
                    --
                    -- Common Parameters
                    --
                    p_effective_start_date => l_reflection_date,
                    p_effective_end_date   => l_ee_end_date,
                    --
                    -- Element Entry Table
                    --
                    p_element_entry_id   => l_element_entry_id,
                    p_original_entry_id  => l_original_entry_id,
                    p_assignment_id      => p_asg_id,
                    p_element_link_id    => l_rtr_ee_cntr_ele_link_id,
                    p_creator_type       => 'RR',
                    p_entry_type         => 'E', -- for Bug 7229385
                    p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id,
                    p_updating_action_id   => l_updating_action_id,
                    p_updating_action_type => l_updating_action_type,
                    p_comment_id           => l_comment_id,
                    p_creator_id           => null ,-- assignemnt_action_id of retropay run goes here
                    p_reason               => l_reason,
                    p_target_entry_id      => null, -- for Bug 7229385
                    p_subpriority          => l_subpriority,
                    p_date_earned          => l_date_earned,
                    p_personal_payment_method_id => l_personal_payment_method_id,
                    p_attribute_category   => l_attribute_category,
                    p_attribute1           => l_attribute1,
                    p_attribute2           => l_attribute2,
                    p_attribute3           => l_attribute3,
                    p_attribute4           => l_attribute4,
                    p_attribute5           => l_attribute5,
                    p_attribute6           => l_attribute6,
                    p_attribute7           => l_attribute7,
                    p_attribute8           => l_attribute8,
                    p_attribute9           => l_attribute9,
                    p_attribute10          => l_attribute10,
                    p_attribute11          => l_attribute11,
                    p_attribute12          => l_attribute12,
                    p_attribute13          => l_attribute13,
                    p_attribute14          => l_attribute14,
                    p_attribute15          => l_attribute15,
                    p_attribute16          => l_attribute16,
                    p_attribute17          => l_attribute17,
                    p_attribute18          => l_attribute18,
                    p_attribute19          => l_attribute19,
                    p_attribute20          => l_attribute20,
                    --
                    -- Element Entry Values Table
                    --
                    p_input_value_id1      => p_retro_ee_contr_ip_value_id,
                    p_entry_value1         => p_diff_ee_contr,
                    -- p_override_user_ent_chk      varchar2  default 'N',
                    p_label_identifier     => l_label_identifier
         ) ;

         hr_utility.trace('New element entry id :'||l_element_entry_id);
   	     hr_utility.set_location(l_proc_name,40);

         select start_date,end_date
         into l_prev_entry_start_date, l_prev_entry_end_date
         from per_time_periods
         where time_period_id = p_time_prd_id ;

         hr_utility.trace('Prev entry Start Date:'||to_char(l_prev_entry_start_date));
         hr_utility.trace('Prev entry End Date:'||to_char(l_prev_entry_end_date));

         update pay_element_entries_f
         set    source_asg_action_id = p_assact_id
               ,source_start_date    = l_prev_entry_start_date
               ,source_end_date      = l_prev_entry_end_date
         where element_entry_id = l_element_entry_id;

         hr_utility.trace('SQL%ROWCOUNT :'||SQL%ROWCOUNT);
         if SQL%ROWCOUNT = 0 then
             hr_utility.trace('Error : No element entry created');
         end if ;
   	     hr_utility.set_location(l_proc_name,50);
 end create_retro_ele_entry;



/******************************************************************************
 ****************        Procedure create_uif_backdated_entries  **************
 ******************************************************************************/

procedure create_uif_backdated_entries(errbuf out nocopy varchar2,
                                       retcode out nocopy number,
                                       p_payroll_id number,
                                       p_reflection_date_char varchar2,
                                       p_asg_set_id number)
				       is

cursor c_all_asg_ids(p_payroll_id number,
                     p_effective_date date) is
 select assignment_id,
        assignment_number
 from per_all_assignments_f paaf
 where payroll_id = p_payroll_id
   and assignment_status_type_id in (1,3) -- pick active and terminated ( whose final process date is left) assignments
   and p_effective_date between effective_start_date and effective_end_date ;

cursor c_get_ee_id (p_ele_type_id number
                   ,p_asact_id number) is
select prr.element_entry_id
from   pay_run_results  prr
where  prr.assignment_action_id    = p_asact_id
  and  prr.element_type_id = p_ele_type_id ;

l_asg_id number;
l_pact_id number;
l_assact_id number;
l_eff_date date;
l_time_prd_id number ;
l_rec_count number ;

l_proc_name varchar2(30);

l_ee_contr_ele_type_id    number;
l_ee_contr_ip_value_id    number;
l_er_contr_ele_type_id    number;
l_er_contr_ip_value_id    number;
l_excs_er_contr_ele_type_id    number;
l_excs_er_contr_ip_value_id    number;

l_retro_ee_contr_ele_type_id    number;
l_retro_ee_contr_ip_value_id    number;
l_retro_er_contr_ele_type_id    number;
l_retro_er_contr_ip_value_id    number;
l_retro_excs_er_cntr_ele_tp_id    number;
l_retro_excs_er_cntr_ip_val_id    number;

rec_assact tab_assact ;
unprocessed_assignments tab_assact ;
unprocessed_asgn_count number := 0 ;

l_prev_ee_cntr number;
l_prev_er_cntr number;
l_prev_excs_er_cntr number;

l_process_run_count number;

l_calc_ee_contr  number;
l_calc_empr_contr number;
l_calc_ARREAR_UIF number;

l_diff_ee_contr number;
l_diff_er_contr number;
l_diff_excs_er_contr number;

p_reflection_date date ;
l_ee_contr_ee_id number;

l_last_printed_asg number;

v_incl_sw char;
asg_include boolean;
l_action_type varchar2(10);
l_header_printed boolean := false;

begin
     -- hr_utility.trace_on(null,'ZA_UIF');

     hr_utility.trace('Starting Trace for UIF Refund March 2008');
     p_reflection_date := to_date(p_reflection_date_char,'YYYY/MM/DD HH24:MI:SS');
     l_proc_name := 'create_uif_backdated_entries' ;

     hr_utility.set_location('Entering '||l_proc_name,10);
     hr_utility.set_location('payroll_id : ' || p_payroll_id,1);
     hr_utility.set_location('Effective_date : ' || p_reflection_date,1);
     hr_utility.set_location('Assignment Set Id  : ' ||p_asg_set_id,1);


     ---------------------------------------------------------------------------
     --------------           Get Element Details      -------------------------
     ---------------------------------------------------------------------------
     begin
       get_ele_dtls ('ZA_UIF_Employee_Contribution',sysdate,l_ee_contr_ele_type_id,l_ee_contr_ip_value_id);
       get_ele_dtls ('ZA_UIF_Employer_Contribution',sysdate,l_er_contr_ele_type_id,l_er_contr_ip_value_id);
       get_ele_dtls ('ZA Excess Employer UIF Contribution',sysdate,l_excs_er_contr_ele_type_id,l_excs_er_contr_ip_value_id);

       get_ele_dtls ('ZA_Retro_UIF_Employee_Contribution',sysdate,l_retro_ee_contr_ele_type_id,l_retro_ee_contr_ip_value_id);
       get_ele_dtls ('ZA_Retro_UIF_Employer_Contribution',sysdate,l_retro_er_contr_ele_type_id,l_retro_er_contr_ip_value_id);
       get_ele_dtls ('ZA Retro Excess Employer UIF Contribution',sysdate,l_retro_excs_er_cntr_ele_tp_id,l_retro_excs_er_cntr_ip_val_id);

       hr_utility.set_location('l_ee_contr_ele_type_id      :   ' || l_ee_contr_ele_type_id,2);
       hr_utility.set_location('l_ee_contr_ip_value_id      :   ' || l_ee_contr_ip_value_id,2);
       hr_utility.set_location('l_er_contr_ele_type_id      :   ' || l_er_contr_ele_type_id,2);
       hr_utility.set_location('l_er_contr_ip_value_id      :   ' || l_er_contr_ip_value_id,2);
       hr_utility.set_location('l_excs_er_contr_ele_type_id :   ' || l_excs_er_contr_ele_type_id,2);
       hr_utility.set_location('l_excs_er_contr_ip_value_id :   ' || l_excs_er_contr_ip_value_id,2);
       exception
       WHEN others then
         hr_utility.set_location('ERROR while getting element_details ',9999);
         hr_utility.set_location('Error code is                    ' || SQLCODE, 9999);
         hr_utility.set_location('Error Messages' || substr(SQLERRM,1,255), 9999);
         RAISE;
     end;

     ---------------------------------------------------------------------------
     --------------           Start Processing         -------------------------
     ---------------------------------------------------------------------------

     l_rec_count := 0 ;

     if  p_asg_set_id is not null then
        begin
           select distinct include_or_exclude
           into v_incl_sw
           from   hr_assignment_set_amendments
           where  assignment_set_id = p_asg_set_id;
        exception
           when no_data_found  then
              v_incl_sw := 'I';
        end;
     end if;

     -- Get All 'ACTIVE' and 'TERMINATED' ( whose FinalProcessDate >= reflection date) Assignments for the payroll
     for rec_all_asg_ids in c_all_asg_ids ( p_payroll_id, p_reflection_date)
     loop
        -- Check the Assignment set to see if the assignment should be
        -- processed or not
        asg_include := TRUE;
        if p_asg_set_id is not null then
            declare
               inc_flag varchar2(5);
            begin
               select include_or_exclude
               into   inc_flag
               from   hr_assignment_set_amendments
               where  assignment_set_id = p_asg_set_id
                 and  assignment_id = rec_all_asg_ids.assignment_id;

               if inc_flag = 'E' then
                  asg_include := FALSE;
                  hr_utility.set_location('Excluding Assignment '||rec_all_asg_ids.assignment_id,10);
               else
                  hr_utility.set_location('Including Assignment '||rec_all_asg_ids.assignment_id,20);
               end if;
            exception
               when no_data_found then
                    if  v_incl_sw = 'I' then
                        asg_include := FALSE;
                        hr_utility.set_location('Excluding Assignment '||rec_all_asg_ids.assignment_id,30);
                    else
                        asg_include := TRUE;
                        hr_utility.set_location('Including Assignment '||rec_all_asg_ids.assignment_id,40);
                    end if;
            end ;
         end if;

        if asg_include = TRUE then
           -- Populate table rec_assact with max(action_sequence)
           -- for all the assignment for the months Oct2007 - Jan2008.
           -- The table will contain 4 rows (for each month) per assignment
           hr_utility.trace('Populating table for assignment_id :'||rec_all_asg_ids.assignment_id||'  assignment_number :'||rec_all_asg_ids.assignment_number) ;
           populate_assact_tab (rec_assact,
                             rec_all_asg_ids.assignment_id,
                             rec_all_asg_ids.assignment_number,
                             l_rec_count,
                             l_ee_contr_ele_type_id) ;
        end if ;
     end loop ;

     -- Loop through all the assignments per month
     hr_utility.trace('rec_assact.count :'||rec_assact.count);

     -- Checking if there is any row to process
     if rec_assact.first is null then
          hr_utility.trace('No assignment to process... Exitting');
          return ;
     end if ;

     l_last_printed_asg := -1 ;

     for rec_count in rec_assact.first .. rec_assact.last
     loop
        -- Get payroll_action and assignment_action details
        -- for the action_sequence
        begin

        hr_utility.trace('Processing Assignment_ID : '||rec_assact(rec_count).assignment_id);
        hr_utility.trace('Action Sequence : '||rec_assact(rec_count).action_seq);


        begin
            select ppa.payroll_action_id
                  ,paa.assignment_action_id
                  ,ppa.effective_date
                  ,ppa.time_period_id
                  ,paa.assignment_id
                  ,ppa.action_type
            into l_pact_id
                ,l_assact_id
                ,l_eff_date
                ,l_time_prd_id
                ,l_asg_id
                ,l_action_type
            from pay_payroll_actions ppa
                ,pay_assignment_actions paa
            where ppa.payroll_action_id = paa.payroll_action_id
              and paa.action_sequence = rec_assact(rec_count).action_seq
              and paa.assignment_id = rec_assact(rec_count).assignment_id ;
         exception
           when others then
             hr_utility.trace('Error while fetching payroll_action/assignment_action details for assignment_id '||rec_assact(rec_count).assignment_id);
             RAISE;
         end ;

        hr_utility.trace('Month_Year : '||rec_assact(rec_count).month_yr);
        hr_utility.trace('Payroll_action_id : '||l_pact_id);
        hr_utility.trace('Assignment_action_id : '||l_assact_id);
        hr_utility.trace('Effective_Date : '||l_eff_date);
        hr_utility.trace('Time_Period_ID : '||l_time_prd_id);
        hr_utility.trace('Action_Type : '||l_action_type);

        -- Get MTD balances for UIF contributions
        -- commented while testing for weekly payrolls
        -- l_prev_ee_cntr := nvl(get_balance_value('UIF Employee Contribution','_ASG_TAX_MTD',l_assact_id),0);
        -- l_prev_er_cntr := nvl(get_balance_value('UIF Employer Contribution','_ASG_TAX_MTD',l_assact_id),0);
        -- l_prev_excs_er_cntr := nvl(get_balance_value('Excess Employer UIF Contrib','_ASG_TAX_MTD',l_assact_id),0);

        -- Check if retro entries have already been created
        -- which would mean that the customer has already run the process
        select count(1)
        into l_process_run_count
        from pay_element_entries_f
        where source_asg_action_id = l_assact_id
          and element_type_id in (l_retro_ee_contr_ele_type_id,
                                  l_retro_er_contr_ele_type_id,
                                  l_retro_excs_er_cntr_ele_tp_id);

        hr_utility.trace('Process run count :'||l_process_run_count);

        if l_process_run_count = 0 then
             if l_action_type in ('B','V','I') then
                 raise excp_uif_manipulated ;
             end if ;
             -- Calculate the UIF amounts as per the latest global values
             calc_UIF_contribution(l_pact_id, p_payroll_id, l_eff_date, l_assact_id,
                                   l_calc_ee_contr, l_calc_empr_contr, l_calc_ARREAR_UIF,
                                   l_prev_ee_cntr, l_prev_er_cntr, l_prev_excs_er_cntr );

              l_calc_ee_contr := nvl(l_calc_ee_contr,0);
              l_calc_empr_contr := nvl(l_calc_empr_contr,0);
              l_calc_ARREAR_UIF := nvl(l_calc_ARREAR_UIF,0);

              hr_utility.trace('Calculated UIF Contributions :');
              hr_utility.trace('Employee Contribution :'|| l_calc_ee_contr);
              hr_utility.trace('Employer Contribution :'|| l_calc_empr_contr);
              hr_utility.trace('Arrears :'|| l_calc_ARREAR_UIF);
              hr_utility.trace('Balance UIF_Employee_Contribution_ASG_TAX_MTD :'||l_prev_ee_cntr);
              hr_utility.trace('Balance UIF_Employer_Contribution_ASG_TAX_MTD :'||l_prev_er_cntr);
              hr_utility.trace('Balance Excess_Employer_UIF_Contrib_ASG_TAX_PTD :'||l_prev_excs_er_cntr);

             -- Calculate differences between the previous balances and the
             -- the newly calculated UIF contributions

             -- commented while testing for weekly payrolls
             -- l_diff_ee_contr := l_calc_ee_contr - l_prev_ee_cntr ;
             -- l_diff_er_contr := l_calc_empr_contr - l_prev_er_cntr ;
             -- l_diff_excs_er_contr := l_calc_ARREAR_UIF - l_prev_excs_er_cntr ;

             l_diff_ee_contr := l_calc_ee_contr ;
             l_diff_er_contr := l_calc_empr_contr ;
             l_diff_excs_er_contr := l_calc_ARREAR_UIF ;

             hr_utility.trace('Differences :'||l_diff_ee_contr|| '   '|| l_diff_er_contr||'   '||l_diff_excs_er_contr);

             -- get element_entry_id for previous UIF contribution element
             open c_get_ee_id(l_ee_contr_ele_type_id, l_assact_id);
             fetch c_get_ee_id into l_ee_contr_ee_id ;
             close c_get_ee_id ;

             hr_utility.trace('Element entry ID of prev UIF contri elem :'||l_ee_contr_ee_id);

             -- Create element entries for the differences
             hr_utility.trace('Creating element entry for Employee COntribution');
             if l_diff_ee_contr <> 0 then
                 create_retro_ele_entry(l_ee_contr_ele_type_id
                                  ,l_retro_ee_contr_ele_type_id
                                  ,l_retro_ee_contr_ip_value_id
                                  ,p_payroll_id
                                  ,l_assact_id
                                  ,l_asg_id
                                  ,l_eff_date
                                  ,p_reflection_date
                                  ,l_time_prd_id
                                  ,l_diff_ee_contr
                                  ,l_ee_contr_ee_id
                                  );
                 hr_utility.set_location(l_proc_name,100);
             end if ;

             hr_utility.trace('Creating element entry for Employer COntribution');
             if l_diff_er_contr <> 0 then
                 create_retro_ele_entry(l_er_contr_ele_type_id
                                  ,l_retro_er_contr_ele_type_id
                                  ,l_retro_er_contr_ip_value_id
                                  ,p_payroll_id
                                  ,l_assact_id
                                  ,l_asg_id
                                  ,l_eff_date
                                  ,p_reflection_date
                                  ,l_time_prd_id
                                  ,l_diff_er_contr
                                  ,l_ee_contr_ee_id
                                  );
                 hr_utility.set_location(l_proc_name,110);
             end if ;

             hr_utility.trace('Creating element entry for Excess Employer COntribution');
             if l_diff_excs_er_contr <> 0 then
                 create_retro_ele_entry(l_excs_er_contr_ele_type_id
                                  ,l_retro_excs_er_cntr_ele_tp_id
                                  ,l_retro_excs_er_cntr_ip_val_id
                                  ,p_payroll_id
                                  ,l_assact_id
                                  ,l_asg_id
                                  ,l_eff_date
                                  ,p_reflection_date
                                  ,l_time_prd_id
                                  ,l_diff_excs_er_contr
                                  ,l_ee_contr_ee_id
                                  );
                 hr_utility.set_location(l_proc_name,120);
             end if ;

             /**********************************
              ***** Printing the report ********
              **********************************/

             if l_diff_ee_contr <>0 or l_diff_er_contr <>0 or l_diff_excs_er_contr <>0 then
                   if l_header_printed = false then
                      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'The following Assignments have been processed for the below mentioned calendar months -');
                      l_header_printed := true ;
                   end if;
                   if l_last_printed_asg <> l_asg_id then
                       FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
                       FND_FILE.PUT_LINE(FND_FILE.LOG,'-------------------');
                       FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
                       FND_FILE.PUT_LINE(FND_FILE.LOG,'Assignment Number : '||rec_assact(rec_count).assignment_number);
                       FND_FILE.PUT_LINE(FND_FILE.LOG,'Assignment ID     : '||l_asg_id);
                   end if ;
                   l_last_printed_asg := l_asg_id ;
                   FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Duration          :' || rec_assact(rec_count).month_yr);
                   FND_FILE.PUT_LINE(FND_FILE.LOG,lpad(' ',32,' ')|| lpad('Existing Value',25,' ')||lpad('Expected Value',25,' ')||lpad('Retro Element Entry Amount',30,' ') );
             end if ;

             if l_diff_ee_contr<>0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('Employee Contributions :',32,' ') ||lpad(l_prev_ee_cntr,25,' ')|| lpad((l_prev_ee_cntr+l_diff_ee_contr),25,' ')|| lpad(l_diff_ee_contr,30,' '));
             end if ;

             if l_diff_er_contr <> 0 then
                  -- Bug  7175221
                  -- Empr Contr balance = empr contribution  + Excess empr contribution
                  -- hence subtract excess empr contribution from Empr Contr Bal to get the actual Empr Contribution
                  l_prev_er_cntr :=  l_prev_er_cntr - nvl(l_prev_excs_er_cntr,0);
                  FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('Employer Contributions :',32,' ')||lpad(l_prev_er_cntr,25,' ')|| lpad((l_prev_er_cntr+l_diff_er_contr),25,' ')|| lpad(l_diff_er_contr,30,' '));
             end if ;

             if l_diff_excs_er_contr <> 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('Excess Employer Contributions :',32,' ')||lpad(l_prev_excs_er_cntr,25,' ')|| lpad((l_prev_excs_er_cntr+l_diff_excs_er_contr),25,' ')|| lpad(l_diff_excs_er_contr,30,' '));
             end if ;

        else
            hr_utility.trace('Process already run for assignment_id :'||l_asg_id);
        end if ;

        hr_utility.trace('Completed processing for Assignment :'||rec_assact(rec_count).assignment_id||'  Month Year :'||rec_assact(rec_count).month_yr);
        exception
           when excp_uif_manipulated then
               unprocessed_asgn_count := unprocessed_asgn_count + 1 ;
               unprocessed_assignments(unprocessed_asgn_count).assignment_id := rec_assact(rec_count).assignment_id;
               unprocessed_assignments(unprocessed_asgn_count).assignment_number := rec_assact(rec_count).assignment_number;
               unprocessed_assignments(unprocessed_asgn_count).month_yr := rec_assact(rec_count).month_yr;
        end ;
     end loop;

     -- Print unprocessed assignments in the log file
     if unprocessed_asgn_count > 0 then
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('-',120,'-'));
        FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('-',120,'-'));
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'The following Assignments were not processed for the below mentioned calendar months,');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'as UIF contributions for these have been manually adjusted.');
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Please review the same and perform the adjustments as required.');
        FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('Assignment Number',50)|| rpad('Calendar Month',20));
        FND_FILE.PUT_LINE(FND_FILE.LOG,rpad('-',45,'-')|| rpad(' ',5,' ')||rpad('-',20,'-'));
        for asgn_count in unprocessed_assignments.first .. unprocessed_assignments.last
        loop
            FND_FILE.PUT_LINE(FND_FILE.LOG,rpad(unprocessed_assignments(asgn_count).assignment_number,50)|| rpad(unprocessed_assignments(asgn_count).month_yr,'20'));
        end loop ;
     end if;

     FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    -- Clear PL/SQL table
    --rec_assact.DELETE ;
    commit ;

    hr_utility.trace('Exiting '||l_proc_name);
    hr_utility.trace('Trace for UIF Refund March 2008 ends');
end create_uif_backdated_entries;

end PAY_ZA_UIF_REFUND_MARCH_2008;

/
