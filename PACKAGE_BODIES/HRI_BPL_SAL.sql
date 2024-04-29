--------------------------------------------------------
--  DDL for Package Body HRI_BPL_SAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_BPL_SAL" AS
/* $Header: hribsal.pkb 120.2 2006/05/17 04:39:20 rkonduru noship $ */
--
-- Declare global variables.
--
g_currency        VARCHAR2(3);
g_salary          NUMBER;
g_assignment_id   NUMBER;
g_date            DATE;
TYPE g_varchar_tabtype IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
g_rate_type_tab   g_varchar_tabtype;
g_default_rate_type   VARCHAR2(30) := fnd_profile.value('BIS_PRIMARY_RATE_TYPE');
--
-- -------------------------------------------------------------------------
--
PROCEDURE fetch_currency_and_salary(p_assignment_id  IN NUMBER,
                                      p_date           IN DATE) IS
  -- bug 3553301
  l_salary          NUMBER;
  l_currency        VARCHAR2(100);
  --
  CURSOR c_salary_value
  ( p_assignment_id    NUMBER
  , p_effective_date   DATE)
  IS
  select  s.proposed_salary_n* ppb.pay_annualization_factor salary
  --      nvl(ppb.pay_annualization_factor,tpt.number_per_fiscal_year) salary -- bug 3547581
  ,       pet.input_currency_code                    salary_currency_code
  from    pay_element_types_f pet
  ,       pay_input_values_f piv
  ,       per_pay_bases ppb
  --,       per_time_period_types tpt  -- bug 3547581
  --,       pay_all_payrolls_f prl     -- bug 3547581
  ,       per_assignments_f a
  ,       per_pay_proposals_v2 s
  where  a.assignment_type = 'E'
  and    a.assignment_id = p_assignment_id
  and    p_effective_date between a.effective_start_date and a.effective_end_date
  and    s.change_date IN (select max(ppp2.change_date)
                           from per_pay_proposals_v2 ppp2
                           where ppp2.change_date <= p_effective_date
                           and   ppp2.assignment_id = a.assignment_id)
  and    a.pay_basis_id = ppb.pay_basis_id
  and    ppb.input_value_id = piv.input_value_id
  -- bug 3547581
  /*and    s.change_date between
         prl.effective_start_date and prl.effective_end_date
  and    a.payroll_id=prl.payroll_id
  and    prl.period_type=tpt.period_type  */
  and    p_effective_date between
             piv.effective_start_date and piv.effective_end_date
  and    piv.element_type_id = pet.element_type_id
  and    p_effective_date between
             pet.effective_start_date and pet.effective_end_date
  and    a.assignment_id = s.assignment_id
  and   s.approved = 'Y'
  order by a.assignment_id;
  --
BEGIN
  --
  OPEN c_salary_value(p_assignment_id,
                       p_date);
  FETCH c_salary_value INTO l_salary, l_currency;
  --
  -- bug 3553301: get the cursor value in a local varibale first and therefore it does not
  -- incorrectly cache data.
  --
  g_salary := NVL(l_salary,0);
  --
  g_currency := NVL(l_currency,'NA_EDW');
  --
  CLOSE c_salary_value;
  --
  g_assignment_id := p_assignment_id;
  g_date          := p_date;
  --
END fetch_currency_and_salary;
-- -------------------------------------------------------------------------
FUNCTION get_assignment_sal(p_assignment_id  IN NUMBER,
                            p_date           IN DATE)
RETURN NUMBER IS
BEGIN
  IF (p_assignment_id = g_assignment_id) AND (p_date = g_date) THEN
    RETURN g_salary;
  END IF;
  fetch_currency_and_salary(p_assignment_id, p_date);
  RETURN g_salary;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_assignment_sal;
-- -------------------------------------------------------------------------
FUNCTION get_assignment_currency(p_assignment_id  IN NUMBER,
                                 p_date           IN DATE)
RETURN VARCHAR2 IS
BEGIN
  IF (p_assignment_id = g_assignment_id) AND (p_date = g_date) THEN
    RETURN g_currency;
  END IF;
  fetch_currency_and_salary(p_assignment_id, p_date);
  RETURN g_currency;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END get_assignment_currency;
