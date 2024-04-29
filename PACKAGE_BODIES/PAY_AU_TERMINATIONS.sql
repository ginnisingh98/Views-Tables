--------------------------------------------------------
--  DDL for Package Body PAY_AU_TERMINATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_TERMINATIONS" AS
/*  $Header: pyauterm.pkb 120.13.12010000.6 2009/09/07 12:18:39 pmatamsr ship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Procedures and functions used in AU terminations version 2
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  =========================================================
**  14-AUG-2000 sclarke  115.0     Created for AU
**  01-SEP-2000 sclarke  115.0     Terminations tax calculation
**  27-SEP-2000 sclarke  115.1     Added LSL function
**  15-NOV-2000 sclarke  115.2     Bug 1500587 Post 30 June ratio fixed
**  16-NOV-2000 sclarke  115.3     Bug 1499206
**  22-NOV-2000 sclarke  115.4     Bug 1510774
**  04-DEC-2000 sclarke  115.5     Bug 1519569 rounding of deductions on marginal tax
**  15-DEC-2000 sclarke  115.6     Bug 1544503
**  20-DEC-2000 rayyadev 115.7     bug no 1547908
**  11-JAN-2001 rayyadev 115.8     bug no 1553213
**  19-JUL-2001 apunekar 115.9     Adjustments taken care of for accruals.Bug no. 1855872
**  12-SEP-2001 shoskatt 115.11    Leave Initialise Values used for calculating the Accruals
**                                 Bug #1942971
**  Package containing addition processing required by
**  formula in AU localisatons.
**  28-NOV-2001 nnaresh 115.12     Updated for GSCC Standards
**  04-Dec-2002 Ragovind 115.13    Added NOCOPY to thr functions check_rollover, etp_prepost_ratios
**                                 ,get_long_service_leave, term_lsl_eligibility_years
**  07-May-2003 Ragovind 115.15    Bug#2819479 - ETP Pre/Post Enhancement.
**  18-May-2003 Ragovind 115.16    Added Reference Bug# for Bug#2819479
**  23-Jul-2003 Nanuradh 115.17    Bug#2984390 - Added an extra parameter p_etp_service_date to the function etp_prepost_ratios
**                                 ETP Pre/post Enhancement
**  26-Jul-2003 Nanuradh 115.18    Bug#2984390 - Modified the function etp_prepost_ratios.
**                                 Pre/post ratios assgined to zero when pre/post 1983 days are zero.
**  23-Dec-2003 punmehta 115.19    Bug#3306112 - Modified the cursor to improve performance and added conditional debug.
**  10-May-2003 Ragovind 115.20    Bug#3263690 - NGE calculation Enhancement.
**  25-Jun-2004 srrajago 115.21    Bug#3603495 - Modified the cursor 'recurring_entries' in the function 'processed' - Performance fix.
**  09-AUG-2004 abhkumar 115.22    Bug#2610141 - Legal Employer enhancement changes.
**  12-AUG-2004 abhkumar 115.23    Bug#2610141 - Modfied cursor c_get_prev_year_max_asg_act_id to consider for action_type='V'
**  08-SEP-2004 abhkumar 115.25    Bug#2610141 - Added a parameter to function calculate_term_asg_nge to support the
**                                 versioning of the tax formula.
**  19-Apr-2004 ksingla  115.26    Bug#4177679 - Added an extra parameter p_le_etp_service_date to the function etp_prepost_ratios.
**  03-AUG-2005 abhkumar 115.27    Bug#4538463 - Modified the function calculate_term_asg_nge to have a logic similar as
**                                 calculate_asg_prev_value
**  01-SEP-2005 abhkumar 115.28    Bug#4474896 - Average Earnings Calculation enhancement
**  02-Apr-2006 abhargav 115.29    Bug#5107059 - Added new function get_total_accrual_hours().
**  17-Apr-2006 abhargav 115.30   Bug#5107059 -  Modified to remove gscc error.
**  27-Jun-2006 hnainani 115.31   Bug# 5056831 - Added Function Override_eligibility
**  11-Jul-2006 priupadh 115.32   Bug# 5377591 - Changed cursor c_check_payroll_run to Function CALCULATE_TERM_ASG_NGE
**  17-Jul-2006 avenkatk 115.33   Bug# 5388657 - Modified Dates passed to c_check_payroll_run in Function CALCULATE_TERM_ASG_NGE
**
** 21-Sep-2006  hnainani 115.24    Bug# 5056831  - Removed extra param to Override_eligibility based
**                                              on review comments
** 09-May-2007  priupadh 115.36    Bug# 5956223  Added new function calculate_etp_tax,get_trans_prev_etp
** 16-May-2007  priupadh 115.37    Bug# 5956223  Removed function get_trans_prev_etp,added function get_fin_year_end
** 31-May-2007  priupadh 115.38    Bug# 6071863  Added function get_prev_age Modified cursor csr_get_etp_tax
** 31-May-2007  priupadh 115.39    Bug# 6071863  Corrected version numbers in change history .
** 04-Jun-2007  priupadh 115.40    Bug# 6071863  Modified query csr_get_prev_age in function get_prev_age .
** 23-Aug-2007  priupadh 115.41    Bug# 6192381  Added function au_check_trans
** 17-Sep-2007  avenkatk 115.42    Bug# 6430072  Function calculate_etp_tax - Added condition to convert User Tables value using
**                                               fnd_number.canonical_to_number
** 26-May-2009  dduvvuri 115.43    Bug# 8482224  Cursor csr_get_accrual_plan_id modified in Function get_accrual_plan_by_category
** 20-Jul-2009  skshin   115.45    Bug# 8647962  Added Index(PURF) and ORDERED hint to get correct execution path
** 30-Jul-2009  skshin   115.46    Bug# 8725341  Added Earnings_Leave_Loading balance to be retrieved effective from 01-JUL-2009 in calculate_term_asg_nge function
** 07-Sep-2009  pmatamsr 115.47    Bug# 8769345  Added new input parameter to check_rollover function.
*/
g_debug constant boolean  := hr_utility.debug_enabled;
g_package   constant varchar2(60) := 'pay_au_terminations.';
--
-------------------------------------------------------------------------------------------------
--
-- FUNCTION get_long_service_leave
--
-- Returns :
--           1 if function runs successfully
--           0 otherwise
--
-- Purpose : Calculates net amount of long service leave accrual plan and breaks the
--           amounts into the appropriate time buckets as required for Terminations
--           tax calculations.  Days suspended is taken into account by using the accrual
--           fastformula.
--
-- In :      p_assignment_id     - assignment which is enrolled in the accrual plan
--           p_payroll_id        - payroll to which the assignment is enrolled
--           p_business_group_id
--           p_effective_date    - date up to which accrual is to be calculated
--
-- Out :     p_pre_aug_1978      - net leave amount before from start of accrual plan to 15-AUG-1978
--           p_post_aug_1978     - net leave amount from 16-AUG-1978 to 17-AUG-1993
--           p_post_aug_1993     - net leave amount from 18-AUG-1993 until effective_date
--
-- Uses :    per_accrual_calc_functions
--           pay_au_terminations
--           hr_utility
--
------------------------------------------------------------------------------------------------
function get_long_service_leave
(p_assignment_id        in  number
,p_payroll_id           in  number
,p_business_group_id    in  number
,p_effective_date       in  date
,p_pre_aug_1978         out NOCOPY number
,p_post_aug_1978        out NOCOPY number
,p_post_aug_1993        out NOCOPY number
) return number is
--
  l_procedure           constant varchar2(300) := g_package||'get_long_service_leave';
  l_plan_id             number;
  l_long_service_leave  varchar2(30);
  l_pre78_accrual       number(9,2);
  l_pre78_absence       number(9,2);
  l_post78_accrual      number(9,2);
  l_post78_absence      number(9,2);
  l_post93_accrual      number(9,2);
  l_post93_absence      number(9,2);
  l_others_entitlement_pre78 number(9,2);
  l_others_entitlement_post78 number(9,2);
  l_others_entitlement_post93 number(9,2);
  l_start_date          date;
  l_end_date            date;
  l_accrual_end_date    date;
  l_pre_16_aug_1978     constant date := to_date('16-08-1978','DD-MM-YYYY');
  l_post_15_aug_1978    constant date := to_date('15-08-1978','DD-MM-YYYY');
  l_post_17_aug_1993    constant date := to_date('17-08-1993','DD-MM-YYYY');
  --
  -- Bug #1942971 -- Start
  l_accrual_init_pre78       number(9,2);
  l_accrual_init_post78      number(9,2);
  l_accrual_init_post93      number(9,2);
  l_entitlement_init_pre78   number(9,2);
  l_entitlement_init_post78  number(9,2);
  l_entitlement_init_post93  number(9,2);
  l_initialise_type          varchar2(100);

  -- Bug #1942971 -- End
begin
  /* Initialize the variables */
  l_long_service_leave  := 'AULSL';


  IF g_debug THEN
          hr_utility.trace('-----------------------------------------');
          hr_utility.set_location('Entering : '||l_procedure, 1);
  END IF;
  --
  -- Get the accrual plan for long service leave
  --
  l_plan_id := pay_au_terminations.get_accrual_plan_by_category
  (p_assignment_id      => p_assignment_id
  ,p_effective_date     => p_effective_date
  ,p_plan_category      => l_long_service_leave
  );
  IF g_debug THEN
          hr_utility.trace('plan id            := '||to_char(l_plan_id));
  END IF;
  --
  ---------------------------
  -- Calculate pre aug 1978
  ---------------------------
  -- Accrual pre-aug-1978
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 10);
  END IF;
  per_accrual_calc_functions.get_accrual
  (p_assignment_id      => p_assignment_id
  ,p_calculation_date   => l_pre_16_aug_1978 - 1
  ,p_plan_id            => l_plan_id
  ,p_business_group_id  => p_business_group_id
  ,p_payroll_id         => p_payroll_id
  ,p_start_date         => l_start_date
  ,p_end_date           => l_end_date
  ,p_accrual_end_date   => l_accrual_end_date
  ,p_accrual            => l_pre78_accrual
  );

  l_others_entitlement_pre78 := per_accrual_calc_functions.get_other_net_contribution (p_assignment_id => p_assignment_id
               ,p_plan_id           => l_plan_id
               ,p_start_date        => l_start_date
               ,p_calculation_date  => l_pre_16_aug_1978 - 1);

-- Bug #1942971 -- Start

  l_initialise_type := 'Leave Accrual Initialise' ;

  l_accrual_init_pre78 := (hr_au_holidays.get_leave_initialise
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => l_plan_id
                        ,p_calc_end_date       => l_pre_16_aug_1978 - 1
                        ,p_initialise_type     => l_initialise_type
                        ,p_start_date          => l_start_date
                        ,p_end_date            => l_pre_16_aug_1978 - 1
                        ));

  l_initialise_type := 'Leave Entitlement Initialise' ;

  l_entitlement_init_pre78 := (hr_au_holidays.get_leave_initialise
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => l_plan_id
                        ,p_calc_end_date       => l_pre_16_aug_1978 - 1
                        ,p_initialise_type     => l_initialise_type
                        ,p_start_date          => l_start_date
                        ,p_end_date            => l_pre_16_aug_1978 - 1
                        ));

  l_pre78_accrual:=l_pre78_accrual + l_others_entitlement_pre78 + l_accrual_init_pre78 + l_entitlement_init_pre78 ;

