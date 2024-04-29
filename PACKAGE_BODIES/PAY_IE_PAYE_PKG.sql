--------------------------------------------------------
--  DDL for Package Body PAY_IE_PAYE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PAYE_PKG" as
/* $Header: pyietax.pkb 120.10.12010000.5 2009/12/04 11:24:10 abraghun ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE PAYE package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  20 JUN 2001 jmhatre  N/A        Created
**  20 SEP 2001 jmhatre  N/A        Added social benefits suff
**  18 OCT 2001 abhaduri N/A        Changes due to SOE form requirement,
                                    added out parameters p_assess_basis
                                    and p_certificate_issue_date to
                                    function get_paye_details to be fed
                                    to PAYE details
**  05 DEC 2001 gpadmasa  N/A       Added dbdrv Commands
**  11 FEB 2002 abhaduri  N/A       Added input parameters Reduced Tax
                                    Credit, Reduced Std Rate Cut Off and
                                    Benefit amount for P45 data archiving
                                    and display for get_paye_details.
**  26 JUN 2002 abhaduri  N/A       Added function get_calculated_period_values
                                    for calculating tax credits and cut offs
                                    according to user entered values and
                                    period types.
**  09-DEC-2002 smrobins  N/A       Added function get_pps_number.
**  16-MAY-2003 nsugavan  2943335   Added function Valid_Work_incidents and made
**				    changes to existing social benefits cursor
**				    to use element entry values instead of data
**				    from table, pay_ie_social_benefits_f
** 04-jul-2003 asengar   3030621    Added two procedures insert_element_entry
**                                  and update_element_entry.
** 30-JUL-2003 asengar  3030616     Added four functions get_weekly_tax_credit
**                                  get_weekly_std_rate_cut_off,get_monthly_tax_credit
**                                  get_monthly_std_rate_cut_off to be called by
**                                  view pay_ie_paye_details_v.
**  09-FEB-2005 aashokan  4080773  Added a new procedure to create record in new tax record
**				   if pay frequency is changed.
**  10-Feb-2005 vikgupta  4080773  Modified the proc update_paye_change_freq (included
**                                 P_DATETRACK_UPDATE_MODE)
**  11-Feb-2005 vikgupta  4080773  Modified the proc update_paye_change_freq
**  22-Feb-2005 skhandwa  4080773  Modified the proc update_paye_change_freq
**				   included check if no current or future record
**				   exists
**  22-Feb-2005 skhandwa  4080773  Modified the proc update_paye_change_freq
**				   For Cumulative, set nonapplicable
**				   credit and cut-off values to null
**  22-Feb-2005 skhandwa  4080773  Modified the proc update_paye_change_freq
**				   Added global variable for old payroll
**  22-Feb-2005 skhandwa  4080773  Modified the proc update_paye_change_freq
**				   Changed p_effective_date for Correction cases.
**  23-Feb-2005 skhandwa  4080773  Modified the proc update_paye_change_freq
**				   Added assignment start date check for Correction cases .
**  20-Apr-2005 alikhar   3227184  Changed cursor c_paye_dtl to use the payroll effective
**				   date to fetch paye values from pay_ie_paye_details_f.
**  26-Sep-2005 rrajaman  4619038  Added checks for new Tax Basis IE_EXEMPTION.
**  04-Oct-2005 rrajaman  4561012  Added checks for IE_WEEK1_MONTH1.
**  15-Dec-2005 vikgupta  4878630  Modified the update_paye_change_freq proc
**                                 for tax credit upload process.
**  04-Jan-2006 vikgupta  4926302  added info source as IE_ELECTRONCI and asess
**                                 basis 'IE_SEP_TREAT' for Tax Credit upload
**                                 in update_paye_change_freq proc.
**  01-Mar-2006 rbhardwa  5070091  Made changes to accomodate offset payrolls.
**  19-Sep-2006 MGettins  5472781  Added a check to see if legislation
**                                 has been installed, as part
**                                 of the fix for GSI bug 5472781.
**  19-Feb-2007 vikgupta           SR 17140460.6, change the parameter passed to
**                                 update_paye_change_freq
**  09-Apr-2007 rbhardwa  5867343  Modified code to include new functions get_paye_tax_basis,
**                                 get_diff_tax_basis and get_ie_exclude_tax_basis.
**  05-May-2008 knadhan   6929566  Replaced p_effective_date with new parameter p_cert_date,
** 05-Dec-2008  rrajaman  7622221  Ireland budget 2009 new formula function
** 11-Dec-2008 rrajaman  7622221  get_age_payroll_period modified to check age as of 31-Dec
** 23-Dec-2008  rrajaman  7665572    Levy dates advanced for Offset Payroll
** 03-Dec-2009  rrajaman  9177545  added get_periods_between function.
-------------------------------------------------------------------------------
*/
g_package  varchar2(33) := 'pay_ie_paye.';
g_old_payroll_id	per_all_assignments_f.payroll_id%TYPE; --added for update_paye_change_freq
/* Added cursor for Bug 3030621 */
cursor g_absence_dates (c_element_entry_id number) is
   SELECT pev.SCREEN_ENTRY_VALUE
       FROM pay_element_entries_f pee, pay_element_links_f pel, pay_element_types_f pet,pay_element_entry_values_f pev,
       pay_input_values_f piv
       WHERE pee.element_link_id = pel.element_link_id
       AND pet.element_type_id = pel.element_type_id
       AND pet.element_name = 'IE Social Benefit Option 2'
       AND pee.element_entry_id = c_element_entry_id
       AND pet.element_type_id = piv.element_type_id
       AND piv.legislation_code='IE'
       AND piv.name in ('Absence Start Date','Absence End Date')
       AND piv.element_type_id = pel.element_type_id
       AND piv.input_value_id=pev.input_value_id
       AND pev.element_entry_id = c_element_entry_id
   ORDER by piv.name desc;



 Function get_paye_tax_basis(p_assignment_id              in          number         /* 5867343 */
                            ,p_payroll_action_id          in          number
			    ,p_tax_basis                  out nocopy  varchar2)
 return number is

 --Local vriables-----

 l_proc                 varchar2(72) := g_package||'get_paye_details';


 -- cursor to fetch tax basis
 cursor c_paye_tax_basis is select  tax_basis
                            from  pay_ie_paye_details_f pipd
                                  ,pay_payroll_actions ppa
                                  ,per_time_periods ptp
                            where  pipd.assignment_id = p_assignment_id
                              and  ppa.payroll_action_id = p_payroll_action_id
		              and ppa.effective_date between pipd.effective_start_date and  --Bug Fix 3227184
                                  nvl(pipd.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
                              and  pipd.info_source in ('IE_P45','IE_ELECTRONIC','IE_CERT_TAX_CREDITS','IE_NONE_PROVIDED');


 procedure initialise is
   begin
      p_tax_basis:='zzzz' ;
   end;

 begin

   hr_utility.set_location('Entering:'||l_proc, 5);
   open c_paye_tax_basis;

   fetch c_paye_tax_basis into p_tax_basis;

   if c_paye_tax_basis%notfound then
      initialise;
      close c_paye_tax_basis;
      return 0;
   end if;

   close c_paye_tax_basis;
   hr_utility.set_location('Leaving:'||l_proc, 30);
   return 1;

   exception when others then
   initialise;
   close c_paye_tax_basis;
   raise_application_error(-20001,l_proc||'- '||sqlerrm);
   return 0;

end get_paye_tax_basis;                           /* 5867343 */

Function get_diff_tax_basis(p_assignment_id              in          number         /* 5867343 */
                            ,p_payroll_id                 in          number
			    ,p_date_earned                in          date)
 return number is

 --Local vriables-----

 l_proc                 varchar2(72) := g_package||'get_diff_tax_basis';
 l_sec_assignment       number;

 -- Cursor to check whether multiple assignment has a different tax basis
CURSOR chk_multi_asgn_tax_basis IS
SELECT 1
 FROM per_all_assignments_f paaf
      ,per_time_periods ptp
      ,pay_ie_paye_details_f pipd
 WHERE paaf.person_id = ( SELECT distinct person_id FROM per_all_assignments_f WHERE assignment_id = p_assignment_id )
   AND paaf.assignment_id <> p_assignment_id
   AND pipd.assignment_id(+) = paaf.assignment_id
   AND nvl(pipd.tax_basis,'X') <> 'IE_EXCLUDE'
   AND p_date_earned BETWEEN ptp.start_date and ptp.end_date
   AND ptp.payroll_id = p_payroll_id
   AND paaf.effective_start_date <= ptp.end_date
   AND paaf.effective_end_date >= ptp.start_date;

BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN chk_multi_asgn_tax_basis;
   FETCH chk_multi_asgn_tax_basis INTO l_sec_assignment;

   IF chk_multi_asgn_tax_basis%NOTFOUND THEN
      close chk_multi_asgn_tax_basis;
      hr_utility.set_location('Leaving:'||l_proc, 30);
      return 0;
   ELSE
      close chk_multi_asgn_tax_basis;
      hr_utility.set_location('Leaving:'||l_proc, 31);
      return 1;
   END IF;

   exception when others then
   close chk_multi_asgn_tax_basis;
   raise_application_error(-20001,l_proc||'- '||sqlerrm);
   return 0;

end get_diff_tax_basis;                           /* 5867343 */


Function get_ie_exclude_tax_basis(p_assignment_id              in          number         /* 5867343 */
                                 ,p_payroll_id                 in          number
			         ,p_date_earned                in          date)
 return number is

 --Local vriables-----

 l_proc                 varchar2(72) := g_package||'get_ie_exclude_tax_basis';
 l_sec_assignment       number;

 -- Cursor to check whether multiple assignment has a different tax basis
CURSOR chk_multi_asgn_tax_basis IS
SELECT 1
 FROM per_all_assignments_f paaf
      ,per_time_periods ptp
      ,pay_ie_paye_details_f pipd
 WHERE paaf.person_id = ( SELECT distinct person_id FROM per_all_assignments_f WHERE assignment_id = p_assignment_id )
   AND paaf.assignment_id <> p_assignment_id
   AND pipd.assignment_id(+) = paaf.assignment_id
   AND nvl(pipd.tax_basis,'X') = 'IE_EXCLUDE'
   AND p_date_earned BETWEEN ptp.start_date and ptp.end_date
   AND ptp.payroll_id = p_payroll_id
   AND paaf.effective_start_date <= ptp.end_date
   AND paaf.effective_end_date >= ptp.start_date;

BEGIN

   hr_utility.set_location('Entering:'||l_proc, 5);

   OPEN chk_multi_asgn_tax_basis;
   FETCH chk_multi_asgn_tax_basis INTO l_sec_assignment;

   IF chk_multi_asgn_tax_basis%NOTFOUND THEN
      close chk_multi_asgn_tax_basis;
      hr_utility.set_location('Leaving:'||l_proc, 30);
      return 0;
   ELSE
      close chk_multi_asgn_tax_basis;
      hr_utility.set_location('Leaving:'||l_proc, 31);
      return 1;
   END IF;

   exception when others then
   close chk_multi_asgn_tax_basis;
   raise_application_error(-20001,l_proc||'- '||sqlerrm);
   return 0;

end get_ie_exclude_tax_basis;                           /* 5867343 */




 Function get_paye_details(p_assignment_id                in           number
                            ,p_payroll_action_id          in           number
                            ,p_info_source                out nocopy  varchar2
                            ,p_tax_basis                  out nocopy  varchar2
                            ,p_weekly_tax_credit          out nocopy  number
                            ,p_monthly_tax_credit         out nocopy  number
                            ,p_weekly_std_rate_cutoff     out nocopy  number
                            ,p_monthly_std_rate_cutoff    out nocopy  number
                            ,p_certificate_start_date     out nocopy  date
                            ,p_certificate_end_date       out nocopy  date
                            /*changes for SOE form requirements*/
                            ,p_assess_basis               out nocopy  varchar2
                            ,p_certificate_issue_date     out nocopy  date
                            /*parameters added for p45 archiving*/
                            ,p_reduced_tax_credit         out nocopy  number
                            ,p_reduced_std_rate_cutoff    out nocopy  number
                            ,p_benefit_amount             out nocopy  number)
                            /*************************************************/
 return number is

  --Local vriables-----

  l_proc                 varchar2(72) := g_package||'get_paye_details';
  l_payroll_id number;
  l_date_earned date;
  l_period_type varchar2(20);
  l_soc_ben_rec pay_ie_social_benefits_f%rowtype;

  -- added for getting calculated values as per period type
  l_period_ind varchar2(3);
  l_cal_reduced_tax_credit number;
  l_cal_reduced_cut_off number;
  --
 -- Bug 2943335 - Added
total_benefit_amount number := 0;
l_benefit_amount number;

  cursor c_paye_dtl is select  ppa.payroll_id
                              ,ppa.date_earned
                              ,info_source
                              ,tax_basis
                              ,nvl(weekly_tax_credit,0)
                              ,nvl(monthly_tax_credit,0)
                              ,nvl(weekly_std_rate_cut_off,0)
                              ,nvl(monthly_std_rate_cut_off,0)
                              ,effective_start_date
                              ,nvl(pipd.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
                             /*changes for SOE form requirements*/
                             ,pipd.tax_assess_basis
                             ,nvl(pipd.certificate_issue_date,to_date('01-01-0001','DD-MM-YYYY'))
                             ,ptp.period_type
                         from  pay_ie_paye_details_f pipd
                              ,pay_payroll_actions ppa
                              ,per_time_periods ptp
                        where  pipd.assignment_id = p_assignment_id
                          and  ppa.payroll_action_id = p_payroll_action_id
                          -- and ppa.date_earned between pipd.effective_start_date and
			  and ppa.effective_date between pipd.effective_start_date and  --Bug Fix 3227184
                          nvl(pipd.effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
                          and  pipd.info_source in ('IE_P45','IE_ELECTRONIC','IE_CERT_TAX_CREDITS','IE_NONE_PROVIDED')
                          and ptp.payroll_id = ppa.payroll_id
                          and ppa.date_earned between ptp.start_date and ptp.end_date;
--
-- Bug 2943335 - commented code below to reference element entries table for data
--
 /* cursor c_soc_ben(c_payroll_id number,c_date_earned date) is select calculation_option
                           ,nvl(reduced_tax_credit,0)
                           ,nvl(reduced_standard_cutoff,0)
                           ,nvl(benefit_amount,0)
                      from pay_ie_social_benefits_f psb,
                           per_time_periods ptp
                     where psb.absence_start_date between ptp.start_date and ptp.end_date
                       and ptp.payroll_id = c_payroll_id
                       and psb.assignment_id = p_assignment_id
                       and calculation_option not in('IE_OPTION0','IE_OPTION1')
                       and c_date_earned between ptp.start_date and ptp.end_date
                       order by psb.effective_start_date desc; */
 -- SOC cahnges....
--
cursor cur_c_soc_ben
is
select NVL(SUM(TO_NUMBER(SCREEN_ENTRY_VALUE)),0)
from
PAY_INPUT_VALUES_F INPVAL,
PAY_ELEMENT_TYPES_F TYPE,
PAY_ELEMENT_LINKS_F LINK,
PAY_ELEMENT_ENTRY_VALUES_F VALUE,
PAY_ELEMENT_ENTRIES_F ENTRY,
PER_TIME_PERIODS PTP,
PAY_PAYROLL_ACTIONS PACT
-- ,FND_SESSIONS SESH
WHERE
PACT.PAYROLL_ACTION_ID =  P_PAYROLL_ACTION_ID AND
--PTP.TIME_PERIOD_ID = PACT.TIME_PERIOD_ID AND                    -- Bug 5070091 Offset payroll change
PACT.PAYROLL_ID = PTP.PAYROLL_ID AND
PACT.DATE_EARNED BETWEEN PTP.START_DATE AND PTP.END_DATE AND
--SESH.SESSION_ID = USERENV ('sessionid') AND
TYPE.ELEMENT_NAME = 'IE Social Benefit Option 2' AND
-- SESH.EFFECTIVE_DATE BETWEEN TYPE.EFFECTIVE_START_DATE AND TYPE.EFFECTIVE_END_DATE AND
PACT.EFFECTIVE_DATE BETWEEN TYPE.EFFECTIVE_START_DATE AND TYPE.EFFECTIVE_END_DATE AND
TYPE.ELEMENT_TYPE_ID = LINK.ELEMENT_TYPE_ID AND
-- SESH.EFFECTIVE_DATE BETWEEN LINK.EFFECTIVE_START_DATE AND LINK.EFFECTIVE_END_DATE AND
PACT.EFFECTIVE_DATE BETWEEN LINK.EFFECTIVE_START_DATE AND LINK.EFFECTIVE_END_DATE AND
ENTRY.ELEMENT_LINK_ID = LINK.ELEMENT_LINK_ID AND
ENTRY.ASSIGNMENT_ID = P_ASSIGNMENT_ID AND
ENTRY.EFFECTIVE_START_DATE <=  PTP.END_DATE AND
ENTRY.EFFECTIVE_END_DATE >= PTP.START_DATE AND
VALUE.ELEMENT_ENTRY_ID = ENTRY.ELEMENT_ENTRY_ID AND
VALUE.EFFECTIVE_START_DATE = ENTRY.EFFECTIVE_START_DATE AND
VALUE.EFFECTIVE_END_DATE = ENTRY.EFFECTIVE_END_DATE AND
INPVAL.INPUT_VALUE_ID = VALUE.INPUT_VALUE_ID AND
INPVAL.NAME = 'Taxable Benefit Amount'  AND
-- SESH.EFFECTIVE_DATE BETWEEN INPVAL.EFFECTIVE_START_DATE AND INPVAL.EFFECTIVE_END_DATE;
PACT.EFFECTIVE_DATE BETWEEN INPVAL.EFFECTIVE_START_DATE AND INPVAL.EFFECTIVE_END_DATE;

   procedure initialise is
   begin
      p_info_source:='zzzz'  ;
      p_tax_basis:='zzzz' ;
      p_weekly_tax_credit:=0;
      p_monthly_tax_credit:=0;
      p_weekly_std_rate_cutoff:=0;
      p_monthly_std_rate_cutoff:=0;
      p_certificate_start_date:=to_date('01-01-0001','DD-MM-YYYY');
      p_certificate_end_date:=to_date('01-01-0001','DD-MM-YYYY');
     /********************************/
      p_reduced_tax_credit:=0;
      p_reduced_std_rate_cutoff:=0;
      p_benefit_amount:=0;
     /**************************/
   end;

  --end Local vriables---------

begin

    hr_utility.set_location('Entering:'||l_proc, 5);
     /********************************/
      p_reduced_tax_credit:=0;
      p_reduced_std_rate_cutoff:=0;
      p_benefit_amount:=0;
     /**************************/
    open c_paye_dtl;

          fetch c_paye_dtl into l_payroll_id
                               ,l_date_earned
                               ,p_info_source
                               ,p_tax_basis
                               ,p_weekly_tax_credit
                               ,p_monthly_tax_credit
                               ,p_weekly_std_rate_cutoff
                               ,p_monthly_std_rate_cutoff
                               ,p_certificate_start_date
                               ,p_certificate_end_date
                              /*changes for SOE form requirements*/
                               ,p_assess_basis
                               ,p_certificate_issue_date
                               ,l_period_type;

        if c_paye_dtl%notfound then
         initialise;
         return 0;
        end if;

        /* Getting calculated values as per the period type*/
        if (l_period_type ='Week'
            or l_period_type ='Bi-Week'
            or l_period_type='Lunar Month')
        then
            l_period_ind := 'W';
            p_weekly_tax_credit := get_calculated_period_values(l_period_type,
                                                                l_period_ind,
                                                                p_weekly_tax_credit);
            p_weekly_std_rate_cutoff := get_calculated_period_values(l_period_type,
                                                                     l_period_ind,
                                                                     p_weekly_std_rate_cutoff);

        elsif (l_period_type ='Bi-Month' or
                l_period_type ='Calendar Month' or
                l_period_type='Quarter' or
                l_period_type = 'Semi-Month' or
                l_period_type = 'Semi-Year' or
                l_period_type ='Year')
        then
            l_period_ind :='M';
            p_monthly_tax_credit := get_calculated_period_values(l_period_type,
                                                                 l_period_ind,
                                                                 p_monthly_tax_credit);
            p_monthly_std_rate_cutoff := get_calculated_period_values(l_period_type,
                                                                      l_period_ind,
                                                                      p_monthly_std_rate_cutoff);

        end if;

	-- Bug 2943335 - commented code below to reference element entries table for data
        /*Social Benefits stuff*/
      /* open c_soc_ben(l_payroll_id,l_date_earned);
        fetch c_soc_ben into l_soc_ben_rec.calculation_option
                            ,l_soc_ben_rec.reduced_tax_credit
                            ,l_soc_ben_rec.reduced_standard_cutoff
                            ,l_soc_ben_rec.benefit_amount;
        if c_soc_ben%found then

                -- getting calculated values according to the period
                l_cal_reduced_tax_credit := get_calculated_period_values(l_period_type,l_period_ind,l_soc_ben_rec.reduced_tax_credit);
                l_cal_reduced_cut_off:= get_calculated_period_values(l_period_type,l_period_ind,l_soc_ben_rec.reduced_standard_cutoff);

                if l_soc_ben_rec.calculation_option = 'IE_OPTION1' then
                    --
                    p_benefit_amount:=l_soc_ben_rec.benefit_amount;
                    --
                elsif l_soc_ben_rec.calculation_option = 'IE_OPTION2' then
                    --
                    if l_period_ind = 'W'
                    then
                        p_reduced_tax_credit:=p_weekly_tax_credit - l_cal_reduced_tax_credit;
                        p_reduced_std_rate_cutoff:=p_weekly_std_rate_cutoff - l_cal_reduced_cut_off;
                    elsif l_period_ind = 'M'
                    then
                        p_reduced_tax_credit:=p_monthly_tax_credit - l_cal_reduced_tax_credit;
                        p_reduced_std_rate_cutoff:=p_monthly_std_rate_cutoff - l_cal_reduced_cut_off;
                    end if;

                    p_benefit_amount:=l_soc_ben_rec.benefit_amount;
                    p_weekly_tax_credit:= l_cal_reduced_tax_credit;
                    p_monthly_tax_credit:= l_cal_reduced_tax_credit;
                    p_weekly_std_rate_cutoff:= l_cal_reduced_cut_off;
                    p_monthly_std_rate_cutoff:= l_cal_reduced_cut_off;
                    --
                elsif l_soc_ben_rec.calculation_option = 'IE_OPTION3' then
                    --
                    if (l_period_ind='W')
                    then
                        p_reduced_tax_credit:=p_weekly_tax_credit - l_cal_reduced_tax_credit;
                        p_reduced_std_rate_cutoff:=p_weekly_std_rate_cutoff - l_cal_reduced_cut_off;
                    elsif l_period_ind='M'
                    then
                        p_reduced_tax_credit:=p_monthly_tax_credit - l_cal_reduced_tax_credit;
                        p_reduced_std_rate_cutoff:=p_monthly_std_rate_cutoff - l_cal_reduced_cut_off;
                    end if;

                    p_benefit_amount:=l_soc_ben_rec.benefit_amount;
                    p_weekly_tax_credit:= l_cal_reduced_tax_credit;
                    p_monthly_tax_credit:= l_cal_reduced_tax_credit;
                    p_weekly_std_rate_cutoff:= l_cal_reduced_cut_off;
                    p_monthly_std_rate_cutoff:= l_cal_reduced_cut_off;
                    p_tax_basis:='IE_WEEK1_MONTH1';
                    --
                elsif l_soc_ben_rec.calculation_option = 'IE_OPTION4' then
                    --
                    p_tax_basis:='IE_WEEK1_MONTH1';
                    p_benefit_amount:=l_soc_ben_rec.benefit_amount;
                    --
                end if;
        end if;

        close c_soc_ben;       */
--
-- Bug 2943335 - Fetch the sum of benefit amount am employee has in this period

                open  cur_c_soc_ben;
                fetch  cur_c_soc_ben into total_benefit_amount;
                close cur_c_soc_ben;
                -- @D:/Comm/IE/Social_ben/pyietax.pkb
           p_benefit_amount := nvl(total_benefit_amount,0);
           hr_utility.set_location('benefit amt:'||p_benefit_amount, 15);
           hr_utility.set_location('p_monthly_tax_credit: '||p_monthly_tax_credit, 25);
           hr_utility.set_location('p_monthly_std_rate_cutoff:'||p_monthly_std_rate_cutoff, 35);

        close c_paye_dtl;
        hr_utility.set_location('Leaving:'||l_proc, 30);
        return 1;

     exception when others then
     initialise;
     close c_paye_dtl;
     raise_application_error(-20001,l_proc||'- '||sqlerrm);
     return 0;

end get_paye_details;

Function get_payroll_details( p_payroll_id             in            number
                              ,p_payroll_action_id       in            number
                              ,p_period_num              out nocopy  number
                              ,p_payroll_type            out nocopy  varchar2) return number is

     cursor c_payroll_details is select  ptp.period_num
                                        ,ptp.period_type
                                   from per_time_periods ptp,
                                        pay_all_payrolls pap,
                                        pay_payroll_actions ppa
                                  where pap.payroll_id = ptp.payroll_id
                                    and pap.payroll_id=p_payroll_id
                                    and ppa.payroll_id=pap.payroll_id
                                    and ppa.payroll_action_id=p_payroll_action_id
                                    and ppa.date_earned between ptp.start_date and ptp.end_date;

    l_proc                 varchar2(72) := g_package||'get_payroll_details';

begin

    hr_utility.set_location('Entering:'||l_proc, 35);

    open c_payroll_details;
    fetch c_payroll_details into p_period_num
                                 ,p_payroll_type;
    close c_payroll_details;

    hr_utility.set_location('Leaving:'||l_proc, 50);

    return 1;
    exception when others then
      return 0;

end;
--
FUNCTION get_calculated_period_values(p_period_type IN VARCHAR2,
                                      p_period_ind  IN VARCHAR2,
                                      p_actual_value IN NUMBER) RETURN NUMBER IS

l_calculated_value NUMBER;
l_number_per_year NUMBER;

CURSOR csr_number_per_year IS
  SELECT  number_per_fiscal_year
  FROM per_time_period_types
  WHERE period_type =p_period_type;

BEGIN

OPEN csr_number_per_year;
FETCH csr_number_per_year INTO l_number_per_year;
CLOSE csr_number_per_year;

IF p_period_ind = 'M' THEN
    l_calculated_value := p_actual_value * 12/l_number_per_year;

ELSIF p_period_ind='W' THEN
    l_calculated_value := p_actual_value * 52/l_number_per_year;

END IF;

RETURN l_calculated_value;

END get_calculated_period_values;
--
--
Function get_pps_number(p_assignment_id IN NUMBER,
                        p_payroll_action_id IN NUMBER) RETURN NUMBER IS
--
l_pps_number  VARCHAR2(30);
l_tax_basis   VARCHAR2(30);
l_func        VARCHAR2(14):= 'get_pps_number';

Cursor csr_pps_number IS
   SELECT nvl(pap.national_identifier, 'X')
   FROM   per_all_people_f pap
         ,per_all_assignments_f paa
         ,pay_payroll_actions ppa
   WHERE ppa.payroll_action_id = p_payroll_action_id
   and   paa.assignment_id = p_assignment_id
   and   ppa.effective_date between paa.effective_start_date and paa.effective_end_date
   and   paa.person_id = pap.person_id
   and   ppa.effective_date between pap.effective_start_date and pap.effective_end_date;

Cursor csr_emer_no_pps_basis IS
   SELECT nvl(pipd.tax_basis, 'X')
   from   pay_ie_paye_details_f pipd,
          pay_payroll_actions ppa
   WHERE  ppa.payroll_action_id = p_payroll_action_id
   and    pipd.assignment_id = p_assignment_id
   and    ppa.effective_date between pipd.effective_start_date and pipd.effective_end_date;
--
Begin
   hr_utility.set_location('Entering : '||l_func, 10);
   OPEN csr_pps_number;
   FETCH csr_pps_number into l_pps_number;
   CLOSE csr_pps_number;
--
  IF l_pps_number = 'X' then
    hr_utility.set_location('In : '||l_func, 20);
    RETURN 1;
  ELSE
   hr_utility.set_location('In : '||l_func, 30);
    OPEN csr_emer_no_pps_basis;
   FETCH csr_emer_no_pps_basis into l_tax_basis;
   CLOSE csr_emer_no_pps_basis;
   IF l_tax_basis IS NULL THEN
        hr_utility.set_location('In : '||l_func, 35);
        l_tax_basis := 'X';
   END IF;
   IF l_tax_basis <> 'IE_EMERGENCY_NO_PPS' THEN
      hr_utility.set_location('In : '||l_func, 40);
      RETURN 0;
   ELSE
      hr_utility.set_location('In : '||l_func, 50);
      RETURN 1;
   END IF;
   hr_utility.set_location('In : '||l_func, 60);
  END IF;
  hr_utility.set_location('In : '||l_func, 70);
END get_pps_number;
--
-- Bug 2943335 added function to see if work incident exist for the person
-- This would return true if the work incident
--   entered on the element entry screen exists for the person
--
function Valid_Work_incidents
(p_assignment_id                  in number
,p_date_earned                    in date
,p_reference                      in varchar2) return varchar2 is
--
  l_valid     varchar2(10);
  cursor csr_find_match is
  select  'TRUE'
  from    per_all_assignments_f   asg,
          per_work_incidents         pwi,
          hr_lookups hl
  where   p_date_earned between asg.effective_start_date
                            and asg.effective_end_date and
    p_assignment_id       = asg.assignment_id
    and   pwi.PERSON_ID       = asg.PERSON_ID
    and hl.lookup_type = 'INCIDENT_TYPE'
    and   pwi.INCIDENT_TYPE         = hl.lookup_code
    and hl.meaning = p_reference ;
--
BEGIN
  open csr_find_match;
  fetch csr_find_match into l_valid;
  if csr_find_match%NOTFOUND then
    l_valid := 'FALSE';
  end if;
  close csr_find_match;
return l_valid;
END Valid_Work_incidents;

/* Added following two procedures as user hooks for BUG 3030621 */
procedure insert_element_entry
 (p_element_entry_id           in number
 )is
  l_procedure_name                varchar2(61) := 'hr_ie_element_entry_hook.insert_element_name' ;
  l_absence_start_date            varchar2(30);
  l_absence_end_date              varchar2(30);
 --
 begin
   --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN
    --
    open g_absence_dates (p_element_entry_id);
      for i in 1..2 loop
           if i=1 then
             fetch g_absence_dates
             into l_absence_start_date;
           elsif i=2 then
             fetch g_absence_dates
             into l_absence_end_date;
           end if;
      end loop;
      close g_absence_dates  ;
      hr_utility.trace('In: ' || l_procedure_name) ;
      if l_absence_start_date is not null and l_absence_end_date is not null then
        if FND_DATE.CANONICAL_TO_DATE(l_absence_start_date) > FND_DATE.CANONICAL_TO_DATE(l_absence_end_date) then
          hr_utility.set_message(801,'HR_IE_SOCIAL_BENEFIT_DATES');
          hr_utility.raise_error;
        end if;
      end if;
      hr_utility.trace('Out: ' || l_procedure_name) ;
	END IF;
 end insert_element_entry  ;
 --
 procedure update_element_entry
 ( p_element_entry_id           in number
  ) is
   l_procedure_name                varchar2(61) := 'hr_ie_element_entry_hook.update_element_name' ;
   l_absence_start_date            varchar2(30);
   l_absence_end_date              varchar2(30);
  begin
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'IE') THEN
     --
     open g_absence_dates (p_element_entry_id);
     for i in 1..2 loop
          if i=1 then
           fetch g_absence_dates
           into l_absence_start_date;
         elsif i=2 then
           fetch g_absence_dates
           into l_absence_end_date;
         end if;
     end loop;
     close g_absence_dates ;
     hr_utility.trace('In: ' || l_procedure_name) ;
     if l_absence_start_date is not null and l_absence_end_date is not null then
       if FND_DATE.CANONICAL_TO_DATE(l_absence_start_date) > FND_DATE.CANONICAL_TO_DATE(l_absence_end_date) then
         hr_utility.set_message(801,'HR_IE_SOCIAL_BENEFIT_DATES');
         hr_utility.raise_error;
       end if;
     end if;
     hr_utility.trace('Out: ' || l_procedure_name) ;
   END IF;
 end update_element_entry  ;
--
/* End of BUG 3030621 */
/*ADDED FOUR FUNCTIONS FOR BUG 3030616 */
--
function get_monthly_std_rate_cut_off
(p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
RETURN number
is
	CURSOR get_global_val(l_name IN VARCHAR2) IS
	SELECT global_value
	FROM   ff_globals_f,fnd_sessions ses
	WHERE  global_name = l_name
	AND ses.session_id = userenv('SESSIONID')
	AND ses.effective_date BETWEEN effective_start_date AND effective_end_date;
	--
	CURSOR get_pay_frequency_csr IS
	SELECT pp.period_type
	FROM pay_all_payrolls_f pp, per_all_assignments_f pa,fnd_sessions ses
	WHERE pa.assignment_id = p_assignment_id
	AND ses.session_id = userenv('SESSIONID')
	AND   ses.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date
	AND   pp.payroll_id = pa.payroll_id
	AND   ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
	--
	CURSOR monthly_std_rate_cut_off IS
	SELECT nvl(pp.monthly_std_rate_cut_off,0)
	FROM pay_ie_paye_details_f pp,fnd_sessions ses
	WHERE pp.assignment_id=p_assignment_id
	AND ses.session_id = userenv('SESSIONID')
	AND ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
	--
	get_pay_frequency_rec get_pay_frequency_csr%ROWTYPE;
	v_monthly_std_rate_cut_off number;
BEGIN
--
OPEN get_pay_frequency_csr;
FETCH get_pay_frequency_csr INTO get_pay_frequency_rec;
CLOSE get_pay_frequency_csr;
--
IF p_tax_basis='IE_EMERGENCY' THEN
        IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')  THEN
        	 OPEN get_global_val('IE_MONTHLY_STANDARD_RATE_CUT_OFF');
		 FETCH get_global_val INTO v_monthly_std_rate_cut_off;
	         CLOSE get_global_val;
        ELSE
              v_monthly_std_rate_cut_off:= NULL;
		--
	END IF;
ELSIF   p_tax_basis='IE_EMERGENCY_NO_PPS' THEN
        v_monthly_std_rate_cut_off:= NULL;
ELSE
	IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')
        THEN
        	  OPEN monthly_std_rate_cut_off;
		  FETCH monthly_std_rate_cut_off INTO v_monthly_std_rate_cut_off;
		  CLOSE monthly_std_rate_cut_off;
        ELSE
                  v_monthly_std_rate_cut_off:= NULL;
        END IF;
 END IF;
 --
 RETURN v_monthly_std_rate_cut_off;
 --
 END get_monthly_std_rate_cut_off;
 --
 function get_monthly_tax_credit
 (p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
 p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
 RETURN number
 is
 	CURSOR get_global_val(l_name IN VARCHAR2) IS
 	SELECT global_value
 	FROM   ff_globals_f,fnd_sessions ses
 	WHERE  global_name = l_name
 	AND ses.session_id = userenv('SESSIONID')
 	AND ses.effective_date BETWEEN effective_start_date AND effective_end_date;
 	--
 	CURSOR get_pay_frequency_csr IS
 	SELECT pp.period_type
 	FROM pay_all_payrolls_f pp, per_all_assignments_f pa,fnd_sessions ses
 	WHERE pa.assignment_id = p_assignment_id
 	AND ses.session_id = userenv('SESSIONID')
 	AND   ses.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date
 	AND   pp.payroll_id = pa.payroll_id
 	AND   ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
 	--
 	CURSOR monthly_tax_credit IS
 	SELECT nvl(pp.monthly_tax_credit,0)
 	FROM pay_ie_paye_details_f pp,fnd_sessions ses
 	WHERE pp.assignment_id=p_assignment_id
 	AND ses.session_id = userenv('SESSIONID')
 	AND ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
 	--
 	get_pay_frequency_rec get_pay_frequency_csr%ROWTYPE;
 	v_get_monthly_tax_credit number;
 --
 BEGIN
 --
 	OPEN get_pay_frequency_csr;
 	FETCH get_pay_frequency_csr INTO get_pay_frequency_rec;
 	CLOSE get_pay_frequency_csr;
 --
 IF p_tax_basis='IE_EMERGENCY' THEN
         IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')  THEN
 --
 	OPEN get_global_val('IE_MONTHLY_TAX_CREDIT');
 	FETCH get_global_val INTO v_get_monthly_tax_credit;
 	CLOSE get_global_val;
 --
         ELSE
         v_get_monthly_tax_credit:= NULL;
 --
         END IF;
 --
 ELSIF p_tax_basis='IE_EMERGENCY_NO_PPS' THEN
       v_get_monthly_tax_credit:= NULL;
 --
        ELSE
        IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')
        THEN
 	OPEN monthly_tax_credit ;
 	FETCH monthly_tax_credit INTO v_get_monthly_tax_credit;
 	CLOSE monthly_tax_credit;
 	ELSE
 v_get_monthly_tax_credit:= 0;
         END IF;
 END IF;
 --
 RETURN v_get_monthly_tax_credit;
 --
END get_monthly_tax_credit;
--
 function get_weekly_std_rate_cut_off
(p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
RETURN number
is
	CURSOR get_global_val(l_name IN VARCHAR2) IS
	SELECT global_value
	FROM   ff_globals_f,fnd_sessions ses
	WHERE  global_name = l_name
	AND ses.session_id = userenv('SESSIONID')
	AND ses.effective_date BETWEEN effective_start_date AND effective_end_date;
	--
	CURSOR get_pay_frequency_csr IS
	SELECT pp.period_type
	FROM pay_all_payrolls_f pp, per_all_assignments_f pa,fnd_sessions ses
	WHERE pa.assignment_id = p_assignment_id
	AND ses.session_id = userenv('SESSIONID')
	AND   ses.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date
	AND   pp.payroll_id = pa.payroll_id
	AND   ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
	--
	CURSOR weekly_std_rate_cut_off IS
	SELECT nvl(pp.weekly_std_rate_cut_off,0)
	FROM pay_ie_paye_details_f pp,fnd_sessions ses
	WHERE pp.assignment_id=p_assignment_id
	AND ses.session_id = userenv('SESSIONID')
	AND ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
	--
	get_pay_frequency_rec get_pay_frequency_csr%ROWTYPE;
	v_weekly_std_rate_cut_off number;
BEGIN
--
OPEN get_pay_frequency_csr;
FETCH get_pay_frequency_csr INTO get_pay_frequency_rec;
CLOSE get_pay_frequency_csr;
--
IF p_tax_basis='IE_EMERGENCY' THEN
        IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')  THEN
                v_weekly_std_rate_cut_off:= NULL;
--
        ELSE
		OPEN get_global_val('IE_WEEKLY_STANDARD_RATE_CUT_OFF');
		FETCH get_global_val INTO v_weekly_std_rate_cut_off;
		CLOSE get_global_val;
		--
	END IF;
ELSIF   p_tax_basis='IE_EMERGENCY_NO_PPS' THEN
                  v_weekly_std_rate_cut_off:= NULL;
ELSE
	IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')
        THEN
                  v_weekly_std_rate_cut_off:= NULL;
        ELSE
		  OPEN weekly_std_rate_cut_off;
		  FETCH weekly_std_rate_cut_off INTO v_weekly_std_rate_cut_off;
		  CLOSE weekly_std_rate_cut_off;
        END IF;
 END IF;
 --
 RETURN v_weekly_std_rate_cut_off;
 --
 END get_weekly_std_rate_cut_off;
 --
 function get_weekly_tax_credit
 (p_assignment_id in pay_ie_paye_details_f.ASSIGNMENT_ID%TYPE,
 p_tax_basis in pay_ie_paye_details_f.TAX_BASIS%TYPE)
 RETURN number
 is
 	CURSOR get_global_val(l_name IN VARCHAR2) IS
 	SELECT global_value
 	FROM   ff_globals_f,fnd_sessions ses
 	WHERE  global_name = l_name
 	AND ses.session_id = userenv('SESSIONID')
 	AND ses.effective_date BETWEEN effective_start_date AND effective_end_date;
 	--
 	CURSOR get_pay_frequency_csr IS
 	SELECT pp.period_type
 	FROM pay_all_payrolls_f pp, per_all_assignments_f pa,fnd_sessions ses
 	WHERE pa.assignment_id = p_assignment_id
 	AND ses.session_id = userenv('SESSIONID')
 	AND   ses.effective_date BETWEEN pa.effective_start_date AND pa.effective_end_date
 	AND   pp.payroll_id = pa.payroll_id
 	AND   ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
 	--
 	CURSOR weekly_tax_credit IS
 	SELECT nvl(pp.weekly_tax_credit,0)
 	FROM pay_ie_paye_details_f pp,fnd_sessions ses
 	WHERE pp.assignment_id=p_assignment_id
 	AND ses.session_id = userenv('SESSIONID')
 	AND ses.effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date;
 	--
 	get_pay_frequency_rec get_pay_frequency_csr%ROWTYPE;
 	v_get_weekly_tax_credit number;
 BEGIN
 --
 	OPEN get_pay_frequency_csr;
 	FETCH get_pay_frequency_csr INTO get_pay_frequency_rec;
 	CLOSE get_pay_frequency_csr;
 --
 IF p_tax_basis='IE_EMERGENCY' THEN
         IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')  THEN
            v_get_weekly_tax_credit:= NULL;
      --
 	ELSE
 	  OPEN get_global_val('IE_WEEKLY_TAX_CREDIT');
 	  FETCH get_global_val INTO v_get_weekly_tax_credit;
 	  CLOSE get_global_val;
         END IF;
 ELSIF p_tax_basis='IE_EMERGENCY_NO_PPS' THEN
       v_get_weekly_tax_credit:= NULL;
 ELSE
        IF get_pay_frequency_rec.period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year')
        THEN
           v_get_weekly_tax_credit:= NULL;
        ELSE
 	  OPEN weekly_tax_credit ;
 	  FETCH weekly_tax_credit INTO v_get_weekly_tax_credit;
 	  CLOSE weekly_tax_credit;
        END IF;
  END IF;
  RETURN v_get_weekly_tax_credit;
  --
 END get_weekly_tax_credit;
 --
 /* End of BUG 3030616 */

/*-------------------- decode_value_char --------------------*/
function decode_value_char(p_expression boolean,
                      p_true	     varchar2,
			    p_false      varchar2) return varchar2 is
begin
if p_expression then
	return p_true;
else
	return p_false;
end if;

end decode_value_char;

/*-------------------- decode_value_date --------------------*/
function decode_value_date(p_expression boolean,
                      p_true	     date,
			    p_false      date) return date is
begin
if p_expression then
	return p_true;
else
	return p_false;
end if;

end decode_value_date;


/*-------------------- decode_value_number --------------------*/
function decode_value_number(p_expression boolean,
                      p_true	     number,
			    p_false      number) return number is
begin
if p_expression then
	return p_true;
else
	return p_false;
end if;

end decode_value_number;



/*Bug 4080773*/

PROCEDURE update_paye_change_freq(p_assignment_id			number
                                 ,p_effective_date			date
					   ,p_payroll_id				number
					   ,P_DATETRACK_UPDATE_MODE		VARCHAR2
					   ,p_tax_upload_flag			varchar2 default 'X'
					   ,p_tax_basis				varchar2 default null
					   ,p_cert_start_date			date default null -- 17140460.6
					   ,p_cert_end_date			date default null
					   ,p_weekly_tax_credit			number default null
				         ,p_monthly_tax_credit		number default null
			               ,p_weekly_std_rate_cut_off		number default null
					   ,p_monthly_std_rate_cut_off	number default null
					   ,p_tax_deducted_to_date		number default null
					   ,p_pay_to_date				number default null
					   ,p_cert_date                 date ) is  --4878630

Cursor c_effective_paye is select *
from pay_ie_paye_details_f
where p_effective_date between effective_start_date and effective_end_date
  and assignment_id = p_assignment_id
  order by effective_start_date asc;

cursor c_future_paye(p_paye_details_id number) is select *
from pay_ie_paye_details_f
where p_effective_date < effective_start_date
and assignment_id = p_assignment_id
and ((paye_details_id <> p_paye_details_id and p_paye_details_id is not null) or p_paye_details_id is null )
order by effective_start_date asc;

/* Cusror added for tax credit upload */  --4878630
Cursor c_tax_effective_paye(p_paye_id number,p_date date) is
select *
from  pay_ie_paye_details_f
where ((p_date < effective_start_date and trunc(p_date,'Y') = trunc(effective_start_date,'Y') and p_paye_id is null)
or    (paye_details_id <> p_paye_id and p_paye_id is not null and p_date < effective_start_date))
and   assignment_id = p_assignment_id
order by effective_start_date desc;


Cursor csr_get_assg(p_assignment_id in number,p_effective_date date) is
		     SELECT payroll_id  ,effective_start_date
       	       FROM per_all_assignments_f paa
		      WHERE paa.assignment_id=p_assignment_id
        	       AND  p_effective_date between paa.effective_start_date
                                   and paa.effective_end_date;

CURSOR get_global_val(l_name IN VARCHAR2,p_effective_date date) IS
      	           SELECT  global_value
            	     FROM  ff_globals_f
            	    WHERE  global_name = l_name
            	      AND  p_effective_date BETWEEN effective_start_date AND effective_end_date;

Cursor csr_freq(p_payroll_id number,p_effective_date date) IS
		    SELECT 1
		      FROM pay_all_payrolls_f pp
		     WHERE pp.payroll_id = p_payroll_id
		       AND p_effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date
                       AND period_type IN ('Calendar Month', 'Quarter', 'Bi-Month', 'Semi-Month', 'Semi-Year', 'Year');


c_effective_paye_fetch  c_effective_paye%rowtype;
c_future_paye_fetch c_future_paye%rowtype;
c_tax_upload_paye	c_tax_effective_paye%rowtype;
l_asg_effective_start_date date;
l_start_date		date;
l_end_date		date;
l_api_ovn	NUMBER;
l_monthly_tax_credit NUMBER:=0;
l_monthly_std_rate_cut_off NUMBER:=0;
l_weekly_tax_credit	NUMBER:=0;
l_weekly_std_rate_cut_off	NUMBER:=0;
l_tax_basis varchar2(20):='IE_CUMULATIVE';
l_info_source varchar2(20):='IE_NONE_PROVIDED';
l_tax_assess_basis varchar2(20):='IE_SEP_ASSESS';
l_certificate_issue_date date;
l_certificate_end_date date;
p_update_mode varchar2(20);
l_assignment_id number;
L_PRIM_PAYROLL_ID number;
L_EFFECTIVE_DATE date;
l_old_flag		NUMBER:=0;
l_new_flag		NUMBER:=0;
L_MIN_PAYE_ID number;
L_MIN_EFFECTIVE_DATE date;
L_NEW_PAYROLL_ID number;
L_CERTIFICATE_START_DATE date;
l_futrec_effective_end_date date;
l_max_paye_id	pay_ie_paye_details_f.paye_details_id%TYPE; --4878630
l_max_effective_start_date	date; --4878630
BEGIN
l_new_payroll_id := p_payroll_id;
l_effective_date :=p_effective_date;
l_assignment_id := p_assignment_id;
/*Checking whether pay frequency is changed or not*/
hr_utility.set_location('In update_paye_change_freq',840);
hr_utility.set_location('effective date..'||l_effective_date,841);
hr_utility.set_location('p_payroll_id..'||p_payroll_id,842);
hr_utility.set_location('p_tax_upload_flag..'||p_tax_upload_flag,843);
hr_utility.set_location('p_tax_basis..'|| p_tax_basis,844);
hr_utility.set_location('p_cert_start_date..'|| p_cert_start_date,845);
hr_utility.set_location('p_cert_end_date..'|| p_cert_end_date,846);
hr_utility.set_location('p_weekly_tax_credit ..'|| p_weekly_tax_credit,847);
hr_utility.set_location('p_monthly_tax_credit..'|| p_monthly_tax_credit,848);
hr_utility.set_location('p_weekly_std_rate_cut_off..'|| p_weekly_std_rate_cut_off,849);
hr_utility.set_location('p_monthly_std_rate_cut_off..'|| p_monthly_std_rate_cut_off,850);
hr_utility.set_location('p_tax_deducted_to_date..'|| p_tax_deducted_to_date,851);
hr_utility.set_location('p_pay_to_date..'|| p_pay_to_date,852);


if l_new_payroll_id is not null then
     hr_utility.set_location('l_new_payroll_id is not null..'|| l_new_payroll_id,853);
	if p_tax_upload_flag <> 'TU' then  --4878630
	  hr_utility.set_location('p_tax_upload_flag <> TU..'|| l_new_payroll_id,854);
		open csr_get_assg(l_assignment_id,l_effective_date);
		fetch csr_get_assg into l_prim_payroll_id,l_asg_effective_start_date;
		close csr_get_assg;

		if (g_old_payroll_id is not null) then -- if global var is set use global value
			l_prim_payroll_id := g_old_payroll_id;
		end if;
		unset_old_payroll_id;

		open csr_freq(l_prim_payroll_id,l_effective_date);
		fetch csr_freq into l_old_flag;
		close csr_freq;

		open csr_freq(l_new_payroll_id,l_effective_date);
		fetch csr_freq into l_new_flag;
		close csr_freq;
	end if; -- p_tax_upload_flag <> 'TU'

	if ( l_new_flag <> l_old_flag or  p_tax_upload_flag <> 'X' )  then    -- --4878630
	/*Fetching global values */
	hr_utility.set_location('l_new_flag <> l_old_flag or  p_tax_upload_flag <> X',855);
		if l_new_flag =1 and p_tax_upload_flag <> 'TU' then
		hr_utility.set_location('l_new_flag =1',856);
		   open get_global_val('IE_MONTHLY_TAX_CREDIT',l_effective_date);
		   fetch get_global_val into l_monthly_tax_credit;
		   close get_global_val;
		   open get_global_val('IE_MONTHLY_STANDARD_RATE_CUT_OFF',l_effective_date);
		   fetch get_global_val into l_monthly_std_rate_cut_off;
		   close get_global_val;
		   /* For monthly payroll, weekly values must be null */
		   l_weekly_tax_credit		:=NULL;
		   l_weekly_std_rate_cut_off	:=NULL;
		elsif l_new_flag = 0 and p_tax_upload_flag <> 'TU'	then
		hr_utility.set_location('l_new_flag =0',857);
		   open get_global_val('IE_WEEKLY_TAX_CREDIT',l_effective_date);
		   fetch get_global_val into l_weekly_tax_credit;
		   close get_global_val;
		   open get_global_val('IE_WEEKLY_STANDARD_RATE_CUT_OFF',l_effective_date);
		   fetch get_global_val into l_weekly_std_rate_cut_off;
		   close get_global_val;
   		   /* For weekly payroll, monthly values must be null */
		   l_monthly_tax_credit		:=NULL;
		   l_monthly_std_rate_cut_off	:=NULL;
		elsif p_tax_upload_flag = 'TU' then -- --4878630
		hr_utility.set_location('p_tax_upload_flag =TU',858);
			l_weekly_tax_credit		:= p_weekly_tax_credit;
			l_monthly_tax_credit		:= p_monthly_tax_credit;
			l_weekly_std_rate_cut_off	:= p_weekly_std_rate_cut_off;
			l_monthly_std_rate_cut_off	:= p_monthly_std_rate_cut_off;
		   /* fetch values from interface table */
		end if;

		open c_effective_paye ;
		fetch c_effective_paye into c_effective_paye_fetch;
		if c_effective_paye%found then
		hr_utility.set_location('if found',859);
		     -- delete all future records ie diff paye_details_id
		     open c_future_paye(c_effective_paye_fetch.paye_details_id);
		     loop
			     fetch c_future_paye into c_future_paye_fetch;
			     EXIT when c_future_paye%NOTFOUND;
			     		hr_utility.set_location('if loop',860);
					pay_ie_paye_api.delete_ie_paye_details
						    (p_validate                 => FALSE
						    ,p_effective_date           => c_future_paye_fetch.effective_start_date
						    ,p_datetrack_delete_mode    => 'ZAP'
						    ,p_paye_details_id          => c_future_paye_fetch.paye_details_id
						    ,p_object_version_number    => c_future_paye_fetch.object_version_number
						    ,p_effective_start_date     => l_start_date
						    ,p_effective_end_date       => l_end_date
						    );
		     end loop;
		     close c_future_paye;
		   -- FETCH OVN
		   l_api_ovn := c_effective_paye_fetch.object_version_number;
		   hr_utility.set_location('l_api_ovn..'||l_api_ovn,861);
		   --if the start date is the effective date in the form then only mode possible should be CORRECTION
 		   if (c_effective_paye_fetch.tax_basis <> 'IE_CUMULATIVE' and c_effective_paye_fetch.tax_basis <> 'IE_EXEMPTION'
                       and c_effective_paye_fetch.tax_basis <> 'IE_WEEK1_MONTH1' and c_effective_paye_fetch.tax_basis <> 'IE_EXEMPT_WEEK_MONTH'
			     and p_tax_upload_flag <> 'TU' ) then
			     hr_utility.set_location('Emergency ..',862);
			   l_weekly_tax_credit:=NULL;
			   l_weekly_std_rate_cut_off:=NULL;
			   l_monthly_tax_credit:=NULL;
			   l_monthly_std_rate_cut_off:=NULL;
		   end if;
		   --if there are no future changes to the paye record.
		   if c_effective_paye_fetch.effective_end_date <> to_date('31-12-4712','DD-MM-YYYY') then
			--if there are future changes.Then just leave one till 4712 using mode future change
			hr_utility.set_location('date <> 31-12-4712',863);
				pay_ie_paye_api.delete_ie_paye_details
						    (p_validate                 => FALSE
						    ,p_effective_date           => c_effective_paye_fetch.effective_start_date
						    ,p_datetrack_delete_mode    => 'FUTURE_CHANGE'
						    ,p_paye_details_id          => c_effective_paye_fetch.paye_details_id
						    ,p_object_version_number    => l_api_ovn
						    ,p_effective_start_date     => l_start_date
						    ,p_effective_end_date       => l_end_date
						    );

		   end if;

			  if c_effective_paye_fetch.effective_start_date = p_effective_date then
				          hr_utility.set_location('c_effective_paye_fetch.effective_start_date = p_effective_date',864);
				  --if P_DATETRACK_UPDATE_MODE = 'CORRECTION' then
					pay_ie_paye_api.update_ie_paye_details
							(p_validate                 => FALSE
						       ,p_effective_date            =>  p_effective_date
						       ,p_datetrack_update_mode     =>  'CORRECTION'
						       ,p_paye_details_id           =>  c_effective_paye_fetch.paye_details_id
						       ,p_info_source               =>  decode_value_char(p_tax_upload_flag ='X',c_effective_paye_fetch.info_source,'IE_ELECTRONIC')
						       ,p_tax_basis                 =>  decode_value_char(p_tax_upload_flag ='X',c_effective_paye_fetch.tax_basis,p_tax_basis) -- tax credit upload changes
						       ,p_certificate_start_date    =>  decode_value_date(p_tax_upload_flag='X',c_effective_paye_fetch.certificate_start_date,p_cert_start_date) -- tax credit upload changes 17140460.6
						       ,p_tax_assess_basis          =>  decode_value_char(p_tax_upload_flag ='X',c_effective_paye_fetch.tax_assess_basis,'IE_SEP_TREAT')
						       ,p_certificate_issue_date    =>  decode_value_date(p_tax_upload_flag='X',c_effective_paye_fetch.certificate_issue_date,p_cert_date) -- Bug 6929566 p_effective_date) -- tax credit upload changes
						       ,p_certificate_end_date      =>  decode_value_date(p_tax_upload_flag='X',c_effective_paye_fetch.certificate_end_date,p_cert_end_date) -- tax credit upload changes
						       ,p_weekly_tax_credit         =>  l_weekly_tax_credit
						       ,p_weekly_std_rate_cut_off   =>  l_weekly_std_rate_cut_off
						       ,p_monthly_tax_credit        =>  l_monthly_tax_credit
						       ,p_monthly_std_rate_cut_off  =>  l_monthly_std_rate_cut_off
						       ,p_tax_deducted_to_date      =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,p_tax_deducted_to_date) -- tax credit upload change
						       ,p_pay_to_date               =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,p_pay_to_date) -- tax credit upload change
						       ,p_disability_benefit        =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,null) -- tax credit upload change
						       ,p_lump_sum_payment          =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,null) -- tax credit upload change
						       ,p_object_version_number     =>  l_api_ovn
						       ,p_effective_start_date      =>  l_start_date
						       ,p_effective_end_date       =>   l_end_date
						       );
			else   --c_effective_paye_fetch.effective_start_date <> p_effective_date
			-- should always be update with new credits and cutoffs
					if P_DATETRACK_UPDATE_MODE = 'CORRECTION' then
						-- check with asg start date
					 hr_utility.set_location('Correction and <> TU',865);
						if (l_asg_effective_start_date <= c_effective_paye_fetch.effective_start_date ) then
							pay_ie_paye_api.update_ie_paye_details
								(p_validate                 => FALSE
							       ,p_effective_date            =>  p_effective_date
							       ,p_datetrack_update_mode     =>  'CORRECTION'
							       ,p_paye_details_id           =>  c_effective_paye_fetch.PAYE_DETAILs_ID
							       ,p_info_source               =>  c_effective_paye_fetch.info_source
							       ,p_tax_basis                 =>  c_effective_paye_fetch.tax_basis
							       ,p_certificate_start_date    =>  c_effective_paye_fetch.certificate_start_date
							       ,p_tax_assess_basis          =>  c_effective_paye_fetch.tax_assess_basis
							       ,p_certificate_issue_date    =>  c_effective_paye_fetch.certificate_issue_date
							       ,p_certificate_end_date      =>  c_effective_paye_fetch.certificate_end_date
							       ,p_weekly_tax_credit         =>  l_weekly_tax_credit
							       ,p_weekly_std_rate_cut_off   =>  l_weekly_std_rate_cut_off
							       ,p_monthly_tax_credit        =>  l_monthly_tax_credit
							       ,p_monthly_std_rate_cut_off  =>  l_monthly_std_rate_cut_off
							       ,p_tax_deducted_to_date      =>  hr_api.g_number
							       ,p_pay_to_date               =>  hr_api.g_number
							       ,p_disability_benefit        =>  hr_api.g_number
							       ,p_lump_sum_payment          =>  hr_api.g_number
							       ,p_object_version_number     =>  l_api_ovn
							       ,p_effective_start_date      =>  l_start_date
							       ,p_effective_end_date       =>   l_end_date);
						else -- asg start date > paye start  date then update using asg start date
						hr_utility.set_location('Correction and <> TU',865);
							pay_ie_paye_api.update_ie_paye_details
								(p_validate                 => FALSE
							       ,p_effective_date            =>   l_asg_effective_start_date
							       ,p_datetrack_update_mode     =>  'UPDATE'
							       ,p_paye_details_id           =>  c_effective_paye_fetch.PAYE_DETAILs_ID
							       ,p_info_source               =>  c_effective_paye_fetch.info_source
							       ,p_tax_basis                 =>  c_effective_paye_fetch.tax_basis
							       ,p_certificate_start_date    =>  c_effective_paye_fetch.certificate_start_date
							       ,p_tax_assess_basis          =>  c_effective_paye_fetch.tax_assess_basis
							       ,p_certificate_issue_date    =>  c_effective_paye_fetch.certificate_issue_date
							       ,p_certificate_end_date      =>  c_effective_paye_fetch.certificate_end_date
							       ,p_weekly_tax_credit         =>  l_weekly_tax_credit
							       ,p_weekly_std_rate_cut_off   =>  l_weekly_std_rate_cut_off
							       ,p_monthly_tax_credit        =>  l_monthly_tax_credit
							       ,p_monthly_std_rate_cut_off  =>  l_monthly_std_rate_cut_off
							       ,p_tax_deducted_to_date      =>  hr_api.g_number
							       ,p_pay_to_date               =>  hr_api.g_number
							       ,p_disability_benefit        =>  hr_api.g_number
							       ,p_lump_sum_payment          =>  hr_api.g_number
							       ,p_object_version_number     =>  l_api_ovn
							       ,p_effective_start_date      =>  l_start_date
							       ,p_effective_end_date       =>   l_end_date);
						end if; -- end of check with asg start date
					else -- P_DATETRACK_UPDATE_MODE <> 'CORRECTION'
					hr_utility.set_location('UPDATE and = TU',866);
						pay_ie_paye_api.update_ie_paye_details
								(p_validate                 => FALSE
							       ,p_effective_date            =>  p_effective_date
							       ,p_datetrack_update_mode     =>  'UPDATE'
							       ,p_paye_details_id           =>  c_effective_paye_fetch.PAYE_DETAILs_ID
							       ,p_info_source               =>  decode_value_char(p_tax_upload_flag ='X',c_effective_paye_fetch.info_source,'IE_ELECTRONIC')
							       ,p_tax_basis                 =>  decode_value_char(p_tax_upload_flag='X',c_effective_paye_fetch.tax_basis,p_tax_basis) -- tax credit upload changes
							       ,p_certificate_start_date    =>  decode_value_date(p_tax_upload_flag='X',c_effective_paye_fetch.certificate_start_date,p_cert_start_date) -- tax credit upload changes, 17140460.6
							       ,p_tax_assess_basis          =>  decode_value_char(p_tax_upload_flag ='X',c_effective_paye_fetch.tax_assess_basis,'IE_SEP_TREAT')
							       ,p_certificate_issue_date    =>  decode_value_date(p_tax_upload_flag='X',c_effective_paye_fetch.certificate_issue_date,p_cert_date) -- Bug 6929566 p_effective_date) -- tax credit upload changes
							       ,p_certificate_end_date      =>  decode_value_date(p_tax_upload_flag='X',c_effective_paye_fetch.certificate_end_date,p_cert_end_date) -- tax credit upload changes
							       ,p_weekly_tax_credit         =>  l_weekly_tax_credit
							       ,p_weekly_std_rate_cut_off   =>  l_weekly_std_rate_cut_off
							       ,p_monthly_tax_credit        =>  l_monthly_tax_credit
							       ,p_monthly_std_rate_cut_off  =>  l_monthly_std_rate_cut_off
							       ,p_tax_deducted_to_date      =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,p_tax_deducted_to_date) -- tax credit upload change
							       ,p_pay_to_date               =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,p_pay_to_date) -- tax credit upload change
							       ,p_disability_benefit        =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,null) -- tax credit upload change
							       ,p_lump_sum_payment          =>  decode_value_number(p_tax_upload_flag='X',hr_api.g_number,null) -- tax credit upload change
							       ,p_object_version_number     =>  l_api_ovn
							       ,p_effective_start_date      =>  l_start_date
							       ,p_effective_end_date       =>   l_end_date);
					end if; --P_DATETRACK_UPDATE_MODE = 'CORRECTION'
					hr_utility.set_location('After datetrack check',867);
			   end if; -- c_effective_paye_fetch.effective_start_date = p_effective_date
		else -- not found
		--get the first record as of effective date.This is becasue there mare reocrds only afte the effective date.Nothing as of
		--the effective date.this record should be extended upto 4712
		hr_utility.set_location('Effective date does not lie between paye start and end date',868);
		     if p_tax_upload_flag <> 'TU' then  --4878630
		     hr_utility.set_location('<> TU',869);
			     open c_future_paye(null);
			     fetch c_future_paye into c_future_paye_fetch ;
			     l_min_paye_id := c_future_paye_fetch.paye_details_id ;
			     l_min_effective_date := c_future_paye_fetch.effective_start_date;
			     l_api_ovn := c_future_paye_fetch.object_version_number;
			     l_tax_basis := c_future_paye_fetch.tax_basis;
			     l_info_source := c_future_paye_fetch.info_source;
			     l_certificate_start_date :=  c_future_paye_fetch.certificate_start_date;
			     l_certificate_end_date :=  c_future_paye_fetch.certificate_end_date;
			     l_certificate_issue_date :=  c_future_paye_fetch.certificate_issue_date;
			     l_tax_assess_basis := c_future_paye_fetch.tax_assess_basis;
			     l_futrec_effective_end_date := c_future_paye_fetch.effective_end_date;
			     close c_future_paye;
		     else --4878630
				hr_utility.set_location('= TU',870);
				open c_tax_effective_paye(null,p_effective_date);
				fetch c_tax_effective_paye into c_tax_upload_paye;
				l_max_paye_id := c_tax_upload_paye.paye_details_id;
				l_max_effective_start_date := c_tax_upload_paye.effective_start_date;
				l_futrec_effective_end_date := c_tax_upload_paye.effective_end_date;
				l_api_ovn := c_tax_upload_paye.object_version_number;
				l_info_source := c_tax_upload_paye.info_source;
				--l_tax_assess_basis := c_tax_upload_paye.tax_assess_basis;
				CLOSE c_tax_effective_paye;
				hr_utility.set_location('l_max_paye_id..'|| l_max_paye_id,871);
				hr_utility.set_location('l_max_effective_start_date.'|| l_max_effective_start_date,872);
				hr_utility.set_location('l_futrec_effective_end_date '|| l_futrec_effective_end_date,873);
				hr_utility.set_location('l_api_ovn '|| l_api_ovn,874);
				hr_utility.set_location('l_info_source.'|| l_info_source,875);

			end if;
		     IF p_tax_upload_flag <> 'TU' then
			     --delete any other future records ie different paye_details_id
			     open c_future_paye(l_min_paye_id);
			     loop
				     fetch c_future_paye into c_future_paye_fetch;
				     EXIT when c_future_paye%NOTFOUND;
				     pay_ie_paye_api.delete_ie_paye_details
								    (p_validate                 => FALSE
								    ,p_effective_date           => c_future_paye_fetch.effective_start_date
								    ,p_datetrack_delete_mode    => 'ZAP'
								    ,p_paye_details_id          => c_future_paye_fetch.paye_details_id
								    ,p_object_version_number    => c_future_paye_fetch.object_version_number
								    ,p_effective_start_date     => l_start_date
								    ,p_effective_end_date       => l_end_date
								    );
			     end loop;
			     close c_future_paye;


			     if l_futrec_effective_end_date  <> to_date('31-12-4712','DD-MM-YYYY')
			     AND (l_futrec_effective_end_date  IS NOT NULL)
			     then
			     --extend the first record after the effective date till 4712
			     pay_ie_paye_api.delete_ie_paye_details
							    (p_validate                 => FALSE
							    ,p_effective_date           => l_min_effective_date
							    ,p_datetrack_delete_mode    => 'FUTURE_CHANGE'
							    ,p_paye_details_id          => l_min_paye_id
							    ,p_object_version_number    => l_api_ovn
							    ,p_effective_start_date     => l_start_date
							    ,p_effective_end_date       => l_end_date
							    );
			     end if;
			    if (l_tax_basis <> 'IE_CUMULATIVE' and l_tax_basis <> 'IE_EXEMPTION'
					and l_tax_basis <> 'IE_WEEK1_MONTH1' and l_tax_basis <> 'IE_EXEMPT_WEEK_MONTH') then
				  l_weekly_tax_credit:=NULL;
				  l_weekly_std_rate_cut_off:=NULL;
				  l_monthly_tax_credit:=NULL;
				  l_monthly_std_rate_cut_off:=NULL;
			    end if;
			    --only mode possible should be correction, using the new credits and cutoffs
			   IF (l_futrec_effective_end_date  IS NOT NULL) THEN
			     pay_ie_paye_api.update_ie_paye_details
							(p_validate                 => FALSE
							 ,p_effective_date            =>  l_min_effective_date
							 ,p_datetrack_update_mode     =>  'CORRECTION'
							 ,p_paye_details_id           =>  l_min_paye_id
							 ,p_info_source               =>  l_info_source
							 ,p_tax_basis                 =>  l_tax_basis
							 ,p_certificate_start_date    =>  l_certificate_start_date
							 ,p_tax_assess_basis          =>  l_tax_assess_basis
							 ,p_certificate_issue_date    =>  l_certificate_issue_date
							 ,p_certificate_end_date      =>  l_certificate_end_date
							 ,p_weekly_tax_credit         =>  l_weekly_tax_credit
							 ,p_weekly_std_rate_cut_off   =>  l_weekly_std_rate_cut_off
							 ,p_monthly_tax_credit        =>  l_monthly_tax_credit
							 ,p_monthly_std_rate_cut_off  =>  l_monthly_std_rate_cut_off
							 ,p_tax_deducted_to_date      =>  hr_api.g_number
							 ,p_pay_to_date               =>  hr_api.g_number
							 ,p_disability_benefit        =>  hr_api.g_number
							 ,p_lump_sum_payment          =>  hr_api.g_number
							 ,p_object_version_number     =>  l_api_ovn
							 ,p_effective_start_date      =>  l_start_date
							 ,p_effective_end_date       =>   l_end_date
							 );
			   END IF;-- futrec is null
			ELSE -- p_tax_upload_flag = 'TU'
				--delete any other future records ie different paye_details_id
				hr_utility.set_location('else of future paye.'|| l_info_source,876);
			     open c_tax_effective_paye(l_max_paye_id,l_max_effective_start_date);
			     loop
				     fetch c_tax_effective_paye into c_tax_upload_paye;
				     EXIT when c_tax_effective_paye%NOTFOUND;
				     hr_utility.set_location('In loop',878);
					hr_utility.set_location('c_tax_upload_paye.effective_start_date '|| c_tax_upload_paye.effective_start_date ,879);
					hr_utility.set_location('c_tax_upload_paye.paye_details_id.'||c_tax_upload_paye.paye_details_id,880);

				     pay_ie_paye_api.delete_ie_paye_details
								    (p_validate                 => FALSE
								    ,p_effective_date           => c_tax_upload_paye.effective_start_date
								    ,p_datetrack_delete_mode    => 'ZAP'
								    ,p_paye_details_id          => c_tax_upload_paye.paye_details_id
								    ,p_object_version_number    => c_tax_upload_paye.object_version_number
								    ,p_effective_start_date     => l_start_date
								    ,p_effective_end_date       => l_end_date
								    );
			     end loop;
			     hr_utility.set_location('else of future paye After ZAping',881);
			     close c_tax_effective_paye;

			     hr_utility.set_location('l_futrec_effective_end_date..'|| l_futrec_effective_end_date,879);
			     if l_futrec_effective_end_date  <> to_date('31-12-4712','DD-MM-YYYY')
			     AND (l_futrec_effective_end_date  IS NOT NULL)
			     then
			     --extend the first record after the effective date till 4712
			     pay_ie_paye_api.delete_ie_paye_details
							    (p_validate                 => FALSE
							    ,p_effective_date           => l_max_effective_start_date
							    ,p_datetrack_delete_mode    => 'FUTURE_CHANGE'
							    ,p_paye_details_id          => l_max_paye_id
							    ,p_object_version_number    => l_api_ovn
							    ,p_effective_start_date     => l_start_date
							    ,p_effective_end_date       => l_end_date
							    );
			     end if;

			    --only mode possible should be correction, using the new credits and cutoffs
			   IF (l_futrec_effective_end_date  IS NOT NULL) THEN
			   hr_utility.set_location('The last Mode',880);
			     pay_ie_paye_api.update_ie_paye_details
							(p_validate                 => FALSE
							 ,p_effective_date            =>  l_max_effective_start_date
							 ,p_datetrack_update_mode     =>  'CORRECTION'
							 ,p_paye_details_id           =>  l_max_paye_id
							 ,p_info_source               =>  'IE_ELECTRONIC'
							 ,p_tax_basis                 =>  p_tax_basis
							 ,p_certificate_start_date    =>  p_cert_start_date
							 ,p_tax_assess_basis          =>  'IE_SEP_TREAT'
							 ,p_certificate_issue_date    =>  p_effective_date
							 ,p_certificate_end_date      =>  p_cert_end_date
							 ,p_weekly_tax_credit         =>  p_weekly_tax_credit
							 ,p_weekly_std_rate_cut_off   =>  p_weekly_std_rate_cut_off
							 ,p_monthly_tax_credit        =>  p_monthly_tax_credit
							 ,p_monthly_std_rate_cut_off  =>  p_monthly_std_rate_cut_off
							 ,p_tax_deducted_to_date      =>  p_tax_deducted_to_date
							 ,p_pay_to_date               =>  p_pay_to_date
							 ,p_disability_benefit        =>  null
							 ,p_lump_sum_payment          =>  null
							 ,p_object_version_number     =>  l_api_ovn
							 ,p_effective_start_date      =>  l_start_date
							 ,p_effective_end_date       =>   l_end_date
							 );
					hr_utility.set_location('After The last Mode',881);
			   END IF;-- futrec is null

			END If; -- p_tax_upload_flag <> 'TU'
		end if; --if c_effective_paye%found
		close c_effective_paye;
	end if; --(l_new_flag <> l_old_flag)
