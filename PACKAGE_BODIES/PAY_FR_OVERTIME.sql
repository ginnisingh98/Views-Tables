--------------------------------------------------------
--  DDL for Package Body PAY_FR_OVERTIME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_OVERTIME" as
/* $Header: pyfrovtm.pkb 115.20 2004/03/31 08:34:12 autiwari noship $ */
--
g_package varchar2(30) := 'pay_fr_overtime';
--
TYPE scheme_rec is RECORD
(Overtime_Payroll_Id number
,Overtime_Scheme_Type varchar2(150)
,Threshold varchar2(150)
,Annual_Quota varchar2(150)
,Weekly_Offset_Threshold varchar2(150)
,Bonification_Method varchar2(150)
,Majoration_Method varchar2(150)
,Weekly_Compensation_Threshold varchar2(150)
,Upper_Compensation_Threshold varchar2(150)
,Lower_Compensation_Factor varchar2(150)
,Higher_Compensation_Factor varchar2(150)
,Overtime_Band_Table varchar2(150)
,Regularisation_Period_Type varchar2(150)
,Regularisation_Period_Weeks varchar2(150)
,Regularisation_Threshold varchar2(150)
,Regularisation_Offset varchar2(150)
,Regularisation_Payment_Basis varchar2(150)
,Regularisation_Start_Date varchar2(150)
,Overtime_formula_ID varchar2(150)
,Regularisation_Formula_ID varchar2(150));
--
null_scheme scheme_rec;
scheme scheme_rec;
--
TYPE band_rec is RECORD
(Label varchar2(30)
,Hours varchar2(30)
,Hours_Percentage varchar2(30)
,Factor varchar2(30));
--
TYPE band_tab is TABLE of band_rec INDEX by BINARY_INTEGER;
--
null_band band_tab;
band band_tab;
--
------------------------------------------------------------------------
-- Function GET_UPPER_COMP_THRESHOLD
--
-- This is a local function that derives the overtime scheme upper compensation
-- threshold by prorating the threshold applicable for the employee during the
-- year.
-- Once the effective date is reached, as long as the employee is assigned
-- to the overtime scheme on DATE_EARNED+1 the upper compensation threshold
-- effective on DATE_EARNED+1 is assumed to last until the end of the year.
-- If the they are not on an overtime scheme on DATE_EARNED+1 (perhaps
-- because they are a leaver) then the prorated threshold is only calculated
-- upt to DATE_EARNED.
------------------------------------------------------------------------
function get_upper_comp_threshold
(p_assignment_id number
,p_effective_date date) return number is
--
start_of_year date;
end_of_year date;
days_in_year number;
proration_factor number;
upper_compensation_threshold number;
prev_threshold number;
total_threshold number;
end_date date;
l_proc varchar2(72) := g_package||'.get_upper_comp_threshold';
--
cursor c_overtime_scheme is
select nvl(to_number(p.prl_information8),0) upper_compensation_threshold
,      greatest(start_of_year
               ,p.effective_start_date
               ,ee.effective_start_date) start_date
,      least(end_of_year
            ,p.effective_end_date
            ,ee.effective_end_date) end_date
from   pay_element_entries_f ee
,      pay_element_links_f el
,      pay_element_types_f et
,      pay_payrolls_f p
where  et.element_name = 'FR_OVERTIME'
and    p_effective_date
          between et.effective_start_date and et.effective_end_date
and    el.element_type_id = et.element_type_id
and    p_effective_date
          between el.effective_start_date and el.effective_end_date
and    el.element_link_id = ee.element_link_id
and    ee.assignment_id = p_assignment_id
and    p.effective_start_date <= ee.effective_end_date
and    p.effective_end_date >= ee.effective_start_date
and    fnd_number.canonical_to_number(ee.ENTRY_INFORMATION1) = p.payroll_id
and    p.effective_start_date <= end_of_year
and    p.effective_end_date >= start_of_year
and    ee.effective_start_date <= end_of_year
and    ee.effective_end_date >= start_of_year
order by greatest(start_of_year,p.effective_start_date,ee.effective_start_date);
--
begin
  hr_utility.set_location(l_proc,10);
/* Initialise parameters */
   start_of_year :=
                  to_date(to_char(p_effective_date,'YYYY')||'0101','YYYYMMDD');
   end_of_year := to_date(to_char(p_effective_date,'YYYY')||'1231','YYYYMMDD');
   days_in_year := end_of_year - start_of_year + 1;
   total_threshold := 0;
   --
/* Loop through the overtime scheme records
   If the start date is before date earned and the end date is after date
   earned then move the end date to end of year - we assume employee is on
   the scheme to the end of the year.

   If the start date is date earned + 1 then this implies that the employee
   had a scheme change on date earned but continues to receive overtime - hence
   use the upper compensation threshold applicable on date earned up until the
   end of the year
*/
   for e in c_overtime_scheme loop
       if e.start_date <= p_effective_date  then
          if e.end_date > p_effective_date then
             end_date := end_of_year;
          else
             end_date := e.end_date;
          end if;
          upper_compensation_threshold := e.upper_compensation_threshold;
       else -- e.start_date = p_effective_date + 1
          upper_compensation_threshold := prev_threshold;
          end_date := end_of_year;
       end if;
--
/*
   Calculate the prorated value of upper compensation threshold
   Keep running total of threshold value.
*/
       proration_factor := (end_date - e.start_date + 1) / days_in_year;
--
       total_threshold := total_threshold +
                              round(
                  upper_compensation_threshold * proration_factor,1);
       prev_threshold := upper_compensation_threshold;
--
/* Once the end date has reached end_of_year then no need to process further
   records
*/
       if end_date = end_of_year then
          exit;
       end if;
   end loop;
  hr_utility.set_location(l_proc,20);
   return total_threshold;
end;
--
------------------------------------------------------------------------
-- Function SET_SCHEME
--
-- This function retrieves the overtime scheme details of the employee
-- as of the p_date. The details are held in a PL/SQL table.
-- It also derives the band values.
------------------------------------------------------------------------
function set_scheme (p_assignment_id number
                    ,p_date date) return number is
cursor get_scheme is
Select to_char(SCHEME.PAYROLL_ID)
,PRL_INFORMATION1 -- Overtime_Scheme_Type
,PRL_INFORMATION2 -- Threshold
,PRL_INFORMATION3 -- Annual_Quota
,PRL_INFORMATION4 -- Weekly_Offset_Threshold
,nvl(TARGET.ENTRY_INFORMATION2,PRL_INFORMATION5) -- Bonification_Method
,nvl(TARGET.ENTRY_INFORMATION3,PRL_INFORMATION6) -- Majoration_Method
,PRL_INFORMATION7 -- Weekly_Compensation_Threshold
,'0' -- Upper_Compensation_Threshold
,PRL_INFORMATION9 -- Lower_Compensation_Factor
,PRL_INFORMATION10 -- Higher_Compensation_Factor
,PRL_INFORMATION11 -- Overtime_Band_Table
,PRL_INFORMATION12 -- Regularisation_Period_Type
,PRL_INFORMATION13 -- Regularisation_Period_Weeks
,PRL_INFORMATION14 -- Regularisation_Threshold
,PRL_INFORMATION15 -- Regularisation_Offset
,PRL_INFORMATION16 -- Regularisation_Payment_Basis
,nvl(TARGET.ENTRY_INFORMATION4,PRL_INFORMATION17) -- Regularisation_Start_Date
,nvl(PRL_INFORMATION18,'-1') -- Overtime Formula ID
,nvl(PRL_INFORMATION19,'-1') -- Regularisation Formula ID
from pay_element_entries_f                  TARGET
,       pay_element_links_f                    LINK
,       pay_element_types_f                    ELEMENT
,       pay_payrolls_f                         SCHEME
where   TARGET.assignment_id   = p_assignment_id
and     p_date BETWEEN TARGET.effective_start_date
                 AND TARGET.effective_end_date
