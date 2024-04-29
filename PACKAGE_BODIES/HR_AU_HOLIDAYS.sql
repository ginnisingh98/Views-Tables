--------------------------------------------------------
--  DDL for Package Body HR_AU_HOLIDAYS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_HOLIDAYS" AS
  --  $Header: hrauhol.pkb 120.3.12010000.7 2010/03/31 11:29:02 pnethaga ship $
  --
  --  Copyright (C) 2000 Oracle Corporation
  --  All Rights Reserved
  --
  --  Script to create AU HRMS hr_au_holidays package
  --
  --  Change List
  --  ===========
  --
  --  Date        Author   Ver     Description
  --  -----------+--------+-------+-----------------------------------------------
  --  31-Mar-2009 pnethaga 115.28  9444169 - Added cursor c_get_oth_adj_type to get the value for
  --					     'Other Adjustments Type' in 'Further Accrual Information' DFF
  --					     Added Step 4b.
  --  17-Jun-2009 pmatamsr 115.27  8604518 - Cursor c_enrollment_startdate modified in function au_get_enrollment_startdate
  --  26 May 2009 dduvvuri 115.26  8482224 - Cursor csr_get_accrual_plan_id modified in Function get_accrual_plan_by_category
  --  04-Mar-2009 dduvvuri 115.25  8301730 - function get_accrual_entitlement - removed Step 4a
  --  16-Dec-2008 pmatamsr 115.23  Bug 7607177 function au_get_enrollment_startdate added
  --                               to get the correct enrollment start date
  --                               for calculating the PTO Accrual.
  --  01-Oct-2007 priupadh 115.22  Bug 6449311 function get_accrual_entitlement added Step 4a
  --  04-Apr-2007 priupadh 115.21  Bug 5964317 removed cursor c_asg_periods modified c_periods
  --  02-Apr-2007 priupadh  115.20 Bug 5964317 Added cursor c_asg_periods and loop a_periods
  --  29 May 2003 apunekar 115.9   Bug2920725 - Corrected base tables to support security model
  --  02 Dec 2002 Apunekar 115.18  Bug#2689173-Added Nocopy to out and in out parameters
  -- 20-MAR-2001  apunekar 115.17  Validated anniversary date for 29th feb input,Bug#2272301
  --  10-DEC-2001 srussell 115.16  Put in checkfile syntax.
  --  07-DEC-2001 srussell 115.15  Allow get_accrual_entitlement to return a
  --                               negative amount for net_accrual.
  --  28-NOV-2001 nnaresh  115.12  Updated for GSCC Standards
  --  26-SEP-2001 shoskatt 115.11  Used the get_leave_initialise to get the accrual
  --                               initialise at the entitlement end date. This is
  --                               used to calculate the net entitlements
  --  12-SEP-2001 shoskatt 115.10  Used the get_leave_initialise function to get
  --                               the Leave Entitlement Initialise and Leave Accrual
  --                               Initialise value. This is used to calculate the
  --                               Net Entitlement as well as Net Accrual. Bug #1942971
  --  16-OCT-2000 rayyadev 115.9   change the code to consider multiple bands with
  --                               different annual rate  bug no 1460922
  --  25-Jan-2000 sclarke  115.8   Moved term_lsl_eligibility_years to pay_au_terminations
  --  29-May-2000 makelly  115.7   Re-added get_net_accrual wrapper
  --  26-May-2000 makelly  115.6   Bug 1313971 anniversary date counted twice in
  --                               accrual_daily_basis. (removed exceptions)
  --  16-May-2000 makelly  115.5   Bug 1300935 Altered accrual_entitlement to check for
  --                               start date and change to entitlement adjustments
  --  03-May-2000 makelly  115.4   Bug 1273677 and added accrual_entitlement fn
  --                               to simplify calls from accrual/absence forms
  --  21-Mar-2000 makelly  115.3   fixed bug in call to asg_working_hours
  --  15-Mar-2000 sclarke  115.2   Added LSL function
  --  21-Jan-2000 makelly  115.1   Initial - Based on hrnzhol.pkb
  -----------------------------------------------------------------------------------
  --  private global declarations
  -----------------------------------------------------------------------------------

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
    AND    p_effective_date BETWEEN pel.effective_start_date AND pel.effective_end_date /*Added for 8482224*/
    AND    p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date /*Added for 8482224*/
    AND    pel.element_link_id = pee.element_link_id
    AND    pel.element_type_id = pet.element_type_id
    AND    pap.accrual_plan_element_type_id = pet.element_type_id
    AND    pap.accrual_category = p_plan_category ;

  BEGIN
    hr_utility.set_location(' Entering::'||l_proc,5);

    OPEN csr_get_accrual_plan_id(p_assignment_id, p_effective_date, p_plan_category) ;

    FETCH csr_get_accrual_plan_id INTO l_accrual_plan_id;

    IF csr_get_accrual_plan_id%NOTFOUND
    THEN
      CLOSE csr_get_accrual_plan_id;
      hr_utility.set_location('Plan Not Found '||l_proc,10);
      hr_utility.set_message(801, 'HR_AU_ACCRUAL_PLAN_NOT_FOUND');
      hr_utility.raise_error;
    end if ;

    FETCH csr_get_accrual_plan_id INTO l_dummy ;

    IF csr_get_accrual_plan_id%FOUND
    THEN
      CLOSE csr_get_accrual_plan_id;
      hr_utility.set_location('Enrolled in Multiple Plans '||l_proc,15);
      hr_utility.set_message(801, 'HR_AU_TOO_MANY_ACCRUAL_PLANS');
      hr_utility.raise_error;
    END IF;

    CLOSE csr_get_accrual_plan_id;
    hr_utility.set_location('Leaving:'||l_proc,20);

    RETURN l_accrual_plan_id;

