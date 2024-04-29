--------------------------------------------------------
--  DDL for Package Body PAY_CA_GROUP_LEVEL_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_GROUP_LEVEL_BAL_PKG" AS
/* $Header: pycatxbv.pkb 120.1.12000000.1 2007/01/17 17:37:22 appldev noship $ */

-------------------------------------------------------------------------------
-- Name:       get_date_mask
--
-- Parameters: p_time_dimension
--
-- Return:     VARCHAR2 - the new date mask
--
-- Description: This function calculates the correct date mask for the given
--              time dimension.
-------------------------------------------------------------------------------
FUNCTION get_date_mask (p_time_dimension VARCHAR2) RETURN VARCHAR2 IS

l_date_mask VARCHAR2(5) := '';
l_routine_name VARCHAR2(64) := 'pay_ca_group_level_bal_pkg.get_date_mask';

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  IF p_time_dimension = 'YTD' THEN
    l_date_mask := 'Y';
    hr_utility.trace(l_routine_name||': 20');
  ELSIF p_time_dimension = 'QTD' THEN
    l_date_mask := 'Q';
    hr_utility.trace(l_routine_name||': 30');
  ELSIF p_time_dimension = 'MONTH' THEN
    l_date_mask := 'MONTH';
    hr_utility.trace(l_routine_name||': 40');
  ELSE
    pay_us_balance_view_pkg.debug_err('Invalid time dimension');
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_date_mask;

END get_date_mask;

-------------------------------------------------------------------------------
-- Name:       get_asg_virtual_date
--
-- Parameters: p_assignment_id
--             p_date_earned
--             p_date_mask
--
-- Return:     DATE - the new validated date
--
-- Description: This function finds the date of the last assignment with a
--              payroll.
-------------------------------------------------------------------------------
FUNCTION get_asg_virtual_date (p_assignment_id NUMBER,
                               p_date_earned   DATE,
                               p_date_mask     VARCHAR2) RETURN DATE IS

CURSOR csr_get_max_asg_end_date(p_asg_id    NUMBER,
                                p_date      DATE,
                                p_date_mask VARCHAR2) IS
  SELECT MAX(asg.effective_end_date)
  FROM   per_all_assignments_f asg
  WHERE  asg.assignment_id = p_asg_id
  AND    asg.payroll_id IS NOT NULL
  AND    asg.effective_end_date BETWEEN TRUNC(p_date, p_date_mask)
                                    AND p_date;

l_routine_name VARCHAR2(64):='pay_ca_group_level_bal_pkg.get_asg_virtual_date';

l_asg_virtual_date     DATE;
e_no_valid_date_exists EXCEPTION;

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  OPEN csr_get_max_asg_end_date(p_assignment_id,
                                p_date_earned,
                                p_date_mask);
  FETCH csr_get_max_asg_end_date INTO l_asg_virtual_date;
  IF csr_get_max_asg_end_date%NOTFOUND THEN
    hr_utility.trace(l_routine_name||': 20');
    RAISE e_no_valid_date_exists;
  END IF;

  hr_utility.trace
              ('Ending routine: '||l_routine_name);
  RETURN l_asg_virtual_date;
EXCEPTION
  WHEN e_no_valid_date_exists THEN
    hr_utility.trace(l_routine_name||': 40');
    NULL;
END get_asg_virtual_date;

-------------------------------------------------------------------------------
-- Name:       get_virtual_date
--
-- Parameters: p_assignment_id
--             p_virtual_date
--             p_date_mask
--
-- Return:     DATE - the validated date
--
-- Description: This function ensures that the assignment is on a payroll on
--              effective date and if not, a valid date is found.
--              If no valid date can be found then an error is raised.
-------------------------------------------------------------------------------
FUNCTION get_virtual_date (p_assignment_id NUMBER,
                           p_virtual_date  DATE,
                           p_date_mask     VARCHAR2) RETURN DATE IS

CURSOR csr_asg_in_payroll(p_asg_id NUMBER,
                          p_date   DATE) IS
  SELECT 'X'
  FROM   per_all_assignments_f asg,
         pay_all_payrolls_f        pay
  WHERE  asg.assignment_id   = p_asg_id
  AND    p_date BETWEEN asg.effective_start_date
                    AND asg.effective_end_date
  AND    asg.payroll_id      = pay.payroll_id
  AND    p_date BETWEEN pay.effective_start_date
                    AND pay.effective_end_date;

CURSOR csr_get_virtual_date(p_asg_id    NUMBER,
                            p_date      DATE,
                            p_date_mask VARCHAR2) IS
  SELECT MAX(pay.effective_end_date)
  FROM   pay_all_payrolls_f        pay,
         per_all_assignments_f asg
  WHERE  asg.assignment_id = p_asg_id
  AND    asg.payroll_id    = pay.payroll_id
  AND    pay.effective_end_date BETWEEN TRUNC(p_date, p_date_mask)
                                    AND p_date;

l_routine_name         VARCHAR2(64):='pay_ca_group_level_bal_pkg.get_virtual_date';

l_asg_in_payroll       VARCHAR2(1);
l_virtual_date         DATE;
l_altered_date         DATE;
l_res_date             DATE;
e_no_valid_date_exists EXCEPTION;

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  OPEN csr_asg_in_payroll(p_assignment_id,
                          p_virtual_date);
  FETCH csr_asg_in_payroll INTO l_asg_in_payroll;
  IF csr_asg_in_payroll%NOTFOUND THEN
    hr_utility.trace(l_routine_name||': 20');
    l_virtual_date := get_asg_virtual_date (p_assignment_id,
                                           p_virtual_date,
                                           p_date_mask);
    OPEN csr_get_virtual_date(p_assignment_id,
                              p_virtual_date,
                              p_date_mask);
    FETCH csr_get_virtual_date INTO l_altered_date;
    IF l_virtual_date IS NULL THEN
      hr_utility.trace(l_routine_name||': 30');
      IF l_altered_date IS NULL THEN
        hr_utility.trace(l_routine_name||': 40');
        RAISE e_no_valid_date_exists;
      ELSE
        hr_utility.trace(l_routine_name||': 50');
        l_res_date := l_virtual_date;
      END IF;
    ELSE
      IF l_altered_date IS NULL THEN
        hr_utility.trace(l_routine_name||': 60');
        l_res_date := l_virtual_date;
      ELSE
        hr_utility.trace(l_routine_name||': 70');
        l_res_date := LEAST (l_virtual_date, l_altered_date);
      END IF;
    END IF;
  ELSE
    hr_utility.trace(l_routine_name||': 80');
    l_res_date := p_virtual_date;
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_res_date;
EXCEPTION
  WHEN e_no_valid_date_exists THEN
    hr_utility.trace(l_routine_name||': 100');
END get_virtual_date;

-------------------------------------------------------------------------------
-- Name:       get_defined_balance
--
-- Parameters: p_balance_name
--             p_dimension
--             p_business_group_id
--
-- Return:     NUMBER - Defined Balance Id
--
-- Description: This function finds the defined balance id given the balance
--              name and dimension.
-------------------------------------------------------------------------------
FUNCTION get_defined_balance (p_balance_name      VARCHAR2,
                              p_dimension         VARCHAR2,
                              p_business_group_id NUMBER DEFAULT NULL
                              ) RETURN NUMBER IS

CURSOR csr_get_def_bal_id(p_bal_name   VARCHAR2,
                          p_dimension  VARCHAR2,
                          p_bus_grp_id NUMBER) IS
  SELECT dbl.defined_balance_id
  FROM   pay_defined_balances dbl
  WHERE  dbl.balance_type_id  = (SELECT balance_type_id
                                 FROM   pay_balance_types blt
                                 WHERE  blt.balance_name      = p_bal_name
                                 AND   (blt.legislation_code  = 'CA'
                                   OR   blt.business_group_id = p_bus_grp_id))
  AND dbl.balance_dimension_id =(SELECT balance_dimension_id
                                 FROM   pay_balance_dimensions bld
                                 WHERE  bld.database_item_suffix =
                                                             '_'|| p_dimension
                                 AND   (bld.legislation_code  = 'CA'
                                   OR   bld.business_group_id = p_bus_grp_id))
  AND  (dbl.legislation_code  = 'CA'
    OR  dbl.business_group_id = p_bus_grp_id);

l_routine_name VARCHAR2(64) := 'pay_ca_group_level_bal_pkg.get_defined_balance';

l_defined_balance_id  NUMBER;
l_business_group_id   NUMBER;

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  hr_utility.trace('Balance type: '||p_balance_name);
  hr_utility.trace('Balance Dimension: '||p_dimension);
  OPEN csr_get_def_bal_id(p_balance_name,
                          p_dimension,
                          p_business_group_id);
  FETCH csr_get_def_bal_id INTO l_defined_balance_id;
  IF csr_get_def_bal_id%NOTFOUND THEN
    pay_us_balance_view_pkg.debug_err
                    ('No defined balance exists.');
    l_defined_balance_id := NULL;
  END IF;
  CLOSE csr_get_def_bal_id;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_defined_balance_id;

END get_defined_balance;

-------------------------------------------------------------------------------
-- Name:       get_grp_pydate_with_aa
--
-- Parameters:
--             p_lb_dimension
--             p_balance_name
--             p_effective_date
--             p_start_date
--             p_jurisdiction_code
--             p_gre_id
--             p_source_id
--             p_organization_id
--             p_location_id
--             p_payroll_id
--             p_pay_basis_type
--             p_business_group_id
--
-- Return:     NUMBER - The value of the group level balance
--
-- Description: This function calculates the balance value for all PYDATE level
--              balance wich have at least one parameter which is not a context.
--              This function is split into two parts: when the pay basis type
--              NULL and when it has a value.
-------------------------------------------------------------------------------
FUNCTION get_grp_pydate_with_aa
                          (p_lb_dimension   VARCHAR2,
                           p_balance_name   VARCHAR2,
                           p_effective_date DATE,
                           p_start_date     DATE,
                           p_jurisdiction   VARCHAR2,
                           p_gre_id         NUMBER,
                           p_source_id      NUMBER,
                           p_organization_id NUMBER,
                           p_location_id    NUMBER,
                           p_payroll_id     NUMBER,
                           p_pay_basis_type VARCHAR2,
                           p_business_group_id NUMBER) RETURN NUMBER IS

/*
 * Select all the assignment actions in PAY_ACTION_CONTEXTS for a given GRE
 * which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */
CURSOR csr_get_asg_gre_add(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_gre_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE) IS
  SELECT DISTINCT asa.assignment_action_id
  FROM   pay_payroll_actions    pya,
         pay_assignment_actions asa,
         per_all_assignments_f  asg
  WHERE  asg.organization_id   = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id       = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id        = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                          ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND    asa.assignment_id     = asg.assignment_id
  AND    asa.tax_unit_id       = p_gre_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.effective_date BETWEEN p_start_date
                                AND p_end_date;

CURSOR csr_get_asg_src_add(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_src_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE) IS
  SELECT DISTINCT asa.assignment_action_id
  FROM   per_all_assignments_f  asg,
         pay_payroll_actions    pya,
         pay_assignment_actions asa,
         pay_action_contexts    acx,
         ff_contexts            cxt
  WHERE  cxt.context_name    = 'SOURCE_ID'
  AND    cxt.context_id      = acx.context_id
  AND    acx.context_value   = TO_CHAR(p_src_id)
  AND    asa.assignment_action_id = acx.assignment_action_id
  AND    pya.payroll_action_id    = asa.payroll_action_id
  AND    pya.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    acx.assignment_id   = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE and
 * jurisdiction which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */
CURSOR csr_get_asg_jd_gre_add(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_gre_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE) IS
  SELECT DISTINCT asa.assignment_action_id
  FROM   per_all_assignments_f  asg,
         pay_payroll_actions    pya,
         pay_assignment_actions asa,
         pay_action_contexts    acx,
         ff_contexts            cxt
  WHERE  cxt.context_name    = 'JURISDICTION_CODE'
  AND    cxt.context_id      = acx.context_id
  AND    acx.context_value   = p_jd
  AND    acx.assignment_action_id = asa.assignment_action_id
  AND    asa.tax_unit_id          = p_gre_id
  AND    pya.payroll_action_id    = asa.payroll_action_id
  AND    pya.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    acx.assignment_id   = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));