end if; -- l_new_payroll_id is not null
END update_paye_change_freq;

Procedure set_old_payroll_id(
			     p_old_payroll_id number
			    )
IS
BEGIN
	g_old_payroll_id:=p_old_payroll_id;
END set_old_payroll_id;

Procedure unset_old_payroll_id
IS
BEGIN
	g_old_payroll_id:=null;
END unset_old_payroll_id;

Function get_old_payroll_id return number is
begin
 return g_old_payroll_id;
end get_old_payroll_id;
/*End of Bug 4080773*/

FUNCTION get_age_payroll_period(p_assignment_id   IN  NUMBER
                               ,p_payroll_id      IN  NUMBER
                               ,p_date_earned     IN  DATE) RETURN NUMBER IS
  --
  -- Local variables
  --
  l_proc                 VARCHAR2(120) := g_package || 'get_age_payroll_period';
  l_period_start_date    DATE;
  l_period_end_date      DATE;
  l_dob                  DATE;
  l_age_last_day_month   NUMBER;
  l_last_day_of_year  DATE;
  --
  v_last_name varchar2(100);
  v_asg_number varchar2(50);

  --
  -- Cursor get_period_dates
  --
  CURSOR get_period_dates IS
  SELECT ptp.start_date     start_date
        ,ptp.end_date       end_date
  FROM   per_time_periods   ptp
  WHERE  ptp.payroll_id=p_payroll_id
  AND p_date_earned    BETWEEN ptp.start_date AND ptp.end_date;
  --
  -- Cursor get_db
  --
  CURSOR get_dob IS
  SELECT date_of_birth,per.last_name,paf.assignment_number
  FROM   per_all_people_f per
        ,per_all_assignments_f paf
  WHERE  per.person_id      = paf.person_id
  AND    paf.assignment_id  = p_assignment_id
  AND    p_date_earned       BETWEEN per.effective_start_date AND per.effective_end_date
  AND    p_date_earned       BETWEEN paf.effective_start_date AND paf.effective_end_date;
  --