and     TARGET.element_link_id = LINK.element_link_id
and     p_date BETWEEN LINK.effective_start_date
                 AND LINK.effective_end_date
and     LINK.element_type_id = ELEMENT.element_type_id
and     p_date BETWEEN ELEMENT.effective_start_date
                 AND ELEMENT.effective_end_date
and     ELEMENT.element_name = 'FR_OVERTIME'
and     fnd_number.canonical_to_number(TARGET.ENTRY_INFORMATION1)
                                            = SCHEME.payroll_id
and     p_date BETWEEN SCHEME.effective_start_date
                AND SCHEME.effective_end_date;
--
cursor get_band_values(p_band_table_id number) is
select r.ROW_LOW_RANGE_OR_NAME
,    decode(scheme.overtime_scheme_type,'F',ci1.VALUE,null) hours_value
,    decode(scheme.overtime_scheme_type,'P',ci1.VALUE,null) working_hours_value
,      ci2.VALUE factor_value
from   pay_user_rows_f r
,      pay_user_column_instances_f ci1
,      pay_user_column_instances_f ci2
,      pay_user_columns c1
,      pay_user_columns c2
where  r.user_table_id = p_band_table_id
and    p_date BETWEEN r.effective_start_date and r.effective_end_date
and    c1.user_table_id = p_band_table_id
and    c1.user_column_id = ci1.user_column_id
and    ci1.user_row_id = r.user_row_id
and    p_date BETWEEN ci1.effective_start_date and ci1.effective_end_date
and    c1.user_column_name = decode(scheme.overtime_scheme_type,
                                    'F','HOURS',
                                    'P','WORKING_HOURS_PERCENTAGE')
and    c2.user_table_id = p_band_table_id
and    c2.user_column_id = ci2.user_column_id
and    ci2.user_row_id = r.user_row_id
and    p_date BETWEEN ci2.effective_start_date and ci2.effective_end_date
and    c2.user_column_name = 'FACTOR'
order by r.display_sequence;
--
i number;
l_proc varchar2(72) := g_package||'.set_scheme';
begin
  hr_utility.set_location(l_proc,10);
   scheme := null_scheme;
   band := null_band;
   --
   open get_scheme;
   fetch get_scheme into scheme;
   if get_scheme%notfound then
      close get_scheme;
      return 1;
   else
      scheme.upper_compensation_threshold :=
           to_char(get_upper_comp_threshold(p_assignment_id,p_date));
   end if;
   close get_scheme;
   --
/* Check mandatory data */
   if (scheme.Overtime_Scheme_Type <> 'P' and
       scheme.Overtime_Scheme_Type <> 'F') then
      fnd_message.set_name('PAY','PAY_74966_MANDATORY_OT_TYPE');
      fnd_message.raise_error;
   end if;
   --
   if scheme.Overtime_Scheme_Type = 'F' then
      if scheme.threshold is null
      or scheme.Weekly_Offset_Threshold is null
      or (scheme.Bonification_Method <> 'P' and
          scheme.Bonification_Method <> 'T')
      or (scheme.Majoration_Method <> 'P' and
          scheme.Majoration_Method <> 'T')
      or scheme.Upper_Compensation_Threshold is null
      or scheme.Weekly_Compensation_Threshold is null
      or scheme.Lower_Compensation_Factor is null
      or scheme.Higher_Compensation_Factor is null
      or scheme.Overtime_Band_Table is null
      or (scheme.Regularisation_Payment_Basis <> 'W' and
          scheme.Regularisation_Payment_Basis <> 'C') then
         fnd_message.set_name('PAY','PAY_74967_MANDATORY_FT_SCHEME');
         fnd_message.raise_error;
      end if;
      --
      if scheme.Regularisation_Period_Type = 'P' then
         if scheme.Regularisation_Period_Weeks is null then
            fnd_message.set_name('PAY','PAY_74968_MANDATORY_REG_PERIOD');
            fnd_message.raise_error;
         end if;
      end if;
      if scheme.Regularisation_Period_Type is not null then
         if scheme.Regularisation_Threshold is null
         or scheme.Regularisation_Offset is null
         or scheme.Regularisation_Start_Date is null
         or scheme.Regularisation_Formula_ID = -1 then
            fnd_message.set_name('PAY','PAY_74969_MANDATORY_REG_ATTS');
            fnd_message.raise_error;
         end if;
      end if;
   end if;
   --
   if scheme.Overtime_Scheme_Type = 'P' then
      if (scheme.Bonification_Method <> 'P' and
          scheme.Bonification_Method <> 'T')
      or scheme.Overtime_Band_Table is null then
            fnd_message.set_name('PAY','PAY_74970_MANDATORY_PT_SCHEME');
            fnd_message.raise_error;
      end if;
      if (scheme.Majoration_Method is null) then
         /* Set Majoration Method to 'T' for processing purposes */
         scheme.Majoration_Method := 'T';
      end if;
   end if;


/* Load Band information */
   i := 0;
   for b in get_band_values(
              fnd_number.canonical_to_number(scheme.overtime_band_table)) loop
       i := i + 1;
       band(i) := b;
   end loop;
   --
  hr_utility.set_location(l_proc,20);
   return 0;
end;
--
------------------------------------------------------------------------
-- Function GET_SCHEME
--
-- This function reads the PL/SQL scheme table and returns the value of
-- an item in the table, the item returned is specified in a parameter.
------------------------------------------------------------------------
function get_scheme(p_scheme_item varchar2) return varchar2 is
l_proc varchar2(72) := g_package||'.get_scheme';
begin
  hr_utility.set_location(l_proc,10);
if p_scheme_item = 'OVERTIME_PAYROLL_ID' then
return scheme.OVERTIME_PAYROLL_ID;
elsif p_scheme_item = 'OVERTIME_SCHEME_TYPE' then
return scheme.OVERTIME_SCHEME_TYPE;
elsif p_scheme_item = 'THRESHOLD' then
return scheme.THRESHOLD;
elsif p_scheme_item = 'ANNUAL_QUOTA' then
return scheme.ANNUAL_QUOTA;
elsif p_scheme_item = 'WEEKLY_OFFSET_THRESHOLD' then
return scheme.WEEKLY_OFFSET_THRESHOLD;
elsif p_scheme_item = 'BONIFICATION_METHOD' then
return scheme.BONIFICATION_METHOD;
elsif p_scheme_item = 'MAJORATION_METHOD' then
return scheme.MAJORATION_METHOD;
elsif p_scheme_item = 'WEEKLY_COMPENSATION_THRESHOLD' then
return scheme.WEEKLY_COMPENSATION_THRESHOLD;
elsif p_scheme_item = 'UPPER_COMPENSATION_THRESHOLD' then
return scheme.UPPER_COMPENSATION_THRESHOLD;
elsif p_scheme_item = 'LOWER_COMPENSATION_FACTOR' then
return scheme.LOWER_COMPENSATION_FACTOR;
elsif p_scheme_item = 'HIGHER_COMPENSATION_FACTOR' then
return scheme.HIGHER_COMPENSATION_FACTOR;
elsif p_scheme_item = 'OVERTIME_BAND_TABLE' then
return scheme.OVERTIME_BAND_TABLE;
elsif p_scheme_item = 'REGULARISATION_PERIOD_TYPE' then
return scheme.REGULARISATION_PERIOD_TYPE;
elsif p_scheme_item = 'REGULARISATION_PERIOD_WEEKS' then
return scheme.REGULARISATION_PERIOD_WEEKS;
elsif p_scheme_item = 'REGULARISATION_THRESHOLD' then
return scheme.REGULARISATION_THRESHOLD;
elsif p_scheme_item = 'REGULARISATION_OFFSET' then
return scheme.REGULARISATION_OFFSET;
elsif p_scheme_item = 'REGULARISATION_PAYMENT_BASIS' then
return scheme.REGULARISATION_PAYMENT_BASIS;
elsif p_scheme_item = 'REGULARISATION_START_DATE' then
return scheme.REGULARISATION_START_DATE;
elsif p_scheme_item = 'OVERTIME_FORMULA_ID' then
return scheme.OVERTIME_FORMULA_ID;
elsif p_scheme_item = 'REGULARISATION_FORMULA_ID' then
return scheme.REGULARISATION_FORMULA_ID;
else
  return('');
