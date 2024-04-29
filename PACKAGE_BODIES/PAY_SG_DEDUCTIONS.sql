--------------------------------------------------------
--  DDL for Package Body PAY_SG_DEDUCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SG_DEDUCTIONS" AS
/*  $Header: pysgdedn.pkb 120.10.12010000.4 2009/03/13 10:43:18 vaisriva ship $
**
**  Copyright (c) 2002 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in SG deduction formula
**
**  Change List
**  ===========
**
**  Date        Author   Reference    Bug Number        Description
**  =========== ======== =========    ==========	=====================
**  26 Jun 2000 makelly  115.0     			Initial
**  6  Apr 2002 Ragovind 115.4     			Added Sg_get_Prorator function
**  10 Apr 2002 Ragovind 115.6     			Modified the sg_get_prorator function.
**  10 apr 2002 Ragovind 115.7     			Added comments to sg_get_prorator about functionality of CPF Proration calculation.
**  28 Jun 2002 SRussell 115.9     			Added CPF Retropay functions.
**  26 Jul 2002 SRussell 115.10    			Changed exception clause and Table order.
**  06 Aug 2002 Kaverma  115.11       2494173		modified sg_get_prorator function(Bug No - 2494173).
**  07 Aug 2002 Kaverma  115.12    			Modified fwl_amount function
**  02 Sep 2002 Ragoivnd 115.13    			Added Function get_prev_year_ord_ytd
**  19 Sep 2002 Ragovind 115.14    			Modified the cursor c_tax_unit_id
**  04 Oct 2002 vgsriniv 115.15    			Modified fwl_amount function
**  17 Oct 2002 apunekar 115.16    			Modified cursor c_get_dates to add distinct clause
**  17 Oct 2002 apunekar 115.17    			Added comments
**  06 Nov 2002 Ragovind 115.18    			Modified the cursor c_get_per_start_end_dates for CPF Calculation
**  11 Dec 2002 Apunekar 115.19    			Added nocopy to out or in out parameters
**  20 Dec 2002 Ragovind 115.20       2475324		Added CPF Report Coding.
**  29 Jan 2002 JLin     115.21       2772106		Modified cursor c_get_per_start_end_dates
**  11 Feb 2003 Ragovind 115.22       2796093   	Modified the CPF Report code for Correct CPF for Terminated Employees.
**  19 Mar 2003 Ragovind 115.23       2858065  		Corrected CPF prorator factor for Termination and Rehire employee in the same month
**  27 Mar 2003 Ragovind 115.24       2873083 	 	Corrected CPF prorator factor for Term/Rehire in same month and run Quickpay for the
**                                 			Terminated Employee Assignment.
**  02 Jan 2004 Nanuradh 115.25       3331018  		Removed the cursor c_get_prev_ord_ytd, instead used
**                                 			pay_balance.get_value to get prev year ordinary earnings ytd value.
**  02 Jan 2004 Nanuradh 115.26       3331018  		Modified the function get_prev_year_ord_ytd by initializing the
**                                 			variable l_prev_ord_ytd to zerio.
**  21 Jan 2004 agore    115.27       3279235 		Modified the function get_prev_year_ord_ytd ( ) to refer monthly balance
**                                 			values of following balances to arrive at Annual CPF eligible OW with monthly ceiling
**                                 			of 5500.CPF_ORDINARY_EARNINGS_ELIGIBLE_COMP, ORDINARY_EARNINGS_INELIGIBLE_FOR_CPF
**                                 			and RETRO_ORD_RETRO_PERIOD
**                                 			Added new functions get_cur_year_ord_ytd ( ) and get_retro_earnings( )
**  18 May 2004 Nanuradh 115.28       3595103 		Added new function spl_amount( ) to calculate S Pass Levy for permit type SP.
**  18 May 2004 Nanuradh 115.32       3595103 		Modified function sg_get_prorator() for permit type 'SP'
**  24 Jun 2004 abhargav 115.35        			Undo the changes of the Bug#3677801
**  31 Jan 2005 snimmala 115.36       4149190		Modified the function sg_get_prorator() to calculate total days as number of
**							working days instead of days in the payroll period.
**  27 Jun 2005 JLin     115.37       4267196           Performance issue, modified the function get_prev_year_ord_ytd
**                                                      and get_cur_year_ord_ytd to replace ppa.date_earned with ppa.effective_date
**  09 Jun 2006 JLin     115.39       5298298           Modified the function
**                                                      get_prev_year_ord_ytd and
**                                                      get_cur_year_ord_ytd to
**                                                      include all assignments.
**                                                      (eg.,rehire to include original assignment)
**  13 Jun 2006 JLin     115.40       5298298           To include the Legal Entity
**                                                      check for previous fix
**  14 Jun 2006 JLin     115.41,42    5298298           To include the multi-assignments
**  23 Jun 2006 snimmala 115.43       5353558           Modified the sql query of the cursor get_retro_method
**                                                      in the function which_retro_method.
**  27 Jun 2006 snimmala 115.44       5353558           Removed the check for 'Information' classification
**                                                      in the function which_retro_method.
**  14 Sep 2006 snimmala 115.45       5410589           Function fwl_amount() has been modified to check whether
**                                                      permit category is valid for pay period or not.
**  21 May 2007 snimmala 115.46       6046808           Modified the cursor c_get_dates in the function fwl_amount
**                                                      to move order by clause to outer query.
**  02 Jul 2007 jalin    115.47       6158284           Modified the cursor c_get_dates in the function fwl_amount
**                                                      to add currect employee check
** 22 Feb 2008  jalin    115.48       6815874           Modified calling function
**                                                      get_retro_earnings to use
**                                                      l_effective as parameter
**                                                      Modified cursor c_pay_element_entries
**                                                      to get correct retro values
**                                                      Removed parameter ass_act_id from get_retro_earnings function
** 27 Mar 2008  jalin    115.49       6815874           Added fix if retro ord
**                                                      is neg
** 12-Mar-2009  vaisriva 115.50       7661439           Added code for the new balance 'Ordinary Earnings Ineligible
**                                                      For CPF Calc'

**  ============== Formula Fuctions ====================
**  Package containing addition processing required by
**  formula in SG localisation
*/

/*
**  fwl_amount - returns the amount of foreign workers levy
**  due in a month
**
**  Error return codes used - messages raised in fast formula
**
**  -77  Invalid dates used for Work Permit
**  -88  Work Permit Category is null
**  -99  Unhandled Exception
*/

function  fwl_amount ( p_business_group_id in     number
                     , p_date_earned       in     date
                     , p_assignment_id     in     number
                     , p_start_date        in     date
                     , p_end_date          in     date   )
          return number is


TYPE t_permit_dates_rec is record   (  permit_category  varchar2(60)
                                     , date_start       date
                                     , date_end         date
                                     , date_cancel      date
                                     , effective_start_date date) ;

TYPE t_permit_dates_tab is table of t_permit_dates_rec index by binary_integer ;

l_permit              t_permit_dates_tab;
l_counter             number;
l_amt                 number              := 0;
l_mth_amt             number;
l_dly_amt             number;
l_days                number              := 0;
l_tot_days            number              := 0;
l_max_days            number              := 0;
l_category            varchar2(60);
l_same_category       boolean             := TRUE;
l_sot                 date;
l_eot                 date;
l_proc                varchar2(60);
l_start		      date;
l_end		      date;
l_months	      number;
l_value               number;

/*Bug#2626075-Distinct added in c_get_dates cursor*/
/*Bug#6046808 - Moved Order By clause to Outer Query */
/*Bug#6158284 - Added current employee flag check */

cursor c_get_dates       (  p_assignment_id NUMBER
                          , p_start_date    DATE
                          , p_end_date      DATE   ) is