CURSOR csr_get_asg_jd_src_add(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_src_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE) IS
  SELECT DISTINCT asa.assignment_action_id
  FROM   per_all_assignments_f  asg,
         pay_payroll_actions    pya,
         pay_assignment_actions asa,
         pay_action_contexts    acx2,
         ff_contexts            cxt2,
         pay_action_contexts    acx1,
         ff_contexts            cxt1
  WHERE  cxt1.context_name   = 'SOURCE_ID'
  AND    cxt1.context_id     = acx1.context_id
  AND    acx1.context_value  = TO_CHAR(p_src_id)
  AND    cxt2.context_name   = 'JURISDICTION_CODE'
  AND    cxt2.context_id     = acx2.context_id
  AND    acx2.context_value  = p_jd
  AND    asa.assignment_action_id = acx1.assignment_action_id
  AND    asa.assignment_action_id = acx2.assignment_action_id
  AND    asa.tax_unit_id          = p_gre_id
  AND    pya.payroll_action_id    = asa.payroll_action_id
  AND    pya.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    acx1.assignment_id  = asg.assignment_id
  AND    acx2.assignment_id  = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));


l_routine_name VARCHAR2(64) :=
               'pay_ca_group_level_bal_pkg.get_grp_pydate_with_aa';

l_lb_defined_balance_id NUMBER(9);
l_balance_value         NUMBER(38,10) := 0;
l_run_dimension         VARCHAR2(30);

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  l_run_dimension := REPLACE(p_lb_dimension, 'PYDATE', 'RUN');

  l_lb_defined_balance_id := get_defined_balance(p_balance_name,
                                                 l_run_dimension,
                                                 p_business_group_id);
  IF l_lb_defined_balance_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF p_source_id IS NOT NULL THEN
    /*
     * Loop through all the assignment actions for this Reporting Unit
     * (Source Id) and sum the latest balance value for each one
     */
    hr_utility.trace(l_routine_name||': 30');
    IF p_jurisdiction IS NULL THEN
      FOR r_asg IN csr_get_asg_src_add(p_organization_id,
                                       p_location_id,
                                       p_payroll_id,
                                       p_pay_basis_type,
                                       p_source_id,
                                       p_start_date,
                                       p_effective_date) LOOP
        hr_utility.trace(l_routine_name||': 60');
        l_balance_value := l_balance_value +
                   pay_ca_balance_view_pkg.get_value
                        (p_assignment_action_id => r_asg.assignment_action_id,
                         p_defined_balance_id   => l_lb_defined_balance_id,
                         p_dont_cache           => 1,
                         p_always_get_dbi       => 0);
      END LOOP;
    ELSE
      FOR r_asg IN csr_get_asg_jd_src_add(p_organization_id,
                                          p_location_id,
                                          p_payroll_id,
                                          p_pay_basis_type,
                                          p_source_id,
                                          p_jurisdiction,
                                          p_start_date,
                                          p_effective_date) LOOP
        hr_utility.trace(l_routine_name||': 70');
        l_balance_value := l_balance_value +
                  pay_ca_balance_view_pkg.get_value
                        (p_assignment_action_id => r_asg.assignment_action_id,
                         p_defined_balance_id   => l_lb_defined_balance_id,
                         p_dont_cache           => 1,
                         p_always_get_dbi       => 0);
      END LOOP;
    END IF;
  ELSE
    /*
     * Loop through all the assignments for this GRE and sum the latest
     * balance value for each one
     */
    hr_utility.trace(l_routine_name||': 80');
    IF p_jurisdiction IS NULL THEN
      FOR r_asg IN csr_get_asg_gre_add(p_organization_id,
                                       p_location_id,
                                       p_payroll_id,
                                       p_pay_basis_type,
                                       p_gre_id,
                                       p_start_date,
                                       p_effective_date) LOOP
        hr_utility.trace(l_routine_name||': 110');
        l_balance_value := l_balance_value +
                  pay_ca_balance_view_pkg.get_value
                      (p_assignment_action_id => r_asg.assignment_action_id,
                       p_defined_balance_id   => l_lb_defined_balance_id,
                       p_dont_cache           => 1,
                       p_always_get_dbi       => 0);
      END LOOP;
    ELSE
      FOR r_asg IN csr_get_asg_jd_gre_add(p_organization_id,
                                          p_location_id,
                                          p_payroll_id,
                                          p_pay_basis_type,
                                          p_gre_id,
                                          p_jurisdiction,
                                          p_start_date,
                                          p_effective_date) LOOP
        hr_utility.trace(l_routine_name||': 120');
        l_balance_value := l_balance_value +
                  pay_ca_balance_view_pkg.get_value
                      (p_assignment_action_id => r_asg.assignment_action_id,
                       p_defined_balance_id   => l_lb_defined_balance_id,
                       p_dont_cache           => 1,
                       p_always_get_dbi       => 0);
      END LOOP;
    END IF;
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_balance_value;
END get_grp_pydate_with_aa;



-------------------------------------------------------------------------------
-- Name:       get_grp_pydate_with_aa_rb
--
-- Parameters:
--             p_lb_dimension
--             p_balance_name
--             p_effective_date
--             p_start_date
--             p_jurisdiction_code
--             p_gre_id
--             p_source_id
--             p_organization_id
--             p_location_id
--             p_payroll_id
--             p_pay_basis_type
--             p_business_group_id
--
-- Return:     NUMBER - The value of the group level balance
--
-- Description: This function calculates the balance value for all PYDATE level
--              balance wich have at least one parameter which is not a context.
--              This function is split into two parts: when the pay basis type
--              NULL and when it has a value.
--              Uses PAY_RUN_BALANCES tables for all cursors in this function.
-------------------------------------------------------------------------------
FUNCTION get_grp_pydate_with_aa_rb
                          (p_lb_dimension   VARCHAR2,
                           p_balance_name   VARCHAR2,
                           p_effective_date DATE,
                           p_start_date     DATE,
                           p_jurisdiction   VARCHAR2,
                           p_gre_id         NUMBER,
                           p_source_id      NUMBER,
                           p_organization_id NUMBER,
                           p_location_id    NUMBER,
                           p_payroll_id     NUMBER,
                           p_pay_basis_type VARCHAR2,
                           p_business_group_id NUMBER) RETURN NUMBER IS

/*
 * Select all the assignment actions in PAY_ACTION_CONTEXTS for a given GRE
 * which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */

-- NEW EBRA CURSOR csr_get_asg_gre_add definition with pay_run_balances
-- validation.
CURSOR csr_get_asg_gre_add_rb(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_gre_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE,
                           p_def_bal_id NUMBER) IS
  SELECT DISTINCT prb.assignment_action_id
  FROM   pay_run_balances prb,
         per_all_assignments_f  asg
  WHERE  asg.organization_id   = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id       = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id        = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                          ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND    prb.assignment_id     = asg.assignment_id
  AND    prb.tax_unit_id       = p_gre_id
  AND    prb.defined_balance_id   = p_def_bal_id
  AND    prb.effective_date BETWEEN p_start_date
                                AND p_end_date;


-- NEW EBRA CURSOR csr_get_asg_src_add definition with
-- pay_run_balances validation.
CURSOR csr_get_asg_src_add_rb(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_src_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE,
                           p_def_bal_id NUMBER) IS
  SELECT DISTINCT prb.assignment_action_id
  FROM   per_all_assignments_f  asg,
         pay_run_balances prb
  WHERE  prb.source_id   = p_src_id
  AND    prb.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    prb.assignment_id   = asg.assignment_id
  AND    prb.defined_balance_id = p_def_bal_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));


/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE and
 * jurisdiction which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */

-- NEW EBRA CURSOR csr_get_asg_jd_gre_add definition with
-- pay_run_balances validation
CURSOR csr_get_asg_jd_gre_add_rb(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_gre_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE,
                              p_def_bal_id NUMBER) IS
  SELECT DISTINCT prb.assignment_action_id
  FROM   per_all_assignments_f  asg,
         pay_run_balances prb
  WHERE  prb.jurisdiction_code   = p_jd
  AND    prb.tax_unit_id          = p_gre_id
  AND    prb.defined_balance_id   = p_def_bal_id
  AND    prb.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    prb.assignment_id   = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));



CURSOR csr_get_asg_jd_src_add(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_src_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE) IS
  SELECT DISTINCT asa.assignment_action_id
  FROM   per_all_assignments_f  asg,
         pay_payroll_actions    pya,
         pay_assignment_actions asa,
         pay_action_contexts    acx2,
         ff_contexts            cxt2,
         pay_action_contexts    acx1,
         ff_contexts            cxt1
  WHERE  cxt1.context_name   = 'SOURCE_ID'
  AND    cxt1.context_id     = acx1.context_id
  AND    acx1.context_value  = TO_CHAR(p_src_id)
  AND    cxt2.context_name   = 'JURISDICTION_CODE'
  AND    cxt2.context_id     = acx2.context_id
  AND    acx2.context_value  = p_jd
  AND    asa.assignment_action_id = acx1.assignment_action_id
  AND    asa.assignment_action_id = acx2.assignment_action_id
  AND    asa.tax_unit_id          = p_gre_id
  AND    pya.payroll_action_id    = asa.payroll_action_id
  AND    pya.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    acx1.assignment_id  = asg.assignment_id
  AND    acx2.assignment_id  = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));


l_routine_name VARCHAR2(64) :=
               'pay_ca_group_level_bal_pkg.get_grp_pydate_with_aa_rb';

l_lb_defined_balance_id NUMBER(9);
l_balance_value         NUMBER(38,10) := 0;
l_run_dimension         VARCHAR2(30);
l_ge_def_bal_id         NUMBER(20);

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  l_run_dimension := REPLACE(p_lb_dimension, 'PYDATE', 'RUN');

  l_lb_defined_balance_id := get_defined_balance(p_balance_name,
                                                 l_run_dimension,
                                                 p_business_group_id);

  /* To check in run_balances table with def_bal_id and get valid
     Assignment or Assignment Action for Balance calls */

  If p_jurisdiction is NULL then
    l_ge_def_bal_id := get_defined_balance(p_balance_name,
                                           'ASG_GRE_RUN',
                                            p_business_group_id);
    hr_utility.trace('Def_bal_id of '||p_balance_name||'_ASG_GRE_RUN : '||to_char(l_ge_def_bal_id));

  Else

    l_ge_def_bal_id := get_defined_balance(p_balance_name,
                                         'ASG_JD_GRE_RUN',
                                          p_business_group_id);
    hr_utility.trace('Def_bal_id of '||p_balance_name||'_ASG_JD_GRE_RUN : '||to_char(l_ge_def_bal_id));
  End if;

  hr_utility.trace('Def_bal_id of GROSS_EARNINGS_ASG_JD_GRE_RUN : '||to_char(l_ge_def_bal_id));

  IF l_lb_defined_balance_id IS NULL THEN
    RETURN NULL;
  END IF;

  IF p_source_id IS NOT NULL THEN
    /*
     * Loop through all the assignment actions for this Reporting Unit
     * (Source Id) and sum the latest balance value for each one
     */
    hr_utility.trace(l_routine_name||': 30');
    IF p_jurisdiction IS NULL THEN

      FOR r_asg IN csr_get_asg_src_add_rb(p_organization_id,
                                       p_location_id,
                                       p_payroll_id,
                                       p_pay_basis_type,
                                       p_source_id,
                                       p_start_date,
                                       p_effective_date,
                                       l_ge_def_bal_id) LOOP
        hr_utility.trace(l_routine_name||': 60');
        l_balance_value := l_balance_value +
                   pay_ca_balance_view_pkg.get_value
                        (p_assignment_action_id => r_asg.assignment_action_id,
                         p_defined_balance_id   => l_lb_defined_balance_id,
                         p_dont_cache           => 1,
                         p_always_get_dbi       => 0);
      END LOOP;
    ELSE
      FOR r_asg IN csr_get_asg_jd_src_add(p_organization_id,
                                          p_location_id,
                                          p_payroll_id,
                                          p_pay_basis_type,
                                          p_source_id,
                                          p_jurisdiction,
                                          p_start_date,
                                          p_effective_date) LOOP
        hr_utility.trace(l_routine_name||': 70');
        l_balance_value := l_balance_value +
                  pay_ca_balance_view_pkg.get_value
                        (p_assignment_action_id => r_asg.assignment_action_id,
                         p_defined_balance_id   => l_lb_defined_balance_id,
                         p_dont_cache           => 1,
                         p_always_get_dbi       => 0);
      END LOOP;
    END IF;
  ELSE
    /*
     * Loop through all the assignments for this GRE and sum the latest
     * balance value for each one
     */
    hr_utility.trace(l_routine_name||': 80');
    IF p_jurisdiction IS NULL THEN
      FOR r_asg IN csr_get_asg_gre_add_rb(p_organization_id,
                                       p_location_id,
                                       p_payroll_id,
                                       p_pay_basis_type,
                                       p_gre_id,
                                       p_start_date,
                                       p_effective_date,
                                       l_ge_def_bal_id) LOOP
        hr_utility.trace(l_routine_name||': 110');
        l_balance_value := l_balance_value +
                  pay_ca_balance_view_pkg.get_value
                      (p_assignment_action_id => r_asg.assignment_action_id,
                       p_defined_balance_id   => l_lb_defined_balance_id,
                       p_dont_cache           => 1,
                       p_always_get_dbi       => 0);
      END LOOP;
    ELSE
      FOR r_asg IN csr_get_asg_jd_gre_add_rb(p_organization_id,
                                          p_location_id,
                                          p_payroll_id,
                                          p_pay_basis_type,
                                          p_gre_id,
                                          p_jurisdiction,
                                          p_start_date,
                                          p_effective_date,
                                          l_ge_def_bal_id) LOOP
        hr_utility.trace(l_routine_name||': 120');
        l_balance_value := l_balance_value +
                  pay_ca_balance_view_pkg.get_value
                      (p_assignment_action_id => r_asg.assignment_action_id,
                       p_defined_balance_id   => l_lb_defined_balance_id,
                       p_dont_cache           => 1,
                       p_always_get_dbi       => 0);
      END LOOP;
    END IF;
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_balance_value;
END get_grp_pydate_with_aa_rb;