-- Bug #1942971 --  End
  IF g_debug THEN
          hr_utility.trace('p_start_date       := '||to_char(l_start_date,'dd-MM-yyyy'));
          hr_utility.trace('p_end_date         := '||to_char(l_end_date,'dd-MM-yyyy'));
          hr_utility.trace('p_accrual_end_date := '||to_char(l_accrual_end_date,'dd-MM-yyyy'));
          hr_utility.trace('pre78 accrual      := '||to_char((l_pre78_accrual)));
  END IF;
  --
  -- Absences for pre-aug-1978
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 15);
  END IF;
  l_pre78_absence := per_accrual_calc_functions.get_absence
  (p_assignment_id      => p_assignment_id
  ,p_plan_id            => l_plan_id
  ,p_calculation_date   => l_pre_16_aug_1978 - 1
  ,p_start_date         => l_start_date
  );
  IF g_debug THEN
          hr_utility.trace('pre78 absence      := '||to_char(l_pre78_absence));
  END IF;
  --
  ---------------------------
  -- Calculate post aug 1978
  ---------------------------
  -- Accrual post-aug-1978
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 30);
  END IF;
--
  if p_effective_date < l_post_17_aug_1993 and  p_effective_date > l_pre_16_aug_1978  then
  per_accrual_calc_functions.get_accrual
  (p_assignment_id      => p_assignment_id
  ,p_calculation_date   => p_effective_date
  ,p_plan_id            => l_plan_id
  ,p_business_group_id  => p_business_group_id
  ,p_payroll_id         => p_payroll_id
  ,p_start_date         => l_start_date
  ,p_end_date           => l_end_date
  ,p_accrual_end_date   => l_accrual_end_date
  ,p_accrual            => l_post78_accrual
  );
  else
    per_accrual_calc_functions.get_accrual
  (p_assignment_id      => p_assignment_id
  ,p_calculation_date   => l_post_17_aug_1993
  ,p_plan_id            => l_plan_id
  ,p_business_group_id  => p_business_group_id
  ,p_payroll_id         => p_payroll_id
  ,p_start_date         => l_start_date
  ,p_end_date           => l_end_date
  ,p_accrual_end_date   => l_accrual_end_date
  ,p_accrual            => l_post78_accrual
  );

  end if;
--Get the adjustments made and then add it to the accruals.Bug no 1855872
  l_others_entitlement_post78 := per_accrual_calc_functions.get_other_net_contribution (p_assignment_id => p_assignment_id
               ,p_plan_id           => l_plan_id
               ,p_start_date        => l_start_date
               ,p_calculation_date  => l_post_17_aug_1993);


-- Bug #1942971 -- Start
  l_initialise_type := 'Leave Accrual Initialise' ;

  l_accrual_init_post78 := (hr_au_holidays.get_leave_initialise
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => l_plan_id
                        ,p_calc_end_date       => l_post_17_aug_1993
                        ,p_initialise_type     => l_initialise_type
                        ,p_start_date          => l_pre_16_aug_1978
                        ,p_end_date            => l_post_17_aug_1993
                        ));

  l_initialise_type := 'Leave Entitlement Initialise' ;

  l_entitlement_init_post78 := (hr_au_holidays.get_leave_initialise
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => l_plan_id
                        ,p_calc_end_date       => l_post_17_aug_1993
                        ,p_initialise_type     => l_initialise_type
                        ,p_start_date          => l_pre_16_aug_1978
                        ,p_end_date            => l_post_17_aug_1993
                        ));

  l_post78_accrual := l_post78_accrual - l_pre78_accrual + l_others_entitlement_post78 + l_accrual_init_post78 + l_entitlement_init_post78;
  --
-- Bug #1942971 --  End
  IF g_debug THEN
          hr_utility.trace('p_start_date       := '||to_char(l_start_date,'dd-MM-yyyy'));
          hr_utility.trace('p_end_date         := '||to_char(l_end_date,'dd-MM-yyyy'));
          hr_utility.trace('p_accrual_end_date := '||to_char(l_accrual_end_date,'dd-MM-yyyy'));
          hr_utility.trace('post78 accrual     := '||to_char((l_post78_accrual)));
  END IF;
  --
  -- Absences for post-aug-1978
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 35);
  END IF;
  l_post78_absence := per_accrual_calc_functions.get_absence
  (p_assignment_id      => p_assignment_id
  ,p_plan_id            => l_plan_id
  ,p_calculation_date   => l_post_17_aug_1993
  ,p_start_date         => l_post_15_aug_1978 + 1
  );
  IF g_debug THEN
          hr_utility.trace('post78 absence     := '||to_char(l_post78_absence));
  END IF;
  --
  ---------------------------
  -- Calculate post aug 1993
  ---------------------------
  -- Accrual post-aug-1993
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 50);
  END IF;
  per_accrual_calc_functions.get_accrual
  (p_assignment_id      => p_assignment_id
  ,p_calculation_date   => p_effective_date
  ,p_plan_id            => l_plan_id
  ,p_business_group_id  => p_business_group_id
  ,p_payroll_id         => p_payroll_id
  ,p_start_date         => l_start_date
  ,p_end_date           => l_end_date
  ,p_accrual_end_date   => l_accrual_end_date
  ,p_accrual            => l_post93_accrual
  );

--Get the adjustments made and then add it to the accruals.Bug no 1855872
  l_others_entitlement_post93 := per_accrual_calc_functions.get_other_net_contribution (p_assignment_id => p_assignment_id
               ,p_plan_id           => l_plan_id
               ,p_start_date        => l_start_date
               ,p_calculation_date  => p_effective_date);
  l_post93_accrual:=l_post93_accrual + l_others_entitlement_post93;

-- Bug #1942971 -- Start
  l_initialise_type := 'Leave Accrual Initialise' ;

  l_accrual_init_post93 := (hr_au_holidays.get_leave_initialise
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => l_plan_id
                        ,p_calc_end_date       => p_effective_date
                        ,p_initialise_type     => l_initialise_type
                        ,p_start_date          => l_post_17_aug_1993 + 1
                        ,p_end_date            => l_end_date
                        ));

  l_initialise_type := 'Leave Entitlement Initialise' ;

  l_entitlement_init_post93 := (hr_au_holidays.get_leave_initialise
                        (p_assignment_id       => p_assignment_id
                        ,p_accrual_plan_id     => l_plan_id
                        ,p_calc_end_date       => p_effective_date
                        ,p_initialise_type     => l_initialise_type
                        ,p_start_date          => l_post_17_aug_1993 + 1
                        ,p_end_date            => l_end_date
                        ));

  l_post93_accrual := l_post93_accrual - l_pre78_accrual - l_post78_accrual + l_accrual_init_post93 + l_entitlement_init_post93 ;
  --
-- Bug #1942971 -- End
  IF g_debug THEN
          hr_utility.trace('p_start_date       := '||to_char(l_start_date,'dd-MM-yyyy'));
          hr_utility.trace('p_end_date         := '||to_char(l_end_date,'dd-MM-yyyy'));
          hr_utility.trace('p_accrual_end_date := '||to_char(l_accrual_end_date,'dd-MM-yyyy'));
          hr_utility.trace('post93 accrual     := '||to_char((l_post93_accrual)));
  END IF;
  --
  -- Absences for post-aug-1993
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 55);
  END IF;

  l_post93_absence := per_accrual_calc_functions.get_absence
  (p_assignment_id      => p_assignment_id
  ,p_plan_id            => l_plan_id
  ,p_calculation_date   => p_effective_date
  ,p_start_date         => l_post_17_aug_1993 + 1
  );
  IF g_debug THEN
          hr_utility.trace('post93 absence     := '||to_char(l_post93_absence));
  END IF;
  --
  -- Absence are taken from accruals LIFO
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 70);
  END IF;
  if l_post93_absence > l_post93_accrual
  then
    IF g_debug THEN
                hr_utility.set_location(l_procedure, 72);
    END IF;
        p_post_aug_1993 := 0;
    --
    -- Move excess absences from post aug 1993 to absence for post aug 1978, previous bucket
    --
    l_post78_absence := l_post78_absence + (l_post93_absence - l_post93_accrual);
  else
    IF g_debug THEN
                hr_utility.set_location(l_procedure, 74);
    END IF;
        p_post_aug_1993 := l_post93_accrual - l_post93_absence;
  end if;
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 80);
  END IF;
  if l_post78_absence > l_post78_accrual
  then
  IF g_debug THEN
        hr_utility.set_location(l_procedure, 82);
  END IF;
    p_post_aug_1978 := 0;
    --
    -- Move excess absences from post aug 1978 to absence for pre aug 1978, previous bucket
    --
    l_pre78_absence := l_pre78_absence + (l_post78_absence - l_post78_accrual);
  else
     IF g_debug THEN
                hr_utility.set_location(l_procedure, 84);
                hr_utility.trace('l_post78_accrual:'||l_post78_accrual);
                hr_utility.trace('l_post78_absence:'||l_post78_absence);
         END IF;
    p_post_aug_1978 := l_post78_accrual - l_post78_absence;
  end if;
  --
  IF g_debug THEN
          hr_utility.set_location(l_procedure, 90);
  END IF;
  if l_pre78_absence > l_pre78_accrual
  then
      IF g_debug THEN
                hr_utility.set_location(l_procedure, 92);
      END IF;
        -- Just set to zero, as we will not use negative amounts
    p_pre_aug_1978 := 0;
  else
        IF g_debug THEN
                hr_utility.set_location(l_procedure, 94);
        END IF;
    p_pre_aug_1978 := l_pre78_accrual - l_pre78_absence;
  end if;
  --
  IF g_debug THEN
          hr_utility.set_location('Leaving : '||l_procedure, 999);
          hr_utility.trace('-----------------------------------------');
  END IF;
  return 1;
end get_long_service_leave;
--
--------------------------------------------------------------------------------------
-- Start Bug# 5056831
--------------------------------------------------------------------------------------
-- Function override_elig
--
-- Returns 'Y' if the element entry has already been selected for override_elig in a payroll
-- run. Used by the PAYAUTRM form views
--
function override_elig
(p_element_entry_id      number
,p_input_value_id     number
,p_effective_date date
)
return varchar2 is
  --
  override_elig       VARCHAR2(1) ;
  --
  -- Define how to determine if the entry is Prorated
  --

cursor get_override_elig is

  select nvl(eev.screen_entry_value, 'N')
  from pay_element_entry_values_f eev
  where eev.input_value_id = p_input_Value_id
  and   eev.element_entry_id  = p_element_entry_id
  and   p_effective_date between eev.effective_Start_Date and eev.effective_end_date;

begin
 override_elig      := 'N';
    --
    open get_override_elig;
    fetch get_override_elig into override_elig;
    close get_override_elig;

return override_elig;

end override_elig;

