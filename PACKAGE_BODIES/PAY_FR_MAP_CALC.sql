--------------------------------------------------------
--  DDL for Package Body PAY_FR_MAP_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_MAP_CALC" AS
/* $Header: pyfrmapp.pkb 120.1 2005/06/28 05:30:22 sbairagi noship $ */

-----------------------------------------------------------------------
-- Date               Author      Comments
-- 19-12-02           asnell      Initial version of package with reqd program
--                                for Absence report and IJSS calc
-- 06-01-03           vsjain      Additions for Maternity Architecture
-- 16-01-03           vsjain      Changes in procedures after Design Review
-- 20-01-03           vsjain      Changes for map deduction procedure
-- 22-01-03           asnell      added details of calc_map/calc_map_ijss
-- 06-02-03           vsjain      Check valid parent absence
-- 28-06-05           sbairagi    GSCC Error ...to_date is removed line 348 . version 115.23
-----------------------------------------------------------------------
-- PACKAGE GLOBALS
--
 cs_MARGIN           CONSTANT NUMBER := 1;
 blank_map_arch      t_map_arch;
 blank_map_calc      t_map_calc;
 g_ctl               t_ctl;
 blank_ctl           t_ctl;
 g_ijss_net_rate     number;

 g_package  varchar2(33) := '  PAY_FR_MAP_CALC.';
--

--
-- PUBLIC FUNCTIONS
---------------------------------------------------------------------------------
PROCEDURE Calculate_Maternity_Deduction is

l_inputs                ff_exec.inputs_t;
l_outputs               ff_exec.outputs_t;

begin

  hr_utility.set_location('Deduction',10);

   IF g_map_arch.deduct_formula is null then

         hr_utility.set_message(801, 'PY_75027_SICK_DEDUCT_FF_NULL');
         hr_utility.raise_error;

   END IF;

   /* set context value before calling fast formula */

   pay_balance_pkg.set_context('ASSIGNMENT_ID'
                                   , g_map_arch.assignment_id);
   pay_balance_pkg.set_context('ASSIGNMENT_ACTION_ID'
                                   , g_map_arch.assignment_action_id);
   pay_balance_pkg.set_context('DATE_EARNED'
                     , fnd_date.date_to_canonical(g_map_arch.date_earned));
   pay_balance_pkg.set_context('BUSINESS_GROUP_ID'
                                   , g_map_arch.business_group_id);
   pay_balance_pkg.set_context('PAYROLL_ID'
                                   , g_map_arch.payroll_id);
   pay_balance_pkg.set_context('ELEMENT_ENTRY_ID'
                                   , g_map_arch.element_entry_id);

   /* Get input paramaters for fast formula */

   ff_exec.init_formula(g_map_arch.deduct_formula
                      , g_map_arch.date_earned
                      , l_inputs
                      , l_outputs);

  hr_utility.set_location('Deduct',30);

   For i in 1..l_inputs.count Loop
      IF    l_inputs(i).name = 'DEDUCTION_START_DATE' THEN
            l_inputs(i).value := fnd_date.date_to_canonical(g_map_calc.start_date);
      ELSIF l_inputs(i).name = 'DEDUCTION_END_DATE' THEN
            l_inputs(i).value:= fnd_date.date_to_canonical(g_map_calc.end_date);
      ELSIF l_inputs(i).name = 'ASG_ACTION_START_DATE' THEN
            l_inputs(i).value:= fnd_date.date_to_canonical(g_map_arch.action_start_date);
      ELSIF l_inputs(i).name = 'ASG_ACTION_END_DATE' THEN
            l_inputs(i).value:= fnd_date.date_to_canonical(g_map_arch.action_end_date);
      ELSIF l_inputs(i).name = 'REFERENCE_SALARY' THEN
            l_inputs(i).value:= g_map_arch.ded_ref_salary;
      ELSIF l_inputs(i).name = 'ASSIGNMENT_ID' THEN
            l_inputs(i).value:= g_map_arch.assignment_id;
      ELSIF l_inputs(i).name = 'DATE_EARNED' THEN
            l_inputs(i).value:= fnd_date.date_to_canonical(g_map_arch.date_earned);
      ELSIF l_inputs(i).name = 'ASSIGNMENT_ACTION_ID' THEN
            l_inputs(i).value:= g_map_arch.assignment_action_id;
      ELSIF l_inputs(i).name = 'BUSINESS_GROUP_ID' THEN
            l_inputs(i).value:= g_map_arch.business_group_id;
      ELSIF l_inputs(i).name = 'PAYROLL_ID' THEN
            l_inputs(i).value:= g_map_arch.payroll_id;
      ELSIF l_inputs(i).name = 'ELEMENT_ENTRY_ID' THEN
            l_inputs(i).value:= g_map_arch.element_entry_id;
      END IF;
   END Loop;

  hr_utility.set_location('Deduction',50);

      /* define output values for fast formula */

        l_outputs(1).name := 'L_SICKNESS_DEDUCTION';
        l_outputs(2).name :=  'L_RATE_NUMBER_OF_DAYS'; --NUMBER_OF_DAYS';
        l_outputs(3).name := 'L_DAILY_RATE_D'; --'DAILY_RATE';

        /* run formula and get outputs */

        per_formula_functions.run_formula
        (p_formula_id       => g_map_arch.deduct_formula
        ,p_calculation_date => g_map_arch.date_earned
        ,p_inputs           => l_inputs
        ,p_outputs          => l_outputs);

        g_map_calc.deduction      := l_outputs(1).value;
        g_map_calc.deduction_rate := l_outputs(2).value;
        g_map_calc.deduction_base := l_outputs(3).value;

    IF g_map_calc.deduction_base = -1 then
       hr_utility.set_message (801, 'PY_75065_DEDUCT_WORK_PAT_NULL');
        hr_utility.raise_error;
   END IF;

  hr_utility.set_location('Deduction',100);