--  EXCEPTION
--    WHEN OTHERS THEN
--        hr_utility.set_location('Leaving:'||l_proc,99);
--        RETURN NULL;
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

     --------------------------------------
     --  Bug No : 2132299 Start
     --------------------------------------

     l_initialise_type     VARCHAR2(100);
     l_accrual_init        NUMBER ;
     l_entitlement_init    NUMBER;

    --------------------------------------
    -- Bug No : 2132299 End
    --------------------------------------

     BEGIN
         hr_utility.set_location('Entering: '||l_proc,10) ;
         l_assignment_id := p_assignment_id ;
         l_plan_id := p_plan_id ;
         l_payroll_id := p_payroll_id ;
         l_business_group_id := p_business_group_id ;
         l_calculation_date := p_calculation_date ;
         l_start_date := NULL ;
         l_end_date := NULL ;
         l_accrual_end_date := NULL ;
         l_accrual := NULL ;
         l_net_entitlement := NULL ;
         per_accrual_calc_functions.get_net_accrual(
                          p_assignment_id      =>   l_assignment_id
                         ,p_plan_id            =>   l_plan_id
                         ,p_payroll_id         =>   l_payroll_id
                         ,p_business_group_id  =>   l_business_group_id
                         ,p_calculation_date   =>   l_calculation_date
                         ,p_start_date         =>   l_start_date
                         ,p_end_date           =>   l_end_date
                         ,p_accrual_end_date   =>   l_accrual_end_date
                         ,p_accrual            =>   l_accrual
                         ,p_net_entitlement    =>   l_net_entitlement) ;

         --------------------------------------
         --    Bug No : 2132299 Start
         --------------------------------------

         l_initialise_type := 'Leave Accrual Initialise';
         l_accrual_init  := (get_leave_initialise(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_initialise_type     => l_initialise_type
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date)
                      );

         l_initialise_type := 'Leave Entitlement Initialise';
         l_entitlement_init  := (get_leave_initialise(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_initialise_type     => l_initialise_type
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date)
                      );



         l_net_entitlement := l_net_entitlement + l_entitlement_init  + l_accrual_init;

         --------------------------------------
         --    Bug No : 2132299 End
         --------------------------------------

         hr_utility.set_location('Leaving '||l_proc,20);
         RETURN l_net_entitlement ;

  END get_net_accrual ;



--------------------------------------------------------------
--
--  get_accrual_entitlement
--
--  This function is required mainly by the AU local library
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
  ,p_net_accrual          OUT   NOCOPY NUMBER
  ,p_net_entitlement      OUT   NOCOPY NUMBER
  ,p_calc_start_date      OUT   NOCOPY DATE
  ,p_last_accrual         OUT   NOCOPY DATE
  ,p_next_period_end      OUT   NOCOPY DATE)
RETURN NUMBER IS


--  The stages of the calculation are as follows
--
--  1: Find the entitlement end date using the get_carryover_values
--     core function - ie the last day of the entitlement period
--
--  2: Find net leave at entitlement end date using the core
--     get_net_accrual Function.
--
--  3: Find the total net leave up to the calculation date using
--     the core get_net_accrual function.
--
--  4: Find the number of hours taken during the accrual period
--     i.e. date from step 1 plus 1 day until calc date using the
--     core get_absence function
--
--   Added Step 4a for Bug 6449311
--  4a Find the Net Contribution of other elements using
--      per_accrual_calc_functions.get_other_net_contribution
--   Added Step 4b for Bug 9444169
--  4b If the Other Adjustments type is 'Entitlement', 'Other Net Contributions'
--    are added to Net Entitlement.
--
--  5: Find Leave Accrual Initialise during period
--
--  6: Find Leave Entitlement Initialise during period
--
--  7: Net entitlement = greater ((step 2 - step 4 + step 6 + step 4.1), 0)
--
--  8: Net accrual = (step 3 + step 5 - step 7 + step 6)
--


  l_proc                        VARCHAR2(72) := g_package||'.get_accrual_entitlement';
  l_assignment_id               NUMBER ;
  l_plan_id                     NUMBER ;
  l_payroll_id                  NUMBER ;
  l_business_group_id           NUMBER ;
  l_calculation_date            DATE ;
  l_start_date                  DATE ;
  l_end_date                    DATE ;
  l_accrual_end_date            DATE ;
  l_accrual_period_start_date   DATE ;
  l_accrual_period_end_date     DATE ;
  l_entitlement_period_end_date DATE ;
  l_net_accrual                 NUMBER ;
  l_net_entitlement             NUMBER ;
  l_co_formula_id               NUMBER ;
  l_max_co                      NUMBER ;
  l_leave_end_ent               NUMBER ;
  l_leave_calc_date             NUMBER ;
  l_accrual                     NUMBER ;
  l_accrual_absences            NUMBER ;
  l_total_ent_adj               NUMBER ;
  l_other                       NUMBER ; -- Bug 9444169
  l_other_adj_type              VARCHAR2(10); -- Bug 9444169
  ---------------------------------------------
  -- Bug #1942971 -- Start
  ---------------------------------------------
  l_initialise_type             VARCHAR2(100);
  l_accrual_init                NUMBER ;
  l_accrual_ent                 NUMBER ;
  l_entitlement_init            NUMBER ;
  ---------------------------------------------
  -- Bug #1942971 -- End
  ---------------------------------------------

  cursor c_get_co_formula (v_accrual_plan_id number) is
    select  co_formula_id
    from    pay_accrual_plans
    where   accrual_plan_id = v_accrual_plan_id;

 -- Start of Bug 9444169
 cursor c_get_oth_adj_type(v_accrual_plan_id number) is
    select information2
    from  pay_accrual_plans
    where accrual_plan_id = v_accrual_plan_id;
 -- End of Bug 9444169