--------------------------------------------------------------------------------------
--  End Bug# 5056831
--------------------------------------------------------------------------------------

-- Function processed
--
-- Returns 'Y' if the element entry has already been processed in a payroll
-- run. Used by the PAYAUTRM form views
--
function processed
(p_element_entry_id      number
,p_original_entry_id     number
,p_processing_type       varchar2
,p_entry_type            varchar2
,p_effective_date        date
)
return varchar2 is
  --
  processed       VARCHAR2(1) ;
  l_source_id     NUMBER      ; --Bug 3306112
  --
  -- Define how to determine if the entry is processed
  --
  cursor nonrecurring_entries is
  select  'Y'
  from    pay_run_results
  where   source_id       = p_element_entry_id
  and     status          <> 'U';
  --
  -- Bug 522510, recurring entries are considered as processed in the Date Earned period,
  -- not Date Paid period - where run results exists.
  --

  -- Bug No: 3603495 - Modified the following cursor - Performance Fix.
  cursor  recurring_entries is
  select  'Y'
  from    pay_run_results  RESULT
  where   result.source_id  = l_source_id  --Bug 3306112
  and     result.status     <> 'U'
  and     exists ( select 1
                   from   pay_assignment_actions   ASGT_ACTION
                      ,   pay_payroll_actions      PAY_ACTION
                      ,   per_time_periods         PERIOD
                   where  result.assignment_action_id    = asgt_action.assignment_action_id
                   and    asgt_action.payroll_action_id  = pay_action.payroll_action_id
                   and    pay_action.payroll_id          = period.payroll_id
                   and    pay_action.date_earned  between period.start_date and period.end_date
                   and    p_effective_date        between period.start_date and period.end_date
                 );
  --
begin

  processed        := 'N';
  l_source_id      :=  nvl(p_original_entry_id, p_element_entry_id); --Bug 3306112
  --
  if (p_entry_type in ('S','D','A','R') or p_processing_type = 'N')
  then
    --
    open nonrecurring_entries;
    fetch nonrecurring_entries into processed;
    close nonrecurring_entries;
    --
  else
    --
    open recurring_entries;
    fetch recurring_entries into processed;
    close recurring_entries;
    --
  end if;
  --
  return processed;
  --
end processed;
--
---------------------------------------------------------------------
-- Function get_accrual_plan_by_category
--
-- RETURNS: accrual_plan_id if successful, 0 otherwise
--
-- PURPOSE: To retrieve accrual plan id for designated category, copy
--          of hr_au_holidays equivalent except that when no accrual
--          plan is found return 0, this is to allow for casual employees
--          who do not have accrual plans and are not supposed to be paid
--          for such on termination.
--
-- IN:      assignment_id
--          effective_date
--          accrual plan category - annual leave or long service leave
-- OUT:
--
--
-- USES:  hr_utility
--        hr_au_holidays
--
function get_accrual_plan_by_category
(p_assignment_id    in    number
,p_effective_date   in    date
,p_plan_category    in    varchar2)
return number is
  --
  l_proc                 varchar2(72);
  l_accrual_plan_id      number ;
  l_dummy                number ;
  --
  cursor csr_get_accrual_plan_id
  (p_assignment_id    number
  ,p_effective_date   date
  ,p_plan_category    varchar2
  ) is
  select pap.accrual_plan_id
  from   pay_accrual_plans pap,
         pay_element_entries_f pee,
         pay_element_links_f pel,
         pay_element_types_f pet
  where  pee.assignment_id = p_assignment_id
  and    p_effective_date between pee.effective_start_date and pee.effective_end_date
  and    p_effective_date between pel.effective_start_date and pel.effective_end_date /*Added for 8482224*/
  and    p_effective_date between pet.effective_start_date and pet.effective_end_date /*Added for 8482224*/
  and    pel.element_link_id = pee.element_link_id
  and    pel.element_type_id = pet.element_type_id
  and    pap.accrual_plan_element_type_id = pet.element_type_id
  and    pap.accrual_category = p_plan_category ;
  --
begin
  l_proc                 := g_package||'get_accrual_plan_by_category' ;
  IF g_debug THEN
          hr_utility.set_location(' Entering::'||l_proc,5);
  END IF;
  open csr_get_accrual_plan_id(p_assignment_id, p_effective_date, p_plan_category) ;
  fetch csr_get_accrual_plan_id
  into l_accrual_plan_id;
  if csr_get_accrual_plan_id%notfound
  then
    close csr_get_accrual_plan_id;
    return 0;
  end if ;
  fetch csr_get_accrual_plan_id
  into l_dummy;
  if csr_get_accrual_plan_id%found
  then
    close csr_get_accrual_plan_id;
    IF g_debug THEN
                hr_utility.set_location('Enrolled in Multiple Plans '||l_proc,15);
        END IF;
            hr_utility.set_message(801, 'HR_AU_TOO_MANY_ACCRUAL_PLANS');
            hr_utility.raise_error;
  end if;
  close csr_get_accrual_plan_id;
  IF g_debug THEN
          hr_utility.set_location('Leaving:'||l_proc,20);
  END IF;
  return l_accrual_plan_id;
END get_accrual_plan_by_category;
--
------------------------------------------------------------
-- Function calculate_marginal_tax
--
-- RETURNS: marginal tax deduction for termination amounts
--
-- PURPOSE: used by formula function to calculate marginal tax deduction for termination amounts
--
-- IN:      p_date_earned - passed as a context
--          p_tax_variation_type - tax variation, percentage, marginal, fixed etc
--          p_tax_variation_amount - holds amount for tax variation type
--          p_gross_termination_amount - termination earnings amount used when performing marginal rate formula
--          p_average_pay - average earnings to be taxed
--          p_a_variable - variable used in marginal rate formula
--          p_b_variabel - variable used in marginal rate formula
--          p_pay_frequency - frequency of payroll used by formula to convert back to period amount
--          p_tax_instalment_deduction - used by formula to convert back to period amount
-- OUT:
--
--
-- USES:  hr_utility
--        hr_au_holidays
--
function calculate_marginal_tax
( p_date_earned                 in date
, p_tax_variation_type          in varchar2
, p_tax_variation_amount        in number
, p_gross_termination_amount    in number
, p_average_pay                 in number
, p_a_variable1                 in number
, p_b_variable1                 in number
, p_a_variable2                 in number
, p_b_variable2                 in number
, p_pay_freq                    in number
, p_tax_scale                   in number
) return number
is
  lc_tax_exempt         constant varchar2(3) := upper('e');      -- Exempt from Tax
  lc_tax_percentage     constant varchar2(3) := upper('p');     -- Tax calculated at a fixed percentage
  lc_tax_amount         constant varchar2(3) := upper('f');     -- Taxed a Fixed Amount
  lc_tax_marginal       constant varchar2(3) := upper('n');     -- Taxed at marginal ax-b
  --
  l_lump_tax                     number(15,2);
  l_procedure           constant varchar2(100) := g_package||'calculate_marginal_tax';
  l_average_term_pay            number(15,2);
  l_average_term_pay_tax        number(15,2);
  l_average_pay_tax             number(15,2);
  lv_average_pay                number(15,2);
  lv_average_term_pay_period    number(15,2);
  --
begin


  IF g_debug THEN
          hr_utility.set_location(l_procedure, 1);
          hr_utility.trace('p_tax_variation_type = '||p_tax_variation_type);
  END IF;
  --
  -- Which Tax method to use : Exempt, Fixed %, Fixed Amt or Marginal Rate
  --
  if upper( p_tax_variation_type ) = lc_tax_exempt
  then
    --
    -- Exempt from Tax
    --
    return 0;
    --
  elsif upper( p_tax_variation_type ) = lc_tax_percentage
  then
    --
    -- Fixed Percentage
    --
    --************************************************************************************
    return  p_gross_termination_amount * ( p_tax_variation_amount/100 );
    --
  elsif upper( p_tax_variation_type ) = lc_tax_amount
  then
    --
    -- Fixed Amount
    --
    --************************************************************************************
    return p_tax_variation_amount;
    --
  elsif upper( p_tax_variation_type ) = lc_tax_marginal
  then
    --
    -- Use Marginal Calculation ax-b
    -- The amount used here is assumed to be a weekly amount
    -- so it must be converted back to a period amount
    --
  IF g_debug THEN
        hr_utility.trace('p_a_variable1 = '||to_char(p_a_variable1));
    hr_utility.trace('p_b_variable1 = '||to_char(p_b_variable1));
hr_utility.trace('average pay = '||to_char(p_average_pay));
  END IF;
    --
    -- Calculate the average termination pay
    --
    lv_average_term_pay_period := p_gross_termination_amount/p_pay_freq;

    lv_average_pay := pay_au_paye_ff.convert_to_week(p_pay_freq,p_average_pay);
        IF g_debug THEN

                hr_utility.trace('lv_average_term_pay_period = '||to_char(lv_average_term_pay_period));
                hr_utility.trace('average term pay = '||to_char(lv_average_pay));
    END IF;
        --
    -- Calculate tax on the average pay + average term pay
    --
    l_average_pay_tax := (p_a_variable1 * pay_au_paye_ff.convert_to_week(p_pay_freq,(p_average_pay + lv_average_term_pay_period))) - p_b_variable1;
   if p_tax_scale <> 4
    then
      l_average_pay_tax := round(l_average_pay_tax, 0);
    else
      l_average_pay_tax := trunc(l_average_pay_tax);
    end if;
  IF g_debug THEN
    hr_utility.trace('average pay tax = '||to_char(l_average_pay_tax));
  END IF;
        --
    -- Calculate tax on the average pay
    --
  IF g_debug THEN
    hr_utility.trace('p_a_variable2 = '||to_char(p_a_variable2));
    hr_utility.trace('p_b_variable2 = '||to_char(p_b_variable2));
 END IF;

    l_average_term_pay_tax := (p_a_variable2 * lv_average_pay) - p_b_variable2;
    if p_tax_scale <> 4
    then
      l_average_term_pay_tax := round(l_average_term_pay_tax, 0);
    else
      l_average_term_pay_tax := trunc(l_average_term_pay_tax);
    end if;
    --
    IF g_debug THEN
                hr_utility.trace('average term tax = '||to_char(l_average_term_pay_tax));
        END IF;
    --
    -- Total tax payable equals the difference between the tax amounts multiplied by 52
    --
       l_lump_tax := (pay_au_paye_ff.convert_to_period_amt(p_pay_freq,l_average_pay_tax,p_tax_scale) - pay_au_paye_ff.convert_to_period_amt(p_pay_freq,l_average_term_pay_tax,p_tax_scale)) * p_pay_freq;

    --

    --
    IF g_debug THEN
                hr_utility.trace('l_lump_tax = '||to_char(l_lump_tax));
        END IF;
    return  l_lump_tax;
    --
  else
    --
    -- Invalid Tax Type
    --
    raise_application_error ( -20000, 'PAY Error : HR_AU_TAX_VAR_NOT_VALID' );
    --
  end if;
  --