end Calculate_Maternity_Deduction;

-----------------------------------------------------------------------
-- calculate the number of dependent children the emplouee has
-- based on FR Public Sector code in HREMEA.pld which uses
-- shared types to classify lookups of type contact as
-- dependent children
FUNCTION COUNT_CHILDREN(
P_person_id IN Number,
P_effective_date IN Date) return NUMBER IS

l_no_dep_child number;

    CURSOR c_no_dep_Child
       IS
    SELECT count(*)
     FROM  per_contact_relationships_v2 pcr
     WHERE pcr.person_id = p_person_id
        AND   dependent_flag = 'Y'
        AND  p_effective_date
          BETWEEN
              NVL(pcr.date_start, p_effective_date)
          AND NVL(pcr.date_end,p_effective_date)
        AND EXISTS
               ( SELECT pst.INFORMATION3 from per_shared_types pst
                  WHERE pcr.contact_type = pst.system_type_cd
                    AND pst.lookup_type = 'CONTACT'
                    AND pst.INFORMATION3 = 'Y'
                    AND ( pst.business_group_id = pcr.business_group_id
                     OR   pst.business_group_id  IS NULL)
              );
    BEGIN

      OPEN c_no_dep_Child;
      fetch c_no_dep_Child into l_no_dep_Child;
      if c_no_dep_Child%NOTFOUND then
         l_no_dep_child := 0;
      end if;
      close c_no_dep_Child;

      RETURN  l_no_dep_child;

END COUNT_CHILDREN;

---------------------------------------------------------------------------------

-- calculates maternity IJSS
PROCEDURE CALC_MAP_IJSS(
p_assignment_id         IN  Number,
p_start_date            IN  Date,
p_end_date              IN  Date
) is

Cursor c_prev_postnatal_abs(p_end_date date,
                            p_confinement_date date,
                            p_parent_absence_id number,
                            p_person_id  number) is
select sum(date_end - date_start +1 ) duration
from per_absence_attendances
where person_id = p_person_id
and   abs_information_category = 'FR_M'
and   date_end < p_end_date
and   date_end > p_confinement_date
and   abs_information4 is null
and   abs_information1 = fnd_number.number_to_canonical(p_parent_absence_id);

-- 1) for anti natal maternity no check is done on duration as the eligibility for
--    IJSS lasts until the birth.
-- 2) for post natal leave the duration is fetched from user_table FR_MAP_DURATION
--    determine the criteria key from the type of absence, the number of births and
--    the number of dependent children.
-- 3) calculate the duration of the absence from the absence confinement data up to
--    the p_end_date.  If band is exausted set the p_ijjs_end_date to the date is
--    exausts on. Else set p_ijjs_end_date to p_end_date
-- 4) set p_absence_duration to be the days between p_ijjs_start and end.
-- 5) fetch reference salary over 3 month prior to maternity
-- 6) derive the daily reference salary from 5 above and cap on the net SS_CEILING
-- 7) multiple the rate by number of days
--
l_count_dependent_children number;
l_start_ijss date;
l_end_ijss date;
l_ijss_rate number;
l_ss_ceiling_rate number;
l_criteria varchar2(40);
l_ref_date date;
l_ref_start_date date;
l_ref_end_date date;
l_ref_sal number;
l_prev_postnatal_duration  number := 0;
l_postnatal_duration       number := 0;
l_postnatal_duration_max   number := 0;

begin

  hr_utility.set_location('IJSS',10);

l_count_dependent_children := count_children(
				G_MAP_CALC.person_id,
				G_MAP_CALC.start_date);

-- first set the IJSS start and end dates to the dates of the absence
-- being processed.  Thse dates will subsequently be amended if max
-- duration for IJSS exceeded
   g_map_calc.IJSS_GROSS_START_DATE := p_start_date;
   g_map_calc.IJSS_GROSS_END_DATE := p_end_date;

-- read the maximum duration from the user table dependent on no of births
-- and no of dependent children

If G_MAP_CALC.absence_category = 'FR_M' and G_MAP_CALC.births > 2 then
      l_criteria := 'Maternity more than 2 births';
elsif G_MAP_CALC.absence_category = 'FR_M' and G_MAP_CALC.births = 2 then
      l_criteria := 'Maternity Twins';
elsif G_MAP_CALC.absence_category = 'FR_M' and l_count_dependent_children > 1 then
      l_criteria := 'Maternity at least 2 dependent children';
elsif G_MAP_CALC.absence_category = 'FR_M'  then
      l_criteria := 'Maternity less than 2 dependent children';
elsif G_MAP_CALC.absence_category = 'FR_FR_ADOPTION' and G_MAP_CALC.births > 1 then
      l_criteria := 'Adoption multiple births';
elsif G_MAP_CALC.absence_category = 'FR_FR_ADOPTION' and l_count_dependent_children > 1 then
      l_criteria := 'Adoption at least 2 dependent children';
elsif G_MAP_CALC.absence_category = 'FR_FR_ADOPTION' then
      l_criteria := 'Adoption less than 2 dependent children';
elsif G_MAP_CALC.absence_category = 'FR_FR_PATERNITY' and  G_MAP_CALC.births > 1 then
      l_criteria := 'Paternity multiple births';
else  l_criteria := 'Paternity';
      end if;

-- if the absence is post natal check against max IJSS duration

  hr_utility.set_location('IJSS'|| l_criteria,30);

BEGIN

   l_postnatal_duration_max := hruserdt.get_table_value(
      					G_MAP_ARCH.business_group_id,
   					'FR_MAP_DURATION',
   					'Post-Natal',
   					l_criteria,
   					p_end_date);