BEGIN

  hr_utility.set_location('Entering: '||l_proc,10) ;
  l_assignment_id              := p_assignment_id ;
  l_plan_id                    := p_plan_id ;
  l_payroll_id                 := p_payroll_id ;
  l_business_group_id          := p_business_group_id ;
  l_calculation_date           := p_calculation_date ;


  --
  --  Step 1 Find entitlement end date
  --  first get the carryover formula then call it
  --  to get the prev and next anniversary dates.
  --  Entitlement end date and accrual end dates are
  --  actually the day before the anniversary dates.
  --

  open  c_get_co_formula (l_plan_id);
  fetch c_get_co_formula into l_co_formula_id;
  close c_get_co_formula;


  per_accrual_calc_functions.get_carry_over_values(
                    p_co_formula_id      =>   l_co_formula_id
                   ,p_assignment_id      =>   l_assignment_id
                   ,p_calculation_date   =>   l_calculation_date
                   ,p_accrual_plan_id    =>   l_plan_id
                   ,p_business_group_id  =>   l_business_group_id
                   ,p_payroll_id         =>   l_payroll_id
                   ,p_accrual_term       =>   'AU_FORM'
                   ,p_effective_date     =>   l_accrual_period_start_date
                   ,p_session_date       =>   l_calculation_date
                   ,p_max_carry_over     =>   l_max_co
                   ,p_expiry_date        =>   l_accrual_period_end_date  );



   --
   --  Step two find the Net leave at entitlement end date
   --
   --  Before first anniversary date accrual_period_start_date = start_date
   --  in this case l_max_co will be set to 1
   --

   if l_max_co = 1 then
     l_entitlement_period_end_date := l_accrual_period_start_date;
   else
     l_entitlement_period_end_date := (l_accrual_period_start_date - 1);
   end if;

   per_accrual_calc_functions.get_net_accrual(
                     p_assignment_id      =>   l_assignment_id
                    ,p_plan_id            =>   l_plan_id
                    ,p_payroll_id         =>   l_payroll_id
                    ,p_business_group_id  =>   l_business_group_id
                    ,p_calculation_date   =>   l_entitlement_period_end_date
                    ,p_start_date         =>   l_start_date
                    ,p_end_date           =>   l_end_date
                    ,p_accrual_end_date   =>   l_accrual_end_date
                    ,p_accrual            =>   l_accrual
                    ,p_net_entitlement    =>   l_leave_end_ent) ;  -- at end of entitlement perod


  --
  --  Step three find the Net leave at the calculation_date
  --

  per_accrual_calc_functions.get_net_accrual(
                    p_assignment_id      =>   l_assignment_id
                   ,p_plan_id            =>   l_plan_id
                   ,p_payroll_id         =>   l_payroll_id
                   ,p_business_group_id  =>   l_business_group_id
                   ,p_calculation_date   =>   l_calculation_date
                   ,p_start_date         =>   l_start_date
                   ,p_end_date           =>   l_end_date
                   ,p_accrual_end_date   =>   l_accrual_end_date
                   ,p_accrual            =>   l_accrual
                   ,p_net_entitlement    =>   l_leave_calc_date) ;  -- at calculation date



  --
  --  Step four find out the numder of hours taken during the accrual period
  --

  l_accrual_absences := per_accrual_calc_functions.get_absence(
                                 p_assignment_id       => l_assignment_id,
                                 p_plan_id             => l_plan_id,
                                 p_start_date          => l_accrual_period_start_date,
                                 p_calculation_date    => l_calculation_date   );

/*Bug 6449311 Begin */
  --
  --  Step 4a find out the contribution from other elements
  --
l_other := per_accrual_calc_functions.get_other_net_contribution(
                                         p_assignment_id    => l_assignment_id,
                                         p_plan_id          => l_plan_id,
                                         p_start_date       => l_accrual_period_start_date,
                                         p_calculation_date => l_calculation_date );

/*Bug 6449311 End */

/* 8301730 - Removed the above call to per_accrual_calc_functions.get_other_net_contribution made
             in bug 6449311 */

  -------------------------------------------------------------------------------------------
  --- Bug #1942971  ----- Start
  -------------------------------------------------------------------------------------------
  --
  -- Step 5 : Find the Leave Accrual Initialise for the period(5a). Also get leave accrual initialise
  --          at the end of entitlement date(5b).
  --
      l_initialise_type := 'Leave Accrual Initialise';
      l_accrual_init  := (get_leave_initialise(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_initialise_type     => l_initialise_type
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date)
                      );

      l_accrual_ent := (get_leave_initialise(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_initialise_type     => l_initialise_type
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_entitlement_period_end_date - 1)
                      );

  --
  -- Step 6 : Find the Leave Entitlement Initialise for the period.
  --
      l_initialise_type := 'Leave Entitlement Initialise';
      l_entitlement_init  := (get_leave_initialise(
                                   p_assignment_id       => l_assignment_id
                                  ,p_accrual_plan_id     => l_plan_id
                                  ,p_calc_end_date       => l_calculation_date
                                  ,p_initialise_type     => l_initialise_type
                                  ,p_start_date          => l_start_date
                                  ,p_end_date            => l_end_date)
                      );

/* Bug 9444169 */
open  c_get_oth_adj_type (l_plan_id);
  fetch c_get_oth_adj_type into l_other_adj_type;
  close c_get_oth_adj_type;

/*Bug 6449311 l_other (Step 4a) added for calculating l_net_entitlement */
  --
  --  Step 7:  Net entitlement = greater ((step 2 - step 4 + step 6 + Step 5b +Step 4a), 0)
  --
/* Start of Bug 9444169 */
 --  Modified Step 7:  Net entitlement = greater ((step 2 - step 4 + step 6 + Step 5b), 0)
     if   (nvl(l_other_adj_type,'E') = 'A') then
	l_net_entitlement := greatest( (l_leave_end_ent - l_accrual_absences + l_entitlement_init + l_accrual_ent) , 0);

     elsif (nvl(l_other_adj_type,'E') = 'E') then
	l_net_entitlement := greatest( (l_leave_end_ent - l_accrual_absences + l_entitlement_init + l_accrual_ent + l_other ) , 0);
     end if;