select distinct * from
(
select per_information8
     , to_date(per_information9,  'YYYY/MM/DD HH24:MI:SS')
     , to_date(per_information10, 'YYYY/MM/DD HH24:MI:SS')
     , to_date(per_information11, 'YYYY/MM/DD HH24:MI:SS')
     , effective_start_date
  from per_all_people_f        per
 where per.person_id = (select max(paf.person_id)
                          from per_all_assignments_f paf
                         where paf.assignment_id = p_assignment_id)
   and per.per_information6 = 'WP'
   and nvl(per.current_employee_flag,'N') = 'Y' /* Bug 6158284 */
   and per.effective_start_date <= p_end_date
   and per.effective_end_date   >= p_start_date)
   order by effective_start_date;

/*Bug#5410589 - Following cursor has been added to check whether permit category is valid
                for this pay period or not*/

cursor c_check_permit_type(p_permit_category  per_all_people_f.per_information8%type
                          ,p_date_earned DATE)
is
select CINST.value
from   pay_user_tables                    tab
      ,pay_user_columns                   col
      ,pay_user_rows_f                    r
      ,pay_user_column_instances_f        cinst
where  tab.user_table_name = 'FWL_RATES'
and    col.user_table_id   = tab.user_table_id
and    upper(col.user_column_name)= upper('Daily Rate')
and    cinst.user_column_id = col.user_column_id
and    r.user_table_id = tab.user_table_id
and    r.ROW_LOW_RANGE_OR_NAME = p_permit_category
and    cinst.user_row_id = r.user_row_id
and    p_date_earned between cinst.effective_start_date and cinst.effective_end_date;