end if;
--
end get_scheme;
--
------------------------------------------------------------------------
-- Function GET_BAND
--
-- This function reads the PL/SQL band table and returns the band label,
-- hours, working_time_percentage and factor for a specified band.
------------------------------------------------------------------------
function get_band(p_band number
                 ,p_label out nocopy varchar2
                 ,p_hours out nocopy number
                 ,p_hours_percentage out nocopy number
                 ,p_factor out nocopy number) return number is
l_proc varchar2(72) := g_package||'.get_band';
begin
  hr_utility.set_location(l_proc,10);
  p_label := band(p_band).Label;
  p_hours := band(p_band).Hours;
  p_hours_percentage := band(p_band).Hours_Percentage;
  p_factor := band(p_band).Factor;
hr_utility.trace('Fetching Band '||to_char(p_band));
hr_utility.trace('Hours_Percentage '||p_hours_percentage);
  return 0;
exception when others then
  return 1;
end;
--
------------------------------------------------------------------------
-- Function CALCULATE_BAND
--
-- This function will determine the number of hours to pay at the prevailing
-- full band rate and reduced band rate (if some hours have already been
-- included in normal pay due to working hours being greater than the
-- overtime threshold).
--
-- It also takes into account whether the compensation is either being paid
-- or taken as time off in lieu. Either the pay and the hourly pay rate
-- (increased according to the band factor) or time accrued and the accrual
-- rate (band factor) is returned by the function.
------------------------------------------------------------------------
function calculate_band
(p_low_value number
,p_band_hours number
,p_overtime_hours number
,p_weekly_reference_hours number
,p_band_factor number
,p_pay_rate number
,p_compensation_method varchar2
,p_high_value out nocopy number
,p_band_full_factor out nocopy number
,p_band_full_pay_rate out nocopy number
,p_band_full_hours out nocopy number
,p_band_full_pay out nocopy number
,p_band_full_accrual out nocopy number
,p_band_reduced_actor out nocopy number
,p_band_reduced_pay_rate out nocopy number
,p_band_reduced_hours out nocopy number
,p_band_reduced_pay out nocopy number
,p_band_reduced_accrual out nocopy number) return number is
--
l_overtime_hours_in_band number;
--
l_high_value number := 0;
l_full_factor number := 0;
l_hourly_rate_ff number := 0;
l_hourly_pay_rate_ff number := 0;
l_hourly_accrual_rate_ff number := 0;
l_hours_ff number := 0;
l_pay_ff number := 0;
l_accrual_ff number := 0;
--
l_reduced_factor number := 0;
l_hourly_rate_rf number := 0;
l_hourly_pay_rate_rf number := 0;
l_hourly_accrual_rate_rf number := 0;
l_hours_rf number := 0;
l_pay_rf number := 0;
l_accrual_rf number := 0;
--
l_proc varchar2(72) := g_package||'.calculate_band';
begin
  hr_utility.set_location(l_proc,10);
--
/* The number of hours is
1. 0 if the weekly hours are below the bands low value

2. or the difference between the weekly hours and the low value if less than the high value

3.  or the difference between the low and high value if weekly hours is greater than the high value
*/
--
l_high_value := p_low_value + p_band_hours;
--
l_overtime_hours_in_band :=
  least(greatest(p_overtime_hours, p_low_value),l_high_value) - p_low_value;
--
/* If weekly reference hours is greater than the overtime threshold then the
implication is that the time worked up to the weekly reference hours is
covered by the salary payment. These hours are therefore only subject to the
difference between the band overtime rate and 100%.

For instance if the weekly reference hours is 37 and a person works 38
hours then 2 of these hours are payable at 10% and 1 hour is payable at 110%. */
--
if p_weekly_reference_hours > p_low_value then
/* Calculate the differential rate */
   l_reduced_factor := p_band_factor - 100;
   l_hourly_pay_rate_rf := p_pay_rate * l_reduced_factor / 100;
   l_hourly_accrual_rate_rf := l_reduced_factor / 100;
end if;
--
/* If weekly reference hours is at or above the upper level for the band then all the overtime hours are payable at a differential value */
--
if p_weekly_reference_hours < l_high_value then
   l_full_factor := p_band_factor;
   l_hourly_pay_rate_ff := p_pay_rate * l_full_factor / 100;
   l_hourly_accrual_rate_ff := l_full_factor / 100;
end if;
--
/* Determine the number of hours overtime payable at a reduced rate */
l_hours_rf := least(l_overtime_hours_in_band,
                    (least(greatest(p_weekly_reference_hours, p_low_value)
                             ,l_high_value) - p_low_value));
--
/* The remaining hours in the band are payable at the full rate */
l_hours_ff := l_overtime_hours_in_band - l_hours_rf;
--
if p_compensation_method = 'P' then
   if l_hours_rf <> 0 then
      l_hourly_rate_rf := l_hourly_pay_rate_rf;
      l_pay_rf := l_hours_rf * l_hourly_rate_rf;
   end if;
--
   if l_hours_ff <> 0 then
      l_hourly_rate_ff := l_hourly_pay_rate_ff;
      l_pay_ff := l_hours_ff * l_hourly_rate_ff;
   end if;
--
else /* COMPENSATION_METHOD = 'T' */
   if l_hours_rf <> 0 then
      l_hourly_rate_rf := l_hourly_accrual_rate_rf;
      l_accrual_rf := l_hours_rf * l_hourly_rate_rf;
   end if;
--
   if l_hours_ff <> 0 then
      l_hourly_rate_ff := l_hourly_accrual_rate_ff;
      l_accrual_ff := l_hours_ff * l_hourly_rate_ff;
   end if;