--
FUNCTION convert_amount(p_from_currency      IN VARCHAR2,
                        p_to_currency        IN VARCHAR2,
                        p_conversion_date    IN DATE,
                        p_amount             IN NUMBER,
                        p_business_group_id  IN NUMBER DEFAULT NULL)
            RETURN NUMBER IS

  l_result     NUMBER;
  l_rate_type  VARCHAR2(30);

BEGIN

/* If a business group id is given look for an overriding rate type */
  IF (p_business_group_id IS NOT NULL) THEN

  /* Trap exception in sql block for cache miss */
    BEGIN
    /* Check cache for rate type */
      l_rate_type := g_rate_type_tab(p_business_group_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      /* If there is no rate type stored in the cache, find the rate type */
      /* for the given business group */
        l_rate_type := hr_currency_pkg.get_rate_type
                         (p_business_group_id => p_business_group_id,
                          p_conversion_date => p_conversion_date,
                          p_processing_type => 'I');
     /* If no rate type is found, use the default */
        IF (l_rate_type IS NULL) THEN
          l_rate_type := g_default_rate_type;
        END IF;
     /* Cache the rate type for next time */
        g_rate_type_tab(p_business_group_id) := l_rate_type;
    END;

  ELSE
  /* No business group given, so use the default rate type */
    l_rate_type := g_default_rate_type;

  END IF;

--  l_result := hr_currency_pkg.convert_amount
  l_result := hri_bpl_currency.convert_currency_amount
                (p_from_currency => p_from_currency,
                 p_to_currency => p_to_currency,
                 p_conversion_date => p_conversion_date,
                 p_amount => p_amount,
                 p_rate_type => l_rate_type);

  RETURN l_result;

END convert_amount;
--
-- Salary conversion function for DBI moved from HRI_DBI_SALARY
--
FUNCTION convert_amount(p_from_currency      IN VARCHAR2,
                        p_to_currency        IN VARCHAR2,
                        p_conversion_date    IN DATE,
                        p_amount             IN NUMBER,
                        p_rate_type          IN VARCHAR2)
            RETURN NUMBER IS

  l_converted_amount      NUMBER := 0;

BEGIN

  IF (p_from_currency IS NOT NULL AND
      p_to_currency IS NOT NULL AND
      p_amount IS NOT NULL)
  THEN
    IF (p_from_currency = 'NA_EDW')
    THEN
      l_converted_amount := p_amount ;
    ELSE
--      l_converted_amount := hr_currency_pkg.convert_amount
      l_converted_amount := hri_bpl_currency.convert_currency_amount
                             (p_from_currency    => p_from_currency
                             ,p_to_currency      => p_to_currency
                             ,p_conversion_date  => p_conversion_date
                             ,p_amount           => p_amount
                             ,p_rate_type        => p_rate_type);
    END IF;
  ELSE
  -- no salary for this assignment.
    l_converted_amount := 0;
  END IF;

  RETURN l_converted_amount ;

END convert_amount;
--
-- ----------------------------------------------------------------------------
-- FUNCTION    GET_ANNUALIZATION_FACTOR
-- ----------------------------------------------------------------------------
-- When the pay basis type is PERIOD then the annualization factor can be null.
-- In such cases the annualization factor is same as the yearly frequency of
-- the payroll. This function returns the annualization factor is such cases.
-- ----------------------------------------------------------------------------
--
FUNCTION get_perd_annualization_factor( p_assignment_id  IN NUMBER,
                                        p_effective_date IN DATE)
RETURN NUMBER IS
--
  l_dummy VARCHAR2(240);
  l_pay_annualization_factor NUMBER;
--
BEGIN
--
  PER_PAY_PROPOSALS_POPULATE.GET_PAYROLL(p_assignment_id
                       ,p_effective_date
                       ,l_dummy
                       ,l_pay_annualization_factor);
  --
  RETURN l_pay_annualization_factor;
  --
--
END get_perd_annualization_factor;
--
END hri_bpl_sal;

/
