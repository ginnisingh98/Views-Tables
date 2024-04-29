--------------------------------------------------------
--  DDL for Package Body HR_NZ_HOLIDAYS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_HOLIDAYS" AS
  --  $Header: hrnzhol.pkb 120.1 2005/09/01 21:44:11 snekkala noship $
  --
  --  Copyright (C) 1999 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create NZ HRMS hr_nz_holidays package
  --
  --  Change List
  --  ===========
  --
  --  Date        Author      Reference Descripti_n
  --  -----------+-----------+---------+---------------------------------------
  --  03 Feb 2003 sclarke     3417767   c_get_adjustments in get_adjustment_values
  --                                    now returns adjustment entries who have
  --                                    effective_start_date outside accrual period
  --  22 Dec 2003 sclarke     3064179   Backed out change on 01-NOV, now just
  --                                    provided comments.
  --  01 Nov 2003 sclarke     3064179   Changed get_net_entitlement to point to
  --                                    new package pay_nz_holidays.
  --                                    NULLED out redundant procedures.
  --  15 May 2003 puchil      2950172   Changed function annual_leave_eoy_adjustment
  --                                    to return negative EOY Adjustment value.
  --  14 May 2003 puchil      2798048   Changed variable name from l_element_id to
  --                                    l_pleave_taken in function get_parental_leaves_taken
  --  06 May 2003 puchil      2798048   Changed function annual_leave_entitled_to_pay
  --                                    to include parental leave logic
  --  13 Mar 2003 vgsriniv    2264070   Added the function check_retro_eoy
  --  03 Dec 2002 srrajago    2689221   Included 'nocopy' option for the 'out' and
  --                                    'in out' parameters of all the
  --                                    procedures and functions.
  --  19 Nov 2002 kaverma     2581490   Modified cursor get_pay_period_start_date
  --                                    and retro_start_date function
  --  24 Jun 2002 vgsriniv    2366349   Added function get_adjustment_values to
  --                                    handle Adjustment Elements for Accrual and
  --                                    Entitlement.Also modified the relevant
  --                                    functions to calculate Accrual and Entitlement
  --  21 Mar 2002 vgsriniv    2264070   Added  functions to handle leaves
  --                                    retroed after EOY period and modified
  --                                    cursor get_pay_period_start_date in the
  --                                    function annual_leave_entitled_to_pay
  --  05-Mar-2002 vgsriniv    2230110   Added a check for Anniversary date between
  --                                    the pay period in function annual_leave
  --                                    entitled to pay
  --  29 Jan 2002 vgsriniv    2185116   Removed the check for Termination type
  --  24-Jan-2002 vgsriniv    2185116   Added two extra parameters to function
  --                                    annual_leave_entitled_to_pay
  --  17-JAN-2002 vgsriniv    2183135   Added function get_acp_start_date to
  --                                    get the enrollment start date
  --  05-DEC-2001 vgsriniv    2127114   Added a function get_leap_year_mon and used
  --                                    it in accrual_daily_basis function to adjust
  --                                    for extra day in leap year
  --   19-NOV-2001 vgsriniv   2097319   changed the cursor c_leave_in_advance
  --                    Added OR clause to handle payrolls with offsets
  --   19-NOV-2001 hnainani   2115332   Added a round and NVL statement to the
  --                                    l_hours_left_to_pay calculation
  --  12 NOV 2001 vgsriniv    2097319   Changed the join in the cursor
  --                                    c_leave_in_advance
  --  06-NOV-2001 shoskatt    2090809   Changed the parameter to calculation date
  --                                    for  hr_nzbal.calc_asg_hol_ytd_date, which
  --                                    is called from annual_leave_entitled_to_pay
  --                                    function
  --  10-OCT-2001 rbsinha     2077370   modified annual_leave_net entitlement to
  --                                    call get_accrual_entitlement
  --  31-JUL 2001 rbsinha     1422001   added function average_accrual_rate
  --  12 Jul 2001 Apunekar    1872465  Fixed for getting correct value of entitlement
  --                                   and accrual in case of absences
  --  07 Jun 2000 SClarke     1323998   extra day accrual fixed
  --  07 Jun 2000 SClarke     1323990   Changes for display of entitlement +
  --                                    accrual on forms
  --  21 Mar 2000 JTurner     1243407   Updated calls to asg_working_hours to
  --                                    cater for mid period terminations
  --  14 Feb 2000 JTurner     1189790   Fixed problem with selection of
  --                                    accrual bands
  --  27 Jan 2000 JTurner     1098494   Changes num_weeks_for_avg_earnings to
  --                                    absence dev desc flex number of
  --                                    complete weeks segment instead of
  --                                    absence entry input value
  --  27 Jan 2000 JTurner     1098494   Changed get_accrual_plan_by_category
  --                                    to use code rather than meaning
  --  26 Jan 2000 JTurner     1098494   Modified annual_leave_eoy_adjustment
  --                                    function to cater for no carryover
  --  25 Jan 2000 JTurner     1098494   Modified annual_leave_entitled_to_pay
  --                                    function to cater for no carryover
  --  17 Jan 2000 JTURNER     1098494   Modified annual_leave_net_entitlement
  --                                    fn to cater for no carryover
  --  17 Jan 2000 JTURNER     1098494   Added accrual_daily_basis
  --                                    function.
  --  14 Jan 2000 JTURNER     1098494   Added accrual_period_basis
  --                                    function.
  --  11 Jan 2000 J Turner              Moved Header symbol to 2nd line for
  --                                    standards compliance
  --  29 Sep 1999 S.Clarke    110.6     Bug fix from QA testing to EOY
  --                                    adjustment
  --  28 Sep 1999 P.Macdonald 110.5     Bug 1007736 -
  --                                    annual_leave_net_entitlement
  --  23 Aug 1999 P.Macdonald 110.4     Fix syntax error
  --  13 Aug 1999 P.Macdonald 110.3     Add new functions
  --  30 Jul 1999 J Turner    110.2     Added get_net_accrual fn
  --  30 Jul 1999 J Turner    110.1     Completed development of
  --                                    get_accrual_plan_by_category fn
  --  25 Jul 1999 P Macdonald 110.0     Created
  --  30 Oct 2001 VGSRINIV    2072748   Function accrual_daily_basis modified to
  --                                    increment the accrual band on the continous
  --                                    service date or the Hire date
  -- 01 Nov 2001 VGSRINIV     2072748   Modified  accrual_daily_basis function
  --                                    to validate years of service
  -- 02 Nov 2001 VGSRINIV     2033033   Modified accrual_daily_basis to get the
  --                                    correct annual leave accrual when
  --                                    assignment working hours change
  -- 05 Nov 2001 VGSRINIV     2033033   Modified accrual_daily basis to get
  --                                    accruals when assignment working hours
  --                                    change more then once
  -- 10 Oct 2002 PUCHIL       2595888   Changed line 3460 from varchar2(1) to
  --                                    pay_payroll_actions.action_type%type
  -- 01 Aug 2005 SNEKKALA     4259438   Modified Cursor c_get_curr_action_type
  --                                    as part of performance fix
-----------------------------------------------------------------------------
  --  private global declarations
  -----------------------------------------------------------------------------

  --  Define a record and PL/SQL table to hold accrual band information.
  --  Used by accrual_period_basis and ann_leave_accrual_daily_basis
  --  functions.

  type t_accrual_band_rec is record
  (lower_limit                      pay_accrual_bands.lower_limit%type
  ,upper_limit                      pay_accrual_bands.upper_limit%type
  ,annual_rate                      pay_accrual_bands.annual_rate%type) ;

  type t_accrual_band_tab
    is table of t_accrual_band_rec
    index by binary_integer ;

  --  Define a record and PL/SQL table to hold assignment work day data.
  --  Used by accrual_period_basis and ann_leave_accrual_daily_basis
  --  functions.

  type t_asg_work_day_info_rec is record
  (effective_start_date             per_all_assignments_f.effective_start_date%type
  ,effective_end_date               per_all_assignments_f.effective_end_date%type
  ,normal_hours                     per_all_assignments_f.normal_hours%type
  ,frequency                        per_all_assignments_f.frequency%type) ;

  type t_asg_work_day_info_tab
    is table of t_asg_work_day_info_rec
    index by binary_integer ;

 --* Bug# 2183135 Function to get Accrual Plan Enrollment Start date

   FUNCTION get_acp_start_date
   (p_assignment_id   NUMBER
   ,p_plan_id         NUMBER
   ,p_effective_date  DATE) RETURN DATE IS

 l_effective_date DATE;

 CURSOR csr_acp_start_date(p_assignment_id  IN NUMBER
   ,p_plan_id        IN NUMBER
   ,p_effective_date IN DATE) IS
  SELECT LEAST(PEE.EFFECTIVE_START_DATE)
  FROM   pay_element_entries_f pee,
         pay_element_links_f pel,
         pay_element_types_f pet,
         pay_accrual_plans pap
  where  pee.element_link_id = pel.element_link_id
  and    pel.element_type_id = pet.element_type_id
  and    pet.element_type_id = pap.accrual_plan_element_type_id
  and    pee.entry_type ='E'
  and    pee.assignment_id = p_assignment_id
  and    pap.accrual_plan_id = p_plan_id
  and    p_effective_date between pee.effective_start_date
              and     pee.effective_end_date
  and    p_effective_date between pel.effective_start_date
              and     pel.effective_end_date
  and    p_effective_date between pet.effective_start_date
              and     pet.effective_end_date;


  BEGIN
    OPEN csr_acp_start_date(p_assignment_id, p_plan_id,                             p_effective_date);
    FETCH csr_acp_start_date into l_effective_date;
    CLOSE csr_acp_start_date;

    RETURN l_effective_date;

   END get_acp_start_date;







  /*---------------------------------------------------------------------
    Name    : get_accrual_plan_by_category
    Purpose : To retrieve accrual plan id for designated category
    Returns : accrual_plan_id if successful, null otherwise
    ---------------------------------------------------------------------*/

  FUNCTION get_accrual_plan_by_category
    (p_assignment_id    IN    NUMBER
    ,p_effective_date   IN    DATE
    ,p_plan_category    IN    VARCHAR2) RETURN NUMBER IS

    l_proc                 VARCHAR2(72) := g_package||'get_accrual_plan_by_category' ;
    l_accrual_plan_id      NUMBER ;
    l_dummy                NUMBER ;

  CURSOR csr_get_accrual_plan_id(p_assignment_id    NUMBER
                                ,p_effective_date   DATE
                                ,p_plan_category    VARCHAR2) IS
    SELECT pap.accrual_plan_id
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
    hr_utility.trace('In: ' || l_proc) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_effective_date: ' || to_char(p_effective_date,'dd Mon yyyy')) ;
    hr_utility.trace('  p_plan_category: ' || p_plan_category) ;

    OPEN csr_get_accrual_plan_id(p_assignment_id, p_effective_date, p_plan_category) ;

    FETCH csr_get_accrual_plan_id INTO l_accrual_plan_id;

    IF csr_get_accrual_plan_id%NOTFOUND
    THEN
      CLOSE csr_get_accrual_plan_id;
      hr_utility.trace('Crash Out: ' || l_proc) ;
      hr_utility.set_message(801, 'HR_NZ_ACCRUAL_PLAN_NOT_FOUND');
      hr_utility.raise_error;
    end if ;

    FETCH csr_get_accrual_plan_id INTO l_dummy ;

    IF csr_get_accrual_plan_id%FOUND
    THEN
      CLOSE csr_get_accrual_plan_id;
      hr_utility.trace('Crash Out: ' || l_proc) ;
      hr_utility.set_message(801, 'HR_NZ_TOO_MANY_ACCRUAL_PLANS');
      hr_utility.raise_error;
    END IF;

    CLOSE csr_get_accrual_plan_id;

    hr_utility.trace('  return: ' || to_char(l_accrual_plan_id)) ;
    hr_utility.trace('Out: ' || l_proc) ;
    RETURN l_accrual_plan_id;

  END get_accrual_plan_by_category;

  --
  --  get_net_accrual
  --
  --  This function is a wrapper for the
  --  per_accrual_calc_functions.get_net_accrual procedure.  The
  --  wrapper is required so that a FastFormula function can be
  --  registered for use in formulas.
  --

  FUNCTION get_net_accrual
    (p_assignment_id        IN    NUMBER
    ,p_payroll_id           IN    NUMBER
    ,p_business_group_id    IN    NUMBER
    ,p_plan_id              IN    NUMBER
    ,p_calculation_date     IN    DATE)
  RETURN NUMBER IS

    l_proc              VARCHAR2(72) := g_package||'get_net_accrual';
    l_assignment_id       NUMBER ;
    l_plan_id             NUMBER ;
    l_payroll_id          NUMBER ;
    l_business_group_id   NUMBER ;
    l_calculation_date    DATE ;
    l_start_date          DATE ;
    l_end_date            DATE ;
    l_accrual_end_date    DATE ;
    l_accrual             NUMBER ;
    l_net_entitlement     NUMBER ;

    l_adjustment_element   VARCHAR2(100);
    l_accrual_adj  NUMBER;
    l_entitlement_adj NUMBER;

    BEGIN

      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_plan_id: ' || to_char(p_plan_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

        l_assignment_id         := p_assignment_id ;
        l_plan_id               := p_plan_id ;
        l_payroll_id            := p_payroll_id ;
        l_business_group_id     := p_business_group_id ;
        l_calculation_date      := p_calculation_date ;
        l_start_date            := NULL ;
        l_end_date              := NULL ;
        l_accrual_end_date      := NULL ;
        l_accrual               := NULL ;
        l_net_entitlement       := NULL ;

        per_accrual_calc_functions.get_net_accrual
        (p_assignment_id    => l_assignment_id
        ,p_plan_id          => l_plan_id
        ,p_payroll_id       => l_payroll_id
        ,p_business_group_id => l_business_group_id
        ,p_calculation_date => l_calculation_date
        ,p_start_date       => l_start_date
        ,p_end_date         => l_end_date
        ,p_accrual_end_date => l_accrual_end_date
        ,p_accrual          => l_accrual
        ,p_net_entitlement  => l_net_entitlement) ;

--  venkat ---
/* Bug 2366349 Adjustment values are added to the accruals to display the annual leave
   balance in the SOE  */

         l_adjustment_element:= 'Entitlement Adjustment Element';
         l_entitlement_adj:= (get_adjustment_values(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date));


         hr_utility.trace('ven_others_ent= '||to_char(l_entitlement_adj));

         l_adjustment_element := 'Accrual Adjustment Element';
         l_accrual_adj:= (get_adjustment_values(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date));


      hr_utility.trace('ven_others_acc= '||to_char(l_accrual_adj));


--  venkat ---


       l_net_entitlement := l_net_entitlement + l_entitlement_adj + l_accrual_adj;

        hr_utility.trace('  return: ' || to_char(l_net_entitlement)) ;
        hr_utility.trace('Out: ' || l_proc) ;
        RETURN l_net_entitlement ;

  END get_net_accrual ;

  --------------------------------------------------------------
  --  ====================================
  --  3064179
  --  This function becomes on 01-APR-2004
  --  ====================================

  --  get_accrual_entitlement
  --
  --  This function is required mainly by the NZ local library
  --  and will return the net accrual and net entitlement for a
  --  given person on a given day.
  --
  --  These values will be displayed in the forms PAYWSACV and
  --  PAYWSEAD.
  --
  --------------------------------------------------------------

  FUNCTION get_accrual_entitlement
    (p_assignment_id        IN    NUMBER
    ,p_payroll_id           IN    NUMBER
    ,p_business_group_id    IN    NUMBER
    ,p_plan_id              IN    NUMBER
    ,p_calculation_date     IN    DATE
    ,p_net_accrual          OUT NOCOPY NUMBER
    ,p_net_entitlement      OUT NOCOPY NUMBER
    ,p_calc_start_date      OUT NOCOPY DATE
    ,p_last_accrual         OUT NOCOPY DATE
    ,p_next_period_end      OUT NOCOPY DATE)
  RETURN NUMBER IS
    --
    l_proc                          varchar2(72) := g_package||'.get_accrual_entitlement';
    l_start_date                    date ;
    l_end_date                      date ;
    l_accrual_end_date              date ;
    l_entitlement_end_date          date ;
    l_net_accrual                   number ;
    l_net_entitlement               number ;
    l_co_formula_id                 number ;
    l_max_co                        number ;
    l_accrual                       number ;
    l_accrual_absences              number ;
    l_leave_accrual_amount          number;
    l_leave_total_amount            number;
    l_leave_entitlement_amount      number;
    l_expiry_date                   date;
    l_last_anniversary_date         date;
    l_first_anniversary_date        date;
    l_continuous_service_date       date;
    l_temp                          number;
    l_others_entitlement_amount      number;
    l_others_accrual_amount         number;
    l_assignment_id                     number;
    l_plan_id                               number;
    l_calculation_date                  date;

  --------------------------------------
     --  Bug No : 2366349 Start
     --------------------------------------

     l_adjustment_element  VARCHAR2(100);
     l_accrual_adj         NUMBER ;
     l_entitlement_adj     NUMBER;
     l_accrual_ent         NUMBER;
    --------------------------------------
    -- Bug No : 2366349 End
    --------------------------------------

    --
    cursor c_get_co_formula (v_accrual_plan_id number) is
      select  co_formula_id
      from    pay_accrual_plans
      where   accrual_plan_id = v_accrual_plan_id;
    --
  BEGIN
    --
    hr_utility.set_location('Entering: '||l_proc,10) ;
    --

     l_assignment_id := p_assignment_id;
     l_plan_id           := p_plan_id;
     l_calculation_date := p_calculation_date;

    --  Step 1 Find entitlement end date
    --  first get the carryover formula then call it
    --  to get the prev and next anniversary dates.
    --  Entitlement end date and accrual end dates are
    --  actually the day before the anniversary dates.
    --