end if;
--
hr_utility.trace('-------------------------------------');
hr_utility.trace('Low Value = '||to_char(p_low_value));
hr_utility.trace('High Value = '||to_char(l_high_value));
hr_utility.trace('-------------------------------------');
hr_utility.trace('Full Factor = '||to_char(l_full_factor));
hr_utility.trace('Full Pay Rate = '||to_char(l_hourly_rate_ff));
hr_utility.trace('Full Hours = '||to_char(l_hours_ff));
hr_utility.trace('Full Pay = '||to_char(l_pay_ff));
hr_utility.trace('Full Accrual = '||to_char(l_accrual_ff));
hr_utility.trace('-------------------------------------');
hr_utility.trace('Reduced Factor = '||to_char(l_reduced_factor));
hr_utility.trace('Reduced Pay Rate = '||to_char(l_hourly_rate_rf));
hr_utility.trace('Reduced Hours = '||to_char(l_hours_rf));
hr_utility.trace('Reduced Pay = '||to_char(l_pay_rf));
hr_utility.trace('Reduced Accrual = '||to_char(l_accrual_rf));
hr_utility.trace('-------------------------------------');
--
p_high_value := l_high_value;
p_band_full_factor := l_full_factor;
p_band_full_pay_rate := l_hourly_rate_ff;
p_band_full_hours := l_hours_ff;
p_band_full_pay := l_pay_ff;
p_band_full_accrual := l_accrual_ff;
p_band_reduced_actor := l_reduced_factor;
p_band_reduced_pay_rate := l_hourly_rate_rf;
p_band_reduced_hours := l_hours_rf;
p_band_reduced_pay := l_pay_rf;
p_band_reduced_accrual := l_accrual_rf;
--
  hr_utility.set_location(l_proc,10);
return 0;
end calculate_band;
--
------------------------------------------------------------------------
-- Function LAST_REGULARISATION
--
-- This function retrieves the date of the last regularisation if one exists.
------------------------------------------------------------------------
function last_regularisation
(P_ASSIGNMENT_ID number
,P_DATE_EARNED DATE
,P_RANGE_END_DATE date
,P_RANGE_START_DATE date) return date is
--
cursor get_elements(p_orig_ele varchar2,
                    p_retr_ele varchar2) is
select /*+ORDERED index(pet PAY_ELEMENT_TYPES_F_UK2) */
      max(decode(pet.element_name,p_orig_ele,pet.element_type_id)) orig_ele_id,
      max(decode(pet.element_name,p_retr_ele,pet.element_type_id)) retr_ele_id
from   pay_element_types_f pet
where  pet.element_name in (p_orig_ele,p_retr_ele)
and    pet.legislation_code = 'FR'
and    pet.business_group_id is null
and    p_date_earned between pet.effective_start_date
                         and pet.effective_end_date;
--
cursor c_get_regularisation(p_orig_ele_id number,
                            p_retr_ele_id number,
                            p_range_start_chr varchar2,
                            p_range_end_chr varchar2) is
select /*+ordered use_nl(i i2) */ rr.result_value,
       sum(fnd_number.canonical_to_number(rr2.result_value))
from pay_assignment_actions a
,pay_run_results r
,pay_input_values_f i
,pay_run_result_values rr
,pay_input_values_f i2
,pay_run_result_values rr2
where i.element_type_id = r.element_type_id
and   i.name = 'End Date'
and   i.business_group_id is null
and   i.legislation_code = 'FR'
and   p_date_earned
       between i.effective_start_date and i.effective_end_date
and   i2.element_type_id = r.element_type_id
and   i2.name = 'Processing Sequence'
and   i2.business_group_id is null
and   i2.legislation_code = 'FR'
and   p_date_earned
       between i2.effective_start_date and i2.effective_end_date
and   a.assignment_id = p_assignment_id
and   a.assignment_action_id = r.assignment_action_id
and   r.element_type_id in (p_orig_ele_id,p_retr_ele_id)
and   rr.run_result_id = r.run_result_id
and   i.input_value_id = rr.input_value_id
and   rr2.run_result_id = r.run_result_id
and   i2.input_value_id = rr2.input_value_id
and rr.result_value <= p_range_end_chr
and rr.result_value >= p_range_start_chr
and   r.status in ('P','PA')
group by rr.result_value
having sum(fnd_number.canonical_to_number(rr2.result_value)) >0
order by rr.result_value desc;
--
l_last_regularisation varchar2(30);
l_Proc_Seq_sum        number;
l_orig_ele_id number;
l_retr_ele_id number;
--
l_proc varchar2(72) := g_package||'.last_regularisation';
begin
  hr_utility.set_location(l_proc,10);
--
open get_elements('FR_REGULARISATION_WEEK','FR_REGULARISATION_WEEK_RETRO');
fetch get_elements into l_orig_ele_id,l_retr_ele_id;
close get_elements;
open c_get_regularisation(l_orig_ele_id,l_retr_ele_id,
                          fnd_date.date_to_canonical(p_range_start_date),
                          fnd_date.date_to_canonical(p_range_end_date));
fetch c_get_regularisation into l_last_regularisation,l_Proc_Seq_sum;
close c_get_regularisation;
--
return fnd_date.canonical_to_date(l_last_regularisation);
end last_regularisation;
--
------------------------------------------------------------------------
-- Function DETERMINE_REGULARISATION
--
-- This function determines whether regularisation is due in the current
-- week being processed. It will use the type of regularisation and the
-- regularisation start week to determine whether the regularisation is due.
------------------------------------------------------------------------
function determine_regularisation
(P_ASSIGNMENT_ID number
,P_DATE_EARNED DATE
,P_OVERTIME_PAYROLL_ID NUMBER
,P_PERIOD_TYPE VARCHAR2
,P_NUMBER_OF_WEEKS NUMBER
,P_START_DATE DATE
,P_CURRENT_WEEK_END_DATE DATE
,P_PERIOD_START_DATE OUT NOCOPY DATE
,P_PERIOD_END_DATE OUT NOCOPY DATE) return varchar2 is
--
l_start_date date;
l_end_date date;
l_period_start_date date;
l_period_end_date date;
l_number_of_weeks number;
l_proc varchar2(72) := g_package||'.determine_regularisation';
--
cursor c_week_start_date(p_payroll_id number
                      ,p_date date) is
select max(start_date)
from per_time_periods
where payroll_id = p_payroll_id
and   p_date >= start_date;
--
cursor c_week_end_date(p_payroll_id number
                      ,p_date date) is
select max(end_date)
from per_time_periods
where payroll_id = p_payroll_id
and   p_date >= end_date;
--
/* Local function to increment the date either with a full year or
   a multiple of  weeks */
function increment_date(p_date date) return date is
begin
   if p_period_type = 'Y' then
      return(add_months(p_date,12));
   else
      return(p_date + 7*p_number_of_weeks);
   end if;
end;
--
begin
  hr_utility.set_location(l_proc,10);
--
/* If there is a regularisation after the initial one defined on the scheme
   or element entry override - then treat it as the start of the repetitions
*/
l_start_date := last_regularisation(p_assignment_id
                                   ,p_date_earned
                                   ,p_current_week_end_date
                                   ,p_start_date);
if l_start_date is null then
   l_start_date := p_start_date;
else
   l_start_date := l_start_date +1;
end if;
--
--
while l_start_date < p_current_week_end_date loop
--
   open c_week_start_date(p_overtime_payroll_id
                    ,l_start_date);
   fetch c_week_start_date into l_period_start_date;
   if c_week_start_date%notfound then
      close c_week_start_date;
      fnd_message.set_name('PAY','PAY_74961_REG_WEEK_NOT_FOUND');
      fnd_message.raise_error;
   else
      close c_week_start_date;
      l_period_start_date := l_period_start_date;
   end if;

l_end_date := increment_date(l_start_date) - 1;
--
   open c_week_end_date(p_overtime_payroll_id
                       ,l_end_date);
   fetch c_week_end_date into l_period_end_date;
   if c_week_end_date%notfound then
      close c_week_end_date;
      fnd_message.set_name('PAY','PAY_74961_REG_WEEK_NOT_FOUND');
      fnd_message.raise_error;
   else
      close c_week_end_date;
   end if;