BEGIN
  --
  --  hr_utility.set_location('Entering:'|| l_proc, 5);

  --
  /*OPEN get_period_dates;
    FETCH get_period_dates INTO l_period_start_date,l_period_end_date;
  CLOSE get_period_dates;*/
  --
   l_last_day_of_year := to_date( '31/12/' || to_char(p_date_earned, 'YYYY'), 'DD/MM/YYYY');
  --
  --
  OPEN get_dob;
      FETCH get_dob INTO l_dob,v_last_name,v_asg_number;
  CLOSE get_dob;

  hr_utility.set_location('- Name   = '|| v_last_name, 5);
  hr_utility.set_location('- Asg No = '|| v_asg_number, 5);

  RETURN(TRUNC(MONTHS_BETWEEN(l_last_day_of_year,l_dob)/12));

  /*l_age_last_day_month := TRUNC(MONTHS_BETWEEN(last_day(p_date_earned),l_dob)/12);

  IF l_dob >= l_period_start_date AND l_dob <= l_period_end_date THEN
    RETURN(TRUNC(MONTHS_BETWEEN(l_period_end_date,l_dob)/12));
  ELSE
    RETURN(TRUNC(MONTHS_BETWEEN(p_date_earned,l_dob)/12));
  END IF;*/
END get_age_payroll_period;
--