/* End of Bug 9444169 */
  --
  --  Step 8: Net accrual = greater((step 3 + step 5 - step 7 + step 6),0)
  --
  --l_net_accrual := greatest((l_leave_calc_date + l_accrual_init - l_net_entitlement + l_entitlement_init),0);
  l_net_accrual := (l_leave_calc_date + l_accrual_init - l_net_entitlement + l_entitlement_init);


  --
  --  set up return values
  --

  p_net_accrual        := round(nvl(l_net_accrual,     0), 3);
  p_net_entitlement    := round(nvl(l_net_entitlement, 0), 3);
  p_calc_start_date    := l_start_date;
  p_last_accrual       := l_accrual_end_date;
  p_next_period_end    := l_accrual_period_end_date - 1;

  hr_utility.set_location('Leaving '||l_proc,20);
  RETURN (0);

--  EXCEPTION
--    WHEN OTHERS
--    THEN
--        hr_utility.set_location('Leaving:'||l_proc,99);
--        RETURN -99;

END get_accrual_entitlement ;



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
        AND     pap.business_group_id = c_business_group_id
        AND     c_calculation_date BETWEEN pee.effective_start_date AND pee.effective_end_date
        AND     pap.accrual_category = (
            SELECT lookup_code
            FROM hr_lookups
            WHERE lookup_type = 'ABSENCE_CATEGORY'
            AND meaning = 'Annual Leave');

    BEGIN
        hr_utility.set_location('Entering: '||l_proc,5);
        OPEN csr_annual_leave_accrual_plan  (p_business_group_id
                                            ,p_calculation_date
                                            ,p_assignment_id);

        FETCH csr_annual_leave_accrual_plan INTO l_plan_id;
        CLOSE csr_annual_leave_accrual_plan;
        hr_utility.set_location('Leaving:'||l_proc,10);
        RETURN l_plan_id;

--    EXCEPTION
--        WHEN OTHERS
--        THEN
--            hr_utility.set_location('Leaving:'||l_proc,99);
--            RETURN NULL;
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

    /*Bug2920725   Corrected base tables to support security model*/

    CURSOR csr_continuous_service_date  (c_business_group_id    NUMBER
                                        ,c_accrual_plan_id      NUMBER
                                        ,c_calculation_date     DATE
                                        ,c_assignment_id        NUMBER) IS
        SELECT NVL(TO_DATE(pev.screen_entry_value,'YYYY/MM/DD HH24:MI:SS'),pps.date_start)
        FROM    pay_element_entries_f pee,
                pay_element_entry_values_f pev,
                pay_input_values_f piv,
                pay_accrual_plans pap,
                hr_lookups hrl,
                per_assignments_f asg,
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
        AND     piv.name = hrl.meaning
        AND     hrl.lookup_type = 'NAME_TRANSLATIONS'
        AND     hrl.lookup_code = 'PTO_CONTINUOUS_SD';

  BEGIN
    hr_utility.set_location('Entering:'||l_proc,5);
    OPEN csr_continuous_service_date    (p_business_group_id
                                        ,p_accrual_plan_id
                                        ,p_calculation_date
                                        ,p_assignment_id);
    FETCH csr_continuous_service_date INTO l_csd;
    CLOSE csr_continuous_service_date;
    hr_utility.set_location('Leaving:'||l_proc,10);
    RETURN l_csd;

--  EXCEPTION
--    WHEN OTHERS
--    THEN
--        hr_utility.set_location('Leaving:'||l_proc,99);
--        RETURN NULL;
    END;



  -----------------------------------------------------------------------------
  --  accrual_daily_basis function
  --
  --  public function called by PTO Accrual Formulae
  --  PTO accrual formula.
  -----------------------------------------------------------------------------

  function accrual_daily_basis
  (p_payroll_id                   in      number
  ,p_accrual_plan_id              in      number
  ,p_assignment_id                in      number
  ,p_calculation_start_date       in      date
  ,p_calculation_end_date         in      date
  ,p_service_start_date           in      date
  ,p_business_group_hours         in      number
  ,p_business_group_freq          in      varchar2)
  return number is

    l_procedure_name                varchar2(61) := 'hr_au_holidays.accrual_daily_basis' ;
    l_accrual                       number := 0 ;
    l_accrual_band_cache            t_accrual_band_tab ;
    l_asg_work_day_info_cache       t_asg_work_day_info_tab ;
    l_counter                       integer ;
    l_years_service                 number ;
    l_annual_accrual                number ;
    l_special_annual_accrual        number ;
    l_days_in_year                  integer ;
    l_days_in_part_period           integer ;
    l_days_suspended                integer ;
    l_next_anniversary_date         date ;
    l_mm_dd                         varchar2(10);
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