--
hr_utility.trace('Regularisation Period = ' || to_char(l_period_start_date,'DD-MON-YYYY') ||' - '||to_char(l_period_end_date,'DD-MON-YYYY'));
--
  if l_period_end_date = p_current_week_end_date then
     l_number_of_weeks := (l_period_end_date - l_period_start_date+1)/7;
--
hr_utility.trace('Regularisation Due --------------');
--
     /* Set output variables */
     p_period_start_date := l_period_start_date;
     p_period_end_date := l_period_end_date;
     --
     return('Y');
  else
      l_start_date := l_end_date + 1;
  end if;
--
end loop;
--
hr_utility.trace('Regularisation Not Found');
return('N');
--
end determine_regularisation;
--
/*
------------------------------------------------------------------------
-- Function OVERTIME_ENTRY_EXISTS
--
-- This is a local function that derives the overtime scheme upper compensation
------------------------------------------------------------------------
function overtime_entry_exists(p_assignment_id number
                              ,p_week_start_date date
                              ,p_week_end_date date) return varchar2 is
--
cursor c_overtime_entry is
select 'Y'
from pay_element_entries_f ee
,    pay_element_links_f el
,    pay_element_types_f et
where ee.assignment_id = p_assignment_id
and   ee.element_link_id = el.element_link_id
and   el.element_type_id = et.element_type_id
and   et.element_name in ('FR_OVERTIME_WEEK','FR_OVERTIME_EXCEPTION_WEEK')
and   exists
   (select null
    from pay_element_entry_values_f eev
    ,    pay_input_values_f iv
    where eev.input_value_id = iv.input_value_id
    and   eev.element_entry_id = ee.element_entry_id
    and   iv.name = 'Start Date'
    and   eev.screen_entry_value =
             fnd_date.date_to_canonical(p_week_start_date)
    )
and   exists
   (select null
    from pay_element_entry_values_f eev
    ,    pay_input_values_f iv
    where eev.input_value_id = iv.input_value_id
    and   eev.element_entry_id = ee.element_entry_id
    and   iv.name = 'End Date'
    and   eev.screen_entry_value =
              fnd_date.date_to_canonical(p_week_end_date)
    );
--
l_entry_exists varchar2(1) := 'N';
--
l_proc varchar2(72) := g_package||'.overtime_entry_exists';
begin
  hr_utility.set_location(l_proc,10);
open c_overtime_entry;
fetch c_overtime_entry into l_entry_exists;
close c_overtime_entry;
--
return l_entry_exists;
end;
*/
--
------------------------------------------------------------------------
-- Function GET_OVERTIME_WEEKS
--
-- This function will be called from the FR_OVERTIME_WEEK elements
-- processing and will determine whether the overtime week corresponding
-- to the WEEK_START and WEEK_END Dates is a valid week in the overtime scheme.
-- If so it returns the Julian value of the WEEK_END_DATE to be used as
-- the processing priority.
------------------------------------------------------------------------
function get_overtime_weeks(p_overtime_payroll_id number
                                ,p_week_start_date date
                                ,p_week_end_date date) return number is
cursor c_weeks is
select 'Y'
from per_time_periods o
where o.payroll_id = p_overtime_payroll_id
and   o.start_date = p_week_start_date
and   o.end_date   = p_week_end_date;
--
l_valid_week varchar2(1) := 'N';
l_process_week number;
l_proc varchar2(72) := g_package||'.get_overtime_weeks';
--
begin
  hr_utility.set_location(l_proc,10);
open c_weeks;
fetch c_weeks into l_valid_week;
close c_weeks;
--
if l_valid_week = 'N' then
   fnd_message.set_name('PAY','PAY_74956_NO_SCHEME_WEEK');
   fnd_message.raise_error;
else
   l_process_week := to_number(to_char(p_week_end_date,'J'));
end if;
--
return l_process_week;
--
end get_overtime_weeks;
--
------------------------------------------------------------------------
-- Function GET_OVERTIME_WEEK_DATES
--
-- This function will be called from the FR_OVERTIME_WEEK1-6 elements
-- processing and will determine the whether the overtime week corresponding
-- to the WEEK_NUMBER parameter, should be processed in the current payroll
-- period. If this is the case then the WEEK START and END dates are returned.
------------------------------------------------------------------------
function get_overtime_week_dates(p_overtime_payroll_id number
                                ,p_payroll_start_date date
                                ,p_week_number number
                                ,p_week_start_date out nocopy date
                                ,p_week_end_date out nocopy date) return number is
cursor c_weeks is
select o.start_date,o.end_date
from per_time_periods o
,    per_time_periods p
where o.prd_information2 = p.time_period_id
and p.start_date = p_payroll_start_date
and o.payroll_id = p_overtime_payroll_id
order by o.start_date;
--
l_weeks number := 0;
l_process_week number := 0;
--
l_proc varchar2(72) := g_package||'.get_overtime_week_dates';
begin
  hr_utility.set_location(l_proc,10);
  for w in c_weeks loop
      l_weeks := l_weeks + 1;
      if l_weeks = p_week_number then
         --
         l_process_week := to_number(to_char(w.end_date,'J'));
         p_week_start_date := w.start_date;
         p_week_end_date := w.end_date;
         exit;
      end if;
         --
  end loop;
--
  return l_process_week;
end get_overtime_week_dates;
--
------------------------------------------------------------------------
-- Function GET_OVERTIME_WEEK_DATES
--
-- This function will be called from the FR_OVERTIME_WEEK1-6 elements
-- processing and will determine the whether the overtime week corresponding
-- to the WEEK_NUMBER parameter, should be processed in the current payroll
-- period. If this is the case then the WEEK START and END dates are returned.
-- overloaded function with extra payroll_id context for performance. Overloaded
-- to avoid having to ship pdt in 11.5.10, although after that previous version
-- becomes obsolete
------------------------------------------------------------------------
function get_overtime_week_dates(p_payroll_id number
                                ,p_overtime_payroll_id number
                                ,p_payroll_start_date date
                                ,p_week_number number
                                ,p_week_start_date out nocopy date
                                ,p_week_end_date out nocopy date) return number is
cursor c_weeks is
select o.start_date,o.end_date
from per_time_periods o
,    per_time_periods p
where o.prd_information2 = p.time_period_id
and p.payroll_id = p_payroll_id
and p.start_date = p_payroll_start_date
and o.payroll_id = p_overtime_payroll_id
order by o.start_date;
--
l_weeks number := 0;
l_process_week number := 0;
--
l_proc varchar2(72) := g_package||'.get_overtime_week_dates';
begin
  hr_utility.set_location(l_proc,10);
  for w in c_weeks loop
      l_weeks := l_weeks + 1;
      if l_weeks = p_week_number then
         --
         l_process_week := to_number(to_char(w.end_date,'J'));
         p_week_start_date := w.start_date;
         p_week_end_date := w.end_date;
         exit;
      end if;
         --
  end loop;
--
  return l_process_week;
end get_overtime_week_dates;
--
------------------------------------------------------------------------
-- Function GET_WEEK_DETAILS
--
-- This function will retrieve the number of hours overtime for a given week.
-- This information will be acquired by executing a user defined formula
-- named FR_USER_OVERTIME_WEEKS, i.e. to retrieve the OVERTIME_HOURS,
-- QUOTA_HOURS and COMPENSATION_HOURS.
------------------------------------------------------------------------
function get_week_details(p_assignment_id number
                         ,p_effective_date date
                         ,p_business_group_id number
                         ,p_assignment_action_id number
                         ,p_payroll_action_id number
                         ,p_week_start_date date
                         ,p_week_end_date date
                         ,p_formula_id number
                         ,p_overtime_hours out nocopy number
                         ,p_quota_hours out nocopy number
                         ,p_compensation_hours out nocopy number) return number is