end calculate_marginal_tax;
  --
  ---------------------------------------------------
  --
  -- Function max_etp_tax_free
  --
  -- Calculates the maximum allowable amount of the
  -- ETP payment components which can be free of tax
  --
  -- RETURNS: maximum tax free amount
  --
  -- USES:    hr_utility
  --
  function max_etp_tax_free
  (p_years_of_service           in  number
  ,p_lump_d_tax_free            in  number
  ,p_lump_d_service_increment   in  number
  )
  return number is
    --
    l_procedure     constant varchar2(100) := g_package||'max_etp_tax_free';
    --
  begin
    --
    IF g_debug THEN
                hr_utility.set_location(l_procedure, 1);
        END IF;
    return p_lump_d_tax_free + p_lump_d_service_increment * p_years_of_service;
    --
  end max_etp_tax_free;
  --
  ---------------------------------------------------
  --
  -- Function check_rollover
  --
  -- Checks to see if the user has entered a rollover
  -- amount which will exceed the maximum allowable
  --
  -- RETURNS: 1 if amount elected to rollover is within the maximum allowed
  --          0 if amount exceeds limit
  --
  -- IN:      p_rollover_amount - amount user has elected to roll into a super fund
  --          p_maximum_rollover - the maximum allowable amount a user may elect to roll into a super fund
  /* Start 8769345 */
  -- IN:      p_etp_component - This input value is used to set 'Taxable' or 'Tax Free' text
  --                            in the Super Rollover message.
  /* End 8769345 */
  --
  -- OUT:     p_message - error message containing token for maximum amount to roll over
  --
  -- USES:    hr_utility
  --          fnd_message
  --
  function check_rollover
  (p_rollover_amount            in   number
  ,p_maximum_rollover           in   number
  ,p_message                    out  NOCOPY varchar2
  ,p_etp_component              in   varchar2 default 'Taxable'
  )
  return number is
    l_procedure         constant varchar2(100) := g_package||'check_rollover';
    l_message           varchar2(500);
  begin

    IF g_debug THEN
                hr_utility.set_location(l_procedure,1);
            hr_utility.trace('p_rollover_amount '||to_char(p_rollover_amount));
    END IF;
        if p_rollover_amount > p_maximum_rollover
    then
      IF g_debug THEN
                  hr_utility.trace('rollover exceeded - maximum '||to_char(p_maximum_rollover));
          END IF;
      fnd_message.set_name('PAY','HR_AU_SUPER_ROLL_NOT_VALID');
      fnd_message.set_token('rollover_amount', p_maximum_rollover);
      fnd_message.set_token('etp_component', p_etp_component);
      p_message := fnd_message.get;
      l_message := p_message;
      IF g_debug THEN
                  hr_utility.trace('message = '||l_message);
          END IF;
      return 0;
    else
      return 1;
    end if;
  end check_rollover;
  --
  --------------------------------------------------
  --
  -- Function etp_prepost_ratios
  --
  -- Calculates the pre 01 July 1983 ratio for calculation of ETP
  -- and the post 30 Jun 1983 ratio for calculation ETP
  --
  -- RETURNS: 1 if calculation was successful
  --          0 otherwise
  --
  -- IN:      p_assignment_id - assignment
  --          p_hire_date - date employee started work
  --          p_termination_date - date employee ends employment
  --
  -- OUT:     p_pre01jul1983_ratio - ratio to use when calculating the pre 01 July 1983 portion of ETP
  --          p_post30jun1983_ratio - ratio to use when calculating the post 30 June 1983 portion of ETP
  --
  -- USES:    hr_utility
  --          fffunc
  --          hr_au_holidays
  --
  function etp_prepost_ratios
  (p_assignment_id              in  number
  ,p_hire_date                  in  date
  ,p_termination_date           in  date
  ,p_term_form_called           in  varchar2 -- Bug#2819479
  ,p_pre01jul1983_days          out NOCOPY number
  ,p_post30jun1983_days         out NOCOPY number
  ,p_pre01jul1983_ratio         out NOCOPY number
  ,p_post30jun1983_ratio        out NOCOPY number
  ,p_etp_service_date           out NOCOPY date     /* Bug# 2984390 */
  ,p_le_etp_service_date        out NOCOPY date     /* Bug 4177679 */
  )
  /*  Bug# 2984390 Added new parameter p_etp_service_date, which is used for payment summary reporting purpose.
      If ETP service date is entered then return the ETP service date else return Hiredate */

  return number is

    /* Bug#2819479 - ETP Pre/Post enhancment */
    /* Get the details of the ETP Continuous Service Date and Pre/Post Days
    if Entered for the calculation. These details if provided by the user
    will be used in the ETP payments calculation. */

    cursor c_get_etp_information(c_assignment_id per_all_assignments_f.assignment_id%TYPE)
    is
    select  peev.screen_entry_value,
            peev1.screen_entry_value,
            to_date(peev2.screen_entry_value,'YYYY/MM/DD HH24:MI:SS')
    from    pay_element_types_f pet,
            pay_element_entries_f peef,
            pay_element_links_f pel,
            pay_input_values_f piv,
            pay_input_values_f piv1,
            pay_input_values_f piv2,
            pay_element_entry_values_f peev,
            pay_element_entry_values_f peev1,
            pay_element_entry_values_f peev2
    where   peef.assignment_id = c_assignment_id
    and     pet.element_name = 'ETP on Termination'
    and     pet.legislation_code = 'AU'
    and     pet.element_type_id = pel.element_type_id
    and     pel.element_link_id = peef.element_link_id
    and     peef.element_entry_id = peev.element_entry_id
    and     peef.element_entry_id = peev1.element_entry_id
    and     peef.element_entry_id = peev2.element_entry_id
    and     pet.element_type_id = piv.element_type_id
    and     pet.element_type_id = piv1.element_type_id
    and     pet.element_type_id = piv2.element_type_id
    and     peev.input_value_id = piv.input_value_id
    and     peev1.input_value_id = piv1.input_value_id
    and     peev2.input_value_id = piv2.input_value_id
    and     piv.name = 'Pre 1983 Days'
    and     piv1.name = 'Post 1983 Days'
    and     piv2.name = 'ETP Service Date';

    l_procedure     constant varchar2(100) := g_package||'etp_prepost_portions';
    l_pre_date      date ;
    l_post_date     date ;
    l_days_worked_pre           number(9,2);
    l_days_worked_post          number(9,2);
    l_days_worked_total         number(9,2);
    l_days_suspended_pre        number(9,2);
    l_days_suspended_post       number(9,2);
    l_days_suspended_total      number(9,2);
    l_actual_pre                number(9,2);
    l_actual_post               number(9,2);
    l_actual_total              number(9,2);
    l_calculation_date          date;
    l_term_form_called          varchar2(10);
    l_calc_date_entered         varchar2(10); /* Bug 4177679 */

  begin

    l_pre_date      := to_date('01-07-1983','DD-MM-YYYY');
    l_post_date     := to_date('30-06-1983','DD-MM-YYYY');
    l_term_form_called := nvl(p_term_form_called , 'N');
    p_le_etp_service_date :=null; /* bug 4177679 */
    l_calc_date_entered := 'Y';  /* Bug 4177679 */

    IF g_debug THEN
            hr_utility.set_location(l_procedure,1);
            hr_utility.trace('p_assignment_id :'||p_assignment_id);
            hr_utility.trace('p_hire_date :'||p_hire_date);
    END IF;

    open c_get_etp_information(p_assignment_id);
    fetch c_get_etp_information
     into l_actual_pre, l_actual_post, l_calculation_date;
    IF c_get_etp_information%FOUND then
      close c_get_etp_information;
      IF g_debug THEN
                  hr_utility.trace('l_actual_pre :'||l_actual_pre);
              hr_utility.trace('l_actual_post :'||l_actual_post);
              hr_utility.trace('l_calculation_date :'||l_calculation_date);
      END IF;
          l_actual_total := l_actual_pre + l_actual_post;
    END IF;
    IF g_debug THEN
            hr_utility.trace('l_calculation_date :'||l_calculation_date);
        END IF;

    IF l_actual_pre is not null and l_actual_post is not null
       and l_term_form_called = 'N' then

    -- Use the pre/post days for the calculation of the pre/post ratios.
      IF g_debug THEN
                  hr_utility.set_location(l_procedure, 30);
      END IF;
          p_pre01jul1983_days   := l_actual_pre;
      p_post30jun1983_days  := l_actual_post;
      IF (p_pre01jul1983_days = 0 and p_post30jun1983_days = 0) then
          p_pre01jul1983_ratio := 0;   /* Bug: 2984390 */
          p_post30jun1983_ratio := 0;
      ELSE
          p_pre01jul1983_ratio  := l_actual_pre/l_actual_total;
          p_post30jun1983_ratio := 1 - p_pre01jul1983_ratio;
      END IF;
      IF l_calculation_date is null then  /* Bug# 2984390 */
              p_etp_service_date := p_hire_date;
              p_le_etp_service_date := null;   /* Bug 4177679 */
      ELSE
              p_etp_service_date := l_calculation_date;
              p_le_etp_service_date := l_calculation_date;   /* Bug 4177679 */
      END IF;
          IF g_debug THEN
                  hr_utility.trace('p_pre01jul1983_days:'||p_pre01jul1983_days);
              hr_utility.trace('p_post30jun1983_days:'||p_post30jun1983_days);
              hr_utility.trace('p_pre01jul1983_ratio:'||p_pre01jul1983_ratio);
              hr_utility.trace('p_post30jun1983_ratio:'||p_post30jun1983_ratio);
      END IF;
      return 1;

    END IF;

    IF l_calculation_date is null and l_term_form_called = 'N' then

    -- Use the Hire Date for the calculation of Pre/Post days
    -- Use the Hire Date of the employee for the pre/post ratio calculation.
     l_calc_date_entered :='N' ; /* Bug 4177679 */
       l_calculation_date := p_hire_date;
       p_etp_service_date := l_calculation_date;  /* Bug# 2984390 */
       p_le_etp_service_date := null;   /* Bug 4177679 */

       IF g_debug THEN
                   hr_utility.trace('p_hire_date : '||p_hire_date);
           END IF;
    END IF;

    IF l_term_form_called = 'Y' and p_hire_date is not null then
    -- Use the Hire Date for the calculation of the Pre/Post days
    -- This Hire Date can have either ETP Service Date entered at Form or
    -- Original Hire Date of the employee
       l_calculation_date := p_hire_date;
       p_etp_service_date := l_calculation_date;  /* Bug# 2984390 */
        p_le_etp_service_date := null;   /* Bug 4177679 */
    END IF;
  IF g_debug THEN
    hr_utility.trace('l_calculation_date :'||l_calculation_date);
  END IF;
    /* End of  Bug#2819479 */

    --
    -- Did the employee start after or on 01 July 1983
    --
    if l_calculation_date >= l_pre_date
    then
      IF g_debug THEN
                  hr_utility.set_location(l_procedure, 15);
         END IF;
      p_pre01jul1983_days   := 0;
      p_pre01jul1983_ratio  := 0;
      p_post30jun1983_ratio := 1;
      l_days_worked_post    := fffunc.days_between(p_termination_date, l_calculation_date);
      l_days_suspended_post := hr_au_holidays.days_suspended(p_assignment_id, l_calculation_date, p_termination_date);
      p_post30jun1983_days  := l_days_worked_post - l_days_suspended_post;
      p_etp_service_date := l_calculation_date;  /* Bug# 2984390 */
       /* Bug 4177679 Only if the calculation date is entered then the p_le_etp_service_date will be passed*/
      if l_calc_date_entered = 'Y' then
        p_le_etp_service_date := l_calculation_date;
      end if;
      return 1;
    --
    -- Did the employee termination before 30 June 1983
    --
    elsif p_termination_date <= l_post_date
    then
      IF g_debug THEN
                  hr_utility.set_location(l_procedure, 16);
      END IF;
      p_post30jun1983_days  := 0;
      p_post30jun1983_ratio := 0;
      p_pre01jul1983_ratio  := 1;
      l_days_worked_pre     := fffunc.days_between(p_termination_date, l_calculation_date);
      l_days_suspended_pre  := hr_au_holidays.days_suspended(p_assignment_id, l_calculation_date, p_termination_date);
      p_pre01jul1983_days   := l_days_worked_pre - l_days_suspended_pre;
      p_etp_service_date := l_calculation_date;  /* Bug# 2984390 */
       /* Bug 4177679 Only if the calculation date is entered then the p_le_etp_service_date will be passed*/
      if l_calc_date_entered = 'Y' then
        p_le_etp_service_date := l_calculation_date;
      end if;
      return 1;
    else
      IF g_debug THEN
                  hr_utility.set_location(l_procedure, 20);
         END IF;
      --
      -- Calculate the number of days worked for pre, post and total
      --
      l_days_worked_pre   := fffunc.days_between(l_pre_date, l_calculation_date);
      l_days_worked_post  := fffunc.days_between(p_termination_date, l_post_date);
      l_days_worked_total := fffunc.days_between(p_termination_date, l_calculation_date) + 1;
      --
      -- How many of these days were suspended without pay for pre, post and total
      --
      l_days_suspended_pre   := hr_au_holidays.days_suspended(p_assignment_id, l_calculation_date, l_pre_date);
      l_days_suspended_post  := hr_au_holidays.days_suspended(p_assignment_id, l_post_date, p_termination_date);
      l_days_suspended_total := hr_au_holidays.days_suspended(p_assignment_id, l_calculation_date, p_termination_date);
      --
      l_actual_pre   := l_days_worked_pre - l_days_suspended_pre;
      l_actual_post  := l_days_worked_post - l_days_suspended_post;
      l_actual_total := l_days_worked_total - l_days_suspended_total;
      --
      if (l_actual_pre < 0) or (l_actual_post < 0) or (l_actual_total < 0)
      then
        IF g_debug THEN
                        hr_utility.set_location(l_procedure, 21);
                END IF;
        return 0;
      end if;
      --

      p_pre01jul1983_days := l_actual_pre;
      p_post30jun1983_days := l_actual_post;
      p_pre01jul1983_ratio := l_actual_pre/l_actual_total;
      p_post30jun1983_ratio := 1 - p_pre01jul1983_ratio;
      p_etp_service_date := l_calculation_date;   /* Bug# 2984390 */
       /* Bug 4177679 Only if the calculation date is entered then the p_le_etp_service_date will be passed*/
      if l_calc_date_entered = 'Y' then
        p_le_etp_service_date := l_calculation_date;
      end if;

      IF g_debug THEN
                  hr_utility.trace('p_pre01jul1983_days:'||p_pre01jul1983_days);
                  hr_utility.trace('p_post30jun1983_days:'||p_post30jun1983_days);
                  hr_utility.trace('p_pre01jul1983_ratio:'||p_pre01jul1983_ratio);
                  hr_utility.trace('p_post30jun1983_ratio:'||p_post30jun1983_ratio);
          END IF;
      return 1;

    END IF;
  end etp_prepost_ratios;

  --
  --------------------------------------------------
  --
  -- Function term_lsl_eligibility_years
  --
  -- gets the number of years a person must have worked
  -- before they become eiligible to recieve payment for
  -- long service leave upon termination of employment
  --
  -- RETURNS: 1 if successful, 0 otherwise
  --
  -- IN:      p_date_earned - context passed in form payroll run
  --          p_accrual_plan_id - id of the particular long service leave accrual plan
  --
  -- OUT:     p_eligibility_years - number of years until eligible
  --
  -- USES:    hr_utility
  --
  --
  function term_lsl_eligibility_years
  (p_date_earned                  in date
  ,p_accrual_plan_id              in number
  ,p_eligibility_years            out NOCOPY number
  )
  return number is
    --
    -- Must limit the element to one which is of LSL classification
    -- as we are getting a value from the developer flex on the element
    -- which uses the element classification as a context
    --
    cursor csr_get_years
    (p_effective_date             date
    ,p_accrual_plan_id            number
    ) is
    select  to_number(hrl.description)
    from    pay_element_types_f                petf
    ,       pay_input_values_f                 pivf
    ,       pay_accrual_plans                  pap
    ,       hr_lookups                         hrl
    ,       pay_element_classifications        pec
    where   pap.accrual_plan_id                = p_accrual_plan_id
    and     pivf.input_value_id                = pap.pto_input_value_id
    and     petf.element_type_id               = pivf.element_type_id
    and     petf.classification_id             = pec.classification_id
    and     pec.classification_name            = 'Long Service Leave'
    and     hrl.lookup_type (+)                = 'AU_TERM_LSL_ELIGIBILITY_YEARS'
    and     hrl.lookup_code (+)                = petf.element_information1
    and     hrl.enabled_flag  (+)              = 'Y'
    and     p_effective_date                   between petf.effective_start_date and petf.effective_end_date
    and     p_effective_date                   between pivf.effective_start_date and pivf.effective_end_date;
    --
    l_years number;
    l_procedure     constant varchar2(100) := g_package||'term_lsl_eligibility_years';
    --
  begin

    IF g_debug THEN
                hr_utility.set_location(l_procedure, 10);
        END IF;
    open csr_get_years(p_date_earned, p_accrual_plan_id);
    fetch csr_get_years
    into  l_years;
    if csr_get_years%notfound
    then
      close csr_get_years;
      p_eligibility_years := 999;
      return 0;
    end if;
    close csr_get_years;
    --
    p_eligibility_years := l_years;
    IF g_debug THEN
                hr_utility.trace('LSL eligibility years : '||to_char(l_years));
        END IF;
    return 1;
    --
  end term_lsl_eligibility_years;
  --


  -- Bug#3263690 - NGE calculation Enhancement.
  --  Function to calculate the Normal Gross Earnings for a given assignment
  --
  FUNCTION CALCULATE_TERM_ASG_NGE
  ( p_assignment_id     in      per_all_assignments_f.assignment_id%TYPE,
    p_business_group_id in      hr_all_organization_units.organization_id%TYPE,
    p_date_earned       in      date,
    p_tax_unit_id       in      hr_all_organization_units.organization_id%TYPE,
    p_assignment_action_id IN number, /*Bug 4538463*/
    p_payroll_id IN NUMBER, /*Bug 4538463*/
    p_termination_date  in      date,
    p_hire_date         in      date,
    p_period_start_date in      date,
    p_period_end_date   in      date,
    p_case              out     NOCOPY varchar2,
    p_earnings_standard out     NOCOPY number, /*Bug 4474896*/
    p_pre_tax_spread    out     NOCOPY number, /*Bug 4474896*/
    p_pre_tax_fixed     out     NOCOPY number,  /*Bug 4474896*/
    p_pre_tax_prog      out     NOCOPY number,  /*Bug 4474896*/
    p_paid_periods      out     NOCOPY number, /*Bug 4474896*/
    p_use_tax_flag      IN      VARCHAR2 --2610141
  )
  return NUMBER is
  -----------------------------------------------------------------------
  -- Variables
  -----------------------------------------------------------------------
  g_debug       boolean;
  l_procedure   varchar2(30);

  -- This year Financial Start and End Dates
  --
  l_fin_start_date date;
  l_fin_end_date date;

  -- Last Year Financial Start and End Dates
  --
  l_prev_yr_fin_start_date      date ;
  l_prev_yr_fin_end_date        date ;


  -- Variable to store the maximum previous year assignment action id and its corresponding
  -- tax_unit_id (legal Employer).
  l_asg_act_id          pay_assignment_actions.assignment_action_id%TYPE;
  l_tax_unit_id         pay_assignment_actions.tax_unit_id%TYPE;


  -- Total Earnings variable
  --
  l_total_earnings      number;

  -- Loop Counter variable
  --
  i number;


  -----------------------------------------------------------------------
  -- Cursor      : c_get_prev_year_max_asg_act_id
  -- Description : To get the Previous Year Maximum Assignment Action ID
  --               for a given Assignment_id in a Financial Year.
  --               If there exists any LE changes, then it gets the max
  --               Assignment Action ID for the corresponding LE.
  -----------------------------------------------------------------------
  CURSOR c_get_prev_year_max_asg_act_id
  ( c_assignment_id     in per_all_assignments_f.assignment_id%TYPE,
    c_business_group_id in hr_all_organization_units.organization_id%TYPE,
    c_fin_start_date    in date,
    c_fin_end_date      in date)
  IS
  SELECT paa.assignment_action_id, paa.tax_unit_id, ppa.payroll_id
  FROM  pay_assignment_actions paa
       ,pay_payroll_actions ppa
  WHERE paa.assignment_id = c_assignment_id
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppa.business_group_id = c_business_group_id
  AND   paa.action_sequence in
               (
                SELECT MAX(paa.action_sequence)
                  FROM  pay_assignment_actions paa,
                        pay_payroll_actions ppa,
                        per_all_assignments_f paaf
                  WHERE ppa.business_group_id = c_business_group_id
                  AND paaf.assignment_id = c_assignment_id
                  AND paa.assignment_id = paaf.assignment_id
                  AND ppa.payroll_action_id = paa.payroll_action_id
                  AND ppa.action_type in ('Q','R','B','I','V') --2610141
                  AND ppa.effective_date between c_fin_start_date AND c_fin_end_date
        AND paa.action_status = 'C'
                  AND paa.tax_unit_id = p_tax_unit_id --2610141
                )
   ORDER BY date_earned desc;