/*Bug 5964317 Modified cursor c_periods to get time periods for corresponding payrolls */
    --  cursor to get time periods to process

    cursor c_periods (p_assignment_id number
                     ,p_start_date date
                     ,p_end_date date) is
      select greatest(tp.start_date,paf.effective_start_date) start_date,least(tp.end_date,paf.effective_end_date) end_date
      from   per_time_periods tp,per_assignments_f paf
      where  paf.assignment_id = p_assignment_id
      and    tp.payroll_id =   paf.payroll_id
      and    tp.start_date <=  paf.effective_end_date
      and    tp.end_date   >=  paf.effective_start_date
      and    tp.start_date <=  p_end_date
      and    tp.end_date   >=  p_start_date
      and    paf.effective_start_date <= p_end_date
      and    paf.effective_end_date   >= p_start_date
      order by  tp.start_date ;

    --  local function to get accrual annual rate from PL/SQL table

    function accrual_annual_rate(p_years_service number) return number is

      l_procedure_name                varchar2(61) := '  accrual_annual_rate' ;
      l_annual_accrual                pay_accrual_bands.annual_rate%type ;
      l_counter                       integer := 1 ;
      l_band_notfound_flag            boolean := true ;

    begin

      hr_utility.trace('  In: ' || l_procedure_name) ;

      --  loop through the PL/SQL table looking for a likely accrual band
      while l_accrual_band_cache.count > 0
        and l_band_notfound_flag
        and l_counter <= l_accrual_band_cache.last
      loop

        if (p_years_service >= l_accrual_band_cache(l_counter).lower_limit) and
           (p_years_service <  l_accrual_band_cache(l_counter).upper_limit)
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

      hr_utility.trace('  Out: ' || l_procedure_name ||' '|| l_annual_accrual) ;
      return l_annual_accrual ;

    end accrual_annual_rate ;

    --  local function to get asg working hours from PL/SQL table

    function asg_working_hours(p_effective_date date
                              ,p_frequency varchar2) return number is

      l_procedure_name                varchar2(61) := '  asg_working_hours' ;
      l_asg_working_hours             per_all_assignments_f.normal_hours%type ;
      l_counter                       integer := 1 ;
      l_hours_notfound_flag           boolean := true ;

    begin

      hr_utility.trace('  In: ' || l_procedure_name) ;
      hr_utility.trace('p_effective_date = '||to_char(p_effective_date, 'DD-MON-YYYY'));

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

        hr_utility.trace('     Failed_mk: ' || l_procedure_name ) ;
        hr_utility.trace('     End Date: ' || to_char(l_asg_work_day_info_cache(l_counter).effective_end_date, 'DD-MON-YYYY'));
        raise e_accrual_function_failure ;

      end if ;

      hr_utility.trace('  Out: ' || l_procedure_name) ;
      return l_asg_working_hours ;



    end asg_working_hours ;

  begin

    hr_utility.trace('In: '                         || l_procedure_name) ;
    hr_utility.trace('  p_payroll_id: '             || to_char(p_payroll_id)) ;
    hr_utility.trace('  p_accrual_plan_id: '        || to_char(p_accrual_plan_id)) ;
    hr_utility.trace('  p_assignment_id: '          || to_char(p_assignment_id)) ;
    hr_utility.trace('  p_calculation_start_date: ' || to_char(p_calculation_start_date, 'DD-MM-YYYY')) ;
    hr_utility.trace('  p_calculation_end_date: '   || to_char(p_calculation_end_date, 'DD-MM-YYYY')) ;
    hr_utility.trace('  p_service_start_date: '     || to_char(p_service_start_date, 'DD-MM-YYYY')) ;
    hr_utility.trace('  p_business_group_hours: '   || to_char(p_business_group_hours)) ;
    hr_utility.trace('  p_business_group_freq: '    || p_business_group_freq) ;

    --  cache the assignment's work day history

    l_counter := 1 ;

    for r_asg_work_day in c_asg_work_day_history(p_assignment_id
                                                ,p_calculation_start_date
                                                ,p_calculation_end_date)
    loop

      l_asg_work_day_info_cache(l_counter).effective_start_date := r_asg_work_day.effective_start_date ;
      l_asg_work_day_info_cache(l_counter).effective_end_date   := r_asg_work_day.effective_end_date ;

      if r_asg_work_day.normal_hours is not null then
        l_asg_work_day_info_cache(l_counter).normal_hours := r_asg_work_day.normal_hours ;
      else
        l_asg_work_day_info_cache(l_counter).normal_hours := p_business_group_hours ;
      end if ;

      if r_asg_work_day.frequency is not null then
        l_asg_work_day_info_cache(l_counter).frequency := r_asg_work_day.frequency ;
      else
        l_asg_work_day_info_cache(l_counter).frequency := p_business_group_freq ;
      end if ;

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

/*Bug 5964317  Passing p_assignment_id in place of p_payroll_id */
    --  loop through the payroll periods
    for r_period in c_periods(p_assignment_id
                             ,p_calculation_start_date
                             ,p_calculation_end_date)
    loop

      --  how many years of effective service does the assignment have (at the end of each period)
      --  i.e. (days since hired - days with susp ass) / avg no of days per year
      l_years_service := floor(((r_period.end_date - p_service_start_date)
                         - hr_au_holidays.days_suspended(p_assignment_id, p_service_start_date, r_period.end_date))  / 365.25) ;

      --  get the accrual band
      l_annual_accrual := accrual_annual_rate(l_years_service) ;



      --  get the assignment's normal working hours (at the end of each period)
      --  l_asg_working_hours := asg_working_hours(r_period.end_date, p_business_group_freq) ;

      l_asg_working_hours := asg_working_hours(least(r_period.end_date, p_calculation_end_date), p_business_group_freq) ;


      --  the accrual rate in the accrual band is for assignments that work the
      --  business group's default working hours.  Now prorate the accrual rate
      --  based on the proporation of the business group hours that the
      --  assignment works.
      l_annual_accrual := l_annual_accrual * (l_asg_working_hours / p_business_group_hours) ;

      --  the algorithm being used here is:
      --
      --  days to accrue for period
      --    = (annual entitlement / days in current holiday year)
      --        * days in period
      --
      --  the number of days in the year varies between leap years and
      --  leap years.  if the anniversary date falls in the period (or part
      --  period) being processed then the calculation needs to treat the
      --  bit of the period up to the anniversary date separately from the
      --  bit of the period after the anniversary date to allow for different
      --  number of days in the holiday year.

      --  we may be dealing with a part period here, ie if the calculation
      --  start date is part way through the first period or if the
      --  calculation end date is part way through the last period.
      if p_calculation_start_date between r_period.start_date and r_period.end_date then
        l_start_date := p_calculation_start_date ;
      else
        l_start_date := r_period.start_date ;
      end if ;

      if p_calculation_end_date between r_period.start_date and r_period.end_date then
        l_end_date := p_calculation_end_date ;
      else
        l_end_date := r_period.end_date ;
      end if ;

      --  l_start_date and l_end_date now define the time span we're
      --  interested in.  find the anniversary date and see if it falls
      --  between the dates.
      l_mm_dd:= to_char(p_service_start_date, 'MMDD');/*for bug2272301*/
      if (l_mm_dd = '0229' ) then
       l_mm_dd:='0228';
      end if;
      l_next_anniversary_date := to_date(to_char(l_start_date, 'YYYY') ||l_mm_dd
                                        ,'YYYYMMDD') ;

      if l_next_anniversary_date <= l_start_date
      then
        l_next_anniversary_date := add_months(l_next_anniversary_date, 12) ;
      end if ;

      if  (least((l_next_anniversary_date-1), p_calculation_end_date)) between l_start_date and l_end_date then


        --  this is the special case where the anniversary date is in the time
        --  span we're dealing with

        --  process the start of the time span up to the (but not incl) anniversary date
        --  see bug 1313971
        --  consideration of multiple bands of different annual rate bug no 1460922

        l_years_service := floor((((least((l_next_anniversary_date-1), p_calculation_end_date))- p_service_start_date)
                         - hr_au_holidays.days_suspended(p_assignment_id, p_service_start_date, (least((l_next_anniversary_date-1), p_calculation_end_date))))  / 365.25) ;


      l_special_annual_accrual := accrual_annual_rate(l_years_service) ;



      l_asg_working_hours := asg_working_hours((least((l_next_anniversary_date-1), p_calculation_end_date)), p_business_group_freq) ;


      --  the accrual rate in the accrual band is for assignments that work the
      --  business group's default working hours.  Now prorate the accrual rate
      --  based on the proporation of the business group hours that the
      --  assignment works.
      l_special_annual_accrual := l_special_annual_accrual * (l_asg_working_hours / p_business_group_hours) ;



        l_days_in_year := (l_next_anniversary_date - add_months(l_next_anniversary_date, -12)) ;
        l_days_in_part_period := ((least((l_next_anniversary_date-1), p_calculation_end_date)) - l_start_date) +1 ;
        l_days_suspended := hr_au_holidays.days_suspended (p_assignment_id
                                                          ,l_start_date
                                                          ,(least((l_next_anniversary_date-1), p_calculation_end_date)));
        l_period_accrual := (l_special_annual_accrual / l_days_in_year) * (l_days_in_part_period - l_days_suspended) ;