--
l_proc varchar2(72) := g_package||'.get_week_details';
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;
l_formula_id          number;
l_start_date          date;
--
cursor csr_get_formula is
    select ff.formula_id,
         ff.effective_start_date
    from   ff_formulas_f ff
    where  ff.formula_id = p_formula_id
    and    p_effective_date
       between ff.effective_start_date and ff.effective_end_date
    and    ff.business_group_id = p_business_group_id;

begin
  hr_utility.set_location(l_proc,10);
--
open  csr_get_formula;
  fetch csr_get_formula into l_formula_id, l_start_date;
  If csr_get_formula%found then
  hr_utility.set_location(l_proc,20);
     -- Initialise the formula
     ff_exec.init_formula (l_formula_id,
                           l_start_date,
                           l_inputs,
                           l_outputs);
     --
     -- populate input parameters
    if (l_inputs.first is not null) and (l_inputs.last is not null) then
       for i in l_inputs.first..l_inputs.last loop
          if l_inputs(i).name = 'ASSIGNMENT_ID' then
             l_inputs(i).value := p_assignment_id;
          elsif l_inputs(i).name = 'DATE_EARNED' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
          elsif l_inputs(i).name = 'BUSINESS_GROUP_ID' then
             l_inputs(i).value := p_business_group_id;
          elsif l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
             l_inputs(i).value := p_assignment_action_id;
          elsif l_inputs(i).name = 'PAYROLL_ACTION_ID' then
             l_inputs(i).value := p_payroll_action_id;
          elsif l_inputs(i).name = 'WEEK_START_DATE' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_week_start_date);
          elsif l_inputs(i).name = 'WEEK_END_DATE' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_week_end_date);
          end if;
       end loop;
    end if;
     --
     hr_utility.set_location(' Prior to execute the formula',8);
  hr_utility.set_location(l_proc,30);
     ff_exec.run_formula (l_inputs
                         ,l_outputs);
     --
  hr_utility.set_location(l_proc,40);
     hr_utility.set_location(' End run formula',9);
     --
     for l_out_cnt in l_outputs.first..l_outputs.last loop
         if l_outputs(l_out_cnt).name = 'OVERTIME_HOURS' then
            p_overtime_hours := l_outputs(l_out_cnt).value;
         elsif l_outputs(l_out_cnt).name = 'QUOTA_HOURS' then
            p_quota_hours := l_outputs(l_out_cnt).value;
         elsif l_outputs(l_out_cnt).name = 'COMPENSATION_HOURS' then
            p_compensation_hours := l_outputs(l_out_cnt).value;
         end if;
     end loop;
     --
     close csr_get_formula;
  else
     close csr_get_formula;
  end if;
  return 0;
end get_week_details;
--
------------------------------------------------------------------------
-- Function REGULARISATION
--
-- This function will call a user formula named in the overtime scheme
-- (passed in as a parameter) to perform the regularisation process.
------------------------------------------------------------------------
function regularisation(p_assignment_id number
                       ,p_effective_date date
                       ,p_business_group_id number
                       ,p_assignment_action_id number
                       ,p_payroll_action_id number
                       ,p_reg_period_start_date date
                       ,p_reg_period_end_date date
                       ,p_formula_id number
                       ,p_b1_pay_ff out nocopy number
                       ,p_b1_hours_ff out nocopy number
                       ,p_b1_hourly_rate_ff out nocopy number
                       ,p_b1_full_factor out nocopy number
                       ,p_b1_accrual_ff out nocopy number
                       ,p_b1_label_ff out nocopy varchar2
                       ,p_b1_pay_rf out nocopy number
                       ,p_b1_hours_rf out nocopy number
                       ,p_b1_hourly_rate_rf out nocopy number
                       ,p_b1_reduced_factor out nocopy number
                       ,p_b1_accrual_rf out nocopy number
                       ,p_b1_label_rf out nocopy varchar2
                       ,p_b2_pay_ff out nocopy number
                       ,p_b2_hours_ff out nocopy number
                       ,p_b2_hourly_rate_ff out nocopy number
                       ,p_b2_full_factor out nocopy number
                       ,p_b2_accrual_ff out nocopy number
                       ,p_b2_label_ff out nocopy varchar2
                       ,p_b2_pay_rf out nocopy number
                       ,p_b2_hours_rf out nocopy number
                       ,p_b2_hourly_rate_rf out nocopy number
                       ,p_b2_reduced_factor out nocopy number
                       ,p_b2_accrual_rf out nocopy number
                       ,p_b2_label_rf out nocopy varchar2
                       ,p_b3_pay_ff out nocopy number
                       ,p_b3_hours_ff out nocopy number
                       ,p_b3_hourly_rate_ff out nocopy number
                       ,p_b3_full_factor out nocopy number
                       ,p_b3_accrual_ff out nocopy number
                       ,p_b3_label_ff out nocopy varchar2
                       ,p_b3_pay_rf out nocopy number
                       ,p_b3_hours_rf out nocopy number
                       ,p_b3_hourly_rate_rf out nocopy number
                       ,p_b3_reduced_factor out nocopy number
                       ,p_b3_accrual_rf out nocopy number
                       ,p_b3_label_rf out nocopy varchar2
                       ,p_b4_pay_ff out nocopy number
                       ,p_b4_hours_ff out nocopy number
                       ,p_b4_hourly_rate_ff out nocopy number
                       ,p_b4_full_factor out nocopy number
                       ,p_b4_accrual_ff out nocopy number
                       ,p_b4_label_ff out nocopy varchar2
                       ,p_b4_pay_rf out nocopy number
                       ,p_b4_hours_rf out nocopy number
                       ,p_b4_hourly_rate_rf out nocopy number
                       ,p_b4_reduced_factor out nocopy number
                       ,p_b4_accrual_rf out nocopy number
                       ,p_b4_label_rf out nocopy varchar2
                       ,p_b5_pay_ff out nocopy number
                       ,p_b5_hours_ff out nocopy number
                       ,p_b5_hourly_rate_ff out nocopy number
                       ,p_b5_full_factor out nocopy number
                       ,p_b5_accrual_ff out nocopy number
                       ,p_b5_label_ff out nocopy varchar2
                       ,p_b5_pay_rf out nocopy number
                       ,p_b5_hours_rf out nocopy number
                       ,p_b5_hourly_rate_rf out nocopy number
                       ,p_b5_reduced_factor out nocopy number
                       ,p_b5_accrual_rf out nocopy number
                       ,p_b5_label_rf out nocopy varchar2
                       ,p_b6_pay_ff out nocopy number
                       ,p_b6_hours_ff out nocopy number
                       ,p_b6_hourly_rate_ff out nocopy number
                       ,p_b6_full_factor out nocopy number
                       ,p_b6_accrual_ff out nocopy number
                       ,p_b6_label_ff out nocopy varchar2
                       ,p_b6_pay_rf out nocopy number
                       ,p_b6_hours_rf out nocopy number
                       ,p_b6_hourly_rate_rf out nocopy number
                       ,p_b6_reduced_factor out nocopy number
                       ,p_b6_accrual_rf out nocopy number
                       ,p_b6_label_rf out nocopy varchar2
) return number is
--
l_proc varchar2(72) := g_package||'.regularisation';
l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;
l_formula_id          number;
l_start_date          date;
--
cursor csr_get_formula is
    select ff.formula_id,
         ff.effective_start_date
    from   ff_formulas_f ff
    where  ff.formula_id = p_formula_id
    and    p_effective_date
       between ff.effective_start_date and ff.effective_end_date;

