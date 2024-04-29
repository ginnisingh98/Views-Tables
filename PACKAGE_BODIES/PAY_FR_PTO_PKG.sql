--------------------------------------------------------
--  DDL for Package Body PAY_FR_PTO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_PTO_PKG" as
/* $Header: pyfrhpto.pkb 120.2 2005/09/21 06:43:47 ayegappa noship $ */
g_package  varchar2(50) := '  pay_fr_pto_pkg.';  -- Global package name
g_rate_tab    rate_tab;

TYPE term_payment_rec is RECORD
(payment     number,
 days        number,
 daily_rate  number,
 accrual_date date,
 next_payment number);

TYPE term_payment_tab is TABLE of term_payment_rec INDEX by BINARY_INTEGER;

term_payment term_payment_tab;

TYPE reg_payment_rec is RECORD
(payment     number,
 accrual_date date,
 next_payment number);

TYPE reg_payment_tab is TABLE of reg_payment_rec INDEX by BINARY_INTEGER;

reg_payment reg_payment_tab;

--
-------------------------------------------------------------------------------
-- Function read_termination_payment_rate
-- obtains the first Rate value from the pl/sql table
-------------------------------------------------------------------------------
Function read_termination_payment_rate(p_accrual_plan_id IN         NUMBER,
                                       p_days            OUT NOCOPY NUMBER)
	return number is
l_index number;

begin

hr_utility.trace('in read termination payment rate');

hr_utility.trace('p_accrual_plan_id = ' || p_accrual_plan_id);

l_index := p_accrual_plan_id * 10 + 1;

p_days := term_payment(l_index).days;

hr_utility.trace('p_days = ' || p_days);

hr_utility.trace('left read termination payment rate');

return 0;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.trace('read_termination_payment rate');
   hr_utility.trace(SQLCODE);
   hr_utility.trace(SQLERRM);
   Raise;
end read_termination_payment_rate;


--
-------------------------------------------------------------------------------
-- LOAD_FR_PAYSLIP_ACCRUAL_DATA                                   Archiver Call
-- Called by the payslip archiver PAY_FR_ARC_PKG
-------------------------------------------------------------------------------
Procedure load_fr_payslip_accrual_data
(P_assignment_id                  IN Number
,p_date_earned                    IN Date
,p_business_Group_id              IN Number) is
--
-- Cursor to get all accrual plans for this assignment as at date earned
--
CURSOR   csr_all_plans is
         select /*+ USE_NL(pap, asg, pee) */
                pap.accrual_plan_id                accrual_plan_id
               ,pap.accrual_plan_name              accrual_plan_name
               ,pap.accrual_category               accrual_category
               ,pap.accrual_plan_element_type_id   accrual_plan_element_type_id
               ,pee.effective_start_date           effective_start_date
               ,asg.payroll_id                     payroll_id
         from   pay_accrual_plans     pap
               ,pay_element_entries_f pee
               ,per_all_assignments_f asg
         where  pap.business_group_id + 0   = p_business_group_id
           and  asg.assignment_id = p_assignment_id
           and  p_date_earned between asg.effective_start_date and asg.effective_end_date
           and  pee.element_link_id in (select element_link_id
                                        from   pay_element_links_f
                                        where  element_type_id = pap.accrual_plan_element_type_id
                                        )
           and pee.assignment_id = p_assignment_id
           and p_date_earned between pee.effective_start_date and pee.effective_end_date;

cursor csr_check_for_termination is
        select null
        from   per_periods_of_service pds
              ,PER_ALL_ASSIGNMENTS_F ASG
        where  pds.period_of_service_id = asg.period_of_service_id
          and  asg.assignment_id = p_assignment_id
          and  pds.actual_termination_date
                       between asg.effective_start_date and asg.effective_end_Date
          and  pds.actual_termination_date is not null;

l_accrual_total number  := 0;
l_ent_total     number  := 0;
l_taken_total   number  := 0;
l_balance_total number  := 0;

l_accrual_this  number  := 0;
l_taken_this    number  := 0;
l_balance_this  number  := 0;
l_ent_this      number  := 0;
l_ent_balance   number  := 0;

l_standard_entitlement    number := 0;
l_standard_accrual        number := 0;

l_term_pay_total          number := 0;
l_term_pay_this           number := 0;
--l_term_ent_total          number := 0;
--l_term_ent_this           number := 0;
l_term_pay_period_1       number := 0;
l_gross_taken_total       number := 0;
l_ret number;

l_unused_date   date;
l_unused_number number;
l_unused_char   varchar2(10);
l_remaining     number;

l_total_accrued_pto       number := 0;
l_total_accrued_protected number := 0;

l_ent_m number;
l_net_m number;

l_fr_plan_info g_fr_plan_info;
l_fr_pay_info  g_fr_pay_info;
l_fr_pay_r_info  g_fr_pay_info;

l_index number := 0;

l_std_start_date date;
l_std_end_date   date;
l_std_absence    number;
l_std_carryover  number;
l_std_other      number;
l_payslip_taken_to_date date;

l_proc VARCHAR2(72) :=    g_package||' load_fr_payslip_accrual_data ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Set flag to accrual formula to not deduct holiday from the accrual
  -- (this is usually done if there is no entitlement stored)
  --
  -- Clear the structure to hold the results;
  --
  g_fr_payslip_info.DELETE;
  hr_utility.set_location('Step ' || l_proc,30);
  --
  -- Main loop for all plans for this assignment
  --
  hr_utility.set_location('assignment_id is ',  p_assignment_id);
  hr_utility.set_location('business_group_id is ' ,  p_business_group_id);
  hr_utility.set_location('date earned is ' || to_char(p_date_earned), 30);


  FOR l_accrual_plan_rec in csr_all_plans LOOP
  l_index := l_index + 1;

  hr_utility.set_location('l_accrual_plan_rec.accrual_plan_id is ',  l_accrual_plan_rec.accrual_plan_id);
  hr_utility.set_location('l_accrual_plan_rec.accrual_plan_element_type_id is ' ,  l_accrual_plan_rec.accrual_plan_element_type_id);
  hr_utility.set_location('l_accrual_plan_rec.payroll_id is ' ,  l_accrual_plan_rec.payroll_id);

  IF l_accrual_plan_rec.accrual_category in ('FR_MAIN_HOLIDAY', 'FR_RTT_HOLIDAY', 'FR_ADDITIONAL_HOLIDAY') THEN
    --
    -- Call this year and previous 3 years
    --
    l_accrual_total := 0;
    l_ent_total     := 0;
    l_taken_total   := 0;
    l_balance_total := 0;

    l_accrual_this  := 0;
    l_ent_this      := 0;
    l_taken_this    := 0;
    l_term_pay_total := 0;
    l_term_pay_this  := 0;

    l_total_accrued_pto := 0;
    l_total_accrued_protected := 0;

    --
    -- Load the plan info
    --
    hr_utility.set_location('Step ' || l_proc,40);
    l_fr_plan_info := get_fr_accrual_plan_info(
      p_accrual_plan_id          => l_accrual_plan_rec.accrual_plan_id
     ,p_accrual_date             => p_date_earned);
    --
    -- record the date as at holiday must be taken before to reduce entitlement, rather than appear
    -- on the payslip as 'taken' bug 2448832
    --
    l_payslip_taken_to_date := l_fr_plan_info.accrual_year_start;

    hr_utility.set_location('Step ' || l_proc,50);
    --
    -- Call the accrual formula for this year, up to date_earned. Do not deduct holiday taken
    -- from accrual. This may return zero if entitlement is stored past p_date_earned - this
    -- will be picked up by entitlement
    --
/**/
    FR_Get_Accrual
     (P_Assignment_ID               => P_Assignment_ID
     ,P_Calculation_Date            => p_date_earned
     ,p_accrual_start_date          => l_fr_plan_info.accrual_year_start
     ,P_Plan_ID                     => l_accrual_plan_rec.accrual_plan_id
     ,P_Business_Group_ID           => p_business_Group_id
     ,P_Payroll_ID                  => l_accrual_plan_rec.payroll_id
     ,p_create_all                  => 'N' /* (do not create extra accrual types) */
     ,p_reprocess_whole_period      => 'N' /* (only run accrual from latest ent to p_date_earned) */
     ,p_payslip_process             => 'Y'
     ,P_Start_Date                  => l_unused_date
     ,P_End_Date                    => l_unused_date
     ,P_Accrual_End_Date            => l_unused_date
     ,P_total_accrued_pto           => l_total_accrued_pto
     ,P_total_Accrued_protected     => l_total_Accrued_protected
     ,P_total_Accrued_seniority     => l_unused_number
     ,P_total_Accrued_mothers       => l_unused_number
     ,P_total_Accrued_conventional  => l_unused_number ) ;

  hr_utility.set_location('Step ' || l_proc,60);
  l_accrual_this := nvl(l_total_accrued_pto,0) + nvl(l_total_Accrued_protected,0);
  l_accrual_total := l_accrual_total +  l_accrual_this;


  --
  -- Get the entitlement and net for this year. Only deduct holidays taken and paid
  -- (do not deduct all holidays booked, as the payslip must only show days taken to date )
  --
  hr_utility.set_location('Step ' || l_proc,60);

    get_fr_net_entitlement
     (p_accrual_plan_id                => l_accrual_plan_rec.accrual_plan_id
     ,p_effective_date                 => p_date_earned
     ,p_assignment_id                  => p_assignment_id
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_term_pay_this
     ,p_net_main                       => l_taken_total   /* days taken and paid this accrual year, from any accrual year */
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this     /* net entitlement, excluding days paid this year */
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'Y'  /* indicated paid days should be deducted */
     ,p_paid_days_to                   =>  l_payslip_taken_to_date);

    hr_utility.set_location('Step ' || l_proc,70);
    hr_utility.trace('y=1 l_payslip_taken_to_date is ' || l_payslip_taken_to_date);
    hr_utility.trace('y=1 ltaken_total is ' || l_taken_total);
    hr_utility.trace('y=1 l_ent_this is ' || l_ent_this);
    hr_utility.trace('y=1 l_term_pay_this is ' || l_term_pay_this);
    l_term_pay_period_1 := l_term_pay_this;
    --
    -- Add back the term payments for this year to ent
    --
    l_ent_this := l_ent_this + l_term_pay_this;
    l_term_pay_total := l_term_pay_total + nvl(l_term_pay_this,0);
    l_ent_total := l_ent_total + nvl(l_ent_this,0);
    hr_utility.trace('y=1 adj ent is ' || l_ent_this);
    --
    -- Y-1
    --
  hr_utility.set_location('3 get net ent', 130);
    get_fr_net_entitlement
     (p_accrual_plan_id                => l_accrual_plan_rec.accrual_plan_id
     ,p_effective_date                 => add_months(p_date_earned, -12)
     ,p_assignment_id                  => p_assignment_id
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_term_pay_this
     ,p_net_main                       => l_unused_number
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'Y'  /* indicates paid days should be deducted */
     ,p_paid_days_to                   =>  l_payslip_taken_to_date);

    hr_utility.set_location('Step ' || l_proc,80);
    hr_utility.trace('y=2 l_payslip_taken_to_date is ' || l_payslip_taken_to_date);
    hr_utility.trace('y=2 ltaken_total is ' || l_taken_total);
    hr_utility.trace('y=2 l_ent_this is ' || l_ent_this);
    hr_utility.trace('y=2 l_term_pay_this is ' || l_term_pay_this);
    --
    -- Add back the term payments for this year to ent
    --
    l_ent_this := l_ent_this + l_term_pay_this;
    l_term_pay_total := l_term_pay_total + nvl(l_term_pay_this,0);
    hr_utility.trace('l_ent_this is ' || l_ent_this);
    hr_utility.trace('y=2 adj ent is ' || l_ent_this);

    l_ent_total := l_ent_total + nvl(l_ent_this,0);
    --
    -- Y-2
    --
    get_fr_net_entitlement
     (p_accrual_plan_id                => l_accrual_plan_rec.accrual_plan_id
     ,p_effective_date                 => add_months(p_date_earned, -24)
     ,p_assignment_id                  => p_assignment_id
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_term_pay_this
     ,p_net_main                       => l_unused_number
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'Y'  /* indicated paid days should be deducted */
     ,p_paid_days_to                   =>  l_payslip_taken_to_date);

     hr_utility.set_location('Step ' || l_proc,80);
     hr_utility.trace('l_ent_this is ' || l_ent_this);
    hr_utility.trace('y=3 l_term_pay_this is ' || l_term_pay_this);
    --
    -- Add back the term payments for this year to ent
    --
    l_ent_this := l_ent_this + l_term_pay_this;
    l_term_pay_total := l_term_pay_total + nvl(l_term_pay_this,0);
    hr_utility.trace('l_ent_this is ' || l_ent_this);
    l_ent_total := l_ent_total + nvl(l_ent_this,0);
    hr_utility.trace('y=3 adj ent is ' || l_ent_this);
    --
    -- Y-3
    --
    get_fr_net_entitlement
     (p_accrual_plan_id                => l_accrual_plan_rec.accrual_plan_id
     ,p_effective_date                 => add_months(p_date_earned, -36)
     ,p_assignment_id                  => p_assignment_id
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_term_pay_this
     ,p_net_main                       => l_unused_number
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'Y'  /* indicated paid days should be deducted */
     ,p_paid_days_to                   =>  l_payslip_taken_to_date);

    hr_utility.set_location('Step ' || l_proc,90);
    hr_utility.trace('y=3 l_payslip_taken_to_date is ' || l_payslip_taken_to_date);
    hr_utility.trace('y=3 ltaken_total is ' || l_taken_total);
    hr_utility.trace('y=3 l_ent_this is ' || l_ent_this);
    hr_utility.trace('l_ent_this is ' || l_ent_this);
    --
    -- Add back the term payments for this year to ent
    --
    l_ent_this := l_ent_this + l_term_pay_this;

    hr_utility.trace('l_ent_this is ' || l_ent_this);
    hr_utility.trace('y=4 l_term_pay_this is ' || l_term_pay_this);
    l_term_pay_total := l_term_pay_total + nvl(l_term_pay_this,0);
    hr_utility.trace('l_ent_this is ' || l_ent_this);
    hr_utility.trace('y=4 adj ent is ' || l_ent_this);

    l_ent_total := l_ent_total + nvl(l_ent_this,0);
    l_ent_balance   := nvl(l_ent_total,0) - nvl(l_taken_total,0);

    --
    -- If termination, adjust the output as follows:
    -- if acc + ent (gross of term payments) = termination days paid + holiday days paid
    -- set values to zero.
    -- the taken represents all termination payments over all years +
    -- any holidays booked and paid this period.
    --
    open csr_check_for_termination;
    fetch csr_check_for_termination into l_unused_char;
    if csr_check_for_termination%FOUND then
      l_gross_taken_total := l_taken_total - l_term_pay_period_1;
      if l_accrual_total + l_ent_total = l_term_pay_total + l_gross_taken_total THEN
         -- set variables to zero. Taken represents all paid hols is year, + all
         -- termination payments this year.
         --
         l_accrual_total := 0;
         l_ent_total     := 0;
         l_ent_balance   := 0;
         l_taken_total   := l_gross_taken_total + l_term_pay_total;
      end if;
    end if;
    close csr_check_for_termination;
    hr_utility.trace('end tot acc = ' || l_accrual_total);
    hr_utility.trace('end ent tot = ' || l_ent_total);
    hr_utility.trace('end tak tot = ' || l_taken_total);
    hr_utility.trace('end bal tot = ' || l_ent_balance);
    hr_utility.trace('end term tot = ' || l_term_pay_total);


    --
    -- Calculate and store values in record structure.
    --
    g_fr_payslip_info(l_index).assignment_id := p_assignment_id;
    g_fr_payslip_info(l_index).plan_name     := l_accrual_plan_rec.accrual_plan_name;
    g_fr_payslip_info(l_index).Accrual       := nvl(l_accrual_total,0);
    g_fr_payslip_info(l_index).Entitlement   := nvl(l_ent_total,0);
    g_fr_payslip_info(l_index).Taken         := nvl(l_taken_total,0);
    g_fr_payslip_info(l_index).Balance       := l_ent_balance;

    hr_utility.set_location('Step ' || l_proc,100);
    --
    --
    --
    ELSE
      --
      -- Call the standard functions
      --
      hr_utility.set_location('Step ' || l_proc,100);

      per_accrual_calc_functions.get_accrual(
        p_assignment_id          => p_assignment_id
       ,p_plan_id                => l_accrual_plan_rec.accrual_plan_id
       ,p_calculation_date       => p_date_earned
       ,p_business_group_id      => p_business_group_id
       ,p_payroll_id             => l_accrual_plan_rec.payroll_id
       ,p_assignment_action_id   => -1
       ,p_accrual_start_date     => null
       ,p_accrual_latest_balance => null
       ,p_start_date             => l_std_start_date
       ,p_end_date               => l_std_end_date
       ,p_accrual_end_date       => l_unused_date
       ,p_accrual                => l_accrual_total);

      hr_utility.set_location('Step ' || l_proc,110);

      l_std_absence := per_accrual_calc_functions.get_absence(
        p_assignment_id          => p_assignment_id
       ,p_plan_id                => l_accrual_plan_rec.accrual_plan_id
       ,p_start_date             => l_std_start_date
       ,p_calculation_date       => l_std_end_date);

      hr_utility.set_location('Step ' || l_proc,120);

      l_std_other := per_accrual_calc_functions.get_other_net_contribution(
        p_assignment_id          => p_assignment_id
       ,p_plan_id                => l_accrual_plan_rec.accrual_plan_id
       ,p_start_date             => l_std_start_date
       ,p_calculation_date       => l_std_end_date );

      hr_utility.set_location('Step ' || l_proc,130);

      l_std_carryover := per_accrual_calc_functions.get_carry_over(
        p_assignment_id          => p_assignment_id
       ,p_plan_id                => l_accrual_plan_rec.accrual_plan_id
       ,p_start_date             => l_std_start_date
       ,p_calculation_date       => l_std_end_date);

      hr_utility.set_location('Step ' || l_proc,140);

      --
      -- Archive the values
      --
      g_fr_payslip_info(l_index).assignment_id := p_assignment_id;
      g_fr_payslip_info(l_index).plan_name     := l_accrual_plan_rec.accrual_plan_name;
      g_fr_payslip_info(l_index).Accrual       := 0;
      g_fr_payslip_info(l_index).Entitlement   := nvl(l_accrual_total,0) + nvl(l_std_other,0) + nvl(l_std_carryover,0);
      g_fr_payslip_info(l_index).Taken         := nvl(l_std_absence,0);
      g_fr_payslip_info(l_index).Balance       := nvl(l_accrual_total,0) + nvl(l_std_other,0) + nvl(l_std_carryover,0) -  nvl(l_std_absence,0);

      hr_utility.set_location('Step ' || l_proc,150);

     hr_utility.set_location(' loop_counter is ' || to_char(l_index), 20);
     hr_utility.set_location(' g_fr_payslip_info(l_index).Accrual is ' , g_fr_payslip_info(l_index).Accrual);
     hr_utility.set_location(' g_fr_payslip_info(l_index).Entitlementl is ' , g_fr_payslip_info(l_index).Entitlement);
     hr_utility.set_location(' g_fr_payslip_info(l_index).Taken is ' , g_fr_payslip_info(l_index).Taken);
     hr_utility.set_location(' g_fr_payslip_info(l_index).Balance is ' , g_fr_payslip_info(l_index).Balance);

    END IF; /* if French Type accrual category */
  END LOOP; /* loop of all plans */
  --
  -- Reset the payslip taken to date bug 2448832
  --
  hr_utility.set_location('Leaving:  '||l_proc,160);
END load_fr_payslip_accrual_data;
--
-------------------------------------------------------------------------------
-- PROCEDURE                 GET_FR_NET_ENTITLEMENT                          --
-------------------------------------------------------------------------------
procedure get_fr_net_entitlement
(p_accrual_plan_id                IN Number
,p_effective_date                 IN Date
,p_assignment_id                  IN Number
,p_ignore_ent_adjustments         IN Varchar2 default 'N'
-- adding extra parameter for additional holidays
-- to get correct accrual dates
,p_accrual_type                   IN varchar2 default null
,p_legal_period_end               IN date default null
--
,p_remaining                     OUT NOCOPY Number
,p_net_main                      OUT NOCOPY Number
,p_net_protected                 OUT NOCOPY Number
,p_net_young_mothers             OUT NOCOPY Number
,p_net_seniority                 OUT NOCOPY Number
,p_net_conventional              OUT NOCOPY Number
,p_ent_main                      OUT NOCOPY Number
,p_ent_protected                 OUT NOCOPY Number
,p_ent_young_mothers             OUT NOCOPY Number
,p_ent_seniority                 OUT NOCOPY Number
,p_ent_conventional              OUT NOCOPY Number
,p_accrual_start_date            OUT NOCOPY Date
,p_accrual_end_date              OUT NOCOPY Date
,p_type_calculation              IN Varchar2 default 'N' /* Normal, Y=Payslip A=Archive */
,p_paid_days_to                  IN Date     default null
) is
--
l_fr_plan_info g_fr_plan_info;
l_fr_pay_info  g_fr_pay_info;
l_fr_pay_r_info  g_fr_pay_info;
--
l_accrual_plan_id number := p_accrual_plan_id;
l_net_m Number := 0; l_net_p Number := 0; l_net_y Number := 0; l_net_s Number := 0; l_net_c Number := 0;
--
l_ent_m Number := 0; l_ent_p Number := 0; l_ent_y Number := 0; l_ent_s Number := 0; l_ent_c Number := 0;
l_obs_m Number := 0; l_obs_p Number := 0; l_obs_y Number := 0; l_obs_s Number := 0; l_obs_c Number := 0;
l_adj_m Number := 0; l_adj_p Number := 0; l_adj_y Number := 0; l_adj_s Number := 0; l_adj_c Number := 0;
--
l_paid_m0 Number := 0; l_paid_p0 Number := 0; l_paid_y0 Number := 0; l_paid_s0 Number := 0; l_paid_c0  Number := 0;
l_paid_m1 Number := 0; l_paid_p1 Number := 0; l_paid_y1 Number := 0; l_paid_s1 Number := 0; l_paid_c1  Number := 0;
--
l_taken_total                        Number;
l_unused_number                      Number;
l_unused_char                        varchar2(30);
l_unused_date                        date;
l_latest_entitlement_date            date;
l_ret                                Number;
l_previous_paid_absences             Number := 0;
l_current_paid_absences              Number := 0;
l_previous_paid_absences_retro       Number := 0;
l_current_paid_absences_retro        Number := 0;
l_action_sequence                    PAY_ASSIGNMENT_ACTIONS.ACTION_SEQUENCE%TYPE;
--
l_booked_m Number; l_booked_s Number; l_booked_y Number; l_booked_c Number; l_booked_p Number;
--
l_term_payment                       Number;
--
l_net_main                           Number;
l_net_protected                      Number;
l_net_conventional                   Number;
l_net_seniority  		     Number;
l_net_young_mothers                  Number;
--
l_ent_main                          Number;
l_ent_protected                     Number;
l_ent_young_mothers                 Number;
l_ent_seniority                     Number;
l_ent_conventional                  Number;


-- Get the sum per accrual type of all booked absences for this asg
-- Includes this absence (if it is saved).
--
cursor csr_check_for_termination is
        select null
        from   per_periods_of_service pds
              ,PER_ALL_ASSIGNMENTS_F ASG
        where  pds.period_of_service_id = asg.period_of_service_id
          and  asg.assignment_id = p_assignment_id
          and  pds.actual_termination_date
                       between asg.effective_start_date and asg.effective_end_Date
          and  pds.actual_termination_date is not null
;
--
-- Payslip processing - sum the totals of paid absences, fetching from run results, not
--                      all booked (element entries).
--
CURSOR       csr_previous_action_sequence is
             select max(paa.action_sequence)
             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
             where ppa.payroll_action_id = paa.payroll_action_id
             and   paa.assignment_id = p_assignment_id
             and   p_paid_days_to >= ppa.effective_date
             and   ppa.action_type in ('Q','R');

CURSOR  csr_previous_paid_absences is
             select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_info.pay_total_days_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_info.pay_plan_input_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.element_type_id         = l_fr_pay_info.pay_element_id
               and  prr.status                  in ('P','PA')
               and  prrv_plan.result_value      = l_accrual_plan_id
               and  paa.action_sequence < l_action_sequence
               /* restrict to just this accrual year, otherwise all taken across all plan years will be added in  */
               and  prrv_accrual.result_value between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                  and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);


CURSOR  csr_previous_paid_absences_r is
             select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_r_info.pay_total_days_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_r_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_r_info.pay_plan_input_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.element_type_id         = l_fr_pay_r_info.pay_element_id
               and  prr.status                  in ('P','PA')
               and  prrv_plan.result_value      = l_accrual_plan_id
               and  paa.action_sequence < l_action_sequence
               /* restrict to just this accrual year, otherwise all taken across all plan years will be added in  */
               and  prrv_accrual.result_value between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                  and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);
--
-- Get the absences on or after the action sequence
CURSOR       csr_current_paid_absences is
             select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_info.pay_total_days_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_info.pay_plan_input_ID
               and  prrv_plan.result_value      = l_accrual_plan_id
               and  prr.status                  in ('P','PA')
               and  paa.action_sequence        >= l_action_sequence
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.element_type_id         = l_fr_pay_info.pay_element_id;

-- Get the absences on or after the action sequence
CURSOR       csr_current_paid_absences_r is
             select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_r_info.pay_total_days_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_r_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_r_info.pay_plan_input_ID
               and  prrv_plan.result_value      = l_accrual_plan_id
               and  paa.action_sequence        >= l_action_sequence
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.status                  in ('P','PA')
               and  prr.element_type_id         = l_fr_pay_r_info.pay_element_id;

-- Get the minimum action sequence in this accrual year
--
CURSOR       csr_current_action_sequence is
             select min(paa.action_sequence)
             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
             where ppa.payroll_action_id = paa.payroll_action_id
             and   paa.assignment_id = p_assignment_id
             and   p_paid_days_to  <= ppa.effective_date
             and   ppa.action_type in ('Q','R');

CURSOR       csr_previous_and_current_seq is
             select max(paa.action_sequence)
             from pay_assignment_actions paa
                 ,pay_payroll_actions    ppa
             where ppa.payroll_action_id = paa.payroll_action_id
             and   paa.assignment_id = p_assignment_id
             and   p_paid_days_to >= ppa.effective_date
             and   ppa.action_type in ('Q','R');


CURSOR       csr_prev_and_current_paid_abs is
             select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_info.pay_total_days_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_info.pay_plan_input_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prrv_plan.result_value      = l_accrual_plan_id
               and  prr.element_type_id         = l_fr_pay_info.pay_element_id
               and  prr.status                  in ('P','PA')
               and  paa.action_sequence        <= l_action_sequence
               and  prrv_accrual.result_value between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                  and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);

CURSOR       csr_prev_and_cur_paid_abs_r is
             select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_r_info.pay_total_days_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_r_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_r_info.pay_plan_input_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prrv_plan.result_value      = l_accrual_plan_id
               and  prr.element_type_id         = l_fr_pay_r_info.pay_element_id
               and  prr.status                  in ('P','PA')
               and  paa.action_sequence        <= l_action_sequence
               and  prrv_accrual.result_value between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                  and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);

--
-- Termination processing - get sum of paid absences
--
cursor csr_get_paid_days is
       select sum(prrv_days.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
                   ,pay_payroll_actions    ppa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_plan_info.term_days_iv_ID
               and  prrv_accrual.input_value_id = l_fr_plan_info.term_accrual_date_iv_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.element_type_id         = l_fr_plan_info.term_element_id
               and  prr.status                  in ('P','PA')
               and  ppa.payroll_action_id = paa.payroll_action_id
               -- termination payments always exist over all time for an accrual year
               -- and  p_paid_days_to >= ppa.effective_date
               --  restrict to just this accrual year,
               -- otherwise all taken across all plan years will be added in
               -- this cursor is used by the accruals calculation
               and  prrv_accrual.result_value between
               fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
           and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);


--
-- get the total of ENTITLEMENT, OBSOLETION, ADJUSTMENT entries for this asg for this accrual plan year
--
cursor csr_get_ent_obs(
               p_type_m_iv_id number
              ,p_type_p_iv_id number
              ,p_type_s_iv_id number
              ,p_type_c_iv_id number
              ,p_type_y_iv_id number
              ,p_type_accrual_date_iv_id number ) is
       select  sum(fnd_number.canonical_to_number(pevm.screen_entry_value))
              ,sum(fnd_number.canonical_to_number(pevp.screen_entry_value))
              ,sum(fnd_number.canonical_to_number(pevc.screen_entry_value))
              ,sum(fnd_number.canonical_to_number(pevs.screen_entry_value))
              ,sum(fnd_number.canonical_to_number(pevy.screen_entry_value))
       from    pay_element_entry_values_f pevm
              ,pay_element_entry_values_f pevp
              ,pay_element_entry_values_f pevc
              ,pay_element_entry_values_f pevs
              ,pay_element_entry_values_f pevy
              ,pay_element_entry_values_f pevdate
              ,pay_element_entries_f      pee
       where   pevm.input_value_id = p_type_m_iv_id
       and     pevp.input_value_id = p_type_p_iv_id
       and     pevs.input_value_id = p_type_s_iv_id
       and     pevc.input_value_id = p_type_c_iv_id
       and     pevy.input_value_id = p_type_y_iv_id
       and     pevdate.input_value_id = p_type_accrual_date_iv_id
       and     pee.element_entry_id = pevm.element_entry_id
       and     pee.element_entry_id = pevp.element_entry_id
       and     pee.element_entry_id = pevs.element_entry_id
       and     pee.element_entry_id = pevc.element_entry_id
       and     pee.element_entry_id = pevy.element_entry_id
       and     pee.element_entry_id = pevdate.element_entry_id
       and     pevdate.screen_entry_value between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                              and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end)
       and     pee.assignment_id = p_assignment_id ;
--
-- Cursor for calculating existing entitlements for additional holidays
cursor csr_get_ent_add(
               p_type_m_iv_id number
              ,p_type_accrual_date_iv_id number) is
       select  sum(pevm.screen_entry_value)
       from    pay_element_entry_values_f pevm
              ,pay_element_entry_values_f pevdate
              ,pay_element_entries_f      pee
       where   pevm.input_value_id = p_type_m_iv_id
       and     pevdate.input_value_id = p_type_accrual_date_iv_id
       and     pee.element_entry_id = pevm.element_entry_id
       and     pee.element_entry_id = pevdate.element_entry_id
       and     pevdate.screen_entry_value = fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end)
       and     pee.assignment_id = p_assignment_id
       and     pee.effective_start_date between p_legal_period_end and
                                              add_months(l_fr_plan_info.accrual_year_end,12);
--
l_proc VARCHAR2(72) :=    g_package||' get_fr_net_entitlement ';

BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);

  --
  -- Get plan info
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_accrual_date             => p_effective_date );

  hr_utility.set_location('Step ' || l_proc,20);
  --
  -- Get the payment element type if it will be used ie type calculation = 'Y' or Accruals
  --
  IF p_type_calculation = 'Y' or p_type_calculation = 'A' THEN
    l_fr_pay_info := get_payment_globals;
    l_fr_pay_r_info := get_payment_globals_r;
    hr_utility.set_location('Step ' || l_proc,30);
  END IF;
  --                           /***/
  --
  hr_utility.set_location(' Accrual type is: '||p_accrual_type, 22);
  hr_utility.set_location('Legal period end is: '||to_char(p_legal_period_end), 22);
  hr_utility.set_location('Accrual year end is: '||to_char(l_fr_plan_info.accrual_year_end),22);
  hr_utility.set_location('l_fr_plan_info.ent_m_iv_id is: '||to_char(l_fr_plan_info.ent_m_iv_id), 22);
  hr_utility.set_location('l_fr_plan_info.ent_accrual_date_iv_id is: '||to_char(l_fr_plan_info.ent_accrual_date_iv_id), 22);
  -- Get the ENTitlement Entries for this assignment / accrual date
  -- Added condition for addtional holidays
  IF p_accrual_type = 'ADD' THEN
     --
     Open csr_get_ent_add(l_fr_plan_info.ent_m_iv_id, l_fr_plan_info.ent_accrual_date_iv_id);
     Fetch csr_get_ent_add into l_ent_m;
     Close csr_get_ent_add;
     --
  ELSE
     --
     open csr_get_ent_obs(l_fr_plan_info.ent_m_iv_id, l_fr_plan_info.ent_p_iv_id
                         ,l_fr_plan_info.ent_s_iv_id, l_fr_plan_info.ent_c_iv_id
                         ,l_fr_plan_info.ent_y_iv_id, l_fr_plan_info.ent_accrual_date_iv_id);
     fetch csr_get_ent_obs into l_ent_m, l_ent_p, l_ent_c, l_ent_s, l_ent_y;
     close csr_get_ent_obs;
     --
  END IF;
  hr_utility.set_location('Step ' || l_proc,40);

  hr_utility.trace('l_ent_m is ' || l_ent_m);
  hr_utility.trace('l_ent_p is ' || l_ent_p);
  hr_utility.trace('l_ent_c is ' || l_ent_c);
  hr_utility.trace('l_ent_s is ' || l_ent_s);
  hr_utility.trace('l_ent_y is ' || l_ent_y);

  --
  -- The parameter p_ignore_ent_adjustments relates to the 'ENT' output variables.
  -- If it is 'Y', the adjustments should not be added into the ENT parameters, otherwist they sdhould bw.
  -- The absence form will show ent with adjustments,
  -- The create entitlement process will need pure entitlement regardless of adjustments.
  -- If the parameter p_ignore_ent_adjustments is 'Y', this is the only type of entitlement to consider.
  -- otherwise, continue with other types and also deduct holidays and if termination, paid days.
  --
    --
    -- Get the OBSoletion entries
    --
    open csr_get_ent_obs(l_fr_plan_info.obs_m_iv_id, l_fr_plan_info.obs_p_iv_id
                        ,l_fr_plan_info.obs_s_iv_id, l_fr_plan_info.obs_c_iv_id
                        ,l_fr_plan_info.obs_y_iv_id, l_fr_plan_info.obs_accrual_date_iv_id);
    fetch csr_get_ent_obs into l_obs_m, l_obs_p, l_obs_c, l_obs_s, l_obs_y;
    close csr_get_ent_obs;
  hr_utility.trace('l_obs_m is ' || l_obs_m);
  hr_utility.trace('l_obs_p is ' || l_obs_p);
  hr_utility.trace('l_obs_c is ' || l_obs_c);
  hr_utility.trace('l_obs_s is ' || l_obs_s);
  hr_utility.trace('l_obs_y is ' || l_obs_y);

    hr_utility.set_location('Step ' || l_proc,50);
    --
    -- Get the ASJustment entries
    --
    open csr_get_ent_obs(l_fr_plan_info.adj_m_iv_id, l_fr_plan_info.adj_p_iv_id
                        ,l_fr_plan_info.adj_s_iv_id, l_fr_plan_info.adj_c_iv_id
                        ,l_fr_plan_info.adj_y_iv_id, l_fr_plan_info.adj_accrual_date_iv_id);
    fetch csr_get_ent_obs into l_adj_m, l_adj_p, l_adj_c, l_adj_s, l_adj_y;
    close csr_get_ent_obs;
  hr_utility.trace('l_adj_m is ' || l_adj_m);
  hr_utility.trace('l_adj_p is ' || l_adj_p);
  hr_utility.trace('l_adj_c is ' || l_adj_c);
  hr_utility.trace('l_adj_s is ' || l_adj_s);
  hr_utility.trace('l_adj_y is ' || l_adj_y);
    hr_utility.set_location('Step ' || l_proc,60);
    --
    -- Uncommented and modified for termination
    -- If this assignment is terminated, (ie there is a termination date),
    -- Deduct any paid holidays
    open csr_check_for_termination;
    fetch csr_check_for_termination into l_unused_date;
    if csr_check_for_termination%FOUND then
       close csr_check_for_termination;
       hr_utility.trace('IN TERMINATION');
       --
       --hr_utility.trace(' l_fr_plan_info.term_days_iv_ID ' || l_fr_plan_info.term_days_iv_ID);
       --hr_utility.trace(' l_fr_plan_info.term_accrual_date_iv_ID ' || l_fr_plan_info.term_accrual_date_iv_ID);
       --hr_utility.trace(' p_assignment_id ' || p_assignment_id);
       --hr_utility.trace(' l_fr_plan_info.term_element_id ' || l_fr_plan_info.term_element_id);
       --hr_utility.trace(' p_paid_days_to ' || p_paid_days_to);
       --hr_utility.trace(' l_fr_plan_info.accrual_year_start ' || l_fr_plan_info.accrual_year_start);
       --hr_utility.trace(' l_fr_plan_info.accrual_year_end ' || l_fr_plan_info.accrual_year_end);
       --hr_utility.trace(' p_paid_days_to ' || p_paid_days_to);

       open csr_get_paid_days ;
       fetch csr_get_paid_days into l_term_payment;
       close csr_get_paid_days;
       --
    else
       l_term_payment :=0;
       close csr_check_for_termination;
    end if;
    --
    IF p_type_calculation = 'N' THEN
   hr_utility.trace('P type = N');
      --
      -- only deduct holidays if there is entitlement stored against this accrual plan
      -- otherwise it will be taken off of accrual
      --
      l_ret := get_fr_latest_ent_date
             (p_assignment_id              => p_assignment_id
             ,p_accrual_plan_id            => p_accrual_plan_id
             ,p_effective_date             => p_effective_date
             ,p_latest_date                => l_latest_entitlement_date
             ,p_entitlement_start_date     => l_unused_date
             ,p_accrual_start_date         => l_unused_date
             ,p_accrual_end_date           => l_unused_date);
      hr_utility.set_location('Step ' || l_proc,70);
      --
      IF l_latest_entitlement_date > to_date('1990-01-01','yyyy-mm-dd') THEN
        --
        -- Deduct any holidays booked against this assignment / accrual plan / accrual date
        --
      hr_utility.set_location('Step ' || l_proc,80);
        l_ret := Get_fr_holidays_booked_list (
                P_assignment_id                  => p_assignment_id
               ,p_business_Group_id              => l_fr_plan_info.business_Group_id
               ,P_accrual_plan_id                => p_accrual_plan_id
               ,p_accrual_start_date             => l_fr_plan_info.accrual_year_start
               ,p_accrual_end_date               => l_fr_plan_info.accrual_year_end
               ,p_holiday_element_id             => l_fr_plan_info.holiday_element_id
               ,p_total_m                        => l_booked_m
               ,p_total_p                        => l_booked_p
               ,p_total_c                        => l_booked_c
               ,p_total_s                        => l_booked_s
               ,p_total_y                        => l_booked_y );
         hr_utility.set_location('Step ' || l_proc,90);
      END IF;
    ELSE
      IF p_type_calculation = 'Y' then         /* payslip */
         hr_utility.trace('P type = Y');
        -- This calculation is for the payslip - deduct holidays paid for asg / plan / year
        --
        open csr_previous_action_sequence;
        fetch csr_previous_action_sequence into l_action_sequence;
        close csr_previous_action_sequence;
        open csr_previous_paid_absences;
        fetch csr_previous_paid_absences into l_previous_paid_absences;
        l_previous_paid_absences := nvl(l_previous_paid_absences, 0);
        hr_utility.trace('l_previous_paid_absences is ' || l_previous_paid_absences);
        close csr_previous_paid_absences;
        hr_utility.set_location('Step ' || l_proc,100);
        open csr_previous_paid_absences_r;
        fetch csr_previous_paid_absences_r into l_previous_paid_absences_retro;
        l_previous_paid_absences_retro := nvl(l_previous_paid_absences_retro, 0);
        l_previous_paid_absences := nvl(l_previous_paid_absences, 0) + l_previous_paid_absences_retro;
        hr_utility.trace('l_previous_paid_absences is ' || l_previous_paid_absences);
        close csr_previous_paid_absences_r;
        hr_utility.set_location('Step ' || l_proc,110);
        --
        -- This calculation is for the payslip - find holidays taken this period
        --
        open csr_current_action_sequence;
        fetch csr_current_action_sequence into l_action_sequence;
        close csr_current_action_sequence;
        hr_utility.trace('csr_current_paid_absences is ' || l_Action_sequence);
        hr_utility.trace('p_paid_days_to is ' || to_char(p_paid_days_to));
        open csr_current_paid_absences;
        fetch csr_current_paid_absences into l_current_paid_absences;
        l_current_paid_absences := nvl(l_current_paid_absences, 0);
        hr_utility.trace('l_current_paid_absences is ' || l_current_paid_absences);
        close csr_current_paid_absences;
        hr_utility.set_location('Step ' || l_proc,120);

        open csr_current_paid_absences_r;
        fetch csr_current_paid_absences_r into l_current_paid_absences_retro;
        l_current_paid_absences := nvl(l_current_paid_absences, 0) + nvl(l_current_paid_absences_retro, 0);
        hr_utility.trace('l_current_paid_absences is ' || l_current_paid_absences);
        close csr_current_paid_absences_r;
        hr_utility.set_location('Step ' || l_proc,130);

        -- Added code for termination
        l_current_paid_absences := l_current_paid_absences + nvl(l_term_payment,0);
        --
      ELSE
         hr_utility.trace('P type = ACCRUALS');
        --
        -- This calculation is for accruals - deduct all hols taken prior to date earned.
        --
        open csr_previous_and_current_seq;
        fetch csr_previous_and_current_seq into l_action_sequence;
        close csr_previous_and_current_seq;
        hr_utility.trace('csr_prev_and_current_paid_abs is ' || l_action_sequence);
        open csr_prev_and_current_paid_abs;
        fetch csr_prev_and_current_paid_abs into l_previous_paid_absences;
        close csr_prev_and_current_paid_abs;
        hr_utility.set_location('Step ' || l_proc,135);

        open csr_prev_and_cur_paid_abs_r;
        fetch csr_prev_and_cur_paid_abs_r into l_previous_paid_absences_retro;
        close csr_prev_and_cur_paid_abs_r;
        l_previous_paid_absences  := nvl(l_previous_paid_absences,0) + nvl(l_previous_paid_absences_retro,0);
        hr_utility.set_location('Step ' || l_proc,145);

         -- Added code for termination
	 l_previous_paid_absences := l_previous_paid_absences + nvl(l_term_payment,0);
         --
      END IF;
    END IF;
    --
    -- Modified for termination
    --
    hr_utility.set_location('Step ' || l_proc,150);

  hr_utility.trace('l_ent_m is ' || l_ent_m);
  hr_utility.trace('l_ent_p is ' || l_ent_p);
  hr_utility.trace('l_ent_c is ' || l_ent_c);
  hr_utility.trace('l_ent_s is ' || l_ent_s);
  hr_utility.trace('l_ent_y is ' || l_ent_y);


    l_net_main          := nvl(l_ent_m,0) + nvl(l_adj_m,0) + nvl(l_obs_m,0) - nvl(l_booked_m,0)- nvl(l_term_payment,0);
    hr_utility.trace('l_term_payment is ' || l_term_payment);
    hr_utility.trace('l_booked_m is ' || l_booked_m);
    hr_utility.trace('18 l_NET_main is ' || l_net_main);
    -- replaced out paramter with declared variable
    l_net_protected     := nvl(l_ent_p,0) + nvl(l_adj_p,0) + nvl(l_obs_p,0) - nvl(l_booked_p,0);
    -- Bug 2861012
    l_net_conventional  := nvl(l_ent_c,0) + nvl(l_adj_c,0) + nvl(l_obs_c,0) - nvl(l_booked_c,0);
    l_net_seniority     := nvl(l_ent_s,0) + nvl(l_adj_s,0) + nvl(l_obs_s,0) - nvl(l_booked_s,0);
    l_net_young_mothers := nvl(l_ent_y,0) + nvl(l_adj_y,0) + nvl(l_obs_y,0) - nvl(l_booked_y,0);
    --
    -- End of modified code
    p_remaining := l_net_main
               + l_net_protected /* replaced out paramter */
        /*     + p_net_seniority
               + p_net_young_mothers
               + p_net_conventional; */
        -- Bug 2861012
               + l_net_seniority
               + l_net_young_mothers
               + l_net_conventional;

    if p_ignore_ent_adjustments = 'N' THEN
    hr_utility.trace('P_IGNORE ENT ADJ IS N');
      l_ent_main          := nvl(l_ent_m,0) + nvl(l_adj_m,0);
      l_ent_protected     := nvl(l_ent_p,0) + nvl(l_adj_p,0);
      l_ent_conventional  := nvl(l_ent_c,0) + nvl(l_adj_c,0);
      l_ent_seniority     := nvl(l_ent_s,0) + nvl(l_adj_s,0);
      l_ent_young_mothers := nvl(l_ent_y,0) + nvl(l_adj_y,0);
      hr_utility.set_location('Step ' || l_proc,120);
      hr_utility.trace('20 l_ent_main ' || l_ent_main);
    ELSE
      hr_utility.trace('P_IGNORE ENT ADJ IS Y');
      l_ent_main          := nvl(l_ent_m,0);
      l_ent_protected     := nvl(l_ent_p,0);
      l_ent_conventional  := nvl(l_ent_c,0);
      l_ent_seniority     := nvl(l_ent_s,0);
      l_ent_young_mothers := nvl(l_ent_y,0);
      hr_utility.set_location('Step ' || l_proc,130);
      hr_utility.trace('21 l_ent_main ' || l_ent_main);
    END IF;
  IF p_type_calculation = 'Y' or p_type_calculation = 'A' THEN /* paYslip or Accruals */
    hr_utility.trace('IN Y OR A - resetting l_ent_main');
    hr_utility.trace('22 l_NET_main is ' || l_net_main);
    --
    -- Use only the net main and ent main OUT variables as totals. Still include termination paid days.
    -- Replaced out paramter p_net_protected

    -- carry out similar change for p_net_conventional,p_net_seniority and p_net_young_mothers
    -- Bug 2861012
    l_ent_main          := l_net_main + l_net_protected + l_net_conventional + l_net_seniority + l_net_young_mothers - nvl(l_previous_paid_absences,0);
    hr_utility.set_location('l_ent_main: '||to_char(l_ent_main), 22);
    l_net_main          := nvl(l_current_paid_absences,0);
    l_net_protected     := 0;

    -- Bug 2861012
    l_net_conventional  := 0;
    l_net_seniority     := 0;
    l_net_young_mothers := 0;
    l_ent_protected     := 0;
    l_ent_young_mothers := 0;
    l_ent_seniority     := 0;
    l_ent_conventional  := 0;
    p_remaining         := nvl(l_term_payment,0);
    hr_utility.set_location('Step ' || l_proc,160);
  END IF;

  p_accrual_start_date := l_fr_plan_info.accrual_year_start;
  p_accrual_end_date   := l_fr_plan_info.accrual_year_end;

  -- Assigning value of local variable to out parameter
  p_net_main          := l_net_main;
  p_net_protected     := l_net_protected;
  p_net_conventional  := l_net_conventional;
  p_net_seniority     := l_net_seniority;
  p_net_young_mothers := l_net_young_mothers;
  p_ent_main          := l_ent_main;
  p_ent_protected     := l_ent_protected;
  p_ent_conventional  := l_ent_conventional;
  p_ent_seniority     := l_ent_seniority;
  p_ent_young_mothers := l_ent_young_mothers;

  hr_utility.set_location('p_ent_main is :'||to_char(p_ent_main), 22);
  hr_utility.set_location('Leaving:  '||l_proc,170);
end get_fr_net_entitlement;
--------------------------------------------------------------------------------
-- Read_Regularization_Payment
--------------------------------------------------------------------------------
Function read_regularization_payment
(p_accrual_plan_id IN number,
 p_index                 IN  number,
 p_reg_payment    OUT NOCOPY number,
 p_accrual_date    OUT NOCOPY date,
 p_next_payment  OUT NOCOPY number)
 return number is

l_index number;

begin

 l_index := p_index;

 if p_index is null OR p_index = 0 Then
    l_index := p_accrual_plan_id * 10 + 1;
 end if;

 p_reg_payment := reg_payment(l_index).payment;
 p_accrual_date := reg_payment(l_index).accrual_date;
 p_next_payment := nvl(reg_payment(l_index).next_payment, 0);

 return 0;
EXCEPTION
WHEN OTHERS THEN
   Raise;

end read_regularization_payment;
---------------------------------------------------------------------------------
-- Write_Regularization_Payment
-------------------------------------------------------------------------------
Function write_regularization_payment
(p_accrual_plan_id  number,
 p_y0_reg_payment number,
 p_y0_accrual_date date,
 p_y1_reg_payment number,
 p_y1_accrual_date date,
 p_y2_reg_payment number,
 p_y2_accrual_date date,
 p_y3_reg_payment number,
 p_y3_accrual_date date
) return number is

i number;
last_i number;

begin
  i := p_accrual_plan_id * 10;
  if p_y0_reg_payment <> 0 and p_y0_reg_payment is not null then
    i := i+1;
    reg_payment(i).payment         := p_y0_reg_payment;
    reg_payment(i).accrual_date  := p_y0_accrual_date;
    reg_payment(i).next_payment := 0;
    last_i := i;
  end if;

  if p_y1_reg_payment <> 0 and p_y1_reg_payment is not null then
     i := i+1;
     reg_payment(i).payment      := p_y1_reg_payment;
     reg_payment(i).accrual_date := p_y1_accrual_date;
     reg_payment(i).next_payment := 0;

    if last_i is not null then
       reg_payment(last_i).next_payment := i;
    end if;

    last_i := i;
  end if;

  if p_y2_reg_payment <> 0 and p_y2_reg_payment is not null then
    i := i+1;
   reg_payment(i).payment      := p_y2_reg_payment;
   reg_payment(i).accrual_date := p_y2_accrual_date;
   reg_payment(i).next_payment := 0;

    if last_i is not null then
       reg_payment(last_i).next_payment := i;
    end if;

    last_i := i;
  end if;

  if p_y3_reg_payment <> 0 and p_y3_reg_payment is not null then
    i := i+1;
    reg_payment(i).payment      := p_y3_reg_payment;
    reg_payment(i).accrual_date := p_y3_accrual_date;
    reg_payment(i).next_payment := 0;

    if last_i is not null then
       reg_payment(last_i).next_payment := i;
    end if;

    last_i := i;
  end if;

  return 0;

EXCEPTION
WHEN OTHERS THEN
   Raise;

end write_regularization_payment;
--
-------------------------------------------------------------------------------
-- Get_fr_reg_payments
-------------------------------------------------------------------------------

function Get_fr_reg_payments
(p_assignment_id       IN Number
,p_date_earned         IN Date
,p_accrual_plan_id     IN Number
,p_calculation_date    IN Date
,p_y0_term_payments    IN Number
,p_y1_term_payments    IN Number
,p_global_reg_sal_pct  IN Number
,p_daily_rate          IN Number
,p_y0_regularized_amt  OUT NOCOPY Number
,p_y1_regularized_amt  OUT NOCOPY Number
,p_y2_regularized_amt  OUT NOCOPY Number
,p_y3_regularized_amt  OUT NOCOPY Number
,p_y0_accrual_date     OUT NOCOPY Date
,p_y1_accrual_date     OUT NOCOPY Date
,p_y2_accrual_date     OUT NOCOPY Date
,p_y3_accrual_date     OUT NOCOPY Date
,p_reg_option_flg      OUT NOCOPY Varchar2
) return number is
--
l_proc                     varchar2(72) := g_package||'Get_fr_reg_payments';
l_regularize_possible      Varchar2(3);
l_session_date             Date;
l_accrued_start_date       Date;
l_accrued_end_date         Date;
l_reference_days_accrued   Number;
l_total_days_to_regularize Number;
l_original_payment         Number;
l_tot_days_to_regularize_retro Number;
l_original_payment_retro   Number;
l_previous_reg_payment     Number;
l_term_reg_payments        Number;
l_new_payment              Number;
l_reference_salary         Number;
l_return                   Number;
l_yr_count                 Number;
l_action_sequence   Number;
l_next_accrued_end_date    Date;
l_fr_pay_info           g_fr_pay_info;
l_fr_pay_r_info           g_fr_pay_info;
l_reg_option_flg      Varchar2(3);

TYPE l_yr_payments_rec IS RECORD(
     l_accrual_date          Date,
     l_regularized_payment   Number,
     l_term_payments         Number);
TYPE l_yr_payments_tab is TABLE of l_yr_payments_rec INDEX by BINARY_INTEGER;
l_yr_payments          l_yr_payments_tab;
--
-- Cursor for finding number of days to be regularized
-- and holiday payments made
-- in case of unregularized payments
Cursor csr_paid_absence  IS
select sum(prrv_days.result_value), sum(prrv_pay.result_value)
from   pay_run_result_values  prrv_days
      ,pay_run_result_values  prrv_pay
      ,pay_run_result_values  prrv_accrual
      ,pay_run_result_values  prrv_flag
      ,pay_run_result_values  prrv_plan
      ,pay_run_results        prr
      ,pay_assignment_actions paa
where  prrv_days.run_result_id     = prr.run_result_id
  and  prrv_pay.run_result_id      = prr.run_result_id
  and  prrv_plan.run_result_id     = prr.run_result_id
  and  prrv_flag.run_result_id     = prr.run_result_id
  and  prrv_accrual.run_result_id  = prr.run_result_id
  and  prrv_days.input_value_id    = l_fr_pay_info.pay_total_days_input_ID
  and  prrv_pay.input_value_id     = l_fr_pay_info.pay_payment_input_ID
  and  prrv_accrual.input_value_id = l_fr_pay_info.pay_accrual_date_input_ID
  and  prrv_plan.input_value_id    = l_fr_pay_info.pay_plan_input_ID
  and  prrv_flag.input_value_id    = l_fr_pay_info.pay_flag_input_ID
  and  prr.assignment_action_id    = paa.assignment_action_id
  and  paa.assignment_id           = p_assignment_id
  and  prr.element_type_id         = l_fr_pay_info.pay_element_id
  and  prr.status                  in ('P','PA')
  and  prrv_accrual.result_value
                  between fnd_date.date_to_canonical(l_accrued_start_date)
                  and fnd_date.date_to_canonical(l_accrued_end_date);
--
-- Cursor for finding number of days to be regularized
-- and holiday payments made
-- in case of unregularized payments retro
Cursor csr_paid_absence_r  IS
select sum(prrv_days.result_value), sum(prrv_pay.result_value)
from   pay_run_result_values  prrv_days
      ,pay_run_result_values  prrv_pay
      ,pay_run_result_values  prrv_accrual
      ,pay_run_result_values  prrv_flag
      ,pay_run_result_values  prrv_plan
      ,pay_run_results        prr
      ,pay_assignment_actions paa
where  prrv_days.run_result_id     = prr.run_result_id
  and  prrv_pay.run_result_id      = prr.run_result_id
  and  prrv_plan.run_result_id     = prr.run_result_id
  and  prrv_flag.run_result_id     = prr.run_result_id
  and  prrv_accrual.run_result_id  = prr.run_result_id
  and  prrv_days.input_value_id    = l_fr_pay_r_info.pay_total_days_input_ID
  and  prrv_pay.input_value_id     = l_fr_pay_r_info.pay_payment_input_ID
  and  prrv_accrual.input_value_id = l_fr_pay_r_info.pay_accrual_date_input_ID
  and  prrv_plan.input_value_id    = l_fr_pay_r_info.pay_plan_input_ID
  and  prrv_flag.input_value_id    = l_fr_pay_r_info.pay_flag_input_ID
  and  prr.assignment_action_id    = paa.assignment_action_id
  and  paa.assignment_id           = p_assignment_id
  and  prr.element_type_id         = l_fr_pay_r_info.pay_element_id
  and  prr.status                 in ('P','PA')
  and  prrv_accrual.result_value
                  between fnd_date.date_to_canonical(l_accrued_start_date)
                  and fnd_date.date_to_canonical(l_accrued_end_date);
--
-- Cursor to fetch all previous regularized payments
Cursor csr_prev_reg_pymt IS
select sum(prrv_pay.result_value)
from   pay_run_result_values  prrv_pay
      ,pay_run_result_values  prrv_accrual
      ,pay_run_result_values  prrv_plan
      ,pay_run_results        prr
      ,pay_assignment_actions paa
where  prrv_pay.run_result_id      = prr.run_result_id
  and  prrv_plan.run_result_id     = prr.run_result_id
  and  prrv_accrual.run_result_id  = prr.run_result_id
  and  prrv_pay.input_value_id     = l_fr_pay_info.pay_reg_payment_input_ID
  and  prrv_accrual.input_value_id = l_fr_pay_info.pay_reg_date_input_ID
  and  prrv_plan.input_value_id    = l_fr_pay_info.pay_reg_plan_input_ID
  and  prr.assignment_action_id    = paa.assignment_action_id
  and  paa.assignment_id           = p_assignment_id
  and  prr.element_type_id         = l_fr_pay_info.pay_reg_element_id
  and  prr.status                 in ('P','PA')
  and  prrv_accrual.result_value
            between fnd_date.date_to_canonical(l_accrued_start_date)
	    and fnd_date.date_to_canonical(l_accrued_end_date);

-- Cursor to fetch all previous regularized payments retro
Cursor csr_prev_reg_pymt_r IS
select sum(prrv_pay.result_value)
from   pay_run_result_values  prrv_pay
      ,pay_run_result_values  prrv_accrual
      ,pay_run_result_values  prrv_plan
      ,pay_run_results        prr
      ,pay_assignment_actions paa
where  prrv_pay.run_result_id      = prr.run_result_id
  and  prrv_plan.run_result_id     = prr.run_result_id
  and  prrv_accrual.run_result_id  = prr.run_result_id
  and  prrv_pay.input_value_id     = l_fr_pay_r_info.pay_reg_payment_input_ID
  and  prrv_accrual.input_value_id = l_fr_pay_r_info.pay_reg_date_input_ID
  and  prrv_plan.input_value_id    = l_fr_pay_r_info.pay_reg_plan_input_ID
  and  prr.assignment_action_id    = paa.assignment_action_id
  and  paa.assignment_id           = p_assignment_id
  and  prr.element_type_id         = l_fr_pay_r_info.pay_reg_element_id
  and  prr.status                 in ('P','PA')
  and  prrv_accrual.result_value
            between fnd_date.date_to_canonical(l_accrued_start_date)
	    and fnd_date.date_to_canonical(l_accrued_end_date);
--
--
-- Cursor to fetch regularised payments on termination
Cursor csr_fetch_term_reg_pymts IS
select sum(nvl(prrv_pay.result_value,0)) payments
  from pay_run_result_values  prrv_pay
      ,pay_run_result_values  prrv_accrual
      ,pay_run_result_values  prrv_plan
      ,pay_element_types_f    petf
      ,pay_input_values_f     pivf_pay
      ,pay_input_values_f     pivf_accrual
      ,pay_input_values_f     pivf_plan
      ,pay_run_results        prr
      ,pay_assignment_actions paa
where  prrv_pay.run_result_id      = prr.run_result_id
  and  prrv_plan.run_result_id     = prr.run_result_id
  and  prrv_accrual.run_result_id  = prr.run_result_id
  and  prrv_pay.input_value_id     = pivf_pay.input_value_id
  and  prrv_accrual.input_value_id = pivf_accrual.input_value_id
  and  prrv_plan.input_value_id    = pivf_plan.input_value_id
  --
  and  petf.element_name           = 'FR_TERMINATION_REGULARIZE'
  and petf.legislation_code        = 'FR'
  and  pivf_pay.element_type_id    = petf.element_type_id
  and  prr.status                 in ('P','PA')
  and  pivf_pay.name               = 'Pay Value'
  and  pivf_accrual.element_type_id= petf.element_type_id
  and  pivf_plan.element_type_id   = petf.element_type_id
  and  pivf_accrual.name           = 'Accrual Date'
  and  pivf_plan.name              = 'Accrual Plan ID'
  --
  and  prr.assignment_action_id    = paa.assignment_action_id
  and  prrv_plan.result_value      = p_accrual_plan_id
  and  paa.action_sequence        <= nvl(l_action_sequence, paa.action_sequence)
  and  paa.assignment_id           = p_assignment_id
  and  prr.element_type_id         = petf.element_type_id
  and  prrv_accrual.result_value
       between fnd_date.date_to_canonical(l_accrued_start_date)
          and fnd_date.date_to_canonical(l_accrued_end_date);

-- Cursor to check whether user has opted for regularization
Cursor csr_reg_option_flg IS
Select nvl(INFORMATION30, 'N') reg_flg
  from pay_accrual_plans
where ACCRUAL_PLAN_ID = p_accrual_plan_id
   and  INFORMATION_CATEGORY in ('FR_FR_MAIN_HOLIDAY', 'FR_FR_RTT_HOLIDAY', 'FR_FR_ADDITIONAL_HOLIDAY');
--
Begin
--
-- Check whether regularization is to be done
OPEN csr_reg_option_flg;
FETCH csr_reg_option_flg INTO l_reg_option_flg;
CLOSE csr_reg_option_flg;
--
IF l_reg_option_flg ='N' THEN
   -- initialise OUT parameters
   p_y0_regularized_amt := 0;
   p_y1_regularized_amt := 0;
   p_y2_regularized_amt := 0;
   p_y3_regularized_amt := 0;
   p_y0_accrual_date := to_date('01-01-0001', 'dd-mm-yyyy');
   p_y1_accrual_date := to_date('01-01-0001', 'dd-mm-yyyy');
   p_y2_accrual_date := to_date('01-01-0001', 'dd-mm-yyyy');
   p_y3_accrual_date := to_date('01-01-0001', 'dd-mm-yyyy');
   p_reg_option_flg := l_reg_option_flg;
   --
ELSE
   -- Estimate regularization amount
   l_fr_pay_info := get_payment_globals;
   l_fr_pay_r_info := get_payment_globals_r;
   --
   l_next_accrued_end_date := p_calculation_date;
   l_yr_payments(1).l_term_payments := nvl(p_y0_term_payments,0);
   l_yr_payments(2).l_term_payments := nvl(p_y1_term_payments,0);
    --
   FOR l_yr_count in 1..4 LOOP
        -- Intiialize the accrual date
        l_yr_payments(l_yr_count).l_accrual_date:= l_next_accrued_end_date;
        --
        l_return := pay_fr_pto_pkg.Get_fr_holiday_reg_details
                          (p_assignment_id           => p_assignment_id
                          ,p_date_earned             => p_date_earned
                          ,P_accrual_plan_id         => p_accrual_plan_id
                          ,P_accrual_date            => l_yr_payments(l_yr_count).l_accrual_date
                          ,P_accrue_start_Date       => l_accrued_start_date
                          ,P_accrue_end_date         => l_accrued_end_date
                          ,P_reference_entitlement   => l_reference_days_accrued
                          ,p_reference_salary        => l_reference_salary
                          ,p_session_date            => l_session_date
                          ,p_regularization_possible => l_regularize_possible
                          ,p_total_days_paid         => l_total_days_to_regularize
                          ,p_total_payment_made      => l_original_payment
                          ,p_previous_reg_payments   => l_previous_reg_payment);
       --
       -- if regularization is possible, calculate the regularized payment
      IF l_regularize_possible = 'Y' THEN
          -- Calculate the regularized Amount
          IF l_yr_count = 1 OR l_yr_count = 2 THEN
              l_reference_salary := l_reference_salary + l_yr_payments(l_yr_count).l_term_payments;
          END IF;
          l_new_payment := ((p_global_reg_sal_pct/100) * l_reference_salary * l_total_days_to_regularize)/l_reference_days_accrued;
          l_yr_payments(l_yr_count).l_regularized_payment:= GREATEST(0, (l_new_payment - l_original_payment - l_previous_reg_payment));
      ELSE
           -- Calculate the number of days to be regularized
          -- and the holiday payments made
          OPEN csr_paid_absence;
          FETCH csr_paid_absence INTO l_total_days_to_regularize, l_original_payment;
          CLOSE csr_paid_absence;
     l_total_days_to_regularize := nvl(l_total_days_to_regularize, 0);
     l_original_payment := nvl(l_original_payment, 0);

           -- Calculate the number of days to be regularized retro
          OPEN csr_paid_absence_r;
          FETCH csr_paid_absence_r INTO l_tot_days_to_regularize_retro, l_original_payment_retro;
          CLOSE csr_paid_absence_r;
     l_total_days_to_regularize := l_total_days_to_regularize + nvl(l_tot_days_to_regularize_retro,0);
     l_original_payment := l_original_payment + nvl(l_original_payment_retro, 0);

           -- Calculate previous regularized payment
          OPEN csr_prev_reg_pymt;
          FETCH csr_prev_reg_pymt INTO l_previous_reg_payment;
          CLOSE csr_prev_reg_pymt;
     l_previous_reg_payment := nvl(l_previous_reg_payment, 0);
          -- Calculate the holiday payments made
          -- fetch all regularization payments paid by termination element
          OPEN csr_fetch_term_reg_pymts;
          FETCH csr_fetch_term_reg_pymts INTO l_term_reg_payments;
          CLOSE csr_fetch_term_reg_pymts;
     l_term_reg_payments := nvl(l_term_reg_payments, 0);
          -- Add the termination payments to the previous regularization payments
          l_previous_reg_payment := l_previous_reg_payment + l_term_reg_payments;
          --
          -- Calculate the total regularization payment to be made
          -- (the p_daile_rate  is equal to the earnings for each day, i.e.
          -- either the FR_SUBJECT_TO_EARNINGS_DEDUCTION_ASG_PTD balance
          -- or the notice period payment
          -- divided by the corresponding number of days)
          l_new_payment := p_daily_rate * l_total_days_to_regularize;
         --
         -- Calculate the net regularization payment
          l_yr_payments(l_yr_count).l_regularized_payment:= GREATEST(0, (l_new_payment - l_original_payment - l_previous_reg_payment));
           --
      END IF;
       -- Calculate and store the previous year accrual date
      l_next_accrued_end_date := add_months(l_accrued_end_date, -12);
   END LOOP;
   -- populate OUT variables
   p_y0_regularized_amt := l_yr_payments(1).l_regularized_payment;
   p_y1_regularized_amt := l_yr_payments(2).l_regularized_payment;
   p_y2_regularized_amt := l_yr_payments(3).l_regularized_payment;
   p_y3_regularized_amt := l_yr_payments(4).l_regularized_payment;
   p_y0_accrual_date    := l_yr_payments(1).l_accrual_date;
   p_y1_accrual_date    := l_yr_payments(2).l_accrual_date;
   p_y2_accrual_date    := l_yr_payments(3).l_accrual_date;
   p_y3_accrual_date    := l_yr_payments(4).l_accrual_date;
   p_reg_option_flg := l_reg_option_flg;
   --
END IF;
Return 1;
END;

--
---------------------------------------------------------------------------------
-- Get_FR_HOLIDAY_REG_DETAILS                                  REG Fast Formula
-------------------------------------------------------------------------------
function Get_fr_holiday_reg_details
(P_assignment_id                  IN Number
,p_date_earned                    IN Date
,P_accrual_plan_id                IN Number
,P_accrual_date                   IN Date
,P_accrue_start_Date             OUT NOCOPY Date     /* period start date of accrual year   */
,P_accrue_end_date               OUT NOCOPY Date     /* period start date of accrual year   */
,P_reference_entitlement         OUT NOCOPY Number   /* The main days of entitlement in the accrual year  */
,p_reference_salary              OUT NOCOPY Number   /* the salary (stored on entitlement element)    */
,p_session_date                  OUT NOCOPY Date     /* The sesssion date */
,p_regularization_possible       OUT NOCOPY Varchar2 /* flag if this accrual period is not yet closed as as session date */
,p_total_days_paid               OUT NOCOPY Number   /* The number of days paid in this accrual year      */
,p_total_payment_made            OUT NOCOPY Number   /* The original payment made for those days          */
,p_previous_reg_payments         OUT NOCOPY Number   /* Any previous regularization payments made         */
) return number is
--
l_proc        varchar2(72) := g_package||'Get_FR_holiday_reg_details';

l_remaining                           Number := 0;
l_unused                              Number := 0;
l_accrue_start_Date                   Date;
l_accrue_end_date                     Date;
l_reference_entitlement               Number := 0;
l_session_date                        Date;
l_regularization_possible             Varchar2(10);
l_reference_salary                    Number;
l_total_days_paid                     Number := 0;
l_total_payment_made                  Number := 0;
l_total_days_paid_r                   Number := 0;
l_total_payment_made_r                Number := 0;
l_previous_reg_payments               Number := 0;
l_term_reg_payments                   Number := 0;
l_action_sequence                     PAY_ASSIGNMENT_ACTIONS.ACTION_SEQUENCE%TYPE := null;
--
l_fr_plan_info g_fr_plan_info;
l_fr_pay_info g_fr_pay_info;
l_fr_pay_r_info g_fr_pay_info;
--
cursor       csr_session_date is
             select effective_date
             from   fnd_sessions
             where  session_id = USERENV('SESSIONID');
--
-- Get the termination regularization amount
--

Cursor csr_fetch_term_reg_pymts IS
select sum(nvl(prrv_pay.result_value,0)) payments
  from pay_run_result_values  prrv_pay
      ,pay_run_result_values  prrv_accrual
      ,pay_run_result_values  prrv_plan
      ,pay_element_types_f    petf
      ,pay_input_values_f     pivf_pay
      ,pay_input_values_f     pivf_accrual
      ,pay_input_values_f     pivf_plan
      ,pay_run_results        prr
      ,pay_assignment_actions paa