If l_end_date > (l_next_anniversary_date-1) then
        --  process the anniversary date to the end of the time span
        l_days_in_year := (add_months(l_next_anniversary_date, 12) - l_next_anniversary_date) ;
        l_days_in_part_period := (l_end_date - l_next_anniversary_date) + 1 ;
        l_days_suspended := hr_au_holidays.days_suspended (p_assignment_id
                                                          ,l_next_anniversary_date
                                                          ,l_end_date);
        l_period_accrual := l_period_accrual + (l_annual_accrual / l_days_in_year) * (l_days_in_part_period - l_days_suspended);
end if;

      else

        --  this is the most common case where the anniversary date is outside
        --  the time span we're dealing with

        l_days_in_year := (l_next_anniversary_date - add_months(l_next_anniversary_date, -12)) ;
        l_days_in_part_period := (l_end_date - l_start_date) + 1 ;
        l_days_suspended := hr_au_holidays.days_suspended (p_assignment_id
                                                      ,l_start_date
                                                          ,l_end_date);
        l_period_accrual := (l_annual_accrual / l_days_in_year) * (l_days_in_part_period - l_days_suspended) ;

      end if ;

      l_accrual := l_accrual + l_period_accrual ;

    end loop ;  --  c_periods

    hr_utility.trace('Out: ' || l_procedure_name) ;
    return l_accrual ;

--  exception
--    when e_accrual_function_failure
--    then
--      hr_utility.set_message(801, 'HR_AU_ACCRUAL_FUNCTION_FAILURE') ;
--      hr_utility.raise_error ;

  end accrual_daily_basis ;


    /*---------------------------------------------------------------------
                Name    : days_suspended
                Purpose : to get the number of suspended days in the period
                Returns : Number of suspended days
      Issue - the requirement AU019PTO 1.8 talks about suspending accrual
      based on leave types. In Core PTO they suggest using assignment status
      so basing on that but including proration.
      ---------------------------------------------------------------------*/

  FUNCTION days_suspended
      (p_assignment_id       IN NUMBER
      ,p_start_date          IN DATE
      ,p_end_date            IN DATE)
  RETURN NUMBER IS

/*Bug2920725   Corrected base tables to support security model*/

      CURSOR csr_days_suspended(c_assignment_id         NUMBER
                               ,c_start_date            DATE
                               ,c_end_date              DATE) IS
    SELECT
           NVL(SUM(1+
                 LEAST(effective_end_date, c_end_date)
               - GREATEST(effective_start_date, c_start_date)),0)
          FROM
               per_assignments_f asg
              ,per_assignment_status_types t
         WHERE
               assignment_id = c_assignment_id
           AND t.assignment_status_type_id = asg.assignment_status_type_id
           AND effective_start_date <= c_end_date
           AND effective_end_date >= c_start_date
           AND per_system_status = 'SUSP_ASSIGN';

      l_proc            VARCHAR2(72)  := g_package||'days_suspended';
      l_days_suspended  NUMBER        := 0;

    BEGIN

      hr_utility.set_location('Entering'||l_proc,5);
    --  hr_utility.trace(TO_CHAR(p_start_date,'DD-MM-YYYY')||' and '
    --                  ||TO_CHAR(p_end_date,'DD-MM-YYYY'));

      IF (p_start_date > p_end_date) THEN
          hr_utility.set_message(801,'HR_AU_INVALID_DATE_RANGE');
          hr_utility.raise_error;
      END IF;

      OPEN csr_days_suspended(p_assignment_id
                             ,p_start_date
                             ,p_end_date);
      FETCH csr_days_suspended INTO l_days_suspended;
      CLOSE csr_days_suspended;

      hr_utility.trace('Days Suspended between '
                      ||TO_CHAR(p_start_date,'DD-MM-YYYY')||' and '
                      ||TO_CHAR(p_end_date,'DD-MM-YYYY')||' = '
                      ||TO_CHAR(l_days_suspended));
      hr_utility.set_location('Leaving:'||l_proc,10);

      RETURN l_days_suspended;