-------------------------------------------------------------------------------
-- Name:       get_grp_non_pydate_with_asg
--
-- Parameters: p_assignment_id
--             p_time_dimension
--             p_lb_dimension
--             p_gl_defined_balance_id
--             p_balance_name
--             p_effective_date
--             p_start_date
--             p_jurisdiction_code
--             p_gre_id
--             p_source_id
--             p_organization_id
--             p_location_id
--             p_payroll_id
--             p_pay_basis_type
--             p_business_group_id
--
-- Return:     NUMBER - The value of the group level balance
--
-- Description: This function calculates the balance value given an assignment
--              id and date. If the latest balances exist they will be utilised.
-------------------------------------------------------------------------------
FUNCTION get_grp_non_pydate_with_asg
                          (p_assignment_id  NUMBER,
                           p_time_dimension VARCHAR2,
                           p_lb_dimension   VARCHAR2,
                           p_gl_defined_balance_id NUMBER,
                           p_balance_name   VARCHAR2,
                           p_effective_date DATE,
                           p_start_date     DATE,
                           p_jurisdiction   VARCHAR2,
                           p_gre_id         NUMBER,
                           p_source_id      NUMBER,
                           p_organization_id NUMBER,
                           p_location_id    NUMBER,
                           p_payroll_id     NUMBER,
                           p_pay_basis_type VARCHAR2,
                           p_business_group_id NUMBER) RETURN NUMBER IS

CURSOR csr_latest_bal_exists(p_asg_id     NUMBER,
                             p_def_bal_id NUMBER,
                             p_start_date DATE,
                             p_end_date   DATE) IS
  SELECT 'X'
  FROM   SYS.DUAL
  WHERE EXISTS (SELECT 'X'
                FROM   pay_payroll_actions             pya,
                       pay_assignment_actions          asa,
                       pay_assignment_latest_balances  alb
                WHERE  alb.assignment_id       = p_asg_id
                AND    alb.defined_balance_id  = p_def_bal_id
                AND    alb.assignment_action_id = asa.assignment_action_id
                AND    asa.payroll_action_id    = pya.payroll_action_id
                AND    pya.effective_date BETWEEN p_start_date
                                              AND p_end_date);

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE
 * which have been run in a given time period.
 * These are for the cases where all the additional parameter ie. location_id,
 * organization_id, payroll_id, pay_basis_type are NULL
 */
CURSOR csr_get_asg_gre(p_gre_id     NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments asg
  WHERE EXISTS (SELECT 'X'
                FROM   pay_payroll_actions     pya,
                       pay_assignment_actions  asa
                WHERE  asa.assignment_id     = asg.assignment_id
                AND    asa.tax_unit_id       = p_gre_id
                AND    pya.payroll_action_id = asa.payroll_action_id
                AND    pya.effective_date BETWEEN p_start_date
                                              AND p_end_date);

CURSOR csr_get_asg_src(p_src_id     NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE) IS
  SELECT DISTINCT(acx.assignment_id) assignment_id
  FROM   pay_action_contexts acx,
         ff_contexts         cxt
  WHERE  cxt.context_name  = 'SOURCE_ID'
  AND    cxt.context_id    = acx.context_id
  AND    acx.context_value = TO_CHAR(p_src_id)
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions     pya,
                     pay_assignment_actions  asa
              WHERE  asa.assignment_action_id = acx.assignment_action_id
              AND    pya.payroll_action_id    = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date);

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE and
 * jurisdiction which have been run in a given time period.
 * These are for the cases where all the additional parameter ie. location_id,
 * organization_id, payroll_id, pay_basis_type are NULL
 */
CURSOR csr_get_asg_jd_gre(p_gre_id     NUMBER,
                          p_jd         VARCHAR2,
                          p_start_date DATE,
                          p_end_date   DATE) IS
  SELECT DISTINCT(acx.assignment_id) assignment_id
  FROM   pay_action_contexts    acx,
         ff_contexts            cxt
  WHERE  cxt.context_name         = 'JURISDICTION_CODE'
  AND    cxt.context_id           = acx.context_id
  AND    acx.context_value        = p_jd
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions     pya,
                     pay_assignment_actions  asa
              WHERE  asa.assignment_action_id = acx.assignment_action_id
              AND    asa.tax_unit_id          = p_gre_id
              AND    pya.payroll_action_id = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date);

CURSOR csr_get_asg_jd_src(p_src_id     NUMBER,
                          p_jd         VARCHAR2,
                          p_start_date DATE,
                          p_end_date   DATE) IS
  SELECT DISTINCT(acx1.assignment_id) assignment_id
  FROM   pay_action_contexts    acx1,
         pay_action_contexts    acx2,
         ff_contexts            cxt1,
         ff_contexts            cxt2
  WHERE  cxt1.context_name         = 'SOURCE_ID'
  AND    cxt1.context_id           = acx1.context_id
  AND    acx1.context_value        = TO_CHAR(p_src_id)
  AND    cxt2.context_name         = 'JURISDICTION_CODE'
  AND    cxt2.context_id           = acx2.context_id
  AND    acx2.context_value        = p_jd
  AND    acx1.assignment_action_id = acx2.assignment_action_id
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  asa.assignment_action_id = acx1.assignment_action_id
              AND    pya.payroll_action_id  = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date);

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE
 * which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */
CURSOR csr_get_asg_gre_add(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_gre_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg
  WHERE  asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  asa.assignment_id     = asg.assignment_id
              AND    asa.tax_unit_id       = p_gre_id
              AND    pya.payroll_action_id = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date);

CURSOR csr_get_asg_src_add(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_src_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE) IS
  SELECT DISTINCT(acx.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg,
         pay_action_contexts    acx,
         ff_contexts            cxt
  WHERE  cxt.context_name    = 'SOURCE_ID'
  AND    cxt.context_id      = acx.context_id
  AND    acx.context_value   = TO_CHAR(p_src_id)
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  asa.assignment_action_id = acx.assignment_action_id
              AND    pya.payroll_action_id    = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date)
  AND    acx.assignment_id   = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE and
 * jurisdiction which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */
CURSOR csr_get_asg_jd_gre_add(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_gre_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg,
         pay_action_contexts    acx,
         ff_contexts            cxt
  WHERE  cxt.context_name    = 'JURISDICTION_CODE'
  AND    cxt.context_id      = acx.context_id
  AND    acx.context_value   = p_jd
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  acx.assignment_action_id = asa.assignment_action_id
              AND    asa.tax_unit_id          = p_gre_id
              AND    pya.payroll_action_id    = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date)
  AND    acx.assignment_id   = asg.assignment_id
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id+0 IN (SELECT pyb.pay_basis_id
                                FROM   per_pay_bases pyb
                                WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));

CURSOR csr_get_asg_jd_src_add(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_src_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE) IS
  SELECT DISTINCT(acx1.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg,
         pay_action_contexts    acx2,
         pay_action_contexts    acx1,
         ff_contexts            cxt2,
         ff_contexts            cxt1
  WHERE  cxt1.context_name   = 'SOURCE_ID'
  AND    cxt1.context_id     = acx1.context_id
  AND    acx1.context_value  = TO_CHAR(p_src_id)
  AND    acx1.assignment_id  = asg.assignment_id
  AND    cxt2.context_name   = 'JURISDICTION_CODE'
  AND    cxt2.context_id     = acx2.context_id
  AND    acx2.context_value  = p_jd
  AND    acx2.assignment_id  = asg.assignment_id
  AND    acx1.assignment_action_id = acx2.assignment_action_id
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  asa.assignment_action_id = acx1.assignment_action_id
              AND    asa.tax_unit_id          = p_gre_id
              AND    pya.payroll_action_id    = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date)
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));


l_routine_name VARCHAR2(64) := 'pay_ca_group_level_bal_pkg.get_grp_non_pydate_with_asg';