begin
  hr_utility.set_location(l_proc,10);
--
open  csr_get_formula;
  fetch csr_get_formula into l_formula_id, l_start_date;
  If csr_get_formula%found then
  hr_utility.set_location(l_proc,20);
     -- Initialise the formula
     ff_exec.init_formula (l_formula_id,
                           l_start_date,
                           l_inputs,
                           l_outputs);
     --
     -- populate input parameters
    if (l_inputs.first is not null) and (l_inputs.last is not null) then
       for i in l_inputs.first..l_inputs.last loop
          if l_inputs(i).name = 'ASSIGNMENT_ID' then
             l_inputs(i).value := p_assignment_id;
          elsif l_inputs(i).name = 'DATE_EARNED' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_effective_date);
          elsif l_inputs(i).name = 'BUSINESS_GROUP_ID' then
             l_inputs(i).value := p_business_group_id;
          elsif l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' then
             l_inputs(i).value := p_assignment_action_id;
          elsif l_inputs(i).name = 'PAYROLL_ACTION_ID' then
             l_inputs(i).value := p_payroll_action_id;
          elsif l_inputs(i).name = 'REG_PERIOD_START_DATE' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_reg_period_start_date);
          elsif l_inputs(i).name = 'REG_PERIOD_END_DATE' then
             l_inputs(i).value := fnd_date.date_to_canonical(p_reg_period_end_date);
          end if;
       end loop;
    end if;
     --
     hr_utility.set_location(' Prior to execute the formula',8);
  hr_utility.set_location(l_proc,30);
     ff_exec.run_formula (l_inputs
                         ,l_outputs);
     --
  hr_utility.set_location(l_proc,40);
     hr_utility.set_location(' End run formula',9);
     --
     for l_out_cnt in l_outputs.first..l_outputs.last loop

if l_outputs(l_out_cnt).name = 'B1_PAY_FF'
then	p_b1_pay_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_BASE_FF'
then	p_b1_hours_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_HOURLY_RATE_FF'
then	p_b1_hourly_rate_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_FULL_FACTOR'
then	p_b1_full_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_ACCRUAL_FF'
then	p_b1_accrual_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_PAY_RF'
then	p_b1_pay_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_BASE_RF'
then	p_b1_hours_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_HOURLY_RATE_RF'
then	p_b1_hourly_rate_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_REDUCED_FACTOR'
then	p_b1_reduced_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_ACCRUAL_RF'
then	p_b1_accrual_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_PAY_FF'
then	p_b2_pay_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_BASE_FF'
then	p_b2_hours_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_HOURLY_RATE_FF'
then	p_b2_hourly_rate_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_FULL_FACTOR'
then	p_b2_full_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_ACCRUAL_FF'
then	p_b2_accrual_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_PAY_RF'
then	p_b2_pay_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_BASE_RF'
then	p_b2_hours_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_HOURLY_RATE_RF'
then	p_b2_hourly_rate_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_REDUCED_FACTOR'
then	p_b2_reduced_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_ACCRUAL_RF'
then	p_b2_accrual_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_PAY_FF'
then	p_b3_pay_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_BASE_FF'
then	p_b3_hours_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_HOURLY_RATE_FF'
then	p_b3_hourly_rate_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_FULL_FACTOR'
then	p_b3_full_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_ACCRUAL_FF'
then	p_b3_accrual_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_PAY_RF'
then	p_b3_pay_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_BASE_RF'
then	p_b3_hours_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_HOURLY_RATE_RF'
then	p_b3_hourly_rate_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_REDUCED_FACTOR'
then	p_b3_reduced_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_ACCRUAL_RF'
then	p_b3_accrual_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_PAY_FF'
then	p_b4_pay_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_BASE_FF'
then	p_b4_hours_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_HOURLY_RATE_FF'
then	p_b4_hourly_rate_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_FULL_FACTOR'
then	p_b4_full_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_ACCRUAL_FF'
then	p_b4_accrual_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_PAY_RF'
then	p_b4_pay_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_BASE_RF'
then	p_b4_hours_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_HOURLY_RATE_RF'
then	p_b4_hourly_rate_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_REDUCED_FACTOR'
then	p_b4_reduced_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_ACCRUAL_RF'
then	p_b4_accrual_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_PAY_FF'
then	p_b5_pay_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_BASE_FF'
then	p_b5_hours_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_HOURLY_RATE_FF'
then	p_b5_hourly_rate_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_FULL_FACTOR'
then	p_b5_full_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_ACCRUAL_FF'
then	p_b5_accrual_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_PAY_RF'
then	p_b5_pay_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_BASE_RF'
then	p_b5_hours_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_HOURLY_RATE_RF'
then	p_b5_hourly_rate_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_REDUCED_FACTOR'
then	p_b5_reduced_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_ACCRUAL_RF'
then	p_b5_accrual_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_PAY_FF'
then	p_b6_pay_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_BASE_FF'
then	p_b6_hours_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_HOURLY_RATE_FF'
then	p_b6_hourly_rate_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_FULL_FACTOR'
then	p_b6_full_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_ACCRUAL_FF'
then	p_b6_accrual_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_PAY_RF'
then	p_b6_pay_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_BASE_RF'
then	p_b6_hours_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_HOURLY_RATE_RF'
then	p_b6_hourly_rate_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_REDUCED_FACTOR'
then	p_b6_reduced_factor := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_ACCRUAL_RF'
then	p_b6_accrual_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_LABEL_FF'
then	p_b1_label_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_LABEL_FF'
then	p_b2_label_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_LABEL_FF'
then	p_b3_label_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_LABEL_FF'
then	p_b4_label_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_LABEL_FF'
then	p_b5_label_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_LABEL_FF'
then	p_b6_label_ff := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B1_LABEL_RF'
then	p_b1_label_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B2_LABEL_RF'
then	p_b2_label_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B3_LABEL_RF'
then	p_b3_label_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B4_LABEL_RF'
then	p_b4_label_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B5_LABEL_RF'
then	p_b5_label_rf := l_outputs(l_out_cnt).value;
elsif l_outputs(l_out_cnt).name = 'B6_LABEL_RF'
then	p_b6_label_rf := l_outputs(l_out_cnt).value;
end if;
     end loop;
     --
     hr_utility.set_location(' After Loop',1);
     close csr_get_formula;
  else
     close csr_get_formula;
  end if;
     hr_utility.set_location(' Leaving Regularisation',10);
  return 0;
--
end regularisation;
--
------------------------------------------------------------------------
-- Function CHECK_EXISTING_OVERTIME_WEEK
--
-- This function will be called from the FR_OVERTIME_WEEK_PROCESS formula
-- and will check whether there are any run results of type
-- FR_OVERTIME_WEEK_PROCESS the same START and END Dates as those passed
-- into the function. If such a record is found then the a warning is issued.
------------------------------------------------------------------------
function check_existing_overtime_week
(p_assignment_id number
,p_element_type_id number
,p_date_earned date
,p_week_end_date date) return varchar2 is
--
cursor get_elements(p_orig_ele varchar2,
                    p_retr_ele varchar2) is