where  prrv_pay.run_result_id      = prr.run_result_id
  and  prrv_plan.run_result_id     = prr.run_result_id
  and  prrv_accrual.run_result_id  = prr.run_result_id
  and  prrv_pay.input_value_id     = pivf_pay.input_value_id
  and  prrv_accrual.input_value_id = pivf_accrual.input_value_id
  and  prrv_plan.input_value_id    = pivf_plan.input_value_id
  --
  and  petf.element_name           = 'FR_TERMINATION_REGULARIZE'
  and petf.legislation_code        = 'FR'
  and  pivf_pay.element_type_id    = petf.element_type_id
  and  pivf_pay.name               = 'Pay Value'
  and  pivf_accrual.element_type_id= petf.element_type_id
  and  pivf_plan.element_type_id   = petf.element_type_id
  and  pivf_accrual.name           = 'Accrual Date'
  and  pivf_plan.name              = 'Accrual Plan ID'
  --
  and  prr.assignment_action_id    = paa.assignment_action_id
  and  prrv_plan.result_value      = p_accrual_plan_id
  and  paa.action_sequence        <= nvl(l_action_sequence, paa.action_sequence)
  and  paa.assignment_id           = p_assignment_id
  and  prr.element_type_id         = petf.element_type_id
  and  prr.status                 in ('P','PA')
  and  prrv_accrual.result_value    between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                    and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);

--
-- Get the payments made for all absences in this accrual year. (NOT regularization payments)
--

CURSOR       csr_fetch_all_reg_payments is
             select sum(prrv_pay.result_value)
             from   pay_run_result_values  prrv_pay
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
            where  prrv_pay.run_result_id      = prr.run_result_id
              and  prrv_plan.run_result_id     = prr.run_result_id
              and  prrv_accrual.run_result_id  = prr.run_result_id
              and  prrv_pay.input_value_id     = l_fr_pay_info.pay_reg_payment_input_ID
              and  prrv_accrual.input_value_id = l_fr_pay_info.pay_reg_date_input_ID
              and  prrv_plan.input_value_id    = l_fr_pay_info.pay_reg_plan_input_ID
              and  prr.assignment_action_id    = paa.assignment_action_id
              and  prrv_plan.result_value      = p_accrual_plan_id
              and  paa.action_sequence        <= nvl(l_action_sequence, paa.action_sequence)
              and  paa.assignment_id           = p_assignment_id
              and  prr.element_type_id         = l_fr_pay_info.pay_reg_element_id
              and  prr.status                 in ('P','PA')
              and  prrv_accrual.result_value    between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);

--
-- Get the payments made for all absences in this accrual year. (NOT regularization payments)
--

CURSOR       csr_fetch_all_paid_absences is
             select sum(prrv_days.result_value), sum(prrv_pay.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_pay
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_pay.run_result_id      = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_info.pay_total_days_input_ID
               and  prrv_pay.input_value_id     = l_fr_pay_info.pay_payment_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_info.pay_plan_input_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.element_type_id         = l_fr_pay_info.pay_element_id
               and  prr.status                 in ('P','PA')
               and  prrv_plan.result_value      = p_accrual_plan_id
               and  paa.action_sequence        <= l_action_sequence
               and  prrv_accrual.result_value    between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                     and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);
CURSOR       csr_fetch_all_paid_absences_r is
             select sum(prrv_days.result_value), sum(prrv_pay.result_value)
             from   pay_run_result_values  prrv_days
                   ,pay_run_result_values  prrv_pay
                   ,pay_run_result_values  prrv_accrual
                   ,pay_run_result_values  prrv_plan
                   ,pay_run_results        prr
                   ,pay_assignment_actions paa
             where  prrv_days.run_result_id     = prr.run_result_id
               and  prrv_pay.run_result_id      = prr.run_result_id
               and  prrv_plan.run_result_id     = prr.run_result_id
               and  prrv_accrual.run_result_id  = prr.run_result_id
               and  prrv_days.input_value_id    = l_fr_pay_r_info.pay_total_days_input_ID
               and  prrv_pay.input_value_id     = l_fr_pay_r_info.pay_payment_input_ID
               and  prrv_accrual.input_value_id = l_fr_pay_r_info.pay_accrual_date_input_ID
               and  prrv_plan.input_value_id    = l_fr_pay_r_info.pay_plan_input_ID
               and  prr.assignment_action_id    = paa.assignment_action_id
               and  paa.assignment_id           = p_assignment_id
               and  prr.element_type_id         = l_fr_pay_r_info.pay_element_id
               and  prr.status                 in ('P','PA')
               and  prrv_plan.result_value      = p_accrual_plan_id
               and  paa.action_sequence        <= l_action_sequence
               and  prrv_accrual.result_value    between fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_start)
                                                     and fnd_date.date_to_canonical(l_fr_plan_info.accrual_year_end);
CURSOR        csr_action_sequence_all_paid is
              select max(paa.action_sequence)
              from pay_assignment_actions paa
                  ,pay_payroll_Actions    ppa
              where ppa.payroll_action_id = paa.payroll_action_id
                and paa.assignment_id = p_assignment_id;
begin
  hr_utility.set_location('Entering ' || l_proc,10);
 -- --fnd_file.put_line(fnd_file.log,'Entering ' || l_proc);

  --
  -- Fetch the effective_date
  --
  open csr_session_date;
  fetch csr_session_date into l_session_date;
  close csr_session_date;
  --
  -- Ensure globals for this accrual_plan_id are set.
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => p_accrual_plan_id
    ,p_accrual_date             => p_accrual_date );

  hr_utility.set_location('Step ' || l_proc,20);
  --
  -- Get the Payment globals
  --
  l_fr_pay_info := get_payment_globals;
  l_fr_pay_r_info := get_payment_globals_r;
  hr_utility.set_location('Step ' || l_proc,30);
  --
  -- Calculate if the accrual period has ended yet - this is needed as the regularized payment
  -- is only possible if the accrual period is closed and therefore the salary balance is known.
  --
  if p_date_earned >= l_fr_plan_info.accrual_year_end then
    l_regularization_possible := 'Y';
    hr_utility.set_location('Step ' || l_proc,40);
  else
    l_regularization_possible := 'N';
  end if;
  --
  -- If regularization is possible, get the total entitlement for main and protected stored
  -- for this assignment for this accrual period.
  --
  if l_regularization_possible = 'Y' then

/*

    get_reference_entitlement(
      P_ACCRUAL_PLAN_ID        => p_accrual_plan_id
     ,P_ACCRUAL_START_DATE     => l_fr_plan_info.accrual_year_start
     ,P_ACCRUAL_END_DATE       => l_fr_plan_info.accrual_year_end
     ,P_ASSIGNMENT_ID          => p_assignment_id
     ,P_ENT_REF_DAYS_ID        => l_fr_plan_info.ent_reference_days_iv_id
     ,P_ENT_REF_SALARY_ID      => l_fr_plan_info.ent_reference_sal_iv_id
     ,P_ENT_ACCRUAL_DATE_IV_ID => l_fr_plan_info.ent_accrual_date_iv_id
     ,P_REF_MAIN_DAYS          => l_reference_entitlement
     ,P_REF_SALARY             => l_reference_salary);
*/

    get_reference_entitlement(
      P_ACCRUAL_PLAN_ID        => p_accrual_plan_id
     ,P_ACCRUAL_START_DATE     => l_fr_plan_info.accrual_year_start
     ,P_ACCRUAL_END_DATE       => l_fr_plan_info.accrual_year_end
     ,P_ASSIGNMENT_ID          => p_assignment_id
     ,P_ENT_REF_DAYS_ID        => ''
     ,P_ENT_REF_SALARY_ID      => ''
     ,P_ENT_ACCRUAL_DATE_IV_ID => ''
     ,P_REF_MAIN_DAYS          => l_reference_entitlement
     ,P_REF_SALARY             => l_reference_salary);

    hr_utility.set_location('In reg_details, l_reference_entitlement 1 ' , l_reference_entitlement);

    --
    -- A regularization is only posible if the reference salary is non-zero and
    -- the reference days is non-zero.
    --
    IF ((nvl(l_reference_entitlement,0) = 0) OR (nvl(l_reference_salary,0) = 0)) THEN
      l_regularization_possible := 'N';
      hr_utility.set_location('Step ' || l_proc,60);
    END IF;
  end if;
    hr_utility.set_location('In reg_details, l_reference_entitlement 2 ' , l_reference_entitlement);

  --
  -- if a regularization is possible, get the total days paid, and the original payments
  -- paid for these days.
  --
  IF  l_regularization_possible = 'Y' THEN
    open csr_action_sequence_all_paid;
    fetch csr_action_sequence_all_paid into l_action_sequence;
    close csr_action_sequence_all_paid;
    hr_utility.trace('new action seq csr_fetch_all_paid_absences is ' || l_action_sequence);
    open  csr_fetch_all_paid_absences;
    fetch csr_fetch_all_paid_absences into l_total_days_paid, l_total_payment_made;
    close csr_fetch_all_paid_absences;
    --
    -- adjust for any retro paid absences
    open  csr_fetch_all_paid_absences_r;
    fetch csr_fetch_all_paid_absences_r into l_total_days_paid_r, l_total_payment_made_r;
    close csr_fetch_all_paid_absences_r;
    hr_utility.trace('regularization paid absence csr, l_total_days_paid:' || to_char(l_total_days_paid) ||
                     ' l_total_payment_made:'|| to_char(l_total_payment_made) ||
                     ' l_total_days_paid_r:' || to_char(l_total_days_paid_r)  ||
                     ' l_total_payment_made_r:'|| to_char(l_total_payment_made_r));

    l_total_days_paid := l_total_days_paid + nvl(l_total_days_paid_r,0);
    l_total_payment_made := l_total_payment_made + nvl(l_total_payment_made_r,0);

    hr_utility.set_location('Step ' || l_proc,70);
    hr_utility.set_location('In reg_details, l_reference_entitlement 3 ' , l_reference_entitlement);
    -- Also, get the total of regularization payments already made for asg/accrual plan/accrual date
    --
    l_action_sequence := null;
    hr_utility.trace('new action seq csr_fetch_all_reg_payments is ' || l_action_sequence);
    open  csr_fetch_all_reg_payments;
    fetch csr_fetch_all_reg_payments into l_previous_reg_payments;
    close csr_fetch_all_reg_payments;
    hr_utility.set_location('In reg_details, l_reference_entitlement 4 ' , l_reference_entitlement);
    hr_utility.set_location('Step ' || l_proc,80);
    -- fetch all regularization payments paid by termination element
    OPEN csr_fetch_term_reg_pymts;
    FETCH csr_fetch_term_reg_pymts INTO l_term_reg_payments;
    CLOSE csr_fetch_term_reg_pymts;
    l_term_reg_payments := nvl(l_term_reg_payments, 0);
    l_previous_reg_payments := l_previous_reg_payments + l_term_reg_payments;

  END IF;
  IF nvl(l_reference_entitlement,0) = 0 then
     l_regularization_possible := 'N';
  hr_utility.set_location('Step ' || l_proc,90);
  END IF;

  hr_utility.set_location('In reg_details, l_reference_entitlement 5 ' , l_reference_entitlement);
  hr_utility.set_location('l_fr_pay_info.pay_reg_payment_input_ID' , l_fr_pay_info.pay_reg_payment_input_ID);
  hr_utility.set_location('l_fr_pay_info.pay_reg_date_input_ID' , l_fr_pay_info.pay_reg_date_input_ID);
  hr_utility.set_location('l_fr_pay_info.pay_reg_plan_input_ID' , l_fr_pay_info.pay_reg_plan_input_ID);
  hr_utility.set_location('p_assignment_id ' , p_assignment_id );
  hr_utility.set_location('l_fr_pay_info.pay_reg_element_id' , l_fr_pay_info.pay_reg_element_id);
  --
  -- Set Out Variables
  --
  p_accrue_start_Date             := l_fr_plan_info.accrual_year_start;
  p_accrue_end_date               := l_fr_plan_info.accrual_year_end;
  p_reference_entitlement         := nvl(l_reference_entitlement,0);
  p_reference_salary              := nvl(l_reference_salary,0);
  p_session_date                  := l_session_date;
  p_regularization_possible       := l_regularization_possible;
  p_total_days_paid               := nvl(l_total_days_paid,0);
  p_total_payment_made            := nvl(l_total_payment_made,0);
  p_previous_reg_payments         := nvl(l_previous_reg_payments,0);
  --
    hr_utility.set_location('In reg_details, l_reference_entitlement 6 ' , l_reference_entitlement);
    hr_utility.set_location('In reg_details, p_reference_entitlement 7 ' , p_reference_entitlement);


hr_utility.set_location('Leaving:  '||l_proc,100);
return 1;
end Get_fr_holiday_reg_details;
--
-------------------------------------------------------------------------------
-- FUNCTION                                                 GET_PAYMENT_GLOBALS
-------------------------------------------------------------------------------
function get_payment_globals
return g_fr_pay_info is
--
l_unused     number;
  --
CURSOR       csr_input_values (p_input_name in varchar2, p_element_name in varchar2) is
             select  piv.input_value_id, pet.element_type_id
             from    pay_element_types_f pet
                    ,pay_input_values_f  piv
             where   piv.element_Type_id = pet.element_type_id
               and   pet.legislation_code = 'FR'
--               and   piv.legislation_code = 'FR'
               and   pet.element_name = p_element_name
               and   piv.name = p_input_name;