l_lb_defined_balance_id NUMBER(9);
l_latest_bal_exists     VARCHAR2(1);
l_virtual_date          DATE;
l_balance_value         NUMBER(38,10) := 0;
l_date_mask             VARCHAR2(5);
l_additional_params     VARCHAR2(1);

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);

  l_lb_defined_balance_id := get_defined_balance(p_balance_name,
                                                 p_lb_dimension,
                                                 p_business_group_id);
  IF l_lb_defined_balance_id IS NULL THEN
    RETURN NULL;
  END IF;

  /*
   * Have any additional parmaeters been specified (location, organization,
   * payroll, paybasis type) ?
   */
  IF p_organization_id IS NULL AND
     p_location_id     IS NULL AND
     p_payroll_id      IS NULL AND
     p_pay_basis_type  IS NULL THEN
    hr_utility.trace(l_routine_name||': 5');
    l_additional_params := 'N';
  ELSE
    hr_utility.trace(l_routine_name||': 10');
    l_additional_params := 'Y';
  END IF;

  /*
   * First check whether latest balances exist for the given assignment
   * on the given date
   */
  OPEN csr_latest_bal_exists(p_assignment_id,
                             l_lb_defined_balance_id,
                             p_start_date,
                             p_effective_date);
  FETCH csr_latest_bal_exists INTO l_latest_bal_exists;
  IF csr_latest_bal_exists%NOTFOUND AND
      l_additional_params = 'N' THEN
    hr_utility.trace(l_routine_name||': 20');
    /*
     * No latest balances found so calculate the group level balance from
     * first principles
     */
    l_balance_value := pay_ca_balance_view_pkg.get_value
                              (p_assignment_id,
                               p_gl_defined_balance_id,
                               p_effective_date);

  ELSIF p_source_id IS NOT NULL THEN
    /*
     * Loop through all the assignments for this Reporting Unit (Source Id)
     * and sum the latest balance value for each one
     */
    hr_utility.trace(l_routine_name||': 30');
    l_date_mask := get_date_mask(p_time_dimension);
    IF l_additional_params = 'N' THEN
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_src(p_source_id,
                                     p_start_date,
                                     p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 40');

          IF p_time_dimension <> 'PYDATE' THEN
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          END IF;
          l_balance_value := l_balance_value +
                      pay_ca_balance_view_pkg.get_value(r_asg.assignment_id,
                                                        l_lb_defined_balance_id,
                                                        l_virtual_date,
                                                        1); /*turn caching off*/
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_src(p_source_id,
                                        p_jurisdiction,
                                        p_start_date,
                                        p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 50');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                      pay_ca_balance_view_pkg.get_value(r_asg.assignment_id,
                                                        l_lb_defined_balance_id,
                                                        l_virtual_date,
                                                        1); /*turn caching off*/
        END LOOP;
      END IF;
    ELSE
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_src_add(p_organization_id,
                                         p_location_id,
                                         p_payroll_id,
                                         p_pay_basis_type,
                                         p_source_id,
                                         p_start_date,
                                         p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 60');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value (r_asg.assignment_id,
                                                       l_lb_defined_balance_id,
                                                       l_virtual_date,
                                                       1); /*turn caching off*/
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_src_add(p_organization_id,
                                            p_location_id,
                                            p_payroll_id,
                                            p_pay_basis_type,
                                            p_source_id,
                                            p_jurisdiction,
                                            p_start_date,
                                            p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 70');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value (r_asg.assignment_id,
                                                       l_lb_defined_balance_id,
                                                       l_virtual_date,
                                                       1); /*turn caching off*/
        END LOOP;
      END IF;
    END IF;
  ELSE
    /*
     * Loop through all the assignments for this GRE and sum the latest
     * balance value for each one
     */
    hr_utility.trace(l_routine_name||': 80');
    IF p_time_dimension <> 'PYDATE' THEN
      l_date_mask := get_date_mask(p_time_dimension);
    END IF;
    IF l_additional_params = 'N' THEN
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_gre(p_gre_id,
                                     p_start_date,
                                     p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 90');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_gre(p_gre_id,
                                        p_jurisdiction,
                                        p_start_date,
                                        p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 100');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      END IF;
    ELSE
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_gre_add(p_organization_id,
                                         p_location_id,
                                         p_payroll_id,
                                         p_pay_basis_type,
                                         p_gre_id,
                                         p_start_date,
                                         p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 110');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_gre_add(p_organization_id,
                                            p_location_id,
                                            p_payroll_id,
                                            p_pay_basis_type,
                                            p_gre_id,
                                            p_jurisdiction,
                                            p_start_date,
                                            p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 120');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      END IF;
    END IF;
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_balance_value;
END get_grp_non_pydate_with_asg;


-------------------------------------------------------------------------------
-- Name:       get_grp_non_pydate_with_asg_rb
--
-- Parameters: p_assignment_id
--             p_time_dimension
--             p_lb_dimension
--             p_gl_defined_balance_id
--             p_balance_name
--             p_effective_date
--             p_start_date
--             p_jurisdiction_code
--             p_gre_id
--             p_source_id
--             p_organization_id
--             p_location_id
--             p_payroll_id
--             p_pay_basis_type
--             p_business_group_id
--
-- Return:     NUMBER - The value of the group level balance
--
-- Description: This function calculates the balance value given an assignment
--              id and date. If the latest balances exist they will be utilised.
--              Uses pay_run_balances validation in all cursor definitions (EBRA)
-------------------------------------------------------------------------------
FUNCTION get_grp_non_pydate_with_asg_rb
                          (p_assignment_id  NUMBER,
                           p_time_dimension VARCHAR2,
                           p_lb_dimension   VARCHAR2,
                           p_gl_defined_balance_id NUMBER,
                           p_balance_name   VARCHAR2,
                           p_effective_date DATE,
                           p_start_date     DATE,
                           p_jurisdiction   VARCHAR2,
                           p_gre_id         NUMBER,
                           p_source_id      NUMBER,
                           p_organization_id NUMBER,
                           p_location_id    NUMBER,
                           p_payroll_id     NUMBER,
                           p_pay_basis_type VARCHAR2,
                           p_business_group_id NUMBER) RETURN NUMBER IS

CURSOR csr_latest_bal_exists(p_asg_id     NUMBER,
                             p_def_bal_id NUMBER,
                             p_start_date DATE,
                             p_end_date   DATE) IS
  SELECT 'X'
  FROM   SYS.DUAL
  WHERE EXISTS (SELECT 'X'
                FROM   pay_payroll_actions             pya,
                       pay_assignment_actions          asa,
                       pay_assignment_latest_balances  alb
                WHERE  alb.assignment_id       = p_asg_id
                AND    alb.defined_balance_id  = p_def_bal_id
                AND    alb.assignment_action_id = asa.assignment_action_id
                AND    asa.payroll_action_id    = pya.payroll_action_id
                AND    pya.effective_date BETWEEN p_start_date
                                              AND p_end_date);

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE
 * which have been run in a given time period.
 * These are for the cases where all the additional parameter ie. location_id,
 * organization_id, payroll_id, pay_basis_type are NULL
 */

-- NEW EBRA CURSOR csr_get_asg_gre definition with
-- pay_run_balances validation.
CURSOR csr_get_asg_gre_rb(p_gre_id     NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE,
                       p_def_bal_id NUMBER) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments_f asg
  WHERE EXISTS (SELECT 'X'
                FROM   pay_run_balances prb
                WHERE  prb.assignment_id     = asg.assignment_id
                AND    prb.tax_unit_id       = p_gre_id
                AND    prb.defined_balance_id = p_def_bal_id
                AND    prb.effective_date BETWEEN p_start_date
                                              AND p_end_date);


-- NEW EBRA CURSOR csr_get_asg_src definition with
-- pay_run_balances validation.
CURSOR csr_get_asg_src_rb(p_src_id     NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE
                       ) IS
  SELECT DISTINCT(prb.assignment_id) assignment_id
  FROM   pay_run_balances prb
  WHERE  prb.source_id = p_src_id
  AND    prb.effective_date BETWEEN p_start_date AND p_end_date;


/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE and
 * jurisdiction which have been run in a given time period.
 * These are for the cases where all the additional parameter ie. location_id,
 * organization_id, payroll_id, pay_basis_type are NULL
 */
-- NEW EBRA CURSOR csr_get_asg_jd_gre definition with
-- pay_run_balances validation.
CURSOR csr_get_asg_jd_gre_rb(p_gre_id     NUMBER,
                          p_jd         VARCHAR2,
                          p_start_date DATE,
                          p_end_date   DATE,
                          p_def_bal_id NUMBER) IS
  SELECT DISTINCT(prb.assignment_id) assignment_id
  FROM   pay_run_balances prb
  WHERE  prb.tax_unit_id          = p_gre_id
  AND    prb.jurisdiction_code    = p_jd
  AND    prb.defined_balance_id = p_def_bal_id
  AND    prb.effective_date BETWEEN p_start_date AND p_end_date;



CURSOR csr_get_asg_jd_src(p_src_id     NUMBER,
                          p_jd         VARCHAR2,
                          p_start_date DATE,
                          p_end_date   DATE) IS
  SELECT DISTINCT(acx1.assignment_id) assignment_id
  FROM   pay_action_contexts    acx1,
         pay_action_contexts    acx2,
         ff_contexts            cxt1,
         ff_contexts            cxt2
  WHERE  cxt1.context_name         = 'SOURCE_ID'
  AND    cxt1.context_id           = acx1.context_id
  AND    acx1.context_value        = TO_CHAR(p_src_id)
  AND    cxt2.context_name         = 'JURISDICTION_CODE'
  AND    cxt2.context_id           = acx2.context_id
  AND    acx2.context_value        = p_jd
  AND    acx1.assignment_action_id = acx2.assignment_action_id
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  asa.assignment_action_id = acx1.assignment_action_id
              AND    pya.payroll_action_id  = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date);

/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE
 * which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */

-- NEW CURSOR csr_get_asg_gre_add definition with
-- pay_run_balances validation.
CURSOR csr_get_asg_gre_add_rb(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_gre_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE,
                           p_def_bal_id NUMBER) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg
  WHERE  asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND EXISTS (SELECT 'X'
              FROM   pay_run_balances prb
              WHERE  prb.assignment_id     = asg.assignment_id
              AND    prb.tax_unit_id       = p_gre_id
              AND    prb.defined_balance_id = p_def_bal_id
              AND    prb.effective_date BETWEEN p_start_date
                                            AND p_end_date);


-- NEW EBRA CURSOR csr_get_asg_src_add definition with
-- pay_run_balances validation
CURSOR csr_get_asg_src_add_rb(p_org_id     NUMBER,
                           p_loc_id     NUMBER,
                           p_pay_id     NUMBER,
                           p_basis_type VARCHAR2,
                           p_src_id     NUMBER,
                           p_start_date DATE,
                           p_end_date   DATE,
                           p_def_bal_id NUMBER) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg
  WHERE  EXISTS (SELECT 'X'
                 FROM   pay_run_balances prb
                 WHERE  asg.assignment_id = prb.assignment_id
                 AND    prb.source_id   = p_src_id
                 AND    prb.defined_balance_id = p_def_bal_id
                 AND    prb.effective_date BETWEEN p_start_date
                                            AND p_end_date)
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
          AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));



/*
 * Select all the assignments in PAY_ACTION_CONTEXTS for a given GRE and
 * jurisdiction which have been run in a given time period.
 * These are for the cases where at least one of the additional parameter is
 * NULL, (ie. l,ocation_id, organization_id, payroll_id, pay_basis_type)
 */

-- NEW EBRA CURSOR csr_get_asg_jd_gre_add definition with
-- pay_run_balances validation.
CURSOR csr_get_asg_jd_gre_add_rb(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_gre_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE,
                              p_def_bal_id NUMBER) IS
  SELECT DISTINCT(asg.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg
  WHERE  EXISTS (SELECT 'X'
              FROM   pay_run_balances    prb
              WHERE  prb.assignment_id = asg.assignment_id
              AND    prb.tax_unit_id   = p_gre_id
              AND    prb.jurisdiction_code  = p_jd
              AND    prb.defined_balance_id = p_def_bal_id
              AND    prb.effective_date BETWEEN p_start_date
                                            AND p_end_date)
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                                FROM   per_pay_bases pyb
                                WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));


CURSOR csr_get_asg_jd_src_add(p_org_id     NUMBER,
                              p_loc_id     NUMBER,
                              p_pay_id     NUMBER,
                              p_basis_type VARCHAR2,
                              p_src_id     NUMBER,
                              p_jd         VARCHAR2,
                              p_start_date DATE,
                              p_end_date   DATE) IS
  SELECT DISTINCT(acx1.assignment_id) assignment_id
  FROM   per_all_assignments_f  asg,
         pay_action_contexts    acx2,
         pay_action_contexts    acx1,
         ff_contexts            cxt2,
         ff_contexts            cxt1
  WHERE  cxt1.context_name   = 'SOURCE_ID'
  AND    cxt1.context_id     = acx1.context_id
  AND    acx1.context_value  = TO_CHAR(p_src_id)
  AND    acx1.assignment_id  = asg.assignment_id
  AND    cxt2.context_name   = 'JURISDICTION_CODE'
  AND    cxt2.context_id     = acx2.context_id
  AND    acx2.context_value  = p_jd
  AND    acx2.assignment_id  = asg.assignment_id
  AND    acx1.assignment_action_id = acx2.assignment_action_id
  AND EXISTS (SELECT 'X'
              FROM   pay_payroll_actions    pya,
                     pay_assignment_actions asa
              WHERE  asa.assignment_action_id = acx1.assignment_action_id
              AND    asa.tax_unit_id          = p_gre_id
              AND    pya.payroll_action_id    = asa.payroll_action_id
              AND    pya.effective_date BETWEEN p_start_date
                                            AND p_end_date)
  AND    asg.organization_id = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id     = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id      = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                           ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL));


l_routine_name VARCHAR2(64) := 'pay_ca_group_level_bal_pkg.get_grp_non_pydate_with_asg_rb';

l_lb_defined_balance_id NUMBER(9);
l_latest_bal_exists     VARCHAR2(1);
l_virtual_date          DATE;
l_balance_value         NUMBER(38,10) := 0;
l_date_mask             VARCHAR2(5);
l_additional_params     VARCHAR2(1);
l_ge_def_bal_id         NUMBER(20);