select /*+ORDERED index(pet PAY_ELEMENT_TYPES_F_UK2) */
      max(decode(pet.element_name,p_orig_ele,pet.element_type_id)) orig_ele_id,
      max(decode(pet.element_name,p_retr_ele,pet.element_type_id)) retr_ele_id
from   pay_element_types_f pet
where  pet.element_name in (p_orig_ele,p_retr_ele)
and    pet.legislation_code = 'FR'
and    pet.business_group_id is null
and    p_date_earned between pet.effective_start_date
                         and pet.effective_end_date;
--
cursor get_existing_week(p_orig_ele_id number,
                         p_retr_ele_id number,
                         p_week_end in varchar2) is
select /*+ordered use_nl(i i2) */
       decode(sum(rr2.result_value),null,'N',0,'N','Y')
from pay_assignment_actions a
,pay_run_results r
,pay_input_values_f i
,pay_run_result_values rr
,pay_input_values_f i2
,pay_run_result_values rr2
where i.element_type_id = r.element_type_id
and   i.name = 'End Date'
and   i.business_group_id is null
and   i.legislation_code = 'FR'
and   p_date_earned
       between i.effective_start_date and i.effective_end_date
and   i2.element_type_id = r.element_type_id
and   i2.name = 'Processing Sequence'
and   i2.business_group_id is null
and   i2.legislation_code = 'FR'
and   p_date_earned
       between i2.effective_start_date and i2.effective_end_date
and   a.assignment_id = p_assignment_id
and   a.assignment_action_id = r.assignment_action_id
and   r.element_type_id in (p_orig_ele_id,p_retr_ele_id)
and   rr.run_result_id = r.run_result_id
and   i.input_value_id = rr.input_value_id
and   rr2.run_result_id = r.run_result_id
and   i2.input_value_id = rr2.input_value_id
and   rr.result_value = p_week_end
and   r.status in ('P','PA');
--
l_exists varchar2(1) := 'N';
l_orig_ele_id number;
l_retr_ele_id number;
--
l_proc varchar2(72) := g_package||'.check_existing_overtime_week';
begin
  hr_utility.set_location(l_proc,10);
--
open get_elements('FR_OVERTIME_WEEK_PROCESS','FR_OVERTIME_WEEK_PROCESS_RETRO');
fetch get_elements into l_orig_ele_id,l_retr_ele_id;
close get_elements;
open get_existing_week(l_orig_ele_id,l_retr_ele_id,
                       fnd_date.date_to_canonical(p_week_end_date));
fetch get_existing_week into l_exists;
close get_existing_week;
--
return l_exists;
end check_existing_overtime_week;
--
------------------------------------------------------------------------
-- Function GET_PERIOD_BALANCE
--
-- This function will sum the run results of a specified element and
-- input value of a given period of time specified by input parameters.
-- In order that this can be done the element in question must have at
-- least one date input value in addition to the input value to be summed.
------------------------------------------------------------------------
function get_period_balance
(p_assignment_id number
,p_date_earned date
,p_business_group_id number
,p_element varchar2
,p_start_input varchar2
,p_start_date date
,p_end_input varchar2
,p_end_date date
,p_value_input varchar2) return number is
--
cursor get_element is
select /*+ORDERED index(pet PAY_ELEMENT_TYPES_F_UK2) */ pet.element_type_id,
       max(decode(piv.name,p_value_input,piv.input_value_id)) value_iv,
       max(decode(piv.name,p_start_input,piv.input_value_id)) start_iv,
       max(decode(piv.name,p_end_input,  piv.input_value_id)) end_iv
from   pay_element_types_f pet,
       pay_input_values_f  piv
where  pet.element_name = p_element
and   (pet.legislation_code = 'FR' or
       pet.business_group_id = p_business_group_id)
and    p_date_earned between pet.effective_start_date
                         and pet.effective_end_date
and    piv.element_type_id = pet.element_type_id
and    p_date_earned between piv.effective_start_date
                         and piv.effective_end_date
and    piv.name in (p_value_input,p_start_input,p_end_input)
group  by pet.element_type_id;
--
cursor get_balance(p_element_type_id number,
                   p_value_iv number, p_start_iv number,
                   p_end_iv number, p_start_date_chr varchar2,
                   p_end_date_chr varchar2) is
select /*+ORDERED */
sum(to_number(rr.result_value))
from pay_assignment_actions a
,    pay_run_results r
,    pay_run_result_values rrsd
,    pay_run_result_values rred
,    pay_run_result_values rr
where a.assignment_id = p_assignment_id
and   a.assignment_action_id = r.assignment_action_id
and   r.element_type_id = p_element_type_id
and   rr.run_result_id = r.run_result_id
and   rr.input_value_id = p_value_iv
and   rrsd.run_result_id = r.run_result_id
and   rrsd.input_value_id = p_start_iv
and   rred.run_result_id = r.run_result_id
and   rred.input_value_id = p_end_iv
and   rred.result_value <= p_end_date_chr
and   rrsd.result_value >= p_start_date_chr
and   r.status in ('P','PA');
--
l_ele     get_element%ROWTYPE;
l_balance number;
--
l_proc varchar2(72) := g_package||'.get_period_balance';
begin
hr_utility.set_location(l_proc,10);
--
open get_element;
fetch get_element into l_ele;
if get_element%FOUND then
  open get_balance(l_ele.element_type_id,l_ele.value_iv,
                   l_ele.start_iv, l_ele.end_iv,
                   fnd_date.date_to_canonical(p_start_date),
                   fnd_date.date_to_canonical(p_end_date));
  fetch get_balance into l_balance;
  close get_balance;
end if;
close get_element;
--
if l_balance is null then
   l_balance := 0;
end if;
--
return l_balance;
end get_period_balance;
--
--
------------------------------------------------------------------------
-- Function GET_NORMAL_WEEK_HOURS
--
-- This function will retrieve the normal working hours as of the overtime
-- week end date and convert them into a weekly frequency
------------------------------------------------------------------------
function get_normal_week_hours
(p_business_group_id number
,p_assignment_id number
,p_effective_date date) return number is
--
cursor get_hours is
select normal_hours,frequency
from per_all_assignments_f
where assignment_id = p_assignment_id
and   p_effective_date
   between effective_start_date and effective_end_date;
--
l_normal_hours number;
l_frequency varchar2(30);
l_hours number;
--
begin
hr_utility.trace('Business Group = '||to_char(p_business_group_id));
hr_utility.trace('Assignment ID = '||to_char(p_assignment_id));
hr_utility.trace('Effective Date = '||to_char(p_effective_date,'YYYYMMDD'));
  open get_hours;
  fetch get_hours into l_normal_hours,l_frequency;
  if get_hours%notfound then
     close get_hours;
     fnd_message.set_name('PAY','PAY_74980_MISSING_HOURS');
     fnd_message.raise_error;
  end if;
  close get_hours;
  --
  hr_utility.trace('Found Assignment');
  if l_normal_hours is null or l_frequency is null then
     fnd_message.set_name('PAY','PAY_74980_MISSING_HOURS');
     fnd_message.raise_error;
  end if;
  --
  l_hours := pay_fr_general.convert_hours(p_effective_date
                                         ,p_business_group_id
                                         ,p_assignment_id
                                         ,l_normal_hours
                                         ,l_frequency
                                         ,'W');
--
  return l_hours;
--
end get_normal_week_hours;
--
end pay_fr_overtime;

/