l_fr_pay_info g_fr_pay_info;
l_proc VARCHAR2(72) :=    g_package||' get_payment_globals ';
--
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- load the regularization values into the structure
  --
  open csr_input_values('Pay Value', 'FR_HOLIDAY_REGULARIZE');
  fetch csr_input_values into l_fr_pay_info.pay_reg_payment_input_ID, l_fr_pay_info.pay_reg_element_id;
  close csr_input_values;

  hr_utility.set_location('pay reg element id ' , l_fr_pay_info.pay_reg_element_id);
  hr_utility.set_location('pay reg value iv id ' , l_fr_pay_info.pay_reg_payment_input_ID);

  open csr_input_values('Accrual Plan ID', 'FR_HOLIDAY_REGULARIZE');
  fetch csr_input_values into l_fr_pay_info.pay_reg_plan_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay reg plan iv id ' , l_fr_pay_info.pay_reg_plan_input_ID);

  open csr_input_values('Accrual Date', 'FR_HOLIDAY_REGULARIZE');
  fetch csr_input_values into l_fr_pay_info.pay_reg_date_input_ID, l_unused;
  close csr_input_values;

  hr_utility.set_location('pay reg date iv id ' , l_fr_pay_info.pay_reg_date_input_ID);
  --
  -- load the payment input values into the structure
  --
  open csr_input_values('Rate', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_total_days_input_ID, l_fr_pay_info.pay_element_id;
  close csr_input_values;

  hr_utility.set_location('pay element ID id ' , l_fr_pay_info.pay_element_id);
  hr_utility.set_location('pay total days - rate - iv id ' , l_fr_pay_info.pay_total_days_input_ID);

  open csr_input_values('Protected Days Paid', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_protected_days_input_ID, l_unused;
  close csr_input_values;

  hr_utility.set_location('pay protected days iv id ' , l_fr_pay_info.pay_protected_days_input_ID);

  open csr_input_values('Accrual Date', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_accrual_date_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay date days iv id ' , l_fr_pay_info.pay_accrual_date_input_ID);

  open csr_input_values('Pay Value', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_payment_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay pay value iv id ' , l_fr_pay_info.pay_payment_input_ID);

  open csr_input_values('Regularized Flag', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_flag_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay regularized flag days iv id ' , l_fr_pay_info.pay_flag_input_ID);

  open csr_input_values('Accrual Plan ID', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_plan_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay plan iv id ' , l_fr_pay_info.pay_plan_input_ID);

  open csr_input_values('Absence Attendance ID', 'FR_HOLIDAY_PAY');
  fetch csr_input_values into l_fr_pay_info.pay_abs_attend_input_id, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay abs_attend iv id ' , l_fr_pay_info.pay_abs_attend_input_id);
  --
  hr_utility.set_location('Leaving:  '||l_proc,100);
return l_fr_pay_info;
end get_payment_globals;
-------------------------------------------------------------------------------
-- FUNCTION                                           FR_LATEST_PLAN_START_DATE
-------------------------------------------------------------------------------
function fr_latest_plan_start_date (p_element_entry_id  in number)
return date is

l_proc VARCHAR2(200) :=    g_package||'fr_latest_plan_start_date ';
l_effective_start_date     date;

CURSOR csr_get_effective_start_date is
SELECT min(pee.effective_start_date) start_date
    from pay_element_entries_f pee
   where pee.element_entry_id = p_element_entry_id;

BEGIN

hr_utility.set_location('Entering ' || l_proc, 10);

open csr_get_effective_start_date;
fetch csr_get_effective_start_date into l_effective_start_date;
close csr_get_effective_start_date;

hr_utility.set_location('Assigned the value ' || l_proc, 20);

hr_utility.set_location('Leaving ' || l_proc, 30);

return l_effective_start_date;
end fr_latest_plan_start_date;
--
-------------------------------------------------------------------------------
-- FUNCTION                                              GET_PAYMENT_GLOBALS_R
-------------------------------------------------------------------------------
function get_payment_globals_r
return g_fr_pay_info is
--
l_unused     number;
  --
CURSOR       csr_input_values (p_input_name in varchar2, p_element_name in varchar2) is
             select  piv.input_value_id, pet.element_type_id
             from    pay_element_types_f pet
                    ,pay_input_values_f  piv
             where   piv.element_Type_id = pet.element_type_id
               and   pet.legislation_code = 'FR'
--               and   piv.legislation_code = 'FR'
               and   pet.element_name = p_element_name
               and   piv.name = p_input_name;


l_fr_pay_r_info g_fr_pay_info;
l_proc VARCHAR2(72) :=    g_package||' get_payment_globals_r ';
--
--
BEGIN
  -- load the regularization values into the structure
  --
  open csr_input_values('Amount', 'FR_HOLIDAY_REGULARIZE_INFO_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_reg_payment_input_ID, l_fr_pay_r_info.pay_reg_element_id;
  close csr_input_values;

  hr_utility.set_location('pay reg element id retro' , l_fr_pay_r_info.pay_reg_element_id);
  hr_utility.set_location('pay reg value iv id retro' , l_fr_pay_r_info.pay_reg_payment_input_ID);

  open csr_input_values('Accrual Plan ID', 'FR_HOLIDAY_REGULARIZE_INFO_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_reg_plan_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay reg plan iv id retro' , l_fr_pay_r_info.pay_reg_plan_input_ID);

  open csr_input_values('Accrual Date', 'FR_HOLIDAY_REGULARIZE_INFO_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_reg_date_input_ID, l_unused;
  close csr_input_values;

  hr_utility.set_location('pay reg date iv id retro' , l_fr_pay_r_info.pay_reg_date_input_ID);
  --
  -- load the payment input values into the structure
  --
  open csr_input_values('Days', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_total_days_input_ID, l_fr_pay_r_info.pay_element_id;
  close csr_input_values;

  hr_utility.set_location('pay element ID id retro' , l_fr_pay_r_info.pay_element_id);
  hr_utility.set_location('pay total days - rate - iv id ' , l_fr_pay_r_info.pay_total_days_input_ID);

  open csr_input_values('Protected Days Paid', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_protected_days_input_ID, l_unused;
  close csr_input_values;

  hr_utility.set_location('pay protected days iv id retro' , l_fr_pay_r_info.pay_protected_days_input_ID);

  open csr_input_values('Accrual Date', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_accrual_date_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay date days iv id retro' , l_fr_pay_r_info.pay_accrual_date_input_ID);

  open csr_input_values('Amount', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_payment_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay amount iv id retro' , l_fr_pay_r_info.pay_payment_input_ID);

  open csr_input_values('Regularized Flag', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_flag_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay regularized flag days iv id retro' , l_fr_pay_r_info.pay_flag_input_ID);

  open csr_input_values('Accrual Plan ID', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_plan_input_ID, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay plan iv id retro' , l_fr_pay_r_info.pay_plan_input_ID);

  open csr_input_values('Absence Attendance ID', 'FR_HOLIDAY_PAY_DAYS_RETRO');
  fetch csr_input_values into l_fr_pay_r_info.pay_abs_attend_input_id, l_unused;
  close csr_input_values;
  hr_utility.set_location('pay abs_attend iv id retro' , l_fr_pay_r_info.pay_abs_attend_input_id);
  --
  hr_utility.set_location('Leaving:  '||l_proc,100);
return l_fr_pay_r_info;
end get_payment_globals_r;
--
-------------------------------------------------------------------------------
-- FR_CREATE_ENTITLEMENT
-------------------------------------------------------------------------------
procedure fr_create_entitlement
(ERRBUF               OUT NOCOPY varchar2
,RETCODE              OUT NOCOPY number
,P_business_group_id  IN  number
,p_assignment_id      IN  number DEFAULT Null
,P_calculation_date   IN  varchar2
,P_accrual_date       IN  varchar2
,P_plan_id            IN  number
,P_type               IN  varchar2
 ) is
--
--   p_type can be :
--     'ENT' to create entitlement in MAIN or RTT
--     'OBS' to obsolete entitlement in MAIN, RTT or ADDitional
--     'ADD' to create additional days in an FR_ADDITIONAL_DAYS plan.
--
l_dummy                   varchar2(10);
l_calculation_date        date := to_date(p_calculation_date, 'YYYY/MM/DD HH24:MI:SS');
l_accrual_date            date := to_date(p_accrual_date, 'YYYY/MM/DD HH24:MI:SS');
l_accrual_plan_element_id Number;   /* asg - accrual plan member link */
l_index                   Number := 1;
l_balance_type_id         Number;
l_latest_aa               Number;
l_asg_count               Number := 0;
-- addign variables for additional holidays
l_assg_hiredate          date;
l_start_legal_period     date;
l_end_legal_period       date;
l_main_plan_info g_fr_plan_info;
--
l_fr_plan_info g_fr_plan_info;
--
-- Cursor to fetch plan type
--
CURSOR   csr_get_assignment_action (l_assignment_id number) is
         select fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                paa.assignment_action_id),16))
         from   pay_assignment_actions paa,
               pay_payroll_actions    ppa
         where  paa.assignment_id = l_assignment_id
         and    ppa.payroll_action_id = paa.payroll_action_id
         and    ppa.effective_date between l_fr_plan_info.accrual_year_start and l_fr_plan_info.accrual_year_end
         and    ppa.action_type in ('R', 'Q', 'I', 'V', 'B');
--
CURSOR   csr_get_balance_type_id is
         select  balance_type_id
         from    pay_balance_types
         where   balance_name = 'FR_SUBJECT_TO_EARNINGS_DEDUCTION'
           and   legislation_code = 'FR';
--
CURSOR   csr_plan_type is
         select accrual_formula_id, co_formula_id
         from   PAY_ACCRUAL_PLANS
         where  ACCRUAL_PLAN_ID = p_plan_id
         and    ACCRUAL_CATEGORY in ('FR_MAIN_HOLIDAY', 'FR_RTT_HOLIDAY', 'FR_ADDITIONAL_HOLIDAY');
--
-- Modified for bug 3730069
-- Substituted get_fr_plan_info.accrual_year_start
-- in sub-query.
CURSOR   csr_get_balance_value is
         Select nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0)
         from
         pay_run_result_values    TARGET
        ,pay_balance_feeds_f      FEED
        ,pay_run_results          RR
        ,pay_assignment_actions   ASSACT
        ,pay_assignment_actions   BAL_ASSACT
        ,pay_payroll_actions      PACT
        ,pay_payroll_actions      BACT
        ,per_time_periods         PTP
  where  BAL_ASSACT.assignment_action_id = l_latest_aa           /*B1 */
  and    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
  and    FEED.balance_type_id    = l_balance_type_id             /*U1*/
         +   decode(TARGET.input_value_id, null, 0, 0)
  and    FEED.input_value_id     = TARGET.input_value_id
  and    nvl(TARGET.result_value, '0') <> '0'
  and    TARGET.run_result_id    = RR.run_result_id
  and    RR.assignment_action_id = ASSACT.assignment_action_id
  and    ASSACT.payroll_action_id = PACT.payroll_action_id
  and    PACT.effective_date between
          FEED.effective_start_date and FEED.effective_end_date
  and    RR.status in ('P','PA')
  and    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
  and    ASSACT.assignment_id = BAL_ASSACT.assignment_id
  and    PTP.time_period_id = BACT.time_period_id
    /* Year To Date */
  and    PACT.effective_date > (
                 select nvl(min(PTP1.end_date),l_fr_plan_info.accrual_year_start)
            from PAY_ACCRUAL_PLANS PAP1
                ,per_time_periods PTP1
            where PAP1.ACCRUAL_PLAN_ID = l_fr_plan_info.accrual_plan_id
            and pap1.information1 is not null
            AND PTP1.payroll_id = BACT.payroll_id
           and l_fr_plan_info.accrual_year_start -1
            between PTP1.start_date and PTP1.end_date);
--
-- get all the assignments in the plan to process
--
-- Changed for Performance bug 2662236
CURSOR   csr_get_assignment(c_assignment_id number) is
         select  pee.assignment_id assignment_id
         from   pay_element_entries_f  pee
         where  pee.element_type_id    = l_fr_plan_info.accrual_plan_element_id
         and    pee.assignment_id      = nvl(c_assignment_id,pee.assignment_id)
         and    l_calculation_date between pee.effective_start_date
                                             and pee.effective_end_date;
--
-- Cursor to fetch payroll details for a given asg
--
CURSOR c_payroll_period(p_payroll_id  number, p_effective_date date) is
       select ptp.start_date
             ,ptp.end_date
       from   per_time_periods ptp
       where  ptp.payroll_id = p_payroll_id
       and    p_effective_date between ptp.start_date and ptp.end_date;
--
-- Cursor to return payroll_id
--
-- Changed and renamed cursor c_payroll_id for bug 2662236
CURSOR csr_asg_details (p_assignment_id  number,  p_effective_date date) is
       select payroll_id, assignment_number
       from   per_all_assignments_f
       where  assignment_id = p_assignment_id
       and   (p_effective_date between effective_start_date and effective_end_date);
--
-- Cursor to get the last effective end date of the assignment
-- so that terminated employees can be evaluated.
--
CURSOR c_get_asg_end_date (p_assignment_id number) is
       select max(effective_end_date)
       from   per_all_assignments_f
       where  assignment_id = p_assignment_id;
--
-- Defining cursor selecting hiredate
Cursor csr_assg_hiredate(c_assignment_id number,
                         c_accrual_date date) is
Select ppos.date_start
From   per_all_assignments_f pasg,
       per_periods_of_service ppos
Where ppos.period_of_service_id = pasg.period_of_service_id
  and pasg.assignment_id = c_assignment_id
  and c_accrual_date between pasg.effective_start_date
                         and pasg.effective_end_date;
--
  -- Local Variables
  l_accrual_plan_id       Number := p_plan_id;
  l_accrual_start_date    Date;     /* plan year start date */
  l_accrual_end_date      Date;     /* plan year end date */
  l_assignment_number	  per_all_assignments_f.assignment_number%TYPE;

  l_unused_date      Date;
  l_payroll_id       number;
  l_max_asg_end_date date;
  l_new_ee_id        number;

  l_unused_number         Number;
  l_unused_char           Varchar2(30);

  L_TYPE_M_IV_ID        Number;
  L_TYPE_P_IV_ID        Number;
  L_TYPE_Y_IV_ID        Number;
  L_TYPE_S_IV_ID        Number;
  L_TYPE_C_IV_ID        Number;
  L_TYPE_ACP_IV_ID        Number;
  L_TYPE_ACCRUAL_DATE_IV_ID        Number;


  l_ent_link_id          Number := Null;
  l_adj_link_id          Number := Null;
  l_type_link_id         Number := Null;
  --
  l_previous_main          Number := Null;
  l_previous_protected     Number := Null;
  l_previous_mothers       Number := Null;
  l_previous_seniority     Number := Null;
  l_previous_conventional  Number := Null;
  l_previous_ref_days      Number := 0;
  l_previous_ref_salary    Number := 0;

  --
  l_total_accrued_pto           Number := Null;
  l_total_Accrued_protected     Number := Null;
  l_total_Accrued_seniority     Number := Null;
  l_total_Accrued_mothers       Number := Null;
  l_total_Accrued_conventional  Number := Null;
  --
  l_new_main            Number := Null;
  l_new_protected       Number := Null;
  l_new_mothers         Number := Null;
  l_new_seniority       Number := Null;
  l_new_conventional    Number := Null;
  l_new_ref_days        Number := Null;
  l_new_ref_salary      Number := Null;
  --
  l_net_entitlement     Number := Null;
  l_net_main            Number := Null;
  l_net_protected       Number := Null;
  l_net_young_mother    Number := Null;
  l_net_seniority       Number := Null;
  l_net_conventional    Number := Null;
  l_net_ref_days        Number := Null;
  l_net_ref_salary      Number := Null;

  l_formula_id          Number := Null;
  l_co_formula_id       Number := Null;

  i                     Number := 1;
  --
  l_pay_period_start_date       date;
  l_pay_period_end_date         date;

  l_message_count    Number := Null;
  l_message       varchar2(256);

  -- Declare tables for input value ids and Screen Entry Values

  inp_value_id_tbl hr_entry.number_table;
  scr_valuetbl     hr_entry.varchar2_table;

l_proc VARCHAR2(72) :=    g_package||' FR_Create_Entitlement ';
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);

  ERRBUF := Null;
  RETCODE:= 0;
  per_accrual_message_pkg.clear_table;

  open csr_plan_type;
  --
  -- check the plan type is correct
  --

  hr_utility.set_location('Step ' || l_proc,20);
  fetch csr_plan_type into l_formula_id, l_co_formula_id;
  close csr_plan_type;

  hr_utility.set_location('formual_id is ', l_formula_id);
  --
  --
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_accrual_date             => l_accrual_date );
--
-- Retrieve the correct accrual dates for additional holidays
IF p_type ='ADD' THEN
    -- Calculate accrual dates accordingly
    l_main_plan_info := get_fr_accrual_plan_info(
        p_accrual_plan_id          => l_fr_plan_info.main_holiday_acc_plan_id
       ,p_accrual_date             => l_accrual_date );
    l_fr_plan_info.accrual_year_start := l_main_plan_info.accrual_year_start;
    l_fr_plan_info.accrual_year_end := l_main_plan_info.accrual_year_end;
END IF;
--
  hr_utility.set_location('Step ' || l_proc,30);
  --
  -- Set variables for saving to either the ENTitlement element
  -- Except link, which varies by assignment
  --
  if (P_type = 'ENT' or p_type = 'ADD') then
    l_type_accrual_date_iv_id := l_fr_plan_info.ent_accrual_date_iv_id;
    l_type_m_iv_id   := l_fr_plan_info.ent_m_iv_id;
    l_type_p_iv_id   := l_fr_plan_info.ent_p_iv_id;
    l_type_y_iv_id   := l_fr_plan_info.ent_y_iv_id;
    l_type_s_iv_id   := l_fr_plan_info.ent_s_iv_id;
    l_type_c_iv_id   := l_fr_plan_info.ent_c_iv_id;
    l_type_acp_iv_id := l_fr_plan_info.ent_acp_iv_id;
    hr_utility.set_location('Step ' || l_proc,40);
  --
  -- or the OBSoletion element
  --
  ELSE
    l_type_accrual_date_iv_id := l_fr_plan_info.obs_accrual_date_iv_id;
    l_type_m_iv_id   := l_fr_plan_info.obs_m_iv_id;
    l_type_p_iv_id   := l_fr_plan_info.obs_p_iv_id;
    l_type_y_iv_id   := l_fr_plan_info.obs_y_iv_id;
    l_type_s_iv_id   := l_fr_plan_info.obs_s_iv_id;
    l_type_c_iv_id   := l_fr_plan_info.obs_c_iv_id;
    l_type_acp_iv_id := l_fr_plan_info.obs_acp_iv_id;
  END IF;
  -- For additional holidays
  -- calculate the legal period start and end dates
  IF p_type = 'ADD' THEN
     IF  to_date(to_char(l_calculation_date, 'DD-MM'),'DD-MM') > to_date('31-10', 'DD-MM') THEN
        l_start_legal_period := to_date('01-05-'||to_char(l_calculation_date, 'YYYY'), 'DD-MM-YYYY');
     ELSE
        l_start_legal_period := to_date('01-05-'||to_char(add_months(l_calculation_date, -12), 'YYYY'), 'DD-MM-YYYY');
     END IF;
     l_end_legal_period := last_day(add_months(l_start_legal_period, 6)-1);
  END IF;
  --
  -- putting in a check for the element entry date
  -- if the accrual type is 'ADD'
  IF p_type <> 'ADD' OR
     (p_type = 'ADD' AND
      l_calculation_date <=  add_months(l_fr_plan_info.accrual_year_end,12)) THEN
     /*                               */
     /* MAIN loop for all assignments */
     /*                               */

     for l_asg in csr_get_assignment(p_assignment_id) LOOP
       l_asg_count := l_asg_count+1;
       l_index := 0;
       --
       -- putting in check for each assignment
       OPEN csr_assg_hiredate(l_asg.assignment_id, l_accrual_date);
       FETCH csr_assg_hiredate INTO l_assg_hiredate;
       CLOSE csr_assg_hiredate;

       IF p_type <> 'ADD' OR
          (p_type = 'ADD'  AND l_assg_hiredate < l_start_legal_period)THEN

          -- Get the persons payroll_id as at calc date.
          --
          hr_utility.set_location('In loop index ' , l_index);

          open csr_asg_details(l_asg.assignment_id,
                            l_calculation_date);
          fetch csr_asg_details into l_payroll_id, l_assignment_number;
          close csr_asg_details;
          --
          -- For this assignment, get the total accrual from the
          -- beginning of the accrual year (adjusted for eligibility
          -- and starting / leaving plan etc by formula)
          if (P_type = 'ENT' or p_type = 'ADD') then
              FR_Get_Accrual
               (P_Assignment_ID               => l_asg.assignment_id
               ,P_Calculation_Date            => l_calculation_date    /* calc accruals up to this date */
               ,p_accrual_start_date          => l_accrual_date  /* formula will adjust this      */
               ,P_Plan_ID                     => p_plan_id
               ,P_Business_Group_ID           => l_fr_plan_info.business_Group_id
               ,P_Payroll_ID                  => l_payroll_id
               ,P_Assignment_Action_ID        => null
               ,P_Accrual_Latest_Balance      => null
               ,p_create_all                  => 'Y'                   /* generate each accrual value */
               ,p_reprocess_whole_period      => 'Y'                   /* calculate from beginning    */
               --
               ,p_legal_period_start_date     =>l_start_legal_period
               ,p_entitlement_offset	      =>l_fr_plan_info.entitlement_offset
               ,p_main_holiday_acc_plan_id    =>l_fr_plan_info.main_holiday_acc_plan_id
               ,p_type			      =>p_type
                --
               ,P_Start_Date                  => l_unused_Date
               ,P_End_Date                    => l_unused_Date
               ,P_Accrual_End_Date            => l_unused_Date
               ,P_total_accrued_pto           => l_total_accrued_pto
               ,P_total_Accrued_protected     => l_total_Accrued_protected
               ,P_total_Accrued_seniority     => l_total_Accrued_seniority
               ,P_total_Accrued_mothers       => l_total_Accrued_mothers
               ,P_total_Accrued_conventional  => l_total_Accrued_conventional) ;
             end if;
             --
             --
             -- Previous runs may have converted accruals already, this
             -- must be netted off before storage
             -- Also, there may already be an entry in this period, in which
             -- case multiple entries allowed = Y must be on - User DOC - on
             -- all entitlement entries. The process must store the net adjustment
             -- but can only INCREASE the entitlements
             --
             hr_utility.set_location('Step ' || l_proc,50);
             IF (p_type ='ENT') then
                 l_dummy := 'Y';
             ELSE
                 l_dummy := 'N';
             END IF;
             --
             get_fr_net_entitlement
               (p_accrual_plan_id                => p_plan_id
               ,p_effective_date                 => l_accrual_date  /* a date in the accrual period */
               ,p_assignment_id                  => l_asg.assignment_id
               ,p_ignore_ent_adjustments         => l_dummy  /* need pure entitlement already stored - ignore user additions / subtractions */
               -- pass parameter to get correct accrual dates for additional holidays
	       -- to check for existing entitlements
	       , p_accrual_type                  => p_type
	       , p_legal_period_end              => l_end_legal_period
	       --
               ,p_remaining                      => l_net_entitlement
               ,p_net_main                       => l_net_main
               ,p_net_protected                  => l_net_protected
               ,p_net_young_mothers              => l_net_young_mother
               ,p_net_seniority                  => l_net_seniority
               ,p_net_conventional               => l_net_conventional
               ,p_ent_main                       => l_previous_main          /* these value hold already stored entitlement */
               ,p_ent_protected                  => l_previous_protected
               ,p_ent_young_mothers              => l_previous_mothers
               ,p_ent_seniority                  => l_previous_seniority
               ,p_ent_conventional               => l_previous_conventional
               ,p_accrual_start_date             => l_unused_date
               ,p_accrual_end_date               => l_unused_date);

           hr_utility.set_location('Step ' || l_proc,60);
          --
          -- Calculate the net new amount to store
          --
          if (P_type='ENT' or p_type='ADD') then
              l_new_main         := nvl(l_total_accrued_pto, 0)          - nvl(l_previous_main, 0);
              l_new_protected    := nvl(l_total_Accrued_protected, 0)    - nvl(l_previous_protected, 0);
              l_new_mothers      := nvl(l_total_Accrued_mothers, 0)      - nvl(l_previous_mothers, 0);
              l_new_seniority    := nvl(l_total_Accrued_seniority, 0)    - nvl(l_previous_seniority, 0);
              l_new_conventional := nvl(l_total_Accrued_conventional, 0) - nvl(l_previous_conventional, 0);

              hr_utility.set_location('Step ' || l_proc,70);
              hr_utility.set_location('new m ' || l_new_main,70);
              hr_utility.set_location('new p ' || l_new_protected,70);
              hr_utility.set_location('new m ' || l_new_mothers,70);
              hr_utility.set_location('new s ' || l_new_seniority,70);
              hr_utility.set_location('new c ' || l_new_conventional,70);

          elsif(P_type='OBS') then
             hr_utility.set_location('Step ' || l_proc,80);
             obsoletion_procedure
                      (p_business_group_id    =>  l_fr_plan_info.business_group_id
                      ,p_assignment_id        =>  l_asg.assignment_id
                      ,p_accrual_plan_id      =>  p_plan_id
                      ,p_effective_date       =>  l_calculation_date
                      ,p_accrual_date         =>  l_accrual_date
                      ,p_formula_id           =>  l_co_formula_id
                      ,p_payroll_id           =>  l_payroll_id
                      ,p_net_entitlement      =>  l_net_entitlement
                      ,p_net_main_days        =>  l_net_main
                      ,p_net_conven_days      =>  l_net_conventional
                      ,p_net_seniority_days   =>  l_net_seniority
                      ,p_net_protected_days   =>  l_net_protected
                      ,p_net_youngmother_days =>  l_net_young_mother
                      ,p_new_main_days        =>  l_new_main
                      ,p_new_conven_days      =>  l_new_conventional
                      ,p_new_seniority_days   =>  l_new_seniority
                      ,p_new_protected_days   =>  l_new_protected
                      ,p_new_youngmother_days =>  l_new_mothers) ;
          end if;
          --
          -- Get the links each of the entitlement elements.
          -- These cannot be stored in globals, as they could change by assignment
          -- Also, only MAIN may exist - others are not mandatory.

          IF (P_type = 'ENT' or p_type = 'ADD') then
             l_type_link_id := hr_entry_api.get_link(
                P_assignment_id   => l_asg.assignment_id,
                P_element_type_id => l_fr_plan_info.ent_element_id,
                P_session_date    => l_calculation_date);
          ELSE
             l_type_link_id := hr_entry_api.get_link(
                P_assignment_id   => l_asg.assignment_id,
                P_element_type_id => l_fr_plan_info.obs_element_id,
                P_session_date    => l_calculation_date);
          END IF;

          --
          -- Get the reference days, and the reference salary value
          -- if the reference period has ended. The reference period ending is calculated as the accrual year end date
          -- is less than the canculation date.
          --
          hr_utility.set_location('Step ' || l_proc,90);

          IF  (P_type = 'ENT') and l_fr_plan_info.accrual_year_end <= l_calculation_date  THEN
             hr_utility.set_location('Step ' || l_proc,100);
             --
             l_previous_ref_salary := 0;
             l_previous_ref_days   := 0;
             --
             get_reference_entitlement(
                p_accrual_plan_id         => p_plan_id
               ,p_accrual_start_date      => l_fr_plan_info.accrual_year_start
               ,p_accrual_end_date        => l_fr_plan_info.accrual_year_end
               ,p_assignment_id           => l_asg.assignment_id
               ,p_ent_ref_days_id         => l_fr_plan_info.ent_reference_days_iv_id
               ,p_ent_ref_salary_id       => l_fr_plan_info.ent_reference_sal_iv_id
               ,p_ent_accrual_date_iv_id  => l_type_accrual_date_iv_id
               ,p_ref_main_days           => l_previous_ref_days
               ,p_ref_salary              => l_previous_ref_salary);
             --
             l_new_ref_days := nvl(l_total_accrued_pto,0) + nvl(l_total_accrued_protected,0);
             --
             -- calculate the value of the balance for reference salary
             -- Pleace holder for now - need to check if period has ended.
             --
             open csr_get_assignment_action(l_asg.assignment_id);
             fetch csr_get_assignment_action into l_latest_aa;
             close csr_get_assignment_action;
             hr_utility.set_location('Step ' || l_proc,110);

             hr_utility.set_location('l_latest_aa is ' || l_latest_aa, 110);
             --
             --
             open csr_get_balance_type_id;
             fetch csr_get_balance_type_id into l_balance_type_id;
             close csr_get_balance_type_id;
             hr_utility.set_location('Step ' || l_proc,120);
             --
             l_new_ref_salary := 0;

             open csr_get_balance_value;
             fetch csr_get_balance_value into  l_new_ref_salary;
             close csr_get_balance_value;
             hr_utility.set_location('Step ' || l_proc,130);

             hr_utility.set_location('l_new_ref_salary is ' || l_new_ref_salary, 110);
             --
             --
             -- Calculate new values to store - only post increments
             --
             l_net_ref_salary := greatest(0, nvl(l_new_ref_salary,0) - nvl(l_previous_ref_salary, 0));
             l_net_ref_days   := greatest(0, nvl(l_new_ref_days,0)   - nvl(l_previous_ref_days, 0));

             hr_utility.set_location('l_net_ref_salary is ' || l_net_ref_salary, 110);
             hr_utility.set_location('l_net_ref_days is ' || l_net_ref_days, 110);

          ELSE
             hr_utility.set_location('Step ' || l_proc,140);
             null;
          END IF;

          --
          -- new ENT storage is necessary only if any of these are posiitve
          -- new OBS storage if any are non-zero
          --

          IF ((p_type = 'ENT' or p_type = 'ADD') and l_new_main > 0 or l_new_protected > 0 or l_new_mothers > 0 or l_new_seniority > 0 or l_new_conventional > 0 or l_net_ref_salary > 0 or l_net_ref_days > 0 )
             OR ((p_type = 'OBS') and l_new_main <> 0 or l_new_protected <> 0 or l_new_mothers <> 0 or l_new_seniority <> 0 or l_new_conventional <> 0) THEN

             hr_utility.set_location('creating entries ' || l_proc,150);
             --
             -- We must get the payroll period start and end dates for
             -- the period in which the element entry will be made,
             -- as these are the effective start and end dates for all
             -- non-recurring element entries.
             --
             open c_payroll_period(l_payroll_id,   l_calculation_date);
             fetch c_payroll_period into l_pay_period_start_date,   l_pay_period_end_date;
             close c_payroll_period;
             hr_utility.set_location('Step ' || l_proc,150);
             --
             -- Check that the assignment does not end before the payroll
             -- period end date.
             --
             open c_get_asg_end_date(l_asg.assignment_id);
             fetch c_get_asg_end_date into l_max_asg_end_date;
             close c_get_asg_end_date;
             hr_utility.set_location('Step ' || l_proc,160);

             If l_max_asg_end_date < l_pay_period_end_date then
                --
                -- warn user in log : assignment ends before payroll period end date
                --
                fnd_message.set_name('PAY','PAY_75024_PTO_ACC_PERIOD');
                fnd_message.set_token('ASG_NO', l_assignment_number);
                fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
             ELSE
                --
                -- proceed with the element entries.
                --
                --
                -- One of the entitlements are non-zero, so populate the record
                --
                -- The date will always be present
                --
                l_index := l_index + 1;
                inp_value_id_tbl(l_index) := l_type_accrual_date_iv_id;
                l_accrual_date := l_fr_plan_info.accrual_year_end;
                scr_valuetbl(l_index)     := fnd_date.date_to_displaydate(l_accrual_date);
                --
                -- The Accrual Plan ID will always be present
                --
                l_index := l_index + 1;
                inp_value_id_tbl(l_index) := l_type_acp_iv_id;
                scr_valuetbl(l_index)     := fnd_number.number_to_canonical(p_plan_id);
                --
                -- The Main will always exist
                --
                l_index := l_index + 1;
                inp_value_id_tbl(l_index) := l_type_m_iv_id;
                scr_valuetbl(l_index)     := l_new_main;
                --
                -- Protected may not exist
                --
                IF l_type_p_iv_id is not null THEN
                  l_index := l_index + 1;
                  inp_value_id_tbl(l_index) := l_type_p_iv_id;
                  scr_valuetbl(l_index)     := l_new_protected;
                END IF;
                --
                -- Conventional may not exist
                --
                IF l_type_c_iv_id is not null THEN
                  l_index := l_index + 1;
                  inp_value_id_tbl(l_index) := l_type_c_iv_id;
                  scr_valuetbl(l_index)     := l_new_conventional;
                END IF;
                --
                -- Seniority may not exist
                --
                IF l_type_s_iv_id is not null THEN
                  l_index := l_index + 1;
                  inp_value_id_tbl(l_index) := l_type_s_iv_id;
                  scr_valuetbl(l_index)     := l_new_seniority;
                END IF;
                --
                -- Young Mothers may not exist
                --
                IF l_type_y_iv_id is not null THEN
                  l_index := l_index + 1;
                  inp_value_id_tbl(l_index) := l_type_y_iv_id;
                  scr_valuetbl(l_index)     := l_new_mothers;
                END IF;
                --
                -- Also create the reference salary and days
                --
                IF p_type = 'ENT' THEN
                  IF l_fr_plan_info.ent_reference_days_iv_id is not null and l_net_ref_days > 0 THEN
                    l_index := l_index + 1;
                    inp_value_id_tbl(l_index) := l_fr_plan_info.ent_reference_days_iv_id;
                    scr_valuetbl(l_index)     := l_net_ref_days;
                  END IF;
                  IF l_fr_plan_info.ent_reference_sal_iv_id is not null and l_net_ref_salary > 0 THEN
                    l_index := l_index + 1;
                    inp_value_id_tbl(l_index) := l_fr_plan_info.ent_reference_sal_iv_id;
                    scr_valuetbl(l_index)     := l_net_ref_salary;
                  END IF;
                END IF;
                --
                -- Write the record
                --

                hr_utility.set_location('Step ' || l_proc,200);

                IF l_type_link_id is null then
                  --
                  -- error : warn user in log : this asg does not have the link to the element
                  --
                  fnd_message.set_name('PAY','PAY_75023_PTO_ACC_LINK');
                  fnd_message.set_token('ASG_NO', l_assignment_number);
                  fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
                END IF;

                hr_entry_api.insert_element_entry(
                       p_effective_start_date     => l_pay_period_start_date,
                       p_effective_end_date       => l_pay_period_end_date,
                       p_element_entry_id         => l_new_ee_id,
                       p_assignment_id            => l_asg.assignment_id,
                       p_element_link_id          => l_type_link_id,
                       p_creator_type             => 'F',
                       p_entry_type               => 'E',
                       p_num_entry_values         => l_index,
                       p_input_value_id_tbl       => inp_value_id_tbl,
                       p_entry_value_tbl          => scr_valuetbl);
                hr_utility.set_location('Step ' || l_proc,210);

                IF l_new_ee_id is null THEN
                  --
                  -- warn user in log : could not create the entry
                  --
                  fnd_message.set_name('PAY','PAY_75025_PTO_ACC_NO_ENTRY');
                  fnd_message.set_token('ASG_NO', l_assignment_number);
                  fnd_file.put_line(FND_FILE.LOG,fnd_message.get);
                END IF;

                hr_utility.set_location('l_new_ee_id is ' , l_new_ee_id);

             END IF;            /*  l_max_asg_end_date >= l_pay_period_end_date */
          END IF;         /*  l_new_main > 0 or l_new_protected  ...    */
          --
          -- flush messges
          --
          l_message_count := per_accrual_message_pkg.count_messages;
          for i in 1..l_message_count loop
             --
             l_message := per_accrual_message_pkg.get_message(i);
             hr_utility.trace(l_message);
             --
          end loop;    /* messages */
          --
       END IF;
    END LOOP;        /* l_asg in csr_get_assignment   */
    --
  ELSE
    --
    IF p_type = 'ADD' THEN
       IF l_calculation_date > add_months(l_fr_plan_info.accrual_year_end,12) THEN
            -- show warning log message
            fnd_message.set_name('PAY','PAY_75196_ADD_ENT_DATE_MORE');
            fnd_file.put_line(FND_FILE.LOG, fnd_message.get);
            --
       END IF;
    END IF;
    --
  END IF;
  --
  fnd_message.set_name('PAY','PAY_75026_PTO_ACC_PROCESSED');
  fnd_file.put_line(FND_FILE.LOG,to_char(l_asg_count) || ' ' || fnd_message.get);
  --
  hr_utility.set_location('Leaving:  '||l_proc,50);
end fr_create_entitlement;
--
-------------------------------------------------------------------------------
-- Get FR Accrual PLAN INFO
-------------------------------------------------------------------------------
function get_fr_accrual_plan_info(
 p_accrual_plan_id           IN number
,p_element_entry_id          IN number default null
,p_accrual_date              IN date   default null
)  return g_fr_plan_info is

l_fr_plan_info g_fr_plan_info;

CURSOR csr_plan_input (p_element_type_id in number) is
select piv1.input_value_id       acp_plan_id
from   pay_input_values_f  piv1
where piv1.element_type_id = p_element_type_id
  and piv1.display_sequence = 10;

CURSOR csr_reference_inputs (p_ent_accrual_date_iv in number) is
select piv1.input_value_id         reference_salary
      ,piv2.input_value_id         reference_days
from   pay_input_values_f  piv1
      ,pay_input_values_f  piv2
      ,pay_input_values_f  piv
where piv1.element_type_id  = piv2.element_type_id
  and piv1.element_type_id = piv.element_type_id
  and piv.input_value_id = p_ent_accrual_date_iv
  and piv1.display_sequence = 80
  and piv2.display_sequence = 90;

CURSOR csr_plan_info (p_accrual_plan_id in Number) is
select nvl(pap.information1,6) accrual_start_month
      ,pap.information2       entitlement_offset
      ,pap.information3       entitlement_duration
      ,pap.information4       working_days
      ,pap.information5       protected_days
      ,pap.information6       accounting_method
      ,pap.information7       main_holiday_acc_plan_id
      ,pap.information8       ent_m_iv_id
      ,pap.information9       ent_p_iv_id
      ,pap.information10      ent_c_iv_id
      ,pap.information11      ent_s_iv_id
      ,pap.information12      ent_y_iv_id
      ,pap.information13      obs_m_iv_id
      ,pap.information14      obs_p_iv_id
      ,pap.information15      obs_c_iv_id
      ,pap.information16      obs_s_iv_id
      ,pap.information17      obs_y_iv_id
      ,pap.information18      adj_m_iv_id
      ,pap.information19      adj_p_iv_id
      ,pap.information20      adj_c_iv_id
      ,pap.information21      adj_s_iv_id
      ,pap.information22      adj_y_iv_id
      ,pap.information23      ent_accrual_date_iv_id
      ,pap.information24      obs_accrual_date_iv_id
      ,pap.information25      adj_accrual_date_iv_id
      ,pap.information26      working_days_iv_id
      ,pap.information27      protected_days_iv_id
      -- lines added for termination processing
      ,pap.information28      term_days_iv_id
      ,pap.information29      term_accrual_date_iv_id
      --
      ,pap.accrual_plan_element_type_id accrual_plan_element_id
      ,piv.element_type_id    holiday_element_id
      ,pivE.element_type_id    ENT_element_id
      ,pivO.element_type_id    OBS_element_id
      ,pivA.element_type_id    ADJ_element_id
      -- added for termination processing
      ,pivT.element_type_id    TERM_element_id
      --
      ,pap.business_group_id  business_Group_id
from   pay_accrual_plans  pap
      ,pay_input_values_f piv
      ,pay_input_values_f pivE
      ,pay_input_values_f pivO
      ,pay_input_values_f pivA
      -- added for termination processing
      ,pay_input_values_f pivT
where  pap.accrual_plan_id = p_accrual_plan_id
and    piv.input_value_id  = pap.pto_input_value_id
and    pivE.input_value_id  = pap.information8
and    pivO.input_value_id  = pap.information13
and    pivA.input_value_id  = pap.information18
-- Added for termination processing
and    pivT.input_value_id(+)  = pap.information28;

CURSOR  csr_plan_info_ee (c_element_entry_id in number) is
select pap.information1       accrual_start_month
      ,pap.information2       entitlement_offset
      ,pap.information3       entitlement_duration
      ,pap.information4       working_days
      ,pap.information5       protected_days
      ,pap.information6       accounting_method
      ,pap.information7       main_holiday_acc_plan_id
      ,pap.information8       ent_m_iv_id
      ,pap.information9       ent_p_iv_id
      ,pap.information10      ent_c_iv_id
      ,pap.information11      ent_s_iv_id
      ,pap.information12      ent_y_iv_id
      ,pap.information13      obs_m_iv_id
      ,pap.information14      obs_p_iv_id
      ,pap.information15      obs_c_iv_id
      ,pap.information16      obs_s_iv_id
      ,pap.information17      obs_y_iv_id
      ,pap.information18      adj_m_iv_id
      ,pap.information19      adj_p_iv_id
      ,pap.information20      adj_c_iv_id
      ,pap.information21      adj_s_iv_id
      ,pap.information22      adj_y_iv_id
      ,pap.information23      ent_accrual_date_iv_id
      ,pap.information24      obs_accrual_date_iv_id
      ,pap.information25      adj_accrual_date_iv_id
      ,pap.accrual_plan_element_type_id accrual_plan_element_id
      ,pap.accrual_plan_id    accrual_plan_id
      ,pap.information26      working_days_iv_id
      ,pap.information27      protected_days_iv_id
      ,pap.information28      term_days_iv_id
      ,pap.information29      term_accrual_date_iv_id
      ,pivT.element_type_id   term_element_id
      ,piv.element_Type_id    holiday_element_id
      ,pivE.element_type_id    ENT_element_id
      ,pivO.element_type_id    OBS_element_id
      ,pivA.element_type_id    ADJ_element_id
      ,pap.business_group_id  business_Group_id
from   pay_accrual_plans pap
      ,per_absence_attendances paa
      ,per_absence_attendance_types pat
      ,pay_element_entries_f pee
      ,pay_input_values_f    piv
      ,pay_input_values_f    pivE
      ,pay_input_values_f    pivO
      ,pay_input_values_f    pivA
      ,pay_input_values_f    pivT
where  paa.absence_attendance_type_id = pat.absence_attendance_type_id
  and  pivE.input_value_id  = pap.information8
  and  pivO.input_value_id  = pap.information13
  and  pivA.input_value_id  = pap.information18
  and  pat.input_value_id = pap.pto_input_value_id
  and  paa.absence_Attendance_id = pee.creator_id
  and  pee.creator_type = 'A'
  and  piv.input_value_id = pap.pto_input_value_id
  and  pivT.input_value_id(+)  = pap.information28
  and  pee.element_entry_id = c_element_entry_id;

-- the ddf stores BASE input value id - but the RATE is needed
CURSOR csr_temp_swap_rate (p_element_type_id in number) is
select piv.input_value_id       input_value_id
from   pay_input_values_f  piv
where piv.element_type_id = p_element_type_id
  and piv.display_sequence = 40;

rec_plan_info csr_plan_info%ROWTYPE;
rec_plan_info_ee csr_plan_info_ee%ROWTYPE;
rec_reference_inputs csr_reference_inputs%ROWTYPE;

l_asat_month number;
l_add_months number := 0;
temp_ent_accrual_date_iv_id number := 0;
temp_accrual_start_month number := 0;

l_proc VARCHAR2(72) :=    g_package||' Get FR Accrual Plan Info ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);

  IF p_accrual_plan_id is not null THEN
    open csr_plan_info(p_accrual_plan_id);
    fetch csr_plan_info into rec_plan_info;
    close csr_plan_info;
    l_fr_plan_info.accrual_plan_id          := p_accrual_plan_id;
    l_fr_plan_info.accrual_start_month      := fnd_number.canonical_to_number(rec_plan_info.accrual_start_month);
    l_fr_plan_info.entitlement_offset       := fnd_number.canonical_to_number(rec_plan_info.entitlement_offset);
    l_fr_plan_info.entitlement_duration     := fnd_number.canonical_to_number(rec_plan_info.entitlement_duration);
    l_fr_plan_info.working_days             := fnd_number.canonical_to_number(rec_plan_info.working_days);
    l_fr_plan_info.protected_days           := fnd_number.canonical_to_number(rec_plan_info.protected_days);
    l_fr_plan_info.accounting_method        := rec_plan_info.accounting_method;
    l_fr_plan_info.ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.ent_accrual_date_iv_id);
    l_fr_plan_info.ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.ent_accrual_date_iv_id);
    l_fr_plan_info.ent_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_m_iv_id);
    l_fr_plan_info.ent_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_p_iv_id);
    l_fr_plan_info.ent_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_c_iv_id);
    l_fr_plan_info.ent_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_s_iv_id);
    l_fr_plan_info.ent_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_y_iv_id);
    l_fr_plan_info.obs_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.obs_accrual_date_iv_id);
    l_fr_plan_info.obs_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_m_iv_id);
    l_fr_plan_info.obs_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_p_iv_id);
    l_fr_plan_info.obs_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_c_iv_id);
    l_fr_plan_info.obs_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_s_iv_id);
    l_fr_plan_info.obs_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_y_iv_id);
    l_fr_plan_info.adj_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.adj_accrual_date_iv_id);
    l_fr_plan_info.adj_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_m_iv_id);
    l_fr_plan_info.adj_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_p_iv_id);
    l_fr_plan_info.adj_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_c_iv_id);
    l_fr_plan_info.adj_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_s_iv_id);
    l_fr_plan_info.adj_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_y_iv_id);
    l_fr_plan_info.main_holiday_acc_plan_id := fnd_number.canonical_to_number(rec_plan_info.main_holiday_acc_plan_id);
    l_fr_plan_info.holiday_element_id       := rec_plan_info.holiday_element_id;
    l_fr_plan_info.business_group_id        := rec_plan_info.business_Group_id;
    l_fr_plan_info.accrual_plan_element_id  := rec_plan_info.accrual_plan_element_id;
    l_fr_plan_info.working_days_iv_id       := fnd_number.canonical_to_number(rec_plan_info.working_days_iv_id);
    l_fr_plan_info.protected_days_iv_id     := fnd_number.canonical_to_number(rec_plan_info.protected_days_iv_id);
    l_fr_plan_info.ent_element_id           := rec_plan_info.ENT_element_id;
    l_fr_plan_info.obs_element_id           := rec_plan_info.OBS_element_id;
    l_fr_plan_info.adj_element_id           := rec_plan_info.ADJ_element_id;
    l_fr_plan_info.term_element_id          := rec_plan_info.term_element_id;
    l_fr_plan_info.term_accrual_date_iv_id  := fnd_number.canonical_to_number(rec_plan_info.term_accrual_date_iv_id);
    l_fr_plan_info.term_days_iv_id          := fnd_number.canonical_to_number(rec_plan_info.term_days_iv_id);
    temp_ent_accrual_date_iv_id:= fnd_number.canonical_to_number(rec_plan_info.ent_accrual_date_iv_id);
    temp_accrual_start_month   := fnd_number.canonical_to_number(rec_plan_info.accrual_start_month);
  ELSE
    open csr_plan_info_ee(p_element_entry_id);
    fetch csr_plan_info_ee into rec_plan_info_ee;
    close csr_plan_info_ee;
    l_fr_plan_info.accrual_start_month      := fnd_number.canonical_to_number(rec_plan_info_ee.accrual_start_month);
    l_fr_plan_info.entitlement_offset       := fnd_number.canonical_to_number(rec_plan_info_ee.entitlement_offset);
    l_fr_plan_info.entitlement_duration     := fnd_number.canonical_to_number(rec_plan_info_ee.entitlement_duration);
    l_fr_plan_info.working_days             := fnd_number.canonical_to_number(rec_plan_info_ee.working_days);
    l_fr_plan_info.protected_days           := fnd_number.canonical_to_number(rec_plan_info_ee.protected_days);
    l_fr_plan_info.accounting_method        := rec_plan_info_ee.accounting_method;
    l_fr_plan_info.ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.ent_accrual_date_iv_id);
    l_fr_plan_info.ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.ent_accrual_date_iv_id);
    l_fr_plan_info.ent_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_m_iv_id);
    l_fr_plan_info.ent_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_p_iv_id);
    l_fr_plan_info.ent_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_c_iv_id);
    l_fr_plan_info.ent_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_s_iv_id);
    l_fr_plan_info.ent_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_y_iv_id);
    l_fr_plan_info.obs_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.obs_accrual_date_iv_id);
    l_fr_plan_info.obs_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_m_iv_id);
    l_fr_plan_info.obs_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_p_iv_id);
    l_fr_plan_info.obs_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_c_iv_id);
    l_fr_plan_info.obs_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_s_iv_id);
    l_fr_plan_info.obs_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_y_iv_id);
    l_fr_plan_info.adj_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.adj_accrual_date_iv_id);
    l_fr_plan_info.adj_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_m_iv_id);
    l_fr_plan_info.adj_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_p_iv_id);
    l_fr_plan_info.adj_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_c_iv_id);
    l_fr_plan_info.adj_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_s_iv_id);
    l_fr_plan_info.adj_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_y_iv_id);
    l_fr_plan_info.main_holiday_acc_plan_id := fnd_number.canonical_to_number(rec_plan_info_ee.main_holiday_acc_plan_id);
    l_fr_plan_info.holiday_element_id       := rec_plan_info_ee.holiday_element_id;
    l_fr_plan_info.business_group_id        := rec_plan_info_ee.business_Group_id;
    l_fr_plan_info.accrual_plan_id          := rec_plan_info_ee.accrual_plan_id;
    l_fr_plan_info.accrual_plan_element_id  := rec_plan_info_ee.accrual_plan_element_id;
    l_fr_plan_info.working_days_iv_id       := fnd_number.canonical_to_number(rec_plan_info_ee.working_days_iv_id);
    l_fr_plan_info.ent_element_id           := rec_plan_info_ee.ENT_element_id;
    l_fr_plan_info.obs_element_id           := rec_plan_info_ee.OBS_element_id;
    l_fr_plan_info.adj_element_id           := rec_plan_info_ee.ADJ_element_id;
    l_fr_plan_info.protected_days_iv_id     := fnd_number.canonical_to_number(rec_plan_info_ee.protected_days_iv_id);
    l_fr_plan_info.term_element_id          := rec_plan_info.term_element_id;
    l_fr_plan_info.term_accrual_date_iv_id  := fnd_number.canonical_to_number(rec_plan_info.term_accrual_date_iv_id);
    l_fr_plan_info.term_days_iv_id          := fnd_number.canonical_to_number(rec_plan_info.term_days_iv_id);
    temp_ent_accrual_date_iv_id             := fnd_number.canonical_to_number(rec_plan_info_ee.ent_accrual_date_iv_id);
    temp_accrual_start_month                := fnd_number.canonical_to_number(rec_plan_info_ee.accrual_start_month);
  END IF;

  open csr_temp_swap_rate(l_fr_plan_info.term_element_id);
  fetch csr_temp_swap_rate into l_fr_plan_info.term_days_iv_id;
  close csr_temp_swap_rate;
hr_utility.trace('new days is ' ||l_fr_plan_info.term_days_iv_id);
  --
  open csr_reference_inputs (temp_ent_accrual_date_iv_id);
  fetch csr_reference_inputs into rec_reference_inputs;
  close csr_reference_inputs;
  hr_utility.set_location('Step ' || l_proc,20);
  --
  --
  -- Get the plan dates, if p_accrual_date is not null
  --
  IF p_accrual_date is not null then
    l_asat_month := to_number(to_char(p_accrual_date, 'mm'));
    if l_asat_month < temp_accrual_start_month then
       l_add_months := -12;
    end if;

    --fnd_file.put_line(fnd_file.log,'in accrual_plan_info h1');
    --fnd_file.put_line(fnd_file.log,'temp_accrual_start_month ' || temp_accrual_start_month );
    --fnd_file.put_line(fnd_file.log,'pa_accrual_Date is ' || p_accrual_date );
    --fnd_file.put_line(fnd_file.log,'l_asat_month is ' || l_asat_month );
    --fnd_file.put_line(fnd_file.log,'l_add_months is ' || l_add_months );
    --fnd_file.put_line(fnd_file.log,'rec_plan_infoe.accrual_start_month is ' || rec_plan_info.accrual_start_month);
    --fnd_file.put_line(fnd_file.log,'l_fr_plan_info.entitlement_offset is ' || l_fr_plan_info.entitlement_offset);

    l_fr_plan_info.accrual_year_start := to_date('01-' || temp_accrual_start_month || '-'
      || to_char(add_months(p_accrual_date,l_add_months), 'yyyy') || ' 00:00:00'
      , 'dd-mm-yyyy hh24:mi:ss');

    l_fr_plan_info.accrual_year_end   := add_months(l_fr_plan_info.accrual_year_start - 1,12);
  end if;

  l_fr_plan_info.ent_reference_sal_iv_id  := rec_reference_inputs.reference_salary;
  l_fr_plan_info.ent_reference_days_iv_id := rec_reference_inputs.reference_days;

  open csr_plan_input (l_fr_plan_info.ent_element_id);
  fetch csr_plan_input into l_fr_plan_info.ent_acp_iv_id;
  close csr_plan_input;
  open csr_plan_input (l_fr_plan_info.obs_element_id);
  fetch csr_plan_input into l_fr_plan_info.obs_acp_iv_id;
  close csr_plan_input;
  open csr_plan_input (l_fr_plan_info.adj_element_id);
  fetch csr_plan_input into l_fr_plan_info.adj_acp_iv_id;
  close csr_plan_input;

--
hr_utility.set_location('Leaving:  '||l_proc,100);
return l_fr_plan_info;
end get_fr_accrual_plan_info;
--
-------------------------------------------------------------------------------
-- FR_GET_ACRUAL                              HIGH - CALLS FR_CALCULATE_ACCRUAL
-- Made changes to the procedure to accept extra parameters for calculation of
-- Additional entitlement. Bug#3030610.
-------------------------------------------------------------------------------
procedure FR_Get_Accrual
(P_Assignment_ID               IN  Number
,P_Calculation_Date            IN  Date
,p_accrual_start_date          IN  Date
,P_Plan_ID                     IN  Number
,P_Business_Group_ID           IN  Number
,P_Payroll_ID                  IN  Number
,P_Assignment_Action_ID        IN  Number default null
,P_Accrual_Latest_Balance      IN Number default null
,p_create_all                  IN Varchar2 default 'N'
,p_reprocess_whole_period      IN Varchar2 default 'N'
,p_payslip_process             IN Varchar2 default 'N'
-- Added extra inputs for additional days requirements
,p_legal_period_start_date	      IN Date     default null
,p_entitlement_offset	          IN Number   default null
,p_main_holiday_acc_plan_id       IN Number   default null
,p_type			                  IN Varchar2 default null
--
,P_Start_Date                  OUT NOCOPY Date           /* accrual year start date */
,P_End_Date                    OUT NOCOPY Date           /* accrual year end date   */
,P_Accrual_End_Date            OUT NOCOPY Date           /* accrual end date        */
--
,P_total_accrued_pto           OUT NOCOPY number
,P_total_Accrued_protected     OUT NOCOPY number
,P_total_Accrued_seniority     OUT NOCOPY number
,P_total_Accrued_mothers       OUT NOCOPY number
,P_total_Accrued_conventional  OUT NOCOPY number
) is

l_proc                        varchar2(72) := g_package||'FR_Get_Accrual';
l_accrual_plan_rec            per_Accrual_calc_functions.g_accrual_plan_rec_type;
l_accrual_for_plan            number := 0;
l_effective_start_date        date;
l_effective_end_date          date;
l_accrual_end_date            date;
l_enrolled_in_plan            boolean;
l_ret                         number := 0;