/*Bug 2610141 - Cursor introduced to give the maxmimum assignment action id of previous legal employer*/
  CURSOR c_get_pre_le_max_asg_act_id
  ( c_assignment_id     in per_all_assignments_f.assignment_id%TYPE,
    c_business_group_id in hr_all_organization_units.organization_id%TYPE,
    c_fin_start_date    in date,
    c_fin_end_date      in date)
  IS
  SELECT paa.assignment_action_id, paa.tax_unit_id, ppa.payroll_id, ppa.effective_date
  FROM  pay_assignment_actions paa
       ,pay_payroll_actions ppa
  WHERE paa.assignment_id = c_assignment_id
  and   ppa.payroll_action_id = paa.payroll_action_id
  and   ppa.business_group_id = c_business_group_id
  AND   paa.action_sequence in
               (
                SELECT MAX(paa.action_sequence)
                  FROM  pay_assignment_actions paa,
                        pay_payroll_actions ppa,
                        per_all_assignments_f paaf
                  WHERE ppa.business_group_id = c_business_group_id
                  AND paaf.assignment_id = c_assignment_id
                  AND paa.assignment_id = paaf.assignment_id
                  AND ppa.payroll_action_id = paa.payroll_action_id
                  AND ppa.action_type in ('Q','R','B','I','V')
        AND paa.action_status = 'C'
                  AND ppa.effective_date between c_fin_start_date AND c_fin_end_date
                )
   ORDER BY date_earned desc;

  ---
  -----------------------------------------------------------------------
    -- Cursor      : c_get_periods
    -- Description : To get the Previous Year number of periods to the
    --                   given Assignment_id in previous Financial Year and Tax Unit
    -- Assumption  : No changes to the Payroll during the Financial Year.
  -----------------------------------------------------------------------