--    EXCEPTION
--      WHEN others THEN
--        hr_utility.set_location('Leaving:'||l_proc,99);
--        RETURN NULL;

  END days_suspended;

  -----------------------------------------------------------------------------
  --  check_periods function
  --
  --  public function called by AU_ANNUAL_LEAVE_ACCRUAL_DAILY
  --  PTO accrual formula.
  -----------------------------------------------------------------------------

  function check_periods
  (p_payroll_id                   in      number)
  return date is

    l_proc                          varchar2(61) := 'hr_au_holidays.check_periods' ;
    l_end_date                      date         := to_date('01010001','DDMMYYYY');

  --  cursor to check payroll periods exist up to calc_end_date

    cursor c_last_period (p_payroll_id number) is
              select max(tp.end_date)
              from   per_time_periods tp
              where  tp.payroll_id = p_payroll_id;
  begin

      hr_utility.set_location('  In: ' || l_proc,5) ;

      -- check payroll periods exist up to calculation_end_date

      open c_last_period ( p_payroll_id );
      fetch c_last_period into l_end_date;
      close c_last_period;

      hr_utility.set_location('  Out: ' || l_proc,10) ;

      return(l_end_date);

--      EXCEPTION
--            WHEN others THEN
--              hr_utility.trace('Error - payroll periods not found for payroll_id '||to_char(p_payroll_id));
--              hr_utility.set_location('Leaving:'||l_proc,99);
--              RETURN NULL;

  end check_periods ;

  -----------------------------------------------------------------------------
  --  adjust_for_suspend_assign function
  --
  --  public function called by Accrual/Entitlement Formula
  --  adjusts ineligability end date to take account of any
  --  periods when assignment was suspended
  -----------------------------------------------------------------------------

  function adjust_for_suspend_assign
   (p_assignment_id                    IN NUMBER
   ,p_adjust_date                      IN DATE
   ,p_start_date                       IN DATE
   ,p_end_date                         IN DATE)
   return date is

   l_proc                          varchar2(61) := 'hr_au_holidays.adjust_for_suspend_assign' ;
   l_days_suspended                number       := 1;
   l_start_date                    date         := p_start_date;
   l_adjust_date                   date         := p_adjust_date;

   begin

     hr_utility.set_location('  In: ' || l_proc,5) ;

     -- loop to check each new period added on for suspended assignments

     while (l_days_suspended > 0) and (l_adjust_date < p_end_date) loop

       l_days_suspended := hr_au_holidays.days_suspended (p_assignment_id
                                                         ,l_start_date
                                                         ,l_adjust_date);
       l_start_date  := l_adjust_date;
       l_adjust_date := l_adjust_date + l_days_suspended;

     end loop;

     if l_adjust_date > p_end_date then
       l_adjust_date := p_end_date;
     end if;

     hr_utility.set_location('  Out: ' || l_proc,10) ;

     return (l_adjust_date);

--   EXCEPTION
--     WHEN others THEN
--       hr_utility.set_location('Leaving:'||l_proc,99);
--       RETURN NULL;

  end adjust_for_suspend_assign ;

  -----------------------------------------------------------------------------
  --
  --  Find Leave Adjustment Intialise or Leave Entitlement Initailise value
  --  depending on the parameter(p_initialise_type) passed.
  --
  --  public function called by Leave Formulae
  --
  -----------------------------------------------------------------------------

  function get_leave_initialise
  (p_assignment_id                   in      NUMBER
  ,p_accrual_plan_id                 in      NUMBER
  ,p_calc_end_date                   in      DATE
  ,p_initialise_type                 in      VARCHAR2
  ,p_start_date                      in      DATE
  ,p_end_date                        in      DATE)
  return number is

    l_proc                          varchar2(61) := 'hr_au_holidays.get_leave_initailise' ;
    l_initialise                    number       := 0;

  --  find Leave Initialise Values

    cursor c_get_initialise ( v_assignment_id       number
                             ,v_accrual_plan_id     number
                             ,v_calc_end_date       date
                             ,v_initialise_type     varchar2
                             ,v_start_date          date
                             ,v_end_date            date  ) is
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
              and    pet.element_name = v_initialise_type
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
              and    pee.effective_start_date <= v_calc_end_date
              and    pee.effective_start_date between pet.effective_start_date and pet.effective_end_date
              and    pee.effective_start_date between pel.effective_start_date and pel.effective_end_date
              and    pee.effective_start_date between piv1.effective_start_date and piv1.effective_end_date
              and    pee.effective_start_date between pev1.effective_start_date and pev1.effective_end_date
              and    pee.effective_start_date between piv2.effective_start_date and piv2.effective_end_date
              and    pee.effective_start_date between pev2.effective_start_date and pev2.effective_end_date
              and    pee.effective_start_date between v_start_date and v_end_date;

  begin

      hr_utility.set_location('  In: ' || l_proc,5) ;

      -- find total leave initialise - should return zero if none entered

      open c_get_initialise (p_assignment_id
                            ,p_accrual_plan_id
                            ,p_calc_end_date
                            ,p_initialise_type
                            ,p_start_date
                            ,p_end_date );
      fetch c_get_initialise into l_initialise;
      close c_get_initialise;

      hr_utility.trace('Initialise : '||to_char(l_initialise));
      hr_utility.set_location('  Out: ' || l_proc,10) ;

      return(nvl(l_initialise,0));

  end get_leave_initialise ;


  -----------------------------------------------------------------------------
  --
  --  Find long service leave entitlement date
  --
  --  Because LSL has two entitlement periods they cannot be stored
  --
  --  Find long service leave entitlement date
  --
  --  Because LSL has two entitlement periods they cannot be stored
  --  in the standard PTO model.  For LSL we get the periods from the
  --  different in the from and to dates in the plan accrual bands.
  --
  --  public function called by Long Service Leave Formulae
  --
  -----------------------------------------------------------------------------

  function get_lsl_entitlement_date
    ( p_accrual_plan_id                 in          NUMBER
     ,p_assignment_id                   in          NUMBER
     ,p_enrollment_date                 in          DATE
     ,p_service_start_date              in          DATE
     ,p_calculation_date                in          DATE
     ,p_next_entitlement_date           in out NOCOPY DATE)
    return date is

      l_proc                          varchar2(61) := 'hr_au_holidays.get_lsl_entitlement_date' ;
      l_first_period                  number;
      l_subsequent_periods            number;
      l_entitlement_date              date;
      l_next_entitlement_date         date;
      l_eot                           date         := to_date('31124712','DDMMYYYY');

      --  find lsl entitlement periods
      cursor c_accrual_bands (v_accrual_plan_id number) is
        select (ab.upper_limit - ab.lower_limit)
        from   pay_accrual_bands ab
        where  ab.accrual_plan_id = v_accrual_plan_id
        order by
               ab.lower_limit ;

    begin

      hr_utility.set_location('  In: ' || l_proc, 5) ;

      open c_accrual_bands (p_accrual_plan_id);
      fetch c_accrual_bands into l_first_period;
      fetch c_accrual_bands into l_subsequent_periods;
      close c_accrual_bands;

      hr_utility.trace('First      : '||to_char(l_first_period) );
      hr_utility.trace('Subsequent : '||to_char(l_subsequent_periods) );

      if (l_first_period <= 0) OR (l_subsequent_periods <= 0) then
          hr_utility.set_message(801,'HR_AU_INVALID_LSL_PERIODS');
          hr_utility.raise_error;
      end if;

      --  set entitlement date to end of first period plus any suspension
      --  adjustment
      l_entitlement_date := p_service_start_date;

      p_next_entitlement_date := hr_au_holidays.adjust_for_suspend_assign
                              (p_assignment_id
                              ,add_months(p_service_start_date, (l_first_period * 12) )
                              ,p_service_start_date
                              ,l_eot);

      if p_calculation_date < p_next_entitlement_date then
        return (l_entitlement_date);
      end if;

      --  while next date is less that calculation date keep adding
      --  subsequent entitlement periods
      while  p_calculation_date >= p_next_entitlement_date loop

        l_entitlement_date := p_next_entitlement_date;

        p_next_entitlement_date := hr_au_holidays.adjust_for_suspend_assign
                                    (p_assignment_id
                                    ,add_months(l_entitlement_date, (l_subsequent_periods * 12) )
                                    ,l_entitlement_date
                                    ,l_eot);

      end loop;

      hr_utility.set_location('  Out: ' || l_proc, 10) ;

      return (l_entitlement_date);