BEGIN
  hr_utility.trace('Starting routine: '||l_routine_name);


  /* To check in run_balances table with def_val_id and get valid assignment
     or assignment_action for balance calls */

  If p_jurisdiction is NULL then
    l_ge_def_bal_id := get_defined_balance(p_balance_name,
                                         'ASG_GRE_RUN',
                                          p_business_group_id);
    hr_utility.trace('Def_bal_id of '||p_balance_name||'_ASG_GRE_RUN : '||to_char(l_ge_def_bal_id));
  else
    l_ge_def_bal_id := get_defined_balance(p_balance_name,
                                         'ASG_JD_GRE_RUN',
                                          p_business_group_id);
    hr_utility.trace('Def_bal_id of '||p_balance_name||'_ASG_JD_GRE_RUN : '||to_char(l_ge_def_bal_id));
  End if;


  hr_utility.trace('Def_bal_id of GROSS_EARNINGS_ASG_JD_GRE_RUN : '||to_char(l_ge_def_bal_id));

  l_lb_defined_balance_id := get_defined_balance(p_balance_name,
                                                 p_lb_dimension,
                                                 p_business_group_id);
  IF l_lb_defined_balance_id IS NULL THEN
    RETURN NULL;
  END IF;

  /*
   * Have any additional parmaeters been specified (location, organization,
   * payroll, paybasis type) ?
   */
  IF p_organization_id IS NULL AND
     p_location_id     IS NULL AND
     p_payroll_id      IS NULL AND
     p_pay_basis_type  IS NULL THEN
    hr_utility.trace(l_routine_name||': 5');
    l_additional_params := 'N';
  ELSE
    hr_utility.trace(l_routine_name||': 10');
    l_additional_params := 'Y';
  END IF;

  /*
   * First check whether latest balances exist for the given assignment
   * on the given date
   */
  OPEN csr_latest_bal_exists(p_assignment_id,
                             l_lb_defined_balance_id,
                             p_start_date,
                             p_effective_date);
  FETCH csr_latest_bal_exists INTO l_latest_bal_exists;
  IF csr_latest_bal_exists%NOTFOUND AND
      l_additional_params = 'N' THEN
    hr_utility.trace(l_routine_name||': 20');
    /*
     * No latest balances found so calculate the group level balance from
     * first principles
     */
    l_balance_value := pay_ca_balance_view_pkg.get_value
                              (p_assignment_id,
                               p_gl_defined_balance_id,
                               p_effective_date);

  ELSIF p_source_id IS NOT NULL THEN
    /*
     * Loop through all the assignments for this Reporting Unit (Source Id)
     * and sum the latest balance value for each one
     */
    hr_utility.trace(l_routine_name||': 30');
    l_date_mask := get_date_mask(p_time_dimension);
    IF l_additional_params = 'N' THEN
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_src_rb(p_source_id,
                                     p_start_date,
                                     p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 40');

          IF p_time_dimension <> 'PYDATE' THEN
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          END IF;
          l_balance_value := l_balance_value +
                      pay_ca_balance_view_pkg.get_value(r_asg.assignment_id,
                                                        l_lb_defined_balance_id,
                                                        l_virtual_date,
                                                        1); /*turn caching off*/
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_src(p_source_id,
                                        p_jurisdiction,
                                        p_start_date,
                                        p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 50');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                      pay_ca_balance_view_pkg.get_value(r_asg.assignment_id,
                                                        l_lb_defined_balance_id,
                                                        l_virtual_date,
                                                        1); /*turn caching off*/
        END LOOP;
      END IF;
    ELSE
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_src_add_rb(p_organization_id,
                                         p_location_id,
                                         p_payroll_id,
                                         p_pay_basis_type,
                                         p_source_id,
                                         p_start_date,
                                         p_effective_date,
                                         l_ge_def_bal_id)
          LOOP
          hr_utility.trace(l_routine_name||': 60');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value (r_asg.assignment_id,
                                                       l_lb_defined_balance_id,
                                                       l_virtual_date,
                                                       1); /*turn caching off*/
          END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_src_add(p_organization_id,
                                            p_location_id,
                                            p_payroll_id,
                                            p_pay_basis_type,
                                            p_source_id,
                                            p_jurisdiction,
                                            p_start_date,
                                            p_effective_date) LOOP
          hr_utility.trace(l_routine_name||': 70');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value (r_asg.assignment_id,
                                                       l_lb_defined_balance_id,
                                                       l_virtual_date,
                                                       1); /*turn caching off*/
        END LOOP;
      END IF;
    END IF;
  ELSE
    /*
     * Loop through all the assignments for this GRE and sum the latest
     * balance value for each one
     */
    hr_utility.trace(l_routine_name||': 80');
    IF p_time_dimension <> 'PYDATE' THEN
      l_date_mask := get_date_mask(p_time_dimension);
    END IF;
    IF l_additional_params = 'N' THEN
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_gre_rb(p_gre_id,
                                     p_start_date,
                                     p_effective_date,
                                     l_ge_def_bal_id) LOOP
          hr_utility.trace(l_routine_name||': 90');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_gre_rb(p_gre_id,
                                        p_jurisdiction,
                                        p_start_date,
                                        p_effective_date,
                                        l_ge_def_bal_id) LOOP
          hr_utility.trace(l_routine_name||': 100');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      END IF;
    ELSE
      IF p_jurisdiction IS NULL THEN
        FOR r_asg IN csr_get_asg_gre_add_rb(p_organization_id,
                                         p_location_id,
                                         p_payroll_id,
                                         p_pay_basis_type,
                                         p_gre_id,
                                         p_start_date,
                                         p_effective_date,
                                         l_ge_def_bal_id) LOOP
          hr_utility.trace(l_routine_name||': 110');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      ELSE
        FOR r_asg IN csr_get_asg_jd_gre_add_rb(p_organization_id,
                                            p_location_id,
                                            p_payroll_id,
                                            p_pay_basis_type,
                                            p_gre_id,
                                            p_jurisdiction,
                                            p_start_date,
                                            p_effective_date,
                                            l_ge_def_bal_id) LOOP
          hr_utility.trace(l_routine_name||': 120');
          l_virtual_date := get_virtual_date (r_asg.assignment_id,
                                              p_effective_date,
                                              l_date_mask);
          l_balance_value := l_balance_value +
                    pay_ca_balance_view_pkg.get_value
                        (p_assignment_id      => r_asg.assignment_id,
                         p_defined_balance_id => l_lb_defined_balance_id,
                         p_effective_date     => l_virtual_date,
                         p_dont_cache         => 1); /* turn caching off */
        END LOOP;
      END IF;
    END IF;
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_balance_value;
END get_grp_non_pydate_with_asg_rb;


-------------------------------------------------------------------------------
-- Name:       ca_group_level_balance
--
-- Parameters:
--       p_balance_name   - Mandatory
--       p_time_dimension - Mandatory (MONTH, QTD, YTD, PYDATE, PTD)
--       p_effective_date - Mandatory
--       p_start_date  - If this date is entered a PYDATE grouping is performed
--                       i.e. all assignments between p_start_date and
--                       p_effective_date are summed.
--                       These is always grouped within GRE - not Source Id.
--                       These field is mandatory if p_time_dimension is PYDATE.
--       p_source_id    - Either p_source_id or p_gre_id must be entered.
--                        p_time_dimension must be one of MONTH, QTD or YTD.
--       p_gre_id       - Either p_source_id or p_gre_id must be entered.
--                        p_time_dimension must be one of MONTH, QTD or YTD.
--       p_jurisdiction - If the jurisdiction code is enter the dimension will
--                        be within jurisdiction.
--       p_organization_id - If the organization id is specified then this
--                           routine will only get assignments for that
--                           organization.
--       p_location_id  - If the location id is specified then this routine
--                        will only get assignments for that location.
--       p_payroll_id   - If the payroll id is specified then this routine
--                        will only get assignments for that payroll.
--       p_pay_basis_type - HOURLY   - only assignments with hourly pay bases
--                                     will be included
--                          SALARIED - only assignments with non-hourly pay
--                                     bases will be included
--                          OTHER    - only assignments with no pay bases
--                                     will be included
--
-- Return: NUMBER - Group level balance total
--
-- Description: This is the main calling routine for calculating Canadian
--              Group Level Balances. This routine will initially be used for
--              the following reports:
--                Provincial Medical
--                Workers Compensation
--                Tax Deduction
--                Statistics
--                Gross to Net
-------------------------------------------------------------------------------
FUNCTION ca_group_level_balance (p_balance_name    VARCHAR2,
                                 p_time_dimension  VARCHAR2,
                                 p_effective_date  DATE,
                                 p_start_date      DATE,
                                 p_source_id       NUMBER,
                                 p_gre_id          NUMBER,
                                 p_jurisdiction    VARCHAR2,
                                 p_organization_id NUMBER,
                                 p_location_id     NUMBER,
                                 p_payroll_id      NUMBER,
                                 p_pay_basis_type  VARCHAR2) RETURN NUMBER IS
/*
 * Cursor to find a sample assignment id for the relevant PYDATE.
 */
CURSOR csr_asg_exists_for_gre (p_org_id     NUMBER,
                               p_loc_id     NUMBER,
                               p_pay_id     NUMBER,
                               p_basis_type VARCHAR2,
                               p_start_date DATE,
                               p_end_date   DATE,
                               p_gre        NUMBER,
                               p_gre_type   VARCHAR2) IS
  SELECT asg.assignment_id,
         asg.business_group_id
  FROM   per_all_assignments_f   asg,
         hr_soft_coding_keyflex  sck
  WHERE  decode(p_gre_type, 'T4A/RL1', sck.segment11, 'T4A/RL2', sck.segment12,
                sck.segment1) = TO_CHAR(p_gre)
  AND    asg.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
  AND   EXISTS(SELECT 'X'
               FROM   pay_assignment_actions  asa,
                      pay_payroll_actions     pya
               WHERE  asa.tax_unit_id       = p_gre
               AND    asg.assignment_id     = asa.assignment_id
               AND    pya.payroll_action_id = asa.payroll_action_id
               AND    pya.effective_date BETWEEN p_start_date
                                             AND p_end_date
               AND    pya.action_type       IN ('R', 'Q', 'I', 'V', 'B')
               AND    pya.effective_date BETWEEN asg.effective_start_date
                                             AND asg.effective_end_date)
  AND    asg.organization_id   = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id       = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id        = NVL(p_pay_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                          ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND ROWNUM=1;

cursor c_get_bg_id1(cp_gre_id number) is
select business_group_id
from hr_all_organization_units
where organization_id = cp_gre_id;

/* Cursor to get assignment id without the organization_id, location_id,
   payroll_id and pay_basis_type parameters and added this cursor
   to fix the bug#2391970 */

CURSOR csr_asg_for_gre_only_rb1 ( p_start_date DATE,
                                        p_end_date   DATE,
                                        p_gre        NUMBER,
                                        cp_def_bal_id NUMBER) IS
select prb.assignment_id,paf.business_group_id
from pay_run_balances prb,per_all_assignments_f paf
where prb.defined_balance_id = cp_def_bal_id
and prb.tax_unit_id = p_gre
and prb.effective_date between  p_start_date AND p_end_date
and  prb.assignment_id = paf.assignment_id
and prb.effective_date between  paf.effective_start_date AND
paf.effective_end_date
and rownum = 1;

CURSOR csr_asg_exists_for_gre_only ( p_start_date DATE,
                               p_end_date   DATE,
                               p_gre        NUMBER) IS
SELECT asa.assignment_id,pya.business_group_id
FROM   pay_payroll_actions     pya,
       pay_assignment_actions  asa
WHERE  asa.tax_unit_id       = p_gre
AND    pya.payroll_action_id = asa.payroll_action_id
AND    pya.effective_date BETWEEN  p_start_date
       AND  p_end_date
AND    pya.action_type       IN ('R', 'Q', 'I', 'V', 'B')
AND    rownum = 1;

/*
 * Cursor to find a sample assignment id for the relevant Source Id.
 */
CURSOR csr_asg_exists_for_src (p_org_id     NUMBER,
                               p_loc_id     NUMBER,
                               p_pay_id     NUMBER,
                               p_basis_type VARCHAR2,
                               p_start_date DATE,
                               p_end_date   DATE,
                               p_src        NUMBER) IS
  SELECT asg.assignment_id,
         asg.business_group_id
  FROM   pay_payroll_actions     pya,
         per_all_assignments_f   asg,
         pay_assignment_actions  asa,
         pay_action_contexts     acx,
         ff_contexts             cxt
  WHERE  acx.context_value        = TO_CHAR(p_src)
  AND    cxt.context_id           = acx.context_id
  AND    cxt.context_name         = 'SOURCE_ID'
  AND    asa.assignment_action_id = acx.assignment_action_id
  AND    asg.assignment_id        = asa.assignment_id
  AND    asg.organization_id      = NVL(p_organization_id, asg.organization_id)
  AND    asg.location_id          = NVL(p_location_id, asg.location_id)
  AND    asg.payroll_id           = NVL(p_payroll_id, asg.payroll_id)
  AND   ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type   = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type   = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM   per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                          ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND    pya.payroll_action_id    = asa.payroll_action_id
  AND    pya.effective_date BETWEEN p_start_date
                                AND p_end_date
  AND    pya.action_type          IN ('R', 'Q', 'I', 'V', 'B')
  AND    pya.effective_date BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
  AND    ROWNUM = 1;


l_routine_name VARCHAR2(64) := 'pay_ca_group_level_bal_pkg.ca_group_level_balance';

l_dim_str1           VARCHAR2(60);
l_gl_dimension       VARCHAR2(60);
l_lb_dimension       VARCHAR2(60);
l_assignment_id      NUMBER(15);
l_defined_balance_id NUMBER(15);
l_balance_value      NUMBER(38,10);
l_gl_defined_balance_id NUMBER(15);
l_balance_name       VARCHAR(60);
l_start_date         DATE;
l_date_context       VARCHAR2(30);
l_business_group_id  NUMBER;
lv_gre_type          VARCHAR2(60);
ln_bg_id          number;
ln_run_balance_status varchar2(1);
ln_defbal_id          number;

e_invalid_time_dimension    EXCEPTION;
e_no_gre_or_source_id       EXCEPTION;
e_no_assignments            EXCEPTION;
e_no_gre_specified          EXCEPTION;
e_no_period_specified       EXCEPTION;
e_no_source_id_specified    EXCEPTION;
e_jurisdiction_must_be_null EXCEPTION;
e_invalid_dim_date_comb     EXCEPTION;
e_no_rpt_unit_for_pydate    EXCEPTION;
e_no_start_date_for_pydate  EXCEPTION;


BEGIN

/*  hr_utility.trace_on(NULL,'ORASDR'); */
  hr_utility.trace('Starting routine: '||l_routine_name);
  pay_ca_balance_view_pkg.set_context('DATE_EARNED',
                                fnd_date.date_to_canonical(p_effective_date));

  l_balance_name := p_balance_name;

  IF p_time_dimension <> 'PYDATE' AND
     p_time_dimension <> 'PTD'    AND
     p_time_dimension <> 'MONTH'  AND
     p_time_dimension <> 'QTD'    AND
     p_time_dimension <> 'YTD' THEN
    RAISE e_invalid_time_dimension;
  END IF;

  IF p_time_dimension <> 'PYDATE' AND
     p_start_date IS NULL THEN
    hr_utility.trace(l_routine_name||': 10');
    IF p_time_dimension = 'MONTH' THEN
      l_start_date := TRUNC(p_effective_date,'MONTH');
    ELSIF p_time_dimension = 'YTD' THEN
      l_start_date := TRUNC(p_effective_date,'Y');
    ELSIF p_time_dimension = 'QTD' THEN
      l_start_date := TRUNC(p_effective_date,'Q');
    END IF;
  ELSIF p_time_dimension = 'PYDATE' THEN
    hr_utility.trace(l_routine_name||': 20');
    IF p_start_date IS NULL THEN
      l_date_context := pay_ca_balance_view_pkg.get_context('BALANCE_DATE');
      IF l_date_context IS NOT NULL THEN
        l_start_date := fnd_date.canonical_to_date(l_date_context);
      ELSE
        RAISE e_no_start_date_for_pydate;
      END IF;
    ELSE
      l_start_date := p_start_date;
      pay_ca_balance_view_pkg.set_context('BALANCE_DATE',
                              fnd_date.date_to_canonical(p_start_date));
    END IF;
  ELSIF p_time_dimension = 'PTD' THEN
    hr_utility.trace(l_routine_name||': 25');
    l_start_date := NULL;
  ELSE
    RAISE e_invalid_dim_date_comb;
  END IF;

  IF p_gre_id IS NOT NULL THEN
    hr_utility.trace(l_routine_name||': 30');

    pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',
                                        p_gre_id);

    l_dim_str1 := 'GRE_';


  /* Getting GRE Type of tax unit for Multi GRE functionality
     Based on the gre type, the segment will be used in where clause.

     T4/RL1    -  Segment1
     T4A/RL1   -  Segment11
     T4A/RL2   -  Segment12
  */

  begin
     select org_information5
     into   lv_gre_type
     from   hr_organization_information hoi
     where  hoi.org_information_context = 'Canada Employer Identification'
     and    hoi.organization_id = p_gre_id;

     exception
     when others then
     null;

   end;


    /*
     * Find one assignment that is included in this GRE
     */
/* Commented out to fix the bug#2391970
    OPEN csr_asg_exists_for_gre(p_organization_id,
                                p_location_id,
                                p_payroll_id,
                                p_pay_basis_type,
                                l_start_date,
                                p_effective_date,
                                p_gre_id);
    FETCH csr_asg_exists_for_gre INTO l_assignment_id,
                                      l_business_group_id;
    CLOSE csr_asg_exists_for_gre;
*/

/* Added this condition to fix the bug#2391970 */
    IF p_organization_id is NULL and p_location_id is NULL
       and p_payroll_id is NULL and p_pay_basis_type IS null THEN

             open c_get_bg_id1(p_gre_id);

             fetch c_get_bg_id1 into ln_bg_id;
             hr_utility.trace('ln_bg_id: '||to_char(ln_bg_id));
             close c_get_bg_id1;

      ln_run_balance_status := pay_us_payroll_utils.check_balance_status
                                         (l_start_date,
                                          ln_bg_id,
                                          'PAY_CA_YEPP_BALANCES',
                                          'CA');

      IF ln_run_balance_status = 'Y'  THEN

        ln_defbal_id := get_defined_balance(l_balance_name,
                                              'ASG_GRE_RUN',
                                              ln_bg_id);


    hr_utility.trace('opening rb1 cursor');
       OPEN csr_asg_for_gre_only_rb1(l_start_date,
                                        p_effective_date,
                                        p_gre_id,
                                        ln_defbal_id);

       FETCH csr_asg_for_gre_only_rb1 INTO l_assignment_id,
                                          l_business_group_id;

       CLOSE csr_asg_for_gre_only_rb1;
     else
    hr_utility.trace('opening gre_only cursor');
       OPEN csr_asg_exists_for_gre_only(l_start_date,
                                        p_effective_date,
                                        p_gre_id);

       FETCH csr_asg_exists_for_gre_only INTO l_assignment_id,
                                          l_business_group_id;

       CLOSE csr_asg_exists_for_gre_only;
      end if;
     ELSE
        OPEN csr_asg_exists_for_gre(p_organization_id,
                                p_location_id,
                                p_payroll_id,
                                p_pay_basis_type,
                                l_start_date,
                                p_effective_date,
                                p_gre_id,
                                lv_gre_type);
        FETCH csr_asg_exists_for_gre INTO l_assignment_id,
                                      l_business_group_id;
        CLOSE csr_asg_exists_for_gre;


    END IF;

  ELSIF p_source_id IS NOT NULL THEN
    hr_utility.trace(l_routine_name||': 40');

    pay_ca_balance_view_pkg.set_context('SOURCE_ID',
                                        p_source_id);

    l_dim_str1 := 'RPT_UNIT_';

    /*
     * Find one assignment that is included for this Source Id
     */
      OPEN csr_asg_exists_for_src(p_organization_id,
                                p_location_id,
                                p_payroll_id,
                                p_pay_basis_type,
                                l_start_date,
                                p_effective_date,
                                p_source_id);

      FETCH csr_asg_exists_for_src INTO l_assignment_id,
                                      l_business_group_id;
      CLOSE csr_asg_exists_for_src;

  ELSE
    RAISE e_no_gre_or_source_id;
  END IF;

  /*
   * Build the dimension strings: one for the group level balance and
   * one for the related assignment level balance.
   * e.g. Group level balance       - _GRE_MONTH
   *      Assignment level balance  - _ASG_GRE_MONTH
   * e.g. with JD   Group           - _GRE_JD_MONTH
   *                Assignment      - _ASG_JD_GRE_MONTH
   */
  IF p_jurisdiction IS NULL THEN
    hr_utility.trace(l_routine_name||': 50');
    l_gl_dimension := l_dim_str1 || p_time_dimension;
    l_lb_dimension := 'ASG_' || l_gl_dimension;
  ELSE
    hr_utility.trace(l_routine_name||': 60');
    pay_ca_balance_view_pkg.set_context('JURISDICTION_CODE',
                                        p_jurisdiction);
    l_gl_dimension := l_dim_str1 || 'JD_' || p_time_dimension;
    l_lb_dimension := 'ASG_JD_'|| l_dim_str1 ||  p_time_dimension;
  END IF;
  hr_utility.trace('Group Level Dimension: '||l_gl_dimension);
  hr_utility.trace('Latest Balance Dimension: '||l_lb_dimension);

  IF l_assignment_id IS NOT NULL THEN
    l_gl_defined_balance_id := get_defined_balance(l_balance_name,
                                                   l_gl_dimension,
                                                   l_business_group_id);
    IF l_gl_defined_balance_id IS NULL THEN
      RETURN NULL;
    END IF;

    hr_utility.trace(l_routine_name||': 70');
    IF p_time_dimension = 'PYDATE' OR
       p_time_dimension = 'PTD' THEN
      IF p_time_dimension = 'PTD' OR
        (p_organization_id IS NULL AND
         p_location_id     IS NULL AND
         p_payroll_id      IS NULL AND
         p_pay_basis_type  IS NULL) THEN

        hr_utility.trace(l_routine_name||': 80');

        /*
         * All of the balance parameters are contexts so we can just call PYDATE
         * This will not use latest balances.
         */
        l_balance_value :=
               pay_ca_balance_view_pkg.get_value (l_assignment_id,
                                                  l_gl_defined_balance_id,
                                                  p_effective_date);
      ELSE
        /*
         * At least one of the balance parameters is not a context so we
         * must sum up all the relevant individual assignment action balance
         * values
         * We will will use the _ASG_GRE_RUN route since it is faster than
         * _ASG_GRE_PYDATE. Note the _ASG_GRE_PYDATE balance only sums values
         * on the specified date, not over a date range because of the link to
         * pre-payments
         * We can't use latest balances in this call because they won't exist
         * for any of the balances we are calling.
         */
        hr_utility.trace(l_routine_name||': 85');

        l_balance_value := get_grp_pydate_with_aa
                                          (l_lb_dimension,
                                           l_balance_name,
                                           p_effective_date,
                                           l_start_date,
                                           p_jurisdiction,
                                           p_gre_id,
                                           p_source_id,
                                           p_organization_id,
                                           p_location_id,
                                           p_payroll_id,
                                           p_pay_basis_type,
                                           l_business_group_id);
      END IF;
    ELSE
      /*
       * For all non-PYDATE balances
       */
      hr_utility.trace(l_routine_name||': 90');
      l_balance_value := get_grp_non_pydate_with_asg
                                          (l_assignment_id,
                                           p_time_dimension,
                                           l_lb_dimension,
                                           l_gl_defined_balance_id,
                                           l_balance_name,
                                           p_effective_date,
                                           l_start_date,
                                           p_jurisdiction,
                                           p_gre_id,
                                           p_source_id,
                                           p_organization_id,
                                           p_location_id,
                                           p_payroll_id,
                                           p_pay_basis_type,
                                           l_business_group_id);
    END IF;
  ELSE
    hr_utility.trace(l_routine_name||': 100');
    hr_utility.trace('No Assignments to process');
    l_balance_value := 0;
--    RAISE e_no_assignments;
  END IF;

  hr_utility.trace('Ending routine: '||l_routine_name);
  RETURN l_balance_value;

EXCEPTION
  WHEN e_invalid_time_dimension THEN
    pay_us_balance_view_pkg.debug_err('The time dimension is invalid');
  WHEN e_no_assignments THEN
    pay_us_balance_view_pkg.debug_err('No Assignments to process');
  WHEN e_no_gre_or_source_id THEN
    pay_us_balance_view_pkg.debug_err('Either a GRE or a Reporting Unit '||
                              '(Source Id) must be passed to this routine');
  WHEN e_no_gre_specified THEN
    pay_us_balance_view_pkg.debug_err('The GRE parameter must be specified');
  WHEN e_no_source_id_specified THEN
    pay_us_balance_view_pkg.debug_err('The Source Id parameter must be specified');
  WHEN e_jurisdiction_must_be_null THEN
    pay_us_balance_view_pkg.debug_err('The Jurisdiction parameter can not be entered for Reporting Unit balances');
  WHEN e_invalid_dim_date_comb THEN
    pay_us_balance_view_pkg.debug_err('The Start Date parameter must be entered only when the dimension is PYDATE');
  WHEN e_no_rpt_unit_for_pydate THEN
    pay_us_balance_view_pkg.debug_err('The Reporting Unit dimension can not be used for pay date range calculations');
  WHEN e_no_start_date_for_pydate THEN
    pay_us_balance_view_pkg.debug_err('The Start Date parameter MUST be entered when the dimension is PYDATE');

END ca_group_level_balance;


-------------------------------------------------------------------------------
-- Name:       ca_group_level_balance_rb
--
-- Parameters:
--       p_balance_name   - Mandatory
--       p_time_dimension - Mandatory (MONTH, QTD, YTD, PYDATE, PTD)
--       p_effective_date - Mandatory
--       p_start_date  - If this date is entered a PYDATE grouping is performed
--                       i.e. all assignments between p_start_date and
--                       p_effective_date are summed.
--                       These is always grouped within GRE - not Source Id.
--                       These field is mandatory if p_time_dimension is PYDATE.
--       p_source_id    - Either p_source_id or p_gre_id must be entered.
--                        p_time_dimension must be one of MONTH, QTD or YTD.
--       p_gre_id       - Either p_source_id or p_gre_id must be entered.
--                        p_time_dimension must be one of MONTH, QTD or YTD.
--       p_jurisdiction - If the jurisdiction code is enter the dimension will
--                        be within jurisdiction.
--       p_organization_id - If the organization id is specified then this
--                           routine will only get assignments for that
--                           organization.
--       p_location_id  - If the location id is specified then this routine
--                        will only get assignments for that location.
--       p_payroll_id   - If the payroll id is specified then this routine
--                        will only get assignments for that payroll.
--       p_pay_basis_type - HOURLY   - only assignments with hourly pay bases
--                                     will be included
--                          SALARIED - only assignments with non-hourly pay
--                                     bases will be included
--                          OTHER    - only assignments with no pay bases
--                                     will be included
--
-- Return: NUMBER - Group level balance total
--
-- Description: This is the main calling routine for calculating Canadian
--              Group Level Balances. This routine will initially be used for
--              the following reports:
--                Provincial Medical
--                Workers Compensation
--                Tax Deduction
--                Business Payroll Survey
--                Gross to Net

--              This function has been modified with
--              pay_run_balances validation to check for valid assignments
--              or assignment_actions.  If p_flag is 'Y' this routine will
--              use EBRA validation to avoid unnecessary balance calls for
--              assignment_actions or assignments, if p_flas is 'N' it uses
--              old routine ca_group_level_balance .
-------------------------------------------------------------------------------
FUNCTION ca_group_level_balance_rb (p_balance_name    VARCHAR2,
                                 p_time_dimension  VARCHAR2,
                                 p_effective_date  DATE,
                                 p_start_date      DATE,
                                 p_source_id       NUMBER,
                                 p_gre_id          NUMBER,
                                 p_jurisdiction    VARCHAR2,
                                 p_organization_id NUMBER,
                                 p_location_id     NUMBER,
                                 p_payroll_id      NUMBER,
                                 p_pay_basis_type  VARCHAR2,
                                 p_flag            VARCHAR2) RETURN NUMBER IS
/*
 * Cursor to find a sample assignment id for the relevant PYDATE.
 */

-- New EBRA csr_asg_exists_for_gre Cursor to find a sample assignment id
-- for the relevant PYDATE.

  CURSOR csr_asg_exists_for_gre_rb (p_org_id     NUMBER,
                               p_loc_id     NUMBER,
                               p_pay_id     NUMBER,
                               p_basis_type VARCHAR2,
                               p_start_date DATE,
                               p_end_date   DATE,
                               p_gre        NUMBER,
                               p_gre_type   VARCHAR2,
                               cp_def_bal_id NUMBER) IS
  SELECT asg.assignment_id,
        asg.business_group_id
  FROM  per_all_assignments_f  asg,
        pay_run_balances prb
  WHERE  prb.defined_balance_id = cp_def_bal_id
  and prb.effective_date between p_start_date AND p_end_date
  and prb.tax_unit_id = p_gre
  and prb.assignment_id = asg.assignment_id
  and prb.effective_date between  asg.effective_start_date
                                      AND asg.effective_end_date
  and exists (select 1
              from hr_soft_coding_keyflex  sck
              where asg.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
              AND decode(p_gre_type, 'T4A/RL1', sck.segment11,
              'T4A/RL2', sck.segment12,
                sck.segment1) = TO_CHAR(p_gre))
  AND    asg.organization_id  = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id      = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id        = NVL(p_pay_id, asg.payroll_id)
  AND  ((p_basis_type  = 'OTHER'
          AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type  = 'HOURLY'
        AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM  per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY')
        )
    OR  (p_basis_type  = 'SALARIED'
        AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM  per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                          ('ANNUAL','MONTHLY','PERIOD'))
        )
    OR  (p_basis_type IS NULL)
      )
  AND ROWNUM=1;