EXCEPTION
   WHEN OTHERS THEN
       l_postnatal_duration_max := 0;

END;

 hr_utility.set_location('IJSS'|| l_postnatal_duration_max,31);

 IF G_MAP_CALC.absence_category = 'FR_M' then

    if p_end_date >= G_MAP_CALC.birth_date then -- { post natal

      -- Main Maternity

       l_postnatal_duration := nvl((least(g_map_arch.action_end_date,g_map_calc.parent_absence_end_date) - g_map_calc.birth_date+ 1),0);

       if g_map_calc.parent_absence_id <> g_map_calc.absence_id then

          l_postnatal_duration := nvl(l_postnatal_duration,0) + nvl(g_map_calc.end_date - g_map_calc.absence_start_date + 1,0);

          -- Post Natal Maternity
          open  c_prev_postnatal_abs(g_map_calc.start_date,
                                  g_map_calc.birth_date,
                                  g_map_calc.parent_absence_id,
                                  g_map_calc.person_id);
          fetch c_prev_postnatal_abs into l_prev_postnatal_duration;
          close c_prev_postnatal_abs;

          l_postnatal_duration := l_postnatal_duration + nvl(l_prev_postnatal_duration,0);

       end if;

    end if;

 ELSE

    l_prev_postnatal_duration := nvl(g_map_calc.spouses_leave,0);

    l_postnatal_duration := nvl((g_map_calc.end_date - g_map_calc.parent_absence_start_date + 1),0);

    l_postnatal_duration := l_postnatal_duration + l_prev_postnatal_duration;

 END IF;

-- if postnatal duration is exceeded then set the end of the IJSS Payment to that maximum
   hr_utility.set_location('IJSS'|| l_postnatal_duration,32);

   if l_postnatal_duration > l_postnatal_duration_max then -- { over max
     g_map_calc.IJSS_GROSS_END_DATE := p_end_date - ( l_postnatal_duration - l_postnatal_duration_max);

-- if the post natal duration is exceeded before this absence then no IJSS is due
        if g_map_calc.IJSS_GROSS_END_DATE < p_start_date then
           g_map_calc.IJSS_GROSS_END_DATE := null;
           g_map_calc.IJSS_GROSS_START_DATE := null;
           end if;
        end if; -- } over max

if g_map_calc.IJSS_GROSS_END_DATE is not null and g_map_calc.IJSS_GROSS_START_DATE is not null then -- { ijss calc needed
   g_map_calc.IJSS_GROSS_DAYS := (g_map_calc.IJSS_GROSS_END_DATE - g_map_calc.IJSS_GROSS_START_DATE) +1;

    hr_utility.set_location('IJSS'|| g_map_calc.ijss_gross_days,32);
    hr_utility.set_location('IJSS'|| fnd_date.date_to_canonical(g_map_calc.ijss_gross_start_date),32);
    hr_utility.set_location('IJSS'|| fnd_date.date_to_canonical(g_map_calc.ijss_gross_end_date),32);

-- fetch reference salary
-- reference period is the 3 calendar months that preceed the start of the maternity
   l_ref_date := least(g_map_calc.parent_absence_start_date, g_map_calc.birth_date);
   l_ref_start_date := (add_months(trunc(l_ref_date,'MONTH'),-3));
   l_ref_end_date := last_day(add_months(l_ref_date,-1)) ;

   l_ref_sal := PAY_FR_SICKNESS_CALC.fr_rolling_balance(p_assignment_id,
                                            'FR_MAP_IJSS_REFERENCE_SALARY',
                                            l_ref_start_date,
                                            l_ref_end_date);
  hr_utility.set_location('IJSS',50);

   l_ref_sal := l_ref_sal / 90; -- convert to daily rate

-- cap daily rate at social security ceiling limit
   g_map_calc.IJSS_GROSS_RATE := least( l_ref_sal,g_map_arch.NOTIONAL_SS_RATE);

-- calculate the gross and Net IJSS
   g_map_calc.IJSS_GROSS := g_map_calc.IJSS_GROSS_RATE * g_map_calc.IJSS_GROSS_DAYS;

   g_map_calc.IJSS_NET_PAYMENT := g_map_calc.IJSS_GROSS * (100 - g_ijss_net_rate)/100;

    hr_utility.set_location('IJSS'|| g_map_calc.ijss_gross_rate,32);
    hr_utility.set_location('IJSS'|| g_map_calc.ijss_net_payment,32);

   end if; -- } ijss calc needed
--
  hr_utility.set_location('IJSS',100);

end CALC_MAP_IJSS;

PROCEDURE calc_map is
l_ref_bal_date_from Date;
l_smic_multiplier Number;
l_smic_hourly_rate Number;
l_smid_rate Number;
l_global_smic_ded Number;
l_return number;
l_ante_duration number := 0;
l_ante_duration_max number := 0;

-- Cursor for fetching global value
Cursor csr_global_value(c_global_name VARCHAR2,c_date_earned DATE) IS
   SELECT global_value
   FROM ff_globals_f
   WHERE global_name = c_global_name
   AND legislation_code = 'FR'
   AND c_date_earned BETWEEN effective_start_date AND effective_end_date;

Cursor c_prev_ante_natal_abs(p_start_date date
                            ,p_person_id number) is
select sum(date_end - date_start +1 ) duration
from per_absence_attendances
where person_id = p_person_id
and   abs_information_category = 'FR_M'
and   abs_information4 is null
and   date_start >= add_months(p_start_date,-9)
and   date_start < p_start_date
and   abs_information1 is null;

begin

  hr_utility.set_location('CALC_MAP',10);

 if g_map_calc.absence_category = 'FR_M' and nvl(g_map_calc.birth_date, hr_general.end_of_time) =  hr_general.end_of_time then

     OPEN csr_global_value('FR_MATERNITY_MAX_EXTENSION',g_map_arch.date_earned);
     FETCH csr_global_value INTO l_ante_duration_max;
     CLOSE csr_global_value;

     hr_utility.set_location('CALC_MAP'|| l_ante_duration_max,12);

     open c_prev_ante_natal_abs(g_map_calc.start_date,g_map_calc.person_id);
     fetch c_prev_ante_natal_abs into l_ante_duration;
     close c_prev_ante_natal_abs;

     hr_utility.set_location('CALC_MAP'|| l_ante_duration,14);

     l_ante_duration := (g_map_calc.end_date - g_map_calc.start_date + 1) + nvl(l_ante_duration,0);
     hr_utility.set_location('CALC_MAP'|| l_ante_duration,16);
     if (nvl(l_ante_duration,0) > nvl(l_ante_duration_max,0) ) then

        hr_utility.set_message (801, 'PAY_75052_MAT_EXT_EXCEEDED');
        hr_utility.raise_error;

     end if;

 end if;

-- fetch the IJSS_NET_RATE based on date_earned ( constant for whole run )
  if g_ijss_net_rate is null then
     OPEN csr_global_value('FR_IJSS_NET_RATE',g_map_arch.date_earned);
     FETCH csr_global_value INTO g_ijss_net_rate;
     CLOSE csr_global_value;
   end if;

-- the start and end dates relate to the absence being processed - reset those
-- to be within then run being processed

   if g_map_calc.start_date < g_map_arch.action_start_date then
      g_map_calc.start_date := g_map_arch.action_start_date;
   end if;

  hr_utility.set_location('CALC_MAP'|| g_ijss_net_rate,30);

   if g_map_calc.end_date > g_map_arch.action_end_date then
      g_map_calc.end_date := g_map_arch.action_end_date;
   end if;

      g_map_calc.deduction_start_date := g_map_calc.start_date;
      g_map_calc.deduction_end_date  := g_map_calc.end_date;

   Calculate_Maternity_Deduction;

-- check CALC structure for IJSS eligibility, set ELIG_IJSS flag
   if g_map_calc.ELIG_IJSS_HOURS = 'Y'  THEN -- { ELIG_HOURS
     g_map_calc.ELIG_IJSS := 'Y';
   end if; -- } ELIG_HOURS

  IF g_map_calc.ELIG_IJSS_HOURS <> 'Y' THEN -- { not eligible hours
     -- Perform SMID contributions check
     -- Fetch reference contributions from global
     -- as of 1st day of reference period
     l_ref_bal_date_from := TRUNC(ADD_MONTHS(g_map_calc.PARENT_ABSENCE_START_DATE,-3), 'MONTH');
     --
     OPEN csr_global_value('FR_IJSS_SMIC_MULTIPLIER',l_ref_bal_date_from);
     FETCH csr_global_value INTO l_smic_multiplier;
     CLOSE csr_global_value;
     --
     OPEN csr_global_value('FR_HOURLY_SMIC_RATE',l_ref_bal_date_from);
     FETCH csr_global_value INTO l_smic_hourly_rate;
     CLOSE csr_global_value;

  hr_utility.set_location('CALC_MAP',50);
     --
     l_smid_rate := hruserdt.get_table_value(g_map_arch.business_group_id,'FR_CONTRIBUTION_RATES','Value (EUR)','EE_SMID',l_ref_bal_date_from);
     --
     l_global_smic_ded := l_smic_multiplier *  l_smic_hourly_rate * l_smid_rate / 100;

     hr_utility.set_location('CALC_MAP'|| l_global_smic_ded,50);
     hr_utility.set_location('CALC_MAP'|| g_map_calc.ELIG_IJSS_CONTRIB,50);

     IF g_map_calc.ELIG_IJSS_CONTRIB > l_global_smic_ded THEN -- { ELIG_CONTRIB
        g_map_calc.ELIG_IJSS := 'Y';
     END IF; -- } ELIG_CONTRIB

     IF g_map_calc.ELIG_IJSS_CONTRIB <= l_global_smic_ded THEN -- { not ELIG_CONTRIB
        g_map_calc.ELIG_IJSS := 'N';
     END IF; -- } not ELIG_CONTRIB

  END IF; -- } not eligible hours

  hr_utility.set_location('CALC_MAP',70);

  if g_map_calc.ELIG_IJSS = 'Y'and g_map_calc.estimated_IJSS = 'Y' then -- { ELIG_IJSS
     calc_map_ijss(g_map_arch.assignment_id,
                   g_map_calc.start_date,
                   g_map_calc.end_date);

     IF g_map_calc.ijss_gross > 0 and g_map_calc.ijss_net_payment > 0 then

        g_map_calc.IJSS_ADJUSTMENT := 'Y';

     END IF;

  end if; -- } ELIG_IJSS

  hr_utility.set_location('CALC_MAP',90);

  IF g_map_calc.gi_eligible = 'ALL' then
     g_map_calc.GI_ELIGIBLE := 'Y';
     g_map_calc.GI_PAYMENT := g_map_calc.DEDUCTION;
  ELSIF g_map_calc.gi_eligible = 'IJSS' and g_map_calc.ELIG_IJSS = 'Y' then
  g_map_calc.GI_ELIGIBLE := 'Y';
  g_map_calc.GI_PAYMENT := g_map_calc.DEDUCTION;
  ELSE
  g_map_calc.GI_ELIGIBLE := 'N';
  END IF;

  hr_utility.set_location('CALC_MAP',100);

end calc_map;

--

FUNCTION init_map_absence(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
p_business_group_id     IN      Number,
p_payroll_id            IN      Number,
p_assignment_action_id  IN      Number,
p_element_type_id       IN      Number,
p_deduction_formula	IN      Number,
p_deduction_ref_salary  IN      Number,
P_action_start_date     IN      Date,
P_action_end_date       IN      Date,
p_notional_ss_rate      IN      Number)
RETURN Varchar2  is

cursor c_get_entry_dates is
select min(effective_start_date) effective_start_date
,      max(effective_end_date) effective_end_date
,      min(creator_id) absence_id
from pay_element_entries_f
where element_entry_id = p_element_entry_id;

cursor c_get_absence(p_absence_attendance_id number) is
select
      paa.date_start
,     paa.date_end
,     paa.date_end - paa.date_start + 1 duration
,     paa.person_id
,     paa.abs_information_category
,     paa.abs_information1
,     paa.abs_information2
,     paa.abs_information3
,     paa.abs_information4
,     paa.abs_information5
,     paa.abs_information6
,     paa.abs_information7
,     paa.abs_information8
,     paa.abs_information9
,     paa.abs_information10
from per_absence_attendances paa
where paa.absence_attendance_id = p_absence_attendance_id;

cursor c_get_parent_maternity(p_parent_absence_id number) is
SELECT    pabs.abs_information2 elig_gi,
          nvl(fnd_date.canonical_to_date (pabs.abs_information4),
                              hr_general.end_of_time) birth_date,
          fnd_number.canonical_to_number(pabs.abs_information6) births,
          pabs.abs_information7 estmtd_ijss,
          pabs.abs_information8 elig_ijss_hours,
          fnd_number.canonical_to_number (pabs.abs_information9)
                                              elig_ijss_contrib,
          pabs.date_start abs_start,
          pabs.date_end   abs_end
    FROM per_absence_attendances pabs
      WHERE pabs.absence_attendance_id = p_parent_absence_id;

cursor c_get_child_absence(p_person_id number
                          ,p_parent_absence_id number
                          ,p_max_end_date date) is
select absence_attendance_id
,      date_start
,      date_end
,      date_end - date_start + 1 duration
from per_absence_attendances
where person_id = p_person_id
and   date_end <= p_max_end_date
and   abs_information1 = fnd_number.number_to_canonical(p_parent_absence_id)
order by date_start;

TYPE t_absence is RECORD
(absence_id number
,date_start date
,date_end date
,duration number
,effective_start_date date
,effective_end_date date
,person_id number
,abs_information_category varchar2(30)
,abs_information1 varchar2(80)
,abs_information2 varchar2(80)
,abs_information3 varchar2(80)
,abs_information4 varchar2(80)
,abs_information5 varchar2(80)
,abs_information6 varchar2(80)
,abs_information7 varchar2(80)
,abs_information8 varchar2(80)
,abs_information9 varchar2(80)
,abs_information10 varchar2(80)
);
--
abs_rec t_absence;
parent_abs_rec t_absence;
--
l_duration number := 0;
l_absence_start_date date;
l_absence_end_date date;

l_proc               varchar2(72) := g_package||'init_absence';

begin

  hr_utility.set_location('INIT_MAP',10);

-- fetch the dates and the creator_id (which records the absence_attendance_id of
-- the absence being processed ) for the element being processed
   open c_get_entry_dates;
   fetch c_get_entry_dates into abs_rec.effective_start_date,
                                abs_rec.effective_end_date,
                                abs_rec.absence_id;
   close c_get_entry_dates;

-- fetch the details of the absence - not don't know whether its maternity, adoption,
-- paternity or whether its a parent maternity yet so pospone the interpretetion
-- until the absence has been fetched
   open c_get_absence(abs_rec.absence_id);
   fetch c_get_absence into abs_rec.date_start,
                            abs_rec.date_end,
                            abs_rec.duration,
                            abs_rec.person_id,
                            abs_rec.abs_information_category,
                            abs_rec.abs_information1,
                            abs_rec.abs_information2,
                            abs_rec.abs_information3,
                            abs_rec.abs_information4,
                            abs_rec.abs_information5,
                            abs_rec.abs_information6,
                            abs_rec.abs_information7,
                            abs_rec.abs_information8,
                            abs_rec.abs_information9,
                            abs_rec.abs_information10;

   close c_get_absence;

  hr_utility.set_location('INIT_MAP',30);

   -- set the columns that are relevent to the child absence/same value for child
   -- and parent
   g_map_calc.absence_id            := abs_rec.absence_id;
   g_map_calc.initiator             := 'ABSENCE';
   g_map_calc.person_id 	    := abs_rec.person_id;
   g_map_calc.absence_category 	    := abs_rec.abs_information_category;
   g_map_calc.start_date 	    := abs_rec.date_start;
   g_map_calc.end_date 	            := abs_rec.date_end;
   g_map_calc.absence_start_date    := abs_rec.date_start;
   g_map_arch.deduct_formula        := p_deduction_formula;
   g_map_arch.DED_REF_SALARY        := p_deduction_ref_salary;
   g_map_arch.action_start_date     := p_action_start_date;
   g_map_arch.action_end_date       := p_action_end_date;
   g_map_arch.element_type_id       := p_element_type_id;
   g_map_arch.payroll_id            := p_payroll_id;
   g_map_arch.assignment_action_id  := p_assignment_action_id;
   g_map_arch.business_group_id     := p_business_group_id;
   g_map_arch.notional_ss_rate      := p_notional_ss_rate;

   if abs_rec.abs_information_category = 'FR_M' then  -- { Maternity
      -- if its a parent then transfer all columns into calc structure
      if abs_rec.abs_information1 is null then -- { Parent Maternity

          g_map_calc.parent_absence_id := abs_rec.absence_id;
          g_map_calc.person_id := abs_rec.person_id;
          g_map_calc.absence_category := abs_rec.abs_information_category;
          g_map_calc.parent_absence_start_date := abs_rec.date_start;
          g_map_calc.parent_absence_end_date   := abs_rec.date_end;
          g_map_calc.ESTIMATED_IJSS := abs_rec.abs_information7;
          g_map_calc.GI_ELIGIBLE := abs_rec.abs_information3;
          g_map_calc.births := nvl(fnd_number.canonical_to_number
						(abs_rec.abs_information6),1);
          g_map_calc.birth_date := nvl(fnd_date.canonical_to_date
				(abs_rec.abs_information4), hr_general.end_of_time) ;
 	  g_map_calc.ELIG_IJSS_HOURS := abs_rec.abs_information8;
	  g_map_calc.ELIG_IJSS_CONTRIB := fnd_number.canonical_to_number
					(abs_rec.abs_information9) ;
  hr_utility.set_location('INIT_MAP',50);

      else -- }{ processed absence is child fetch parent
          g_map_calc.parent_absence_id := to_number(abs_rec.abs_information1);

          hr_utility.set_location('INIT_MAP'|| g_map_calc.parent_absence_id,50);

   	  open c_get_absence(g_map_calc.parent_absence_id);
   	  fetch c_get_absence into abs_rec.date_start,
                                   abs_rec.date_end,
                                   abs_rec.duration,
                                   abs_rec.person_id,
                      		   abs_rec.abs_information_category,
                            	   abs_rec.abs_information1,
                            	   abs_rec.abs_information2,
                            	   abs_rec.abs_information3,
                            	   abs_rec.abs_information4,
                            	   abs_rec.abs_information5,
                            	   abs_rec.abs_information6,
                            	   abs_rec.abs_information7,
                            	   abs_rec.abs_information8,
                            	   abs_rec.abs_information9,
                            	   abs_rec.abs_information10;

          if  c_get_absence%NOTFOUND then
                close c_get_absence;
                hr_utility.set_message (801, 'PAY_75031_INVALID_LINK_ABS');
                hr_utility.raise_error;
          end if;

          close c_get_absence;

          g_map_calc.parent_absence_start_date := abs_rec.date_start;
          g_map_calc.parent_absence_end_date   := abs_rec.date_end;
          g_map_calc.ESTIMATED_IJSS := abs_rec.abs_information7;
          g_map_calc.GI_ELIGIBLE := abs_rec.abs_information3;
          g_map_calc.births := nvl(fnd_number.canonical_to_number
						(abs_rec.abs_information6),1);
          g_map_calc.birth_date := nvl(fnd_date.canonical_to_date
				(abs_rec.abs_information4),hr_general.end_of_time);
 	  g_map_calc.ELIG_IJSS_HOURS := abs_rec.abs_information8;
	  g_map_calc.ELIG_IJSS_CONTRIB := fnd_number.canonical_to_number
					(abs_rec.abs_information9) ;
  hr_utility.set_location('INIT_MAP',70);

      end if ; -- } fetch parent
   end if; -- } maternity

   if abs_rec.abs_information_category = 'FR_FR_ADOPTION'
      -- { Adoption assign values into calc structure
      then
          g_map_calc.parent_absence_id := abs_rec.absence_id;
          g_map_calc.parent_absence_start_date := abs_rec.date_start;
          g_map_calc.parent_absence_end_date := abs_rec.date_end;
          g_map_calc.ESTIMATED_IJSS := abs_rec.abs_information4;
          g_map_calc.GI_ELIGIBLE := abs_rec.abs_information2;
          g_map_calc.births := nvl(fnd_number.canonical_to_number
						(abs_rec.abs_information3),1);
          g_map_calc.birth_date := nvl(fnd_date.canonical_to_date
				(abs_rec.abs_information1), hr_general.end_of_time) ;
 	  g_map_calc.ELIG_IJSS_HOURS := abs_rec.abs_information5;
	  g_map_calc.ELIG_IJSS_CONTRIB := fnd_number.canonical_to_number
					(abs_rec.abs_information6) ;
	  g_map_calc.SPOUSES_LEAVE := fnd_number.canonical_to_number
					(abs_rec.abs_information7) ;
  hr_utility.set_location('INIT_MAP',80);

   end if; -- } adoption

   if  abs_rec.abs_information_category = 'FR_FR_PATERNITY'
      -- { Paternity assign values into calc structure
      then
          g_map_calc.parent_absence_id := abs_rec.absence_id;
          g_map_calc.parent_absence_start_date := abs_rec.date_start;
          g_map_calc.parent_absence_end_date := abs_rec.date_end;
          g_map_calc.ESTIMATED_IJSS := abs_rec.abs_information4;
          g_map_calc.GI_ELIGIBLE := abs_rec.abs_information2;
          g_map_calc.births := nvl(fnd_number.canonical_to_number
						(abs_rec.abs_information3),1);
          g_map_calc.birth_date := nvl(fnd_date.canonical_to_date
				(abs_rec.abs_information1), hr_general.end_of_time) ;
 	  g_map_calc.ELIG_IJSS_HOURS := abs_rec.abs_information5;
	  g_map_calc.ELIG_IJSS_CONTRIB := fnd_number.canonical_to_number
					(abs_rec.abs_information6) ;
  hr_utility.set_location('INIT_MAP',90);

   end if; -- } end Paternity

  hr_utility.set_location('INIT_MAP',100);

return 'Y';

end init_map_absence;

--
FUNCTION init_cpam_absence(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
p_business_group_id     IN      Number,
p_payroll_id            IN      Number,
p_assignment_action_id  IN      Number,
p_element_type_id       IN      Number,
p_payment_from_date     IN      Date,
p_payment_to_date       IN      Date,
p_days                  IN      Number,
p_gross_amount          IN      Number,
p_net_amount            IN      Number,
p_gross_daily_rate      IN      Number)

RETURN Varchar2  is

cursor c_get_absence(p_assignment_id number,
                     p_date_earned date,
                     p_payment_from_date date) is
select paa.absence_attendance_id
,      paa.date_start
,      paa.date_end
,      decode(paa.abs_information_category,'FR_M',to_number(paa.abs_information1)) parent_absence_id
,      decode(paa.abs_information_category,'FR_M',NVL(paa.abs_information7,'N'),NVL(paa.abs_information4,'N')) estimated_ijss
from per_absence_attendances paa
     ,per_assignments_f paf
where paf.assignment_id = p_assignment_id
and   paf.person_id = paa.person_id
and   p_date_earned between
      paf.effective_start_date and paf.effective_end_date
and   p_payment_from_date between paa.date_start and paa.date_end
and   paa.abs_information_category IN ('FR_M','FR_FR_PATERNITY','FR_FR_ADOPTION');

cursor c_get_parent_absence(p_absence_attendance_id number) is
select paa.abs_information7 estimated_ijss
from per_absence_attendances paa
where paa.absence_attendance_id = p_absence_attendance_id;

TYPE t_absence is RECORD
(absence_attendance_id number
,parent_absence_id number
,date_start date
,date_end date
,estimated_ijss varchar2(30)
);
--
abs_rec t_absence;
parent_abs_rec t_absence;
--
l_proc               varchar2(72) := g_package||'init_absence';

begin

  hr_utility.set_location('INIT_CPAM',10);

-- fetch the details of the absence looking for a maternity absence that is current
-- on the payment_start_date.  If no maternity is found raise error.  If maternity
-- exists but has been estimated then skip. If the absence fetched is a child absence
-- fetch the parent and read the estimted_ijss flag from that
   begin
   open c_get_absence(p_assignment_id, p_date_earned, p_payment_from_date);
   fetch c_get_absence into abs_rec.absence_attendance_id,
                            abs_rec.date_start,
                            abs_rec.date_end,
                            abs_rec.parent_absence_id,
                            abs_rec.estimated_ijss;
         if c_get_absence%notfound THEN
                hr_utility.set_message (801, 'PAY_75049_IJSS_NO_ABSENCE');
                hr_utility.raise_error;
         end if;
   close c_get_absence;

   g_map_arch.element_type_id       := p_element_type_id;
   g_map_arch.payroll_id            := p_payroll_id;
   g_map_arch.assignment_action_id  := p_assignment_action_id;
   g_map_arch.business_group_id     := p_business_group_id;
   g_map_calc.start_date            := p_payment_from_date;
   g_map_calc.end_date              := p_payment_to_date;
   g_map_calc.ijss_gross_start_date := p_payment_from_date;
   g_map_calc.ijss_gross_end_date   := p_payment_to_date;
   g_map_calc.ijss_gross_rate       := p_gross_daily_rate;
   g_map_calc.ijss_gross_days       := p_days;
   g_map_calc.ijss_gross            := p_gross_amount;
   g_map_calc.ijss_net_payment      := p_net_amount;
   g_map_calc.initiator             := 'CPAM';

  hr_utility.set_location('INIT_CPAM',30);

   end;

   -- set the columns that are relevent to the child absence/same value for child
   -- and parent
   g_map_calc.absence_id := abs_rec.absence_attendance_id;
   g_map_calc.initiator  := 'CPAM';
   if abs_rec.parent_absence_id is not null then
      open c_get_parent_absence (abs_rec.parent_absence_id);
      fetch c_get_parent_absence into abs_rec.estimated_ijss;
      close c_get_parent_absence;
   end if;

  hr_utility.set_location('INIT_CPAM',50);

   g_map_calc.estimated_ijss := abs_rec.estimated_ijss;

-- if the absence is already estimated then don't iterate and skip
-- if the absence is not estimated then iteration is required
   if (g_map_calc.ESTIMATED_IJSS = 'N'and g_map_calc.ijss_gross > 0 and g_map_calc.ijss_net_payment > 0)  then
      g_map_calc.IJSS_ADJUSTMENT := 'Y';
   end if;

  hr_utility.set_location('INIT_CPAM',100);

return g_map_calc.estimated_ijss;

end init_cpam_absence;

FUNCTION get_map_skip
RETURN Varchar2 is

begin

  hr_utility.set_location('SKIP',10);

return g_map_calc.estimated_ijss;

end get_map_skip;

--

FUNCTION iterate(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
p_net_pay               IN      Number,
p_stop_processing       OUT NOCOPY Varchar2)

RETURN Number is

BEGIN

  --
  -- Checking for change in assignment, absence and initialising Variables
  --
  hr_utility.set_location('Iterate',10);

   IF (NVL(g_map_arch.assignment_id, -1) <> p_assignment_id) OR
       (g_map_arch.element_entry_id IS NULL) OR
       (g_map_arch.date_earned <> p_date_earned) THEN

       g_map_arch.assignment_id       := p_assignment_id;
       g_map_arch.date_earned         := p_date_earned;
       g_map_arch.element_entry_id    := p_element_entry_id;
       g_map_arch.net            := p_net_pay;
     hr_utility.set_location('actual net'|| p_net_pay,20);
  hr_utility.set_location('Iterate',20);

       IF g_map_calc.initiator <> 'CPAM' THEN
          calc_map();
       END IF;

   ELSE
         increment_iteration;

 hr_utility.set_location('arch net'|| g_map_arch.net,30);
 hr_utility.set_location('actual net'|| p_net_pay,30);

         IF nvl(g_map_calc.ijss_adjustment,'N') <> 'Y'      OR
            (g_map_arch.net + cs_MARGIN >= p_net_pay AND
             g_map_arch.net - cs_MARGIN <= p_net_pay)THEN

  hr_utility.set_location('Iterate',30);

            reset_data_structures;
            p_stop_processing := 'Y';
         ELSE
            set_adjustment(p_net_pay);
         END IF;

    END IF;

  hr_utility.set_location('Iterate',100);

    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('iterate ',-10);
      hr_utility.trace(SQLCODE);
      hr_utility.trace(SQLERRM);
      hr_utility.trace_off;
      RAISE;

end iterate;

--
-- Create Indirect Elements for Process
--

FUNCTION indirects
 ( p_absence_id            out nocopy number,
   p_ijss_gross            out nocopy number,
   p_ijss_gross_rate       out nocopy number,
   p_ijss_gross_base       out nocopy number,
   p_ijss_gross_start_date out nocopy date,
   p_ijss_gross_end_date   out nocopy date,
   p_ijss_estmtd           out nocopy varchar2,
   p_ijss_net_payment          out nocopy number,
   p_map_deduction         out nocopy number,
   p_map_deduction_rate    out nocopy number,
   p_map_deduction_base    out nocopy number,
   p_map_deduct_start_date out nocopy date,
   p_map_deduct_end_date   out nocopy date,
   p_map_gi_payment        out nocopy number,
   p_map_ijss_adjustment   out nocopy number)

RETURN Number is

begin

  hr_utility.set_location('Indirect',10);

   p_absence_id            :=  g_map_calc.absence_id;
   p_ijss_gross            :=  g_map_calc.ijss_gross;
   p_ijss_gross_rate       :=  g_map_calc.ijss_gross_days;
   p_ijss_gross_base       :=  g_map_calc.ijss_gross_rate;
   p_ijss_gross_start_date :=  g_map_calc.ijss_gross_start_date;
   p_ijss_gross_end_date   :=  g_map_calc.ijss_gross_end_date;
   p_ijss_estmtd           :=  g_map_calc.estimated_ijss;
   p_ijss_net_payment      :=  g_map_calc.ijss_net_payment;
   p_map_deduction         :=  g_map_calc.deduction;
   p_map_deduction_rate    :=  g_map_calc.deduction_rate;
   p_map_deduction_base    :=  g_map_calc.deduction_base;
   p_map_deduct_start_date :=  g_map_calc.deduction_start_date;
   p_map_deduct_end_date   :=  g_map_calc.deduction_end_date;
   p_map_gi_payment        :=  g_map_calc.gi_payment;
   p_map_ijss_adjustment   :=  g_map_calc.gi_ijss_adj;

  hr_utility.set_location('Iterate',100);

return 0;

end indirects;

 --
 -- Maternity Element has been processed to completion so clear down the data
 -- structures in preparation for a new Insurance Element NB.
 --

  PROCEDURE reset_data_structures IS
  BEGIN

    hr_utility.set_location('Reset Data Str',10);

    g_map_calc  := blank_map_calc;
    g_map_arch  := blank_map_arch;
    g_ctl       := blank_ctl;

    hr_utility.set_location('Reset Data Str',100);
  END reset_data_structures;

 --
 -- Increments the iteration.
 --
 --

  PROCEDURE increment_iteration IS
  BEGIN
    hr_utility.set_location('Increment Iteration',10);
    g_ctl.iter := g_ctl.iter + 1;
    hr_utility.set_location('Increment Iteration',100);
  END increment_iteration;

    --
    --
    -- Sets an adjustment as required for the processing of the current guarantee.
    --
    --

    PROCEDURE set_adjustment
    (p_net_pay NUMBER) IS
      --
      --
      -- Local variables
      --
      l_dummy      NUMBER;
      l_target_net NUMBER;
      l_diff       NUMBER;
      l_map_adj   NUMBER;
      l_init     NUMBER := 0;
    BEGIN
    hr_utility.set_location('Set Adjustment',10);
      --
      --
      -- Get the target net for the current guarantee.
      --
      l_target_net := nvl(g_map_arch.net,0);

      select decode(l_target_net,0,1,l_target_net) into l_init from dual;

 hr_utility.set_location('Set Adjustment target net: ' || l_target_net,15);
 hr_utility.set_location('Set Adjustment init: ' || l_init,17);

          --
          -- There has not been an adjustment so set an initial value.
          --
          IF g_map_calc.gi_ijss_adj IS NULL THEN

          hr_utility.set_location('IJSS Adjustment: ' ||g_map_calc.gi_ijss_adj,19);

            l_dummy    := pay_iterate.initialise(g_map_arch.element_entry_id, l_init, - 1 * l_init, l_init);

            l_map_adj  := pay_iterate.get_interpolation_guess(g_map_arch.element_entry_id, 0) ;
            hr_utility.set_location('Set Adjustment',20);
          --
          --
          -- Refine the adjustment.
          --
          ELSE
         hr_utility.set_location('IJSS Adjustment: ' ||g_map_calc.gi_ijss_adj,29);
            l_diff     := l_target_net - p_net_pay;
            l_map_adj  := pay_iterate.get_interpolation_guess(g_map_arch.element_entry_id, l_diff);

   END IF;
    --
    --
    -- Set the  maternity adjustment.
    --
    g_map_calc.gi_ijss_adj := l_map_adj;
    hr_utility.set_location('Set Adjustment',100);

  END set_adjustment;

--
END PAY_FR_MAP_CALC;

/