--    EXCEPTION
--            WHEN others THEN
--              hr_utility.trace('Error - cursor c_accrual_bands failed - Accrual Plan ID: '||to_char(p_accrual_plan_id) );
--              hr_utility.set_location('Leaving: '||l_proc,99);
--              RETURN (p_service_start_date - 1);

  end get_lsl_entitlement_date;


  -----------------------------------------------------------------------------
  --
  --  Validate Accrual Plan Name in Entitlement Adjustment Element Input Value
  --
  -----------------------------------------------------------------------------

  function validate_accrual_plan_name
    ( p_business_group_id               in          NUMBER
     ,p_entry_value                     in          VARCHAR2)
    return number is

      l_proc                          varchar2(61) := 'hr_au_holidays.validate_accrual_plan_name' ;
      l_plan_exists                   number       := 0;

      --  find plan name
      cursor c_plan_name ( v_business_group_id   number
                          ,v_entry_value         varchar2 ) is
        select 1
        from   pay_accrual_plans    pap
        where  pap.business_group_id = v_business_group_id
        and    pap.accrual_plan_name = v_entry_value;

    begin

      hr_utility.set_location('  In: ' || l_proc, 5) ;

      open c_plan_name ( p_business_group_id
                        ,p_entry_value);
      fetch c_plan_name into l_plan_exists;

      if c_plan_name%notfound then
        l_plan_exists := 0;
      end if;

      close c_plan_name;

      hr_utility.set_location('  Out: ' || l_proc, 10) ;

      return (l_plan_exists);

    --EXCEPTION
    --        WHEN others THEN
    --          hr_utility.set_location('Leaving: '||l_proc,99);
    --          RETURN (99);

  end validate_accrual_plan_name;

/*Bug# 7607177 --This function is called from AU_ANNUAL_LEAVE_ACCRUAL_DAILY fast formula
                 to get the correct enrollment start date for calculating the PTO Accruals*/
/*Bug# 8604518 --In the cursor,the date joins on the table 'pay_element_entries_f' are modified
                 to return rows when Annual Leave and LSL are paid to terminated employees */
function au_get_enrollment_startdate
 ( p_accrual_plan_id              in      number
  ,p_assignment_id                in      number
  ,p_calculation_date             in      date  )
return date
is

  l_enrollment_startdate date;

  cursor c_enrollment_startdate(v_accrual_plan_id  number
                                   ,v_assignment_id    number
                                   ,v_calculation_date date )
  is
  select min(PEE.EFFECTIVE_START_DATE)
  from   pay_accrual_plans pap,
         pay_element_types_f pet,
         pay_element_links_f pel,
         pay_element_entries_f pee,
         per_assignments_f paf,
         per_periods_of_service pps
  where  pee.element_link_id = pel.element_link_id
  and    pel.element_type_id = pet.element_type_id
  and    pet.element_type_id = pap.accrual_plan_element_type_id
  and    paf.assignment_id = pee.assignment_id
  and    paf.period_of_service_id =pps.period_of_service_id
  and    pee.entry_type ='E'
  and    pee.assignment_id = v_assignment_id
  and    pap.accrual_plan_id = v_accrual_plan_id
  and    pee.effective_end_date >= pps.date_start
  and    pee.effective_start_date <= nvl(pps.actual_termination_date,to_date('31/12/4712','dd/mm/yyyy'))
  and    pps.date_start between paf.effective_start_date and paf.effective_end_date
  and    v_calculation_date between pel.effective_start_date
                                and pel.effective_end_date
  and    v_calculation_date between pet.effective_start_date
                                and pet.effective_end_date;

 begin

  open c_enrollment_startdate(p_accrual_plan_id,p_assignment_id,p_calculation_date);
 fetch c_enrollment_startdate into l_enrollment_startdate;
 close c_enrollment_startdate;

 return l_enrollment_startdate;

end au_get_enrollment_startdate;
/*End --Bug7607177 */
END hr_au_holidays;

/