/* New EBRA Cursor csr_asg_exists_for_gre_only to get assignment id without the
   organization_id, location_id, payroll_id and pay_basis_type parameters and
   added this cursor to fix the bug#2391970 */

CURSOR csr_asg_exists_for_gre_only_rb ( p_start_date DATE,
                                        p_end_date   DATE,
                                        p_gre        NUMBER,
                                        cp_def_bal_id NUMBER) IS
select prb.assignment_id,paf.business_group_id
from pay_run_balances prb,per_all_assignments_f paf
where prb.defined_balance_id = cp_def_bal_id
and prb.tax_unit_id = p_gre
and prb.effective_date between  p_start_date AND p_end_date
and  prb.assignment_id = paf.assignment_id
and prb.effective_date between  paf.effective_start_date AND
paf.effective_end_date
and rownum = 1;


 /*
 * New EBRA csr_asg_exists_for_src Cursor to find a sample assignment id
 * for the relevant Source Id with pay_run_balance validations.
 */
  CURSOR csr_asg_exists_for_src_rb(p_org_id     NUMBER,
                                  p_loc_id     NUMBER,
                                  p_pay_id     NUMBER,
                                  p_basis_type VARCHAR2,
                                  p_start_date DATE,
                                  p_end_date   DATE,
                                  p_src        NUMBER,
                                  cp_def_bal_id NUMBER) IS
  SELECT prb.assignment_id, asg.business_group_id
  FROM  pay_run_balances    prb,
        per_all_assignments_f  asg
  WHERE  prb.defined_balance_id = cp_def_bal_id
  and    asg.assignment_id        = prb.assignment_id
  and    prb.source_id            = TO_CHAR(p_src)
  AND    asg.organization_id      = NVL(p_org_id, asg.organization_id)
  AND    asg.location_id          = NVL(p_loc_id, asg.location_id)
  AND    asg.payroll_id          = NVL(p_pay_id, asg.payroll_id)
  AND  ((p_basis_type  = 'OTHER'
    AND  asg.pay_basis_id    IS NULL)
    OR  (p_basis_type  = 'HOURLY'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM  per_pay_bases pyb
                              WHERE  pyb.pay_basis = 'HOURLY'))
    OR  (p_basis_type  = 'SALARIED'
    AND  asg.pay_basis_id IN (SELECT pyb.pay_basis_id
                              FROM  per_pay_bases pyb
                              WHERE  pyb.pay_basis IN
                                          ('ANNUAL','MONTHLY','PERIOD')))
    OR  (p_basis_type IS NULL))
  AND    prb.effective_date BETWEEN p_start_date AND p_end_date
  AND    prb.effective_date BETWEEN asg.effective_start_date
                                AND asg.effective_end_date
  AND    ROWNUM = 1;