/*Bug 4474896 - Cursor c_get_paid_periods changed to c_get_periods and logic for the cursor modified
                to count number of pay periods between greatest of (employee's hire date, financial year start date,
                Legal Employer start date) and current period end date*/

  cursor c_get_periods
  (c_tax_unit_id                in hr_all_organization_units.organization_id%TYPE,
   c_payroll_id                 in pay_payrolls_f.payroll_id%TYPE,
   c_start_date         in date,
   c_end_date   in date)
  is
  select count(DISTINCT ptp.time_period_id)
        from per_time_periods ptp
        where exists (select 'EXISTS' from
             per_assignments_f   paf,
             hr_soft_coding_keyflex hsck
       where paf.assignment_id = p_assignment_id
        and  paf.SOFT_CODING_KEYFLEX_ID = hsck.soft_coding_keyflex_id
        and  hsck.segment1 = c_tax_unit_id
        AND  paf.effective_start_date <= c_end_date
        AND  paf.effective_end_date >= c_start_date
        AND  paf.effective_start_date <= ptp.end_date
        AND  paf.effective_end_date >= ptp.start_date)
        AND  ptp.payroll_id = c_payroll_id
        AND  ptp.start_date <= c_end_date
        AND  ptp.end_date >= c_start_date;


/*Bug 4538463 - Two new cursors introduced*/

  CURSOR c_get_payroll_effective_date
  IS
  SELECT ppa.effective_date
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa
  WHERE paa.assignment_action_id  = p_assignment_action_id
  AND ppa.payroll_action_id = paa.payroll_action_id;

  CURSOR c_check_payroll_run (c_assignment_id           in per_all_assignments_f.assignment_id%TYPE,
   c_business_group_id          in hr_all_organization_units.organization_id%TYPE,
   c_start_date         in date,
   c_end_date   in date)
  IS
  SELECT count(paa.assignment_action_id)
  FROM pay_assignment_actions paa,
       pay_payroll_actions ppa,
            per_assignments_f paf
  WHERE ppa.effective_date BETWEEN c_start_date AND c_end_date
  AND   ppa.business_group_id = c_business_group_id
  AND   ppa.payroll_action_id = paa.payroll_action_id
  AND   paa.assignment_id = c_assignment_id
  AND   paa.assignment_id = paf.assignment_id
  AND   ppa.effective_date between paf.effective_start_date and paf.effective_end_date
  AND   paa.action_status = 'C'
  AND   paa.source_action_id IS NULL /*Bug 4418107 - This join added to only pick master assignment action id*/
  AND   ppa.action_type IN ('Q','R','I','B'); /*Bug 4474896 - Introduced action_types 'B' and 'I'*/

  c_ytd_input_table c_get_ytd_def_bal_ids%rowtype;
  l_use_le_balances varchar2(50);
  l_db_item_suffix pay_balance_dimensions.database_item_suffix%type;
  l_payroll_id number;
  l_pay_eff_date DATE;
  l_flag number;
  l_eff_date DATE; /*Bug 4538463*/
  l_counter NUMBER; /*Bug 4538463*/
  l_leave_loading number := 0;  /*bug8725341*/

  BEGIN

  l_procedure                   := 'calculate_term_asg_nge';
  g_ytd_def_bals_populated      := FALSE;
  p_earnings_standard           := 0; /*Bug 4474896*/
  p_pre_tax_spread              := 0; /*Bug 4474896*/
  p_pre_tax_fixed               := 0; /*Bug 4474896*/
  p_pre_tax_prog                := 0; /*Bug 4474896*/
  i                             := 1;
  g_debug                       := hr_utility.debug_enabled;
  l_flag := -1;

  OPEN c_get_payroll_effective_date; /*Bug 4538463*/
  FETCH c_get_payroll_effective_date INTO l_eff_date; /*Bug 4538463*/
  CLOSE c_get_payroll_effective_date; /*Bug 4538463*/

  IF g_debug THEN
    hr_utility.set_location('    '||l_procedure,                10);
    hr_utility.set_location('     p_assignment_id :             ' ||p_assignment_id,10);
    hr_utility.set_location('     p_business_group_id           ' ||p_business_group_id,10);
    hr_utility.set_location('     p_date_earned                 ' ||p_date_earned,10);
    hr_utility.set_location('     p_tax_unit_id                 ' ||p_tax_unit_id,10);
    hr_utility.set_location('     p_termination_date            ' ||p_termination_date,10);
    hr_utility.set_location('     p_hire_date                   ' ||p_hire_date,10);
    hr_utility.set_location('     p_period_start_date           ' ||p_period_start_date,10);
    hr_utility.set_location('     p_period_end_date             ' ||p_period_end_date,10);
    hr_utility.set_location('     p_case                        ' ||p_case,10);
    hr_utility.set_location('     to_char(p_date_earned,ddmm)   ' ||to_char(p_date_earned,'ddmm'),10);
  END IF;

  -- Find the Financial Year Start and End Dates
  /*Bug 4538463 - Modified logic to get financial year start date and end dates
                  on the basis of the payroll effective date*/

  IF MONTHS_BETWEEN(l_eff_date,TRUNC(l_eff_date,'Y')) < 6 THEN
     l_fin_start_date := to_date('01-07-'||to_char(add_months(trunc(l_eff_date,'Y'),-9),'YYYY'),'DD-MM-YYYY');
     l_fin_end_date   := to_date('30-06-'||to_char(add_months(trunc(l_eff_date,'Y'),+3),'YYYY'),'DD-MM-YYYY');
     -- For Previous Fin Year
     l_prev_yr_fin_start_date := to_date('01-07-'||to_char(add_months(trunc(l_eff_date,'Y'),-9-12),'YYYY'),'DD-MM-YYYY');
     l_prev_yr_fin_end_date   := to_date('30-06-'||to_char(add_months(trunc(l_eff_date,'Y'),+3-12),'YYYY'),'DD-MM-YYYY');
  ELSE
     l_fin_start_date := to_date('01-JUL-'||to_char(l_eff_date,'YYYY'),'DD-MM-YYYY');
     l_fin_end_date   := to_date('30-JUN-'||to_char(add_months(l_eff_date,12),'YYYY'),'DD-MM-YYYY');
     -- For Previous Fin Year
     l_prev_yr_fin_start_date := to_date('01-07-'||to_char(add_months(l_eff_date,-12),'YYYY'),'DD-MM-YYYY');
     l_prev_yr_fin_end_date   := to_date('30-06-'||to_char(trunc(l_eff_date,'Y'),'YYYY'),'DD-MM-YYYY');

  END IF;

  IF p_hire_date >= p_period_start_date and p_hire_date <= p_period_end_date and
     p_termination_date >= p_period_start_date and p_termination_date <= p_period_end_date THEN

  /* Nothing has to be done
     Return the flag with USE_PERIOD_EARNINGS */
     p_case := 'USE_PERIOD_EARNINGS';
     return 100;
  END IF;

  -- Use the cursor to check whether any periods in this Financial Year got processed
  -- before this RUN
  IF g_debug THEN
    hr_utility.set_location('l_fin_start_date: '|| l_fin_start_date, 20);
    hr_utility.set_location('l_fin_end_date: '|| l_fin_end_date, 20);

    hr_utility.set_location('l_prev_yr_fin_start_date: '|| l_prev_yr_fin_start_date, 20);
    hr_utility.set_location('l_prev_yr_fin_end_date: '|| l_prev_yr_fin_end_date, 20);
  END IF;

/*Bug 4538463 - Use the cursor below to check if this is the first run for the assignment in the
                current financial year*/
  OPEN c_check_payroll_run(p_assignment_id,
            p_business_group_id,
             l_fin_start_date,
             p_period_start_date - 1); /*Bug 5388657 changed l_eff_date to  p_period_start_date - 1 */
  FETCH c_check_payroll_run INTO l_counter;
  CLOSE c_check_payroll_run;

/* Bug 2610141 - Get the Maximum assignment action id for the Previous Financial Year for the current
   Legal Employer or the maximum assignment action id for previous legal employer for the
   current year*/
IF l_counter = 0 OR p_use_tax_flag = 'N' THEN
     OPEN c_get_prev_year_max_asg_act_id(p_assignment_id, p_business_group_id, l_prev_yr_fin_start_date, l_prev_yr_fin_end_date);
     FETCH c_get_prev_year_max_asg_act_id into l_asg_act_id, l_tax_unit_id, l_payroll_id;
     CLOSE c_get_prev_year_max_asg_act_id;
     IF nvl(l_asg_act_id,-99999) <> -99999 THEN /*Bug 4538463*/
        l_flag := 1; /* Flag is set to 1 when we take YTD earnings for previous year for the current legal employer*/
     END IF;
     hr_utility.trace('Inside 1');
ELSE
     OPEN c_get_pre_le_max_asg_act_id(p_assignment_id, p_business_group_id, l_fin_start_date, l_eff_date);
     FETCH c_get_pre_le_max_asg_act_id into l_asg_act_id, l_tax_unit_id, l_payroll_id, l_pay_eff_date;
     CLOSE c_get_pre_le_max_asg_act_id;
     IF nvl(l_asg_act_id,-99999) <> -99999 THEN /*Bug 4538463*/
        l_flag := 2; /* Flag is set to 2 when we take YTD earnings for current year for the previous legal employer*/
     END IF;
     hr_utility.trace('Inside 2');
END IF;

IF l_flag = -1 THEN
     OPEN c_get_pre_le_max_asg_act_id(p_assignment_id, p_business_group_id, l_prev_yr_fin_start_date, l_prev_yr_fin_end_date);
     FETCH c_get_pre_le_max_asg_act_id into l_asg_act_id, l_tax_unit_id, l_payroll_id, l_pay_eff_date;
     CLOSE c_get_pre_le_max_asg_act_id;
     l_flag := 3; /* Bug 4538463 - Flag is set to 3 when we take YTD earnings for previous year for the legal employer effective on
                     on the last run of year*/
     hr_utility.trace('Inside 3');