begin
--
  hr_utility.set_location('Entering FR_Get_Accrual'||l_proc, 5);

  l_accrual_plan_rec := per_accrual_calc_functions.get_accrual_plan(p_plan_id);
  hr_utility.set_location('Step ' || l_proc,10);
  --fnd_file.put_line(fnd_file.log,'In FR_GET_ACCRUAL' );
  --fnd_file.put_line(fnd_file.log,'asg ' || p_assignment_id );
  hr_utility.set_location('Calling paer_accrual_calc_functions'||l_proc, 25);
  l_Enrolled_In_Plan := per_accrual_calc_functions.check_assignment_enrollment(
                                 p_assignment_id
                                ,l_accrual_plan_rec.accrual_plan_element_type_id
                                ,p_calculation_date);

  IF l_enrolled_in_plan then
    hr_utility.set_location('l_enrolled_in_plan is true in FR_Get_Accrual'||l_proc, 5);
    --Added following if statement to support Addtional Holidays
    IF p_type  IS NULL OR p_type <> 'ADD' THEN
        hr_utility.set_location('Enrolled in Plan ' || l_proc,20);
        --
        l_ret := per_formula_functions.set_text('CREATE_ALL', p_create_all);
        l_ret := per_formula_functions.set_text('REPROCESS_ALL', p_reprocess_whole_period);
        l_ret := per_formula_functions.set_text('FR_PAYSLIP_PROCESS', p_payslip_process);
        l_ret := per_formula_functions.set_date('PROCESS_DATE', p_calculation_date);

        FR_calculate_accrual(p_assignment_id         => p_assignment_id,
                        p_plan_id                    => p_plan_id,
                        p_payroll_id                 => p_payroll_id,
                        p_business_group_id          => p_business_group_id,
                        p_accrual_formula_id         => l_accrual_plan_rec.accrual_formula_id,
                        p_assignment_action_id       => p_assignment_action_id,
                        p_calculation_date           => p_calculation_date,
                        p_accrual_start_date         => p_accrual_start_date,
                        p_accrual_latest_balance     => p_accrual_latest_balance,
                        p_total_accrued_pto          => P_total_accrued_pto,
                        p_total_accrued_protected    => p_total_accrued_protected,
                        p_total_accrued_seniority    => p_total_accrued_seniority,
                        p_total_accrued_mothers      => p_total_accrued_mothers,
                        p_total_accrued_conventional => p_total_accrued_conventional,
                        p_effective_start_date       => l_effective_start_date,
                        p_effective_end_date         => l_effective_end_date,
                        p_accrual_end_date           => l_accrual_end_date
                        );
        hr_utility.set_location('Step ' || l_proc,40);

        -- reset these variables
        l_ret := per_formula_functions.set_text('CREATE_ALL', ' ');
        l_ret := per_formula_functions.set_text('REPROCESS_ALL', ' ');
        l_ret := per_formula_functions.set_text('FR_PAYSLIP_PROCESS', ' ');
        --
        -- Set the return values of the out parameters
        --
        p_start_date := l_effective_start_date;
        p_end_date := l_effective_end_date;
        p_accrual_end_date := l_accrual_end_date;
        hr_utility.set_location('Step ' || l_proc,50);
      --
      --
   ELSIF p_type = 'ADD' THEN
        /*** ie. if p_type = 'ADD'
   		Additional Holidays Process. Call the the accrual formula related. BUG#3030610***/
      hr_utility.set_location('Calling fr_calculate_accrual'||l_proc,125);
      FR_calculate_accrual(p_assignment_id       => p_assignment_id,
                    p_plan_id                    => p_plan_id,
                    p_payroll_id                 => p_payroll_id,
                    p_business_group_id          => p_business_group_id,
                    p_accrual_formula_id         => l_accrual_plan_rec.accrual_formula_id,
                    p_assignment_action_id       => p_assignment_action_id,
                    p_calculation_date           => p_calculation_date,
                    p_accrual_start_date         => p_accrual_start_date,
                    p_accrual_latest_balance     => p_accrual_latest_balance,
                    -- added for additional holidays
                    p_legal_period_start_date  =>  p_legal_period_start_date,
                    --
                    p_entitlement_offset	     => p_entitlement_offset,
            	    p_main_holiday_acc_plan_id   => p_main_holiday_acc_plan_id,
            	    p_type			             => p_type,
                    p_total_accrued_pto          => P_total_accrued_pto,
                    p_total_accrued_protected    => p_total_accrued_protected,
                    p_total_accrued_seniority    => p_total_accrued_seniority,
                    p_total_accrued_mothers      => p_total_accrued_mothers,
                    p_total_accrued_conventional => p_total_accrued_conventional,
                    p_effective_start_date       => l_effective_start_date,
                    p_effective_end_date         => l_effective_end_date,
                    p_accrual_end_date           => l_accrual_end_date);
   END IF;
   --
  ELSE   --Enrolled plan
    hr_utility.set_location('Not Enrolled in plan ' || l_proc,50);
    --
    p_start_date              := null;
    p_end_date                := null;
    p_accrual_end_date        := null;
    p_total_accrued_pto       := 0;
    P_total_Accrued_protected       := 0;
    P_total_Accrued_seniority       := 0;
    P_total_Accrued_mothers         := 0;
    P_total_Accrued_conventional    := 0;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 100);
  --fnd_file.put_line(fnd_file.log,'Leaving FR_GET_ACCRUAL' );
--
end FR_Get_Accrual;
-------------------------------------------------------------------------------
-- FR_CALCULATE_ACRUAL                              LOW LEVEL FAST FORMULA CALL
--Made changes for bug#3030610. The procedure now accepts extra inputs for
--the calculation of additional entitlements.
-------------------------------------------------------------------------------
procedure FR_Calculate_Accrual
(P_Assignment_ID                  IN Number
,P_Plan_ID                        IN Number
,P_Payroll_ID                     IN Number
,P_Business_Group_ID              IN Number
,P_Accrual_formula_ID             IN Number
,P_Assignment_Action_ID           IN Number default null
,P_Calculation_Date               IN Date
,p_accrual_START_date             IN Date
-- Added extra inputs for additional days requirements
,p_legal_period_start_date	      IN Date default null
,p_entitlement_offset	          IN Number default null
,p_main_holiday_acc_plan_id       IN Number default null
,p_type			                  IN Varchar2 default null
--
,P_Accrual_Latest_Balance         IN Number default null
,P_Total_Accrued_PTO              OUT NOCOPY Number
,p_total_accrued_protected        OUT NOCOPY Number
,p_total_accrued_seniority        OUT NOCOPY Number
,p_total_accrued_mothers          OUT NOCOPY Number
,p_total_accrued_conventional     OUT NOCOPY Number
,P_Effective_Start_Date           OUT NOCOPY Date      /* returned by formula */
,P_Effective_End_Date             OUT NOCOPY Date      /* returned by formula */
,P_Accrual_End_date               OUT NOCOPY Date) is  /* returned by formula */
--
l_proc        varchar2(72) := g_package||'FR_Calculate_Accrual';
l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;
l_ret         number;
-- Added Following variables to support additional day requirements
l_main_holiday_acc_plan_id        Number := p_main_holiday_acc_plan_id;
l_accounting_method               Varchar2(60);
l_working_days			          Number;
l_protected_days		          Number;
l_main_accrual_year_start         Date;
l_main_entitlement_offset         Number;
l_main_entitlement_duration       Number;
l_n                   		      Number;
l_d                     	      Date;
-- added to retrieve entitlements
l_ent_accrual_date_iv_id          Number;
l_type_m_iv_id                    Number;
l_type_p_iv_id                    Number;

--
l_add_days  NUMBER;
l_add_ent_found NUMBER;
--
-- Cursor for fetching entitled main and protected days
-- from element entries for additional holidays
Cursor csr_entitled_days (c_start_date date,
                          c_end_date date,
                          c_type_accrual_date_iv_id number,
                          c_type_m_iv_id number,
                          c_type_p_iv_id number)IS
select  sum(pevm.screen_entry_value)
       ,sum(pevp.screen_entry_value)
from    pay_element_entry_values_f pevm
       ,pay_element_entry_values_f pevp
       ,pay_element_entry_values_f pevdate
       ,pay_element_entries_f      pee
where   pevm.input_value_id = c_type_m_iv_id
and     pevp.input_value_id = c_type_p_iv_id
and     pevdate.input_value_id = c_type_accrual_date_iv_id
and     pee.element_entry_id = pevm.element_entry_id
and     pee.element_entry_id = pevp.element_entry_id
and     pee.element_entry_id = pevdate.element_entry_id
and     pevdate.screen_entry_value between fnd_date.date_to_canonical(c_start_date) and fnd_date.date_to_canonical(c_end_date)
and     pee.assignment_id = p_assignment_id ;
--
begin
  hr_utility.set_location('Entering ' || l_proc,10);
  --fnd_file.put_line(fnd_file.log,'In FR_CALCULATE_ACCRUAL' );
  --
  -- Added Following line to support additional day requirements.bug#3030610
  IF p_type IS NULL OR p_type <> 'ADD' THEN
  --
      l_ret :=   per_formula_functions.set_number('TOTAL_ACCRUED_PTO_PROTECTED',0);
      l_ret :=   per_formula_functions.set_number('TOTAL_ACCRUED_PTO_SENIORITY',0);
      l_ret :=   per_formula_functions.set_number('TOTAL_ACCRUED_PTO_MOTHERS',0);
      l_ret :=   per_formula_functions.set_number('TOTAL_ACCRUED_PTO_CONVENTIONAL',0);

      hr_utility.set_location('Step ' || l_proc,20);
      --
      l_inputs(1).name := 'ASSIGNMENT_ID';
      l_inputs(1).value := p_assignment_id;
      l_inputs(2).name := 'DATE_EARNED';
      l_inputs(2).value := fnd_date.date_to_canonical(p_calculation_date);
      l_inputs(3).name := 'ACCRUAL_PLAN_ID';
      l_inputs(3).value := p_plan_id;
      l_inputs(4).name := 'BUSINESS_GROUP_ID';
      l_inputs(4).value := p_business_group_id;
      l_inputs(5).name := 'PAYROLL_ID';
      l_inputs(5).value := p_payroll_id;
      l_inputs(6).name := 'CALCULATION_DATE';
      l_inputs(6).value := fnd_date.date_to_canonical(p_calculation_date);
      l_inputs(7).name := 'ACCRUAL_START_DATE';
      l_inputs(7).value := fnd_date.date_to_canonical(p_accrual_start_date);
      l_inputs(8).name := 'ASSIGNMENT_ACTION_ID';
      l_inputs(8).value := p_assignment_action_id;
      l_inputs(9).name := 'ACCRUAL_LATEST_BALANCE';
      l_inputs(9).value := p_accrual_latest_balance;

      l_outputs(1).name := 'TOTAL_ACCRUED_PTO';
      l_outputs(2).name := 'EFFECTIVE_START_DATE';
      l_outputs(3).name := 'EFFECTIVE_END_DATE';
      l_outputs(4).name := 'ACCRUAL_END_DATE';

      per_formula_functions.run_formula(p_formula_id => p_accrual_formula_id,
                                       p_calculation_date => p_calculation_date,
                                       p_inputs => l_inputs,
                                       p_outputs => l_outputs);


      p_total_accrued_pto := fnd_number.canonical_to_number(l_outputs(1).value);
      p_effective_start_date := fnd_date.canonical_to_date(l_outputs(2).value);
      p_effective_end_date := fnd_date.canonical_to_date(l_outputs(3).value);
      p_accrual_end_date := fnd_date.canonical_to_date(l_outputs(4).value);
      P_total_Accrued_protected       := per_formula_functions.get_number('TOTAL_ACCRUED_PTO_PROTECTED');
      P_total_Accrued_seniority       := per_formula_functions.get_number('TOTAL_ACCRUED_PTO_SENIORITY');
      P_total_Accrued_mothers         := per_formula_functions.get_number('TOTAL_ACCRUED_PTO_MOTHERS');
      P_total_Accrued_conventional    := per_formula_functions.get_number('TOTAL_ACCRUED_PTO_CONVENTIONAL');
      --
    --
  ELSIF p_type = 'ADD' THEN
  /*** That is if p_type = 'ADD' -- The Additional Days Entitlement Process' .bug#3030610**/
     get_accrual_plan_info(
       p_accrual_plan_id          => l_main_holiday_acc_plan_id
      ,p_accrual_date             => p_accrual_start_date
      ,p_accrual_year_start       => l_main_accrual_year_start
      ,p_accrual_year_end         => l_d
      ,p_accrual_start_month      => l_n
      ,p_entitlement_offset       => l_main_entitlement_offset
      ,p_entitlement_duration     => l_main_entitlement_duration
      ,p_working_days             => l_working_days
      ,p_protected_days           => l_protected_days
      ,p_accounting_method        => l_accounting_method
      ,p_ent_accrual_date_iv_id   => l_ent_accrual_date_iv_id -- modified for fetching entitlements
      ,p_ent_reference_sal_iv_id  => l_n
      ,p_ent_reference_days_iv_id => l_n
      ,p_ent_m_iv_id              => l_type_m_iv_id -- modified for fetching entitlements
      ,p_ent_p_iv_id              => l_type_p_iv_id -- modified for fetching entitlements
      ,p_ent_c_iv_id              => l_n
      ,p_ent_s_iv_id              => l_n
      ,p_ent_y_iv_id              => l_n
      ,p_ent_acp_iv_id            => l_n
      ,p_obs_accrual_date_iv_id   => l_n
      ,p_obs_m_iv_id              => l_n
      ,p_obs_p_iv_id              => l_n
      ,p_obs_c_iv_id              => l_n
      ,p_obs_s_iv_id              => l_n
      ,p_obs_y_iv_id              => l_n
      ,p_obs_acp_iv_id            => l_n
      ,p_adj_accrual_date_iv_id   => l_n
      ,p_adj_m_iv_id              => l_n
      ,p_adj_p_iv_id              => l_n
      ,p_adj_c_iv_id              => l_n
      ,p_adj_s_iv_id              => l_n
      ,p_adj_y_iv_id              => l_n
      ,p_adj_acp_iv_id            => l_n
      ,p_main_holiday_acc_plan_id => l_n
      ,p_holiday_element_id       => l_n
      ,p_accrual_plan_element_id  => l_n
      ,p_working_days_iv_id       => l_n
      ,p_protected_days_iv_id     => l_n
      ,p_business_Group_id        => l_n
      ,p_ent_element_id           => l_n
      ,P_obs_element_id           => l_n
      ,P_adj_element_id           => l_n);
      --
      -- Pick up the number of days entitlement from from element entry
      OPEN csr_entitled_days (l_main_accrual_year_start,
                              add_months(l_main_accrual_year_start-1, 12),
                              l_ent_accrual_date_iv_id,
                              l_type_m_iv_id,
                              l_type_p_iv_id);
      FETCH csr_entitled_days INTO l_working_days, l_protected_days;
      CLOSE csr_entitled_days;
      --
      /*** Note that holiday start period = legal period start date
      Legal period start date = add_months(l_main_accrual_year_start,l_main_entitlement_offset) ***/
     --
      l_inputs(1).name := 'ASSIGNMENT_ID';
      l_inputs(1).value := p_assignment_id;
      l_inputs(2).name := 'CALCULATION_DATE';
      l_inputs(2).value := fnd_date.date_to_canonical(p_calculation_date);
      l_inputs(3).name := 'LEGAL_PERIOD';
      -- hard coding the legal period
      l_inputs(3).value := 6;
      --
      l_inputs(4).name := 'MAIN_HOLIDAY_ACC_PLAN_ID';
      l_inputs(4).value := p_main_holiday_acc_plan_id;
      l_inputs(5).name := 'ACCOUNTING_METHOD';
      l_inputs(5).value := l_accounting_method;
      l_inputs(6).name := 'PROCESS_FLAG';
      l_inputs(6).value := p_type;
      l_inputs(7).name := 'MAIN_WORKING_DAYS';
      l_inputs(7).value := l_working_days;
      l_inputs(8).name := 'MAIN_PROTECTED_DAYS';
      l_inputs(8).value := l_protected_days;
      l_inputs(9).name := 'LEGAL_PERIOD_START_DATE';
      -- modified input values and value name
      l_inputs(9).value := fnd_date.date_to_canonical(p_legal_period_start_date);
      l_inputs(10).name := 'HOLIDAY_PERIOD_START_DATE';
      l_inputs(10).value := fnd_date.date_to_canonical(add_months(l_main_accrual_year_start,l_main_entitlement_offset));
      l_inputs(11).name := 'HOLIDAY_PERIOD';
      l_inputs(11).value := l_main_entitlement_duration;


      l_outputs(1).name := 'ADDITIONAL_ENTITLEMENT';


   hr_utility.set_location('Formula ID:'||p_accrual_formula_id, 555);
   hr_utility.set_location('Calc Date:'||p_calculation_date,556);
   hr_utility.set_location(l_inputs(1).name||':'||l_inputs(1).value,557);
   hr_utility.set_location(l_inputs(2).name||':'||l_inputs(2).value,558);
   hr_utility.set_location(l_inputs(3).name||':'||l_inputs(3).value,559);
   hr_utility.set_location(l_inputs(4).name||':'||l_inputs(4).value,560);
   hr_utility.set_location(l_inputs(5).name||':'||l_inputs(5).value,561);
   hr_utility.set_location(l_inputs(6).name||':'||l_inputs(6).value,562);
   hr_utility.set_location(l_inputs(7).name||':'||l_inputs(7).value,563);
   hr_utility.set_location(l_inputs(8).name||':'||l_inputs(8).value,564);
   hr_utility.set_location(l_inputs(9).name||':'||l_inputs(9).value,565);
   hr_utility.set_location(l_inputs(10).name||':'||l_inputs(10).value,566);
   hr_utility.set_location(l_inputs(11).name||':'||l_inputs(11).value,567);


    per_formula_functions.run_formula(p_formula_id => p_accrual_formula_id,
                                         p_calculation_date => p_calculation_date,
                                         p_inputs => l_inputs,
                                         p_outputs => l_outputs);

      p_total_accrued_pto := nvl(l_outputs(1).value,0);
      hr_utility.set_location( l_outputs(1).name||':'|| p_total_accrued_pto,21);

  END IF;
  --
  --fnd_file.put_line(fnd_file.log,'Leaving FR_CALCULATE_ACCRUAL' );
--
end FR_Calculate_Accrual;
--

-------------------------------------------------------------------------------
-- OBSOLETION_PROCEDURE
-------------------------------------------------------------------------------
procedure obsoletion_procedure
(p_business_group_id        IN  number
,p_assignment_id            IN  number default null
,p_accrual_plan_id          IN  number
,p_effective_date           IN  date
,p_accrual_date             IN  date
,p_formula_id               IN  number
,p_payroll_id               IN  number
,p_net_entitlement          IN  number
,p_net_main_days            IN  number
,p_net_conven_days          IN  number
,p_net_seniority_days       IN  number
,p_net_protected_days       IN  number
,p_net_youngmother_days     IN  number
,p_new_main_days            OUT NOCOPY number
,p_new_conven_days          OUT NOCOPY number
,p_new_seniority_days       OUT NOCOPY number
,p_new_protected_days       OUT NOCOPY number
,p_new_youngmother_days     OUT NOCOPY number) is


l_date               date;
l_ent_start_date     date;
l_expiry_date        date;
l_max_carryovers     number;
no_of_obsoletes      number;
l_number             number;
l_unused_date        date;
l_proc VARCHAR2(72) :=    g_package||' obsoletion_Procedure ';

begin
  hr_utility.set_location('Entering ' || l_proc,10);
  --fnd_file.put_line(fnd_file.log,'In Obsoletion Procedure' );

  l_number := per_formula_functions.set_date('PROCESS_DATE', p_effective_date);

  l_number := get_fr_latest_ent_date(
           P_ASSIGNMENT_ID           => p_assignment_id,
           P_ACCRUAL_PLAN_ID         => p_accrual_plan_id,
           P_EFFECTIVE_DATE          => p_accrual_date,
           P_LATEST_DATE             => l_date,
           P_ENTITLEMENT_START_DATE  => l_ent_start_date,
           P_ACCRUAL_START_DATE      => l_date,
           P_ACCRUAL_END_DATE        => l_unused_date);

  hr_utility.set_location('Step ' || l_proc,30);

  --fnd_file.put_line(fnd_file.log,'Ent start date' || l_ent_start_date );
  --fnd_file.put_line(fnd_file.log,'Formula ID' || p_formula_id );
  --fnd_file.put_line(fnd_file.log,'Assignment id' || p_assignment_id );
  --fnd_file.put_line(fnd_file.log,'Accrual Plan Id' || p_accrual_plan_id );
  --fnd_file.put_line(fnd_file.log,'Business Group Id' || p_business_group_id );
  --fnd_file.put_line(fnd_file.log,'Payroll Id' || p_payroll_id );
  --fnd_file.put_line(fnd_file.log,'Effective Date' || p_effective_date );

  per_accrual_calc_functions.get_carry_over_values(
    p_co_formula_id      =>   p_formula_id
   ,p_assignment_id      =>   p_assignment_id
   ,p_accrual_plan_id    =>   p_accrual_plan_id
   ,p_business_group_id  =>   p_business_group_id
   ,p_payroll_id         =>   p_payroll_id
   ,p_calculation_date   =>   l_ent_start_date
   ,p_session_date       =>   p_effective_date
   ,p_accrual_term       =>   'PROCESS'
   ,p_effective_date     =>   l_date
   ,p_expiry_date        =>   l_expiry_date
   ,p_max_carry_over     =>   l_max_carryovers );

  no_of_obsoletes := p_net_entitlement - l_max_carryovers;
  hr_utility.set_location('Step ' || l_proc,40);

  --fnd_file.put_line(fnd_file.log,'Net entitlement' || p_net_entitlement );
  --fnd_file.put_line(fnd_file.log,'Carryovers' || l_max_carryovers );
  --fnd_file.put_line(fnd_file.log,'no of obsoletes' || no_of_obsoletes );

  FOR i in 1..5 LOOP

    IF (i = 1 and p_net_youngmother_days > 0 and no_of_obsoletes > 0) then

      if (no_of_obsoletes >= p_net_youngmother_days ) then
        no_of_obsoletes := no_of_obsoletes - p_net_youngmother_days;
        p_new_youngmother_days := p_net_youngmother_days;
      else
        p_new_youngmother_days  := no_of_obsoletes;
        p_new_main_days       := 0;
        p_new_conven_days     := 0;
        p_new_seniority_days  := 0;
        p_new_protected_days  := 0;
        no_of_obsoletes       := 0;
        hr_utility.set_location('Step ' || l_proc,50);
      end if;
    END IF;
    IF (i = 2 and p_net_protected_days > 0 and no_of_obsoletes > 0) then
      if (no_of_obsoletes >= p_net_protected_days ) then
        no_of_obsoletes := no_of_obsoletes - p_net_protected_days ;
        p_new_protected_days := p_net_protected_days;
      else
        p_new_main_days       := 0;
        p_new_conven_days     := 0;
        p_new_seniority_days  := 0;
        p_new_protected_days  := no_of_obsoletes;
        no_of_obsoletes       := 0;
        hr_utility.set_location('Step ' || l_proc,60);
      end if;
    END IF;
    IF (i = 3 and p_net_seniority_days > 0 and no_of_obsoletes > 0) then
      if (no_of_obsoletes >= p_net_seniority_days ) then
        no_of_obsoletes := no_of_obsoletes - p_net_seniority_days;
        p_new_seniority_days := p_net_seniority_days;
      else
        p_new_main_days      := 0;
        p_new_conven_days    := 0;
        p_new_seniority_days := no_of_obsoletes;
        no_of_obsoletes      := 0;
        hr_utility.set_location('Step ' || l_proc,70);
      end if;
    END IF;
    IF (i = 4 and p_net_conven_days > 0 and no_of_obsoletes > 0) then
      if (no_of_obsoletes >= p_net_conven_days ) then
        no_of_obsoletes := no_of_obsoletes - p_net_conven_days;
        p_new_conven_days := p_net_conven_days;
      else
        p_new_main_days      := 0;
        p_new_conven_days    := no_of_obsoletes;
        no_of_obsoletes      := 0;
      end if;
    END IF;
    IF (i = 5 and p_net_main_days > 0 and no_of_obsoletes > 0) then
      if (no_of_obsoletes >= p_net_main_days ) then
        no_of_obsoletes := no_of_obsoletes - p_net_main_days;
        p_new_main_days := p_net_main_days;
      else
        p_new_main_days     := no_of_obsoletes;
        no_of_obsoletes     := 0;
        hr_utility.set_location('Step ' || l_proc,80);
      end if;
    END IF;
  end loop;

  p_new_youngmother_days  := 0 - p_new_youngmother_days;
  p_new_main_days               := 0 - p_new_main_days;
  p_new_conven_days     := 0 - p_new_conven_days;
  p_new_seniority_days  := 0 - p_new_seniority_days;
  p_new_protected_days  := 0 - p_new_protected_days;

  --fnd_file.put_line(fnd_file.log,' Net Mothers' || p_net_youngmother_days );
  --fnd_file.put_line(fnd_file.log,'Net Main' || p_net_main_days );
  --fnd_file.put_line(fnd_file.log,'Net Conventional' || p_net_conven_days );
  --fnd_file.put_line(fnd_file.log,'Net Seniority' || p_net_seniority_days );
  --fnd_file.put_line(fnd_file.log,'Net Protected' || p_net_protected_days );

  --fnd_file.put_line(fnd_file.log,'Mothers' || p_new_youngmother_days );
  --fnd_file.put_line(fnd_file.log,'Main' || p_new_main_days );
  --fnd_file.put_line(fnd_file.log,'Conventional' || p_new_conven_days );
  --fnd_file.put_line(fnd_file.log,'Seniority' || p_new_seniority_days );
  --fnd_file.put_line(fnd_file.log,'Protected' || p_new_protected_days );

--fnd_file.put_line(fnd_file.log,'Leaving Obsolete Procedure' );
 hr_utility.set_location('Leaving:  '||l_proc,100);
end obsoletion_procedure;
-------------------------------------------------------------------------------
-- GET_FR_HOLIDAYS_BOOKED                                      FORMULA FUNCTION
-------------------------------------------------------------------------------
function Get_fr_holidays_booked
(P_assignment_id                  IN Number   /* the assignment */
,p_business_Group_id              IN Number
,P_accrual_plan_id                IN Number
,p_accrual_start_date             IN Date
,p_total_booked                  OUT NOCOPY Number
) return number is

l_accrual_plan_id                    Number := p_accrual_plan_id;
l_accrual_year_start                 Date;
l_accrual_year_end                   Date;
l_holiday_element_id                 Number;
l_unused_char                        Varchar2(30);
l_unused_number                      Number;
l_ret                                Number;
--
l_total_m                            Number := 0;
l_total_p                            Number := 0;
l_total_s                            Number := 0;
l_total_c                            Number := 0;
l_total_y                            Number := 0;
l_proc VARCHAR2(72) :=    g_package||' Get_fr_holidays_booked ';
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- fetch variables for this accrual plan
  --
  get_accrual_plan_data(
      p_accrual_plan_id        => l_accrual_plan_id
     ,p_accrual_date           => p_accrual_start_date
     ,p_accrual_year_start     => l_accrual_year_start
     ,p_accrual_year_end       => l_accrual_year_end
     ,p_accounting_method      => l_unused_char
     ,p_entitlement_offset     => l_unused_number
     ,p_ent_ref_days_id        => l_unused_number
     ,p_ent_ref_salary_id      => l_unused_number
     ,p_ent_accrual_date_iv_id => l_unused_number
     ,p_holiday_element_id     => l_holiday_element_id);

  hr_utility.set_location('Step ' || l_proc,20);
  --
  -- Call sub procedure to calculate the totals
  --
  l_ret := Get_fr_holidays_booked_list (
    P_assignment_id                  => P_assignment_id
   ,p_business_Group_id              => p_business_Group_id
   ,P_accrual_plan_id                => P_accrual_plan_id
   ,p_accrual_start_date             => l_accrual_year_start
   ,p_accrual_end_date               => l_accrual_year_end
   ,p_holiday_element_id             => l_holiday_element_id
   ,p_total_m                        => l_total_m
   ,p_total_p                        => l_total_p
   ,p_total_c                        => l_total_c
   ,p_total_s                        => l_total_s
   ,p_total_y                        => l_total_y );

  p_total_booked := nvl(l_total_m,0) + nvl(l_total_p,0) +nvl(l_total_c,0) +nvl(l_total_s,0) +nvl(l_total_y,0);
  --
hr_utility.set_location('Leaving:  '||l_proc,50);
return 1;
END get_fr_holidays_booked;
--
-------------------------------------------------------------------------------
-- GET_FR_HOLIDAYS_BOOKED_LIST
-------------------------------------------------------------------------------
function Get_fr_holidays_booked_list
(P_assignment_id                  IN Number   /* the assignment */
,p_business_Group_id              IN Number
,P_accrual_plan_id                IN Number
,p_accrual_start_date             IN Date
,p_accrual_end_date               IN Date
,p_holiday_element_id             IN Number
,p_total_m                       OUT NOCOPY Number
,p_total_p                       OUT NOCOPY Number
,p_total_c                       OUT NOCOPY Number
,p_total_s                       OUT NOCOPY Number
,p_total_y                       OUT NOCOPY Number
) return number  is

CURSOR csr_booked_holiday (p_assignment_id in number, p_holiday_element_id in number
                          ,p_accrual_year_start date, p_accrual_year_end Date) is
       select  sum(to_number(nvl(paa.abs_information2,'0')))  /* main days booked */
              ,sum(to_number(nvl(paa.abs_information3,'0')))  /* protected days booked */
              ,sum(to_number(nvl(paa.abs_information4,'0')))  /* conventional days booked */
              ,sum(to_number(nvl(paa.abs_information5,'0')))  /* Seniority days booked */
              ,sum(to_number(nvl(paa.abs_information6,'0')))  /* Young mothers days booked */
       from    per_absence_attendances paa
              ,pay_element_entries_f pee
      where    pee.element_link_id in (select element_link_id
                                       from   pay_element_links_f
                                       where  element_type_id = p_holiday_element_id
                                       )
        and   pee.creator_type = 'A'
        and   paa.absence_Attendance_id = pee.creator_id
        and   paa.abs_information1 between fnd_date.date_to_canonical(p_accrual_year_start)
                                       and fnd_date.date_to_canonical(p_accrual_year_end)
        and  pee.assignment_id = p_assignment_id;

l_proc VARCHAR2(72) :=    g_package||' Get_fr_holidays_booked_list ';

BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Fetch breakdown of booked holidays
  --
  hr_utility.set_location('p_assignment_id ' , p_assignment_id);
  hr_utility.set_location('p_holiday_element_id ' , p_holiday_element_id);
  hr_utility.set_location('sd' || to_char(p_accrual_start_date,'dd-mm-yyyy'), 10);
  hr_utility.set_location('ed' ||  to_char(p_accrual_end_date,'dd-mm-yyyy'), 20);

  OPEN csr_booked_holiday (p_assignment_id, p_holiday_element_id, p_accrual_start_date, p_accrual_end_date);
  Fetch csr_booked_holiday into p_total_m, p_total_p, p_total_c ,p_total_s ,p_total_y;
  close csr_booked_holiday;

  hr_utility.set_location('p_total_m ' , p_total_m);
  hr_utility.set_location('p_total_p ' , p_total_p);
  hr_utility.set_location('p_total_c ' , p_total_c);
  hr_utility.set_location('p_total_s ' , p_total_s);
  hr_utility.set_location('p_total_u ' , p_total_y);
  --
  hr_utility.set_location('Leaving:  '||l_proc,100);
return 1;
END get_fr_holidays_booked_list;
--
-------------------------------------------------------------------------------
-- GET_FR_YOUNG_MOTHERS_DAYS
-------------------------------------------------------------------------------
function Get_fr_young_mothers_days
(P_assignment_id                  IN Number
,p_business_Group_id              IN Number
,P_child_age_date                 IN Date     /* CHILD COMPARISON DATE        */
,p_child_age                      IN Number   /* max age of eligible children */
,p_no_of_children                OUT NOCOPY Number   /* number of children */
) return number is

CURSOR csr_count is
       select count(distinct(d.person_id))
       from   per_all_people_f d
             ,per_all_people_f p
             ,per_contact_relationships pcr
             ,per_all_assignments_f     asg
       where asg.assignment_id = P_assignment_id
         and asg.business_group_id = p_business_Group_id
         and asg.person_id = p.person_id
         and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
         and trunc(sysdate) between p.effective_start_date and p.effective_end_date
         and trunc(sysdate) between d.effective_start_date and d.effective_end_date
         and asg.person_id = pcr.person_id
         and pcr.contact_person_id = d.person_id
         and add_months(d.date_of_birth, 12 * 16)  > P_child_age_date
         and add_months(p.date_of_birth, 12 * 21)  > add_months(P_child_age_date, -12)
         and p.current_employee_flag = 'Y'
         and p.sex = 'F'
         and nvl(pcr.date_end,   P_child_age_date) >= P_child_age_date
         AND EXISTS
             ( SELECT pst.INFORMATION3 from per_shared_types pst
                WHERE pcr.contact_type = pst.system_type_cd
                  AND pst.lookup_type = 'CONTACT'
                  AND pst.INFORMATION3 = 'Y'
                  AND ( pst.business_group_id = asg.business_group_id
                      OR   pst.business_group_id  IS NULL)
              );
l_proc VARCHAR2(72) :=    g_package||' Get_fr_young_mothers_days ';

BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  open csr_count;
  fetch csr_count into p_no_of_children;
  close csr_count;
  --
  hr_utility.set_location('p_no_of_children ', p_no_of_children);
  hr_utility.set_location('Leaving:  '||l_proc,50);
  --