/* new cursor to get business_group_id to fix bug#3637426 */
cursor c_get_bg_id(cp_gre_id number) is
select business_group_id
from hr_all_organization_units
where organization_id = cp_gre_id;

l_routine_name VARCHAR2(64) := 'pay_ca_group_level_bal_pkg.ca_group_level_balance_rb';

l_dim_str1           VARCHAR2(60);
l_gl_dimension       VARCHAR2(60);
l_lb_dimension       VARCHAR2(60);
l_assignment_id      NUMBER(15);
l_defined_balance_id NUMBER(15);
l_balance_value      NUMBER(38,10);
l_gl_defined_balance_id NUMBER(15);
l_balance_name       VARCHAR(60);
l_start_date         DATE;
l_date_context       VARCHAR2(30);
l_business_group_id  NUMBER;
lv_gre_type          VARCHAR2(60);
ln_newbg_id          number;
ln_bal_type_id       number;
ln_new_defbal_id     number;

e_invalid_time_dimension    EXCEPTION;
e_no_gre_or_source_id       EXCEPTION;
e_no_assignments            EXCEPTION;
e_no_gre_specified          EXCEPTION;
e_no_period_specified       EXCEPTION;
e_no_source_id_specified    EXCEPTION;
e_jurisdiction_must_be_null EXCEPTION;
e_invalid_dim_date_comb     EXCEPTION;
e_no_rpt_unit_for_pydate    EXCEPTION;
e_no_start_date_for_pydate  EXCEPTION;