null;
    open  c_get_co_formula (p_plan_id);
    fetch c_get_co_formula into l_co_formula_id;
    close c_get_co_formula;
    --
    per_accrual_calc_functions.get_carry_over_values
    (p_co_formula_id      =>   l_co_formula_id
    ,p_assignment_id      =>   p_assignment_id
    ,p_accrual_plan_id    =>   p_plan_id
    ,p_business_group_id  =>   p_business_group_id
    ,p_payroll_id         =>   p_payroll_id
    ,p_calculation_date   =>   p_calculation_date
    ,p_session_date       =>   p_calculation_date
    ,p_accrual_term       =>   'NZ_FORM'
    ,p_effective_date     =>   l_entitlement_end_date
    ,p_expiry_date        =>   l_expiry_date
    ,p_max_carry_over     =>   l_max_co
    );
    --
    l_last_anniversary_date := get_last_anniversary
    (p_assignment_id        => p_assignment_id
    ,p_business_group_id    => p_business_group_id
    ,p_calculation_date     => p_calculation_date
    );
    --

    l_continuous_service_date := get_continuous_service_date
    (p_assignment_id        => p_assignment_id
    ,p_business_group_id    => p_business_group_id
    ,p_accrual_plan_id      => p_plan_id
    ,p_calculation_date     => p_calculation_date
    );
    --
    hr_utility.set_location(l_proc,30) ;
    hr_utility.trace('l_entitlement_end_date            = '||to_char(l_entitlement_end_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_expiry_date                     = '||to_char(l_expiry_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_max_co                          = '||to_char(l_max_co));
    --
    -- ============================
    -- ENTITLEMENT PORTION OF LEAVE
    -- ============================
    --
    -- Get the amount of leave which goes toward ENTITLEMENT
    -- Sum from start of plan until last anniversary
    --
    -- l_net_accrual is not used because the net calculation
    -- of leave is done manually to allow for absences to be taken
    -- from entitlement before accrual
    --
    Begin
    per_accrual_calc_functions.get_net_accrual
    (p_assignment_id      =>   p_assignment_id
    ,p_plan_id            =>   p_plan_id
    ,p_payroll_id         =>   p_payroll_id
    ,p_business_group_id  =>   p_business_group_id
    ,p_calculation_date   =>   l_entitlement_end_date
    ,p_start_date         =>   l_start_date
    ,p_end_date           =>   l_end_date
    ,p_accrual_end_date   =>   l_accrual_end_date
    ,p_accrual            =>   l_accrual
    ,p_net_entitlement    =>   l_net_accrual
    );
  Exception
    when Others Then
       NULL;
   End;
    --
    -- If in the first year then if the entitlement end date
    -- is equal to the start date then the entitlement amount = 0
    --
    if l_continuous_service_date = l_last_anniversary_date
    then
      if l_last_anniversary_date <= l_entitlement_end_date
      then
        l_leave_entitlement_amount := 0;
      else
        l_leave_entitlement_amount := l_accrual;
      end if;
    else
      if l_continuous_service_date > l_entitlement_end_date
      then
        l_leave_entitlement_amount := 0;
      else
        l_leave_entitlement_amount := l_accrual;
      end if;
    end if;
    --
    hr_utility.set_location(l_proc,40);
    hr_utility.trace('l_entitlement_end_date            = '||to_char(l_entitlement_end_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_start_date                      = '||to_char(l_start_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_end_date                        = '||to_char(l_end_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_accrual_end_date                = '||to_char(l_accrual_end_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_leave_entitlement_amount        = '||to_char(l_leave_entitlement_amount));

  --------------------------------------
  --**Bug No : 2366349  Value of Adjustment element for Entitlement is calculated to add
  --**  to the entitlements
         --------------------------------------


         l_adjustment_element:= 'Entitlement Adjustment Element';
         l_entitlement_adj:= (get_adjustment_values(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date)
                      );

        hr_utility.trace('ven_others_ent= '||to_char(l_entitlement_adj));

      --------------------------------------
         --    Bug No : 2366349 End
         --------------------------------------


    --
    l_others_entitlement_amount := per_accrual_calc_functions.get_other_net_contribution (p_assignment_id     => p_assignment_id
               ,p_plan_id           => p_plan_id
               ,p_start_date        => l_start_date
               ,p_calculation_date  => l_entitlement_end_date - 1 ) ;

   -- Add other contibutions from adjustment element before anniversary date
   -- to entitlement
--   l_leave_entitlement_amount := l_leave_entitlement_amount +
--l_others_entitlement_amount;

    -- Get the amount of Leave which makes up the TOTAL ( ENTITLEMENT + ACCRUAL )
    --
    -- =========================
    -- ACCRUAL PORTION OF LEAVE
    -- =========================
    --
    -- This is calculated by getting the total amount of leave
    -- accrued from start until the calculation date given.
    -- The Accrual portion will then be: (total - entitlement portion)
    -- Absences must then be subtracted to obtain the net figure
    -- Absences are subtracted from the entitlement portion first
    --
    -- l_net_accrual is not used because the net calculation
    -- of leave is done manually to allow for absences to be taken
    -- from entitlement before accrual
    --
   begin
    per_accrual_calc_functions.get_net_accrual
    (p_assignment_id      =>   p_assignment_id
    ,p_plan_id            =>   p_plan_id
    ,p_payroll_id         =>   p_payroll_id
    ,p_business_group_id  =>   p_business_group_id
    ,p_calculation_date   =>   p_calculation_date
    ,p_start_date         =>   l_start_date
    ,p_end_date           =>   l_end_date
    ,p_accrual_end_date   =>   l_accrual_end_date
    ,p_accrual            =>   l_accrual
    ,p_net_entitlement    =>   l_net_accrual
    );
  Exception
    when Others Then
       NULL;
   End;
--amit
    --
    l_leave_total_amount    := l_accrual;
    --
    hr_utility.set_location(l_proc,50) ;
    hr_utility.trace('l_leave_total_amount         = '||to_char(l_leave_total_amount));
    hr_utility.trace('l_start_date                 = '||to_char(l_start_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_end_date                   = '||to_char(l_end_date, 'yyyy/mm/dd'));
    hr_utility.trace('l_accrual_end_date           = '||to_char(l_accrual_end_date, 'yyyy/mm/dd'));
    --

  ---------------------------------------------------------------------------------
  --** Bug No : 2366349 : Function returns the accrual adjustment value for the first
  --** year which is added to the accrual. This function returns the accrual value in
  --** the first year and in the subsequent years it returns 0
  ---------------------------------------------------------------------------------


         l_adjustment_element := 'Accrual Adjustment Element';
         l_accrual_adj:= (get_adjustment_values(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_entitlement_end_date
                                  ,p_end_date            => l_calculation_date)
                      );
  ----------------------------------------------------------------------------------
  --** Bug No : 2366349 : Function returns the accrual adjustment value which need to
  --** be added to the entitlement value. l_accrual_ent returns the adjustment
  --** value for accrual for all the anniversary years whereas l_accrual_adj returns
  --** the adjustment value for accrual only for the first anniversary year.
  --** Reason : The Adjustment value entered for accrual should be added to the
  --** net accrual in the first year and from the next year onwards i.e., from the
  --** next anniversary year this has to be added to the net entitlement
  ----------------------------------------------------------------------------------

         l_accrual_ent:= (get_adjustment_values(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date));



      hr_utility.trace('ven_others_acc= '||to_char(l_accrual_adj));
      --------------------------------------
         --    Bug No : 2366349 End
         --------------------------------------
    l_others_accrual_amount := per_accrual_calc_functions.get_other_net_contribution (p_assignment_id     => p_assignment_id
               ,p_plan_id           => p_plan_id
               ,p_start_date        => l_entitlement_end_date
               ,p_calculation_date  => p_calculation_date ) ;

--   l_leave_total_amount := l_leave_total_amount + l_others_accrual_amount;
    --
    --  Find out the numder of hours taken during the accrual period
    --  If max_co  is 1 then no accrual only entitlement
    --
    if l_max_co = 1
    then
      l_accrual_absences := per_accrual_calc_functions.get_absence
                            (p_assignment_id    => p_assignment_id
                            ,p_plan_id          => p_plan_id
                            ,p_start_date       => l_entitlement_end_date + 1
                            ,p_calculation_date => p_calculation_date
                            );
      hr_utility.trace('Absence calculation start date = '||to_char(l_entitlement_end_date + 1,'yyyy/mm/dd'));
      l_leave_entitlement_amount := l_leave_total_amount - l_accrual_absences;
      l_leave_accrual_amount     := 0;
      --
    else
      l_accrual_absences := per_accrual_calc_functions.get_absence
                          (p_assignment_id       => p_assignment_id
                          ,p_plan_id             => p_plan_id
                          ,p_start_date          => l_start_date
                          ,p_calculation_date    => p_calculation_date
                          );
      hr_utility.trace('Absence calculation start date = '||to_char(l_start_date,'yyyy/mm/dd'));
      --
      --Get the net entitlement and accrualamount before checking for absences
      -- Determine the amount to go towards accrual portion by subtracting
      -- entitlement portion from total
      --
      l_leave_accrual_amount := l_leave_total_amount - l_leave_entitlement_amount;
      --
    l_leave_accrual_amount := l_leave_accrual_amount +
    l_others_accrual_amount  + l_accrual_adj;

    --** Bug 2366349 : l_accrual_ent is added to the net_entitlement. As this value
    --** in the first year is accrual, not entitlement l_accrual_adj is subtracted.
    --** As l_accrual_adj returns value only in the first anniversary year,
    --** l_accrual_adj and l_accrual_ent is nullified in the first year and from
    --** second year onwards adjusted accrual value is added to the entitlement

    l_leave_entitlement_amount := l_leave_entitlement_amount +
    l_others_entitlement_amount + l_entitlement_adj + l_accrual_ent - l_accrual_adj;


      -- have to subtract absences taken to calculate net entitlement
      -- absences must come off entitlement before accrual
      --
      if l_leave_entitlement_amount > l_accrual_absences
      then
        l_leave_entitlement_amount := l_leave_entitlement_amount - l_accrual_absences;
      else
       --subtract from entitlement and leftovers from accrual
        l_leave_accrual_amount := l_leave_accrual_amount - (l_accrual_absences-l_leave_entitlement_amount);
        l_leave_entitlement_amount := 0;
      end if;
    end if;
    --
    hr_utility.set_location(l_proc,60) ;
    hr_utility.trace('Net Entitlement Amount = '||to_char(l_leave_entitlement_amount));
    hr_utility.trace('Net Accrual Amount     = '||to_char(l_leave_accrual_amount));
    hr_utility.trace('Others accrual         = '||to_char(l_others_accrual_amount));
    hr_utility.trace('Others Entitlement     = '||to_char(l_others_entitlement_amount));

    --
    --  set up return values
    --
    p_net_accrual        := round(nvl(l_leave_accrual_amount,0),3);
    p_net_entitlement    := round(nvl(l_leave_entitlement_amount, 0),3);
    p_calc_start_date    := l_start_date;
    p_last_accrual       := l_accrual_end_date;
    p_next_period_end    := l_expiry_date;
    --
    hr_utility.trace('p_calc_start_date      = '||to_char(p_calc_start_date, 'yyyy/mm/dd'));
    hr_utility.trace('p_last_accrual         = '||to_char(p_last_accrual, 'yyyy/mm/dd'));
    hr_utility.trace('p_next_period_end      = '||to_char(p_next_period_end, 'yyyy/mm/dd'));
    --
    hr_utility.set_location('Leaving '||l_proc,80);
    RETURN (0);
EXCEPTION
WHEN OTHERS THEN
  hr_utility.trace('EXCEPTION-'||sqlerrm);


END get_accrual_entitlement ;

  --
  -----------------------------------------------------------------------------
  --  CHECK_PERIODS
  --
  --  Uses:
  --
  --  Used by:
  --    FastFormula Function NZ_STAT_ANNUAL_LEAVE_CARRYOVER
  --
  -----------------------------------------------------------------------------

function check_periods
(p_payroll_id                   in      number)
return date is
  --
  l_proc                          varchar2(61) := 'hr_nz_holidays.check_periods' ;
  l_end_date                      date         := to_date('01010001','DDMMYYYY');
  --
  --  cursor to check payroll periods exist up to calc_end_date
  --
  cursor c_last_period (p_payroll_id number) is
  select max(tp.end_date)
  from   per_time_periods tp
  where  tp.payroll_id = p_payroll_id;
  --
begin
  hr_utility.set_location('  In: ' || l_proc,5) ;
  --
  -- check payroll periods exist up to calculation_end_date
  --
  open c_last_period ( p_payroll_id );
  fetch c_last_period into l_end_date;
  close c_last_period;
  --
  hr_utility.set_location('  Out: ' || l_proc,10) ;
  return(l_end_date);
  EXCEPTION
    WHEN others THEN
    hr_utility.trace('Error - payroll periods not found for payroll_id '||to_char(p_payroll_id));
    hr_utility.set_location('Leaving:'||l_proc,99);
    RETURN NULL;
end check_periods ;


  /*---------------------------------------------------------------------

    ====================================
    3064179
    This function becomes on 01-APR-2004
    ====================================

    Name    : annual_leave_net_entitlement
    Purpose :
    Returns :  Total accrued entitlement to the last anniversary

    17 Jan 2000, JTurner: modified to cater for no carryover
    ---------------------------------------------------------------------*/

  PROCEDURE annual_leave_net_entitlement
    (p_assignment_id                  IN  NUMBER
    ,p_payroll_id                     IN  NUMBER
    ,p_business_group_id              IN  NUMBER
    ,p_plan_id                        IN  NUMBER
    ,p_calculation_date               IN  DATE
    ,p_start_date                     OUT NOCOPY DATE
    ,p_end_date                       OUT NOCOPY DATE
    ,p_net_entitlement                OUT NOCOPY NUMBER) IS

    --
    -- Local Variables
    --

    l_proc                          VARCHAR2(72) := g_package||'annual_leave_net_entitlement';
    l_net_accrual                   NUMBER;
    l_net_entitlement               NUMBER;
    l_calc_start_date               DATE;
    l_last_accrual                  DATE;
    l_next_period_end               DATE;
    l_return_val                    NUMBER;

  BEGIN

    hr_utility.trace(' In: ' || l_proc) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
    hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
    hr_utility.trace('  p_plan_id: ' || to_char(p_plan_id)) ;
    hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;


    l_return_val :=hr_nz_holidays.get_accrual_entitlement(p_assignment_id
                                          ,p_payroll_id
                                          ,p_business_group_id
                                          ,p_plan_id
                                          ,p_calculation_date
                                          ,l_net_accrual
                                          ,l_net_entitlement
                                          ,l_calc_start_date
                                          ,l_last_accrual
                                          ,l_next_period_end );
--amit
    p_net_entitlement := l_net_entitlement;
    p_start_date := l_calc_start_date ;
    p_end_date := p_calculation_date ;

    hr_utility.trace('  p_net_entitlement: ' || to_char(p_net_entitlement)) ;
    hr_utility.trace('  p_start_date: ' || to_char(p_start_date,'dd Mon yyyy')) ;
    hr_utility.trace('  p_end_date: ' || to_char(p_end_date,'dd Mon yyyy')) ;
    hr_utility.trace('Out: ' || l_proc) ;

  END annual_leave_net_entitlement;

  /*---------------------------------------------------------------------
    Name    : get_net_entitlement
    Purpose : Total accrued entitlement to the last anniversary
    Returns : 0 if successful, 1 otherwise
    ---------------------------------------------------------------------*/

  FUNCTION get_net_entitlement
    (p_assignment_id     IN  NUMBER
    ,p_payroll_id        IN  NUMBER
    ,p_business_group_id IN  NUMBER
    ,p_calculation_date  IN  DATE)
  RETURN NUMBER IS

    l_proc                  VARCHAR2(72) := g_package||'get_net_entitlement';
    l_plan_id               NUMBER;
    l_return_code           NUMBER;
    l_start_date            DATE;
    l_end_date              DATE;
    l_accrual_end_date      DATE;
    l_net_entitlement       NUMBER;
    l_acp_start_date        DATE;
    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

        l_plan_id := hr_nz_holidays.get_annual_leave_plan
                        (p_assignment_id     => p_assignment_id
                        ,p_business_group_id => p_business_group_id
                        ,p_calculation_date  => p_calculation_date);

        IF (l_plan_id IS NULL)
        THEN
    --* Bug# 2183135 Added the code to check the case wherein Employee takes
    --* Absence on the first day of the Accrual Plan Enrollment

        l_plan_id := hr_nz_holidays.get_annual_leave_plan
                        (p_assignment_id     => p_assignment_id
                        ,p_business_group_id => p_business_group_id
                        ,p_calculation_date  => p_calculation_date+1);
       l_acp_start_date := get_acp_start_date(p_assignment_id,l_plan_id,p_calculation_date+1);
      hr_utility.trace('acp_strt_date= '||l_acp_start_date);
      hr_utility.trace('p_cal_1_date = '||p_calculation_date);
      if ((p_calculation_date+1)=l_acp_start_date) then
         l_return_code := per_formula_functions.set_number('NET_ENTITLEMENT',0);
         RETURN 0;
       else
            hr_utility.set_location('Accrual Plan Not Found '||l_proc,10);
            hr_utility.set_message(801,'HR_NZ_ACCRUAL_PLAN_NOT_FOUND');
            hr_utility.raise_error;
        END IF;
       end if;

        hr_nz_holidays.annual_leave_net_entitlement
                        (p_assignment_id     => p_assignment_id
                        ,p_payroll_id        => p_payroll_id
                        ,p_business_group_id => p_business_group_id
                        ,p_plan_id           => l_plan_id
                        ,p_calculation_date  => p_calculation_date
                        ,p_start_date        => l_start_date
                        ,p_end_date          => l_end_date
                        ,p_net_entitlement   => l_net_entitlement);

        hr_utility.trace('  START_DATE: ' || to_char(l_start_date,'dd Mon yyyy')) ;
        l_return_code := per_formula_functions.set_date('START_DATE',l_start_date);
        hr_utility.trace('  END_DATE: ' || to_char(l_end_date,'dd Mon yyyy')) ;
        l_return_code := per_formula_functions.set_date('END_DATE',l_end_date);
        hr_utility.trace('  NET_ENTITLEMENT: ' || to_char(l_net_entitlement)) ;
          l_return_code := per_formula_functions.set_number('NET_ENTITLEMENT',l_net_entitlement);

        hr_utility.trace('  return: 0') ;
        hr_utility.trace('Out: ' || l_proc) ;
        RETURN 0;
    EXCEPTION
    WHEN others
    THEN

      hr_utility.trace('Crash Out: ' || l_proc) ;
        RETURN 1;
    END get_net_entitlement;

  /*---------------------------------------------------------------------
    Name    : call_accrual_formula
    Purpose : To run a named formula, with no inputs and no outputs
    Returns : 0 if successful, 1 otherwise
    ---------------------------------------------------------------------*/

  FUNCTION call_accrual_formula
    (p_assignment_id        IN  NUMBER
    ,p_payroll_id           IN  NUMBER
    ,p_business_group_id    IN  NUMBER
    ,p_accrual_plan_name    IN  VARCHAR2
    ,p_formula_name         IN  VARCHAR2
    ,p_calculation_date     IN  DATE)
  RETURN NUMBER IS

    l_proc              VARCHAR2(72) := g_package||'call_accrual_formula';
    l_inputs            ff_exec.inputs_t;
    l_get_outputs       ff_exec.outputs_t;
    l_accrual_plan_id   NUMBER;

    CURSOR csr_get_accrual_plan_id IS
        SELECT accrual_plan_id
        FROM pay_accrual_plans
        WHERE NVL(business_group_id, p_business_group_id) = p_business_group_id
        AND accrual_plan_name = p_accrual_plan_name;


  BEGIN
    hr_utility.trace('In: ' || l_proc) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
    hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
    hr_utility.trace('  p_accrual_plan_name: ' || p_accrual_plan_name) ;
    hr_utility.trace('  p_formula_name: ' || p_formula_name) ;
    hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

    OPEN csr_get_accrual_plan_id;
    FETCH csr_get_accrual_plan_id INTO l_accrual_plan_id;
    IF (csr_get_accrual_plan_id%NOTFOUND)
    THEN
        CLOSE csr_get_accrual_plan_id;
          hr_utility.trace('Crash Out: ' || l_proc) ;
        hr_utility.set_message(801, 'Accrual Plan Not Found');
        hr_utility.raise_error;
    END IF;
    CLOSE csr_get_accrual_plan_id;


     -----------------------------
     -- Initialise the formula. --
     -----------------------------

     l_inputs(1).name := 'ASSIGNMENT_ID';
     l_inputs(1).value := p_assignment_id;
     l_inputs(2).name := 'DATE_EARNED';
     l_inputs(2).value := TO_CHAR(p_calculation_date, 'DD-MON-YYYY');
     l_inputs(3).name := 'ACCRUAL_PLAN_ID';
     l_inputs(3).value := l_accrual_plan_id;
     l_inputs(4).name := 'BUSINESS_GROUP_ID';
     l_inputs(4).value := p_business_group_id;
     l_inputs(5).name := 'PAYROLL_ID';
     l_inputs(5).value := p_payroll_id;

     l_get_outputs(1).name := 'CONTINUE_PROCESSING_FLAG';

     ----------------------
     -- Run the formula. --
     ----------------------
     per_formula_functions.run_formula  (p_formula_name         => p_formula_name
                                        ,p_business_group_id    => p_business_group_id
                                        ,p_calculation_date     => p_calculation_date
                                        ,p_inputs               => l_inputs
                                        ,p_outputs              => l_get_outputs);

    hr_utility.trace('  return: 0') ;
    hr_utility.trace('Out: ' || l_proc) ;
     RETURN 0;
  EXCEPTION
    WHEN others THEN
      hr_utility.trace('Crash Out: ' || l_proc) ;
        RETURN 1;
  END call_accrual_formula;

  /*---------------------------------------------------------------------
        Name    : get_annual_leave_plan
        Purpose : To get the Annual Leave Plan for an Assignment
        Returns : PLAN_ID if successful, NULL otherwise
    ---------------------------------------------------------------------*/

  FUNCTION get_annual_leave_plan
    (p_assignment_id        IN  NUMBER
    ,p_business_group_id    IN  NUMBER
    ,p_calculation_date     IN  DATE)
  RETURN NUMBER IS

    l_proc      VARCHAR2(72) := g_package||'get_annual_leave_plan';
    l_plan_id   NUMBER;

    CURSOR csr_annual_leave_accrual_plan(c_business_group_id    IN NUMBER
                                        ,c_calculation_date     IN DATE
                                        ,c_assignment_id        IN NUMBER) IS
        SELECT  pap.accrual_plan_id
        FROM    pay_accrual_plans pap,
                pay_element_entries_f pee,
                pay_element_links_f pel,
                pay_element_types_f pet
        WHERE   pel.element_link_id = pee.element_link_id
        AND     pel.element_type_id = pet.element_type_id
        AND     pee.assignment_id = c_assignment_id
        AND     pet.element_type_id = pap.accrual_plan_element_type_id
        AND     pap.business_group_id + 0 = c_business_group_id
        AND     c_calculation_date BETWEEN pee.effective_start_date AND pee.effective_end_date
        AND     pap.accrual_category = 'NZAL' ;

    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

        OPEN csr_annual_leave_accrual_plan  (p_business_group_id
                                            ,p_calculation_date
                                            ,p_assignment_id);

        FETCH csr_annual_leave_accrual_plan INTO l_plan_id;
        CLOSE csr_annual_leave_accrual_plan;

        hr_utility.trace('  return: ' || to_char(l_plan_id)) ;
        hr_utility.trace('Out: ' || l_proc) ;
        RETURN l_plan_id;

    END;

    /*---------------------------------------------------------------------
            Name    : get_continuous_service_date
            Purpose : To get the Continuous Service Date for an Annual Leave Plan
            Returns : CONTINUOUS_SERVICE_DATE if successful, NULL otherwise
      ---------------------------------------------------------------------*/

  FUNCTION get_continuous_service_date
    (p_assignment_id        IN NUMBER
    ,p_business_group_id    IN NUMBER
    ,p_accrual_plan_id      IN NUMBER
    ,p_calculation_date     IN DATE)
  RETURN DATE IS

    l_proc      VARCHAR2(72) := g_package||'get_continuous_service_date';
    l_csd       DATE;

    CURSOR csr_continuous_service_date  (c_business_group_id    NUMBER
                                        ,c_accrual_plan_id      NUMBER
                                        ,c_calculation_date     DATE
                                        ,c_assignment_id        NUMBER) IS
        SELECT  NVL(TO_DATE(pev.screen_entry_value,'YYYY/MM/DD HH24:MI:SS'),pps.date_start)
        FROM    pay_element_entries_f pee,
                pay_element_entry_values_f pev,
                pay_input_values_f piv,
                pay_accrual_plans pap,
                per_all_assignments_f asg,
                per_periods_of_service pps
        WHERE   pev.element_entry_id = pee.element_entry_id
        AND     pap.accrual_plan_element_type_id = piv.element_type_id
        AND     piv.input_value_id = pev.input_value_id
        AND     pee.entry_type ='E'
        AND     asg.assignment_id = pee.assignment_id
        AND     asg.assignment_id = c_assignment_id
        AND     pap.accrual_plan_id = c_accrual_plan_id
        AND     asg.business_group_id = c_business_group_id
        AND     asg.period_of_service_id = pps.period_of_service_id
        AND     c_calculation_date BETWEEN asg.effective_start_date AND asg.effective_end_date
        AND     c_calculation_date BETWEEN pee.effective_start_date AND pee.effective_end_date
        AND     c_calculation_date BETWEEN piv.effective_start_date AND piv.effective_end_date
        AND     c_calculation_date BETWEEN pev.effective_start_date AND pev.effective_end_date
        AND     piv.name = (
                    SELECT meaning
                    FROM hr_lookups
                    WHERE lookup_type = 'NAME_TRANSLATIONS'
                    AND lookup_code = 'PTO_CONTINUOUS_SD');

  BEGIN
    hr_utility.trace('In: ' || l_proc) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
    hr_utility.trace('  p_accrual_plan_id: ' || to_char(p_accrual_plan_id)) ;

    OPEN csr_continuous_service_date    (p_business_group_id
                                        ,p_accrual_plan_id
                                        ,p_calculation_date
                                        ,p_assignment_id);
    FETCH csr_continuous_service_date INTO l_csd;
    CLOSE csr_continuous_service_date;
    hr_utility.trace('  return: ' || to_char(l_csd)) ;
    hr_utility.trace('Out: ' || l_proc) ;
    RETURN l_csd;

    END;


    /*---------------------------------------------------------------------
    ====================================
    3064179
    This function becomes on 01-APR-2004
    ====================================

            Name    : get_anniversary_date
            Purpose : To get the Anniversary Date for an Assignment
            Returns : Anniversary_Date if successful, NULL otherwise
      ---------------------------------------------------------------------*/

  FUNCTION get_anniversary_date
    (p_assignment_id        IN NUMBER
    ,p_business_group_id    IN NUMBER
    ,p_calculation_date     IN DATE)
  RETURN DATE IS

    l_proc              VARCHAR2(72) := g_package||'get_anniversary_date';
    l_anniversary_date  DATE;

    CURSOR csr_scl(c_business_group_id  NUMBER
                  ,c_calculation_date   DATE
                  ,c_assignment_id      NUMBER) IS
        SELECT  TO_DATE(scl.segment2,'YYYY/MM/DD HH24:MI:SS')
        FROM    hr_soft_coding_keyflex scl,
                per_assignments_f      asg
        WHERE   asg.assignment_id          = c_assignment_id
        AND     asg.business_group_id + 0  = c_business_group_id
        AND     scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
        AND     scl.enabled_flag           = 'Y'
        AND     scl.id_flex_num            = 18
        AND     c_calculation_date BETWEEN asg.effective_start_date AND asg.effective_end_date;


    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

        OPEN csr_scl(p_business_group_id
                    ,p_calculation_date
                    ,p_assignment_id);
        FETCH csr_scl INTO l_anniversary_date;
        CLOSE csr_scl;
      hr_utility.trace('  return: ' || to_char(l_anniversary_date,'dd Mon yyyy')) ;
      hr_utility.trace('Out: ' || l_proc) ;
        RETURN l_anniversary_date;

    END;

    /*---------------------------------------------------------------------
    ====================================
    3064179
    This function becomes on 01-APR-2004
    ====================================

            Name    : get_last_anniversary
            Purpose : To get the Last Anniversary Date for an Assignment
            Returns : Anniversary_Date if successful, NULL otherwise
      ---------------------------------------------------------------------*/

  FUNCTION get_last_anniversary
    (p_assignment_id        IN NUMBER
    ,p_business_group_id    IN NUMBER
    ,p_calculation_date     IN DATE)
  RETURN DATE IS

    l_proc              VARCHAR2(72) := g_package||'get_last_anniversary';
    l_base_anniversary  DATE;
    l_last_anniversary  DATE := NULL;

    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

        l_base_anniversary := get_anniversary_date  (p_business_group_id => p_business_group_id
                                                    ,p_calculation_date  => p_calculation_date
                                                    ,p_assignment_id     => p_assignment_id);
        IF (l_base_anniversary IS NULL)
        THEN
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_INVALID_ANNIVERSARY_DATE');
            hr_utility.raise_error;
        END IF;

        -- Assignment Anniversary Date is after the Calculation Date

        IF (l_base_anniversary > p_calculation_date)
        THEN
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_INVALID_CALC_DATE');
            hr_utility.raise_error;
        END IF;

        l_last_anniversary := TO_DATE(TO_CHAR(l_base_anniversary,'DDMM')||TO_CHAR(p_calculation_date,'YYYY'),'DDMMYYYY');
        IF (l_last_anniversary > p_calculation_date) THEN
            l_last_anniversary := ADD_MONTHS(l_last_anniversary,-12);
        END IF;
        hr_utility.trace('  return: ' || to_char(l_last_anniversary,'dd Mon yyyy')) ;
        hr_utility.trace('Out: ' || l_proc) ;
        RETURN l_last_anniversary;

    END;

    /*---------------------------------------------------------------------
            Name    : get_annual_entitlement
            Purpose : To get the annual leave entitlement for an accrual plan
            Returns : ANNUAL_ENTITLEMENT if successful, NULL otherwise
      ---------------------------------------------------------------------*/

  FUNCTION get_annual_entitlement
    (p_assignment_id       IN NUMBER
    ,p_business_group_id   IN NUMBER
    ,p_calculation_date    IN DATE)
  RETURN NUMBER IS
    --
    -- Cursors
    --
    CURSOR csr_get_payroll_end_date(c_assignment_id     NUMBER
                                   ,c_calculation_date  DATE) IS
        SELECT ptp.end_date
        FROM   per_time_periods ptp,
               per_all_assignments_f paa
        WHERE  ptp.payroll_id = paa.payroll_id
        AND    paa.assignment_id = c_assignment_id
        AND    c_calculation_date BETWEEN ptp.start_date AND ptp.end_date;

    CURSOR csr_get_accrual_band (c_number_of_years  NUMBER
                                ,c_accrual_plan_id  NUMBER) IS
        SELECT  annual_rate
        FROM    pay_accrual_bands
        WHERE   c_number_of_years >= lower_limit
        AND     c_number_of_years <  upper_limit
        AND     accrual_plan_id = c_accrual_plan_id;

    --
    -- Local Variables
    --
    l_proc                  VARCHAR2(72) := g_package||'get_annual_entitlement';
    l_continuous_service    DATE;
    l_payroll_period_end    DATE;
    l_accrual_plan_id       NUMBER;
    l_annual_entitlement    NUMBER := 0;
    l_years_service         NUMBER := 0;

    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;


        l_accrual_plan_id := hr_nz_holidays.get_annual_leave_plan
                                            (p_business_group_id => p_business_group_id
                                            ,p_calculation_date  => p_calculation_date
                                            ,p_assignment_id     => p_assignment_id);

        IF (l_accrual_plan_id IS NULL)
        THEN
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_INVALID_ACCRUAL_PLAN');
            hr_utility.raise_error;
        END IF;

        l_continuous_service := hr_nz_holidays.get_continuous_service_date
                                                (p_business_group_id => p_business_group_id
                                                ,p_accrual_plan_id   => l_accrual_plan_id
                                                ,p_calculation_date  => p_calculation_date
                                                ,p_assignment_id     => p_assignment_id);
        IF (l_continuous_service IS NULL)
        THEN
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_INVALID_SERVICE_DATE');
            hr_utility.raise_error;
        END IF;

        -- Get the payroll end date

        OPEN csr_get_payroll_end_date(p_assignment_id,p_calculation_date);
        FETCH csr_get_payroll_end_date INTO l_payroll_period_end;
        IF (csr_get_payroll_end_date%NOTFOUND)
        THEN
            CLOSE csr_get_payroll_end_date;
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_PAYROLL_DATE_NOT_FOUND');
            hr_utility.raise_error;
        END IF;
        CLOSE csr_get_payroll_end_date;

        -- Calculate the number of years service

        l_years_service := FLOOR(MONTHS_BETWEEN(l_payroll_period_end, l_continuous_service)/12);

        -- Get the accrual rate from the accrual band

        OPEN csr_get_accrual_band(l_years_service,l_accrual_plan_id);
        FETCH csr_get_accrual_band INTO l_annual_entitlement;
        IF (csr_get_accrual_band%NOTFOUND)
        THEN
            CLOSE csr_get_accrual_band;
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_ACCRUAL_BAND_NOT_FOUND');
            hr_utility.raise_error;
        END IF;
        CLOSE csr_get_accrual_band;
        hr_utility.trace('  return: ' || to_char(l_annual_entitlement)) ;
        hr_utility.trace('Out: ' || l_proc) ;
        RETURN l_annual_entitlement;

    END;

  /*---------------------------------------------------------------------
            Name    : get_annual_leave_taken
            Purpose : To get the annual leave taken for an accrual plan
            Returns : ANNUAL LEAVE TAKEN if successful, NULL otherwise
    ---------------------------------------------------------------------*/

  FUNCTION get_annual_leave_taken
    (p_assignment_id      IN NUMBER
    ,p_business_group_id  IN NUMBER
    ,p_calculation_date   IN DATE
    ,p_start_date         IN DATE
    ,p_end_date           IN DATE)
  RETURN NUMBER IS

    l_proc                  VARCHAR2(72) := g_package||'get_annual_leave_taken';
    l_plan_id               NUMBER;
    l_total_absence         NUMBER;

    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;
      hr_utility.trace('  p_start_date: ' || to_char(p_start_date,'dd Mon yyyy')) ;
      hr_utility.trace('  p_end_date: ' || to_char(p_end_date,'dd Mon yyyy')) ;

        l_plan_id := hr_nz_holidays.get_annual_leave_plan
                          (p_assignment_id     => p_assignment_id
                          ,p_business_group_id => p_business_group_id
                          ,p_calculation_date  => p_calculation_date);

        IF (l_plan_id IS NULL)
        THEN
          hr_utility.trace('  ** Accrual Plan Not Found **');
          hr_utility.trace('Crash Out: ' || l_proc) ;
          hr_utility.set_message(801,'HR_NZ_ACCRUAL_PLAN_NOT_FOUND');
          hr_utility.raise_error;
        END IF;
        hr_utility.set_location(l_proc,15);
        l_total_absence := per_accrual_calc_functions.get_absence
                            (p_assignment_id     => p_assignment_id
                            ,p_plan_id           => l_plan_id
                            ,p_calculation_date  => p_end_date
                            ,p_start_date        => p_start_date);

          hr_utility.trace('  return: ' || to_char(nvl(l_total_absence, 0))) ;
          hr_utility.trace('Out: ' || l_proc) ;
        RETURN NVL(l_total_absence, 0);

  END get_annual_leave_taken;

  -----------------------------------------------------------------------------
  --  num_weeks_for_avg_earnings
  --
  --  This function determines the number of weeks
  --  to use when calculating average earnings.  Complete
  --  weeks of special leave and protected voluntary
  --  service leave reduce the number of weeks in the year.
  -----------------------------------------------------------------------------

  function num_weeks_for_avg_earnings
  (p_assignment_id      in  number
  ,p_start_of_year_date in  date)
  return number is

    l_proc                  varchar2(72) := g_package||'num_weeks_for_avg_earnings';
    l_number_of_weeks       number;
    l_number_of_leave_weeks number;

    cursor c_number_of_leave_weeks(p_assignment_id  number
                                  ,p_start_of_year  date) is
      select nvl(sum(ab.abs_information2), 0) number_of_complete_weeks
      from   per_absence_attendances        ab
      ,      per_absence_attendance_types   aat
      ,      pay_element_entries_f          ee
      ,      pay_run_results                rr
      ,      pay_assignment_actions         aa
      ,      pay_payroll_actions            pa
      ,      per_time_periods               tp
      where  aat.absence_attendance_type_id = ab.absence_attendance_type_id
      and    aat.absence_category in ('NZSL', 'NZVS')
      and    ee.creator_type = 'A'
      and    ee.creator_id = ab.absence_attendance_id
      and    ee.assignment_id = p_assignment_id
      and    rr.source_id = ee.element_entry_id
      and    rr.source_type = 'E'
      and    aa.assignment_action_id = rr.assignment_action_id
      and    pa.payroll_action_id = aa.payroll_action_id
      and    pa.effective_date between ee.effective_start_date
                                   and ee.effective_end_date
      and    tp.time_period_id = pa.time_period_id
      and    tp.regular_payment_date >= p_start_of_year
      and    tp.regular_payment_date < add_months(p_start_of_year, 12) ;

  begin

    hr_utility.trace('In: ' || l_proc) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_start_of_year_date: ' || to_char(p_start_of_year_date,'dd Mon yyyy')) ;

    open c_number_of_leave_weeks(p_assignment_id
                                ,p_start_of_year_date) ;
    fetch c_number_of_leave_weeks
      into l_number_of_leave_weeks ;
    if (c_number_of_leave_weeks%notfound)
    then
      l_number_of_leave_weeks := 0 ;
    end if ;
    close c_number_of_leave_weeks ;
    l_number_of_weeks := 52 - l_number_of_leave_weeks ;

    hr_utility.trace('  return: ' || to_char(l_number_of_weeks)) ;
    hr_utility.trace('Out: ' || l_proc) ;

    return l_number_of_weeks ;

  end num_weeks_for_avg_earnings ;

  /*---------------------------------------------------------------------
                Name    : get_ar_element_details
                Purpose : To get the get_accrual_record for an accrual plan
                Returns : 0 if successful, 1 otherwise
    ---------------------------------------------------------------------*/

  FUNCTION get_ar_element_details
    (p_assignment_id               IN NUMBER
    ,p_business_group_id           IN NUMBER
    ,p_calculation_date            IN DATE
    ,p_element_type_id             OUT NOCOPY NUMBER
    ,p_accual_plan_name_iv_id      OUT NOCOPY NUMBER
    ,p_holiday_year_end_date_iv_id OUT NOCOPY NUMBER
    ,p_hours_accrued_iv_id         OUT NOCOPY NUMBER)
  RETURN NUMBER IS

    CURSOR csr_accrual_record_element(c_effective_date DATE) IS
        SELECT pet.element_type_id
        FROM   pay_element_types_f pet
        WHERE  pet.element_name = 'Annual Leave Accrual Record'
        AND    c_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date;

    CURSOR csr_accrual_record_iv(c_element_type_id pay_input_values_f.element_type_id%TYPE
                                ,c_effective_date DATE) IS
        SELECT piv.input_value_id
              ,piv.name
        FROM   pay_input_values_f  piv
        WHERE  piv.element_type_id = c_element_type_id
        AND    c_effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date;

    l_proc                        VARCHAR2(72) := g_package||'get_ar_element_details';
    l_element_type_id             NUMBER;
    l_accual_plan_name_iv_id      NUMBER;
    l_holiday_year_end_date_iv_id NUMBER;
    l_hours_accrued_iv_id         NUMBER;

    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;

        -- Find the Accrual Record Element
        OPEN csr_accrual_record_element(p_calculation_date);
        FETCH csr_accrual_record_element INTO l_element_type_id;
        IF (csr_accrual_record_element%NOTFOUND)
        THEN
            CLOSE csr_accrual_record_element;
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
            hr_utility.raise_error;
         END IF;
        CLOSE csr_accrual_record_element;
        hr_utility.set_location(l_proc,10);

        -- Get the input value id for each input value on the Accrual Record Element
        FOR rec_input_values in csr_accrual_record_iv(l_element_type_id, p_calculation_date)
        LOOP
            IF (rec_input_values.name = 'Accrual Plan Name')
            THEN
                l_accual_plan_name_iv_id := rec_input_values.input_value_id;
            ELSIF (rec_input_values.name = 'Holiday Year End Date')
            THEN
                l_holiday_year_end_date_iv_id := rec_input_values.input_value_id;
            ELSIF (rec_input_values.name = 'Hours Accrued')
            THEN
                l_hours_accrued_iv_id := rec_input_values.input_value_id;
            END IF;
        END LOOP;

        IF ( l_accual_plan_name_iv_id IS NULL OR
             l_holiday_year_end_date_iv_id IS NULL OR
             l_hours_accrued_iv_id IS NULL)
        THEN
            hr_utility.trace('Crash Out: ' || l_proc) ;
            hr_utility.set_message(801,'HR_NZ_INPUT_VALUE_NOT_FOUND');
            hr_utility.raise_error;
        END IF;
        hr_utility.set_location(l_proc, 15);

        hr_utility.trace('  p_element_type_id: ' || to_char(p_element_type_id)) ;
        p_element_type_id             := l_element_type_id;
        hr_utility.trace('  p_accual_plan_name_iv_id: ' || to_char(p_accual_plan_name_iv_id)) ;
        p_accual_plan_name_iv_id      := l_accual_plan_name_iv_id;
        hr_utility.trace('  p_holiday_year_end_date_iv_id: ' || to_char(p_holiday_year_end_date_iv_id)) ;
        p_holiday_year_end_date_iv_id := l_holiday_year_end_date_iv_id;
        hr_utility.trace('  p_hours_accrued_iv_id: ' || to_char(p_hours_accrued_iv_id)) ;
        p_hours_accrued_iv_id         := l_hours_accrued_iv_id;

        hr_utility.trace('  return: 0') ;
        hr_utility.trace('Out: ' || l_proc) ;
        RETURN 0;

  EXCEPTION
    WHEN others
    THEN
        hr_utility.trace('Crash Out: ' || l_proc) ;
           RETURN 1;
  END get_ar_element_details;

  /*---------------------------------------------------------------------
              Name    : annual_leave_entitled_to_pay
              Purpose : To get the annual leave pay for entitled pay
              Returns : ANNUAL LEAVE PAY if successful, NULL otherwise
    ---------------------------------------------------------------------*/
  /* Bug# 2185116 Added p_ordinary_rate, p_type parameters */

  FUNCTION annual_leave_entitled_to_pay
  (p_assignment_id                  IN     NUMBER
  ,p_business_group_id              IN     NUMBER
  ,p_payroll_id                     in     number
  ,p_calculation_date               IN     DATE
  ,p_entitled_to_hours              IN     NUMBER
  ,p_start_date                     IN     DATE
  ,p_anniversary_date               IN     DATE
  ,p_working_hours                  IN     NUMBER
  ,p_ordinary_rate                  IN     NUMBER
  ,p_type                           IN     VARCHAR2)
  RETURN NUMBER IS

    l_proc                          VARCHAR2(72) := g_package||'annual_leave_entitled_to_pay';
    l_anniversary_date              DATE;
    l_total_annual_leave_accrual    NUMBER := 0;
    l_prev_total_accrual            NUMBER := 0;
    l_gross_earnings                NUMBER := 0;
    l_annual_leave_pay              NUMBER := 0;
    l_hours_to_pay                  NUMBER := 0;
    l_hours_left_to_pay             NUMBER := 0;
    l_total_annual_leave_taken      NUMBER := 0;
    l_other_net_contributions       NUMBER := 0;
    l_num_weeks_in_year             NUMBER := 0;
    l_rate                          NUMBER := 0;
    l_accrued                       NUMBER := 0;
    l_taken                         NUMBER := 0;

    l_plan_id                       NUMBER;
    l_element_type_id               NUMBER;
    l_accual_plan_name_iv_id        NUMBER;
    l_holiday_year_end_date_iv_id   NUMBER;
    l_hours_accrued_iv_id           NUMBER;
    l_balance_type_id               NUMBER;
    l_return_value                  NUMBER;
    l_invalid_exit                  BOOLEAN := TRUE;

    l_pay_period_start_date          DATE;
    l_num_of_pay_periods_per_year    per_time_period_types.number_per_fiscal_year%type;
    l_extra_weeks                    NUMBER;
    l_offset_flag                    BOOLEAN := FALSE;


    CURSOR csr_gross_earning_balance IS
      SELECT pbt.balance_type_id
      FROM   pay_balance_types pbt
      WHERE  pbt.balance_name = 'Gross Earnings for Holiday Pay'
      AND    legislation_code = 'NZ'
      AND    business_group_id IS NULL;

 /* Bug 2230110 Added the following cursor  */
 /* Bug 2264070 Added a extra join for payroll_action_id  */
    cursor get_pay_period_start_date(p_assignment_id in number) is
      SELECT TPERIOD.start_date,
             TPTYPE.number_per_fiscal_year
       FROM  pay_payroll_actions      PACTION,
             per_time_periods         TPERIOD,
             per_time_period_types    TPTYPE
      where  PACTION.payroll_action_id =
                               (select max(paa.payroll_action_id)
                                  from pay_assignment_actions paa,
                                       pay_payroll_actions ppa
                                 where paa.assignment_id     = p_assignment_id
                                   and ppa.action_type       in ('R','Q')
                                   and ppa.payroll_action_id = paa.payroll_action_id)
        and  PACTION.payroll_id       = TPERIOD.payroll_id
        and  PACTION.date_earned      between TPERIOD.start_date and TPERIOD.end_date
        and  TPTYPE.period_type       = TPERIOD.period_type;

   /* Bug 2798048-NZ Parental leave, added the following code
   for checking whether parental leave is taken in a particular
   period.*/
    l_parental_leave                NUMBER := 0;
    l_prev_anniversary_date         DATE;

    FUNCTION get_parental_leaves_taken
      (p_assignment_id      IN NUMBER
      ,p_business_group_id  IN NUMBER
      ,p_start_date         IN DATE
      ,p_end_date           IN DATE)
    RETURN NUMBER IS

        CURSOR csr_parental_leaves_taken(c_assignment_id IN NUMBER
                                           ,c_business_group_id IN NUMBER
                                           ,c_start_date IN DATE
                                           ,c_end_date IN DATE)IS
        select 1
        from   per_absence_attendances paa,
               per_absence_attendance_types paat
        where  paa.person_id = (select distinct person_id
                                from    per_assignments_f paaf
                                where   paaf.assignment_id = c_assignment_id)
        and    paa.business_group_id = c_business_group_id
        and    paa.business_group_id = paat.business_group_id
        and    paa.absence_attendance_type_id = paat.absence_attendance_type_id
        and    paat.absence_category = 'NZPL'
        and    (paa.date_start between c_start_date and c_end_date
        or     paa.date_end between c_start_date and c_end_date );

        l_pleave_taken  number         := 0;
        l_proc          varchar2(72)   := 'get_parental_leaves_taken' ;

    BEGIN
        hr_utility.trace('In: ' || l_proc);
        hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
        hr_utility.trace('  p_business_group_id: '||to_char(p_business_group_id));
        hr_utility.trace('  p_start_date: ' || to_char(p_start_date,'dd Mon yyyy')) ;
        hr_utility.trace('  p_end_date: ' || to_char(p_end_date,'dd Mon yyyy')) ;

        open csr_parental_leaves_taken(p_assignment_id,
                                       p_business_group_id,
                                       p_start_date,
                                       p_end_date);
        fetch csr_parental_leaves_taken into l_pleave_taken;

        if csr_parental_leaves_taken%FOUND then
            close csr_parental_leaves_taken;
            hr_utility.trace(' l_pleave_taken: ' || to_char(l_pleave_taken));
            hr_utility.trace('Out: ' || l_proc);
            return 1;
        end if;
        close csr_parental_leaves_taken;
        hr_utility.trace(' No parental leave taken');
        hr_utility.trace('Out: ' || l_proc);
        return 0;
    END get_parental_leaves_taken;
   /* Bug 2798048-NZ Parental leave, End.*/


    FUNCTION get_total_annual_leave_accrued
    (p_assignment_id                  number
    ,p_holiday_year_end_date          date
    ,p_plan_id                        number
    ,p_business_group_id              number
    ,p_payroll_id                     number)
    RETURN NUMBER IS

      l_proc                          varchar2(72) := 'get_total_annual_leave_accrued' ;
      l_accrual                       number ;
      l_other                         number ;
      l_total                         number ;
      l_start_date                    date ;
      l_end_date                      date ;
      l_accrual_end_date              date ;

    l_adjustment_element   VARCHAR2(100);
    l_accrual_adj  NUMBER;
    l_entitlement_adj NUMBER;

    BEGIN
      hr_utility.trace('  In: ' || l_proc) ;

      --  find what the accrual was as at the holiday year end date supplied

      per_accrual_calc_functions.get_accrual
      (p_assignment_id      => p_assignment_id
      ,p_calculation_date   => p_holiday_year_end_date
      ,p_plan_id            => p_plan_id
      ,p_business_group_id  => p_business_group_id
      ,p_payroll_id         => p_payroll_id
      ,p_start_date         => l_start_date
      ,p_end_date           => l_end_date
      ,p_accrual_end_date   => l_accrual_end_date
      ,p_accrual            => l_accrual) ;

      --  find what other contributions were at holiday year end date

      /* Bug 2366349 Adjustment Element values are added to the total accrual */

         l_adjustment_element:= 'Entitlement Adjustment Element';
         l_entitlement_adj:= (get_adjustment_values(
                                   p_assignment_id       => p_assignment_id
                                  ,p_accrual_plan_id     => p_plan_id
                                  ,p_calc_end_date       => p_holiday_year_end_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date));


        hr_utility.trace('ven_others_ent= '||to_char(l_entitlement_adj));

         l_adjustment_element := 'Accrual Adjustment Element';
         l_accrual_adj:= (get_adjustment_values(
                                   p_assignment_id       => p_assignment_id
                                  ,p_accrual_plan_id     => p_plan_id
                                  ,p_calc_end_date       => p_holiday_year_end_date
                                  ,p_adjustment_element  => l_adjustment_element
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date));


      hr_utility.trace('ven_others_acc= '||to_char(l_accrual_adj));


      l_other := per_accrual_calc_functions.get_other_net_contribution
                 (p_assignment_id     => p_assignment_id
                 ,p_plan_id           => p_plan_id
                 ,p_start_date        => l_start_date
                 ,p_calculation_date  => p_holiday_year_end_date);

      l_total := l_accrual + l_other +l_accrual_adj + l_entitlement_adj;

      hr_utility.trace('  Out: ' || l_proc) ;
      RETURN l_total ;

    END get_total_annual_leave_accrued;

    BEGIN
      hr_utility.trace('In: ' || l_proc) ;
      hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
      hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
      hr_utility.trace('  p_calculation_date: ' || to_char(p_calculation_date,'dd Mon yyyy')) ;
      hr_utility.trace('  p_entitled_to_hours: ' || to_char(p_entitled_to_hours)) ;
      hr_utility.trace('  p_start_date: ' || to_char(p_start_date,'dd Mon yyyy')) ;
      hr_utility.trace('  p_anniversary_date: ' || to_char(p_anniversary_date,'dd Mon yyyy')) ;
      hr_utility.trace('  p_working_hours: ' || to_char(p_working_hours)) ;

      l_anniversary_date  := p_anniversary_date ;
      l_hours_left_to_pay := p_entitled_to_hours;

      l_plan_id := hr_nz_holidays.get_annual_leave_plan
                   (p_assignment_id     => p_assignment_id
                   ,p_business_group_id => p_business_group_id
                   ,p_calculation_date  => p_calculation_date);

      IF (l_plan_id IS NULL)
      THEN
        hr_utility.trace('Crash Out: ' || l_proc) ;
        hr_utility.set_message(801,'HR_NZ_ACCRUAL_PLAN_NOT_FOUND');
        hr_utility.raise_error;
      END IF;

      --  find total leave taken up until just before this leave

      l_total_annual_leave_taken := hr_nz_holidays.get_annual_leave_taken
                                    (p_assignment_id     => p_assignment_id
                                    ,p_business_group_id => p_business_group_id
                                    ,p_calculation_date  => p_calculation_date
                                    ,p_start_date        => p_anniversary_date
                                    ,p_end_date          => p_start_date - 1) ;

      hr_utility.trace('  l_total_annual_leave_taken: ' || to_char(l_total_annual_leave_taken)) ;
      hr_utility.trace('  l_anniversary_date: ' || to_char(l_anniversary_date, 'dd Mon yyyy')) ;

      WHILE (l_anniversary_date <= p_start_date)
      LOOP

        l_total_annual_leave_accrual := get_total_annual_leave_accrued
                                        (p_assignment_id                  => p_assignment_id
                                        ,p_holiday_year_end_date          => l_anniversary_date - 1
                                        ,p_plan_id                        => l_plan_id
                                        ,p_business_group_id              => p_business_group_id
                                        ,p_payroll_id                     => p_payroll_id) ;

        hr_utility.trace('  l_total_annual_leave_accrual: ' || to_char(l_total_annual_leave_accrual)) ;

        IF (l_total_annual_leave_accrual >= l_total_annual_leave_taken)
        THEN
          l_invalid_exit := FALSE;
          l_total_annual_leave_accrual := l_total_annual_leave_accrual - l_total_annual_leave_taken;
          EXIT ;
        END IF;

        l_anniversary_date  := ADD_MONTHS(l_anniversary_date,12);
        hr_utility.trace('  l_anniversary_date: ' || to_char(l_anniversary_date, 'dd Mon yyyy')) ;

      END LOOP;

      IF (l_invalid_exit)
      THEN
        hr_utility.trace('  ** No entitled annual leave found **');
        hr_utility.trace('Crash Out: ' || l_proc) ;
        hr_utility.set_message(801,'HR_NZ_ENTITLED_LEAVE_NOT_FOUND');
        hr_utility.raise_error;
      END IF;


    /* Bug 2230110 cursor get_pay_period_start_date is used to get the pay period start date. */

       open get_pay_period_start_date(p_assignment_id);
       fetch get_pay_period_start_date into l_pay_period_start_date,l_num_of_pay_periods_per_year;
       close get_pay_period_start_date;


     /* following check is to find whether holiday anniversary date lies in between the pay
        period  and if so, find the number of weeks in the pay period */
       if (to_char(p_anniversary_date,'dd') <> to_char(l_pay_period_start_date,'dd'))
       then
         l_extra_weeks := 52/l_num_of_pay_periods_per_year;
         l_offset_flag := true;
       end if;

      /* Bug 2798048-NZ Parental leave, calculate the previous holiday
         anniversary date.*/
      l_prev_anniversary_date := ADD_MONTHS(l_anniversary_date,-12);

      LOOP

        l_num_weeks_in_year := num_weeks_for_avg_earnings
                               (p_assignment_id => p_assignment_id
                               ,p_start_of_year_date =>  ADD_MONTHS(l_anniversary_date,-12));

       /* if holiday anniversary is inbetween the pay period add the extra pay period weeks */
        if l_offset_flag then
          l_num_weeks_in_year := l_num_weeks_in_year + l_extra_weeks;
        end if;

        OPEN csr_gross_earning_balance;
        FETCH csr_gross_earning_balance INTO l_balance_type_id;
        CLOSE csr_gross_earning_balance;

        IF (l_balance_type_id IS NULL)
        THEN
          hr_utility.trace('Crash Out: ' || l_proc) ;
          hr_utility.set_message(801,'HR_NZ_BALANCE_NOT_FOUND');
          hr_utility.raise_error;
        END IF;

-- Changed the parameter to p_calculation_date. Bug #2090809
/* Bug# 2185116 --> Changed the calculation date to anniversary date-1 */

           l_gross_earnings := hr_nzbal.calc_asg_hol_ytd_date
                               (p_assignment_id   => p_assignment_id
                               ,p_balance_type_id => l_balance_type_id
                               ,p_effective_date  => l_anniversary_date-1);
        hr_utility.trace('  Year Ending: ' || to_char(l_anniversary_date - 1,'dd Mon yyyy')) ;
        hr_utility.trace('  Gross Earnings for Holiday Pay: ' || to_char(l_gross_earnings)) ;

        l_rate := l_gross_earnings / l_num_weeks_in_year / p_working_hours;
        l_hours_to_pay := LEAST(l_hours_left_to_pay, l_total_annual_leave_accrual - l_prev_total_accrual);
        hr_utility.trace('  Rate: ' || to_char(l_rate)) ;
        hr_utility.trace('  Hours Left to Pay: ' || to_char(l_hours_left_to_pay)) ;
        hr_utility.trace('  Total Annual Leave Accrual: ' || to_char(l_total_annual_leave_accrual)) ;
        hr_utility.trace('  Previous Total  Accrual: ' || to_char(l_prev_total_accrual)) ;
        hr_utility.trace('  Hours to Pay: ' || to_char(l_hours_to_pay)) ;
        hr_utility.trace('  Annual Leave Pay: ' || to_char(l_annual_leave_pay)) ;

      /* Bug 2798048-NZ Parental leave, calculation changes for annual leave
         falling in parental leave period.*/
        l_parental_leave := get_parental_leaves_taken
                             (p_assignment_id      => p_assignment_id
                             ,p_business_group_id  => p_business_group_id
                             ,p_start_date         => l_prev_anniversary_date
                             ,p_end_date           => l_anniversary_date-1);

        hr_utility.trace(' Parental Leave Taken:' || to_char(l_parental_leave));
        if l_parental_leave = 1 then
          l_annual_leave_pay := l_annual_leave_pay + (l_hours_to_pay * l_rate);
        else
          /* Bug# 2185116 Included the check for greatest of Ordinary pay and
             Average Pay and the greatest value is returned  */
         l_annual_leave_pay := l_annual_leave_pay + GREATEST((l_hours_to_pay * l_rate),(l_hours_to_pay*p_ordinary_rate));
        end if;

        hr_utility.trace('  Annual Leave Pay: ' || to_char(l_annual_leave_pay)) ;
        l_hours_left_to_pay := nvl(l_hours_left_to_pay,0) - round(nvl(l_hours_to_pay,0),3);

        hr_utility.trace('  Hours Left to Pay: ' || to_char(l_hours_left_to_pay)) ;
        EXIT WHEN (l_hours_left_to_pay = 0);

        /* Bug 2798048-NZ Parental leave, update the
           previous anniversary date*/
        l_prev_anniversary_date := l_anniversary_date;
        l_anniversary_date := ADD_MONTHS(l_anniversary_date,12);
        l_prev_total_accrual := l_total_annual_leave_accrual;

        l_taken := hr_nz_holidays.get_annual_leave_taken
                   (p_assignment_id      => p_assignment_id
                   ,p_business_group_id  => p_business_group_id
                   ,p_calculation_date   => p_calculation_date
                   ,p_start_date         => p_anniversary_date
                   ,p_end_date           => l_anniversary_date);

        l_accrued := get_total_annual_leave_accrued
                     (p_assignment_id                  => p_assignment_id
                     ,p_holiday_year_end_date          => l_anniversary_date - 1
                     ,p_plan_id                        => l_plan_id
                     ,p_business_group_id              => p_business_group_id
                     ,p_payroll_id                     => p_payroll_id) ;

      hr_utility.trace('  Leave Taken: ' || to_char(l_taken)) ;
      hr_utility.trace('  Leave Accrued: ' || to_char(l_accrued)) ;
        l_total_annual_leave_accrual := l_accrued - l_taken;

      END LOOP;

      hr_utility.trace('  return: ' || to_char(l_annual_leave_pay)) ;
      hr_utility.trace('Out: ' || l_proc) ;
      RETURN l_annual_leave_pay;

  END annual_leave_entitled_to_pay;

  -----------------------------------------------------------------------------
  --  ====================================
  --  3064179
  --  This function becomes on 01-APR-2004
  --  ====================================

  --  annual_leave_eoy_adjustment
  --
  --  calculate annual leave end of year adjustment
  -----------------------------------------------------------------------------

  function annual_leave_eoy_adjustment
  (p_business_group_id            in     number
  ,p_payroll_id                   in     number
  ,p_assignment_id                in     number
  ,p_asg_hours                    in     number
  ,p_year_end_date                in     date
  ,p_in_advance_pay_carryover     in out nocopy number
  ,p_in_advance_hours_carryover   in out nocopy number)
  return number is

    l_procedure_name                  varchar2(61) := 'hr_nz_holidays.annual_leave_eoy_adjustment' ;
    l_eoy_adjustment                  number ;
    l_balance_type_id                 pay_balance_types.balance_type_id%type ;
    l_annual_leave_in_advance_hrs     number ;
    l_annual_leave_in_advance_pay     number ;
    l_accrual_plan_id                 pay_accrual_plans.accrual_plan_id%type ;
    l_start_date                      date ;
    l_end_date                        date ;
    l_accrual_end_date                date ;
    l_accrual                         number ;
    l_accrual_tmp                     number ;
    l_in_advance_hours_carryover      number ;
    l_in_advance_pay_carryover        number ;
    l_hours_to_adjust                 number ;
    l_pay_to_adjust                   number ;
    l_gross_earnings_for_hol_pay      number ;
    l_num_weeks                       number ;
    l_recalculated_pay                number ;
    l_absence_hours                   number ;
    l_absence_pay                     number ;
    l_hours_running_total             number ;
    l_prev_hours_running_total        number ;
    l_pay_running_total               number ;
    l_prev_pay_running_total          number ;
    l_pay                             number ;
    l_hours                           number ;

    l_pay_period_start_date           date;
    l_num_of_pay_periods_per_year     number;
    l_extra_weeks                     number;
    l_offset_flag                     boolean:= false;

    e_missing_balance_type            exception ;
    e_missing_accrual_plan            exception ;
    e_missing_leave_in_advance        exception ;

  /* Bug 2581490 - added join to pay_payroll_actions in subquery */
     cursor get_pay_period_start_date(p_assignment_id number) is
      SELECT TPERIOD.start_date,
             TPTYPE.number_per_fiscal_year
       FROM  pay_payroll_actions      PACTION,
             per_time_periods         TPERIOD,
             per_time_period_types    TPTYPE
      where  PACTION.payroll_action_id =
                               (select max(paa.payroll_action_id)
                                  from pay_assignment_actions paa,
                                       pay_payroll_actions ppa
                                 where paa.assignment_id     = p_assignment_id
                                   and ppa.action_type       in ('R','Q')
                                   and ppa.payroll_action_id = paa.payroll_action_id)
        and  PACTION.payroll_id       = TPERIOD.payroll_id
        and  PACTION.date_earned      between TPERIOD.start_date and TPERIOD.end_date
        and  TPTYPE.period_type       = TPERIOD.period_type;

    -- cursor to get ID for a balance type
    cursor c_balance_type(p_name varchar2) is
      select bt.balance_type_id
      from   pay_balance_types bt
      where  bt.balance_name = p_name ;

    --  cursor to get annual leave accrual plan
    cursor c_annual_leave_plan(p_assignment_id  number
                              ,p_effective_date date) is
      select pap.accrual_plan_id
      from   pay_accrual_plans      pap
      ,      pay_element_entries_f  pee
      ,      pay_element_links_f    pel
      ,      pay_element_types_f    pet
      where  pee.assignment_id = p_assignment_id
      and    p_effective_date between pee.effective_start_date
                                  and pee.effective_end_date
      and    pel.element_link_id = pee.element_link_id
      and    p_effective_date between pel.effective_start_date
                                  and pel.effective_end_date
      and    pel.element_type_id = pet.element_type_id
      and    p_effective_date between pet.effective_start_date
                                  and pet.effective_end_date
      and    pap.accrual_plan_element_type_id = pet.element_type_id
      and    pap.accrual_category = 'NZAL' ;

    --  cursor to get annual leave in advance payments made during the year
    --
    --  This is a bit complicated: the hours taken come from the absence
    --  record (per_absence_attendances).  A corresponding element entry,
    --  "absence element entry", is created for each absence record
    --  (pay_element_entries_f).  When the absence element entry gets processed
    --  an indirect result causes a new entry to be created for the "Annual
    --  Leave Pay" element type.  The pay value run result for the "Annual
    --  Leave Pay" element is the amount paid for the leave.

    -- Bug no : 2097319 : added or clause in the query to handle the
    -- when payroll is used with offsets

    cursor c_leave_in_advance(p_accrual_plan_id   number
                             ,p_assignment_id     number
                             ,p_year_end_date     date) is
   select ab.absence_hours               absence_hours
      ,      to_number(rrv2.result_value)   absence_pay
      from   pay_accrual_plans              ap    --  annual leave accrualplan
      ,      pay_element_entry_values_f     eev   --  absence element entry
                                                  --  "hours taken" entry value
      ,      pay_element_entries_f          ee    --  absence element entry
      ,      pay_run_results                rr    --  run result for absence                                                  --  element entry
      ,      per_absence_attendances        ab    --  absence record
      ,      pay_assignment_actions         aa    --  assignment action for                                                  --  absence element entry
      ,      pay_payroll_actions            pa    --  payroll action for                                                  --  absence element entry
      ,      per_time_periods               tp
      ,      pay_run_results                rr2   --  run result for Annual                                                  --  Leave Pay element type
      ,      pay_run_result_values          rrv2  --  run result value for                                                  --  Annual Leave Pay element                                                  --  pay value      ,
     , pay_element_types_f            et2   --  Annual Leave Pay element
      ,      pay_input_values_f             iv2   --  Pay Value input value
      where  ap.accrual_plan_id = p_accrual_plan_id
      and    eev.input_value_id = ap.pto_input_value_id
      and    ee.element_entry_id = eev.element_entry_id
      and    ee.assignment_id = p_assignment_id
      and    rr.source_id = ee.element_entry_id
      and    rr.source_type = 'E'
      and    ee.creator_type = 'A'
      and    ab.absence_attendance_id = ee.creator_id
      and    aa.assignment_action_id = rr.assignment_action_id
      and    pa.payroll_action_id = aa.payroll_action_id
      and (
         (tp.regular_payment_date <= p_year_end_date
          and    pa.effective_date between ee.effective_start_date
                                   and ee.effective_end_date
                  and    pa.effective_date between eev.effective_start_date
                                   and eev.effective_end_date
                  and pa.time_period_id=tp.time_period_id
          )
         or
         (
          pa.payroll_id = tp.payroll_id
          and    pa.date_earned between tp.start_date and tp.end_date
              and    p_year_end_date >= tp.start_date
          and    pa.date_earned between ee.effective_start_date
                                   and ee.effective_end_date
                  and    pa.date_earned between eev.effective_start_date
                                   and eev.effective_end_date
          )
      )
      and    et2.element_name = 'Annual Leave Pay'
      and    pa.effective_date between et2.effective_start_date
                                   and et2.effective_end_date
      and    rr2.element_type_id = et2.element_type_id
      and    rr2.source_id = ee.element_entry_id
      and    rr2.source_type = 'I'
      and    rr2.assignment_action_id = aa.assignment_action_id
      and    rrv2.run_result_id = rr2.run_result_id
      and    iv2.input_value_id = rrv2.input_value_id
      and    pa.effective_date between iv2.effective_start_date
                                   and iv2.effective_end_date
      and    iv2.name = 'Pay Value'
      order by
             aa.action_sequence desc
      ,      ab.date_start desc
      ,      to_date(ab.time_start, 'hh24:mi') ;


  begin

    --  trace input variables
    hr_utility.trace('In: ' || l_procedure_name) ;
    hr_utility.trace('  p_business_group_id: ' || to_char(p_business_group_id)) ;
    hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_asg_hours: ' || to_char(p_asg_hours)) ;
    hr_utility.trace('  p_year_end_date: ' || to_char(p_year_end_date, 'dd Mon yyyy')) ;
    hr_utility.trace('  p_in_advance_pay_carryover: ' || to_char(p_in_advance_pay_carryover)) ;
    hr_utility.trace('  p_in_advance_hours_carryover: ' || to_char(p_in_advance_hours_carryover)) ;

    --  get values for ANNUAL_LEAVE_IN_ADVANCE_HOURS_ASG_HOL_YTD and
    --  ANNUAL_LEAVE_IN_ADVANCE_PAY_ASG_HOL_YTD balances as at the end of the
    --  holiday year

    open c_balance_type('Annual Leave in Advance Hours') ;
    fetch c_balance_type
      into l_balance_type_id ;
    if c_balance_type%notfound
    then
      close c_balance_type ;
      raise e_missing_balance_type ;
    end if ;
    close c_balance_type ;

    l_annual_leave_in_advance_hrs := hr_nzbal.calc_asg_hol_ytd_date
                                     (p_assignment_id
                                     ,l_balance_type_id
                                     ,p_year_end_date) ;

    l_annual_leave_in_advance_hrs := l_annual_leave_in_advance_hrs
                                     + p_in_advance_hours_carryover ;

    open c_balance_type('Annual Leave in Advance Pay') ;
    fetch c_balance_type
      into l_balance_type_id ;
    if c_balance_type%notfound
    then
      close c_balance_type ;
      raise e_missing_balance_type ;
    end if ;
    close c_balance_type ;

    l_annual_leave_in_advance_pay := hr_nzbal.calc_asg_hol_ytd_date
                                     (p_assignment_id
                                     ,l_balance_type_id
                                     ,p_year_end_date) ;

    l_annual_leave_in_advance_pay := l_annual_leave_in_advance_pay
                                     + p_in_advance_pay_carryover ;

    hr_utility.trace('Ann_leave_adv_hrs= '|| to_char(l_annual_leave_in_advance_hrs));
    hr_utility.trace('Ann_leave_adv_pay= '|| to_char(l_annual_leave_in_advance_pay));
    --  if there is no annual leave in advance or annual leave in advance
    --  carryover then we can finish now
    if l_annual_leave_in_advance_hrs = 0
    then

      hr_utility.trace('  no in advance leave to process') ;

      --  set outputs
      p_in_advance_pay_carryover := 0 ;
      p_in_advance_hours_carryover := 0 ;
      l_eoy_adjustment := 0 ;

      --  trace output variables
      hr_utility.trace('  p_in_advance_pay_carryover: ' || to_char(p_in_advance_pay_carryover)) ;
      hr_utility.trace('  p_in_advance_hours_carryover: ' || to_char(p_in_advance_hours_carryover)) ;
      hr_utility.trace('  return: ' || to_char(l_eoy_adjustment)) ;

      return l_eoy_adjustment ;

    end if ;

    hr_utility.trace('  in advance leave to process') ;

    --  Now work out what the accrual for the holiday year was.  First
    --  get the accrual plan ID, then find the accrual up until the end of the
    --  holiday year, then the accrual up until the end of the previous holiday
    --  year and subtract the values

    --  get the accrual plan ID
    open c_annual_leave_plan(p_assignment_id
                            ,p_year_end_date) ;
    fetch c_annual_leave_plan
      into l_accrual_plan_id ;
    if c_annual_leave_plan%notfound
    then
      close c_annual_leave_plan ;
      raise e_missing_accrual_plan ;
    end if ;
    close c_annual_leave_plan ;

    per_accrual_calc_functions.get_accrual
    (p_assignment_id      => p_assignment_id
    ,p_calculation_date   => p_year_end_date
    ,p_plan_id            => l_accrual_plan_id
    ,p_business_group_id  => p_business_group_id
    ,p_payroll_id         => p_payroll_id
    ,p_start_date         => l_start_date
    ,p_end_date           => l_end_date
    ,p_accrual_end_date   => l_accrual_end_date
    ,p_accrual            => l_accrual) ;

    per_accrual_calc_functions.get_accrual
    (p_assignment_id      => p_assignment_id
    ,p_calculation_date   => add_months(p_year_end_date, -12)
    ,p_plan_id            => l_accrual_plan_id
    ,p_business_group_id  => p_business_group_id
    ,p_payroll_id         => p_payroll_id
    ,p_start_date         => l_start_date
    ,p_end_date           => l_end_date
    ,p_accrual_end_date   => l_accrual_end_date
    ,p_accrual            => l_accrual_tmp) ;

    l_accrual := l_accrual - l_accrual_tmp ;

    hr_utility.trace('  l_accrual: ' || to_char(l_accrual)) ;

    --  Now we know how many hours have been taken in advance
    --  (l_annual_leave_in_advance_hrs) and how many hours were accrued during
    --  the year (l_accrual).  We also know the value, as paid, of the in
    --  advance hours (l_annual_leave_in_advance_pay).

    --  Next we need to determine how much of the in advance should be adjusted
    --  this year.

    --  If l_annual_leave_in_advance_hrs is less then or equal to l_accrual
    --  then all the in advance pay should be considered this year.  No
    --  advance hours or advance pay will need to be carried over for future
    --  processing.

    --  If l_annual_leave_in_advance_hrs is greater then l_accrual we need to
    --  carryover the difference for consideration in a future year.  The
    --  number of hours to consider this year will be l_accrual.  We need to
    --  work out the value of those hours.  The advance hours and pay not
    --  adjusted this year will be carried over for future processing.

    if l_annual_leave_in_advance_hrs <= l_accrual
    then

      hr_utility.trace('  no in advance leave carryover to process') ;

      --  all the advance pay will be adjusted this year
      l_in_advance_hours_carryover := 0 ;
      l_hours_to_adjust := l_annual_leave_in_advance_hrs ;
      l_in_advance_pay_carryover := 0 ;
      l_pay_to_adjust := l_annual_leave_in_advance_pay ;

    else  --  if l_annual_leave_in_advance_hrs > l_accrual

      hr_utility.trace('  in advance leave carryover to process') ;

      --  some of the adjustment will be carried over.  Work out what
      --  portion of the advance should be dealth with now.

      --  work out the hours to adjust and the hours to carryover
      l_in_advance_hours_carryover := l_annual_leave_in_advance_hrs
                                      - l_accrual ;
      l_hours_to_adjust := l_accrual ;

      hr_utility.trace('l_hrs_to_adj= '||l_hours_to_adjust);

      --  work out the pay to adjust and the pay to carryover
      --
      --  to find the pay to adjust we need to loop through the in advance
      --  absence records and find those that contribute to the hours to
      --  adjust

      --  initialise some variables used in the following loop
      l_hours_running_total := 0 ;
      l_prev_hours_running_total := 0 ;
      l_pay_running_total := 0 ;
      l_prev_pay_running_total := 0 ;
      l_in_advance_pay_carryover := 0 ;
      l_pay_to_adjust := 0 ;

      --  now loop through the absence records in reverse order
      --  the first records will be those contributing to the carryover
      --  so they can be ignored.  The ones after the those contributing to the
      --  carryover will contribute to the leave we need to adjust now (after
      --  the leave we need to adjust now will come the leave we have
      --  previously adjusted.  A single leave record may span the borders
      --  between the carryover and the leave to adjust now, and/or the border
      --  between the in advance leave and the leave previously adjusted.

      open c_leave_in_advance(l_accrual_plan_id
                             ,p_assignment_id
                             ,p_year_end_date) ;

      loop

        fetch c_leave_in_advance
          into l_absence_hours
          ,    l_absence_pay ;
        if c_leave_in_advance%notfound
        then
          close c_leave_in_advance ;
          raise e_missing_leave_in_advance ;
        end if ;

        l_hours_running_total := l_hours_running_total + l_absence_hours ;
        l_pay_running_total := l_pay_running_total + l_absence_pay ;

        hr_utility.trace('  l_absence_hours: ' || to_char(l_absence_hours)) ;
        hr_utility.trace('  l_absence_pay: ' || to_char(l_absence_pay)) ;

        --  test to see if we've past the records that are in the carryover
        if l_hours_running_total > l_in_advance_hours_carryover
        then

          --  test to see if this is the first record to be included in the
          --  adjustment
          if l_prev_hours_running_total < l_in_advance_hours_carryover
          then

            --  test to see if this is also the last record to be included in
            --  this adjustment
            if l_hours_running_total >= l_annual_leave_in_advance_hrs
            then

              hr_utility.trace('  processing first and last absence record to adjust') ;

              --  first and last record: work out how much of this absence
              --  record should be included in this adjustment

              l_hours := (l_hours_running_total - l_in_advance_hours_carryover)
                         - (l_hours_running_total - l_annual_leave_in_advance_hrs) ;

              l_pay := (l_hours / l_absence_hours) * l_absence_pay ;

              hr_utility.trace('  l_hours: ' || to_char(l_hours)) ;
              hr_utility.trace('  l_pay: ' || to_char(l_pay)) ;

              l_pay_to_adjust := l_pay_to_adjust + l_pay ;

              --  exit from loop
              exit ;

            else

              hr_utility.trace('  processing first record to adjust') ;

              --  first record only: work out how much of this absence record
              --  should be included in this adjustment

              l_hours := l_hours_running_total - l_in_advance_hours_carryover ;
              l_pay := (l_hours / l_absence_hours) * l_absence_pay ;

              hr_utility.trace('  l_hours: ' || to_char(l_hours)) ;
              hr_utility.trace('  l_pay: ' || to_char(l_pay)) ;

              l_pay_to_adjust := l_pay_to_adjust + l_pay ;

            end if ;

          --  test to see if this is the last record to be included in the
          --  adjustment
          elsif l_hours_running_total >= l_annual_leave_in_advance_hrs
          then

            hr_utility.trace('  processing last record to adjust') ;

            l_hours := l_absence_hours - (l_hours_running_total - l_annual_leave_in_advance_hrs) ;
            l_pay := (l_hours / l_absence_hours) * l_absence_pay ;

            hr_utility.trace('  l_hours: ' || to_char(l_hours)) ;
            hr_utility.trace('  l_pay: ' || to_char(l_pay)) ;

            l_pay_to_adjust := l_pay_to_adjust + l_pay ;

            --  exit from loop
            exit ;

          --  otherwise this is a record between the first and last to be
          --  included in the adjustment
          else

            hr_utility.trace('  processing middle in advance absence record to adjust') ;

            --  add all of the value of this absence
            l_pay_to_adjust := l_pay_to_adjust + l_absence_pay ;

          end if ;

        end if ;

        l_prev_hours_running_total := l_hours_running_total ;
        l_prev_pay_running_total := l_pay_running_total ;

      end loop ;

      close c_leave_in_advance ;

      l_in_advance_pay_carryover := l_annual_leave_in_advance_pay - l_pay_to_adjust ;

    end if ;  --  if l_annual_leave_in_advance_hrs <= l_accrual

    --  We now know how many hours (l_hours_to_adjust) and how much pay
    --  (l_pay_to_adjust) this year.

    hr_utility.trace('  l_hours_to_adjust: ' || to_char(l_hours_to_adjust)) ;
    hr_utility.trace('  l_pay_to_adjust: ' || to_char(l_pay_to_adjust)) ;

    --  get the ID of the Gross Earnings for Holiday Pay balance
    open c_balance_type('Gross Earnings for Holiday Pay') ;
    fetch c_balance_type
      into l_balance_type_id ;
    if c_balance_type%notfound
    then
      close c_balance_type ;
      raise e_missing_balance_type ;
    end if ;
    close c_balance_type ;

    l_gross_earnings_for_hol_pay := hr_nzbal.calc_asg_hol_ytd_date
                                    (p_assignment_id
                                    ,l_balance_type_id
                                    ,p_year_end_date) ;

    hr_utility.trace('  l_gross_earnings_for_hol_pay: ' || to_char(l_gross_earnings_for_hol_pay)) ;

    --  Get number of eligible weeks in year (complete weeks of special and
    --  protected voluntary service leave are subtracted from the number of
    --  weeks in the year.
    l_num_weeks := num_weeks_for_avg_earnings
                   (p_assignment_id
                   ,add_months(p_year_end_date + 1, -12)) ;

    hr_utility.trace('  l_num_weeks: ' || to_char(l_num_weeks)) ;

       open get_pay_period_start_date(p_assignment_id);
       fetch get_pay_period_start_date into l_pay_period_start_date,l_num_of_pay_periods_per_year;
       close get_pay_period_start_date;

     /* following check is to find whether holiday anniversary date lies in betw
een the pay
        period  and if so, find the number of weeks in the pay period */
if(to_char((p_year_end_date+1),'dd')<> to_char(l_pay_period_start_date,'
dd'))
       then
         l_extra_weeks := 52/l_num_of_pay_periods_per_year;
         l_offset_flag := true;
       end if;

 /* if holiday anniversary is inbetween the pay period add the extra pay p
eriod weeks */
        if l_offset_flag then
          l_num_weeks:= l_num_weeks + l_extra_weeks;
        end if;
    --  work out the value of the advance leave at the average earnings rate
    l_recalculated_pay := ((l_gross_earnings_for_hol_pay / l_num_weeks)
                           / p_asg_hours)
                          * l_hours_to_adjust ;

    hr_utility.trace('  l_recalculated_pay: ' || to_char(l_recalculated_pay)) ;
    hr_utility.trace(' Pay_to_adjust= '||l_pay_to_adjust);
    --  work out the adjustment (cannot be negative)
    l_eoy_adjustment := l_recalculated_pay - l_pay_to_adjust ;
    /*Bug 2950172 - Removed greatest(...) logic so as to return negative value
                  to the formula. The negative value is handled in the formula.*/

    --  set outputs
    p_in_advance_pay_carryover := l_in_advance_pay_carryover ;
    p_in_advance_hours_carryover := l_in_advance_hours_carryover ;

    --  trace output variables
    hr_utility.trace('  p_in_advance_pay_carryover: ' || to_char(p_in_advance_pay_carryover)) ;
    hr_utility.trace('  p_in_advance_hours_carryover: ' || to_char(p_in_advance_hours_carryover)) ;
    hr_utility.trace('  return: ' || to_char(l_eoy_adjustment)) ;

    return l_eoy_adjustment ;

  exception
    when e_missing_balance_type
    then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
      hr_utility.set_message_token('PROCEDURE', l_procedure_name) ;
      hr_utility.set_message_token('STEP', 'Missing Balance Type Exception') ;
      hr_utility.raise_error ;

    when e_missing_accrual_plan
    then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
      hr_utility.set_message_token('PROCEDURE', l_procedure_name) ;
      hr_utility.set_message_token('STEP', 'Missing Accrual Plan Exception') ;
      hr_utility.raise_error ;

    when e_missing_leave_in_advance
    then
      hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
      hr_utility.set_message_token('PROCEDURE', l_procedure_name) ;
      hr_utility.set_message_token('STEP', 'Missing Leave in Advance Exception') ;
      hr_utility.raise_error ;

  end annual_leave_eoy_adjustment ;

  /*---------------------------------------------------------------------
              Name    : get_weekdays_in_period
              Purpose : To get the number of weekdays in a date range
              Returns : Number of Weekdays if successful, NULL otherwise
    ---------------------------------------------------------------------*/

FUNCTION get_weekdays_in_period
    (p_start_date          IN DATE
    ,p_end_date            IN DATE)
RETURN NUMBER IS
    l_proc      VARCHAR2(72) := g_package||'get_weekdays_in_period';
    l_day_count NUMBER := 0;
    l_day       DATE;
  BEGIN

    hr_utility.trace('In: '||l_proc);
    hr_utility.trace('  p_start_date: ' || to_char(p_start_date,'dd Mon yyyy')) ;
    hr_utility.trace('  p_end_date: ' || to_char(p_end_date,'dd Mon yyyy')) ;

    IF (p_start_date > p_end_date)
    THEN
        hr_utility.trace('Crash Out: '||l_proc);
        hr_utility.set_message(801,'HR_NZ_INVALID_DATE_RANGE');
        hr_utility.raise_error;
    END IF;

    hr_utility.set_location(l_proc,5);
    l_day := p_start_date;
    WHILE (l_day <= p_end_date)
    LOOP
        IF (TO_CHAR(l_day,'DY') IN ('MON','TUE','WED','THU','FRI'))
        THEN
            l_day_count := l_day_count + 1;
        END IF;
        l_day := l_day + 1;
    END LOOP;
    hr_utility.trace('  return: ' || to_char(l_day_count)) ;
    hr_utility.trace('Out: '||l_proc);
    RETURN l_day_count;

  END get_weekdays_in_period;

-- Bug# 2127114 Added the following function
  --------------------------------------------------------------------
  -- get_leap_year_mon function
  -- function called by accrual_daily_basis function
  -- This function finds whether 29-feb of leap year present between
  -- the calculation period and if it is present ignores it
  --------------------------------------------------------------------
  function get_leap_year_mon
  (p_start_date      in   date
  ,p_end_date        in   date)
   return number is

   l_date          date;
   l_curr_year     varchar2(4);

   begin
     l_curr_year := to_char(p_start_date,'YYYY');
     if to_number(l_curr_year)/4 = trunc(to_number(l_curr_year)/4)
     then
       l_date := to_date('29-02'||to_char(p_start_date,'YYYY'),'DD-MM-YYYY');

       if l_date between p_start_date and p_end_date
       then
         return 1;
       else
         return 0;
       end if;
     else
       return 0;
     end if;

   end get_leap_year_mon;

/* end of function */


  -----------------------------------------------------------------------------
  --  ====================================
  --  3064179
  --  This function becomes on 01-APR-2004
  --  ====================================

  --  accrual_period_basis function
  --
  --  public function called by NZ_STAT_ANNUAL_LEAVE_ACCRUAL_PERIOD_BASIS
  --  PTO accrual formula.
  -----------------------------------------------------------------------------

  function accrual_period_basis
  (p_payroll_id                   in      number
  ,p_accrual_plan_id              in      number
  ,p_assignment_id                in      number
  ,p_calculation_start_date       in      date
  ,p_calculation_end_date         in      date
  ,p_service_start_date           in      date
  ,p_business_group_hours         in      number
  ,p_business_group_freq          in      varchar2)
  return number is

    l_procedure_name                varchar2(61) := 'hr_nz_holidays.accrual_period_basis' ;
    l_accrual                       number := 0 ;
    l_accrual_band_cache            t_accrual_band_tab ;
    l_asg_work_day_info_cache       t_asg_work_day_info_tab ;
    l_counter                       integer ;
    l_years_service                 number ;
    l_annual_accrual                number ;
    l_days_in_whole_period          integer ;
    l_days_in_part_period           integer ;
    l_start_date                    date ;
    l_end_date                      date ;
    l_period_accrual                number ;
    l_asg_working_hours             per_all_assignments_f.normal_hours%type ;
    l_pay_periods_per_year          per_time_period_types.number_per_fiscal_year%type ;

    e_accrual_function_failure      exception ;

    --  cursor to get number of periods per year

    cursor c_number_of_periods_per_year (p_payroll_id number
                                        ,p_effective_date date) is
      select tpt.number_per_fiscal_year
      from   pay_payrolls_f p
      ,      per_time_period_types tpt
      where  p.payroll_id = p_payroll_id
      and    p_effective_date between p.effective_start_date
                                  and p.effective_end_date
      and    tpt.period_type = p.period_type ;

    --  cursor to get assignment work day information

    cursor c_asg_work_day_history(p_assignment_id   number
                                 ,p_start_date      date
                                 ,p_end_date        date) is
      select a.effective_start_date
      ,      a.effective_end_date
      ,      a.normal_hours
      ,      a.frequency
      from   per_assignments_f a
      where  a.assignment_id = p_assignment_id
      and    a.effective_start_date <= p_end_date
      and    a.effective_end_date >= p_start_date
      order by
             a.effective_start_date ;

    --  cursor to get accrual band details

    cursor c_accrual_bands (p_accrual_plan_id number) is
      select ab.lower_limit
      ,      ab.upper_limit
      ,      ab.annual_rate
      from   pay_accrual_bands ab
      where  ab.accrual_plan_id = p_accrual_plan_id
      order by
             ab.lower_limit ;

    --  cursor to get time periods to process

    cursor c_periods (p_payroll_id number
                     ,p_start_date date
                     ,p_end_date date) is
      select tp.start_date
      ,      tp.end_date
      from   per_time_periods tp
      where  tp.payroll_id = p_payroll_id
      and    tp.start_date <= p_end_date
      and    tp.end_date >= p_start_date
      order by
             tp.start_date ;

    --  local function to get accrual annual rate from PL/SQL table

    function accrual_annual_rate(p_years_service number) return number is

      l_procedure_name                varchar2(61) := 'accrual_annual_rate' ;
      l_annual_accrual                pay_accrual_bands.annual_rate%type ;
      l_counter                       integer := 1 ;
      l_band_notfound_flag            boolean := true ;

    begin

      --  hr_utility.trace('  In: ' || l_procedure_name) ;

      --  loop through the PL/SQL table looking for a likely accrual band
      while l_accrual_band_cache.count > 0
        and l_band_notfound_flag
        and l_counter <= l_accrual_band_cache.last
      loop

        --  JTurner, 14 Feb 2000, 1189790: changed from using "between"
        if p_years_service >= l_accrual_band_cache(l_counter).lower_limit
          and p_years_service < l_accrual_band_cache(l_counter).upper_limit
        then

          l_annual_accrual := l_accrual_band_cache(l_counter).annual_rate ;
          l_band_notfound_flag := false ;

        end if ;

        l_counter := l_counter + 1 ;

      end loop ;

      --  raise error if no accrual band found
      if l_band_notfound_flag
      then

        raise e_accrual_function_failure ;

      end if ;

      --  hr_utility.trace('  Out: ' || l_procedure_name) ;
      return l_annual_accrual ;

    end accrual_annual_rate ;

    --  local function to get asg working hours from PL/SQL table

    function asg_working_hours(p_effective_date date
                              ,p_frequency varchar2) return number is

      l_procedure_name                varchar2(61) := 'asg_working_hours' ;
      l_asg_working_hours             per_all_assignments_f.normal_hours%type ;
      l_counter                       integer := 1 ;
      l_hours_notfound_flag           boolean := true ;

    begin

      --  hr_utility.trace('  In: ' || l_procedure_name) ;

      --  loop through the PL/SQL table looking for a likely accrual band
      while l_asg_work_day_info_cache.count > 0
        and l_hours_notfound_flag
        and l_counter <= l_asg_work_day_info_cache.last
      loop

        if p_effective_date between l_asg_work_day_info_cache(l_counter).effective_start_date
                                and l_asg_work_day_info_cache(l_counter).effective_end_date
          and l_asg_work_day_info_cache(l_counter).frequency = p_frequency
        then

          l_asg_working_hours := l_asg_work_day_info_cache(l_counter).normal_hours ;
          l_hours_notfound_flag := false ;

        end if ;

        l_counter := l_counter + 1 ;

      end loop ;

      --  raise error if no working hours found
      if l_hours_notfound_flag
      then

        raise e_accrual_function_failure ;

      end if ;

      --  hr_utility.trace('  Out: ' || l_procedure_name) ;
      return l_asg_working_hours ;

    end asg_working_hours ;

  begin

    hr_utility.trace('In: ' || l_procedure_name) ;
    hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
    hr_utility.trace('  p_accrual_plan_id: ' || to_char(p_accrual_plan_id)) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_calculation_start_date: ' || to_char(p_calculation_start_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_calculation_end_date: ' || to_char(p_calculation_end_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_service_start_date: ' || to_char(p_service_start_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_business_group_hours: ' || to_char(p_business_group_hours)) ;
    hr_utility.trace('  p_business_group_freq: ' || p_business_group_freq) ;

    --  cache the assignment's work day history
    l_counter := 1 ;

    for r_asg_work_day in c_asg_work_day_history(p_assignment_id
                                                ,p_calculation_start_date
                                                ,p_calculation_end_date)
    loop

      l_asg_work_day_info_cache(l_counter).effective_start_date := r_asg_work_day.effective_start_date ;
      l_asg_work_day_info_cache(l_counter).effective_end_date := r_asg_work_day.effective_end_date ;
      l_asg_work_day_info_cache(l_counter).normal_hours := r_asg_work_day.normal_hours ;
      l_asg_work_day_info_cache(l_counter).frequency := r_asg_work_day.frequency ;

      l_counter := l_counter + 1 ;

    end loop ;  --  c_asg_work_day_history

    --  cache the accrual bands
    l_counter := 1 ;

    for r_accrual_band in c_accrual_bands(p_accrual_plan_id)
    loop

      l_accrual_band_cache(l_counter).lower_limit := r_accrual_band.lower_limit ;
      l_accrual_band_cache(l_counter).upper_limit := r_accrual_band.upper_limit ;
      l_accrual_band_cache(l_counter).annual_rate := r_accrual_band.annual_rate ;

      l_counter := l_counter + 1 ;

    end loop ;  --  c_accrual_bands

    --  get the number of periods per year
    open c_number_of_periods_per_year(p_payroll_id, p_calculation_start_date) ;
    fetch c_number_of_periods_per_year
      into l_pay_periods_per_year ;
    close c_number_of_periods_per_year ;

    --  loop through the payroll periods
    for r_period in c_periods(p_payroll_id
                             ,p_calculation_start_date
                             ,p_calculation_end_date)
    loop

      --  how many years of service does the assignment have (as at the end of the period)
      l_years_service := floor(months_between(r_period.end_date, p_service_start_date) / 12) ;

      --  get the accrual band
      l_annual_accrual := accrual_annual_rate(l_years_service) ;

      --  get the assignment's normal working hours
     --  JTurner, 21 Mar 2000, 1243407: changed to use least of period end
     --    and calculation end date instead of just period end date.
      l_asg_working_hours := asg_working_hours(least(r_period.end_date
                                          ,p_calculation_end_date)
                                     ,p_business_group_freq) ;
      --  the accrual rate in the accrual band is for assignments that work the
      --  business group's default working hours.  Now prorate the accrual rate
      --  based on the proporation of the business group hours that the
      --  assignment works.
      l_annual_accrual := l_annual_accrual * (l_asg_working_hours / p_business_group_hours) ;

      l_period_accrual := l_annual_accrual / l_pay_periods_per_year ;

      --  how many days are there in the whole period?
      l_days_in_whole_period := (r_period.end_date - r_period.start_date) + 1 ;

      --  we may be dealing with a part period here, ie if the calculation
      --  start date is part way through the first period or if the
      --  calculation end date is part way through the last period.
      if p_calculation_start_date between r_period.start_date
                                      and r_period.end_date
      then
        l_start_date := p_calculation_start_date ;
      else
        l_start_date := r_period.start_date ;
      end if ;

      if p_calculation_end_date between r_period.start_date
                                    and r_period.end_date
      then
        l_end_date := p_calculation_end_date ;
      else
        l_end_date := r_period.end_date ;
      end if ;

      --  how many days are there in the part period?  (Note it may not
      --  actually be a part period).
      l_days_in_part_period := (l_end_date - l_start_date) + 1 ;

      --  prorate the period accrual
      l_period_accrual := l_period_accrual * (l_days_in_part_period / l_days_in_whole_period) ;

      l_accrual := l_accrual + l_period_accrual ;

    end loop ;  --  c_periods

    hr_utility.trace('  return: ' || to_char(l_accrual)) ;
    hr_utility.trace('Out: ' || l_procedure_name) ;
    return l_accrual ;

  exception
    when e_accrual_function_failure
    then
      hr_utility.trace('Crash Out: ' || l_procedure_name) ;
      hr_utility.set_message(801, 'HR_NZ_ACCRUAL_FUNCTION_FAILURE') ;
      hr_utility.raise_error ;

  end accrual_period_basis ;

  -----------------------------------------------------------------------------
  --  ====================================
  --  3064179
  --  This function becomes on 01-APR-2004
  --  ====================================

  --  accrual_daily_basis function
  --
  --  public function called by NZ_STAT_ANNUAL_LEAVE_ACCRUAL_DAILY_BASIS
  --  PTO accrual formula.
  -----------------------------------------------------------------------------

  function accrual_daily_basis
  (p_payroll_id                   in      number
  ,p_accrual_plan_id              in      number
  ,p_assignment_id                in      number
  ,p_calculation_start_date       in      date
  ,p_calculation_end_date         in      date
  ,p_service_start_date           in      date
  ,p_anniversary_date             in      date
  ,p_business_group_hours         in      number
  ,p_business_group_freq          in      varchar2)
  return number is

    l_procedure_name                varchar2(61) := 'hr_nz_holidays.accrual_daily_basis' ;
    l_accrual                       number := 0 ;
    l_accrual_band_cache            t_accrual_band_tab ;
    l_asg_work_day_info_cache       t_asg_work_day_info_tab ;
    l_counter                       integer ;
    l_years_service                 number ;
    l_annual_accrual                number ;
    l_days_in_year                  integer ;
    l_days_in_part_period           integer ;
    l_next_anniversary_date         date ;
    l_start_date                    date ;
    l_end_date                      date ;
    l_period_accrual                number ;
    l_asg_working_hours             per_all_assignments_f.normal_hours%type ;
    l_pay_periods_per_year          per_time_period_types.number_per_fiscal_year%type ;
    l_calc_service_date             date;
    l_annual_accrual_1              number;
    l_annual_accrual_2              number;
    l_asg_working_hours_1           per_all_assignments_f.normal_hours%type;
    l_asg_working_hours_2           per_all_assignments_f.normal_hours%type;
    l_days_in_part_period_1         integer;
    l_days_in_part_period_2         integer;
    l_counter_1                     integer;
    l_counter_2                     integer;
    l_counter_3                     integer;
    l_least_date                    date;
    l_check_flag                    boolean;
    e_accrual_function_failure      exception ;
    --  cursor to get number of periods per year

    cursor c_number_of_periods_per_year (p_payroll_id number
                                        ,p_effective_date date) is
      select tpt.number_per_fiscal_year
      from   pay_payrolls_f p
      ,      per_time_period_types tpt
      where  p.payroll_id = p_payroll_id
      and    p_effective_date between p.effective_start_date
                                  and p.effective_end_date
      and    tpt.period_type = p.period_type ;

    --  cursor to get assignment work day information

    cursor c_asg_work_day_history(p_assignment_id   number
                                 ,p_start_date      date
                                 ,p_end_date        date) is
      select a.effective_start_date
      ,      a.effective_end_date
      ,      a.normal_hours
      ,      a.frequency
      from   per_assignments_f a
      where  a.assignment_id = p_assignment_id
      and    a.effective_start_date <= p_end_date
      and    a.effective_end_date >= p_start_date
      order by
             a.effective_start_date ;

    --  cursor to get accrual band details

    cursor c_accrual_bands (p_accrual_plan_id number) is
      select ab.lower_limit
      ,      ab.upper_limit
      ,      ab.annual_rate
      from   pay_accrual_bands ab
      where  ab.accrual_plan_id = p_accrual_plan_id
      order by
             ab.lower_limit ;

    --  cursor to get time periods to process

    cursor c_periods (p_payroll_id number
                     ,p_start_date date
                     ,p_end_date date) is
      select tp.start_date
      ,      tp.end_date
      from   per_time_periods tp
      where  tp.payroll_id = p_payroll_id
      and    tp.start_date <= p_end_date
      and    tp.end_date >= p_start_date
      order by
             tp.start_date ;

    --  local function to get accrual annual rate from PL/SQL table

    function accrual_annual_rate(p_years_service number) return number is

      l_procedure_name                varchar2(61) := 'accrual_annual_rate' ;
      l_annual_accrual                pay_accrual_bands.annual_rate%type ;
      l_counter                       integer := 1 ;
      l_band_notfound_flag            boolean := true ;

    begin

       hr_utility.trace('acc_band_cache_ct '||l_accrual_band_cache.count);
        hr_utility.trace('l_counter '||l_counter);
        hr_utility.trace('l_accrual_band_cache.last '||l_accrual_band_cache.last);

      --  hr_utility.trace('  In: ' || l_procedure_name) ;

      --  loop through the PL/SQL table looking for a likely accrual band
      while l_accrual_band_cache.count > 0
        and l_band_notfound_flag
        and l_counter <= l_accrual_band_cache.last
      loop

        --  JTurner, 14 Feb 2000, 1189790: changed from using "between"
        if p_years_service >= l_accrual_band_cache(l_counter).lower_limit
          and p_years_service < l_accrual_band_cache(l_counter).upper_limit
        then

          l_annual_accrual := l_accrual_band_cache(l_counter).annual_rate ;
          l_band_notfound_flag := false ;

        end if ;

        l_counter := l_counter + 1 ;

      end loop ;

      --  raise error if no accrual band found
      if l_band_notfound_flag
      then

        raise e_accrual_function_failure ;

      end if ;

      --  hr_utility.trace('  Out: ' || l_procedure_name) ;
      return l_annual_accrual ;

    end accrual_annual_rate ;

    --  local function to get asg working hours from PL/SQL table

    function asg_working_hours(p_effective_date date
                              ,p_frequency varchar2) return number is

      l_procedure_name                varchar2(61) := 'asg_working_hours' ;
      l_asg_working_hours             per_all_assignments_f.normal_hours%type ;
      l_counter                       integer := 1 ;
      l_hours_notfound_flag           boolean := true ;

    begin

      --  hr_utility.trace('  In: ' || l_procedure_name) ;

      --  loop through the PL/SQL table looking for a likely accrual band
      while l_asg_work_day_info_cache.count > 0
        and l_hours_notfound_flag
        and l_counter <= l_asg_work_day_info_cache.last
      loop

        if p_effective_date between l_asg_work_day_info_cache(l_counter).effective_start_date
                                and l_asg_work_day_info_cache(l_counter).effective_end_date
          and l_asg_work_day_info_cache(l_counter).frequency = p_frequency
        then

          l_asg_working_hours := l_asg_work_day_info_cache(l_counter).normal_hours ;
          l_hours_notfound_flag := false ;

        end if ;

        l_counter := l_counter + 1 ;

      end loop ;

      --  raise error if no working hours found
      if l_hours_notfound_flag
      then

        raise e_accrual_function_failure ;

      end if ;

      --  hr_utility.trace('  Out: ' || l_procedure_name) ;
      return l_asg_working_hours ;

    end asg_working_hours ;

  begin
    hr_utility.trace('fun_enetered_ven');
    hr_utility.trace('In: ' || l_procedure_name) ;
    hr_utility.trace('  p_payroll_id: ' || to_char(p_payroll_id)) ;
    hr_utility.trace('  p_accrual_plan_id: ' || to_char(p_accrual_plan_id)) ;
    hr_utility.trace('  p_assignment_id: ' || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_calculation_start_date: ' || to_char(p_calculation_start_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_calculation_end_date: ' || to_char(p_calculation_end_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_service_start_date: ' || to_char(p_service_start_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_anniversary_date: ' || to_char(p_anniversary_date, 'dd-Mon-yyyy')) ;
    hr_utility.trace('  p_business_group_hours: ' || to_char(p_business_group_hours)) ;
    hr_utility.trace('  p_business_group_freq: ' || p_business_group_freq) ;

    --  cache the assignment's work day history
    l_counter := 1 ;
    l_check_flag := false;

    for r_asg_work_day in c_asg_work_day_history(p_assignment_id
                                                ,p_calculation_start_date
                                                ,p_calculation_end_date)
    loop

      l_asg_work_day_info_cache(l_counter).effective_start_date := r_asg_work_day.effective_start_date ;
      l_asg_work_day_info_cache(l_counter).effective_end_date := r_asg_work_day.effective_end_date ;
      l_asg_work_day_info_cache(l_counter).normal_hours := r_asg_work_day.normal_hours ;
      l_asg_work_day_info_cache(l_counter).frequency := r_asg_work_day.frequency ;

      l_counter := l_counter + 1 ;

    end loop ;  --  c_asg_work_day_history
    --  cache the accrual bands
    l_counter := 1 ;

    for r_accrual_band in c_accrual_bands(p_accrual_plan_id)
    loop

      l_accrual_band_cache(l_counter).lower_limit := r_accrual_band.lower_limit ;
      l_accrual_band_cache(l_counter).upper_limit := r_accrual_band.upper_limit ;
      l_accrual_band_cache(l_counter).annual_rate := r_accrual_band.annual_rate ;

      l_counter := l_counter + 1 ;

    end loop ;  --  c_accrual_bands

    --  get the number of periods per year
    open c_number_of_periods_per_year(p_payroll_id, p_calculation_start_date) ;
    fetch c_number_of_periods_per_year
      into l_pay_periods_per_year ;
    close c_number_of_periods_per_year ;

    --  loop through the payroll periods
    for r_period in c_periods(p_payroll_id
                             ,p_calculation_start_date
                             ,p_calculation_end_date)
loop

      --  how many years of service does the assignment have (as at the end of the period)
      hr_utility.trace('---------------------------------------------------------------------');

--   Bug# 2072748 -- added the following code
   -- calculation of accruals is upto the calculation end date, hence for each
   -- period calculation start date and calculation end date are compared with
   -- the period start date and period end date
   if p_calculation_start_date between r_period.start_date and r_period.end_date
   then
     l_start_date := p_calculation_start_date;
   else
     l_start_date := r_period.start_date;
   end if;

   if p_calculation_end_date between r_period.start_date and r_period.end_date
   then
     l_end_date := p_calculation_end_date;
   else
     l_end_date := r_period.end_date;
   end if;

   l_asg_working_hours := asg_working_hours(least(r_period.end_date
                                          ,p_calculation_end_date)
                                     ,p_business_group_freq) ;

   --  if calcualtion end date is less then the period end date

   l_least_date := least(r_period.end_date,p_calculation_end_date);
   l_days_in_year := 365;

   -- if continous service date falls in the pay period then accrual band should
   -- be incremented on that date, if continous service date is not present then
   -- service start date is used
   l_calc_service_date := to_date(to_char(l_start_date,'YYYY') || to_char(p_service_start_date,'MMDD'),'YYYYMMDD');

   if l_calc_service_date between l_start_date and l_end_date
   then
     if l_calc_service_date=p_service_start_date
     then  l_years_service:=0;
     else
--  accrual before the l_next_service_date
     l_years_service := floor(months_between(l_calc_service_date-1,p_service_start_date)/12);
     end if;
     l_annual_accrual_1 := accrual_annual_rate(l_years_service);
     l_days_in_part_period := ((l_calc_service_date)-l_start_date);

-- Bug# 2033033 added the logic to handle assigment working hours change
--* If assignment working hours change then take the part period upto the change as one
--* period and the remaining as another period and calculate accruals seperately with
--* different assignment working hours
--* The same logic is repeated when continious service date happens between the calculation
--* period and accrual band is incremented.

    if (l_asg_work_day_info_cache.count>1)
    then
      for  l_counter_2 in 1..l_asg_work_day_info_cache.count
      loop
        if (l_asg_work_day_info_cache(l_counter_2).effective_end_date between r_period.start_date and l_calc_service_date-1)
        then
          l_asg_working_hours_1 := asg_working_hours(l_asg_work_day_info_cache(l_counter_2).effective_end_date,p_business_group_freq);

          l_asg_working_hours_2 := asg_working_hours(l_calc_service_date-1,p_business_group_freq);

          l_days_in_part_period_1 := l_asg_work_day_info_cache(l_counter_2).effective_end_date - r_period.start_date+1;

-- Bug# 2127114
--** This code subtracts the extra day of the leap year

          l_days_in_part_period_1 := l_days_in_part_period_1 - get_leap_year_mon(r_period.start_date, l_asg_work_day_info_cache(l_counter_2).effective_end_date);

          l_days_in_part_period_2 := l_days_in_part_period - l_days_in_part_period_1;

          l_days_in_part_period_2 := l_days_in_part_period_2 - get_leap_year_mon( l_asg_work_day_info_cache(l_counter_2).effective_end_date+1,l_calc_service_date);

          l_period_accrual:= l_annual_accrual_1 * ((l_asg_working_hours_1*l_days_in_part_period_1) + (l_asg_working_hours_2*l_days_in_part_period_2))/(l_days_in_year * p_business_group_hours);

          l_check_flag:=false;
          exit;
        else
          l_check_flag:=true;
        end if;
     end loop;
  else
     l_check_flag:=true;
  end if;

     if l_check_flag
     then
       l_annual_accrual_1 := l_annual_accrual_1 * (l_asg_working_hours/p_business_group_hours);

       l_days_in_part_period := l_days_in_part_period - get_leap_year_mon(l_start_date,l_calc_service_date);
       l_period_accrual := (l_annual_accrual_1/l_days_in_year)*l_days_in_part_period;
    end if;



    l_years_service := floor(months_between(l_end_date,p_service_start_date)/12);

    l_annual_accrual_2 := accrual_annual_rate(l_years_service);

    l_days_in_part_period := (l_end_date-l_calc_service_date)+1;

    if (l_asg_work_day_info_cache.count>1)
    then
      for l_counter_3 in 1..l_asg_work_day_info_cache.count
      loop
        if (l_asg_work_day_info_cache(l_counter_3).effective_end_date between l_calc_service_date and l_least_date)
        then
          l_asg_working_hours_1 := asg_working_hours(l_asg_work_day_info_cache(l_counter_3).effective_end_date,p_business_group_freq);

          l_asg_working_hours_2 := asg_working_hours(l_least_date,p_business_group_freq);

          l_days_in_part_period_1 := l_asg_work_day_info_cache(l_counter_3).effective_end_date - l_calc_service_date+1;

          l_days_in_part_period_1 := l_days_in_part_period_1 - get_leap_year_mon(l_calc_service_date+1,l_asg_work_day_info_cache(l_counter_3).effective_end_date);


          l_days_in_part_period_2 := l_days_in_part_period - l_days_in_part_period_1;

          l_days_in_part_period_2 := l_days_in_part_period_2 - get_leap_year_mon(l_asg_work_day_info_cache(l_counter_3).effective_end_date+1,l_end_date);

          l_period_accrual := l_period_accrual+(l_annual_accrual_2 * ((l_asg_working_hours_1*l_days_in_part_period_1) + (l_asg_working_hours_2*l_days_in_part_period_2))/(l_days_in_year*p_business_group_hours));

          l_check_flag:=false;
          exit;
        else
          l_check_flag:=true;
        end if;
      end loop;
    else
      l_check_flag:=true;
    end if;
-- accrual after the l_next_service_date
    if l_check_flag
    then
       l_annual_accrual_2 := l_annual_accrual_2 * (l_asg_working_hours/p_business_group_hours);
       l_days_in_part_period := l_days_in_part_period - get_leap_year_mon(l_calc_service_date+1,l_end_date);

       l_period_accrual := l_period_accrual+(l_annual_accrual_2/l_days_in_year)*l_days_in_part_period;

    end if;
-- if the continous service date does not fall between the calculation period
 else
   l_years_service := floor(months_between(l_end_date, p_service_start_date) / 12) ;

      --  get the accrual band
   l_annual_accrual := accrual_annual_rate(l_years_service) ;
   l_days_in_part_period := (l_end_date-l_start_date)+1;

-- Bug# 2033033 included the logic for assignment working hours change

     if (l_asg_work_day_info_cache.count>1)
     then
       for l_counter_1 in 1..l_asg_work_day_info_cache.count
       loop
         if (l_asg_work_day_info_cache(l_counter_1).effective_end_date between r_period.start_date and l_least_date)
         then
           l_asg_working_hours_1 := asg_working_hours(l_asg_work_day_info_cache(l_counter_1).effective_end_date,p_business_group_freq);

           l_asg_working_hours_2 := asg_working_hours(l_least_date,p_business_group_freq);

           l_days_in_part_period_1 := l_asg_work_day_info_cache(l_counter_1).effective_end_date - r_period.start_date+1;

           l_days_in_part_period_1 := l_days_in_part_period_1 - get_leap_year_mon(r_period.start_date,l_asg_work_day_info_cache(l_counter_1).effective_end_date);


           l_days_in_part_period_2 := l_days_in_part_period - l_days_in_part_period_1;

           l_days_in_part_period_2 := l_days_in_part_period_2 - get_leap_year_mon(l_asg_work_day_info_cache(l_counter_1).effective_end_date+1,l_end_date);

           l_period_accrual := l_annual_accrual * ((l_asg_working_hours_1*l_days_in_part_period_1) + (l_asg_working_hours_2*l_days_in_part_period_2))/ (l_days_in_year * p_business_group_hours);

           l_check_flag:= false;
           exit;
         else
           l_check_flag:=true;
         end if;
       end loop;
    else
      l_check_flag:=true;
    end if;

    if l_check_flag
    then
      l_annual_accrual:= l_annual_accrual * (l_asg_working_hours/p_business_group_hours);

      l_days_in_part_period := l_days_in_part_period - get_leap_year_mon(l_start_date,l_end_date);

      l_period_accrual := (l_annual_accrual/l_days_in_year)*l_days_in_part_period;
    end if;
  end if;

    --  hr_utility.trace('l_annual_accrual     = '||to_char(l_annual_accrual));
      --
      --  the algorithm being used here is:
      --
      --  days to accrue for period
      --    = (annual entitlement / days in current holiday year)
      --        * days in period
      --

   --



      l_accrual := l_accrual + l_period_accrual ;
      --
    end loop ;  --  c_periods

    hr_utility.trace('  return: ' || to_char(l_accrual)) ;
    hr_utility.trace('Out: ' || l_procedure_name) ;
    return l_accrual ;

  exception
    when e_accrual_function_failure
    then
      hr_utility.trace('Crash Out: ' || l_procedure_name) ;
      hr_utility.set_message(801, 'HR_NZ_ACCRUAL_FUNCTION_FAILURE') ;
      hr_utility.raise_error ;

  end accrual_daily_basis ;


---------------------------------------------------------------
-- function to calculate average acrual rate (Bug 1422001)
---------------------------------------------------------------

function  average_accrual_rate(
              p_assignment_id    IN  per_all_assignments_f.assignment_id%type
             ,p_calculation_date IN  date
             ,p_anniversary_date IN  date
             ,p_asg_hours        IN  number ) return number is

 CURSOR  get_balance_id
  IS
 SELECT pbt.balance_type_id
 FROM   pay_balance_types  pbt
 WHERE  pbt.balance_name = 'Gross Earnings for Holiday Pay'
 AND    legislation_code = 'NZ'
 AND    business_group_id IS NULL;


 l_gross_earnings  NUMBER;
 l_avg_rate        NUMBER;
 l_balance_type_id pay_balance_types.balance_type_id%TYPE;
 l_num_of_weeks    NUMBER;
 l_year_end        DATE  ;

 BEGIN
   ---------------------------------------------
   -- this function returns  the average rate to
   -- value accrual hrs . In order to get the avg
   -- rate , it uses  the year end balance
   -- for - 'Gross Earnings for Holiday Pay' and
   -- the number of weeks in that year
   --
   -- used for leave liability process
   ---------------------------------------------

   l_year_end := to_date(to_char((p_anniversary_date-1),'DD-MM-')||to_char(p_calculation_date,'YYYY'),'DD-MM-YYYY');
   OPEN get_balance_id ;

   FETCH get_balance_id INTO l_balance_type_id;

   IF get_balance_id %NOTFOUND THEN
     hr_utility.set_location('balance -Gross Earnings for Holiday Pay- not found ',3);
   END IF;

   CLOSE get_balance_id ;

   l_gross_earnings := hr_nzbal.calc_asg_hol_ytd_date
                       (p_assignment_id   => p_assignment_id
                       ,p_balance_type_id => l_balance_type_id
                       ,p_effective_date  => l_year_end);
   hr_utility.trace('gross earnings :'||l_gross_earnings);
   hr_utility.trace('year end date  :'||l_year_end);

   l_num_of_weeks := hr_nz_holidays.num_weeks_for_avg_earnings
                    (p_assignment_id
                    ,add_months(l_year_end + 1, -12)) ;

   hr_utility.trace('num of weeks  :'||l_num_of_weeks);
   l_avg_rate := l_gross_Earnings/l_num_of_weeks/p_asg_hours;
   hr_utility.trace('Return   :'||l_avg_rate);
 RETURN l_avg_rate ;

 EXCEPTION
   WHEN OTHERS THEN
     hr_utility.set_location('Error in function -average_accrual_rate.  ',3);
     RAISE ;
 END average_accrual_rate;

/* Bug 2264070 This function returns the annual leave paid before
   retro process is exceuted.The pay value is fetched from run_result_values. */

Function get_act_ann_lev_pay(
   p_assignment_id  IN  number
 , p_element_entry_id IN  number
 , p_assgt_action_id IN number
 , p_effective_date  IN date)
return NUMBER is

l_ann_lev_pay  number;

 CURSOR c_act_ann_pay(p_assignment_id number, p_element_entry_id number, p_assgt_action_id number,p_effective_date date) IS
   select prv.result_value
   from pay_run_result_values prv
,     pay_run_results prr
,     pay_input_values_f piv
,     pay_element_types_f pet
,     pay_element_entries_f pee
   where pet.element_name = 'Annual Leave Pay'
   and  pet.legislation_code = 'NZ'
   and  pet.element_type_id = piv.element_type_id
   and  piv.name = 'Pay Value'
   and  prv.input_value_id = piv.input_value_id
   and  prr.run_result_id = prv.run_result_id
  and  pee.element_entry_id = p_element_entry_id
  AND  PRR.RUN_RESULT_ID = PEE.SOURCE_ID
  and  prr.assignment_action_id = p_assgt_action_id
  and  p_effective_date between piv.effective_start_date and piv.effective_end_date
  and  p_effective_date between pet.effective_start_date and pet.effective_end_date
  and  p_effective_date between pee.effective_start_date and pee.effective_end_date;


begin
open c_act_ann_pay(p_assignment_id,p_element_entry_id,p_assgt_action_id,p_effective_date);
 fetch c_act_ann_pay into l_ann_lev_pay;
 close c_act_ann_pay;
 return l_ann_lev_pay;

end get_act_ann_lev_pay;

/* Bug 2264070 This function returns the number of weeks which is used for
   calculation of average rate */

Function num_of_weeks_for_avg_earnings(
   p_assignment_id  IN  number
 , p_hol_ann_date   IN  date)
return NUMBER is

l_num_of_weeks                                number;
l_pay_period_start_date                     date;
l_num_of_pay_periods_per_year        number;
l_extra_weeks           number;

  cursor get_pay_period_start_date(p_assignment_id number) is
     SELECT TPERIOD.start_date,
            TPTYPE.number_per_fiscal_year
      FROM  pay_payroll_actions      PACTION,
            per_time_periods         TPERIOD,
            per_time_period_types    TPTYPE
     where  PACTION.payroll_action_id =
                              (select max(paa.payroll_action_id)
                                 from pay_assignment_actions paa,
                                      pay_payroll_actions ppa
                                where paa.assignment_id     = p_assignment_id
                                  and ppa.action_type       in ('R','Q')
                                  and ppa.payroll_action_id = paa.payroll_action_id)
       and  PACTION.payroll_id       = TPERIOD.payroll_id
       and  PACTION.date_earned      between TPERIOD.start_date and TPERIOD.end_date
       and  TPTYPE.period_type       = TPERIOD.period_type;

BEGIN

       open get_pay_period_start_date(p_assignment_id);
       fetch get_pay_period_start_date into l_pay_period_start_date,l_num_of_pay_periods_per_year;
       close get_pay_period_start_date;

       l_num_of_weeks := num_weeks_for_avg_earnings(
                                 p_assignment_id => p_assignment_id
                                ,p_start_of_year_date => ADD_MONTHS(p_hol_ann_date,-12));

   /* If the hol ann date  lies in between the pay period then add
      number of weeks in one extra pay period to the total number of weeks in a year */
   if (to_char(p_hol_ann_date,'dd') <> to_char( l_pay_period_start_date,'dd'))
   then
      l_extra_weeks := 52/l_num_of_pay_periods_per_year;
      l_num_of_weeks := l_num_of_weeks + l_extra_weeks ;

   end if;

   return l_num_of_weeks;

end num_of_weeks_for_avg_earnings;

/* Bug 2264070 The function returns 1 if action type of the current run is
L (Retro) else 0 */

FUNCTION get_current_action_type(p_payroll_id in number)
RETURN number IS

/* Bug 4259438 : Modified cursor as part of performance */
CURSOR c_get_curr_action_type(p_payroll_id NUMBER)
IS
   SELECT action_type
     FROM pay_payroll_actions ppa
         , pay_payrolls_f ppf
    WHERE ppf.payroll_id            = p_payroll_id
      AND ppa.payroll_id            = ppf.payroll_id
      AND ppa.business_group_id     = ppf.business_group_id
      AND (ppa.consolidation_set_id = ppf.consolidation_set_id
           OR ppa.consolidation_set_id IS NULL)
      AND ppa.action_type           LIKE '%'
      AND ppa.effective_date        BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    ORDER BY PAYROLL_ACTION_ID DESC;

-- Bug 2595888: Changed the datatype from varchar2(1) to pay_payroll_actions.action_type%type
l_action_type       pay_payroll_actions.action_type%type;

begin

 open c_get_curr_action_type(p_payroll_id);
 FETCH c_get_curr_action_type INTO l_action_type;
 close c_get_curr_action_type;

 hr_utility.trace('Action_type= '||l_action_type);
 if l_action_type = 'L' then
    return 1;
 else
    return 0;
 end if;

end get_current_action_type;

/* Bug 2264070 This function returns the retro period start date ,that is
   date earned +1 for the last payroll run executed before the retro process*/

FUNCTION retro_start_date
(p_assignment_id in  number)
RETURN date IS

/* Bug No - 2581490 */

-- cursor to give the effective_date of the retro pay process

 cursor c_get_values(p_assignment_id number) is
  select  max(ppa.effective_date)
         ,ppa.payroll_id
    from  pay_payroll_actions ppa
         ,pay_assignment_actions pac
   where  pac.assignment_id     = p_assignment_id
     and  pac.payroll_action_id = ppa.payroll_action_id
     and  ppa.action_type       = 'L'
     group by ppa.payroll_id ;

-- cursor to get the period start_date of the retro process pay period

 cursor c_retro_start_date(p_effective_date date,
                           p_payroll_id     number) is
  select  ptp.start_date
    from  per_time_periods ptp
     ,pay_all_payrolls_f pap
   where  pap.payroll_id = p_payroll_id
     and  ptp.payroll_id = pap.payroll_id
     and (p_effective_date - pap.PAY_DATE_OFFSET) between ptp.start_date and ptp.end_date;

 l_retro_start_date date;
 l_effective_date  date;
 l_payroll_id      number;

begin
 hr_utility.trace('Inside retro_start_date');

 open c_get_values(p_assignment_id);
 fetch c_get_values into l_effective_date ,l_payroll_id;
 close c_get_values;

 open c_retro_start_date(l_effective_date,l_payroll_id);
 fetch c_retro_start_date into l_retro_start_date ;
 close c_retro_start_date ;
 hr_utility.trace('Executed_retro_start_cursor value of date'|| to_char(l_retro_start_date,'DD-MON-YYYY'));
 return l_retro_start_date ;

end retro_start_date;


/* Bug 2264070 This function returns the gross earnings for the calculation
   of Average rate  */

FUNCTION gross_earnings_ytd_for_retro
(p_assignment_id     in  per_all_assignments_f.assignment_id%type
,p_effective_date    in  date) RETURN number IS

l_balance_type_id     NUMBER;
l_gross_earnings      NUMBER;
l_procedure_name      varchar2(61) :=
'hr_nz_holidays.gross_earnings_ytd_for_retro';

e_missing_balance_type   exception;
CURSOR c_balance_type(p_name varchar2) is
  select balance_type_id
  from pay_balance_types
  where balance_name = p_name;


BEGIN


--** get the balance id
open c_balance_type('Gross Earnings for Holiday Pay');
fetch c_balance_type into l_balance_type_id;
if c_balance_type%notfound
then
 close c_balance_type;
 raise e_missing_balance_type;
end if;
close c_balance_type;


l_gross_earnings := hr_nzbal.calc_asg_hol_ytd_date (p_assignment_id,l_balance_type_id,p_effective_date);

return l_gross_earnings;

 exception
  when e_missing_balance_type
  then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE',l_procedure_name);
    hr_utility.set_message_token('STEP','Missing Balance Type Exception');
    hr_utility.raise_error;

END gross_earnings_ytd_for_retro;


--------------------------------------------------------------------------------------------------
--** Bug 2366349 : Function to get the Adjustments for accrual and entitlement entered through seeded elements
--------------------------------------------------------------------------------------------------
function get_adjustment_values
  (p_assignment_id                   in      NUMBER
  ,p_accrual_plan_id                 in      NUMBER
  ,p_calc_end_date                   in      DATE
  ,p_adjustment_element              in      VARCHAR2
  ,p_start_date                      in      DATE
  ,p_end_date                        in      DATE)
  return number is

    l_proc                          varchar2(61) := 'hr_nz_holidays.get_adjustment_values' ;
    l_adjustment                    number       := 0;

  --  find Leave Initialise Values

    cursor c_get_adjustments( v_assignment_id       number
                             ,v_accrual_plan_id     number
                             ,v_calc_end_date       date
                             ,v_adjustment_element  varchar2
                             ,v_start_date          date
                             ,v_end_date            date) is
              select
                     sum(nvl(to_number(pev1.screen_entry_value),0))
              from
                     pay_accrual_plans           pap
                    ,pay_element_types_f         pet
                    ,pay_element_links_f         pel
                    ,pay_input_values_f          piv1
                    ,pay_input_values_f          piv2
                    ,pay_element_entries_f       pee
                    ,pay_element_entry_values_f  pev1
                    ,pay_element_entry_values_f  pev2
              where
                     pee.assignment_id = v_assignment_id
              and    pet.element_name = v_adjustment_element
              and    pet.element_type_id = pel.element_type_id
              and    pel.element_link_id = pee.element_link_id
              and    pee.element_entry_id = pev1.element_entry_id
              and    pev1.input_value_id = piv1.input_value_id
              and    piv1.name = 'Hours'
              and    piv1.element_type_id = pet.element_type_id
              and    pee.element_entry_id = pev2.element_entry_id
              and    pev2.input_value_id = piv2.input_value_id
              and    piv2.name = 'Accrual Plan'
              and    piv2.element_type_id = pet.element_type_id
              and    pev2.screen_entry_value = pap.accrual_plan_name
              and    pap.accrual_plan_id = v_accrual_plan_id
              /* Start date of adjustment entry must be before end of accrual */
              and    pee.effective_start_date <= v_calc_end_date
              /* End date of adjustment entry must be after start of accrual */
              and    pee.effective_end_date >= v_start_date
              and    pee.effective_start_date between pet.effective_start_date and pet.effective_end_date
              and    pee.effective_start_date between pel.effective_start_date and pel.effective_end_date
              and    pee.effective_start_date between piv1.effective_start_date and piv1.effective_end_date
              and    pee.effective_start_date between pev1.effective_start_date and pev1.effective_end_date
              and    pee.effective_start_date between piv2.effective_start_date and piv2.effective_end_date
              and    pee.effective_start_date between pev2.effective_start_date and pev2.effective_end_date;

  begin

      hr_utility.set_location('  In: ' || l_proc,5) ;
      hr_utility.trace('p_adjustment_element = '||p_adjustment_element);
      hr_utility.trace('p_calc_end_date = '||to_char(p_calc_end_date,'dd/mm/rrrr'));
      hr_utility.trace('p_start_date = '||to_char(p_start_date,'dd/mm/rrrr'));
      hr_utility.trace('p_end_date = '||to_char(p_end_date,'dd/mm/rrrr'));
      -- find total leave initialise - should return zero if none entered

      open c_get_adjustments(p_assignment_id
                            ,p_accrual_plan_id
                            ,p_calc_end_date
                            ,p_adjustment_element
                            ,p_start_date
                            ,p_end_date);
      fetch c_get_adjustments into l_adjustment;
      close c_get_adjustments;

      hr_utility.trace('Adjustment: '||to_char(l_adjustment));
      hr_utility.set_location('  Out: ' || l_proc,10) ;

      return(nvl(l_adjustment,0));

  end get_adjustment_values;

/* Bug 2264070. Following function is called from the formula Annual Leave EOY
   Adjustment skip. It checks whether the element entry of EOY Adjustment element
   is due to Retro process or not.
   If it is due to Retro then it returns 1 else 0 */

function check_retro_eoy(p_element_entry_id in number)
  Return number is

l_retro varchar2(10);

cursor c_check_retro(p_element_entry_id in number)
is
select 'EXISTS'
from pay_element_entries_f pee
where pee.element_entry_id = p_element_entry_id
and   pee.creator_type = 'RR';

begin

  open c_check_retro(p_element_entry_id);
  fetch c_check_retro into l_retro;
  if c_check_retro%notfound then
     close c_check_retro;
     return 0;
  end if;
  close c_check_retro;
   if l_retro = 'EXISTS' then
      return 1;
   end if;

end check_retro_eoy;

END hr_nz_holidays;

/