return 1;
end Get_fr_young_mothers_days;
-------------------------------------------------------------------------------
-- GET_FR_ACCRUAL_RATE_CHANGES                        ACCRUALS FORMULA FUNCTION
-------------------------------------------------------------------------------
function get_fr_accrual_rate_changes
(p_assignment_id              IN Number
,p_plan_id                    IN Number
,p_month_in_date              IN Date
,p_main_rate                 OUT NOCOPY Number
,p_protected_rate            OUT NOCOPY Number)
return number is
l_ret                            Number;
l_main_rate_defualt_value        Number;
l_protected_rate_defualt_value   Number;
l_month_in_date                   Date := trunc(p_month_in_date);
l_index                          Number;
l_proc VARCHAR2(72) :=    g_package||' get_fr_accrual_rate_changes ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- If the global collection has not been set, set it
  --
  IF p_assignment_id <> nvl(g_rate_assignment_in_table, -1)
     OR
     p_plan_id <> g_plan_in_table THEN
       l_ret := set_fr_Accrual_rate_changes
        (p_assignment_id       =>  p_assignment_id
        ,p_plan_id             =>  p_plan_id
        ,p_start_date          =>  hr_api.g_sot
        ,p_end_date            =>  hr_api.g_eot);
  END IF;
  --
  -- Get defualt values for main and protected
  --
  l_main_rate_defualt_value       := g_rate_tab(1).main_rate;
  l_protected_rate_defualt_value  := g_rate_tab(1).protected_rate;
  --
  -- Search the array for the rate as at l_month_in_date
  -- Look for earliest end date on or after l_month_in_date.
  --
  l_index := 2;
  IF  l_index <=  g_rate_tab.COUNT THEN

    FOR i in 2 .. g_rate_tab.LAST LOOP
      l_index := i;
      EXIT WHEN l_month_in_date <= g_rate_tab(i).end_date;
    END LOOP;
    --
    -- This may be the natural end of loop, the correct record, or both
    --
    IF l_month_in_date between g_rate_tab(l_index).start_date
                          and g_rate_tab(l_index).end_date THEN
      p_main_rate      := g_rate_tab(l_index).main_rate;
      p_protected_rate := nvl(g_rate_tab(l_index).protected_rate,g_rate_tab(1).protected_rate) ;
    ELSE
      --
      -- Gaps in the arry are filled by the defaults
      --
      p_main_rate      := g_rate_tab(1).main_rate;
      p_protected_rate := g_rate_tab(1).protected_rate;
    END IF;
  ELSE
      --
      -- If there are no records, the defualts are used.
      --
      p_main_rate      := nvl(g_rate_tab(1).main_rate,0);
      p_protected_rate := nvl(g_rate_tab(1).protected_rate,0);
  END IF;
  hr_utility.set_location('Leaving:  '||l_proc,50);
return 1;
END ;
-------------------------------------------------------------------------------
-- SET_FR_ACCRUAL_RATE_CHANGES                        ACCRUALS FORMULA FUNCTION
-------------------------------------------------------------------------------
function set_fr_Accrual_rate_changes
(p_assignment_id              IN Number
,p_plan_id                    IN Number
,p_start_date                 IN Date
,p_end_date                   IN Date )
return number is
l_working_days_iv_id             Number;
l_protected_days_iv_id           Number;
l_accrual_plan_element_id        Number;

l_start_date                     date;
l_end_date                       date;
l_main_rate                      Number ;
l_protected_rate                 Number;
l_index                          Number := 1;
l_main_rate_defualt_value        Number;
l_protected_rate_defualt_value   Number;
l_proc VARCHAR2(72) :=    g_package||' set_fr_Accrual_rate_changes ';
--
CURSOR  csr_get_overrides is
        select peevM.effective_start_Date    start_date
              ,peevM.effective_end_date      end_date
              ,peevM.screen_entry_value      main_rate
              ,peevP.screen_entry_value      protected_rate
        from
               pay_element_entries_f pee
              ,pay_element_entry_values_f peevM
              ,pay_element_entry_values_f peevP
        where
               pee.element_entry_id = peevM.element_entry_id
        and    pee.element_entry_id = peevP.element_entry_id(+)
        and    pee.element_link_id in (select element_link_id
                                       from   pay_element_links_f
                                       where  element_type_id = l_accrual_plan_element_id
                                       )
        and   peevM.input_value_id = l_working_days_iv_id
        and   peevP.input_value_id(+) = l_protected_days_iv_id
        and   pee.effective_start_Date = peevM.effective_start_Date
        and   pee.effective_end_Date   = peevM.effective_end_Date
        and   pee.effective_start_Date = peevP.effective_start_Date(+)
        and   pee.effective_end_Date   = peevP.effective_end_Date(+)
        and   pee.assignment_id = p_assignment_id
        Order by
              peevM.effective_start_Date;


BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  get_accrual_plan_overrides(
   p_accrual_plan_id                => p_plan_id
  ,p_accrual_plan_element_id        => l_accrual_plan_element_id
  ,p_working_days_iv_id             => l_working_days_iv_id
  ,p_protected_days_iv_id           => l_protected_days_iv_id
  ,p_main_rate_defualt_value        => l_main_rate_defualt_value
  ,p_protected_rate_defualt_value   => l_protected_rate_defualt_value);

  hr_utility.set_location('accrual plan element id is ' , l_accrual_plan_element_id);
  hr_utility.set_location('accrual plan working days id  is ' , l_working_days_iv_id);
  hr_utility.set_location('accrual plan protected days id is ' , l_protected_days_iv_id);
  --
  -- Clear out the structure
  --
  g_rate_tab.Delete;
  g_rate_assignment_in_table    := -1;
  g_plan_in_table               := -1;
  --
  -- Set the defaults in instance 1
  --
  g_rate_tab(1).main_rate      :=  l_main_rate_defualt_value;
  g_rate_tab(1).protected_rate :=  l_protected_rate_defualt_value;

  for csr_rec in csr_get_overrides LOOP
    l_index := l_index + 1;
    hr_utility.set_location('l_index ' , l_index);

    g_rate_tab(l_index).main_rate      := csr_rec.main_rate;
    g_rate_tab(l_index).protected_rate := csr_rec.protected_rate;
    g_rate_tab(l_index).start_date     := csr_rec.start_date;
    g_rate_tab(l_index).end_date       := csr_rec.end_date;

  END LOOP;
  g_rate_assignment_in_table    := p_assignment_id;
  g_plan_in_table               := p_plan_id;
  --
  hr_utility.set_location('Leaving:  '||l_proc,50);
return 1;
end set_fr_accrual_rate_changes;

-------------------------------------------------------------------------------
-- Get Accrual Plan Overrides
-------------------------------------------------------------------------------
procedure get_accrual_plan_overrides(
 p_accrual_plan_id               IN number
,p_accrual_plan_element_id      OUT NOCOPY Number
,p_working_days_iv_id           OUT NOCOPY Number
,p_protected_days_iv_id         OUT NOCOPY Number
,p_main_rate_defualt_value      OUT NOCOPY Number
,p_protected_rate_defualt_value OUT NOCOPY Number
) is
l_d date;
l_n number;
l_v varchar2(90);
l_accrual_plan_id number := p_accrual_plan_id;
begin

    get_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_element_entry_id         => l_n
    ,p_accrual_date             => l_d
    ,p_accrual_year_start       => l_d
    ,p_accrual_year_end         => l_d
    ,p_accrual_start_month      => l_n
    ,p_entitlement_offset       => l_n
    ,p_entitlement_duration     => l_n
    ,p_working_days             => p_main_rate_defualt_value
    ,p_protected_days           => p_protected_rate_defualt_value
    ,p_accounting_method        => l_v
    ,p_ent_accrual_date_iv_id   => l_n
    ,p_ent_reference_sal_iv_id  => l_n
    ,p_ent_reference_days_iv_id => l_n
    ,p_ent_m_iv_id              => l_n
    ,p_ent_p_iv_id              => l_n
    ,p_ent_c_iv_id              => l_n
    ,p_ent_s_iv_id              => l_n
    ,p_ent_y_iv_id              => l_n
    ,p_ent_acp_iv_id            => l_n
    ,p_obs_accrual_date_iv_id   => l_n
    ,p_obs_m_iv_id              => l_n
    ,p_obs_p_iv_id              => l_n
    ,p_obs_c_iv_id              => l_n
    ,p_obs_s_iv_id              => l_n
    ,p_obs_y_iv_id              => l_n
    ,p_obs_acp_iv_id            => l_n
    ,p_adj_accrual_date_iv_id   => l_n
    ,p_adj_m_iv_id              => l_n
    ,p_adj_p_iv_id              => l_n
    ,p_adj_c_iv_id              => l_n
    ,p_adj_s_iv_id              => l_n
    ,p_adj_y_iv_id              => l_n
    ,p_adj_acp_iv_id            => l_n
    ,p_main_holiday_acc_plan_id => l_n
    ,p_accrual_plan_element_id  => p_accrual_plan_element_id
    ,p_holiday_element_id       => l_n
    ,p_working_days_iv_id       => p_working_days_iv_id
    ,p_protected_days_iv_id     => p_protected_days_iv_id
    ,p_business_group_id        => l_n
    ,p_ent_element_id           => l_n
    ,P_obs_element_id           => l_n
    ,P_adj_element_id           => l_n);
     --
    --
end get_accrual_plan_overrides;
--
-------------------------------------------------------------------------------
-- FUNCTION               GET_FR_LATEST_ENT_DATE               FORMULA_FUNCTION
-------------------------------------------------------------------------------
function get_fr_latest_ent_date
(p_assignment_id              IN Number
,p_accrual_plan_id            IN Number
,p_effective_date             IN Date     /* a date in the accrual plan */
,p_latest_date               OUT NOCOPY Date     /* out - the latest date of storage, or null */
,p_entitlement_start_date    OUT NOCOPY Date     /* out - the ent start relative to effective_date */
,p_accrual_start_date        OUT NOCOPY Date     /* out - the accrual start relative to effective_date */
,p_accrual_end_date          OUT NOCOPY Date )   /* out - the accrual end relative to effective_date */
return number is

l_accrual_start_date             Date;
l_accrual_end_date               Date;
l_ent_accrual_date_iv_id         Number;
l_accrual_plan_id                Number := p_accrual_plan_id;
l_unused_char                    Varchar2(30);
l_unused_number                  Number;
l_entitlement_offset             Number;
l_not_found_date                 Date := to_date('01-01-0001 00:00:00','dd-mm-yyyy hh24:mi:ss');
l_latest_date                    Date;
l_proc VARCHAR2(72) :=    g_package||' get_fr_latest_ent_date ';
--
CURSOR   csr_latest_ent_date (p_ent_accrual_date_iv_id in number, p_Accrual_start_date in date, p_accrual_end_date in date) is
         select  max(pee.effective_end_Date)
         from    pay_element_entry_values_f pevd
                ,pay_element_entries_f      pee
         where   pevd.input_value_id  = p_ent_accrual_date_iv_id
         and     pee.element_entry_id = pevd.element_entry_id
         and     pevd.screen_entry_value between fnd_date.date_to_canonical(p_accrual_start_date)
                                             and fnd_date.date_to_canonical(p_accrual_end_Date)
         and     pee.assignment_id = p_assignment_id;
--
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Get input variables and plan dates
  --
    get_accrual_plan_data(
      p_accrual_plan_id        => l_accrual_plan_id
     ,p_accrual_date           => p_effective_date
     ,p_accrual_year_start     => l_accrual_start_date
     ,p_accrual_year_end       => l_accrual_end_date
     ,p_accounting_method      => l_unused_char
     ,p_entitlement_offset     => l_entitlement_offset
     ,p_ent_ref_days_id        => l_unused_number
     ,p_ent_ref_salary_id      => l_unused_number
     ,p_ent_accrual_date_iv_id => l_ent_accrual_date_iv_id
     ,p_holiday_element_id     => l_unused_number);
  --
  hr_utility.set_location('Step ' || l_proc,30);
  open csr_latest_ent_date (l_ent_accrual_date_iv_id, l_accrual_start_date, l_accrual_end_date );
  fetch csr_latest_ent_date into p_latest_date;

  if p_latest_date is null THEN
    close csr_latest_ent_date;
    p_latest_date := l_not_found_date;
  end if;
  p_accrual_end_date := l_accrual_end_date;
  p_accrual_start_date := l_accrual_start_date;
  p_entitlement_start_date := add_months(p_accrual_start_date, l_entitlement_offset);

  hr_utility.set_location('Leaving:  '||l_proc,60);
  --
return 1;
end get_fr_latest_ent_date ;
--
-------------------------------------------------------------------------------
-- GET_REFERENCE_ENTITLEMENT                        --
-- gets the sum of main and protected days only for the regularized calculation
-- ignores user adjustements ('ADJ' type)
-- called from FR_GET_HOLIDAY_DETAILS
-------------------------------------------------------------------------------
procedure get_reference_entitlement
(p_accrual_plan_id                IN Number
,p_accrual_start_date             IN Date
,p_accrual_end_date               IN Date
,p_assignment_id                  IN Number
,p_ent_ref_days_id                IN Number default null
,p_ent_ref_salary_id              IN Number default null
,p_ent_accrual_date_iv_id         IN Number default null
,p_ref_main_days                 OUT NOCOPY Number
,p_ref_salary                    OUT NOCOPY Number ) is
--
l_ent_ref_days_id                 Number := p_ent_ref_days_id;
l_ent_ref_salary_id               Number := p_ent_ref_salary_id;
l_ent_accrual_date_iv_id          Number := p_ent_accrual_date_iv_id;
l_accrual_plan_id                 Number := p_accrual_plan_id;
l_unused_date                     Date   := null;
l_unused_char                     Varchar2(30);
l_unused_number                   Number;
l_proc VARCHAR2(72) :=    g_package||' get_reference_entitlement ';
--
CURSOR csr_ref_entitlement (p_sal_input_id in number,p_day_input_id in number,p_date_input_id in number) is
       select sum(fnd_number.canonical_to_number(pevn.screen_entry_value)),
              sum(fnd_number.canonical_to_number(pevs.screen_entry_value))
       from   pay_element_entry_values_f pevn
             ,pay_element_entry_values_f pevd
             ,pay_element_entry_values_f pevs
             ,pay_element_entries_f      pee
       where  pevn.input_value_id  = p_day_input_id
       and    pevd.input_value_id  = p_date_input_id
       and    pevs.input_value_id  = p_sal_input_id
       and    pee.element_entry_id = pevn.element_entry_id
       and    pee.element_entry_id = pevs.element_entry_id
       and    pee.element_entry_id = pevd.element_entry_id
       and    pevd.screen_entry_value between fnd_date.date_to_canonical(p_accrual_start_date)
                                            and fnd_date.date_to_canonical(p_accrual_end_Date)
       and    pee.assignment_id = p_assignment_id;

l_fr_plan_info g_fr_plan_info;

BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Ensure correct globals are set
  --
  p_ref_main_days      := 0;
  p_ref_salary         := 0;

  if l_ent_ref_days_id is null then

    l_fr_plan_info := get_fr_accrual_plan_info(
       p_accrual_plan_id          => l_accrual_plan_id
      ,p_accrual_date             => p_accrual_start_date);

    l_ent_ref_days_id             := l_fr_plan_info.ent_reference_days_iv_id;
    l_ent_ref_salary_id           := l_fr_plan_info.ent_reference_sal_iv_id;
    l_ent_accrual_date_iv_id      := l_fr_plan_info.ent_accrual_date_iv_id;
  end if;

  hr_utility.set_location('IN REF ENTITLEMENT',10);
  hr_utility.set_location('l_ent_ref_salary_id ',l_ent_ref_salary_id );
  hr_utility.set_location('l_ent_ref_days_id',l_ent_ref_days_id);
  hr_utility.set_location('l_ent_accrual_date_iv_id',l_ent_accrual_date_iv_id);
  hr_utility.set_location('p_accrual_start_date' || p_accrual_start_date,10);
  hr_utility.set_location('p_accrual_end_date'|| p_accrual_end_date,10);
  hr_utility.set_location('p_assignment_id',  p_assignment_id);
  hr_utility.set_location('Step ' || l_proc,30);

  open csr_ref_entitlement ( l_ent_ref_salary_id,  l_ent_ref_days_id,  l_ent_accrual_date_iv_id );
  fetch csr_ref_entitlement into p_ref_main_days, p_ref_salary;
  close csr_ref_entitlement;

  hr_utility.set_location('p_ref_main_days ', p_ref_main_days);
  hr_utility.set_location('p_ref_salary ' ,p_ref_salary);

  --fnd_file.put_line(fnd_file.log,'Leaving ' || l_proc);
  --
  hr_utility.set_location('Leaving:  '||l_proc,50);
end get_reference_entitlement;
-------------------------------------------------------------------------------
-- GET_ACCRUAL_PLAN_DATA
-------------------------------------------------------------------------------
procedure get_accrual_plan_data(
 p_accrual_plan_id           IN OUT NOCOPY number
,p_element_entry_id          IN number default null
,p_accrual_date              IN date default null
,p_accrual_year_start       OUT NOCOPY date
,p_accrual_year_end         OUT NOCOPY date
,p_accounting_method        OUT NOCOPY varchar2
,p_entitlement_offset       OUT NOCOPY number
,p_ent_ref_days_id          OUT NOCOPY number
,p_ent_ref_salary_id        OUT NOCOPY number
,p_ent_accrual_date_iv_id   OUT NOCOPY Number
,p_holiday_element_id       OUT NOCOPY Number) is

l_d date;
l_n number;
l_v varchar2(90);
l_accrual_plan_id number := p_accrual_plan_id;
l_proc VARCHAR2(72) :=    g_package||' get_accrual_plan_data ';
begin

    get_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_element_entry_id         => p_element_entry_id
    ,p_accrual_date             => p_accrual_date
    ,p_accrual_year_start       => p_accrual_year_start
    ,p_accrual_year_end         => p_accrual_year_end
    ,p_accrual_start_month      => l_n
    ,p_entitlement_offset       => p_entitlement_offset
    ,p_entitlement_duration     => l_n
    ,p_working_days             => l_n
    ,p_protected_days           => l_n
    ,p_accounting_method        => p_accounting_method
    ,p_ent_accrual_date_iv_id   => p_ent_accrual_date_iv_id
    ,p_ent_reference_sal_iv_id  => p_ent_ref_salary_id
    ,p_ent_reference_days_iv_id => p_ent_ref_days_id
    ,p_ent_m_iv_id              => l_n
    ,p_ent_p_iv_id              => l_n
    ,p_ent_c_iv_id              => l_n
    ,p_ent_s_iv_id              => l_n
    ,p_ent_y_iv_id              => l_n
    ,p_ent_acp_iv_id            => l_n
    ,p_obs_accrual_date_iv_id   => l_n
    ,p_obs_m_iv_id              => l_n
    ,p_obs_p_iv_id              => l_n
    ,p_obs_c_iv_id              => l_n
    ,p_obs_s_iv_id              => l_n
    ,p_obs_y_iv_id              => l_n
    ,p_obs_acp_iv_id            => l_n
    ,p_adj_accrual_date_iv_id   => l_n
    ,p_adj_m_iv_id              => l_n
    ,p_adj_p_iv_id              => l_n
    ,p_adj_c_iv_id              => l_n
    ,p_adj_s_iv_id              => l_n
    ,p_adj_y_iv_id              => l_n
    ,p_adj_acp_iv_id            => l_n
    ,p_main_holiday_acc_plan_id => l_n
    ,p_holiday_element_id       => p_holiday_element_id
    ,p_accrual_plan_element_id  => l_n
    ,p_working_days_iv_id       => l_n
    ,p_protected_days_iv_id     => l_n
    ,p_business_Group_id        => l_n
    ,p_ent_element_id           => l_n
    ,P_obs_element_id           => l_n
    ,P_adj_element_id           => l_n);
    --
    p_accrual_plan_id := l_accrual_plan_id;
    --
    hr_utility.set_location('Leaving:  '||l_proc,50);
end get_accrual_plan_data;
--
-------------------------------------------------------------------------------
-- Get_Payment_info
-------------------------------------------------------------------------------
procedure get_payment_info(
 p_days_input_id             OUT NOCOPY number
,p_protected_days_input_id   OUT NOCOPY number
,p_element_type_id           OUT NOCOPY number
,p_absence_input_id          OUT NOCOPY Number) is

CURSOR   csr_input_values is
         select piv1.input_value_id
               ,piv2.input_value_id
               ,piv3.input_value_id
               ,pet.element_type_id
         from   pay_element_types_f pet
               ,pay_input_values_f  piv1
               ,pay_input_values_f  piv2
               ,pay_input_values_f  piv3
         where  piv1.element_Type_id = pet.element_type_id
         and    piv2.element_Type_id = pet.element_type_id
         and    piv3.element_Type_id = pet.element_type_id
         and    pet.legislation_code = 'FR'
--         and    piv1.legislation_code = 'FR'
--         and    piv2.legislation_code = 'FR'
--         and    piv3.legislation_code = 'FR'
         and    pet.business_group_id is null
         and    piv1.business_group_id is null
         and    piv2.business_group_id is null
         and    piv3.business_group_id is null
         and    pet.element_name = 'FR_HOLIDAY_PAY'
         and    piv1.name = 'Rate'
         and    piv2.name = 'Protected Days Paid'
         and    piv3.name = 'Absence Attendance ID';

 -- /* legislation comments*/
  --
l_proc VARCHAR2(72) :=    g_package||' get_payment_info ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  open csr_input_values;
  fetch csr_input_values into p_days_input_id, p_protected_days_input_id, p_absence_input_id, p_element_type_id;
  close csr_input_values;
  hr_utility.set_location('Leaving:  '||l_proc,50);
END get_payment_info;
--
-------------------------------------------------------------------------------
-- GET_PREVIOUS_HOLIDAY_ABSENCE
-------------------------------------------------------------------------------
procedure get_previous_holiday_absence(
 p_absence_attendance_id       IN Number
,p_assignment_id               IN Number
,p_paid_element_type_id        IN Number default null
,p_days_input_id               IN Number default null
,p_protected_days_input_id     IN Number default null
,p_absence_attendance_input_ID IN Number default null
,p_total_days_paid            OUT NOCOPY Number
,p_protected_days_paid        OUT NOCOPY Number ) is
--
l_paid_element_type_id            Number := p_paid_element_type_id;
l_days_input_id                   Number := p_days_input_id;
l_protected_days_input_id         Number := p_protected_days_input_id;
l_absence_attendance_input_ID     Number := p_absence_attendance_input_ID;
l_proc VARCHAR2(72) :=    g_package||' get_previous_holiday_absence ';
l_fr_pay_info g_fr_pay_info;
l_fr_pay_r_info g_fr_pay_info;
l_total_days_paid                 Number;
l_protected_days_paid             Number;
l_start_date                      Date;
--
-- The payment element is seeded; it will always contain the protected days element regardless of the
-- plan type, however the prrv entry for protected may not exist.
--
-- handles all paid absence attendance ids
--
CURSOR   csr_previous_payments (l_days_input_id number         ,l_assignment_id number
                               ,l_absence_attendance_id number ,l_protected_days_input_id number
                               ,l_paid_element_type_id  number, l_absence_attendance_input_ID number
                               ,l_start_date            date) is
select sum(decode(prrvm.input_value_id,l_days_input_id, prrvm.result_value))
      ,sum(decode(prrvm.input_value_id,l_protected_days_input_id, prrvm.result_value))
from   pay_run_result_values  prrvm
      ,pay_run_result_values  prrva
      ,pay_run_results        prr
      ,pay_assignment_actions paa
      ,pay_payroll_actions    ppa
where  prrvm.run_result_id      = prr.run_result_id
  and  prrva.run_result_id      = prr.run_result_id
  and  prrvm.input_value_id     in(l_days_input_id, l_protected_days_input_id)
  and  prrva.input_value_id     = l_absence_attendance_input_id
  and  prrva.result_value       = l_absence_attendance_id
  and  prr.assignment_action_id = paa.assignment_action_id
  and  prr.element_type_id      = l_paid_element_type_id
  and  prr.status               in ('P','PA')
  and  paa.payroll_action_id    = ppa.payroll_Action_id
  and  ppa.effective_date      >= l_start_date
  and  paa.assignment_id        = l_assignment_id;

/* fetch from before the absence started */
cursor   csr_start_date is
select date_start - 366
from per_absence_attendances
where absence_attendance_id = p_absence_attendance_id;

BEGIN

  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- If necessary fetch the input values that hold the number of days / protected days paid.
  --
  if p_days_input_id is null then
    l_fr_pay_info := get_payment_globals;
  end if;
  --
  open csr_start_date;
  fetch csr_start_date into l_start_date;
  close csr_start_date;
  hr_utility.trace('start_date is ' || to_char(l_start_date,'dd-mm-yyyy'));
  --
  open csr_previous_payments(l_fr_pay_info.pay_total_days_input_ID, p_assignment_id, p_absence_attendance_id
                            ,l_fr_pay_info.pay_protected_days_input_ID, l_fr_pay_info.pay_element_id
                            ,l_fr_pay_info.pay_abs_attend_input_id, l_start_date);
  fetch csr_previous_payments into p_total_days_paid, p_protected_days_paid;
  close csr_previous_payments;

  p_total_days_paid     := nvl(p_total_days_paid, 0);
  p_protected_days_paid := nvl(p_protected_days_paid, 0);

  -- also check for retro results for the same
  open csr_previous_payments(l_fr_pay_r_info.pay_total_days_input_ID, p_assignment_id, p_absence_attendance_id
                            ,l_fr_pay_r_info.pay_protected_days_input_ID, l_fr_pay_r_info.pay_element_id
                            ,l_fr_pay_r_info.pay_abs_attend_input_id ,l_start_date);
  fetch csr_previous_payments into l_total_days_paid, l_protected_days_paid;
  close csr_previous_payments;

  p_total_days_paid     := nvl(p_total_days_paid, 0) +  nvl(l_total_days_paid,0);
  p_protected_days_paid := nvl(p_protected_days_paid, 0) + nvl(l_protected_days_paid,0);

  hr_utility.trace('get_previous_absence_paid p_absence_attendance_id is ' || to_char(p_absence_attendance_id));
  hr_utility.trace('p_total_days_paid is       ' || to_char(p_total_days_paid));
  hr_utility.trace('p_protected_days_paid is   ' || to_char(p_protected_days_paid));
  --fnd_file.put_line(fnd_file.log,'pay_total_days_input_ID is ' || to_char(l_fr_pay_info.pay_total_days_input_ID));
  --fnd_file.put_line(fnd_file.log,'pay_protected_days_input_ID is ' || to_char(l_fr_pay_info.pay_protected_days_input_ID));
  --fnd_file.put_line(fnd_file.log,'l_pay_element_id is ' || to_char(l_fr_pay_info.pay_element_id));
  --fnd_file.put_line(fnd_file.log,'p_assignment_id is ' || to_char(p_assignment_id));
  --fnd_file.put_line(fnd_file.log,'p_total_days_paid is ' || to_char(p_total_days_paid));
  --fnd_file.put_line(fnd_file.log,'p_protected_days_paid is ' || to_char(p_protected_days_paid));
  hr_utility.set_location('Leaving:  '||l_proc,50);
end get_previous_holiday_absence;
--
-------------------------------------------------------------------------------
-- GET_ACCRUAL_PLAN_INFO
-------------------------------------------------------------------------------
procedure get_accrual_plan_info(
 p_accrual_plan_id           IN OUT NOCOPY number
,p_element_entry_id          IN number default null
,p_accrual_date              IN date default null
,p_accrual_year_start       OUT NOCOPY date
,p_accrual_year_end         OUT NOCOPY date
,p_accrual_start_month      OUT NOCOPY number
,p_entitlement_offset       OUT NOCOPY number
,p_entitlement_duration     OUT NOCOPY number
,p_working_days             OUT NOCOPY Number
,p_protected_days           OUT NOCOPY Number
,p_accounting_method        OUT NOCOPY Varchar2
,p_ent_accrual_date_iv_id   OUT NOCOPY number
,p_ent_reference_sal_iv_id  OUT NOCOPY number
,p_ent_reference_days_iv_id OUT NOCOPY number
,p_ent_m_iv_id              OUT NOCOPY number
,p_ent_p_iv_id              OUT NOCOPY number
,p_ent_c_iv_id              OUT NOCOPY number
,p_ent_s_iv_id              OUT NOCOPY number
,p_ent_y_iv_id              OUT NOCOPY number
,p_ent_acp_iv_id            OUT NOCOPY Number
,p_obs_accrual_date_iv_id   OUT NOCOPY number
,p_obs_m_iv_id              OUT NOCOPY number
,p_obs_p_iv_id              OUT NOCOPY number
,p_obs_c_iv_id              OUT NOCOPY number
,p_obs_s_iv_id              OUT NOCOPY number
,p_obs_y_iv_id              OUT NOCOPY number
,p_obs_acp_iv_id            OUT NOCOPY Number
,p_adj_accrual_date_iv_id   OUT NOCOPY number
,p_adj_m_iv_id              OUT NOCOPY number
,p_adj_p_iv_id              OUT NOCOPY number
,p_adj_c_iv_id              OUT NOCOPY number
,p_adj_s_iv_id              OUT NOCOPY number
,p_adj_y_iv_id              OUT NOCOPY number
,p_adj_acp_iv_id            OUT NOCOPY Number
,p_main_holiday_acc_plan_id OUT NOCOPY number
,p_holiday_element_id       OUT NOCOPY Number
,p_accrual_plan_element_id  OUT NOCOPY Number
,p_working_days_iv_id       OUT NOCOPY Number
,p_protected_days_iv_id     OUT NOCOPY Number
,p_business_Group_id        OUT NOCOPY Number
,p_ent_element_id           OUT NOCOPY Number
,P_obs_element_id           OUT NOCOPY Number
,P_adj_element_id           OUT NOCOPY Number) is


CURSOR csr_plan_input (p_element_type_id in number) is
select piv1.input_value_id       acp_plan_id
from   pay_input_values_f  piv1
where piv1.element_type_id = p_element_type_id
  and piv1.display_sequence = 10;

CURSOR csr_reference_inputs (p_ent_accrual_date_iv in number) is
select piv1.input_value_id         reference_salary
      ,piv2.input_value_id         reference_days
from   pay_input_values_f  piv1
      ,pay_input_values_f  piv2
      ,pay_input_values_f  piv
where piv1.element_type_id  = piv2.element_type_id
  and piv1.element_type_id = piv.element_type_id
  and piv.input_value_id = p_ent_accrual_date_iv
  and piv1.display_sequence = 80
  and piv2.display_sequence = 90;

CURSOR csr_plan_info (p_accrual_plan_id in Number) is
select nvl(pap.information1,6)       accrual_start_month
      ,pap.information2       entitlement_offset
      ,pap.information3       entitlement_duration
      ,pap.information4       working_days
      ,pap.information5       protected_days
      ,pap.information6       accounting_method
      ,pap.information7       main_holiday_acc_plan_id
      ,pap.information8       ent_m_iv_id
      ,pap.information9       ent_p_iv_id
      ,pap.information10      ent_c_iv_id
      ,pap.information11      ent_s_iv_id
      ,pap.information12      ent_y_iv_id
      ,pap.information13      obs_m_iv_id
      ,pap.information14      obs_p_iv_id
      ,pap.information15      obs_c_iv_id
      ,pap.information16      obs_s_iv_id
      ,pap.information17      obs_y_iv_id
      ,pap.information18      adj_m_iv_id
      ,pap.information19      adj_p_iv_id
      ,pap.information20      adj_c_iv_id
      ,pap.information21      adj_s_iv_id
      ,pap.information22      adj_y_iv_id
      ,pap.information23      ent_accrual_date_iv_id
      ,pap.information24      obs_accrual_date_iv_id
      ,pap.information25      adj_accrual_date_iv_id
      ,pap.information26      working_days_iv_id
      ,pap.information27      protected_days_iv_id
      ,pap.accrual_plan_element_type_id accrual_plan_element_id
      ,piv.element_type_id    holiday_element_id
      ,pivE.element_type_id    ENT_element_id
      ,pivO.element_type_id    OBS_element_id
      ,pivA.element_type_id    ADJ_element_id
      ,pap.business_group_id  business_Group_id
from   pay_accrual_plans  pap
      ,pay_input_values_f piv
      ,pay_input_values_f pivE
      ,pay_input_values_f pivO
      ,pay_input_values_f pivA
where  pap.accrual_plan_id = p_accrual_plan_id
and    piv.input_value_id  = pap.pto_input_value_id
and    pivE.input_value_id  = pap.information8
and    pivO.input_value_id  = pap.information13
and    pivA.input_value_id  = pap.information18;

CURSOR  csr_plan_info_ee (c_element_entry_id in number) is
select pap.information1       accrual_start_month
      ,pap.information2       entitlement_offset
      ,pap.information3       entitlement_duration
      ,pap.information4       working_days
      ,pap.information5       protected_days
      ,pap.information6       accounting_method
      ,pap.information7       main_holiday_acc_plan_id
      ,pap.information8       ent_m_iv_id
      ,pap.information9       ent_p_iv_id
      ,pap.information10      ent_c_iv_id
      ,pap.information11      ent_s_iv_id
      ,pap.information12      ent_y_iv_id
      ,pap.information13      obs_m_iv_id
      ,pap.information14      obs_p_iv_id
      ,pap.information15      obs_c_iv_id
      ,pap.information16      obs_s_iv_id
      ,pap.information17      obs_y_iv_id
      ,pap.information18      adj_m_iv_id
      ,pap.information19      adj_p_iv_id
      ,pap.information20      adj_c_iv_id
      ,pap.information21      adj_s_iv_id
      ,pap.information22      adj_y_iv_id
      ,pap.information23      ent_accrual_date_iv_id
      ,pap.information24      obs_accrual_date_iv_id
      ,pap.information25      adj_accrual_date_iv_id
      ,pap.accrual_plan_element_type_id accrual_plan_element_id
      ,pap.accrual_plan_id    accrual_plan_id
      ,pap.information26      working_days_iv_id
      ,pap.information27      protected_days_iv_id
      ,piv.element_Type_id    holiday_element_id
      ,pivE.element_type_id    ENT_element_id
      ,pivO.element_type_id    OBS_element_id
      ,pivA.element_type_id    ADJ_element_id
      ,pap.business_group_id  business_Group_id
from   pay_accrual_plans pap
      ,per_absence_attendances paa
      ,per_absence_attendance_types pat
      ,pay_element_entries_f pee
      ,pay_input_values_f    piv
      ,pay_input_values_f    pivE
      ,pay_input_values_f    pivO
      ,pay_input_values_f    pivA
where  paa.absence_attendance_type_id = pat.absence_attendance_type_id
  and  pivE.input_value_id  = pap.information8
  and  pivO.input_value_id  = pap.information13
  and  pivA.input_value_id  = pap.information18
  and  pat.input_value_id = pap.pto_input_value_id
  and  paa.absence_Attendance_id = pee.creator_id
  and  pee.creator_type = 'A'
  and  piv.input_value_id = pap.pto_input_value_id
  and  pee.element_entry_id = c_element_entry_id;