BEGIN

  hr_utility.trace('Starting routine: '||l_routine_name);
  hr_utility.trace('P_Flag for EBRA: '||p_flag);
  hr_utility.trace('p_time_dimension: '||p_time_dimension);
  hr_utility.trace('p_effective_date: '||to_char(p_effective_date));
  hr_utility.trace('p_balance_name: '||p_balance_name);
  hr_utility.trace('p_jurisdiction: '||p_jurisdiction);
  hr_utility.trace('p_gre_id: '||to_char(p_gre_id));
  hr_utility.trace('Starting routine: '||l_routine_name);
  hr_utility.trace('P_Flag for EBRA: '||p_flag);

 -- Checking the EBRA Flag to use Run Balances cursors or
 -- Pay_Assignment_Actions cursors
 If p_flag = 'N' then
    l_balance_value := ca_group_level_balance(p_balance_name
                                ,p_time_dimension
                                ,p_effective_date
                                ,p_start_date
                                ,p_source_id
                                ,p_gre_id
                                ,p_jurisdiction
                                ,p_organization_id
                                ,p_location_id
                                ,p_payroll_id
                                ,p_pay_basis_type
                                );
 Elsif p_flag = 'Y' then
   -- Process rb cursors to find assignments
  pay_ca_balance_view_pkg.set_context('DATE_EARNED',
                                fnd_date.date_to_canonical(p_effective_date));

  l_balance_name := p_balance_name;

  IF p_time_dimension <> 'PYDATE' AND
     p_time_dimension <> 'PTD'    AND
     p_time_dimension <> 'MONTH'  AND
     p_time_dimension <> 'QTD'    AND
     p_time_dimension <> 'YTD' THEN
    RAISE e_invalid_time_dimension;
  END IF;

  IF p_time_dimension <> 'PYDATE' AND
     p_start_date IS NULL THEN
    hr_utility.trace(l_routine_name||': 10');
    IF p_time_dimension = 'MONTH' THEN
      l_start_date := TRUNC(p_effective_date,'MONTH');
    ELSIF p_time_dimension = 'YTD' THEN
      l_start_date := TRUNC(p_effective_date,'Y');
    ELSIF p_time_dimension = 'QTD' THEN
      l_start_date := TRUNC(p_effective_date,'Q');
    END IF;
  ELSIF p_time_dimension = 'PYDATE' THEN
    hr_utility.trace(l_routine_name||': 20');
    IF p_start_date IS NULL THEN
      l_date_context := pay_ca_balance_view_pkg.get_context('BALANCE_DATE');
      IF l_date_context IS NOT NULL THEN
        l_start_date := fnd_date.canonical_to_date(l_date_context);
      ELSE
        RAISE e_no_start_date_for_pydate;
      END IF;
    ELSE
      l_start_date := p_start_date;
      pay_ca_balance_view_pkg.set_context('BALANCE_DATE',
                              fnd_date.date_to_canonical(p_start_date));
    END IF;
  ELSIF p_time_dimension = 'PTD' THEN
    hr_utility.trace(l_routine_name||': 25');
    l_start_date := NULL;
  ELSE
    RAISE e_invalid_dim_date_comb;
  END IF;

  IF p_gre_id IS NOT NULL THEN
    hr_utility.trace(l_routine_name||': 30');

    pay_ca_balance_view_pkg.set_context('TAX_UNIT_ID',
                                        p_gre_id);

    l_dim_str1 := 'GRE_';


  /* Getting GRE Type of tax unit for Multi GRE functionality
     Based on the gre type, the segment will be used in where clause.

     T4/RL1    -  Segment1
     T4A/RL1   -  Segment11
     T4A/RL2   -  Segment12
  */

    begin
     select org_information5
     into   lv_gre_type
     from   hr_organization_information hoi
     where  hoi.org_information_context = 'Canada Employer Identification'
     and    hoi.organization_id = p_gre_id;

      hr_utility.trace('lv_gre_type: '||lv_gre_type);
     exception
     when others then
     null;

    end;

   /* added code to fix bug#3637426 */
   open c_get_bg_id(p_gre_id);
   fetch c_get_bg_id into ln_newbg_id;
    hr_utility.trace('ln_newbg_id: '||to_char(ln_newbg_id));
   close c_get_bg_id;

   IF l_balance_name is not null THEN
      ln_new_defbal_id := get_defined_balance(l_balance_name,
                                              'ASG_GRE_RUN',
                                              ln_newbg_id);
       hr_utility.trace('ln_new_defbal_id: '||to_char(ln_new_defbal_id));
   End if;

   /* end of code for bug#3637426 */


    /*
     * Find one assignment that is included in this GRE
     */

   /* Added this condition to fix the bug#2391970 */
    IF p_organization_id is NULL and p_location_id is NULL
       and p_payroll_id is NULL and p_pay_basis_type IS null THEN

      /* Added this defined_balance_id not null condition to improve
         performance of csr_asg_exists_for_gre_only_rb */
      if ln_new_defbal_id is not null then
         OPEN csr_asg_exists_for_gre_only_rb(l_start_date,
                                           p_effective_date,
                                           p_gre_id,
                                           ln_new_defbal_id);

         FETCH csr_asg_exists_for_gre_only_rb INTO l_assignment_id,
                                          l_business_group_id;

         hr_utility.trace('ran csr_asg_exists_for_gre_only_rb: ');
         hr_utility.trace('l_assignment_id: '||to_char(l_assignment_id));
         CLOSE csr_asg_exists_for_gre_only_rb;
      end if;

     ELSE
      /* Added this defined_balance_id not null condition to improve
         performance of csr_asg_exists_for_gre_rb */
       if ln_new_defbal_id is not null then
          OPEN csr_asg_exists_for_gre_rb(p_organization_id,
                                p_location_id,
                                p_payroll_id,
                                p_pay_basis_type,
                                l_start_date,
                                p_effective_date,
                                p_gre_id,
                                lv_gre_type,
                                ln_new_defbal_id);
          FETCH csr_asg_exists_for_gre_rb INTO l_assignment_id,
                                      l_business_group_id;
           hr_utility.trace('ran csr_asg_exists_for_gre_rb: ');
           hr_utility.trace('l_assignment_id: '||to_char(l_assignment_id));
          CLOSE csr_asg_exists_for_gre_rb;
       end if;


    END IF;

  ELSIF p_source_id IS NOT NULL THEN
    hr_utility.trace(l_routine_name||': 40');

    pay_ca_balance_view_pkg.set_context('SOURCE_ID',
                                        p_source_id);

    l_dim_str1 := 'RPT_UNIT_';

    /* Added code to get the def_bal_id so that we can pass the
       def_bal_id to get the assignment_id from pay_run_balances.
       part of fix for bug#3637426
    */
    IF l_balance_name is not null THEN
      ln_new_defbal_id := get_defined_balance(l_balance_name,
                                              'ASG_RPT_UNIT_RUN',
                                              ln_newbg_id);
      hr_utility.trace('ln_new_defbal_id: '||to_char(ln_new_defbal_id));
    End if;
    /* end of adding code for bug#3637426 */

    /*
     * Find one assignment that is included for this Source Id
     */
    /* Added this defined_balance_id not null condition to improve
         performance of csr_asg_exists_for_gre_rb */
     if ln_new_defbal_id is not null then
        OPEN csr_asg_exists_for_src_rb(p_organization_id,
                                p_location_id,
                                p_payroll_id,
                                p_pay_basis_type,
                                l_start_date,
                                p_effective_date,
                                p_source_id,
                                ln_new_defbal_id);
        FETCH csr_asg_exists_for_src_rb INTO l_assignment_id,
                                      l_business_group_id;
       hr_utility.trace('ran csr_asg_exists_for_src_rb: ');
       hr_utility.trace('l_assignment_id: '||to_char(l_assignment_id));
        CLOSE csr_asg_exists_for_src_rb;
     end if;

  ELSE
    RAISE e_no_gre_or_source_id;
  END IF;

  /*
   * Build the dimension strings: one for the group level balance and
   * one for the related assignment level balance.
   * e.g. Group level balance       - _GRE_MONTH
   *      Assignment level balance  - _ASG_GRE_MONTH
   * e.g. with JD   Group           - _GRE_JD_MONTH
   *                Assignment      - _ASG_JD_GRE_MONTH
   */

  IF p_jurisdiction IS NULL THEN
    hr_utility.trace(l_routine_name||': 50');
    l_gl_dimension := l_dim_str1 || p_time_dimension;
    l_lb_dimension := 'ASG_' || l_gl_dimension;
  ELSE
    hr_utility.trace(l_routine_name||': 60');
    pay_ca_balance_view_pkg.set_context('JURISDICTION_CODE',
                                        p_jurisdiction);
    l_gl_dimension := l_dim_str1 || 'JD_' || p_time_dimension;
    l_lb_dimension := 'ASG_JD_'|| l_dim_str1 ||  p_time_dimension;
  END IF;
  hr_utility.trace('Group Level Dimension: '||l_gl_dimension);
  hr_utility.trace('Latest Balance Dimension: '||l_lb_dimension);


  IF l_assignment_id IS NOT NULL THEN
       l_gl_defined_balance_id := get_defined_balance(l_balance_name,
                                                   l_gl_dimension,
                                                   ln_newbg_id);
       hr_utility.trace('l_gl_defined_balance_id: '||to_char(l_gl_defined_balance_id));

       hr_utility.trace('l_assignment_id is not null satisfied ');
    IF l_gl_defined_balance_id IS NULL THEN
      RETURN NULL;
    END IF;

    hr_utility.trace(l_routine_name||': 70');

    IF p_time_dimension = 'PYDATE' OR
       p_time_dimension = 'PTD' THEN
      IF p_time_dimension = 'PTD' OR
        (p_organization_id IS NULL AND
         p_location_id     IS NULL AND
         p_payroll_id      IS NULL AND
         p_pay_basis_type  IS NULL) THEN

        hr_utility.trace(l_routine_name||': 80');

        /*
         * All of the balance parameters are contexts so we can just call PYDATE
         * This will not use latest balances.
         */
          hr_utility.trace('Calling pay_ca_balance_view_pkg.get_value ');

          hr_utility.trace('l_assignment_id :'||to_char(l_assignment_id));
          l_balance_value :=
               pay_ca_balance_view_pkg.get_value (l_assignment_id,
                                                  l_gl_defined_balance_id,
                                                  p_effective_date);
          hr_utility.trace('l_balance_value :'||to_char(l_balance_value));
      ELSE
        /*
         * At least one of the balance parameters is not a context so we
         * must sum up all the relevant individual assignment action balance
         * values
         * We will will use the _ASG_GRE_RUN route since it is faster than
         * _ASG_GRE_PYDATE. Note the _ASG_GRE_PYDATE balance only sums values
         * on the specified date, not over a date range because of the link to
         * pre-payments
         * We can't use latest balances in this call because they won't exist
         * for any of the balances we are calling.
         */
        hr_utility.trace(l_routine_name||': 85');
        hr_utility.trace('Calling get_grp_pydate_with_aa_rb ');

        l_balance_value := get_grp_pydate_with_aa_rb
                                          (l_lb_dimension,
                                           l_balance_name,
                                           p_effective_date,
                                           l_start_date,
                                           p_jurisdiction,
                                           p_gre_id,
                                           p_source_id,
                                           p_organization_id,
                                           p_location_id,
                                           p_payroll_id,
                                           p_pay_basis_type,
                                           l_business_group_id);
        hr_utility.trace('l_balance_value :'||to_char(l_balance_value));
      END IF;
    ELSE
      /*
       * For all non-PYDATE balances
       */
      hr_utility.trace(l_routine_name||': 90');
      hr_utility.trace('Calling get_grp_non_pydate_with_asg_rb ');
      l_balance_value := get_grp_non_pydate_with_asg_rb
                                          (l_assignment_id,
                                           p_time_dimension,
                                           l_lb_dimension,
                                           l_gl_defined_balance_id,
                                           l_balance_name,
                                           p_effective_date,
                                           l_start_date,
                                           p_jurisdiction,
                                           p_gre_id,
                                           p_source_id,
                                           p_organization_id,
                                           p_location_id,
                                           p_payroll_id,
                                           p_pay_basis_type,
                                           l_business_group_id);
        hr_utility.trace('l_balance_value :'||to_char(l_balance_value));
    END IF;
  ELSE
    hr_utility.trace(l_routine_name||': 100');
    hr_utility.trace('No Assignments to process');
    l_balance_value := 0;
--    RAISE e_no_assignments;
  END IF;

 End if; -- for EBRA p_flag check

  hr_utility.trace('Ending routine: '||l_routine_name);

  RETURN l_balance_value;

EXCEPTION
  WHEN e_invalid_time_dimension THEN
    hr_utility.trace('The time dimension is invalid');
  WHEN e_no_assignments THEN
    hr_utility.trace('No Assignments to process');
  WHEN e_no_gre_or_source_id THEN
    hr_utility.trace('Either a GRE or a Reporting Unit '||
                              '(Source Id) must be passed to this routine');
  WHEN e_no_gre_specified THEN
    hr_utility.trace('The GRE parameter must be specified');
  WHEN e_no_source_id_specified THEN
    hr_utility.trace('The Source Id parameter must be specified');
  WHEN e_jurisdiction_must_be_null THEN
    hr_utility.trace('The Jurisdiction parameter can not be entered for Reporting Unit balances');
  WHEN e_invalid_dim_date_comb THEN
    hr_utility.trace('The Start Date parameter must be entered only when the dimension is PYDATE');
  WHEN e_no_rpt_unit_for_pydate THEN
    hr_utility.trace('The Reporting Unit dimension can not be used for pay date range calculations');
  WHEN e_no_start_date_for_pydate THEN
    hr_utility.trace('The Start Date parameter MUST be entered when the dimension is PYDATE');


END ca_group_level_balance_rb;


END pay_ca_group_level_bal_pkg;


/