END IF;

     IF g_debug THEN
        hr_utility.set_location('l_asg_act_id: '|| l_asg_act_id, 30);
        hr_utility.set_location('g_context_table(1).tax_unit_id: '|| l_tax_unit_id, 30);
        hr_utility.set_location('l_payroll_id: '||l_payroll_id, 30);
        hr_utility.set_location('p_tax_unit_id :'||p_tax_unit_id, 30);
     END IF;


     IF nvl(l_asg_act_id,-99999) = -99999 THEN
     /* There is no payroll actions exist in the previous financial year and also there is no
        actions present in the current year. This means the customer go live and this is the
        first payroll action
        For this case, need to populate message to the user in order to process the Termination
        Payments Manually. For this set the p_case to 'POPULATE_MSG'
        Average_Earnings will not be calculated.
     */
        p_case := 'POPULATE_MSG';
        IF g_debug THEN
           hr_utility.set_location('p_case: '|| p_case, 40);
        END IF;
        RETURN 110;

     ELSE

       /* Bug 2610141 - Get the Total Number of Paid Periods for the Previous Financial Year for the current
          Legal Employer or the number of paid periods of the previous legal employer for the
          current year*/
       IF l_flag = 1 OR l_flag = 3 THEN
            OPEN c_get_periods
           (l_tax_unit_id,
            l_payroll_id,
            l_prev_yr_fin_start_date,
                 l_prev_yr_fin_end_date);
            FETCH c_get_periods INTO p_paid_periods;
            CLOSE c_get_periods;
       ELSE
            OPEN c_get_periods
           (l_tax_unit_id,
            l_payroll_id,
            l_fin_start_date,
                 p_period_start_date - 1);
             FETCH c_get_periods INTO p_paid_periods;
             CLOSE c_get_periods;
       END IF;



       IF g_debug THEN
           hr_utility.set_location('p_paid_periods: '|| p_paid_periods, 50);
       END IF;


       IF NOT g_ytd_def_bals_populated THEN
       -- Fetch the defined balance ids for the required balances
       --

       /*bug 2610141*/
        IF p_use_tax_flag = 'Y' THEN
                l_db_item_suffix := '_ASG_LE_YTD';
        ELSE
                l_db_item_suffix := '_ASG_YTD';
        END IF ;

        OPEN c_get_ytd_def_bal_ids(l_db_item_suffix);
        LOOP
             FETCH c_get_ytd_def_bal_ids into c_ytd_input_table;
             EXIT WHEN c_get_ytd_def_bal_ids%NOTFOUND;

             -- Populate the Defined Balances Input Values Table
             g_ytd_input_table(i).defined_balance_id    := c_ytd_input_table.defined_balance_id;
             g_ytd_input_table(i).balance_value         := null;

             -- Populate the contexts Table

             /*bug 2610141*/
             IF p_use_tax_flag = 'Y' THEN
                     g_ytd_context_table(1).tax_unit_id         := l_tax_unit_id;
             ELSE
                     g_ytd_context_table(1).tax_unit_id         := null;
             END IF;

             -- Populate the Global Defined Balances Table
             g_ytd_bals(i).defined_balance_id := c_ytd_input_table.defined_balance_id;
             g_ytd_bals(i).balance_name       := c_ytd_input_table.balance_name;
             g_ytd_bals(i).dimension_name     := c_ytd_input_table.dimension_name;

             i := i+1;
             END LOOP;
             CLOSE c_get_ytd_def_bal_ids;
             g_ytd_def_bals_populated   := TRUE;

        END IF;

        -- Use BBR for retrieving the balance values for the previous financial year.
        --
        pay_balance_pkg.get_value(P_ASSIGNMENT_ACTION_ID =>l_asg_act_id,
                                  P_DEFINED_BALANCE_LST => g_ytd_input_table,
                                  P_CONTEXT_LST => g_ytd_context_table,
                                  P_OUTPUT_TABLE  => g_ytd_result_table);

/*Bug 4474896 - Modified the code to pick balances Earnings Standard, Pre Tax Spread, Pre Tax Progressive, Pre Tax Fixed*/
        FOR i in g_ytd_result_table.first .. g_ytd_result_table.last
        LOOP
                IF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
                   and g_ytd_bals(i).balance_name = 'Earnings_Standard'
                THEN
                   p_earnings_standard := nvl(g_ytd_result_table(i).balance_value,0);
                   IF g_debug THEN
                      hr_utility.set_location('p_earnings_standard: '||p_earnings_standard, 60);
                   END IF;
                   ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
                      and g_ytd_bals(i).balance_name = 'Pre Tax Spread Deductions'
                   THEN
                   p_pre_tax_spread := nvl(g_ytd_result_table(i).balance_value,0);
                   IF g_debug THEN
                      hr_utility.set_location('p_pre_tax_spread_deductions: '||p_pre_tax_spread, 60);
                   END IF;

                   ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
                     and g_ytd_bals(i).balance_name = 'Pre Tax Fixed Deductions' and p_use_tax_flag = 'Y'
                     /*bug4363057*/
                    THEN
                   p_pre_tax_fixed := nvl(g_ytd_result_table(i).balance_value,0);
                   IF g_debug THEN
                      hr_utility.set_location('p_pre_tax_fixed_deductions: '||p_pre_tax_fixed, 60);
                   END IF;
                   ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
                      and g_ytd_bals(i).balance_name = 'Pre Tax Progressive Deductions'  and p_use_tax_flag = 'Y'
                        /*bug4363057*/
                   THEN
                   p_pre_tax_prog := nvl(g_ytd_result_table(i).balance_value,0);
                   IF g_debug THEN
                      hr_utility.set_location('p_pre_tax_progressive_deductions: '||p_pre_tax_prog, 60);
                   END IF;

                  ELSIF g_ytd_result_table(i).defined_balance_id = g_ytd_bals(i).defined_balance_id
                     and g_ytd_bals(i).balance_name = 'Earnings_Leave_Loading'  and p_use_tax_flag = 'Y'
                     /*bug8725341*/
                  THEN
                  l_leave_loading := nvl(g_ytd_result_table(i).balance_value,0);
                  IF g_debug THEN
                     hr_utility.set_location('l_earnings_leave_loading: '||l_leave_loading, 60);
                  END IF;


                END IF;
        END LOOP;

     IF to_char(l_eff_date,'dd/mm/yyyy') >= '01/07/2009' THEN /*bug8725341*/
          p_earnings_standard := p_earnings_standard + l_leave_loading;
     END IF;

        return 1000;
  END IF;

  END calculate_term_asg_nge;

--
--  Bug 5107059 - Function to return the summed accrued hours of all accrual plan of category AU Annual Leave
--  attached with the assignment
--

FUNCTION get_total_accrual_hours
    ( p_assignment_id    IN    NUMBER
     ,p_business_group_id IN NUMBER
     , p_payroll_id IN Number
      ,p_plan_category    IN    VARCHAR2
      ,p_effective_date   IN    DATE
      ) RETURN NUMBER IS
    l_proc                 VARCHAR2(72) := g_package||'get_total_accrual_hours' ;
    l_accrual_plan_id      NUMBER ;
    l_dummy                NUMBER ;
    l_hours_flag           char(1);
    l_days_flag            char(1);
    l_error                char(1);
    l_hours                number;

  CURSOR csr_get_accrual_plan_id(p_assignment_id    NUMBER
                                ,p_effective_date   DATE
                                ,p_plan_category    VARCHAR2) IS
    SELECT pap.accrual_plan_id,pap.accrual_units_of_measure
    FROM   pay_accrual_plans pap,
           pay_element_entries_f pee,
           pay_element_links_f pel,
           pay_element_types_f pet
    WHERE  pee.assignment_id = p_assignment_id
    AND    p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
    AND    pel.element_link_id = pee.element_link_id
    AND    pel.element_type_id = pet.element_type_id
    AND    pap.accrual_plan_element_type_id = pet.element_type_id
    AND    pap.accrual_category = p_plan_category ;

  BEGIN
    hr_utility.set_location(' Entering::'||l_proc,1);
    l_hours_flag := 'N';
    l_days_flag  := 'N';
    l_hours     :=  0;
    l_error     := 'N';
    for  csr1 in csr_get_accrual_plan_id(p_assignment_id, p_effective_date, p_plan_category)
    loop
       if (csr1.accrual_units_of_measure = 'H' and l_days_flag='Y') or  (csr1.accrual_units_of_measure = 'D' and  l_hours_flag='Y') then
          l_error     := 'Y';
          exit;
       end if;

       if csr1.accrual_units_of_measure = 'H' and l_hours_flag='N' then
         l_hours_flag := 'Y';
       end if;

       if csr1.accrual_units_of_measure = 'D' and l_days_flag='N' then
          l_days_flag := 'Y';
       end if;

       l_hours := l_hours + hr_au_holidays.get_net_accrual(p_assignment_id,p_payroll_id,
                                   p_business_group_id, csr1.accrual_plan_id,p_effective_date);
   end loop;

    IF l_error = 'Y'
    THEN
      hr_utility.set_location('Enrolled in Multiple Plans '||l_proc,15);
      hr_utility.set_message(801, 'HR_AU_MULTIPLE_ACCRUAL_PLANS');
      hr_utility.raise_error;
    END IF;

    hr_utility.set_location('Leaving:'||l_proc,2);

    RETURN l_hours;

--  EXCEPTION
--    WHEN OTHERS THEN
--        hr_utility.set_location('Leaving:'||l_proc,99);
--        RETURN NULL;
  END get_total_accrual_hours;

  --------------------------------------------------
  --
  -- Function calculate_etp_tax Bug 5956223
  --
  --  Calculate ETP Tax on the ETP amount passed
  --  based on User Tables values
  --
  -- RETURNS: ETP Tax
  --
  -- IN:      p_etp_amount Amount on which tax needs to be calculated
  --          p_trans_etp  Transitional Or Non Transitional ETP or termination type Death
  --                   Values can be (D Death, TRANS Transitional,NONTRANS Non Transitional )
  --          p_death_benefit_type   Beneficiary in Death case is Dependent or Non Dependent
  --          p_over_pres_age    Yes or No
  --          p_tfn_for_non_dependant  In Death case TFN for Non Dependent
 FUNCTION calculate_etp_tax
  (p_business_group_id            IN NUMBER
  ,p_date_paid                  IN DATE
  ,p_etp_amount                   IN NUMBER
  ,p_trans_etp                    IN VARCHAR2
  ,p_death_benefit_type           IN VARCHAR2
  ,p_over_pres_age                IN VARCHAR2
  ,p_tfn_for_non_dependent        IN VARCHAR2
  ,p_medicare_levy                IN NUMBER
  )
  RETURN NUMBER IS

/*This Cursor is used to compute the ETP tax amount based on the ETP Amount and User table
  As its a Slab based taxation , Slabs in which the amount is coming and all lower slabs
  needs to be taken into consideration

  "and   p_amount > purf.row_low_range_or_name "

  The least of ETP Amount and Higher range is taken
  "to_number(purf.row_high_range),p_amount)"

  and then the difference with the lower range, This Difference is then multiplied by the Tax Percentage + Medicare Levy

  The Summation of all these values is the Net ETP Tax

  Bug 6430072 - Added condition to convert User Table values to number using fnd_number.canonical_to_number
                and not to_number.
  */

  CURSOR csr_get_etp_tax(p_bus_grp_id IN hr_all_organization_units.organization_id%TYPE
                         ,p_date_paid IN DATE
                         ,p_user_table IN VARCHAR2
                         ,p_amount   IN  NUMBER
                         ,p_med_levy IN   NUMBER) IS