rec_plan_info csr_plan_info%ROWTYPE;
rec_plan_info_ee csr_plan_info_ee%ROWTYPE;
rec_reference_inputs csr_reference_inputs%ROWTYPE;
l_asat_month number;
l_add_months number := 0;
temp_ent_accrual_date_iv_id number := 0;
temp_accrual_start_month number := 0;
l_proc VARCHAR2(72) :=    g_package||' get_accrual_plan_inf0 ';
BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  IF p_accrual_plan_id is not null THEN
    open csr_plan_info(p_accrual_plan_id);
    fetch csr_plan_info into rec_plan_info;
    close csr_plan_info;
    p_accrual_start_month      := fnd_number.canonical_to_number(rec_plan_info.accrual_start_month);
    p_entitlement_offset       := fnd_number.canonical_to_number(rec_plan_info.entitlement_offset);
    p_entitlement_duration     := fnd_number.canonical_to_number(rec_plan_info.entitlement_duration);
    p_working_days             := fnd_number.canonical_to_number(rec_plan_info.working_days);
    p_protected_days           := fnd_number.canonical_to_number(rec_plan_info.protected_days);
    p_accounting_method        := rec_plan_info.accounting_method;
    p_ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.ent_accrual_date_iv_id);
    p_ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.ent_accrual_date_iv_id);
    p_ent_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_m_iv_id);
    p_ent_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_p_iv_id);
    p_ent_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_c_iv_id);
    p_ent_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_s_iv_id);
    p_ent_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info.ent_y_iv_id);
    p_obs_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.obs_accrual_date_iv_id);
    p_obs_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_m_iv_id);
    p_obs_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_p_iv_id);
    p_obs_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_c_iv_id);
    p_obs_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_s_iv_id);
    p_obs_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info.obs_y_iv_id);
    p_adj_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info.adj_accrual_date_iv_id);
    p_adj_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_m_iv_id);
    p_adj_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_p_iv_id);
    p_adj_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_c_iv_id);
    p_adj_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_s_iv_id);
    p_adj_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info.adj_y_iv_id);
    p_main_holiday_acc_plan_id := fnd_number.canonical_to_number(rec_plan_info.main_holiday_acc_plan_id);
    p_holiday_element_id       := rec_plan_info.holiday_element_id;
    p_business_group_id        := rec_plan_info.business_Group_id;
    temp_ent_accrual_date_iv_id:= fnd_number.canonical_to_number(rec_plan_info.ent_accrual_date_iv_id);
    p_accrual_plan_element_id  := rec_plan_info.accrual_plan_element_id;
    p_working_days_iv_id       := fnd_number.canonical_to_number(rec_plan_info.working_days_iv_id);
    p_protected_days_iv_id     := fnd_number.canonical_to_number(rec_plan_info.protected_days_iv_id);
    p_ent_element_id           := rec_plan_info.ENT_element_id;
    p_obs_element_id           := rec_plan_info.OBS_element_id;
    p_adj_element_id           := rec_plan_info.ADJ_element_id;
    temp_accrual_start_month   := fnd_number.canonical_to_number(rec_plan_info.accrual_start_month);
  ELSE
    open csr_plan_info_ee(p_element_entry_id);
    fetch csr_plan_info_ee into rec_plan_info_ee;
    close csr_plan_info_ee;
    p_accrual_start_month      := fnd_number.canonical_to_number(rec_plan_info_ee.accrual_start_month);
    p_entitlement_offset       := fnd_number.canonical_to_number(rec_plan_info_ee.entitlement_offset);
    p_entitlement_duration     := fnd_number.canonical_to_number(rec_plan_info_ee.entitlement_duration);
    p_working_days             := fnd_number.canonical_to_number(rec_plan_info_ee.working_days);
    p_protected_days           := fnd_number.canonical_to_number(rec_plan_info_ee.protected_days);
    p_accounting_method        := rec_plan_info_ee.accounting_method;
    p_ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.ent_accrual_date_iv_id);
    p_ent_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.ent_accrual_date_iv_id);
    p_ent_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_m_iv_id);
    p_ent_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_p_iv_id);
    p_ent_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_c_iv_id);
    p_ent_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_s_iv_id);
    p_ent_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.ent_y_iv_id);
    p_obs_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.obs_accrual_date_iv_id);
    p_obs_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_m_iv_id);
    p_obs_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_p_iv_id);
    p_obs_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_c_iv_id);
    p_obs_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_s_iv_id);
    p_obs_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.obs_y_iv_id);
    p_adj_accrual_date_iv_id   := fnd_number.canonical_to_number(rec_plan_info_ee.adj_accrual_date_iv_id);
    p_adj_m_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_m_iv_id);
    p_adj_p_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_p_iv_id);
    p_adj_c_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_c_iv_id);
    p_adj_s_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_s_iv_id);
    p_adj_y_iv_id              := fnd_number.canonical_to_number(rec_plan_info_ee.adj_y_iv_id);
    p_main_holiday_acc_plan_id := fnd_number.canonical_to_number(rec_plan_info_ee.main_holiday_acc_plan_id);
    p_holiday_element_id       := rec_plan_info_ee.holiday_element_id;
    p_business_group_id        := rec_plan_info.business_Group_id;
    p_accrual_plan_id          := rec_plan_info_ee.accrual_plan_id;
    p_accrual_plan_element_id  := rec_plan_info_ee.accrual_plan_element_id;
    p_working_days_iv_id       := fnd_number.canonical_to_number(rec_plan_info_ee.working_days_iv_id);
    p_ent_element_id           := rec_plan_info.ENT_element_id;
    p_obs_element_id           := rec_plan_info.OBS_element_id;
    p_adj_element_id           := rec_plan_info.ADJ_element_id;
    p_protected_days_iv_id     := fnd_number.canonical_to_number(rec_plan_info_ee.protected_days_iv_id);
    temp_ent_accrual_date_iv_id:= fnd_number.canonical_to_number(rec_plan_info_ee.ent_accrual_date_iv_id);
    temp_accrual_start_month   := fnd_number.canonical_to_number(rec_plan_info_ee.accrual_start_month);
  END IF;
  --
  open csr_reference_inputs (temp_ent_accrual_date_iv_id);
  fetch csr_reference_inputs into rec_reference_inputs;
  close csr_reference_inputs;
  --
  --
  -- Get the plan dates, if p_accrual_date is not null
  --
hr_utility.set_location('p_accrual_date is ' || p_accrual_date, 20);

  IF p_accrual_date is not null then
    l_asat_month := to_number(to_char(p_accrual_date, 'mm'));
    hr_utility.set_location('l_asat_month is ' || l_asat_month, 30);
    hr_utility.set_location('temp_accrual_start_month is ' || temp_accrual_start_month, 40);
    if l_asat_month < temp_accrual_start_month then
      hr_utility.set_location('Step ', 40);
       l_add_months := -12;
    end if;
    p_accrual_year_start := to_date('01-' || temp_accrual_start_month || '-'
                            || to_char(add_months(p_accrual_date,l_add_months), 'yyyy') || ' 00:00:00'
                              , 'dd-mm-yyyy hh24:mi:ss');
    p_accrual_year_end   := add_months(p_accrual_year_start - 1,12);
  end if;

  hr_utility.set_location('p_accrual_date is ' || p_accrual_date, 50);
  hr_utility.set_location('p_accrual_year_start is ' || p_accrual_year_start, 51);
  hr_utility.set_location('p_accrual_year_end is ' || p_accrual_year_end, 52);


  p_ent_reference_sal_iv_id  := rec_reference_inputs.reference_salary;
  p_ent_reference_days_iv_id := rec_reference_inputs.reference_days;

  open csr_plan_input (p_ent_element_id);
  fetch csr_plan_input into p_ent_acp_iv_id;
  close csr_plan_input;
  open csr_plan_input (p_obs_element_id);
  fetch csr_plan_input into p_obs_acp_iv_id;
  close csr_plan_input;
  open csr_plan_input (p_adj_element_id);
  fetch csr_plan_input into p_adj_acp_iv_id;
  close csr_plan_input;
  hr_utility.set_location('Leaving:  '||l_proc,50);
  --
end get_accrual_plan_info;
/* ===========================================================================
   Name    : Get_fr_holiday_details                           FORMULA_FUNCTION
   --------------------------------------------------------------------------*/
function Get_fr_holiday_details
(P_ELEMENT_ENTRY_ID               IN Number
,p_date_earned                    IN Date
,p_prorate_end                    IN Date     /* the proration period end date - may be null              */
,P_Absence_attendance_ID         OUT NOCOPY Number   /* Identifier of the Absence Record                         */
,P_accrual_plan_id               OUT NOCOPY Number   /* Identifier of the Accrual plan                           */
,P_Entry_Start_Date              OUT NOCOPY Date     /* The element entry start date of the keyed absence        */
,P_Entry_End_Date                OUT NOCOPY Date     /* The element entry end   date of the keyed absence        */
,P_Date_Accrued                  OUT NOCOPY Date     /* keyed absence ddf accrued date                           */
,P_total_Main_Days               OUT NOCOPY Number   /* keyed absence ddf main days in whole absence             */
,P_total_Seniority_Days          OUT NOCOPY Number   /* keyed absence ddf seniority days in whole absence        */
,P_total_Young_Mothers_Days      OUT NOCOPY Number   /* keyed absence ddf YM days in whole absence               */
,P_total_Conventional_Days       OUT NOCOPY Number   /* keyed absence ddf Conventional days in whole absence     */
,P_total_Protected_Days          OUT NOCOPY Number   /* keyed absence ddf Protected days in whole absence        */
,P_taken_total_days              OUT NOCOPY Number   /* total days paid for this absence in previous periods     */
,P_taken_protected_Days          OUT NOCOPY Number   /* protected days paid for this absence in previous periods */
,P_proration_period              OUT NOCOPY Varchar2 /* LAST -  This is the last of proration period             */
,p_regularize_possible           OUT NOCOPY Varchar2 /* if reference values are stored (Y/N) if can do a reg payt*/
,p_session_date                  OUT NOCOPY Date     /* the session date applicable to this session              */
,p_accrue_start_date             OUT NOCOPY Date     /* The accrual start date, relative to the DDF date_accrued */
,p_accrue_end_date               OUT NOCOPY Date     /* The accrual end date, relative to the accrual start date */
,P_Assignment_id                 OUT NOCOPY Number   /* The assignment ID owning the absence                     */
,p_ref_total_accrued             OUT NOCOPY Number   /* The total accrued in the period, for main and protected  */
,p_reference_salary              OUT NOCOPY Number   /* The reference salary for the accrual period - if available */
,p_accounting_method             OUT NOCOPY Varchar2 /* The accounting method from the accrual plan ddf          */
) return number is
--
l_proc        varchar2(72) := g_package||'Get_FR_holiday_details';
-- Accrual Plan DDF
-- values for the whole absence
l_whole_absence_attendance_id         number;
l_whole_date_Accrued                  Date;
l_whole_entry_Start_Date              Date;
l_whole_Entry_End_Date                Date;
l_whole_Main_Days                     Number;
l_whole_seniority_Days                Number;
l_whole_Young_Mothers_Days            Number;
l_whole_Conventional_Days             Number;
l_whole_Protected_Days                Number;
l_whole_total_days                    Number;
-- values for previous part absences
l_previous_Total_Days                 Number := 0;
l_previous_Protected_Days             Number := 0;
-- working variables
l_to_pay_flag                         varchar2(30);    /* is this the last proration period? */
l_session_date                        date;
l_assignment_id                       Number;
l_regularize_possible                 varchar2(10);
l_remaining                           Number := 0;
l_unused                              Number := 0;
l_days_input_id                       Number := 0;
l_protected_days_input_id             Number := 0;
l_paid_element_type_id                Number := 0;
l_reference_days_id                   Number := 0;
l_reference_salary_id                 Number := 0;
l_ent_accrual_date_iv_id              Number := 0;
--
--
CURSOR   csr_get_abs_detail(c_element_entry_id in number) is
         select  pee.effective_start_date
                ,pee.effective_end_date
                ,abs.absence_attendance_id
                ,fnd_date.canonical_to_date(abs.abs_information1)   /* date accrued      */
                ,abs.abs_information2   /* main days         */
                ,abs.abs_information3   /* seniority         */
                ,abs.abs_information4   /* young mothers     */
                ,abs.abs_information5   /* conventional days */
                ,abs.abs_information6   /* protected days    */
                ,pee.assignment_id
         from    pay_element_entries_f  pee
                ,per_absence_attendances abs
         where   pee.element_entry_id = c_element_entry_id
           and   pee.creator_id = abs.absence_attendance_id;
--
CURSOR   csr_session_date is
         select  effective_date
         from    fnd_sessions
         where   session_id = USERENV('SESSIONID');

begin
  hr_utility.set_location('Entering ' || l_proc,10);
  --
  -- Fetch the effective_date
  --
  open csr_session_date;
  fetch csr_session_date into l_session_date;
  close csr_session_date;
  --
  -- Get the absence information for this absence_id
  --
  open csr_get_abs_detail(P_element_entry_id);
  fetch csr_get_abs_detail into l_whole_Entry_Start_Date
                               ,l_whole_Entry_End_Date
                               ,l_whole_Absence_attendance_ID
                               ,l_whole_Date_Accrued
                               ,l_whole_Main_Days
                               ,l_whole_Protected_Days
                               ,l_whole_Conventional_Days
                               ,l_whole_Seniority_Days
                               ,l_whole_Young_Mothers_Days
                               ,l_assignment_id;
  close csr_get_abs_detail;
  hr_utility.set_location('Step ' || l_proc,30);
  --
  -- get the plan start date / end date for this accrual date in the plan.
  --
  get_accrual_plan_data(
     p_element_entry_id       => p_element_entry_id
    ,p_accrual_plan_id        => p_accrual_plan_id
    ,p_accrual_date           => l_whole_Date_Accrued
    ,p_accrual_year_start     => p_accrue_start_date
    ,p_accrual_year_end       => p_accrue_end_date
    ,p_accounting_method      => p_accounting_method
    ,p_entitlement_offset     => l_unused
    ,p_ent_ref_days_id        => l_reference_days_id
    ,p_ent_ref_salary_id      => l_reference_salary_id
    ,p_ent_accrual_date_iv_id => l_ent_accrual_date_iv_id
    ,p_holiday_element_id     => l_unused);
  hr_utility.set_location('Step ' || l_proc,40);
  --
  --
  -- Determine which proration period this releates to. This is useful in determining if any
  -- proration is necessary in the number of days, or if this is the last (or only)period
  -- then all the days should be paid (previous days paid + this period days paid = total requested days).
  -- This function can only return the
  -- If the absence happens to be the same as a whole payroll period, the prorate days are not set.
  -- If element entry end date = prorate_end date
  --  OR
  -- IF prorate end is null and and effective date and element entry end date is in same year / month
  -- then this is the last period.
  --
  hr_utility.set_location('Step ' || l_proc,50);

  if (to_char(l_whole_entry_end_date, 'ddmmyyyy') = to_char(p_prorate_end, 'ddmmyyyy')
         and p_prorate_end <> to_date('47121231','yyyymmdd'))
      OR (p_prorate_end = to_date('47121231','yyyymmdd') and
         to_char(l_whole_entry_end_date, 'mmyyyy') = to_char(p_date_earned,'mmyyyy') ) THEN
    l_to_pay_flag := 'LAST';
  else
    l_to_pay_flag := 'OTHER';
  end if;
  --fnd_file.put_line(fnd_file.log,'l_to_pay_flag is ' || l_to_pay_flag);
  --
  -- Calculate if the accrual period has ended yet - this is needed as the regularized payment
  -- is only possible if the accrual period is closed and therefore the salary balance is known.
  --

  if l_session_date is not null and l_session_date between p_accrue_start_date and p_accrue_end_date then
    l_regularize_possible := 'N';
  hr_utility.set_location('Step ' || l_proc,60);
  else
    l_regularize_possible := 'Y';
  end if;
  --
  -- If this is the LAST proration period, get the number of days already paid for this absence
  --

  hr_utility.set_location('Step ' || l_proc,70);
    get_previous_holiday_absence(
      p_absence_attendance_id         =>  l_whole_Absence_attendance_ID
     ,p_assignment_id                 =>  l_assignment_id
     ,p_total_days_paid               =>  l_previous_total_days          /* all absence types */
     ,p_protected_days_paid           =>  l_previous_protected_days);    /* just protected */
    --
    --fnd_file.put_line(fnd_file.log,'l_previous_total_days is ' || to_char(l_previous_total_days));
    --fnd_file.put_line(fnd_file.log,'l_previous_protected_days is ' || to_char(l_previous_protected_days));
    --fnd_file.put_line(fnd_file.log,'previous element id is ' || to_char(l_previous_protected_days));
  --
  -- If regularization is possible, get the total entitlement for main and protected stored
  -- for this assignment for this accrual period.
  --
  if l_regularize_possible = 'Y' then
  hr_utility.set_location('Step ' || l_proc,80);
    get_reference_entitlement(
        p_accrual_plan_id        => p_accrual_plan_id
       ,p_accrual_start_date     => p_accrue_start_date
       ,p_accrual_end_date       => p_accrue_end_date
       ,p_assignment_id          => l_assignment_id
       ,p_ent_ref_days_id        => l_reference_days_id
       ,p_ent_ref_salary_id      => l_reference_salary_id
       ,p_ent_accrual_date_iv_id => l_ent_accrual_date_iv_id
       ,p_ref_main_days          => p_ref_total_accrued
       ,p_ref_salary             => p_reference_salary
       );
    if nvl(p_reference_salary,0) = 0 THEN
      l_regularize_possible := 'N';
      hr_utility.set_location('Step ' || l_proc,90);
    END IF;
  end if;
  --
  -- Set Out Variables
  --
  p_ref_total_accrued             := nvl(p_ref_total_accrued,0);
  p_reference_salary              := nvl(p_reference_salary,0);
  P_Absence_attendance_ID         := l_whole_Absence_attendance_ID;
  P_Assignment_id                 := l_assignment_id;
  P_Entry_Start_Date              := l_whole_Entry_Start_Date;
  P_Entry_End_Date                := l_whole_Entry_End_Date;
  P_Date_Accrued                  := l_whole_Date_Accrued;
  P_total_Main_Days               := nvl(l_whole_Main_Days,0);
  P_total_Seniority_Days          := nvl(l_whole_Seniority_Days,0);
  P_total_Young_Mothers_Days      := nvl(l_whole_Young_Mothers_Days,0);
  P_total_Conventional_Days       := nvl(l_whole_Conventional_Days,0);
  P_total_Protected_Days          := nvl(l_whole_Protected_Days,0);
  P_taken_total_days              := nvl(l_previous_total_days,0);
  P_taken_protected_Days          := nvl(l_previous_protected_days,0);
  P_proration_period              := l_to_pay_flag;
  p_regularize_possible           := l_regularize_possible;
  p_session_date                  := l_session_date;
  --
  hr_utility.set_location('Leaving:  '||l_proc,50);
return 1;
end Get_fr_holiday_details;
--
--
-------------------------------------------------------------------------------
-- GET_ACCRUAL_RATE_PERCENTAGE                                           /**/
-------------------------------------------------------------------------------
function get_accrual_rate_percentage
(p_date_earned 	       IN  date
,p_assignment_id       IN  number
,p_process_type        IN  varchar2
,p_charges_percentage  OUT NOCOPY number
) return number is
--
l_proc        varchar2(72) := g_package||'get_accrual_rate_percentage';
l_estab_accrual_rate_part_time       Number :=0;
l_estab_accrual_rate_normal          Number :=0;
l_estab_accrual_rate_app             Number :=0;
l_estab_accrual_rate_ori             Number :=0;
l_estab_accrual_rate_yq              Number :=0;
--
l_comp_accrual_rate_part_time        Number :=0;
l_comp_accrual_rate_normal           Number :=0;
l_comp_accrual_rate_app              Number :=0;
l_comp_accrual_rate_ori              Number :=0;
l_comp_accrual_rate_yq               Number :=0;
--
-- Get the accrual charges percentages for the establishment
--
cursor csr_fetch_estab_process_rates(p_date_earned in date, p_assignment_id in number) is
	select  target.org_information3
	       ,target.org_information4
	       ,target.org_information5
	       ,target.org_information6
	       ,target.org_information7
	  from	hr_organization_information target
	       ,per_all_assignments_f assign
	 WHERE  p_date_earned BETWEEN assign.effective_start_date AND assign.effective_end_date
	   AND assign.assignment_id    = p_assignment_id
	   AND assign.establishment_id = target.organization_id
	   AND target.org_information_context = 'FR_ESTAB_ACCRUAL_RATE'
	   AND fnd_date.date_to_canonical(p_date_earned)
	       BETWEEN target.org_information1
           AND nvl(target.org_information2, '4712/12/31 00:00:00');

--
-- Get the accrual charges percentages for the Company
--
cursor csr_fetch_comp_process_rates(p_date_earned in date, p_assignment_id in number) is
	select  target.org_information3
	       ,target.org_information4
               ,target.org_information5
	       ,target.org_information6
	       ,target.org_information7
	  from  hr_organization_units comp
	       ,hr_organization_information target
	       ,hr_organization_information estab
	       ,per_all_assignments_f assign
	WHERE  p_date_earned BETWEEN assign.effective_start_date AND assign.effective_end_date
	  AND  assign.assignment_id     = p_assignment_id
	  AND  assign.establishment_id  = estab.organization_id
	  AND  target.organization_id   = comp.organization_id
	  AND  estab.org_information1   = to_char(comp.organization_id)
	  AND  target.org_information_context 	= 'FR_COMP_ACCRUAL_RATE'
	  AND  fnd_date.date_to_canonical(p_date_earned)
	       BETWEEN target.org_information1
	  AND  nvl(target.org_information2, '4712/12/31 00:00:00');

begin
      hr_utility.set_location('Entering ' || l_proc,10);
      --
      -- Fetch the comp / process type percentages
      --
       open  csr_fetch_comp_process_rates(p_date_earned,p_assignment_id);
       fetch csr_fetch_comp_process_rates into l_comp_accrual_rate_normal,l_comp_accrual_rate_part_time
                                              ,l_comp_accrual_rate_app,   l_comp_accrual_rate_ori
                                              ,l_comp_accrual_rate_yq;
       hr_utility.set_location('Step  '|| l_proc,20);
       --
       if csr_fetch_comp_process_rates%FOUND then

         --
         -- Fetch the Estab / process type percentages
         --
      	 open csr_fetch_estab_process_rates(p_date_earned,p_assignment_id);
      	 fetch csr_fetch_estab_process_rates into l_estab_accrual_rate_normal,l_estab_accrual_rate_part_time
                                                 ,l_estab_accrual_rate_app,   l_estab_accrual_rate_ori
                                                 ,l_estab_accrual_rate_yq;

      	 hr_utility.set_location('Step ' || l_proc,30);
      	 --
      	 if csr_fetch_estab_process_rates%NOTFOUND then

	    --
	    If p_process_type = 'NORMAL' then
	       hr_utility.set_location('Step ' || l_proc,40);
	       p_charges_percentage := l_comp_accrual_rate_normal;
	    elsif p_process_type = 'PART_TIME' then
	       hr_utility.set_location('Step ' || l_proc,50);
	       p_charges_percentage := l_comp_accrual_rate_part_time;
      	    elsif p_process_type = 'APPRENTICE' then
	       hr_utility.set_location('Step ' || l_proc,52);
	       p_charges_percentage := l_comp_accrual_rate_app;
      	    elsif p_process_type = 'ORIENT' then
	       hr_utility.set_location('Step ' || l_proc,53);
	       p_charges_percentage := l_comp_accrual_rate_ori;
      	    elsif p_process_type = 'YPQUAL' then
	       hr_utility.set_location('Step ' || l_proc,54);
	       p_charges_percentage := l_comp_accrual_rate_yq;
	    end if;
	    --
      	 else
      	    --
	    If p_process_type = 'NORMAL' then
		   hr_utility.set_location('Step ' || l_proc,60);
		   p_charges_percentage := nvl(l_estab_accrual_rate_normal,l_comp_accrual_rate_normal);
	    elsif  p_process_type = 'PART_TIME' then
		   hr_utility.set_location('Step ' || l_proc,70);
		   p_charges_percentage := nvl(l_estab_accrual_rate_part_time,l_comp_accrual_rate_part_time);
      	    elsif p_process_type = 'APPRENTICE' then
	       hr_utility.set_location('Step ' || l_proc,72);
	       p_charges_percentage := nvl(l_estab_accrual_rate_app,l_comp_accrual_rate_app);
      	    elsif p_process_type = 'ORIENT' then
	       hr_utility.set_location('Step ' || l_proc,73);
	       p_charges_percentage := nvl(l_estab_accrual_rate_ori,l_comp_accrual_rate_ori);
      	    elsif p_process_type = 'YPQUAL' then
	       hr_utility.set_location('Step ' || l_proc,74);
	       p_charges_percentage := nvl(l_estab_accrual_rate_yq,l_comp_accrual_rate_yq);
	    end if;
	    --
       	end if;
       	--
       	close csr_fetch_estab_process_rates;

       else
      	 open csr_fetch_estab_process_rates(p_date_earned,p_assignment_id);
      	 fetch csr_fetch_estab_process_rates into l_estab_accrual_rate_normal,l_estab_accrual_rate_part_time
                                                 ,l_estab_accrual_rate_app,   l_estab_accrual_rate_ori
                                                 ,l_estab_accrual_rate_yq;
      	 hr_utility.set_location('Step ' || l_proc,80);
      	 --
      	 if csr_fetch_estab_process_rates%FOUND then
	    --
	    If p_process_type = 'NORMAL' then
	       hr_utility.set_location('Step ' || l_proc,90);
	       p_charges_percentage := l_estab_accrual_rate_normal;
	    elsif p_process_type = 'PART_TIME' then
	       hr_utility.set_location('Step ' || l_proc,100);
	       p_charges_percentage := l_estab_accrual_rate_part_time;
      	    elsif p_process_type = 'APPRENTICE' then
	       hr_utility.set_location('Step ' || l_proc,105);
	       p_charges_percentage := l_estab_accrual_rate_app;
      	    elsif p_process_type = 'ORIENT' then
	       hr_utility.set_location('Step ' || l_proc,106);
	       p_charges_percentage := l_estab_accrual_rate_ori;
      	    elsif p_process_type = 'YPQUAL' then
	       hr_utility.set_location('Step ' || l_proc,107);
	       p_charges_percentage := l_estab_accrual_rate_yq;
	    end if;
            --
      	  else
      	     p_charges_percentage := 0;
      	  end if;
      	  --
      	  close csr_fetch_estab_process_rates;
       end if;
       --
       close csr_fetch_comp_process_rates;

         --
	 If p_charges_percentage <> 0 then
	  p_charges_percentage := nvl(p_charges_percentage,0);
	  hr_utility.set_location('Step ' || l_proc,110);
	  return 1;
	 else
	  p_charges_percentage := nvl(p_charges_percentage,0);
	  hr_utility.set_location('Step ' || l_proc,120);
	  return 0;
	 end if;
	 --
   hr_utility.set_location('Leaving:  '||l_proc,130);
   --
end get_accrual_rate_percentage;
--
-------------------------------------------------------------------------------
-- GET_ACCOUNTING_DETAILS
-------------------------------------------------------------------------------
function Get_accounting_details
(P_ELEMENT_ENTRY_ID               IN Number
,P_PAYROLL_ID                     IN NUMBER
,P_ASSIGNMENT_ID                  IN NUMBER
-- added 2 new parameters and modified 1 parameter for termination
,P_ACCOUNTING_DATE                IN DATE            /* Replaced with new date parameter for termination*/
,p_accounting_plan_id            OUT NOCOPY Number   /* the accrual plan id*/
,p_accrual_start_month           OUT NOCOPY Number   /* the accrual plan's start month*/
--
,p_accounting_method             OUT NOCOPY Varchar2 /* the accrual plan's accounting method                     */
,p_y0_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y0_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y0_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
,p_y1_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y1_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y1_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
,p_y2_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y2_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y2_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
,p_y3_net_days                   OUT NOCOPY Number   /* the assignment's net days to pay for this year           */
,P_y3_ref_salary                 OUT NOCOPY Number   /* the assignment's reference salary for this year          */
,P_y3_ref_days                   OUT NOCOPY Number   /* the assignment's reference days accrued for this year    */
) return number is

CURSOR   csr_get_plan is
        select pap.accrual_plan_id
        from   pay_accrual_plans     pap
              ,pay_element_entries_f pee
              ,pay_element_links_f   pel
        where  pee.element_entry_id = P_ELEMENT_ENTRY_ID
          and  pee.element_link_id  = pel.element_link_id
          and  pel.element_type_id  = pap.accrual_plan_element_type_id;

l_accrual_plan_id         number;
l_total_accrued_pto       number;
l_total_accrued_protected number;
l_accrual_this            number;
l_ent_this                number;
l_unused_number           number;
l_unused_date             date;
l_paid_this               number;
l_fr_plan_info            g_fr_plan_info;
l_count_paid_days_upto    date;

l_proc VARCHAR2(72) :=    g_package||' get_accounting_details';

BEGIN
  hr_utility.set_location('Entering ' || l_proc,10);
  hr_utility.trace('p_element entry id ' || p_element_entry_id );
  hr_utility.trace('p_payroll_id ' || p_payroll_id );
  hr_utility.trace('p_assignment_id ' || p_assignment_id );
  hr_utility.trace('p_accounting_date ' || p_accounting_date );
  --
  -- Get the accrual plan
  --
  open csr_get_plan;
  fetch csr_get_plan into l_accrual_plan_id;
  close csr_get_plan;
  --
  -- Load the plan info
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_accrual_date             => P_ACCOUNTING_DATE);/* Replaced with new date parameter*/
  --
  -- record the date as at holiday must be taken before to reduce entitlement
  --
  l_count_paid_days_upto := P_ACCOUNTING_DATE;/* Replaced with new date parameter*/
  --
  -- Call this year and previous 3 years
  --
  hr_utility.set_location('Step ' || l_proc,50);
  --
  -- Call the accrual formula for this year, up to accounting_date. Do not deduct holiday taken
  -- from accrual. This may return zero if entitlement is stored past p_accounting_date - this
  -- will be picked up by entitlement
  --
  FR_Get_Accrual
     (P_Assignment_ID               => P_Assignment_ID
     ,P_Calculation_Date            => P_ACCOUNTING_DATE /* Replaced with new date parameter*/
     ,p_accrual_start_date          => l_fr_plan_info.accrual_year_start
     ,P_Plan_ID                     => l_fr_plan_info.accrual_plan_id
     ,P_Business_Group_ID           => l_fr_plan_info.business_Group_id
     ,P_Payroll_ID                  => P_PAYROLL_ID
     ,P_Assignment_Action_ID        => null
     ,P_Accrual_Latest_Balance      => null
     ,p_create_all                  => 'N' /* (do not create extra accrual types) */
     ,p_reprocess_whole_period      => 'N' /* (only run accrual from latest ent to p_accounting_date) */
     ,p_payslip_process             => 'Y' /* (indicates do not deduct hols taken from accrual - ent will show this) */
     ,P_Start_Date                  => l_unused_date
     ,P_End_Date                    => l_unused_date
     ,P_Accrual_End_Date            => l_unused_date
     ,P_total_accrued_pto           => l_total_accrued_pto
     ,P_total_Accrued_protected     => l_total_Accrued_protected
     ,P_total_Accrued_seniority     => l_unused_number
     ,P_total_Accrued_mothers       => l_unused_number
     ,P_total_Accrued_conventional  => l_unused_number ) ;

  hr_utility.set_location('Step ' || l_proc,60);

  l_accrual_this := nvl(l_total_accrued_pto,0) + nvl(l_total_Accrued_protected,0);
  hr_utility.set_location('l_accrual_this'||to_char(l_accrual_this),22);
  --
  -- Get the entitlement and net for this year. Only deduct holidays taken and paid
  -- (do not deduct all holidays booked, as the payslip must only show days taken to date )
  --
  hr_utility.set_location('Step ' || l_proc,60);
    get_fr_net_entitlement
     (p_accrual_plan_id                => l_fr_plan_info.accrual_plan_id
     ,p_effective_date                 => P_ACCOUNTING_DATE /* Replaced with new date parameter*/
     ,p_assignment_id                  => P_ASSIGNMENT_ID
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_unused_number
     ,p_net_main                       => l_paid_this  /* days paid as at (or after) the current accounting_date  */
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this     /* net entitlement, including days paid before p_accounting_date */
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'A'  /* Accrual type */
     ,p_paid_days_to                   => l_count_paid_days_upto);

  hr_utility.set_location('Step ' || l_proc,70);
  hr_utility.set_location('l_ent_this'||to_char(l_ent_this), 22);
  hr_utility.set_location('l_paid_this'||to_char(l_paid_this), 22);
  hr_utility.trace('net Y0 is ' || to_char(nvl(l_ent_this,0) - nvl(l_paid_this,0)));
  p_y0_net_days := l_accrual_this + nvl(l_ent_this,0) - nvl(l_paid_this,0);

  --
  -- Get the reference entitlement for this year
  --
  get_reference_entitlement(
    p_accrual_plan_id         => l_fr_plan_info.accrual_plan_id
   ,p_accrual_start_date      => l_fr_plan_info.accrual_year_start
   ,p_accrual_end_date        => l_fr_plan_info.accrual_year_end
   ,p_assignment_id           => P_ASSIGNMENT_ID
   ,p_ent_ref_days_id         => l_fr_plan_info.ent_reference_days_iv_id
   ,p_ent_ref_salary_id       => l_fr_plan_info.ent_reference_sal_iv_id
   ,p_ent_accrual_date_iv_id  => l_fr_plan_info.ent_accrual_date_iv_id
   ,p_ref_main_days           => P_y0_ref_days
   ,p_ref_salary              => P_y0_ref_salary);

  --
  -- Repeat for the previous year (n-1)
  --
  --
  -- Load the plan info for n-1
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_accrual_date             => add_months(P_ACCOUNTING_DATE, -12));/* Replaced with new date parameter*/

  hr_utility.set_location('Step ' || l_proc,160);

    get_fr_net_entitlement
     (p_accrual_plan_id                => l_fr_plan_info.accrual_plan_id
     ,p_effective_date                 => add_months(P_ACCOUNTING_DATE, -12) /* Replaced with new date parameter*/
     ,p_assignment_id                  => P_ASSIGNMENT_ID
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_unused_number
     ,p_net_main                       => l_paid_this  /* days paid as at (or after) the current accounting_date  */
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this     /* net entitlement, including days paid before p_accounting_date */
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'A'  /* Accrual type */
     ,p_paid_days_to                   => l_count_paid_days_upto);

  hr_utility.set_location('Step ' || l_proc,170);
  hr_utility.trace('net Y1 is ' || to_char(nvl(l_ent_this,0) - nvl(l_paid_this,0)));
  p_y1_net_days := nvl(l_ent_this,0) - nvl(l_paid_this,0);

  hr_utility.trace('p_y1_net_days  is ' || p_y1_net_days );
  --
  -- Get the reference entitlement for this year
  --
  get_reference_entitlement(
    p_accrual_plan_id         => l_fr_plan_info.accrual_plan_id
   ,p_accrual_start_date      => l_fr_plan_info.accrual_year_start
   ,p_accrual_end_date        => l_fr_plan_info.accrual_year_end
   ,p_assignment_id           => P_ASSIGNMENT_ID
   ,p_ent_ref_days_id         => l_fr_plan_info.ent_reference_days_iv_id
   ,p_ent_ref_salary_id       => l_fr_plan_info.ent_reference_sal_iv_id
   ,p_ent_accrual_date_iv_id  => l_fr_plan_info.ent_accrual_date_iv_id
   ,p_ref_main_days           => P_y1_ref_days
   ,p_ref_salary              => P_y1_ref_salary);

  --
  -- Repeat for the previous year (n-2)
  --
  --
  -- Load the plan info for n-2
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_accrual_date             => add_months(P_ACCOUNTING_DATE, -24));/* Replaced with new date parameter*/

  hr_utility.set_location('Step ' || l_proc,260);

    get_fr_net_entitlement
     (p_accrual_plan_id                => l_fr_plan_info.accrual_plan_id
     ,p_effective_date                 => add_months(P_ACCOUNTING_DATE, -24) /* Replaced with new date parameter*/
     ,p_assignment_id                  => P_ASSIGNMENT_ID
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_unused_number
     ,p_net_main                       => l_paid_this  /* days paid as at (or after) the current accounting_date  */
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this     /* net entitlement, including days paid before p_accounting_date */
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'A'  /* Accrual type */
     ,p_paid_days_to                   => l_count_paid_days_upto);

  hr_utility.set_location('Step ' || l_proc,270);
  hr_utility.trace('net Y2 is ' || to_char(nvl(l_ent_this,0) - nvl(l_paid_this,0)));
  p_y2_net_days := nvl(l_ent_this,0) - nvl(l_paid_this,0);

  hr_utility.trace('p_y2_net_days  is ' || p_y2_net_days );
  --
  -- Get the reference entitlement for this year
  --
  get_reference_entitlement(
    p_accrual_plan_id         => l_fr_plan_info.accrual_plan_id
   ,p_accrual_start_date      => l_fr_plan_info.accrual_year_start
   ,p_accrual_end_date        => l_fr_plan_info.accrual_year_end
   ,p_assignment_id           => P_ASSIGNMENT_ID
   ,p_ent_ref_days_id         => l_fr_plan_info.ent_reference_days_iv_id
   ,p_ent_ref_salary_id       => l_fr_plan_info.ent_reference_sal_iv_id
   ,p_ent_accrual_date_iv_id  => l_fr_plan_info.ent_accrual_date_iv_id
   ,p_ref_main_days           => P_y2_ref_days
   ,p_ref_salary              => P_y2_ref_salary);

  --
  -- Repeat for the previous year (n-3)
  --
  --
  -- Load the plan info for n-3
  --
  l_fr_plan_info := get_fr_accrual_plan_info(
     p_accrual_plan_id          => l_accrual_plan_id
    ,p_accrual_date             => add_months(P_ACCOUNTING_DATE, -36));/* Replaced with new date parameter*/

  hr_utility.set_location('Step ' || l_proc,360);

    get_fr_net_entitlement
     (p_accrual_plan_id                => l_fr_plan_info.accrual_plan_id
     ,p_effective_date                 => add_months(P_ACCOUNTING_DATE, -36) /* Replaced with new date parameter*/
     ,p_assignment_id                  => P_ASSIGNMENT_ID
     ,p_ignore_ent_adjustments         => 'N' /* (include obsoletions and adjustments in ent parameters) */
     ,p_remaining                      => l_unused_number
     ,p_net_main                       => l_paid_this  /* days paid as at (or after) the current accounting_date  */
     ,p_net_protected                  => l_unused_number
     ,p_net_young_mothers              => l_unused_number
     ,p_net_seniority                  => l_unused_number
     ,p_net_conventional               => l_unused_number
     ,p_ent_main                       => l_ent_this     /* net entitlement, including days paid before p_accounting_date */
     ,p_ent_protected                  => l_unused_number
     ,p_ent_young_mothers              => l_unused_number
     ,p_ent_seniority                  => l_unused_number
     ,p_ent_conventional               => l_unused_number
     ,p_accrual_start_date             => l_unused_date
     ,p_accrual_end_date               => l_unused_date
     ,p_type_calculation               => 'A'  /* Accrual type */
     ,p_paid_days_to                   => l_count_paid_days_upto);

  hr_utility.set_location('Step ' || l_proc,370);
  hr_utility.trace('net Y3 is ' || to_char(nvl(l_ent_this,0) - nvl(l_paid_this,0)));
  p_y3_net_days := nvl(l_ent_this,0) - nvl(l_paid_this,0);

  hr_utility.trace('p_y3_net_days  is ' || p_y3_net_days );
  --
  -- Get the reference entitlement for this year
  --
  get_reference_entitlement(
    p_accrual_plan_id         => l_fr_plan_info.accrual_plan_id
   ,p_accrual_start_date      => l_fr_plan_info.accrual_year_start
   ,p_accrual_end_date        => l_fr_plan_info.accrual_year_end
   ,p_assignment_id           => P_ASSIGNMENT_ID
   ,p_ent_ref_days_id         => l_fr_plan_info.ent_reference_days_iv_id
   ,p_ent_ref_salary_id       => l_fr_plan_info.ent_reference_sal_iv_id
   ,p_ent_accrual_date_iv_id  => l_fr_plan_info.ent_accrual_date_iv_id
   ,p_ref_main_days           => P_y3_ref_days
   ,p_ref_salary              => P_y3_ref_salary);
  --
  hr_utility.set_location('Leaving:  '||l_proc,360);
  --
  p_accounting_method             := l_fr_plan_info.accounting_method;
  -- added code for termination processing
  p_accounting_plan_id := l_fr_plan_info.accrual_plan_id;
  p_accrual_start_month := l_fr_plan_info.accrual_start_month ;
  --
  p_y0_net_days    := nvl(p_y0_net_days,0);
  P_y0_ref_salary  := nvl(P_y0_ref_salary,0);
  P_y0_ref_days    := nvl(P_y0_ref_days,0);

  p_y1_net_days    := nvl(p_y1_net_days  ,0);
  P_y1_ref_salary  := nvl(P_y1_ref_salary,0);
  P_y1_ref_days    := nvl(P_y1_ref_days  ,0);

  p_y2_net_days    := nvl(p_y2_net_days  ,0);
  P_y2_ref_salary  := nvl(P_y2_ref_salary,0);
  P_y2_ref_days    := nvl(P_y2_ref_days  ,0);

  p_y3_net_days    := nvl(p_y3_net_days  ,0);
  P_y3_ref_salary  := nvl(P_y3_ref_salary,0);
  P_y3_ref_days    := nvl(P_y3_ref_days  ,0);