begin
  l_sot    := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
  l_eot    := to_date('4712/12/31 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
  l_proc   := 'pay_sg_deductions.fwl_amount';


  hr_utility.set_location('Entering : '||l_proc, 5);

  l_counter := 1;

  open c_get_dates( p_assignment_id, p_start_date, p_end_date) ;
  fetch c_get_dates into l_permit(l_counter);
  if c_get_dates%notfound then
    hr_utility.set_location('Leaving - No fwl in month : '||l_proc, 10);
    return 0;
  end if;

  l_counter := l_counter + 1;

  fetch c_get_dates into l_permit(l_counter);

  while c_get_dates%found loop
    l_counter := l_counter + 1;
    fetch c_get_dates into l_permit(l_counter);
  end loop;

  close c_get_dates;

    l_max_days := least (nvl(l_permit(l_permit.last).date_end, l_eot), nvl(l_permit(l_permit.last).date_cancel, l_eot)) -  p_start_date + 1;
  l_category := l_permit(1).permit_category;

  if l_category is not null then
    /*Bug#5410589 */
    open c_check_permit_type(l_category,p_date_earned);
    fetch c_check_permit_type into l_value;
    if c_check_permit_type%notfound then
         return(-66);
    end if;
    close c_check_permit_type;

    l_mth_amt := to_number(hruserdt.get_table_value (p_bus_group_id   => p_business_group_id
                                                    ,p_table_name     => 'FWL_RATES'
                                                    ,p_col_name       => 'Monthly Rate'
                                                    ,p_row_value      => l_category
                                                    ,p_effective_date => p_date_earned ));

    l_dly_amt := to_number(hruserdt.get_table_value (p_bus_group_id   => p_business_group_id
                                                    ,p_table_name     => 'FWL_RATES'
                                                    ,p_col_name       => 'Daily Rate'
                                                    ,p_row_value      => l_category
                                                    ,p_effective_date => p_date_earned ));

  end if;


  FOR i in 1..l_permit.last LOOP

    if l_permit(i).permit_category is null then

        hr_utility.set_location('Error - WP Category is null : '||l_proc, 88);
        return (-88);

    else

      if      (l_permit(i).date_start  > l_permit(i).date_end)
           OR (l_permit(i).date_start  > l_permit(i).date_cancel) THEN

        hr_utility.set_location('Invalid Date Ranges Within Month: '||l_proc, 77);
        return (-77);


      elsif (l_permit(i).date_start  > p_end_date  )
           OR (l_permit(i).date_end    < p_start_date)
           OR (l_permit(i).date_cancel < p_start_date) THEN

        null;

      else
        /*Bug#5410589 */
        open c_check_permit_type(l_permit(i).permit_category,p_date_earned);
        fetch c_check_permit_type into l_value;
        if c_check_permit_type%notfound then
           return(-66);
        end if;
        close c_check_permit_type;

        if l_permit(i).permit_category <> l_category then

          l_same_category := FALSE;

        end if;
        l_start := greatest (nvl(l_permit(i).date_start, l_sot), p_start_date);
        l_end := least (nvl(l_permit(i).date_end, l_eot), nvl(l_permit(i).date_cancel, l_eot));
        /* Bug 2610156 : Least of l_end and Pay Period end date should be
           used to calculate number of days(i.e., l_days)
           l_end is the least of expiry date and cancellation date */
        l_end := least(l_end,p_end_date);

        l_days := greatest ((l_end - l_start)+1, 0 );
        l_months := round(months_between(l_end + 1,l_start),2);


        l_days := greatest ((l_end - l_start)+1, 0 );

        l_tot_days := l_tot_days + l_days;


        if l_tot_days > l_max_days then

          hr_utility.set_location('Invalid Date Ranges Within Month : '||l_proc, 77);
          return (-77);

        end if;

        if l_same_category then
          if l_months >= 1 then
            l_amt := l_mth_amt;
          else
            l_amt := least(l_mth_amt, (l_amt + (l_dly_amt * l_days)));
          end if;

        else

          l_mth_amt  := to_number(hruserdt.get_table_value (p_bus_group_id   => p_business_group_id
                                                           ,p_table_name     => 'FWL_RATES'
                                                           ,p_col_name       => 'Monthly Rate'
                                                           ,p_row_value      => l_permit(i).permit_category
                                                           ,p_effective_date => p_date_earned ));

          l_dly_amt  := to_number(hruserdt.get_table_value (p_bus_group_id   => p_business_group_id
                                                           ,p_table_name     => 'FWL_RATES'
                                                           ,p_col_name       => 'Daily Rate'
                                                           ,p_row_value      => l_permit(i).permit_category
                                                           ,p_effective_date => p_date_earned ));
	  if l_months >= 1 then
	    l_amt := l_mth_amt;
	  else
            l_amt := l_amt + least(l_mth_amt, (l_dly_amt * l_days));
          end if;

        end if;

      end if;

    end if;

  END LOOP;

  hr_utility.set_location('Leaving:'||l_proc, 20);
  return l_amt;

  EXCEPTION
       WHEN others THEN
         hr_utility.set_location('Unhandled Exception in function call fwl_amount : '||l_proc, 99);
         RETURN -99;

end fwl_amount;

/* Bug: 3595103 - New function to calculate S Pass Levy */
function  spl_amount ( p_business_group_id in     number
                     , p_date_earned       in     date
                     , p_assignment_id     in     number
                     , p_start_date        in     date
                     , p_end_date          in     date   )
          return number is

TYPE t_permit_dates_rec is record   (permit_type varchar2(5)
                                     , date_start       date
                                     , date_end         date
                                     , date_cancel      date      ) ;

TYPE t_permit_dates_tab is table of t_permit_dates_rec index by binary_integer ;

l_permit              t_permit_dates_tab;
l_counter             number;
l_amt                 number              := 0;
l_mth_amt             number;
l_dly_amt             number;
l_days                number              := 0;
l_tot_days            number              := 0;
l_max_days            number              := 0;
l_category            varchar2(60);
l_same_category       boolean             := TRUE;
l_sot                 date;
l_eot                 date;
l_proc                varchar2(60);
l_start		      date;
l_end		      date;
l_months	      number;

cursor c_get_dates       (  p_assignment_id NUMBER
                          , p_start_date    DATE
                          , p_end_date      DATE   ) is
select distinct * from
(
select per_information6
     , to_date(per_information9,  'YYYY/MM/DD HH24:MI:SS')
     , to_date(per_information10, 'YYYY/MM/DD HH24:MI:SS')
     , to_date(per_information11, 'YYYY/MM/DD HH24:MI:SS')
  from per_all_people_f        per
 where per.person_id = (select max(paf.person_id)
                          from per_all_assignments_f paf
                         where paf.assignment_id = p_assignment_id)
   and per.per_information6 = 'SP'
   and per.effective_start_date <= p_end_date
   and per.effective_end_date   >= p_start_date
 order by per.effective_start_date);


begin
  l_sot    := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
  l_eot    := to_date('4712/12/31 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
  l_proc   := 'pay_sg_deductions.spl_amount';

  hr_utility.set_location('Entering : '||l_proc, 5);

   l_counter := 1;

  open c_get_dates( p_assignment_id, p_start_date, p_end_date) ;
  fetch c_get_dates into l_permit(l_counter);
  if c_get_dates%notfound then
    hr_utility.set_location('Leaving - No fwl in month : '||l_proc, 10);
    return 0;
  end if;

  l_counter := l_counter + 1;

  fetch c_get_dates into l_permit(l_counter);

  while c_get_dates%found loop
    l_counter := l_counter + 1;
    fetch c_get_dates into l_permit(l_counter);
  end loop;

  close c_get_dates;

    l_max_days := least (nvl(l_permit(l_permit.last).date_end, l_eot), nvl(l_permit(l_permit.last).date_cancel, l_eot)) -  p_start_date + 1;
    l_category := 'SP';
  if l_category is not null then

    l_mth_amt := to_number(hruserdt.get_table_value (p_bus_group_id   => p_business_group_id
                                                    ,p_table_name     => 'FWL_RATES'
                                                    ,p_col_name       => 'Monthly Rate'
                                                    ,p_row_value      => l_category
                                                    ,p_effective_date => p_date_earned ));

    l_dly_amt := to_number(hruserdt.get_table_value (p_bus_group_id   => p_business_group_id
                                                    ,p_table_name     => 'FWL_RATES'
                                                    ,p_col_name       => 'Daily Rate'
                                                    ,p_row_value      => l_category
                                                    ,p_effective_date => p_date_earned ));

  end if;


  FOR i in 1..l_permit.last LOOP
      if (l_permit(i).date_start  > l_permit(i).date_end)
         OR (l_permit(i).date_start  > l_permit(i).date_cancel) THEN

         hr_utility.set_location('Invalid Date Ranges Within Month: '||l_proc, 77);
         return (-77);


      elsif (l_permit(i).date_start  > p_end_date  )
             OR (l_permit(i).date_end    < p_start_date)
             OR (l_permit(i).date_cancel < p_start_date) THEN

             null;
      else
             l_start := greatest (nvl(l_permit(i).date_start, l_sot), p_start_date);
             l_end := least (nvl(l_permit(i).date_end, l_eot), nvl(l_permit(i).date_cancel, l_eot));
             l_end := least(l_end,p_end_date);

             l_days := greatest ((l_end - l_start)+1, 0 );
             l_months := round(months_between(l_end + 1,l_start),2);


             l_tot_days := l_tot_days + l_days;

             if l_tot_days > l_max_days then
                 hr_utility.set_location('Invalid Date Ranges Within Month : '||l_proc, 77);
                 return (-77);
             end if;

             if l_months >= 1 then
                l_amt := l_mth_amt;
             else
                l_amt := least(l_mth_amt, (l_amt + (l_dly_amt * l_days)));
             end if;

        end if;

  END LOOP;

  hr_utility.set_location('Leaving:'||l_proc, 20);
  return l_amt;

  EXCEPTION
       WHEN others THEN
         hr_utility.set_location('Unhandled Exception in function call spl_amount : '||l_proc, 99);
         RETURN -99;

end spl_amount;


function sg_get_prorator   ( p_assignment_id       in  number,
                             p_date_earned         in  date,
                             p_pay_proc_start_date in  date,
                             p_pay_proc_end_date   in  date,
                             p_wac		   in  varchar2,
                             p_cpf_calc_type       out nocopy varchar2
                           ) return number is

l_wac             varchar2(2);
l_effective_date  date;
start_date        date;
start_wac         varchar2(2);
prorate_date      date;
prorate_wac       varchar2(2);
l_prorator        number;
l_days            number;
l_total_days      number;
l_assign_start_date date;
l_assign_end_date   date;
l_proc_start_date   date;
l_proc_end_date     date;
l_emp_start_bet_period varchar2(1);
l_emp_end_bet_period   varchar2(1);
l_proc            varchar2(60);

/* Cursor declaration */
cursor c_get_per_start_end_dates (c_assignment_id       number ,
                              c_pay_proc_start_date date,
                              c_pay_proc_end_date   date)
       is
       select min(pap.effective_start_date),max(pap.effective_end_date) /*bug 2772106 */
         from per_all_people_f pap,
              per_all_assignments_f target
        where target.assignment_id = c_assignment_id
          and pap.person_id = target.person_id
          and nvl(pap.current_employee_flag,'N') = 'Y';

cursor c_get_wac ( c_assignment_id       NUMBER,
                   c_date                DATE )
       is
       select target.PER_INFORMATION6,
              target.EFFECTIVE_START_DATE
         from per_all_people_f               target
        where target.person_id = (select paf.person_id
                                    from per_all_assignments_f paf
                                   where paf.assignment_id = c_assignment_id
                                     and c_date between paf.effective_start_date and paf.effective_end_date )
          and c_date between target.effective_start_date and target.effective_end_date;

begin
  l_prorator  := -1.0;
  l_emp_start_bet_period  := 'N';
  l_emp_end_bet_period    := 'N';
  l_proc      := 'pay_sg_deductions.sg_get_prorator';

 /* Get the WAC effective at start of the pay period */
  hr_utility.set_location('Entering : '||l_proc, 5);
  hr_utility.trace('p_assignment_id : '||p_assignment_id);
  hr_utility.trace('p_pay_proc_start_date : '||p_pay_proc_start_date );
  hr_utility.trace('p_pay_proc_end_date   : '||p_pay_proc_end_date   );
  hr_utility.trace('p_date_earned         : '||p_date_earned         );
  hr_utility.trace('p_wac                 : '||p_wac);

  p_cpf_calc_type  := p_wac ; /* assign the default value of WAC for the person as WAC exist at period end date */

  open c_get_per_start_end_dates(p_assignment_id , p_pay_proc_start_date, p_pay_proc_end_date);
  fetch c_get_per_start_end_dates into l_assign_start_date,l_assign_end_date;

  if c_get_per_start_end_dates%NOTFOUND then
    close c_get_per_start_end_dates;
    hr_utility.set_location('Error : Assignment does not exist in the pay process period'||l_proc,5);
  else
    if (l_assign_start_date > p_pay_proc_start_date ) then
       l_proc_start_date := l_assign_start_date;
    else
       l_proc_start_date := p_pay_proc_start_date;
    end if;
    if (l_assign_end_date < p_pay_proc_end_date ) then
       l_proc_end_date := l_assign_end_date;
    else
       l_proc_end_date := p_pay_proc_end_date;
    end if;
  end if;

    open c_get_wac( p_assignment_id , l_proc_start_date );
    fetch c_get_wac into l_wac, l_effective_date;
    if c_get_wac%NOTFOUND then
       close c_get_wac;
       hr_utility.set_location('Error : Assignment doesnot exist at the pay proc start date'||l_proc,10);
       return 1;  /* Bug#2858065 */
    end if;
    close c_get_wac;
    /* store the wac at the start of the period */
    start_wac := l_wac;
    /* store the wac effective start date */
    start_date := l_effective_date;

   /* if wac effective start date is less than pay proc start date,then
   set the pay proc start date as the start_date */
   if (l_effective_date < p_pay_proc_start_date) then
    start_date := p_pay_proc_start_date;
   end if;

   hr_utility.trace('start_wac : '||start_wac);
   hr_utility.trace('start_date : '||start_date);

   /* Get the WAC and at the period end date*/

  open c_get_wac( p_assignment_id,l_proc_end_date);
  fetch c_get_wac into l_wac, l_effective_date;
  if c_get_wac%NOTFOUND then
    close c_get_wac;
    hr_utility.set_location('Error : Assignment doesnot exist at the pay proc end date (ie terminated)'||l_proc,20);
    return 1; /* Bug#2873083 */
  end if;
  close c_get_wac;

  /* store the wac at the end of the pay period*/
  prorate_wac  := l_wac;
  /* store the effective start date for the above wac*/
  prorate_date := l_effective_date;

  /* if wac effective start date is less than pay proc start date ,then
   set the pay proc start date as the prorate_date */

  if (l_effective_date < p_pay_proc_start_date ) then
    prorate_date := p_pay_proc_start_date;
  end if;

  hr_utility.trace('prorate_wac : '||prorate_wac);
  hr_utility.trace('prorate_date : '||prorate_date);

  if (p_date_earned <> start_date ) then
       l_total_days := fffunc.days_between(l_proc_end_date , l_proc_start_date)+1;
-------------------------------------------------------------------------------------------------
--Bug# 4149190
--p_pay_proc_start_date, p_pay_proc_end_date are replaced by l_proc_start_date,
--l_proc_end_date respectively.
-------------------------------------------------------------------------------------------------
       hr_utility.trace('l_total_days : '||l_total_days );
  end if;

  /* Proration Calculation Block */
  /* If the employee start date or end date is in between the pay period then
    for proration we have to take the employee start / end date instead of period
    start/end date .That is , if the employee has started in between the pay period,then
    we will take this date for the calculation of proration instead of pay period start date.
    Similarly if the emplyee is terminated in between then we will take the termination date
    instead of period end date.In such case the proration is calculated for example
    from employee start date to period end date divided by the number of days in the period*/

   If (l_proc_start_date > p_pay_proc_start_date and l_proc_start_date < p_pay_proc_end_date) then
     l_emp_start_bet_period := 'Y';
   end if;

   If (l_proc_end_date > p_pay_proc_start_date and l_proc_end_date < p_pay_proc_end_date) then
     l_emp_end_bet_period := 'Y';
   end if;

   if (start_wac = prorate_wac and (start_wac = 'PR' or start_wac = 'SG')) then
      p_cpf_calc_type := prorate_wac; /*2494173*/
      l_prorator := 1.0;
  else
  /* Proration need to be accounted for the eligible duration of pay period */
  /* Bug: 3595103 - Modified get_sg_prorator for Permit type S Pass - SP    */

      if ((start_wac = 'PR' or start_wac = 'SG') and (prorate_wac = 'EP' or prorate_wac = 'WP' or start_wac = 'SP'))then
        /* Need to calculate the proration for the first period, since the wac in the second period is
           not eligible for CPF*/
          l_days := fffunc.days_between(prorate_date,start_date);
          p_cpf_calc_type := start_wac;
          l_prorator := l_days / l_total_days;
          hr_utility.trace('p_cpf_calc_type :'||p_cpf_calc_type);
          hr_utility.trace('l_days : '||l_days );

      elsif ((start_wac = 'WP' or start_wac = 'EP' or start_wac = 'SP') and (prorate_wac = 'PR' or prorate_wac = 'SG')) then
        /* Need to calculate the proration for the second period and first period does not have
           eligible for the CPF Proration */
          l_days := fffunc.days_between(l_proc_end_date,prorate_date)+1;
                                /* Added +1 to include prorate date also */
          hr_utility.trace('l_days : '||l_days );
          p_cpf_calc_type := prorate_wac;
          l_prorator := l_days / l_total_days;

      elsif ((start_wac = 'SG' or start_wac = 'PR') and (prorate_wac = 'SG' or prorate_wac = 'PR')) then
        /* Need not calculate the CPF Calculation. Hence setting the l_prorator value to 1 and the
        CPF Calcualtion type to prorate type */
         if (l_emp_start_bet_period = 'Y' and l_emp_end_bet_period = 'Y' ) then
	      l_days := fffunc.days_between(l_proc_end_date, l_proc_start_date)+1;
            l_prorator := l_days/l_total_days;

         elsIf (l_emp_start_bet_period = 'Y') then
           l_days := fffunc.days_between(p_pay_proc_end_date, l_proc_start_date)+1;
           l_prorator := l_days/l_total_days;

         elsif (l_emp_end_bet_period = 'Y') then
           l_days := fffunc.days_between(l_proc_end_date,p_pay_proc_start_date)+1;
           l_prorator := l_days/l_total_days;

         else
	     l_prorator := 1.0;
         end if;
         p_cpf_calc_type := prorate_wac;

     elsif ((start_wac = 'WP' or start_wac = 'EP' or start_wac = 'SP') and
            (prorate_wac = 'WP' or prorate_wac = 'EP' or start_wac = 'SP')) then
     /* Need not calculate the CPF Calculation. Hence setting the l_prorator value to -1 and the
        CPF Calcualtion type to prorate type */
          l_prorator := -1.0;
          p_cpf_calc_type := prorate_wac;

     end if;
  end if;
 /* End of Proration Calculation */
  hr_utility.trace('p_cpf_calc_type :'||p_cpf_calc_type);
  hr_utility.trace('l_prorator : '||l_prorator);
  hr_utility.set_location('Leaving : '||l_proc, 5);

  return l_prorator;
end sg_get_prorator;

/*
**  This function will identify if the element being processed is a retropay element.
**  If it is a flag set to Y is returned.
*/

function check_if_retro
         (
           p_element_entry_id  in pay_element_entries_f.element_entry_id%TYPE,
           p_date_earned in pay_payroll_actions.date_earned%TYPE
         ) return varchar2 IS

cursor c_get_creator_type(
     c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE,
     c_date_earned in pay_payroll_actions.date_earned%TYPE
                         ) is
SELECT creator_type
  FROM pay_element_entries_f pee
  WHERE pee.element_entry_id = c_element_entry_id
  AND c_date_earned between pee.effective_start_date and pee.effective_end_date;

l_creator_type pay_element_entries_f.creator_type%TYPE;
IS_retro_payment varchar2(10);

begin

/*  Check creator_type to identify if its a retropay element.
**  Creator_type of RR (updated element entry) or EE (new element entry) indicates
**  it's a retropay element.
*/

   OPEN  c_get_creator_type(p_element_entry_id,p_date_earned);
   FETCH c_get_creator_type INTO l_creator_type ;
   CLOSE c_get_creator_type;
   if l_creator_type = 'RR' or l_creator_type = 'EE' then
       IS_retro_payment:='Y';
   else
       IS_retro_payment:='N';
   end if;

  return IS_retro_payment;

  EXCEPTION
      when others then
        IS_retro_payment:='N';

end check_if_retro;


/*
**  This function will identify which retropay method the retropay element was
**  created under.
**  Eg. Retropay method A indicates that CPF calculations are to be performed in the
**  current payroll period and therefore the Retropay By Element run had no CPF
**  elements in the element set.
**      Retropay method B indicates that CPF calculations are to be performed in the
**  period the retrospective payment was earnt therefore the Retropay By Element run
**  DID have CPF elements in the element set.
**
*/

function which_retro_method
         (
           p_assignment_id    in pay_assignment_actions.assignment_id%TYPE,
           p_date_earned      in pay_payroll_actions.date_earned%TYPE,
           p_element_entry_id in pay_element_entries_f.element_entry_id%TYPE
         ) return varchar2 IS

/*
**  Bug#5353558  Cursor to look for any CPF elements exists in the Element Set of
**  the retro pay, which has created this retro element.
*/

cursor get_retro_method
         ( c_assignment_id in pay_element_entries_f.element_entry_id%TYPE,
           c_date_earned   in pay_payroll_actions.date_earned%TYPE,
           c_element_entry_id in pay_element_entries_f.element_entry_id%TYPE
         ) is
select pet.element_name
  from pay_element_entries_f pee,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_element_sets pes,
       pay_element_type_rules petr,
       pay_element_types_f pet
  where pee.creator_id = paa.assignment_action_id
  and   pee.assignment_id = c_assignment_id
  and   pee.creator_type in ('EE', 'RR')
  and   pee.element_entry_id = c_element_entry_id
  and   paa.payroll_action_id = ppa.payroll_action_id
  and   ppa.element_set_id = pes.element_set_id
  and   pes.element_set_id = petr.element_set_id
  and   petr.element_type_id = pet.element_type_id
  and   petr.include_or_exclude = 'I'
  and   c_date_earned between pet.effective_start_date and pet.effective_end_date
  and   c_date_earned between pee.effective_start_date and pee.effective_end_date
  and pet.element_name like '%CPF%'
  and pet.legislation_code = 'SG'
union all
select pec.classification_name
  from pay_element_entries_f pee,
       pay_assignment_actions paa,
       pay_payroll_actions ppa,
       pay_element_sets pes,
       pay_ele_classification_rules pecr,
       pay_element_classifications pec
  where pee.creator_id = paa.assignment_action_id
  and   pee.assignment_id = c_assignment_id
  and   pee.creator_type in ('EE', 'RR')
  and   pee.element_entry_id = c_element_entry_id
  and   paa.payroll_action_id = ppa.payroll_action_id
  and   ppa.element_set_id = pes.element_set_id
  and   pes.element_set_id = pecr.element_set_id
  and   pecr.classification_id = pec.classification_id
  and   c_date_earned between pee.effective_start_date and pee.effective_end_date
  and   pec.classification_name in ('Statutory Deductions', 'Employer Liabilities')
  and   pec.legislation_code = 'SG';

l_ele_rec        get_retro_method%ROWTYPE;
l_retro_method   varchar2(10);

begin

/*  Default to method A. */

    l_retro_method := 'A';

/*
**  Bug# 5353558 If any of the elements processed in the retro pay were CPF elements and
**  seeded then the retropay process must have been for Method B.
*/

    open get_retro_method(p_assignment_id,p_date_earned,p_element_entry_id);
    fetch get_retro_method into l_ele_rec;
    if  get_retro_method%FOUND then
        l_retro_method := 'B';
        close get_retro_method;
    end if;

    return l_retro_method;

end which_retro_method;

/*
**  This function will identify the earnings type of the retropay element.
**  If the balance it feeds is 'CPF Ordinary Earnings Eligible Comp' then it
**  must be classed as Ordinary Earnings (type O).
**  If the balance it feeds is 'CPF Additional Earnings Eligible Comp' then it
**  must be classed as Additional Earnings (type A).
**  If neither of these then leave blank.
*/

function earnings_type
         (
           p_element_type_id  in pay_element_types_f.element_type_id%TYPE
         ) return varchar2 IS

cursor c_earnings_type
         ( c_element_type_id   in pay_element_types_f.element_type_id%TYPE,
           c_balance_name      in pay_balance_types.balance_name%TYPE
         ) is
  select decode(pbt.balance_name,
    'CPF Ordinary Earnings Eligible Comp', 'O',
    'CPF Additional Earnings Eligible Comp', 'A', ' ')
    from pay_balance_types pbt,
           pay_balance_feeds_f pbf,
           pay_input_values_f pivf,
           pay_element_types_f petf
    where pbt.balance_type_id = pbf.balance_type_id
    and   pbf.input_value_id = pivf.input_value_id
    and   pivf.element_type_id = petf.element_type_id
    and   pbt.balance_name = c_balance_name
    and   petf.element_type_id = c_element_type_id;

l_earnings_type   varchar2(10);
l_balance_name    pay_balance_types.balance_name%TYPE;

begin
  l_earnings_type  := ' ';
  hr_utility.set_location('Entering Earnings Type : ', 5);
  hr_utility.set_location('Element Type Id : ' || p_element_type_id, 10);

  l_balance_name := 'CPF Ordinary Earnings Eligible Comp';
  open c_earnings_type(p_element_type_id, l_balance_name);
  fetch c_earnings_type into l_earnings_type;
  close c_earnings_type;

  if l_earnings_type <> 'O' then
     l_balance_name := 'CPF Additional Earnings Eligible Comp';
     open c_earnings_type(p_element_type_id, l_balance_name);
     fetch c_earnings_type into l_earnings_type;
     close c_earnings_type;
  end if;

  hr_utility.set_location('Earnings Type : ' || l_earnings_type, 15);

  return l_earnings_type;

  EXCEPTION
    when others then
      l_earnings_type := ' ';
      hr_utility.set_location('Exception Earnings Type : ', 20);

end earnings_type;
---------------------------------------------------------------------------
-- Function returns Previous Year Ordinary Earnings total with
-- Monthly ceiling of 5,500
---------------------------------------------------------------------------
function get_prev_year_ord_ytd
        (
           p_assignment_id   in pay_assignment_actions.assignment_id%TYPE,
           p_date_earned     in pay_payroll_actions.date_earned%TYPE
        )
return number is
    --
    cursor c_tax_unit_id( c_assignment_id number,
                          c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
    is
    select paa.tax_unit_id
      from pay_assignment_actions paa
     where paa.assignment_id = c_assignment_id
       and paa.assignment_action_id = c_assignment_action_id;
    --
    --------------------------------------------------------------------
    -- Bug 5298298, need to get action sequence to include all the assignment
    -- for the re-hire employee, it will include the original assignment. For
    -- multi-assignments with the same LE will be included.
    --------------------------------------------------------------------
    cursor c_month_year_action_sequence( c_assignment_id number,
 			                 c_date_earned   date )
    is
    select  max(paa.action_sequence),
            to_number(to_char(ppa.effective_date,'MM')),
            max(pas.person_id)
      from  per_assignments_f  pas,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
     where  (pas.person_id, paa.tax_unit_id)
                   IN (select pas1.person_id,
                             hsc1.segment1
                      from   per_assignments_f  pas1,
                             hr_soft_coding_keyflex hsc1
                      where  pas1.assignment_id     = c_assignment_id
                      and    pas1.soft_coding_keyflex_id = hsc1.soft_coding_keyflex_id
                      and    c_date_earned between pas1.effective_start_date and pas1.effective_end_date) /* Bug 5298298 */
       and  pas.assignment_id = paa.assignment_id
       and  ppa.payroll_action_id = paa.payroll_action_id
       and  ppa.action_type       in ('R','Q','B','V','I')
       and  ppa.effective_date       between trunc(add_months(c_date_earned,-12),'Y') /* Bug 4267196 */
                                      and trunc(c_date_earned,'Y') - 1
     group by  to_number(to_char(ppa.effective_date,'MM'))
     order by  to_number(to_char(ppa.effective_date,'MM')) desc;
    --
    cursor c_month_year_action ( c_person_id       number,
 			         c_date_earned     date,
                                 c_action_sequence number )
    is
    select  paa.assignment_action_id,
            ppa.effective_date,
            paa.assignment_id
      from  per_assignments_f pas,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
     where  pas.person_id = c_person_id /* Bug 5298298 */
       and  paa.assignment_id = pas.assignment_id
       and  ppa.payroll_action_id = paa.payroll_action_id
       and  paa.action_sequence   = c_action_sequence
       and  ppa.effective_date between trunc(add_months(c_date_earned,-12),'Y') /* Bug 4267196 */
                                and trunc(c_date_earned,'Y') - 1;
    --
    cursor c_defined_bal_id ( p_balance_name   in varchar2,
                              p_dimension_name in varchar2 )
        is
    select  pdb.defined_balance_id
      from  pay_defined_balances pdb,
            pay_balance_types pbt,
            pay_balance_dimensions pbd
     where  pbt.balance_name         = p_balance_name
       and  pbd.dimension_name       = p_dimension_name
       and  pbt.balance_type_id      = pdb.balance_type_id
       and  pdb.balance_dimension_id = pbd.balance_dimension_id
       and  pdb.legislation_code = 'SG';
    --
    cursor c_globals
        is
    select global_value
      from ff_globals_f
     where global_name = 'CPF_ORD_MONTH_CAP_AMT'
       and p_date_earned between effective_start_date and effective_end_date;
    --
    g_balance_value_tab    pay_balance_pkg.t_balance_value_tab;
    g_context_tab          pay_balance_pkg.t_context_tab;
    g_detailed_bal_out_tab pay_balance_pkg.t_detailed_bal_out_tab;
    --
    l_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
    l_action_sequence        pay_assignment_actions.action_sequence%TYPE;
    l_assignment_id          pay_assignment_actions.assignment_id%TYPE;
    l_person_id              per_assignments_f.person_id%TYPE;
    l_month                  number;
    l_effective_date         date;
    l_tax_unit_id            pay_assignment_actions.tax_unit_id%TYPE;
    l_defined_bal_id         number;
    l_prev_ord_ytd           number;
    l_ord_mon_cap_amt        number;
    l_retro_exist            boolean := FALSE ;
    l_retro_ele              number;
    l_retro_date             date;
begin
    l_prev_ord_ytd := 0;
    --
    open c_globals;
    fetch c_globals into l_ord_mon_cap_amt;
    close c_globals ;
    --
    g_balance_value_tab.delete;
    --
    open c_defined_bal_id('CPF Ordinary Earnings Eligible Comp','_PER_LE_MONTH');
    fetch c_defined_bal_id into g_balance_value_tab(1).defined_balance_id;
    close c_defined_bal_id;
    --
    open c_defined_bal_id('Ordinary Earnings ineligible for CPF','_PER_LE_MONTH');
    fetch c_defined_bal_id into g_balance_value_tab(2).defined_balance_id;
    close c_defined_bal_id;
    --
    open c_defined_bal_id('Retro Ord Retro Period','_ASG_PTD');
    fetch c_defined_bal_id into g_balance_value_tab(3).defined_balance_id;
    close c_defined_bal_id;
    --
    -- Start of Bug 7661439
    --
    open  c_defined_bal_id('Ordinary Earnings Ineligible For CPF Calc','_PER_LE_MONTH');
    fetch c_defined_bal_id into g_balance_value_tab(4).defined_balance_id;
    close c_defined_bal_id;
    --
    -- End of Bug 7661439
    --
    open c_month_year_action_sequence( p_assignment_id, p_date_earned );
    loop
         fetch c_month_year_action_sequence into l_action_sequence,l_month,l_person_id;

         exit when c_month_year_action_sequence%NOTFOUND;
         --
         open c_month_year_action( l_person_id, p_date_earned, l_action_sequence );
         fetch c_month_year_action into l_assignment_action_id,l_effective_date,l_assignment_id;

         --
         if c_month_year_action%FOUND then
              open c_tax_unit_id(l_assignment_id , l_assignment_action_id );
              fetch c_tax_unit_id into l_tax_unit_id;
              close c_tax_unit_id;
              --
              g_context_tab.delete;
              g_detailed_bal_out_tab.delete;
              --
              g_context_tab(1).tax_unit_id := l_tax_unit_id;
              g_context_tab(2).tax_unit_id := l_tax_unit_id;
              g_context_tab(3).tax_unit_id := l_tax_unit_id;
              g_context_tab(4).tax_unit_id := l_tax_unit_id;        -- Bug 7661439
              --
              pay_balance_pkg.get_value ( l_assignment_action_id,
                                          g_balance_value_tab,
                                          g_context_tab,
                                          false,
                                          false,
                                          g_detailed_bal_out_tab
                                        );
              --
              if l_retro_exist
                or nvl(g_detailed_bal_out_tab(3).balance_value,0) <> 0  then /* Bug 6815874 */
                    l_retro_ele   := get_retro_earnings( p_assignment_id , l_effective_date ); /* Bug 6815874 */
                    if l_retro_ele = 0 then /* Bug 6815874 */
                        l_retro_exist := FALSE;
                    end if;
                    l_prev_ord_ytd := l_prev_ord_ytd + least( (nvl( g_detailed_bal_out_tab(1).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(2).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(4).balance_value,0 )       -- Bug 7661439
                                                           - nvl( g_detailed_bal_out_tab(3).balance_value,0 )
                                                           + nvl(l_retro_ele,0)),l_ord_mon_cap_amt );
              else
                    l_prev_ord_ytd := l_prev_ord_ytd + least( (nvl( g_detailed_bal_out_tab(1).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(2).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(4).balance_value,0 )       -- Bug 7661439
                                                           - nvl( g_detailed_bal_out_tab(3).balance_value,0 )),l_ord_mon_cap_amt );
              end if;
              --
              if nvl( g_detailed_bal_out_tab(3).balance_value,0 ) <> 0 then
                  l_retro_exist := TRUE;
              end if;
              --
         end if;
         --
         close c_month_year_action;
    end loop;
    --
    close c_month_year_action_sequence;
    --
    return l_prev_ord_ytd;
    --
end get_prev_year_ord_ytd;

---------------------------------------------------------------------------
-- Function returns Current Year Ordinary Earnings total with
-- Monthly ceiling of 5,500
---------------------------------------------------------------------------
function get_cur_year_ord_ytd
        (
           p_assignment_id   in pay_assignment_actions.assignment_id%TYPE,
           p_date_earned     in pay_payroll_actions.date_earned%TYPE
        )
return number is
    --
    cursor c_tax_unit_id( c_assignment_id number,
                          c_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE)
    is
    select paa.tax_unit_id
      from pay_assignment_actions paa
     where paa.assignment_id = c_assignment_id
       and paa.assignment_action_id = c_assignment_action_id;
    --
    --------------------------------------------------------------------
    -- Bug 5298298, need to get action sequence to include all the assignment
    -- for the re-hire employee, it will include the original assignment. For
    -- multi-assignments with the same LE will be included.
    --------------------------------------------------------------------
    cursor c_month_year_action_sequence( c_assignment_id number,
 			                 c_date_earned   date )
    is
    select  max(paa.action_sequence),
            to_number(to_char(ppa.effective_date,'MM')),
            max(pas.person_id)
      from  per_assignments_f pas,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
     where  (pas.person_id, paa.tax_unit_id)
                  IN (select pas1.person_id,
                             hsc1.segment1
                      from   per_assignments_f  pas1,
                             hr_soft_coding_keyflex hsc1
                      where  pas1.assignment_id     = c_assignment_id
                      and    pas1.soft_coding_keyflex_id = hsc1.soft_coding_keyflex_id
                      and    c_date_earned between pas1.effective_start_date and pas1.effective_end_date) /* Bug 5298298 */
       and  pas.assignment_id = paa.assignment_id
       and  ppa.payroll_action_id = paa.payroll_action_id
       and  ppa.action_type       in ('R','Q','B','V','I')
       and  ppa.effective_date between trunc(c_date_earned,'Y') /* Bug 4267196 */
                                and last_day(add_months(c_date_earned,-1))
     group by  to_number(to_char(ppa.effective_date,'MM'))
     order by  to_number(to_char(ppa.effective_date,'MM')) desc;
    --
    cursor c_month_year_action ( c_person_id   number,
 			         c_date_earned     date,
                                 c_action_sequence number )
    is
    select  paa.assignment_action_id,
            ppa.effective_date,
            pas.assignment_id
      from  per_assignments_f pas,
            pay_assignment_actions paa,
            pay_payroll_actions ppa
     where  pas.person_id = c_person_id /* Bug 5298298 */
       and  paa.assignment_id = pas.assignment_id
       and  ppa.payroll_action_id = paa.payroll_action_id
       and  paa.action_sequence   = c_action_sequence
       and  ppa.effective_date between trunc(c_date_earned,'Y') /* Bug 4267196 */
                                and last_day(add_months(c_date_earned,-1)) ;
    --
    cursor c_defined_bal_id ( p_balance_name   in varchar2,
                              p_dimension_name in varchar2 )
        is
    select  pdb.defined_balance_id
      from  pay_defined_balances pdb,
            pay_balance_types pbt,
            pay_balance_dimensions pbd
     where  pbt.balance_name         = p_balance_name
       and  pbd.dimension_name       = p_dimension_name
       and  pbt.balance_type_id      = pdb.balance_type_id
       and  pdb.balance_dimension_id = pbd.balance_dimension_id
       and  pdb.legislation_code = 'SG';
    --
    cursor c_globals
        is
    select global_value
      from ff_globals_f
     where global_name = 'CPF_ORD_MONTH_CAP_AMT'
       and p_date_earned between effective_start_date and effective_end_date;
    --
    g_balance_value_tab      pay_balance_pkg.t_balance_value_tab;
    g_context_tab            pay_balance_pkg.t_context_tab;
    g_detailed_bal_out_tab   pay_balance_pkg.t_detailed_bal_out_tab;
    --
    l_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
    l_action_sequence        pay_assignment_actions.action_sequence%TYPE;
    l_assignment_id          pay_assignment_actions.assignment_id%TYPE;
    l_person_id              per_assignments_f.person_id%TYPE;
    l_month                  number;
    l_effective_date         date;
    l_tax_unit_id            pay_assignment_actions.tax_unit_id%TYPE;
    l_defined_bal_id         number;
    l_cur_ord_ytd            number;
    l_ord_mon_cap_amt        number;
    l_retro_exist            boolean := FALSE ;
    l_retro_ele              number;
    l_retro_date             date;
begin
    l_cur_ord_ytd := 0;
    --
    open c_globals;
    fetch c_globals into l_ord_mon_cap_amt;
    close c_globals ;
    --
    g_balance_value_tab.delete;
    --
    open c_defined_bal_id('CPF Ordinary Earnings Eligible Comp','_PER_LE_MONTH');
    fetch c_defined_bal_id into g_balance_value_tab(1).defined_balance_id;
    close c_defined_bal_id;
    --
    open c_defined_bal_id('Ordinary Earnings ineligible for CPF','_PER_LE_MONTH');
    fetch c_defined_bal_id into g_balance_value_tab(2).defined_balance_id;
    close c_defined_bal_id;
    --
    open c_defined_bal_id('Retro Ord Retro Period','_ASG_PTD');
    fetch c_defined_bal_id into g_balance_value_tab(3).defined_balance_id;
    close c_defined_bal_id;
    --
    -- Start of Bug 7661439
    --
    open c_defined_bal_id('Ordinary Earnings Ineligible For CPF Calc','_PER_LE_MONTH');
    fetch c_defined_bal_id into g_balance_value_tab(4).defined_balance_id;
    close c_defined_bal_id;
    --
    -- End of Bug 7661439
    --
    open c_month_year_action_sequence( p_assignment_id, p_date_earned );
    loop
         fetch c_month_year_action_sequence into l_action_sequence,l_month,l_person_id;
         exit when c_month_year_action_sequence%NOTFOUND;
         --
         open c_month_year_action( l_person_id, p_date_earned, l_action_sequence );
         fetch c_month_year_action into l_assignment_action_id,l_effective_date,l_assignment_id;
         --
         if c_month_year_action%FOUND then
              open c_tax_unit_id( l_assignment_id, l_assignment_action_id );
              fetch c_tax_unit_id into l_tax_unit_id;
              close c_tax_unit_id;
              --
              g_context_tab.delete;
              g_detailed_bal_out_tab.delete;
              --
              g_context_tab(1).tax_unit_id := l_tax_unit_id;
              g_context_tab(2).tax_unit_id := l_tax_unit_id;
              g_context_tab(3).tax_unit_id := l_tax_unit_id;
              g_context_tab(4).tax_unit_id := l_tax_unit_id;        -- Bug 7661439
              --
              pay_balance_pkg.get_value ( l_assignment_action_id,
                                          g_balance_value_tab,
                                          g_context_tab,
                                          false,
                                          false,
                                          g_detailed_bal_out_tab
                                        );
              --
              if l_retro_exist
                  or nvl(g_detailed_bal_out_tab(3).balance_value,0) <> 0 then /* Bug 6815874 */
                    l_retro_ele   := get_retro_earnings( p_assignment_id , l_effective_date );  /* Bug 6815874 */
                    if l_retro_ele = 0 then /* Bug 6815874 */
                      l_retro_exist := FALSE;
                    end if;
                    l_cur_ord_ytd := l_cur_ord_ytd + least( (nvl( g_detailed_bal_out_tab(1).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(2).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(4).balance_value,0 )       -- Bug 7661439
                                                           - nvl( g_detailed_bal_out_tab(3).balance_value,0 )
                                                           + nvl(l_retro_ele,0)),l_ord_mon_cap_amt );
              else
                    l_cur_ord_ytd := l_cur_ord_ytd + least( (nvl( g_detailed_bal_out_tab(1).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(2).balance_value,0 )
                                                           - nvl( g_detailed_bal_out_tab(4).balance_value,0 )       -- Bug 7661439
                                                           - nvl( g_detailed_bal_out_tab(3).balance_value,0 )),l_ord_mon_cap_amt );
              end if;
              --
              if nvl( g_detailed_bal_out_tab(3).balance_value,0 ) <> 0 then
                  l_retro_exist := TRUE;
              end if;

              --
         end if;
         --
         close c_month_year_action;
    end loop;
    --
    close c_month_year_action_sequence;
    --
    return l_cur_ord_ytd;
    --
end get_cur_year_ord_ytd;
--
function get_retro_earnings( p_assignment_id   in pay_assignment_actions.assignment_id%TYPE,
                             p_date_earned     in date ) return number
is
  cursor c_pay_element_entries
      is
  select sum(peev.screen_entry_value)
    from pay_element_entry_values_f peev,
         pay_element_entries_f pee,
         pay_element_types_f pet,
         pay_input_values_f piv,
         pay_element_classifications pec
   where pee.assignment_id         = p_assignment_id
     and pee.source_asg_action_id in
          (select   paa1.assignment_action_id
             from   pay_assignment_actions paa1,
                    pay_payroll_actions ppa1
            where   paa1.assignment_id = pee.assignment_id
              and   ppa1.payroll_action_id = paa1.payroll_action_id
              and   ppa1.action_type       in ('R','Q','B','V','I')
              and   to_char(ppa1.effective_date,'MM') = to_char(p_date_earned,'MM'))
     and pee.creator_type in ('EE','RR')
     and pee.element_type_id       = pet.element_type_id
     and pet.classification_id     = pec.classification_id
     and pec.classification_name   = 'Ordinary Earnings'
     and pec.legislation_code      = 'SG'
     and pee.element_entry_id      = peev.element_entry_id
     and peev.input_value_id       = piv.input_value_id
     and piv.name                  = 'Pay Value'
     and p_date_earned between pee.source_start_date
                           and pee.source_end_date
     and p_date_earned between pet.effective_start_date
                           and pet.effective_end_date
     and p_date_earned between piv.effective_start_date
                           and piv.effective_end_date   ;
  --
  l_retro_value  number;
begin
  open  c_pay_element_entries;
  fetch c_pay_element_entries into l_retro_value;
  close c_pay_element_entries ;
  --
  return l_retro_value;
  --
end get_retro_earnings;

/*****************************************
   CPF Report section : bugno 2475324
*****************************************/

/* Initialize all the contexts required for SG_STAT*/
Procedure init_formula (p_formula_name in varchar2,
                            p_effective_date in date ) is
--
l_effective_date        date;
l_start_date            date;
l_formula_id            number;
--
cursor c_formula_id (c_formula_name varchar2, c_effective_date date)  is
select formula_id, effective_start_date
from   ff_formulas_f
where  formula_name = c_formula_name
and    legislation_code = 'SG'
and    c_effective_date between effective_start_date and effective_end_date;

Begin
   l_effective_date  :=  to_date('1-10-2003','dd-mm-yyyy');
   l_start_date      :=  to_date('1-10-2003','dd-mm-yyyy');

   /* This function call returns -1 if the formula was not found */
   hr_utility.set_location('Starting init',5);
   hr_utility.trace('Formula_id:'||l_formula_id);

   open c_formula_id(p_formula_name, p_effective_date);
   fetch c_formula_id into l_formula_id, l_start_date;
   if c_formula_id%NOTFOUND then
      close c_formula_id;
   else

   hr_utility.trace('Formula_id:'||l_formula_id);
   ff_exec.init_formula (l_formula_id,
                         l_start_date,
                         g_inputs,
                         g_outputs);
   end if;
    --
   hr_utility.set_location('Leaving init',10);

End init_formula;

Function calc_cpf_add_YTD  (p_date_earned          in date
                             ,p_assignment_id      in number
                             ,p_process_type       in varchar2
                             ,p_tax_unit_id        in number
                             ,p_asg_action_id      in number
                             ,p_business_group_id  in number
                             ,p_payroll_action_id  in number
                             ,p_payroll_id         in number
                             ,p_balance_date       in date
                           ) return number is

l_cpf_add_YTD  number;

Begin
  --
  hr_utility.set_location('Entering get_bal',7);
  --
  init_formula('SG_STAT',p_date_earned);
  --
  -- Set up contexts for the formula
  for i in g_inputs.first..g_inputs.last loop
      --

      if g_inputs(i).name = 'DATE_EARNED' then
         hr_utility.trace('setting date earned '||p_date_earned);
         g_inputs(i).value := fnd_date.date_to_canonical(p_date_earned);
      elsif g_inputs(i).name = 'ASSIGNMENT_ID' then
         g_inputs(i).value := p_assignment_id;
      elsif g_inputs(i).name = 'SOURCE_TEXT' then
         hr_utility.trace('setting source text '||p_process_type);
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'PROCESS_TYPE' then
         g_inputs(i).value := p_process_type;
      elsif g_inputs(i).name = 'TAX_UNIT_ID' then
         g_inputs(i).value := p_tax_unit_id;
      elsif g_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
         g_inputs(i).value := p_asg_action_id;
      elsif g_inputs(i).name = 'BUSINESS_GROUP_ID' then
         g_inputs(i).value := p_business_group_id;
      elsif g_inputs(i).name = 'PAYROLL_ACTION_ID' then
         g_inputs(i).value := p_payroll_action_id;
      elsif g_inputs(i).name = 'PAYROLL_ID' then
         g_inputs(i).value := p_payroll_id;
      elsif g_inputs(i).name = 'BALANCE_DATE' then
         g_inputs(i).value := fnd_date.date_to_canonical(p_balance_date);
      else
         hr_utility.set_location('ERROR value = '||g_inputs(i).name ,7);
      end if;
      --
      hr_utility.trace('g_inputs(i).name : '||g_inputs(i).name);
      hr_utility.trace('g_inputs(i).value : '||g_inputs(i).value);
  end loop;
  --
  -- Run the formula
  --
  hr_utility.set_location('Prior to execute the formula',8);
  ff_exec.run_formula (g_inputs ,
                       g_outputs  );
  --
  hr_utility.set_location('End run formula',9);
  --
  for l_out_cnt in g_outputs.first..g_outputs.last loop
      -- only store the output of L_CPF_ADD_CALC_YEAR , ignoe others
      if g_outputs(l_out_cnt).name = 'L_CPF_ADD_CALC_YEAR'  then
        l_cpf_add_YTD  :=  g_outputs(l_out_cnt).value;
        hr_utility.trace('l_cpf_add_YTD:'|| g_outputs(l_out_cnt).value);
      end if;
      --
      hr_utility.trace('Outputs:'||g_outputs(l_out_cnt).name);
      hr_utility.trace('Outputs(values):'||g_outputs(l_out_cnt).value);
  end loop;
  --
  return l_cpf_add_YTD;
    --
End calc_cpf_add_YTD;
/* End of Function */

/* Returns whether the SG_STAT is called from the REPORT or PAYROLL Run*/
Function get_SG_STAT_CALLED_FROM return varchar2
is
begin
  return g_sgstat_called_from;
end;

/* In the before report trigger of PAYSGCPF the global g_sgstat_called_from
 is set to REPORT*/

procedure set_SG_STAT_CALLED_FROM (p_running in varchar2)
is
begin
  g_sgstat_called_from := p_running;
end;

/* Populates the pl/sql table with assignment id and difference of CPF paid (values of the balances)
 and calculated CPF from SG_STAT with SAEOY*/

procedure populate_cpf_table (p_person_id in number,
                              p_cpf_diff number ) is
l_person_id binary_integer;
begin
       l_person_id:= p_person_id;
       cpf_inputs_t(l_person_id).person_id:= p_person_id;
       cpf_inputs_t(l_person_id).cpf_diff := p_cpf_diff;
end;

/* If the assignment exists in the cpf pl/sql table (populated by populate_cpf_table)
,return 1 else 0. Used in the where clause of the report query*/

function get_assignment_from_cpf_table(p_person_id in number) return number is
l_person_id binary_integer;
begin
      l_person_id:= p_person_id;
      if cpf_inputs_t.exists(l_person_id) then
         if (cpf_inputs_t(l_person_id).person_id=  p_person_id) then
            return (1);
         end if;
      end if;
      return (0);
end;

/* Get the overpaid value for the assignment passed from the pl/sql table populated by
populate_cpf_table above*/
function get_cpf_difference(p_person_id in number) return number is
l_cpf_diff number;
l_person_id binary_integer;
begin
   l_cpf_diff := 0;
   l_person_id:= p_person_id;
   if cpf_inputs_t.exists(l_person_id) then
      if (cpf_inputs_t(l_person_id).person_id= p_person_id) then
         l_cpf_diff := cpf_inputs_t(l_person_id).cpf_diff;
      end if;
   end  if;
   return l_cpf_diff;
end;

/* Return last date of the year (stored in g_year_end_date_for_cpf_report)
, used in the SG_STAT*/

function GET_YEAR_END_DATE return date is
begin
   return g_year_end_date_for_cpf_report;
end;

/* set the g_year_end_date_for_cpf_report as the last date of the year*/
procedure set_year_end_date(p_year_end_date in date) is
begin
   g_year_end_date_for_cpf_report := p_year_end_date;
end;

begin

   g_sgstat_called_from := 'PAYROLL';

end pay_sg_deductions;

/