SELECT /*+ INDEX(PURF) ORDERED */ NVL(SUM(round((least(fnd_number.canonical_to_number(purf.row_high_range),p_amount)-fnd_number.canonical_to_number(purf.row_low_range_or_name))
           *(fnd_number.canonical_to_number(pucif.value) + decode(fnd_number.canonical_to_number(pucif.value),0,0,p_med_levy)))),0) -- bug8647962
FROM     pay_user_tables put,
         pay_user_rows_F purf,
         pay_user_columns puc,
         pay_user_column_instances_f pucif
where put.legislation_code='AU'
and   put.user_table_name=p_user_table
and   put.user_table_id=purf.user_table_id
and   put.user_table_id=puc.user_table_id
and   puc.user_column_id=pucif.user_column_id
and   purf.user_row_id=pucif.user_row_id
and   p_date_paid between purf.effective_start_date and purf.effective_end_date
and   p_date_paid between pucif.effective_start_date and pucif.effective_end_date
and   p_amount > fnd_number.canonical_to_number(purf.row_low_range_or_name)             /* 6430072 */
order by fnd_number.canonical_to_number(purf.row_low_range_or_name);

   l_procedure    VARCHAR2(80);
   lv_user_table  VARCHAR2(50);
   lv_etp_tax     NUMBER :=0;
   lv_medicare_levy NUMBER := 0;

  BEGIN

       l_procedure := 'calculate_etp_tax';
  IF g_debug THEN
    hr_utility.set_location('    '||l_procedure,                10);
    hr_utility.set_location('IN     p_business_group_id         ' ||p_business_group_id,10);
    hr_utility.set_location('IN     p_date_paid                 ' ||p_date_paid,10);
    hr_utility.set_location('IN     p_etp_amount                ' ||p_etp_amount,10);
    hr_utility.set_location('IN     p_trans_etp                 ' ||p_trans_etp,10);
    hr_utility.set_location('IN     p_death_benefit_type        ' ||p_death_benefit_type,10);
    hr_utility.set_location('IN     p_over_pres_age             ' ||p_over_pres_age,10);
    hr_utility.set_location('IN     p_tfn_for_non_dependent     ' ||p_tfn_for_non_dependent,10);
    hr_utility.set_location('IN     p_medicare_levy             ' ||p_medicare_levy,10);

  END IF;

  lv_etp_tax:=0;
  lv_user_table:='zzz';

  lv_medicare_levy := p_medicare_levy;

   IF p_trans_etp='D' THEN
      IF p_death_benefit_type = 'D' THEN
         lv_user_table := 'TAX_SCALE_ETP_DEATH_DEPENDENT';
      ELSE
         lv_user_table := 'TAX_SCALE_ETP_DEATH_NON_DEPENDENT';
         IF p_tfn_for_non_dependent ='N' THEN
            lv_medicare_levy:=0;
         END IF;
      END IF;
   END IF;

   IF p_trans_etp='NONTRANS' THEN
     IF p_over_pres_age ='N' THEN
        lv_user_table := 'TAX_SCALE_NON_TRANS_UNDER_PREV_AGE';
     ELSIF p_over_pres_age ='Y' THEN
        lv_user_table := 'TAX_SCALE_NON_TRANS_OVER_PREV_AGE';
     END IF;
   END IF;


   IF p_trans_etp='TRANS' THEN
     IF p_over_pres_age ='N' THEN
        lv_user_table := 'TAX_SCALE_TRANS_UNDER_PREV_AGE';
     ELSIF p_over_pres_age ='Y' THEN
        lv_user_table := 'TAX_SCALE_TRANS_OVER_PREV_AGE';
     END IF;
   END IF;


       OPEN csr_get_etp_tax(p_business_group_id,p_date_paid,lv_user_table,p_etp_amount,lv_medicare_levy);
       FETCH csr_get_etp_tax into lv_etp_tax;
       CLOSE csr_get_etp_tax;

        IF g_debug THEN
            hr_utility.set_location('lv_user_table             ' ||lv_user_table,10);
            hr_utility.set_location('RETURN   lv_etp_tax               '||lv_etp_tax,10);
        END IF;
    RETURN lv_etp_tax;

  END calculate_etp_tax;
    --------------------------------------------------
  --
  -- Function get_fin_year_end Bug 5956223
  --
  --  Calculate Financial Year end date based on a given date
  --
  -- RETURNS: Financial Year end date
  -- IN     :  Date
 FUNCTION get_fin_year_end
   (p_date       IN DATE)
  RETURN DATE IS

  ld_fin_year_end  DATE;
  l_procedure    VARCHAR2(80);
 BEGIN

l_procedure := 'get_fin_year_end';
  IF g_debug THEN
    hr_utility.set_location('    '||l_procedure,                10);
    hr_utility.set_location('IN     p_date                   ' ||p_date,10);
  END IF;

 ld_fin_year_end := to_date('01/01/1900','DD/MM/YYYY');

IF to_number(to_char(p_date,'MM')) <= 06  THEN

     ld_fin_year_end := to_date('30/06/'||to_char(p_date,'YYYY'),'DD/MM/YYYY');

ELSE

     ld_fin_year_end := ADD_MONTHS(to_date('30/06/'||to_char(p_date,'YYYY'),'DD/MM/YYYY'),12);
END IF;

        IF g_debug THEN
            hr_utility.set_location('RETURN   ld_fin_year_end               '||ld_fin_year_end,10);
        END IF;

RETURN ld_fin_year_end;

 END get_fin_year_end;

    --------------------------------------------------
  --
  -- Function get_prev_age Bug 6071863
  --
  --  Get the Preservation Age from User Table ETP_PRESERVATION_AGE
  --  based on Employee's Date of Birth
  --
  -- RETURNS: Preservation Age
  -- IN     :  Date
 FUNCTION get_prev_age
   (p_date_of_birth       IN DATE,p_date_paid  IN DATE)
  RETURN NUMBER IS

/* This Cursor is used to fetch Preservation Age based on Employee's Date of Birth
  from User table 'ETP_PRESERVATION_AGE' .
  From 01-Jul-2007   Date of Birth             Preservation Age
                    Before 01-Jul-1960              55
                    01-Jul-1960  30-Jun-1961        56
                    01-Jul-1961  30-Jun-1962        57
                    01-Jul-1962  30-Jun-1963        58
                    01-Jul-1963  30-Jun-1964        59
                    After 30-Jun-1964               60

  In User Tables as only Number DataType can be Kept dates are stored in number format as YYYYMMDD
  For Example   01-JUL-1960  = 19600701
                30-JUN-1961  = 19610601

  In the cursor this is converted to to_date(purf.row_low_range_or_name,'YYYYMMDD')
  when comparing with Date of Birth */
/* Avoided converting the varchar2 columns purf.row_low_range_or_name and purf.row_high_range to date
   instead converting p_date_of_birth to number and then comparing*/


  CURSOR csr_get_prev_age IS
  SELECT /*+ index(PURF) ORDERED */ to_number(pucif.value) -- bug8647962
FROM     pay_user_tables put,
         pay_user_rows_F purf,
         pay_user_columns puc,
         pay_user_column_instances_f pucif
where put.legislation_code='AU'
and   put.user_table_name='ETP_PRESERVATION_AGE'
and   put.user_table_id=purf.user_table_id
and   put.user_table_id=puc.user_table_id
and   puc.user_column_id=pucif.user_column_id
and   purf.user_row_id=pucif.user_row_id
and   p_date_paid between purf.effective_start_date and purf.effective_end_date
and   p_date_paid between pucif.effective_start_date and pucif.effective_end_date
and   to_number(to_char(p_date_of_birth,'YYYYMMDD')) >= to_number(purf.row_low_range_or_name)
and   to_number(to_char(p_date_of_birth,'YYYYMMDD')) <= to_number(purf.row_high_range);

l_procedure varchar2(80);
ln_prev_age  Number;
  BEGIN

l_procedure := 'get_prev_age';
  IF g_debug THEN
    hr_utility.set_location('    '||l_procedure,                10);
    hr_utility.set_location('IN     p_date_of_birth                   ' ||p_date_of_birth,10);
    hr_utility.set_location('IN     p_date_paid                       ' ||p_date_paid,10);
  END IF;

  ln_prev_age :=0;

      open csr_get_prev_age;
      fetch csr_get_prev_age into ln_prev_age;
      close csr_get_prev_age;

        IF g_debug THEN
            hr_utility.set_location('RETURN   ln_prev_age               '||ln_prev_age,10);
        END IF;

RETURN ln_prev_age;

  END get_prev_age;

    --------------------------------------------------
  --
  -- Function au_check_trans Bug 6192381
  --
  -- Check if there exists a Transitional ETP or not in the current Pay Period .
  --
  -- RETURNS: Preservation Age
  -- IN     :  Assignment Id
  --        :  Date Earned
 FUNCTION au_check_trans
   (p_assignment_id       IN per_all_assignments_f.assignment_id%TYPE,
    p_date_earned         IN DATE
    )
  RETURN VARCHAR2 IS

  cursor csr_check_trans is
  select 1
  from pay_element_types_f pet,
       pay_input_values_f piv,
       pay_element_entries_f pee,
       pay_element_entry_values_f peev
  where pee.assignment_id         = p_assignment_id
  and pet.element_type_id     = piv.element_type_id
  and pet.element_name        = 'ETP on Termination'
  and piv.name                = 'Transitional ETP'
  and pet.element_type_id     = pee.element_type_id
  and pee.element_entry_id    = peev.element_entry_id
  and piv.input_value_id      = peev.input_value_id
  and peev.screen_entry_value = 'Y'
  and p_date_earned between pee.effective_start_date and pee.effective_end_date
  and p_date_earned between peev.effective_start_date and peev.effective_end_date
  and p_date_earned between pet.effective_start_date and pet.effective_end_date
  and p_date_earned between peev.effective_start_date and peev.effective_end_date;

l_procedure varchar2(80);
lv_check_trans  varchar2(1);
ln_tmp number;
  BEGIN

l_procedure := 'au_check_trans';
  IF g_debug THEN
    hr_utility.set_location('    '||l_procedure,                10);
    hr_utility.set_location('IN     p_assignment_id                     ' ||p_assignment_id,10);
    hr_utility.set_location('IN     p_date_earned                       ' ||p_date_earned,10);
  END IF;

lv_check_trans :='N';
ln_tmp         := 0 ;

      open csr_check_trans;
      fetch csr_check_trans into ln_tmp;
         if csr_check_trans%found then
            lv_check_trans :='Y';
         else
            lv_check_trans :='N';
         end if;
      close csr_check_trans;

        IF g_debug THEN
            hr_utility.set_location('RETURN   lv_check_trans              '||lv_check_trans,10);
        END IF;

RETURN lv_check_trans;

  END au_check_trans;
end pay_au_terminations;

/