--
hr_utility.trace('p_y0_net_days GAD is ' || p_y0_net_days);
hr_utility.trace('p_y1_net_days GAD is ' || p_y1_net_days);
hr_utility.trace('p_y2_net_days GAD is ' || p_y2_net_days);

return 1;
END Get_accounting_details;
--

Function write_termination_payment
(p_accrual_plan_id  number,
 p_y0_payment       number,
 p_y0_payment_days  number,
 p_y0_payment_rate  number,
 p_y0_accrual_year  date,
 p_y1_payment       number,
 p_y1_payment_days  number,
 p_y1_payment_rate  number,
 p_y1_accrual_year  date,
 p_y2_payment       number,
 p_y2_payment_days  number,
 p_y2_payment_rate  number,
 p_y2_accrual_year  date,
 p_y3_payment       number,
 p_y3_payment_days  number,
 p_y3_payment_rate  number,
 p_y3_accrual_year  date
) return number is

i number;
last_i number;

begin

  hr_utility.trace('plan _id = ' || p_accrual_plan_id);
  hr_utility.trace('y0_payment = ' || p_y0_payment);
  hr_utility.trace('y0_payment_days = ' || p_y0_payment_days);
  hr_utility.trace('y0_payment_rate = ' || p_y0_payment_rate);
  hr_utility.trace('y0_payment_year = ' || p_y0_accrual_year);

  hr_utility.trace('y1_payment = ' || p_y1_payment);
  hr_utility.trace('y1_payment_days = ' || p_y1_payment_days);
  hr_utility.trace('y1_payment_rate = ' || p_y1_payment_rate);
  hr_utility.trace('y1_payment_year = ' || p_y1_accrual_year);

  hr_utility.trace('y2_payment = ' || p_y2_payment);
  hr_utility.trace('y2_payment_days = ' || p_y2_payment_days);
  hr_utility.trace('y2_payment_rate = ' || p_y2_payment_rate);
  hr_utility.trace('y2_payment_year = ' || p_y2_accrual_year);

  hr_utility.trace('y3_payment = ' || p_y3_payment);
  hr_utility.trace('y3_payment_days = ' || p_y3_payment_days);
  hr_utility.trace('y3_payment_rate = ' || p_y3_payment_rate);
  hr_utility.trace('y3_payment_year = ' || p_y3_accrual_year);

  i := p_accrual_plan_id * 10;
  if p_y0_payment <> 0 and p_y0_payment is not null then
    i := i+1;
    term_payment(i).payment      := p_y0_payment;
    term_payment(i).days         := p_y0_payment_days;
    term_payment(i).daily_rate   := p_y0_payment_rate;
    term_payment(i).accrual_date := p_y0_accrual_year;
    term_payment(i).next_payment := 0;
    last_i := i;
  end if;

  if p_y1_payment <> 0 and p_y1_payment is not null then
    i := i+1;
    term_payment(i).payment      := p_y1_payment;
    term_payment(i).days         := p_y1_payment_days;
    term_payment(i).daily_rate   := p_y1_payment_rate;
    term_payment(i).accrual_date := p_y1_accrual_year;
    term_payment(i).next_payment := 0;

    if last_i is not null then
       term_payment(last_i).next_payment := i;
    end if;

    last_i := i;
  end if;

  if p_y2_payment <> 0 and p_y2_payment is not null then
    i := i+1;
    term_payment(i).payment      := p_y2_payment;
    term_payment(i).days         := p_y2_payment_days;
    term_payment(i).daily_rate   := p_y2_payment_rate;
    term_payment(i).accrual_date := p_y2_accrual_year;
    term_payment(i).next_payment := 0;

    if last_i is not null then
       term_payment(last_i).next_payment := i;
    end if;

    last_i := i;
  end if;

  if p_y3_payment <> 0 and p_y3_payment is not null then
    i := i+1;
    term_payment(i).payment      := p_y3_payment;
    term_payment(i).days         := p_y3_payment_days;
    term_payment(i).daily_rate   := p_y3_payment_rate;
    term_payment(i).accrual_date := p_y3_accrual_year;
    term_payment(i).next_payment := 0;

    if last_i is not null then
       term_payment(last_i).next_payment := i;
    end if;

    last_i := i;
  end if;

  return 0;

EXCEPTION
WHEN OTHERS THEN
   hr_utility.trace('write_termination_payment');
   hr_utility.trace(SQLCODE);
   hr_utility.trace(SQLERRM);
   Raise;

end write_termination_payment;

Function read_termination_payment
(p_accrual_plan_id IN NUMBER,
 p_index IN number,
 p_payment     OUT NOCOPY number,
 p_days        OUT NOCOPY number,
 p_daily_rate  OUT NOCOPY number,
 p_accrual_date OUT NOCOPY date,
 p_next_payment OUT NOCOPY number)
 return number is

l_index number;

begin
 hr_utility.trace('in read termination payment');
 hr_utility.trace('p_accrual_plan_id = ' || p_accrual_plan_id);
 hr_utility.trace('p_index = ' || p_index);

l_index := p_index;

 if p_index is null OR p_index = 0 Then
    l_index := p_accrual_plan_id * 10 + 1;
 end if;

 p_payment := term_payment(l_index).payment;
 p_daily_rate := term_payment(l_index).daily_rate;
 p_accrual_date := term_payment(l_index).accrual_date;
 p_next_payment := term_payment(l_index).next_payment;

 /* Bug 4538139 Obtains the next row */
 if p_next_payment is not null and p_next_payment <> 0 then
    p_days := term_payment(p_next_payment).days;
 end if;

 hr_utility.trace('p_payment = ' || p_payment);
 hr_utility.trace('p_days = ' || p_days);
 hr_utility.trace('p_daily_rate = ' || p_daily_rate);
 hr_utility.trace('p_accrual_date = ' || p_accrual_date);
 hr_utility.trace('p_next_payment = ' || p_next_payment);

 hr_utility.trace('left read termination payment');

 return 0;
EXCEPTION
WHEN OTHERS THEN
   hr_utility.trace('read_termination_payment');
   hr_utility.trace(SQLCODE);
   hr_utility.trace(SQLERRM);
   Raise;

end read_termination_payment;
--
-------------------------------------------------------------------------------
-- VALID_FIXED_TERM_CONTRACT_REF
-- Used by FR_FIXED_TERM_CONTRACT_INDEMNITY_REFERENCE Element Input Validation
-------------------------------------------------------------------------------
function Valid_Fixed_Term_Contract_Ref
(p_assignment_id                  in number
,p_date_earned                    in date
,p_reference                      in varchar2) return varchar2 is
--
  l_valid     varchar2(10);
  cursor csr_find_match is
  select  'TRUE'
  from    per_all_assignments_f   asg,
          per_contracts_f         pcf
  where   p_date_earned        >= asg.effective_start_date
    and   p_assignment_id       = asg.assignment_id
    and   asg.contract_id       = pcf.contract_id
    and   p_date_earned   between pcf.effective_start_date
                              and pcf.effective_end_date
    and   pcf.reference         = p_reference
    and   pcf.ctr_information2  = 'FIXED_TERM';
--
BEGIN
  open csr_find_match;
  fetch csr_find_match into l_valid;
  if csr_find_match%NOTFOUND then
    l_valid := 'FALSE';
  end if;
  close csr_find_match;
return l_valid;
END Valid_Fixed_Term_Contract_Ref;
--
-------------------------------------------------------------------------------
-- CONTRACT_ACTIVE_END_DATE
-- Used by FR_FIXED_TERM_CONTRACT_INDEMNITY formula
-------------------------------------------------------------------------------
function contract_active_end_date
  (p_assignment_id      in number
  ,p_date_earned        in date
  ,p_reference          in varchar2) /* entry ref input value */
return date is
  l_contract_id      per_contracts_f.contract_id%TYPE;
  l_contract_status  per_contracts_f.status%TYPE;
  --
  cursor csr_get_contract_details is
  select  pcf.contract_id, pcf.status
  from    per_all_assignments_f  asg,
          per_contracts_f        pcf
  where   p_assignment_id = asg.assignment_id
    and   asg.contract_id = pcf.contract_id
    and   p_date_earned  >= asg.effective_start_date
    and   p_date_earned between pcf.effective_start_date
                            and pcf.effective_end_date
    and   pcf.reference   = p_reference;
  --
BEGIN
  open csr_get_contract_details;
  fetch csr_get_contract_details into l_contract_id, l_contract_status;
  close csr_get_contract_details;
  if l_contract_id is null then
    fnd_message.set_name('PAY','PAY_75056_ACC_CTR_FT_BAD_REF');
    fnd_message.raise_error;
  end if;
  return nvl(hr_contract_api.get_active_end_date
               (l_contract_id, p_date_earned, l_contract_status),
             hr_general.end_of_time);
END contract_active_end_date;
--
-------------------------------------------------------------------------------
-- GET_FIXED_TERM_CTR_ENTRY_INFO
-- Used by FR_FIXED_TERM_CONTRACT_INDEMNITY formula
-------------------------------------------------------------------------------
function Get_Fixed_Term_Ctr_Entry_info
  (p_assignment_id      in number
  ,p_date_earned        in date
  ,p_reference          in varchar2 /* the ref of the entry value */
  ,p_deferred_payment  out nocopy varchar2 /* payment to be deferred? */
) return number
is
  l_value_defaulted number(1);
  cursor csr_find_entry is
  select 0, pev_def.screen_entry_value
  from   pay_element_entries_f      pee
        ,pay_element_entry_values_f pev_ref
        ,pay_input_values_f         piv_ref
        ,pay_element_types_f        pet
        ,pay_input_values_f         piv_def
        ,pay_element_entry_values_f pev_def
  where  pet.element_name           = 'FR_FIXED_TERM_CONTRACT_INDEMNITY'
    and  pet.legislation_code       = 'FR'
    and  pet.business_group_id     is null
    and  pet.element_type_id        = piv_ref.element_type_id
    and  piv_def.name               = 'Deferred Payment'
    and  piv_def.legislation_code   = 'FR'
    and  piv_def.business_group_id is null
    and  pev_def.input_value_id     = piv_def.input_Value_id
    and  pee.element_entry_id       = pev_def.element_entry_id
    and  pev_ref.screen_entry_value = p_reference
    and  piv_ref.name               = 'Contract Reference'
    and  piv_ref.legislation_code   = 'FR'
    and  piv_ref.business_group_id is null
    and  pev_ref.input_value_id     = piv_ref.input_Value_id
    and  pee.element_entry_id       = pev_ref.element_entry_id
    and  pee.assignment_id          = p_assignment_id
    and  p_date_earned between pev_def.effective_start_date
                           and pev_def.effective_end_date
    and  p_date_earned between piv_def.effective_start_date
                           and piv_def.effective_end_date
    and  p_date_earned between pev_ref.effective_start_date
                           and pev_ref.effective_end_date
    and  p_date_earned between piv_ref.effective_start_date
                           and piv_ref.effective_end_date
    and  p_date_earned between pet.effective_start_date
                           and pet.effective_end_date
    and  p_date_earned between pee.effective_start_date
                           and pee.effective_end_date;
BEGIN
  open csr_find_entry;
  fetch csr_find_entry into l_value_defaulted, p_deferred_payment;
  if csr_find_entry%NOTFOUND then
    p_deferred_payment := 'N';
    l_value_defaulted  := 1;
  end if;
  close csr_find_entry;
return l_value_defaulted;
END Get_Fixed_Term_Ctr_Entry_info;
--
--------------------------------------------------------------------
-- Function Check_fr_holidays_booked
-- Created for bug 2874154 - srjadhav
--------------------------------------------------------------------
function Check_fr_holidays_booked
(P_assignment_id                  IN Number   /* the assignment */
,P_accrual_plan_id                IN Number
,p_start_date                     IN Date
,p_end_date		          IN Date
) return number IS
l_accrual_plan_id                 Number := P_accrual_plan_id;
l_assignment_id 		  Number := P_assignment_id;
l_date_start			  Date := p_start_date;
l_date_end			  Date := p_end_date;
l_holiday_element_id                 Number;
l_unused_char                        Varchar2(30);
l_main_holidays                      Number;
l_unused_number                      Number;
l_unused_date		             Date;
--

CURSOR csr_booked_holiday_sickness (p_assignment_id in number
                          ,p_start_date Date, p_end_date Date) is
-- Added the following cursor for cheking whether the employee
-- has taken a sick leave between LDW and ATD.  Bug#2874154
       select 1
       from    per_absence_attendances paa
               ,pay_element_entries_f pee
               ,per_absence_attendance_types pat
       where  pee.creator_type = 'A'
              and paa.absence_attendance_id = pee.creator_id
            and fnd_date.date_to_canonical (paa.date_start) between fnd_date.date_to_canonical(p_start_date) and fnd_date.date_to_canonical(p_end_date)
              and pee.assignment_id = p_assignment_id
             and paa.absence_attendance_type_id = pat.absence_attendance_type_id
              and pat.absence_category = 'S';
--
--Changed the following cursor for bug#3030610.
CURSOR csr_booked_holiday (p_assignment_id in number, p_holiday_element_id in number
                          ,p_start_date Date, p_end_date Date) is
       select  NVL(sum(paa.abs_information2), -1)
       from    per_absence_attendances paa
              ,pay_element_entries_f pee
      where    pee.element_link_id in (select element_link_id
                                       from   pay_element_links_f
                                       where  element_type_id = p_holiday_Element_id
                                       )
        and   pee.creator_type = 'A'
        and   paa.absence_Attendance_id = pee.creator_id
        and   fnd_date.date_to_canonical(paa.date_start)  between fnd_date.date_to_canonical(p_start_date)
                                       and fnd_date.date_to_canonical(p_end_date)
        and  pee.assignment_id = p_assignment_id;

l_proc VARCHAR2(72) :=    g_package||' Check_fr_holidays_booked ';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,777);
  -- fetch variables for this accrual plan
  --
 OPEN csr_booked_holiday_sickness (l_assignment_id, l_date_start, l_date_end);
 FETCH csr_booked_holiday_sickness into l_unused_number;
-- Added the following IF statement to check whether any sick leave
-- has been taken or not
 IF  csr_booked_holiday_sickness%FOUND THEN
 	RETURN 1;
 ELSE

-- The following procedure is used to check whether the employee has taken
-- leave of any other categories

  get_accrual_plan_data(
      p_accrual_plan_id        => l_accrual_plan_id
     ,p_accrual_year_start     => l_unused_date
     ,p_accrual_year_end       => l_unused_date
     ,p_accounting_method      => l_unused_char
     ,p_entitlement_offset     => l_unused_number
     ,p_ent_ref_days_id        => l_unused_number
     ,p_ent_ref_salary_id      => l_unused_number
     ,p_ent_accrual_date_iv_id => l_unused_number
     ,p_holiday_element_id     => l_holiday_element_id);
  --
  -- Call sub procedure to calculate the totals
  --
  OPEN csr_booked_holiday (l_assignment_id, l_holiday_element_id, l_date_start, l_date_end);
  FETCH csr_booked_holiday into l_main_holidays;
  RETURN l_main_holidays;
 END IF;


close csr_booked_holiday;
close csr_booked_holiday_sickness;

END Check_fr_holidays_booked;
--

--
--------------------------------------------------------------------
-- Function Check_fr_consecutive_holidays_booked
-- Function will return 1 if successful otherwise
-- will return 0. Bug#3030610
--------------------------------------------------------------------
function Check_fr_cons_holidays_booked
        (P_assignment_id                  IN Number   /* the assignment */
        ,P_accrual_plan_id                IN Number
        ,p_start_date                     IN Date
        ,p_end_date                       IN Date
        ) return number IS
l_accrual_plan_id                 Number := P_accrual_plan_id;
l_assignment_id                   Number := P_assignment_id;
l_date_start                      Date := p_start_date;
l_date_end                        Date := p_end_date;
l_holiday_element_id              Number;
l_main_holidays			          Number;
l_accounting_method		          Varchar2(30);
l_unused_char                     Varchar2(30);
l_unused_number                   Number;
l_unused_date                     Date;
l_no_absences                     Number;
--

CURSOR csr_booked_holiday (p_assignment_id in number, p_holiday_element_id in number
                          ,p_start_date Date, p_end_date Date, p_no_absences in number) is
       select  1
       from    per_absence_attendances paa
              ,pay_element_entries_f pee
      where    pee.element_link_id in (select element_link_id
                                       from   pay_element_links_f
                                       where  element_type_id = p_holiday_element_id
                                       )
        and  pee.creator_type = 'A'
        and  paa.absence_Attendance_id = pee.creator_id
        and  fnd_date.date_to_canonical(paa.date_start) >= fnd_date.date_to_canonical(p_start_date)
        and  fnd_date.date_to_canonical(paa.date_end) <= fnd_date.date_to_canonical(p_end_date)
  	    and  paa.absence_days >= p_no_absences
        and  pee.assignment_id = p_assignment_id;



l_proc VARCHAR2(72) :=    g_package||' Check_fr_cons_holidays_booked';

l_found NUMBER := 0;
--
BEGIN
  --
  -- fetch variables for this accrual plan
  --
  hr_utility.set_location('Entering:'||l_proc,777);

  get_accrual_plan_data(
      p_accrual_plan_id        => l_accrual_plan_id
     ,p_accrual_year_start     => l_unused_date
     ,p_accrual_year_end       => l_unused_date
     ,p_accounting_method      => l_accounting_method
     ,p_entitlement_offset     => l_unused_number
     ,p_ent_ref_days_id        => l_unused_number
     ,p_ent_ref_salary_id      => l_unused_number
     ,p_ent_accrual_date_iv_id => l_unused_number
     ,p_holiday_element_id     => l_holiday_element_id);
  --
  -- Call sub procedure to calculate the totals
  --
 IF l_accounting_method ='FR_OPEN_DAYS' THEN
	l_no_absences := 12;
 ELSE /*** will be defaulted to 'FR_WORK_DAYS'**/
	l_no_absences := 10;
 END IF;
  hr_utility.set_location('Cursor Parameters:'||l_proc,780);
  hr_utility.set_location('l_assignment_id:'||l_proc,l_assignment_id);
  hr_utility.set_location('l_holiday_element_id:'||l_proc,l_holiday_element_id);
  hr_utility.set_location('l_date_start:'||l_date_start||':'||l_proc,1001);
  hr_utility.set_location('l_date_end:'||l_date_end||':'||l_proc,1002);
  hr_utility.set_location('l_no_absences:'||l_proc,l_no_absences);

 OPEN csr_booked_holiday (l_assignment_id
                        , l_holiday_element_id
                        , l_date_start
                        , l_date_end
                        , l_no_absences);
 FETCH csr_booked_holiday into l_main_holidays;

 IF  csr_booked_holiday%FOUND THEN
   l_found := 1;
 ELSE  --IF csr_booked_holiday%NOTFOUND THEN
   l_found := 0;
 END IF;

 CLOSE csr_booked_holiday;
 hr_utility.set_location('Returning :'||l_found||':'||l_proc,779);
 RETURN l_found;

END Check_fr_cons_holidays_booked;
--
----------------------------------------------------------------------------
-- Procedure get_fr_add_net_ent
-- called from HREMEA.pld to calculate net additional entitlement
---------------------------------------------------------------------------
PROCEDURE get_fr_add_net_ent(
          p_absence_attendance_type_id in  number,
          p_abs_date_start             in  date,
          p_abs_date_end               in date,
          p_person_id                  in  number,
          p_accrual_plan_id            in  number,
          p_total_ent                  out nocopy number,
          p_net_ent                    out nocopy number)
 IS
 -- Defining cursor to get existing entitlements
 cursor csr_get_ent(
                c_type_m_iv_id number
               ,c_start_date date
               ,c_end_date date) is
        select  nvl(sum(pevm.screen_entry_value),0)
        from    pay_element_entry_values_f pevm
               ,pay_element_entries_f      pee
               ,per_all_assignments_f      pasg
        where   pevm.input_value_id = c_type_m_iv_id
        and     pee.element_entry_id = pevm.element_entry_id
        and     pevm.effective_start_date between c_start_date and c_end_date
        and     pee.effective_start_date between c_start_date and c_end_date
        and     pee.assignment_id = pasg.assignment_id
        and     pasg.person_id = p_person_id;
 --
 -- Defining cursor selecting hiredate
 Cursor csr_assg_hiredate(c_person_id number) is
 Select max(ppos.date_start)
 From  per_periods_of_service ppos
 Where ppos.person_id = c_person_id
 and   ppos.date_start <= p_abs_date_start;

 --
 -- Cursor to sum up existing absences against entitled holidays
 Cursor csr_exist_abs(p_hire_date date) is
 Select sum(date_end-date_start+1)
 from per_absence_attendances
 where person_id = p_person_id
 and date_end <= p_abs_date_end
 and date_start >= p_hire_date
 and absence_attendance_type_id = p_absence_attendance_type_id;
 --
 l_fr_plan_info g_fr_plan_info;
 l_ent_m number :=0;
 l_hiredate date;
 l_exist_absence number;
 l_net_entitlement number;
 --
 --
 BEGIN
 --
   --
   l_fr_plan_info := get_fr_accrual_plan_info(
                      p_accrual_plan_id          => p_accrual_plan_id
                     ,p_accrual_date             => p_abs_date_start );
   -- Get the hire date
   -- to get the date range for checking absence
   open csr_assg_hiredate(p_person_id);
   fetch csr_assg_hiredate into l_hiredate;
   close csr_assg_hiredate;
   -- Calculate the sum of total entitlements created for this accrual plan
   -- within the hire date and absence start date
  hr_utility.set_location('l_fr_plan_info.ent_m_iv_id is : '||to_char(l_fr_plan_info.ent_m_iv_id), 22);
  hr_utility.set_location('l_hiredate is: '||to_char(l_hiredate), 22);
  hr_utility.set_location('p_abs_date_start is: '||to_char(p_abs_date_start),22);
  open csr_get_ent(l_fr_plan_info.ent_m_iv_id,
                       l_hiredate,
                       p_abs_date_start);
  fetch csr_get_ent into l_ent_m;
  close csr_get_ent;
  hr_utility.set_location('total entitlements are :'||l_ent_m, 22);
  -- Check for sum of existing absences against additional entitlements
  open csr_exist_abs(l_hiredate);
  fetch csr_exist_abs into l_exist_absence;
  close csr_exist_abs;
  IF l_exist_absence IS NULL THEN
     l_exist_absence := 0;
  END IF;
  hr_utility.set_location('Total absences are : '||l_exist_absence, 22);
  --
  l_net_entitlement := l_ent_m - l_exist_absence;
  hr_utility.set_location('Net entitlements are : '||l_net_entitlement, 22);
  -- Assign OUT parameters
  p_total_ent := l_ent_m;
  p_net_ent := l_net_entitlement;
  --
END get_fr_add_net_ent;
--
function get_contr_dates(p_assignment_id in number,
                         p_calculation_start_date in date,
                         p_contract_start_date  out nocopy date,
                         p_contract_end_date out nocopy date,
                         p_contract_category out nocopy varchar2)
return number is

 cursor csr_min_effect_start_date(c_assignment_id per_all_assignments_f.assignment_id%type) is
    select min(effective_start_date)as min_effective_start_date
    from per_all_assignments_f
    where assignment_id=c_assignment_id;

 cursor csr_fnd_contract_id(c_assignment_id per_all_assignments_f.assignment_id%type,
                            c_min_effective_start_date per_all_assignments_f.effective_start_date%TYPE) is
     select contract_id,effective_end_date,effective_start_date
     from per_all_assignments_f
     where c_min_effective_start_date between effective_start_date and effective_end_date
     and   assignment_id=c_assignment_id ;

  -- Added new cursors for bugs 4099667 and 4103779.
  -- Modified cursor to find contract category
  cursor csr_contr_change_catg(c_contract_id per_all_assignments_f.contract_id%TYPE) is
      select effective_start_date, ctr_information2 con_catg
      from per_contracts_f
      where contract_id=c_contract_id
      and ctr_information_category = 'FR';

   cursor csr_contr_max_end(c_contract_id per_all_assignments_f.contract_id%TYPE) is
        select max(effective_end_date)
        from per_contracts_f contr
      where contract_id=c_contract_id;

  l_csr_min_effect_start_date  csr_min_effect_start_date%rowtype;
  l_csr_fnd_contract_id   csr_fnd_contract_id%rowtype;
  l_con_start_date date;
  l_con_end_date date;
  l_con_category varchar2(50);
  l_min_effective_start_date per_all_assignments_f.effective_start_date%TYPE;
  l_loop_count number;


 begin

 open csr_min_effect_start_date(p_assignment_id);
 fetch csr_min_effect_start_date into l_csr_min_effect_start_date;
 close csr_min_effect_start_date;


 if  l_csr_min_effect_start_date.min_effective_start_date < p_calculation_start_date then
  l_min_effective_start_date:=p_calculation_start_date;
 else
  l_min_effective_start_date:=l_csr_min_effect_start_date.min_effective_start_date;
 end if;

open csr_fnd_contract_id(p_assignment_id,l_min_effective_start_date);
fetch csr_fnd_contract_id into l_csr_fnd_contract_id;
close csr_fnd_contract_id;

if(l_csr_fnd_contract_id.contract_id is null)
then
   p_contract_start_date:=l_csr_fnd_contract_id.effective_start_date;
   p_contract_end_date:=l_csr_fnd_contract_id.effective_end_date;

else
   --
   l_loop_count :=0;
   for c_contr_chg_catg in csr_contr_change_catg(l_csr_fnd_contract_id.contract_id) loop
      l_loop_count := l_loop_count +1;
      if l_loop_count = 1 then
         l_con_start_date := c_contr_chg_catg.effective_start_date;
         if c_contr_chg_catg.con_catg = 'PERMANENT' then
           l_con_category := c_contr_chg_catg.con_catg;
           exit;
         end if;
      else
         -- compare the previous and present categories
         if c_contr_chg_catg.con_catg <> l_con_category then
            -- note the start dates
            if months_between(c_contr_chg_catg.effective_start_date,l_con_start_date)<4 then
               l_con_category := c_contr_chg_catg.con_catg;
            end if;
            exit;
         end if;
      end if;
      l_con_category := c_contr_chg_catg.con_catg;
   end loop;
   --
   open csr_contr_max_end(l_csr_fnd_contract_id.contract_id);
   fetch csr_contr_max_end into l_con_end_date;
   close csr_contr_max_end;
   --
   p_contract_start_date:=l_con_start_date;
   p_contract_end_date:=l_con_end_date;
   p_contract_category := l_con_category;
   --
end if;
--
IF(p_contract_start_date IS NULL) THEN
     select min(effective_end_date),min(effective_start_date) INTO p_contract_end_date,p_contract_start_date
     from per_all_assignments_f paf
     where paf.assignment_id=assignment_id ;
  RETURN 1;
END IF;
return 0;

end get_contr_dates;
--
------------------------------------------------------------
 -- Function called from the DIF sub accrual formula
 -- to get the working time values.
 -- Added for bugs 4099667 and 4103779.
 ------------------------------------------------------------
 function get_time_values(p_business_group_id in number,
                          p_assignment_id in number,
                          p_effective_date in date,
                          p_working_hours out nocopy number,
                          p_working_frequency out nocopy varchar2,
                          p_cipdz_catg out nocopy varchar2) return number
 is
 --
 l_working_hours number;
 l_working_frequency varchar2(3);
 l_cipdz_catg varchar2(3);
--
 Cursor csr_get_time_catg is
 Select decode(con.ctr_information12,'HOUR', con.ctr_information13, asg.frequency) frequency,
        decode(con.ctr_information12,'HOUR', fnd_number.canonical_to_number(con.ctr_information11), asg.normal_hours) hours,
        substr(hruserdt.get_table_value(p_business_group_id, 'FR_CIPDZ', 'CIPDZ',nvl(asg.employment_category,'FR'),p_effective_date),1,1) cipdz_catg
 from per_all_assignments_f asg,
      per_contracts_f con
 where asg.assignment_id = p_assignment_id
 and asg.business_group_id = p_business_group_id
 and p_effective_date between
     asg.effective_start_date and asg.effective_end_date
 and asg.contract_id = con.contract_id
 and con.business_group_id = p_business_group_id
 and p_effective_date between
     con.effective_start_date and con.effective_end_date;
 --
 begin
 --
 OPEN csr_get_time_catg;
 FETCH csr_get_time_catg INTO l_working_frequency,l_working_hours, l_cipdz_catg;
 CLOSE csr_get_time_catg;
 --
 p_working_frequency := l_working_frequency;
 p_working_hours := l_working_hours;
 p_cipdz_catg := l_cipdz_catg;
 --
 return 1;
 end get_time_values;
----
end pay_fr_pto_pkg;

/