FUNCTION get_age_paid_year(p_assignment_id number,
                       p_payroll_action_id number) RETURN NUMBER IS
  --
  -- Local variables
  --
  l_proc                 VARCHAR2(120) := g_package || 'get_age_payroll_period';
  l_period_start_date    DATE;
  l_period_end_date      DATE;
  l_dob                  DATE;
  l_age_last_day_month   NUMBER;
  l_last_day_of_year  DATE;
  --
  v_last_name varchar2(100);
  v_asg_number varchar2(50);
  l_date_paid date;
  --
  -- Cursor get_period_dates
  --
  CURSOR get_period_dates IS
  SELECT effective_date
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = p_payroll_action_id;
  --
  -- Cursor get_db
  --
  CURSOR get_dob IS
  SELECT date_of_birth,per.last_name,paf.assignment_number
  FROM   per_all_people_f per
        ,per_all_assignments_f paf
  WHERE  per.person_id      = paf.person_id
  AND    paf.assignment_id  = p_assignment_id
  AND    l_date_paid       BETWEEN per.effective_start_date AND per.effective_end_date
  AND    l_date_paid       BETWEEN paf.effective_start_date AND paf.effective_end_date;
  --
BEGIN
  --
  --  hr_utility.set_location('Entering:'|| l_proc, 5);

  --
  OPEN get_period_dates;
    FETCH get_period_dates INTO l_date_paid;
  CLOSE get_period_dates;
  --
   l_last_day_of_year := to_date( '31/12/' || to_char(l_date_paid, 'YYYY'), 'DD/MM/YYYY');
  --
  --
  OPEN get_dob;
      FETCH get_dob INTO l_dob,v_last_name,v_asg_number;
  CLOSE get_dob;

  hr_utility.set_location('- Name   = '|| v_last_name, 5);
  hr_utility.set_location('- Asg No = '|| v_asg_number, 5);

  RETURN(TRUNC(MONTHS_BETWEEN(l_last_day_of_year,l_dob)/12));

  /*l_age_last_day_month := TRUNC(MONTHS_BETWEEN(last_day(p_date_earned),l_dob)/12);

  IF l_dob >= l_period_start_date AND l_dob <= l_period_end_date THEN
    RETURN(TRUNC(MONTHS_BETWEEN(l_period_end_date,l_dob)/12));
  ELSE
    RETURN(TRUNC(MONTHS_BETWEEN(p_date_earned,l_dob)/12));
  END IF;*/
END get_age_paid_year;
--
FUNCTION get_periods_between(p_payroll_id number,
                               p_start_date date,
                               p_end_date date) RETURN NUMBER IS

l_num_periods NUMBER := 0;

CURSOR csr_get_periods_between IS
SELECT COUNT (*)
FROM per_time_periods
WHERE payroll_id = p_payroll_id
AND regular_payment_date BETWEEN p_start_date AND p_end_date;

BEGIN

OPEN csr_get_periods_between;
FETCH csr_get_periods_between INTO l_num_periods;
CLOSE csr_get_periods_between;

RETURN NVL(l_num_periods, 0);

END;
--
end pay_ie_paye_pkg;

/
