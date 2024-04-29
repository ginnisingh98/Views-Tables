--------------------------------------------------------
--  DDL for Package Body PAY_CA_ROE_EI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_ROE_EI_PKG" AS
/* $Header: pycaroei.pkb 120.10.12010000.3 2010/02/03 10:09:34 sapalani ship $ */

--
-- Functions/Procedures
--

-------------------------------------------------------------------------------
-- Name:        populate_date_lookup_table
--
-- Parameters:  p_payroll_id
--              p_assignment_id
--              p_start_date
--              p_effective_date
--              p_last_period_start_date
--
-- Return:      Rehire flag set either to Y or N
--
-- Description: This procedure populates a PL/SQL table with data on the
--              periods of a given payroll. This table is created for
--              performance reasons. If the employee has been rehired in
--              the same pay period as the previous ROE then the days from
--              the rehire date until the first pay period end date are also
--              saved in the PL/SQL table
-------------------------------------------------------------------------------
FUNCTION populate_date_lookup_table
                    (p_payroll_id             NUMBER,
                     p_assignment_id          NUMBER,
                     p_start_date             DATE,
                     p_effective_date         DATE,
                     p_last_period_start_date DATE)
RETURN VARCHAR2 IS

CURSOR csr_periods (p_payroll_id NUMBER,
                    p_start_date DATE,
                    p_end_date   DATE) IS
SELECT tpd.start_date,
       tpd.end_date
FROM   per_time_periods tpd
WHERE  payroll_id   = p_payroll_id
AND  ((start_date   >= p_start_date
       AND end_date <  p_end_date   )
     OR
      (start_date   <= p_start_date
       AND end_date >= p_start_date  ))
ORDER BY start_date DESC;

CURSOR csr_prev_roe_end_date (p_payroll_id NUMBER,
                              p_start_date DATE) IS
SELECT tpd.end_date
FROM   per_time_periods tpd
WHERE  tpd.payroll_id   = p_payroll_id
AND    p_start_date BETWEEN
         tpd.start_date
         AND tpd.end_date;

CURSOR csr_rehire_date (p_asg_id      NUMBER,
                        p_end_date    DATE,
                        p_start_date  DATE) IS
SELECT MAX(service.date_start)    hire_date
FROM   per_periods_of_service service,
       per_assignments_f asg
WHERE  asg.assignment_id = p_asg_id
AND    p_end_date BETWEEN
         asg.effective_start_date
         AND asg.effective_end_date
AND    asg.person_id     = service.person_id
AND    service.date_start BETWEEN
         asg.effective_start_date
         AND asg.effective_end_date
AND    service.date_start <= p_end_date
AND    service.date_start >= p_start_date;

l_proc_name  VARCHAR2(60) := 'pay_ca_roe_ei_pkg.populate_date_lookup_table';

l_period_num  NUMBER;
l_days        NUMBER;
l_rehire_date   DATE;
l_rehire_flag   VARCHAR2(1) := 'N';
l_prev_roe_end_date DATE;
l_first_start_date  DATE;

BEGIN
  hr_utility.set_location('Starting: ' || l_proc_name, 10);
  hr_utility.set_location('p_start_date: ' || p_start_date, 10.5);
  hr_utility.set_location('p_effective_date: ' || p_effective_date, 11);
  hr_utility.set_location('p_last_period_start_date: ' || p_last_period_start_date, 12);

  l_period_num := 1;
  l_days       := 0;

  FOR l_index IN 0..(p_effective_date-p_last_period_start_date) LOOP

    l_days_from_start(l_days) := l_days;
    l_period_number(l_days)   := l_period_num;

    hr_utility.trace('Day : '||to_char(l_days_from_start(l_days))|| ' Period : '|| to_char(l_period_number(l_days)));

    l_days := l_days + 1;

  END LOOP;
  l_period_num := l_period_num + 1;

  FOR r_periods IN csr_periods (p_payroll_id,
                                p_start_date,
                                p_effective_date) LOOP

    FOR l_index IN 0..(r_periods.end_date-r_periods.start_date) LOOP

      l_days_from_start(l_days) := l_days;
      l_period_number(l_days)   := l_period_num;

      hr_utility.trace('Day : '||to_char(l_days_from_start(l_days))|| ' Period : '|| to_char(l_period_number(l_days)));

      l_days := l_days + 1;

    END LOOP;

    l_period_num := l_period_num + 1;

    -- After the final iteration l_first_start_date
    -- will have the very first start date

    l_first_start_date := r_periods.start_date;

  END LOOP;

  hr_utility.trace('p_start_date : ' || to_char(p_start_date));

  -- This section checks to see if the employee was rehired in the
  -- same period as the previous ROE (same period as p_start_date)
  -- if so it we will return Y otherwise N
  -- The days between the rehired date and the end of the period are
  -- also saved in the PL/SQL table
  -- Generally the earnings that fall in the same period as the previous
  -- ROE should not be archived, since they would have been archived in
  -- the previous ROE run, however in the case of a rehire they wouldn't
  -- have been archived, hence the need for this section


  -- Find the end date of the pay period the previous ROE falls into

  OPEN csr_prev_roe_end_date (p_payroll_id, p_start_date);
  FETCH csr_prev_roe_end_date INTO l_prev_roe_end_date;

  IF csr_prev_roe_end_date%FOUND THEN

      hr_utility.trace('l_prev_roe_end_date : '|| to_char(l_prev_roe_end_date));

      -- Find any rehire dates that fall between the previous (ROE date + 1)
      -- and the end date of it's pay period

      OPEN csr_rehire_date (p_assignment_id, l_prev_roe_end_date, p_start_date);
      FETCH csr_rehire_date INTO l_rehire_date;

      IF csr_rehire_date%FOUND AND
         l_rehire_date IS NOT NULL THEN

      hr_utility.trace('l_rehire_date : ' || to_char(l_rehire_date));
      hr_utility.trace('l_first_start_date : ' || to_char(l_first_start_date));
      hr_utility.trace('p_last_period_start_date : ' || to_char(p_last_period_start_date));

          -- If the rehire date falls under the correct range then store
          -- the period between the rehire date and the end of the first
          -- period. The last condition ensures that we do not store any
          -- periods more than once

          IF l_rehire_date >= p_start_date AND
             l_rehire_date <= l_prev_roe_end_date AND
             l_rehire_date < nvl(l_first_start_date, p_last_period_start_date) THEN

               FOR l_index IN 0..(l_prev_roe_end_date-l_rehire_date) LOOP

                    l_days_from_start(l_days) := l_days;
                    l_period_number(l_days)   := l_period_num;

                    hr_utility.trace('Day : '||to_char(l_days_from_start(l_days))|| ' Period : '|| to_char(l_period_number(l_days)));

                    l_days := l_days + 1;

               END LOOP;

               l_rehire_flag := 'Y';

          END IF;

      END IF;

      CLOSE csr_rehire_date;

  END IF;

  CLOSE csr_prev_roe_end_date;

  hr_utility.trace('Rehire flag returned : ' || l_rehire_flag);
  hr_utility.set_location('Ending: ' || l_proc_name, 1000);

  RETURN l_rehire_flag;

END populate_date_lookup_table;


-------------------------------------------------------------------------------
-- Name:        taxability_rule_exists
--
-- Parameters:  p_classification_name
--              p_classification_id
--              p_tax_category
--              p_effective_date
--              p_tax_type
--
-- Return:      VARCHAR2 - 'TRUE' or 'FALSE'
--
-- Description: This procedure determines whether a taxability rule is
--              required. If one is required it also ensures that the rule is
--              applied.
-------------------------------------------------------------------------------
FUNCTION taxability_rule_exists
                    (p_classification_name VARCHAR2,
                     p_classification_id   NUMBER,
                     p_tax_category        VARCHAR2,
                     p_effective_date      DATE,
                     p_tax_type            VARCHAR2)
RETURN VARCHAR2 IS

CURSOR csr_get_taxability_rules (p_class_name VARCHAR2,
                                 p_class_id   NUMBER,
                                 p_tax_cat    VARCHAR2,
                                 p_eff_date   DATE) IS
  SELECT 1
  FROM   pay_taxability_rules_dates trd,
         pay_taxability_rules       txr
  WHERE  txr.classification_id = p_class_id
  AND    txr.tax_type          = 'EIM'
  AND    txr.tax_category      = p_tax_cat
  AND    trd.taxability_rules_date_id = txr.taxability_rules_date_id
  AND    p_eff_date BETWEEN trd.valid_date_from
                        AND trd.valid_date_to;

l_proc_name  VARCHAR2(60) := 'pay_ca_roe_ei_pkg.taxability_rule_exists';

l_dummy NUMBER;

BEGIN

  IF p_classification_name in
             ('Earnings','Balance Initialization') THEN

    RETURN 'TRUE';

  ELSE

    IF p_tax_type = 'EIM' THEN
      OPEN csr_get_taxability_rules(p_classification_name,
                                    p_classification_id,
                                    p_tax_category,
                                    p_effective_date);
      FETCH csr_get_taxability_rules INTO l_dummy;
      IF csr_get_taxability_rules%NOTFOUND THEN
        RETURN 'FALSE';
      ELSE
        RETURN 'TRUE';
      END IF;
    ELSE
      RETURN 'FALSE';
    END IF;

  END IF;

END taxability_rule_exists;

-------------------------------------------------------------------------------
-- Name:        get_pd_num
--
-- Parameters:  p_current_date
--              p_end_date
--
-- Return:      NUMBER - period number
--
-- Description: This function looks up the number of pay periods between two
--              given dates.
-------------------------------------------------------------------------------
FUNCTION get_pd_num
                    (p_current_date  IN DATE,
                     p_end_date      IN DATE)
RETURN NUMBER IS

BEGIN

  RETURN l_period_number(p_end_date - p_current_date);

END get_pd_num;

-------------------------------------------------------------------------------
-- Name:        get_ei_amount_totals
--
-- Parameters:  p_total_type      'EI Hours' or 'EI Earnings'
--              p_assignment_id
--              p_gre
--              p_payroll_id
--              p_end_date       - date of ROE
--              p_period_type (output)
--              p_total_insurable (output) - either Hours or Earnings total
--              p_no_of_periods  (output)  - only used for Box15C
--              p_periods_totals (output)  - only used for Earnings
--              p_term_or_abs_flag         - only used for Date Paid Amount
--
-- Return:      VARCHAR2 - 'BOX15B' or 'BOX15C'
--
-- Description: This is an overloaded version of get_ei_amount_totals without
--              the p_start_date parameter date. If the start date is not
--              entered we set it to NULL.
-------------------------------------------------------------------------------
FUNCTION get_ei_amount_totals
                    (p_total_type      IN  VARCHAR2,
                     p_assignment_id   IN  NUMBER,
                     p_gre             IN  NUMBER,
                     p_payroll_id      IN  NUMBER,
                     p_end_date        IN  DATE,
                     p_period_type     OUT NOCOPY VARCHAR2,
                     p_total_insurable OUT NOCOPY NUMBER,
                     p_no_of_periods   OUT NOCOPY NUMBER,
                     p_period_total    OUT NOCOPY t_large_number_table,
                     p_term_or_abs_flag IN VARCHAR2)
RETURN VARCHAR2 IS
l_return VARCHAR2(10);
BEGIN
  l_return := get_ei_amount_totals
                    (p_total_type      => p_total_type,
                     p_assignment_id   => p_assignment_id,
                     p_gre             => p_gre,
                     p_payroll_id      => p_payroll_id,
                     p_start_date      => NULL,
                     p_end_date        => p_end_date,
                     p_period_type     => p_period_type,
                     p_total_insurable => p_total_insurable,
                     p_no_of_periods   => p_no_of_periods,
                     p_period_total    => p_period_total,
                     p_term_or_abs_flag => p_term_or_abs_flag);
  RETURN l_return;
END;

-------------------------------------------------------------------------------
-- Name:        get_ei_amount_totals
--
-- Parameters:  p_total_type      'EI Hours' or 'EI Earnings'
--              p_assignment_id
--              p_gre
--              p_payroll_id
--              p_start_date     - non mandatory (date + 1 of last ROE)
--              p_end_date       - date of ROE
--              p_period_type (output)     - period type
--              p_total_insurable (output) - either Hours or Earnings total
--              p_no_of_periods  (output)  - only used for Box15C
--              p_periods_totals (output)  - only used for Earnings
--              p_term_or_abs_flag         - only used for Date Paid Amount
--
-- Return:      VARCHAR2 - 'BOX15B' or 'BOX15C'
--
-- Description: This function is the main calling routine of this package.
--              It is used by the Canadian Record of Employment (ROE) Report
--              to calculate the values of boxes 15A, 15B and 15C on that
--              report.
--              15A - This calculates the Insurable Hours for a time period
--                    approximately equal to a year. The details of the
--                    exact time period are different for each period type.
--              15C - This calculate the Insurable Earnings for each pay
--                    period for a tme period approximately equal to 6 months.
--                    The details of the exact time period are different for
--                    ech period type.
--              15B - If any of the results from 15C are zero then values for
--                    all periods (15C) must be returned, otherwise just a
--                    total is required (15B).
--              Note for all of the above balance calculations the
--              element_information3 field ('ROE Allocation By') is used to
--              determine whether we use the 'Date Earned' or 'Date Paid' as
--              the balance's effective date for each element of the balance.
-------------------------------------------------------------------------------
FUNCTION get_ei_amount_totals
                    (p_total_type      IN  VARCHAR2,
                     p_assignment_id   IN  NUMBER,
                     p_gre             IN  NUMBER,
                     p_payroll_id      IN  NUMBER,
                     p_start_date      IN  DATE,
                     p_end_date        IN  DATE,
                     p_period_type     OUT NOCOPY VARCHAR2,
                     p_total_insurable OUT NOCOPY NUMBER,
                     p_no_of_periods   OUT NOCOPY NUMBER,
                     p_period_total    OUT NOCOPY t_large_number_table,
                     p_term_or_abs_flag IN VARCHAR2)
RETURN VARCHAR2 IS

CURSOR csr_get_period_type (p_payroll_id NUMBER,
                            p_date       DATE) IS
  SELECT tpd.period_type,
         tpd.start_date,
         tpd.end_date
  FROM   per_time_periods      tpd
  WHERE  tpd.payroll_id    = p_payroll_id
  AND    p_date BETWEEN tpd.start_date
                    AND tpd.end_date;

CURSOR csr_dp_hours_total_ftr_exists (p_asg_id     NUMBER,
                               p_gre        NUMBER,
                               p_start_date DATE,
                               p_end_date   DATE) IS
  SELECT /*+ leading(asa,pya,ele) use_merge(ele) */
    SUM(NVL(rrv.result_value, 0) * blf.scale) total_dp_hours
  FROM  pay_ca_emp_fed_tax_info_f    fti,
         pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.effective_date  BETWEEN p_start_date
                                 AND p_end_date
  AND    fti.assignment_id     = p_asg_id
  AND    NVL(fti.ei_exempt_flag,'N')    = 'N'
  AND    pya.effective_date BETWEEN fti.effective_start_date
                                AND fti.effective_end_date
  AND    fti.assignment_id = asa.assignment_id
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    pay_ca_roe_ei_pkg.date_paid_or_date_earned
                                 (ele.element_type_id,
                                  'DP',
                                  ele.element_information3) = 'TRUE'
  AND    pya.effective_date BETWEEN ele.effective_start_date
                                AND ele.effective_end_date
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.effective_date BETWEEN ipv.effective_start_date
                                AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.effective_date BETWEEN blf.effective_start_date
                                AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name        = 'EI Hours'
  AND    blt.legislation_code    = 'CA';

  CURSOR csr_dp_hours_total_ftr_nexists (p_asg_id     NUMBER,
                               p_gre        NUMBER,
                               p_start_date DATE,
                               p_end_date   DATE) IS
  SELECT /*+ leading(asa,pya,ele) use_merge(ele) */
    SUM(NVL(rrv.result_value, 0) * blf.scale) total_dp_hours
  FROM   pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.effective_date  BETWEEN p_start_date
                                 AND p_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    pay_ca_roe_ei_pkg.date_paid_or_date_earned
                                 (ele.element_type_id,
                                  'DP',
                                  ele.element_information3) = 'TRUE'
  AND    pya.effective_date BETWEEN ele.effective_start_date
                                AND ele.effective_end_date
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.effective_date BETWEEN ipv.effective_start_date
                                AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.effective_date BETWEEN blf.effective_start_date
                                AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name        = 'EI Hours'
  AND    blt.legislation_code    = 'CA';

CURSOR csr_de_hours_total_ftr_exists (p_asg_id     NUMBER,
                               p_gre        NUMBER,
                               p_start_date DATE,
                               p_end_date   DATE) IS
  SELECT /*+ leading(asa,pya,ele) use_merge(ele) */
    SUM(NVL(rrv.result_value, 0) * blf.scale) total_de_hours
  FROM   pay_ca_emp_fed_tax_info_f    fti,
         pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.date_earned  BETWEEN p_start_date
                              AND p_end_date
  AND    fti.assignment_id     = p_asg_id
  AND    fti.assignment_id = asa.assignment_id
  AND    NVL(fti.ei_exempt_flag,'N')    = 'N'
  AND    pya.date_earned BETWEEN fti.effective_start_date
                             AND fti.effective_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    pay_ca_roe_ei_pkg.date_paid_or_date_earned
                                 (ele.element_type_id,
                                  'DE',
                                  ele.element_information3) = 'TRUE'
  AND    pya.date_earned BETWEEN ele.effective_start_date
                             AND ele.effective_end_date
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.date_earned BETWEEN ipv.effective_start_date
                             AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.date_earned BETWEEN blf.effective_start_date
                             AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name        = 'EI Hours'
  AND    blt.legislation_code    = 'CA';

CURSOR csr_de_hours_total_ftr_nexists (p_asg_id     NUMBER,
                               p_gre        NUMBER,
                               p_start_date DATE,
                               p_end_date   DATE) IS
  SELECT /*+ leading(asa,pya,ele) use_merge(ele) */
    SUM(NVL(rrv.result_value, 0) * blf.scale) total_de_hours
  FROM   pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.date_earned  BETWEEN p_start_date
                              AND p_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    pay_ca_roe_ei_pkg.date_paid_or_date_earned
                                 (ele.element_type_id,
                                  'DE',
                                  ele.element_information3) = 'TRUE'
  AND    pya.date_earned BETWEEN ele.effective_start_date
                             AND ele.effective_end_date
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.date_earned BETWEEN ipv.effective_start_date
                             AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.date_earned BETWEEN blf.effective_start_date
                             AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name        = 'EI Hours'
  AND    blt.legislation_code    = 'CA';

/* Modifed the cursor for Bug 4510534 */
  CURSOR csr_get_dp_total(p_asg_id    NUMBER,
                         p_gre        NUMBER,
                         p_start_date DATE,
                         p_end_date   DATE) IS
   SELECT /*+ RULE */
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           1, NVL(rrv.result_value, 0)*blf.scale,0)),0) +
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           2, NVL(rrv.result_value, 0)*blf.scale,0)),0) +
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           3, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           4, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           5, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           6, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           7, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           8, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           9, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           10,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           11,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           12,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           13,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           14,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           15,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           16,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           17,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           18,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           19,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           20,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           21,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           22,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           23,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           24,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           25,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           26,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           27,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           28,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           29,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           30, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           31, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           32, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           33, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           34, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           35, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           36, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           37,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           38,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           39,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           40,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           41,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           42,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           43,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           44,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           45,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           46,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           47,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           48,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           49,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           50,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           51,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           52,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           53,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           54,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           55,NVL(rrv.result_value, 0)*blf.scale,0)),0)
  FROM   pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_element_classifications  elc,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.effective_date  BETWEEN p_start_date
                                 AND p_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    NVL(ele.element_information3,'DP') = 'DP'
  AND    pya.effective_date BETWEEN ele.effective_start_date
                                AND ele.effective_end_date
  AND    elc.classification_id = ele.classification_id
  AND    elc.classification_name IN ('Earnings',
                                     'Supplemental Earnings',
                                     'Taxable Benefits',
                                     'Balance Initialization')
  AND    pay_ca_roe_ei_pkg.taxability_rule_exists(elc.classification_name,
                                elc.classification_id,
                                ele.element_information1,
                                pya.effective_date,
                                blt.tax_type) = 'TRUE'
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.effective_date BETWEEN ipv.effective_start_date
                                AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.effective_date BETWEEN blf.effective_start_date
                                AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name   IN ('Regular Earnings',
                                'Supplemental Earnings for EI',
                                'Taxable Benefits for EI')
  AND    blt.legislation_code    = 'CA'
  AND    NVL(pay_ca_emp_tax_inf.get_tax_detail_char(p_asg_id,
         SYSDATE,SYSDATE, pya.effective_date, 'EIEXEMPT'),'N') = 'N';

  CURSOR csr_get_dp_total1(p_asg_id     NUMBER,
                         p_gre        NUMBER,
                         p_start_date DATE,
                         p_end_date   DATE) IS
  SELECT /*+ RULE */
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           1, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           2, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           3, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           4, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           5, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           6, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           7, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           8, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           9, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           10,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           11,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           12,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           13,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           14,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           15,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           16,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           17,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           18,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           19,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           20,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           21,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           22,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           23,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           24,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           25,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           26,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           27,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           28, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           29, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           30, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           31, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           32, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           33, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           34, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           35, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           36,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           37,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           38,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           39,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           40,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           41,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           42,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           43,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           44,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           45,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           46,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           47,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           48,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           49,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           50,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           51,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           52,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.effective_date,p_end_date),
           53,NVL(rrv.result_value, 0)*blf.scale,0)),0)
  FROM   pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_element_classifications  elc,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.effective_date  BETWEEN p_start_date
                                 AND p_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    NVL(ele.element_information3,'DP') = 'DP'
  AND    pya.effective_date BETWEEN ele.effective_start_date
                                AND ele.effective_end_date
  AND    elc.classification_id = ele.classification_id
  AND    elc.classification_name IN ('Earnings',
                                     'Supplemental Earnings',
                                     'Taxable Benefits',
                                     'Balance Initialization')
  AND    pay_ca_roe_ei_pkg.taxability_rule_exists(elc.classification_name,
                                elc.classification_id,
                                ele.element_information1,
                                pya.effective_date,
                                blt.tax_type) = 'TRUE'
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.effective_date BETWEEN ipv.effective_start_date
                                AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.effective_date BETWEEN blf.effective_start_date
                                AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name   IN ('Regular Earnings',
                                'Supplemental Earnings for EI',
                                'Taxable Benefits for EI')
  AND    blt.legislation_code    = 'CA'
  AND    NVL(pay_ca_emp_tax_inf.get_tax_detail_char(p_asg_id,
         SYSDATE,SYSDATE, pya.effective_date, 'EIEXEMPT'),'N') = 'N';

  CURSOR csr_get_de_total(p_asg_id     NUMBER,
                         p_gre        NUMBER,
                         p_start_date DATE,
                         p_end_date   DATE) IS
  SELECT /*+ RULE */
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           1, NVL(rrv.result_value, 0)*blf.scale,0)),0) +
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           2, NVL(rrv.result_value, 0)*blf.scale,0)),0) +
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           3, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           4, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           5, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           6, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           7, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           8, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           9, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           10,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           11,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           12,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           13,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           14,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           15,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           16,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           17,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           18,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           19,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           20,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           21,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           22,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           23,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           24,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           25,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           26,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           27,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           28,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           29,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           30, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           31, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           32, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           33, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           34, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           35, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           36, NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           37,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           38,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           39,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           40,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           41,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           42,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           43,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           44,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           45,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           46,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           47,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           48,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           49,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           50,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           51,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           52,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           53,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           54,NVL(rrv.result_value, 0)*blf.scale,0)),0),
   NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           55,NVL(rrv.result_value, 0)*blf.scale,0)),0)
  FROM   pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_element_classifications  elc,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.date_earned  BETWEEN p_start_date
                              AND p_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    NVL(ele.element_information3,'DP') = 'DE'
  AND    pya.date_earned BETWEEN ele.effective_start_date
                             AND ele.effective_end_date
  AND    elc.classification_id = ele.classification_id
  AND    elc.classification_name IN ('Earnings',
                                     'Supplemental Earnings',
                                     'Taxable Benefits')
  AND    pay_ca_roe_ei_pkg.taxability_rule_exists(elc.classification_name,
                                elc.classification_id,
                                ele.element_information1,
                                pya.date_earned,
                                blt.tax_type) = 'TRUE'
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.date_earned BETWEEN ipv.effective_start_date
                             AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.date_earned BETWEEN blf.effective_start_date
                             AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name   IN ('Regular Earnings',
                                'Supplemental Earnings for EI',
                                'Taxable Benefits for EI')
  AND    blt.legislation_code    = 'CA'
  AND    NVL(pay_ca_emp_tax_inf.get_tax_detail_char(p_asg_id,
         SYSDATE, SYSDATE, pya.date_earned, 'EIEXEMPT'),'N') = 'N';

  CURSOR csr_get_de_total1(p_asg_id     NUMBER,
                         p_gre        NUMBER,
                         p_start_date DATE,
                         p_end_date   DATE) IS
  SELECT /*+ RULE */
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           1, NVL(rrv.result_value, 0)*blf.scale,0)),0),
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           2, NVL(rrv.result_value, 0)*blf.scale,0)),0),
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           3, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           4, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           5, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           6, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           7, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           8, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           9, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           10, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           11, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           12, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           13, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           14, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           15, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           16, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           17, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           18, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           19, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           20, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           21, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           22, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           23, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           24, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           25, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           26, NVL(rrv.result_value, 0)*blf.scale,0)),0),
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           27, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           28, NVL(rrv.result_value, 0)*blf.scale,0)),0),
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           29, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           30, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           31, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           32, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           33, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           34, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           35, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           36, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           37, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           38, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           39, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           40, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           41, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           42, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           43, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           44, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           45, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           46, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           47, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           48, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           49, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           50, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           51, NVL(rrv.result_value, 0)*blf.scale,0)),0) ,
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           52, NVL(rrv.result_value, 0)*blf.scale,0)),0),
     NVL(SUM(DECODE(pay_ca_roe_ei_pkg.get_pd_num(pya.date_earned,p_end_date),
           53, NVL(rrv.result_value, 0)*blf.scale,0)),0)
  FROM   pay_assignment_actions       asa,
         pay_payroll_actions          pya,
         pay_run_results              rrs,
         pay_run_result_values        rrv,
         pay_element_types_f          ele,
         pay_element_classifications  elc,
         pay_input_values_f           ipv,
         pay_balance_feeds_f          blf,
         pay_balance_types            blt
  WHERE  asa.assignment_id     = p_asg_id
  AND    asa.tax_unit_id       = p_gre
  AND    pya.payroll_id        = p_payroll_id
  AND    pya.payroll_action_id = asa.payroll_action_id
  AND    pya.date_earned  BETWEEN p_start_date
                              AND p_end_date
  AND    rrs.assignment_action_id = asa.assignment_action_id
  AND    ele.element_type_id      = rrs.element_type_id
  AND    NVL(ele.element_information3,'DP') = 'DE'
  AND    pya.date_earned BETWEEN ele.effective_start_date
                             AND ele.effective_end_date
  AND    elc.classification_id = ele.classification_id
  AND    elc.classification_name IN ('Earnings',
                                     'Supplemental Earnings',
                                     'Taxable Benefits')
  AND    pay_ca_roe_ei_pkg.taxability_rule_exists(elc.classification_name,
                                elc.classification_id,
                                ele.element_information1,
                                pya.date_earned,
                                blt.tax_type) = 'TRUE'
  AND    rrv.run_result_id       = rrs.run_result_id
  AND    ipv.input_value_id      = rrv.input_value_id
  AND    pya.date_earned BETWEEN ipv.effective_start_date
                             AND ipv.effective_end_date
  AND    blf.input_value_id      = ipv.input_value_id
  AND    pya.date_earned BETWEEN blf.effective_start_date
                             AND blf.effective_end_date
  AND    blf.balance_type_id     = blt.balance_type_id
  AND    blt.balance_name   IN ('Regular Earnings',
                                'Supplemental Earnings for EI',
                                'Taxable Benefits for EI')
  AND    blt.legislation_code    = 'CA'
  AND    NVL(pay_ca_emp_tax_inf.get_tax_detail_char(p_asg_id,
         SYSDATE, SYSDATE, pya.date_earned, 'EIEXEMPT'),'N') = 'N';

l_proc_name  VARCHAR2(60) := 'pay_ca_roe_ei_pkg.get_ei_amount_totals';

l_start_date             DATE;
l_start_period           DATE;
l_last_period_start_date DATE;
l_last_period_end_date   DATE;
l_value                  NUMBER;
l_prev_element_entry_id  NUMBER;
l_period_count           NUMBER;
l_period_count1          NUMBER;
l_box15c_flag            BOOLEAN := FALSE;

l_dp_hours_total NUMBER;
l_de_hours_total NUMBER;
l_hours_total    NUMBER;

l_de_total  t_large_number_table;
l_dp_total  t_large_number_table;


  CURSOR cur_count_pay_periods(p_start_date1 DATE) IS
  SELECT COUNT(*)
  FROM   per_time_periods
  WHERE  payroll_id = p_payroll_id
  AND    end_date >= p_start_date1
  AND    start_date <= p_end_date;

  l_no_of_pay_periods  NUMBER;
  l_start_date1        DATE;

  cursor cur_date_of_hire is
  select max(service.date_start)        hire_date
  from   per_periods_of_service service,
         per_assignments_f asg
  where  asg.assignment_id = p_assignment_id
  and    p_end_date BETWEEN
           asg.effective_start_date
           AND asg.effective_end_date
  and    asg.person_id     = service.person_id(+)
  and    service.date_start <= p_end_date;

  l_hire_date  DATE;

  cursor cur_next_prd_start_date is
  select
    ptp.end_date + 1
  from
    per_time_periods ptp
  where
    ptp.payroll_id = p_payroll_id and
    p_start_date between
      ptp.start_date and ptp.end_date;

  cursor csr_start_date (p_payroll_id number,
                         p_start_date date) is
  select start_date
  from   per_time_periods
  where  payroll_id   = p_payroll_id
  and    start_date   = p_start_date;

  l_period_start_date          date;
  l_period_start_date_exists   varchar2(1);

  cursor cur_pay_period_dates(p_date date) is
  select
    ptp2.start_date,
    ptp2.end_date
  from
    per_time_periods ptp,
    per_time_periods ptp1,
    per_time_periods ptp2
  where
    ptp.payroll_id = p_payroll_id and
    p_date between
      ptp.start_date and
      ptp.end_date and
    ptp.payroll_id = ptp1.payroll_id and
    ptp.end_date + 1 between
      ptp1.start_date and
      ptp1.end_date and
    ptp1.payroll_id = ptp2.payroll_id and
    ptp1.end_date + 1 between
      ptp2.start_date and
      ptp2.end_date;

  l_prd_st_date_after_final        date;
  l_prd_end_date_after_final       date;

  CURSOR cur_retro_run(p_start_date date,
                       p_end_date   date) is
  select
    ppa.payroll_action_id,
    ppa.effective_date,
    ppa.start_date
  from
    pay_payroll_actions ppa,
    pay_assignment_actions paa
  where
    paa.assignment_id = p_assignment_id and
    paa.tax_unit_id =   p_gre and
    ppa.payroll_id = p_payroll_id and
    paa.payroll_action_id = ppa.payroll_action_id and
    ppa.action_type = 'L' and
    ppa.action_status = 'C' and
    ppa.start_date between p_start_date and
        p_end_date;

  cursor cur_curr_pay_period_dates(p_date date) is
  select
    ptp.start_date,
    ptp.end_date
  from
    per_time_periods ptp
  where
    ptp.payroll_id = p_payroll_id and
    p_date between
      ptp.start_date and
      ptp.end_date;

  CURSOR cur_payroll_exists(p_pay_period_start_date date,
                            p_pay_period_end_date date) is
  select
    'X'
  from
    pay_payroll_actions ppa,
    pay_assignment_actions paa
  where
    ppa.action_status = 'C' and
    ppa.action_type in ('Q','R') and
    ppa.date_earned between p_pay_period_start_date and
      p_pay_period_end_date and
    ppa.payroll_action_id = paa.payroll_action_id and
    paa.assignment_id = p_assignment_id;


  CURSOR cur_ele_entries(p_start_date date,
                         p_end_date date) IS
  select
    pet.element_type_id,
    pee.element_entry_id,
    pee.creator_type,
    pee.source_id,
    pee.source_asg_action_id,
    nvl(pet.element_information3,'DE') element_information3,
    peev.screen_entry_value,
    pec.classification_name,
    pec.classification_id,
    pet.element_information1
  from
    pay_element_entries_f       pee,
    pay_element_links_f         pel,
    pay_element_types_f         pet,
    pay_element_entry_values_f  peev,
    pay_input_values_f          piv,
    pay_retro_component_usages  prcu,
    pay_element_span_usages     pesu,
    pay_retro_components        prc,
    pay_time_spans              pts,
    pay_element_classifications pec
  where
    pee.assignment_id = p_assignment_id and
    pee.creator_type in ('EE','RR') and
    pee.effective_start_date <= p_end_date and
    pee.effective_end_date >=  p_start_date and
    pee.element_link_id = pel.element_link_id and
    pel.effective_start_date <= p_end_date and
    pel.effective_end_date >=  p_start_date and
    pel.element_type_id = pet.element_type_id and
    pet.effective_start_date <= p_end_date and
    pet.effective_end_date >= p_start_date and
    pet.element_type_id = pesu.retro_element_type_id and
    pesu.time_span_id = pts.time_span_id and
    pesu.retro_component_usage_id = prcu.retro_component_usage_id and
    prcu.retro_component_id = prc.retro_component_id and
    pts.creator_id = prc.retro_component_id and
    prc.legislation_code = 'CA' and
    prc.short_name = 'Retropay' and
    pee.element_entry_id = peev.element_entry_id and
    peev.effective_start_date <= p_end_date and
    peev.effective_end_date >= p_start_date and
    peev.input_value_id = piv.input_value_id and
    piv.element_type_id = pet.element_type_id and
    piv.effective_start_date <= p_end_date and
    piv.effective_end_date >= p_start_date and
    piv.name = 'Pay Value' and
    pet.classification_id = pec.classification_id and
    pec.classification_name in ('Earnings',
                                'Supplemental Earnings',
                                'Taxable Benefits');

  cursor cur_originating_period_rr_de(p_run_result_id  number,
                                      p_start_date     date,
                                      p_end_date       date) is
  select ppa.date_earned
  from
  pay_run_results prr,
  pay_assignment_actions paa,
  pay_payroll_actions ppa
  where ppa.payroll_action_id  = paa.payroll_action_id
  and ppa.date_earned between p_start_date
                      and     p_end_date
  and prr.assignment_action_id = paa.assignment_action_id
  and prr.run_result_id        = p_run_result_id;

  cursor cur_originating_period_asg_de(p_asg_action_id  number,
                                       p_start_date     date,
                                       p_end_date       date) is
  select ppa.date_earned
  from
  pay_assignment_actions paa,
  pay_payroll_actions ppa
  where ppa.payroll_action_id  = paa.payroll_action_id
  and ppa.date_earned between p_start_date
                      and     p_end_date
  and paa.assignment_action_id = p_asg_action_id;

    l_pay_period_start_date date;
    l_pay_period_end_date   date;
    l_pay_period_st_date    date;
    l_pay_period_e_date     date;
    period_from             number;
    period_to               number;
    dummy                   varchar2(1);
    l_rehire                varchar2(1);
    l_next_prd_start_date   date;

  CURSOR cur_ftr(p_ftr_start_date DATE,
                 p_ftr_end_date DATE) IS
  SELECT
    'X'
  FROM
    pay_ca_emp_fed_tax_info_f
  WHERE
    assignment_id = p_assignment_id AND
    effective_start_date <= p_ftr_end_date AND
    effective_end_date >= p_ftr_start_date;

  l_ftr_exists BOOLEAN := FALSE;
  l_hour_start_date  DATE;

BEGIN

  hr_utility.set_location('Starting: ' || l_proc_name, 10);
  hr_utility.set_location('p_start_date: ' || to_char(p_start_date), 11);
  hr_utility.set_location('p_end_date: ' || p_end_date, 12);

  /*
   * Initialise the output parameters
   */
  p_total_insurable := 0;
  FOR r_index IN 1..53 LOOP
    p_period_total(r_index) := 0;
  END LOOP;

  OPEN csr_get_period_type(p_payroll_id,
                           p_end_date);
  FETCH csr_get_period_type INTO p_period_type,
                                 l_last_period_start_date,
                                 l_last_period_end_date;
  CLOSE csr_get_period_type;


  hr_utility.set_location('l_last_period_start_date: ' ||
                          l_last_period_start_date, 13);
  hr_utility.set_location(l_proc_name, 20);
  IF p_total_type = 'EI Hours' THEN

    IF p_period_type = 'Week'        OR
       p_period_type = 'Bi-Week'     OR
       p_period_type = 'Lunar Month' THEN
      hr_utility.set_location(l_proc_name, 30);
      l_start_date := l_last_period_start_date - 364;
    ELSIF p_period_type = 'Semi-Month'     OR
          p_period_type = 'Calendar Month' THEN
      hr_utility.set_location(l_proc_name, 40);
      l_start_date := ADD_MONTHS(l_last_period_start_date, -12);
    END IF;

    hr_utility.set_location('EI Hours l_start_date: ' ||
                                   l_start_date, 20);

    hr_utility.set_location('EI Hours p_start_date: ' ||
                                   p_start_date, 20);

    l_period_start_date_exists := 'N';

    IF p_start_date IS NOT NULL AND
       p_start_date > l_start_date THEN

       open cur_next_prd_start_date;
       fetch cur_next_prd_start_date
       into l_next_prd_start_date;
       close cur_next_prd_start_date;

       l_start_date := p_start_date;

       hr_utility.trace('l_next_prd_start_date : '||to_char(l_next_prd_start_date));
       hr_utility.trace('l_start_date : '||to_char(l_start_date));

       -- Check to see if l_start_date is the start date of a period
       -- If it is, then we set l_period_start_date_exists to Y
       -- this means that the previous ROE date was on the last day
       -- of a period

       OPEN csr_start_date (p_payroll_id, l_start_date);
       FETCH csr_start_date INTO l_period_start_date;
       IF csr_start_date%NOTFOUND THEN
            CLOSE csr_start_date;
            l_period_start_date_exists := 'Y';
            --since we are not passing previous ROE Date but the first day worked
            --for current ROE, pay period should be included for calculations.
       ELSE
            l_period_start_date_exists := 'Y';
            CLOSE csr_start_date;
       END IF;

    END IF;

    l_rehire := populate_date_lookup_table(p_payroll_id,
                                           p_assignment_id,
                                           l_start_date,
                                           l_last_period_end_date,
                                           l_last_period_start_date);

    -- If l_period_start_date_exists is Y then we want to
    -- retrieve the hours from the period l_start_date falls in
    -- not the next period

    IF l_rehire = 'N' AND
       l_next_prd_start_date IS NOT NULL AND
       l_period_start_date_exists = 'N'  THEN

        -- If there are no rehires then get the hours
        -- starting from the next period

       l_hour_start_date := l_next_prd_start_date;

    ELSE

        -- If rehires exist in the previous roe pay period
        -- then get hours starting from l_start_date

       l_hour_start_date := l_start_date;

    END IF;

    hr_utility.trace('EI Hours: l_hour_start_date = '
                            || to_char(l_hour_start_date));
    OPEN cur_ftr(l_hour_start_date,
                 l_pay_period_end_date);
    FETCH cur_ftr
    INTO dummy;

    IF cur_ftr%NOTFOUND THEN
      hr_utility.trace('EI Hours cur_ftr not Found !!!');
      l_ftr_exists := FALSE;
    ELSE
      hr_utility.trace('EI Hours cur_ftr Found !!!');
      l_ftr_exists := TRUE;
    END IF;

    CLOSE cur_ftr;

    IF l_ftr_exists THEN

      hr_utility.trace('EI Hours l_ftr_exists !!!');
      OPEN csr_dp_hours_total_ftr_exists(p_assignment_id,
                                p_gre,
                                l_hour_start_date,
                                l_last_period_end_date);
      FETCH csr_dp_hours_total_ftr_exists INTO l_dp_hours_total;
      CLOSE csr_dp_hours_total_ftr_exists;

      OPEN csr_de_hours_total_ftr_exists(p_assignment_id,
                                p_gre,
                                l_hour_start_date,
                                l_last_period_end_date);
      FETCH csr_de_hours_total_ftr_exists INTO l_de_hours_total;
      CLOSE csr_de_hours_total_ftr_exists;

    ELSE

      hr_utility.trace('EI Hours NOT l_ftr_exists !!!');
      OPEN csr_dp_hours_total_ftr_nexists(p_assignment_id,
                                p_gre,
                                l_hour_start_date,
                                l_last_period_end_date);
      FETCH csr_dp_hours_total_ftr_nexists INTO l_dp_hours_total;
      CLOSE csr_dp_hours_total_ftr_nexists;

      OPEN csr_de_hours_total_ftr_nexists(p_assignment_id,
                                p_gre,
                                l_hour_start_date,
                                l_last_period_end_date);
      FETCH csr_de_hours_total_ftr_nexists INTO l_de_hours_total;
      CLOSE csr_de_hours_total_ftr_nexists;

    END IF;

    hr_utility.trace (' l_dp_hours_total = ' || to_char(l_dp_hours_total));
    hr_utility.trace (' l_de_hours_total = ' || to_char(l_de_hours_total));

    p_total_insurable := NVL(l_dp_hours_total,0) +
                         NVL(l_de_hours_total,0);

    hr_utility.trace('Total Hours : '|| to_char(p_total_insurable));

    RETURN 'BOX15A';

  ELSIF p_total_type = 'EI Earnings' THEN
/* Modified the period count for bug 4510534 */
    IF p_period_type = 'Week'     THEN
      hr_utility.set_location(l_proc_name, 50);
      l_start_date := l_last_period_start_date - 365;
      l_period_count := 53;
      l_period_count1 := 27;
    ELSIF p_period_type = 'Bi-Week' THEN
      hr_utility.set_location(l_proc_name, 60);
      l_start_date := l_last_period_start_date - 365;
      l_period_count := 27;
      l_period_count1 := 14;
    ELSIF p_period_type = 'Semi-Month' THEN
      hr_utility.set_location(l_proc_name, 70);
      l_start_date := ADD_MONTHS(l_last_period_start_date, -12);
      l_period_count := 25;
      l_period_count1 := 13;
    ELSIF p_period_type = 'Calendar Month' THEN
      hr_utility.set_location(l_proc_name, 80);
      l_start_date := ADD_MONTHS(l_last_period_start_date, -12);
      l_period_count := 13;
      l_period_count1 := 7;
    ELSIF p_period_type = 'Lunar Month' THEN
      hr_utility.set_location(l_proc_name, 90);
      l_start_date := l_last_period_start_date - 336;
      l_period_count := 14;
      l_period_count1 := 7;
    END IF;

    IF p_start_date IS NOT NULL AND
       p_start_date > l_start_date THEN

     -- commented out because it can cause earnings not to be archived

/*     open cur_next_prd_start_date;
       fetch cur_next_prd_start_date
       into l_start_date;
       close cur_next_prd_start_date; */

       l_start_date := p_start_date;

    END IF;

    IF p_term_or_abs_flag = 'Y' THEN

      open cur_pay_period_dates(p_end_date);
      fetch cur_pay_period_dates
      into
        l_prd_st_date_after_final,
        l_prd_end_date_after_final;
      close cur_pay_period_dates;

      l_rehire := populate_date_lookup_table(p_payroll_id,
                                             p_assignment_id,
                                             l_start_date,
                                             l_prd_end_date_after_final,
                                             l_prd_st_date_after_final);
    hr_utility.trace('p_assignment_id de' || to_char(p_assignment_id));
    hr_utility.trace('p_gre de' || to_char(p_gre));
    hr_utility.trace('l_start_date de' || to_char(l_start_date));
    hr_utility.trace('l_prd_end_date_after_final de' || to_char(l_prd_end_date_after_final));



/* Modified the code to add aadditional amounts 28 to 53 for bug4510534 */
    OPEN csr_get_de_total(p_assignment_id,
                          p_gre,
                          l_start_date,l_prd_end_date_after_final);

    FETCH csr_get_de_total INTO l_de_total(1),
                                l_de_total(2),
                                l_de_total(3),
                                l_de_total(4),
                                l_de_total(5),
                                l_de_total(6),
                                l_de_total(7),
                                l_de_total(8),
                                l_de_total(9),
                                l_de_total(10),
                                l_de_total(11),
                                l_de_total(12),
                                l_de_total(13),
                                l_de_total(14),
                                l_de_total(15),
                                l_de_total(16),
                                l_de_total(17),
                                l_de_total(18),
                                l_de_total(19),
                                l_de_total(20),
                                l_de_total(21),
                                l_de_total(22),
                                l_de_total(23),
                                l_de_total(24),
                                l_de_total(25),
                                l_de_total(26),
                                l_de_total(27),
                                l_de_total(28),
                                l_de_total(29),
                                l_de_total(30),
                                l_de_total(31),
                                l_de_total(32),
                                l_de_total(33),
                                l_de_total(34),
                                l_de_total(35),
                                l_de_total(36),
                                l_de_total(37),
                                l_de_total(38),
                                l_de_total(39),
                                l_de_total(40),
                                l_de_total(41),
                                l_de_total(42),
                                l_de_total(43),
                                l_de_total(44),
                                l_de_total(45),
                                l_de_total(46),
                                l_de_total(47),
                                l_de_total(48),
                                l_de_total(49),
                                l_de_total(50),
                                l_de_total(51),
                                l_de_total(52),
                                l_de_total(53) ;
    CLOSE csr_get_de_total;

    hr_utility.trace('p_assignment_id dp' || to_char(p_assignment_id));
    hr_utility.trace('p_gre dp' || to_char(p_gre));
    hr_utility.trace('l_start_date dp' || to_char(l_start_date));
    hr_utility.trace('l_prd_end_date_after_final dp' || to_char(l_prd_end_date_after_final));



      OPEN csr_get_dp_total(p_assignment_id,
                            p_gre,
                            l_start_date,
                            l_prd_end_date_after_final);

      FETCH csr_get_dp_total INTO l_dp_total(1),
                                l_dp_total(2),
                                l_dp_total(3),
                                l_dp_total(4),
                                l_dp_total(5),
                                l_dp_total(6),
                                l_dp_total(7),
                                l_dp_total(8),
                                l_dp_total(9),
                                l_dp_total(10),
                                l_dp_total(11),
                                l_dp_total(12),
                                l_dp_total(13),
                                l_dp_total(14),
                                l_dp_total(15),
                                l_dp_total(16),
                                l_dp_total(17),
                                l_dp_total(18),
                                l_dp_total(19),
                                l_dp_total(20),
                                l_dp_total(21),
                                l_dp_total(22),
                                l_dp_total(23),
                                l_dp_total(24),
                                l_dp_total(25),
                                l_dp_total(26),
                                l_dp_total(27),
                                l_dp_total(28),
                                l_dp_total(29),
                                l_dp_total(30),
                                l_dp_total(31),
                                l_dp_total(32),
                                l_dp_total(33),
                                l_dp_total(34),
                                l_dp_total(35),
                                l_dp_total(36),
                                l_dp_total(37),
                                l_dp_total(38),
                                l_dp_total(39),
                                l_dp_total(40),
                                l_dp_total(41),
                                l_dp_total(42),
                                l_dp_total(43),
                                l_dp_total(44),
                                l_dp_total(45),
                                l_dp_total(46),
                                l_dp_total(47),
                                l_dp_total(48),
                                l_dp_total(49),
                                l_dp_total(50),
                                l_dp_total(51),
                                l_dp_total(52),
                                l_dp_total(53);
      CLOSE csr_get_dp_total;


      -- Must reset pay periods so that periods after termination
      -- are ignored for retro processing purposes

      l_rehire := populate_date_lookup_table(p_payroll_id,
                                             p_assignment_id,
                                             l_start_date,
                                             l_last_period_end_date,
                                             l_last_period_start_date);
    ELSE

      hr_utility.trace('p_assignment_id de1= ' || to_char(p_assignment_id));
      hr_utility.trace('p_gre de1= ' || to_char(p_gre));
      hr_utility.trace('l_start_date de1= ' || to_char(l_start_date));
      hr_utility.trace('l_last_period_end_date de1= '
                                  || to_char(l_last_period_end_date));

    OPEN csr_get_de_total1(p_assignment_id,
                          p_gre,
                          l_start_date,l_last_period_end_date);

    FETCH csr_get_de_total1 INTO l_de_total(1),
                                l_de_total(2),
                                l_de_total(3),
                                l_de_total(4),
                                l_de_total(5),
                                l_de_total(6),
                                l_de_total(7),
                                l_de_total(8),
                                l_de_total(9),
                                l_de_total(10),
                                l_de_total(11),
                                l_de_total(12),
                                l_de_total(13),
                                l_de_total(14),
                                l_de_total(15),
                                l_de_total(16),
                                l_de_total(17),
                                l_de_total(18),
                                l_de_total(19),
                                l_de_total(20),
                                l_de_total(21),
                                l_de_total(22),
                                l_de_total(23),
                                l_de_total(24),
                                l_de_total(25),
                                l_de_total(26),
                                l_de_total(27),
                                l_de_total(28),
                                l_de_total(29),
                                l_de_total(30),
                                l_de_total(31),
                                l_de_total(32),
                                l_de_total(33),
                                l_de_total(34),
                                l_de_total(35),
                                l_de_total(36),
                                l_de_total(37),
                                l_de_total(38),
                                l_de_total(39),
                                l_de_total(40),
                                l_de_total(41),
                                l_de_total(42),
                                l_de_total(43),
                                l_de_total(44),
                                l_de_total(45),
                                l_de_total(46),
                                l_de_total(47),
                                l_de_total(48),
                                l_de_total(49),
                                l_de_total(50),
                                l_de_total(51),
                                l_de_total(52),
                                l_de_total(53) ;
    CLOSE csr_get_de_total1;
      hr_utility.trace('p_assignment_id dp1= ' || to_char(p_assignment_id));
      hr_utility.trace('p_gre dp1= ' || to_char(p_gre));
      hr_utility.trace('l_start_date dp1= ' || to_char(l_start_date));
      hr_utility.trace('l_last_period_end_date dp1= '
                                  || to_char(l_last_period_end_date));

      OPEN csr_get_dp_total1(p_assignment_id,
                             p_gre,
                             l_start_date,
                             l_last_period_end_date);
      FETCH csr_get_dp_total1 INTO l_dp_total(1),
                                l_dp_total(2),
                                l_dp_total(3),
                                l_dp_total(4),
                                l_dp_total(5),
                                l_dp_total(6),
                                l_dp_total(7),
                                l_dp_total(8),
                                l_dp_total(9),
                                l_dp_total(10),
                                l_dp_total(11),
                                l_dp_total(12),
                                l_dp_total(13),
                                l_dp_total(14),
                                l_dp_total(15),
                                l_dp_total(16),
                                l_dp_total(17),
                                l_dp_total(18),
                                l_dp_total(19),
                                l_dp_total(20),
                                l_dp_total(21),
                                l_dp_total(22),
                                l_dp_total(23),
                                l_dp_total(24),
                                l_dp_total(25),
                                l_dp_total(26),
                                l_dp_total(27),
                                l_dp_total(28),
                                l_dp_total(29),
                                l_dp_total(30),
                                l_dp_total(31),
                                l_dp_total(32),
                                l_dp_total(33),
                                l_dp_total(34),
                                l_dp_total(35),
                                l_dp_total(36),
                                l_dp_total(37),
                                l_dp_total(38),
                                l_dp_total(39),
                                l_dp_total(40),
                                l_dp_total(41),
                                l_dp_total(42),
                                l_dp_total(43),
                                l_dp_total(44),
                                l_dp_total(45),
                                l_dp_total(46),
                                l_dp_total(47),
                                l_dp_total(48),
                                l_dp_total(49),
                                l_dp_total(50),
                                l_dp_total(51),
                                l_dp_total(52),
                                l_dp_total(53);
      CLOSE csr_get_dp_total1;

    END IF;

    hr_utility.trace('l_de_total(1) = ' || to_char(l_de_total(1)));
    hr_utility.trace('l_de_total(2) = ' || to_char(l_de_total(2)));
    hr_utility.trace('l_de_total(3) = ' || to_char(l_de_total(3)));
    hr_utility.trace('l_de_total(4) = ' || to_char(l_de_total(4)));
    hr_utility.trace('l_de_total(5) = ' || to_char(l_de_total(5)));
    hr_utility.trace('l_de_total(6) = ' || to_char(l_de_total(6)));
    hr_utility.trace('l_de_total(7) = ' || to_char(l_de_total(7)));
    hr_utility.trace('l_de_total(8) = ' || to_char(l_de_total(8)));
    hr_utility.trace('l_de_total(9) = ' || to_char(l_de_total(9)));
    hr_utility.trace('l_de_total(10) = ' || to_char(l_de_total(10)));
    hr_utility.trace('l_de_total(11) = ' || to_char(l_de_total(11)));
    hr_utility.trace('l_de_total(12) = ' || to_char(l_de_total(12)));
    hr_utility.trace('l_de_total(13) = ' || to_char(l_de_total(13)));
    hr_utility.trace('l_de_total(14) = ' || to_char(l_de_total(14)));
    hr_utility.trace('l_de_total(15) = ' || to_char(l_de_total(15)));
    hr_utility.trace('l_de_total(16) = ' || to_char(l_de_total(16)));
    hr_utility.trace('l_de_total(17) = ' || to_char(l_de_total(17)));
    hr_utility.trace('l_de_total(18) = ' || to_char(l_de_total(18)));
    hr_utility.trace('l_de_total(19) = ' || to_char(l_de_total(19)));
    hr_utility.trace('l_de_total(20) = ' || to_char(l_de_total(20)));
    hr_utility.trace('l_de_total(21) = ' || to_char(l_de_total(21)));
    hr_utility.trace('l_de_total(22) = ' || to_char(l_de_total(22)));
    hr_utility.trace('l_de_total(23) = ' || to_char(l_de_total(23)));
    hr_utility.trace('l_de_total(24) = ' || to_char(l_de_total(24)));
    hr_utility.trace('l_de_total(25) = ' || to_char(l_de_total(25)));
    hr_utility.trace('l_de_total(26) = ' || to_char(l_de_total(26)));
    hr_utility.trace('l_de_total(27) = ' || to_char(l_de_total(27)));



    hr_utility.trace('l_dp_total(1) = ' || to_char(l_dp_total(1)));
    hr_utility.trace('l_dp_total(2) = ' || to_char(l_dp_total(2)));
    hr_utility.trace('l_dp_total(3) = ' || to_char(l_dp_total(3)));
    hr_utility.trace('l_dp_total(4) = ' || to_char(l_dp_total(4)));
    hr_utility.trace('l_dp_total(5) = ' || to_char(l_dp_total(5)));
    hr_utility.trace('l_dp_total(6) = ' || to_char(l_dp_total(6)));
    hr_utility.trace('l_dp_total(7) = ' || to_char(l_dp_total(7)));
    hr_utility.trace('l_dp_total(8) = ' || to_char(l_dp_total(8)));
    hr_utility.trace('l_dp_total(9) = ' || to_char(l_dp_total(9)));
    hr_utility.trace('l_dp_total(10) = ' || to_char(l_dp_total(10)));
    hr_utility.trace('l_dp_total(11) = ' || to_char(l_dp_total(11)));
    hr_utility.trace('l_dp_total(12) = ' || to_char(l_dp_total(12)));
    hr_utility.trace('l_dp_total(13) = ' || to_char(l_dp_total(13)));
    hr_utility.trace('l_dp_total(14) = ' || to_char(l_dp_total(14)));
    hr_utility.trace('l_dp_total(15) = ' || to_char(l_dp_total(15)));
    hr_utility.trace('l_dp_total(16) = ' || to_char(l_dp_total(16)));
    hr_utility.trace('l_dp_total(17) = ' || to_char(l_dp_total(17)));
    hr_utility.trace('l_dp_total(18) = ' || to_char(l_dp_total(18)));
    hr_utility.trace('l_dp_total(19) = ' || to_char(l_dp_total(19)));
    hr_utility.trace('l_dp_total(20) = ' || to_char(l_dp_total(20)));
    hr_utility.trace('l_dp_total(21) = ' || to_char(l_dp_total(21)));
    hr_utility.trace('l_dp_total(22) = ' || to_char(l_dp_total(22)));
    hr_utility.trace('l_dp_total(23) = ' || to_char(l_dp_total(23)));
    hr_utility.trace('l_dp_total(24) = ' || to_char(l_dp_total(24)));
    hr_utility.trace('l_dp_total(25) = ' || to_char(l_dp_total(25)));
    hr_utility.trace('l_dp_total(26) = ' || to_char(l_dp_total(26)));
    hr_utility.trace('l_dp_total(27) = ' || to_char(l_dp_total(27)));


    hr_utility.set_location(l_proc_name, 100);

    -- If the hire date is later than either the
    -- previous roe date (p_start_date) or the
    -- starting date for the current roe then hire
    -- date should be used for calculating the
    -- number of pay periods

    open cur_date_of_hire;
    fetch cur_date_of_hire
    into  l_hire_date;
    close cur_date_of_hire;

    hr_utility.trace('l_hire_date = ' || to_char(l_hire_date));

    if p_start_date is not null and
       p_start_date > l_start_date then

      hr_utility.trace('p_start_date = ' || to_char(p_start_date));

      if l_hire_date > p_start_date then
        l_start_date1 := l_hire_date;
      else
        l_start_date1 := p_start_date;
      end if;

    else

      hr_utility.trace('l_start_date = ' || to_char(l_start_date));

      if l_hire_date > l_start_date then
        l_start_date1 := l_hire_date;
      else
        l_start_date1 := l_start_date;
      end if;

    end if;

    hr_utility.trace('l_start_date1 = ' || to_char(l_start_date1));

    OPEN  cur_count_pay_periods(l_start_date1);
    FETCH cur_count_pay_periods
     INTO l_no_of_pay_periods;
    CLOSE cur_count_pay_periods;

    hr_utility.trace('l_no_of_pay_periods = ' || to_char(l_no_of_pay_periods));
    hr_utility.trace('l_period_count = ' || to_char(l_period_count));

    FOR l_index IN 1..l_period_count LOOP

      p_period_total(l_index) := l_dp_total(l_index) + l_de_total(l_index);

    hr_utility.trace('l_dp_total =  ' || to_char(l_dp_total(l_index)));
    hr_utility.trace('l_de_total =  ' || to_char(l_de_total(l_index)));
    hr_utility.trace('l_index =  ' || to_char(l_index));

      IF p_period_total(l_index) = 0 and
      l_index <= l_no_of_pay_periods  THEN
        l_box15c_flag := TRUE;
      END IF;
      if l_index <= l_period_count1 then
        p_total_insurable := p_total_insurable + p_period_total(l_index);
      end if;

    END LOOP;

    p_no_of_periods := l_period_count;

    -- Retro Functionality starts here

    hr_utility.trace('Retro Functionality starts here');

    for i in cur_retro_run(l_start_date,
                           l_last_period_end_date) loop

    hr_utility.trace('cur_retro_run found');
    hr_utility.trace('i.effective_date = ' || to_char(i.effective_date));
    hr_utility.trace('i.start_date = ' || to_char(i.start_date));

    open cur_curr_pay_period_dates(i.effective_date);
    fetch cur_curr_pay_period_dates
    into l_pay_period_start_date,
         l_pay_period_end_date;
    close cur_curr_pay_period_dates;

    hr_utility.trace('l_pay_period_start_date = ' || to_char(l_pay_period_start_date));
    hr_utility.trace('l_pay_period_end_date = ' || to_char(l_pay_period_end_date));

    open cur_payroll_exists(l_pay_period_start_date,
                            l_pay_period_end_date);
    fetch cur_payroll_exists
    into dummy;
    if cur_payroll_exists%NOTFOUND then
      close cur_payroll_exists;
    else
      close cur_payroll_exists;

      for k in cur_ele_entries(l_pay_period_start_date,
                               l_pay_period_end_date) loop

     hr_utility.trace('k.element_type_id = ' || to_char(k.element_type_id));
     hr_utility.trace('k.creator_type = ' || k.creator_type);
     hr_utility.trace('k.source_id = ' || to_char(nvl(k.source_id,0)));
     hr_utility.trace('k.source_asg_action_id = ' || to_char(nvl(k.source_asg_action_id,0)));
     hr_utility.trace('k.screen_entry_value = ' || nvl(k.screen_entry_value,'0'));
     hr_utility.trace('k.element_entry_id = ' || to_char(k.element_entry_id));
     hr_utility.trace('k.classification_name = ' || nvl(k.classification_name,' '));
     hr_utility.trace('k.classification_id = ' || to_char(nvl(k.classification_id,0)));
     hr_utility.trace('k.element_information1 = ' || k.element_information1);

        if (((k.element_entry_id <> l_prev_element_entry_id) or
             (l_prev_element_entry_id is null)) and
            (taxability_rule_exists(k.classification_name,
                                    k.classification_id,
                                    k.element_information1,
                                    l_pay_period_end_date,
                                    'EIM') = 'TRUE')) then

           l_value := to_number(k.screen_entry_value);

           if (k.element_information3 = 'DE') then

              if k.creator_type = 'RR' then

                 open cur_originating_period_rr_de(k.source_id,
                                                   l_start_date,
                                                   l_last_period_end_date);
                 fetch cur_originating_period_rr_de into l_start_period;
                 close cur_originating_period_rr_de;

              else

                 open cur_originating_period_asg_de(k.source_asg_action_id,
                                                    l_start_date,
                                                    l_last_period_end_date);
                 fetch cur_originating_period_asg_de into l_start_period;
                 close cur_originating_period_asg_de;

              end if;

           else /* Retro element is Date Paid */

              l_start_period := null;

           end if;

           period_from := pay_ca_roe_ei_pkg.get_pd_num(i.effective_date,
                                                       l_last_period_end_date);

           if (l_start_period is not null and
               l_value is not null) then

              period_to   := pay_ca_roe_ei_pkg.get_pd_num(l_start_period,
                                                          l_last_period_end_date);

              hr_utility.trace('period_from = ' || to_char(period_from));
              hr_utility.trace('period_to = ' || to_char(period_to));

              p_period_total(period_from) := p_period_total(period_from) - l_value;
              p_period_total(period_to)   := p_period_total(period_to)   + l_value;

           end if;

        end if; -- prev element entry id

        l_prev_element_entry_id := k.element_entry_id;

      end loop;

    end if;

    end loop;

    -- Retro Functionality ends here;

    hr_utility.set_location(l_proc_name, 120);
    IF l_box15c_flag THEN
      hr_utility.set_location('Ending: ' || l_proc_name, 130);
      RETURN 'BOX15C';
    ELSE
      hr_utility.set_location('Ending: ' || l_proc_name, 140);
      RETURN 'BOX15B';
    END IF;

  END IF;

END get_ei_amount_totals;


-------------------------------------------------------------------------------
-- Name:        populate_element_table
--
-- Parameters:
--
-- Description: This procedure creates element tables that would subsequently be
--              be used to determine if date paid or date earned should be used
--              to calculate the balance totals for the ROE report.
--              We need to check Special Features element because 'EI Horus' are
--              stored on the Special Features element.
-------------------------------------------------------------------------------
PROCEDURE populate_element_table(p_bg_id number) IS

  CURSOR cur_bal_type_id IS
  SELECT
    pbt.balance_type_id
  FROM
    pay_balance_types pbt
  WHERE
    pbt.balance_name = 'EI Hours' and
    pbt.legislation_code = 'CA';

  l_bal_type_id   pay_balance_types.balance_type_id%TYPE;

  /* CURSOR csr_get_element_id (p_dp_or_de   VARCHAR2)
  IS
  SELECT DISTINCT ele.element_type_id
  FROM   pay_element_types_f       ele,
         pay_template_core_objects tco1,
         pay_shadow_element_types  sel,
         pay_element_templates     etp,
         pay_template_core_objects tco2
  WHERE  tco2.core_object_type = 'ET'
  AND    etp.template_id       = tco2.template_id
  AND    sel.template_id       = etp.template_id
  AND    sel.element_name NOT LIKE ('%Special Inputs')
  AND    sel.element_type_id   = tco1.shadow_object_id
  AND    tco1.core_object_type = 'ET'
  AND    ele.element_type_id   = tco1.core_object_id
  AND    NVL(ele.element_information3,'DP') = p_dp_or_de
  UNION ALL
  SELECT DISTINCT ele.element_type_id
  FROM pay_element_types_f ele,
       pay_element_classifications pec
  WHERE ele.business_group_id is NULL
  AND   ele.legislation_code = 'CA'
  AND   pec.legislation_code = 'CA'
  AND   pec.classification_name = 'Earnings'
  AND   ele.classification_id = pec.classification_id
  AND   p_dp_or_de = 'DE'; */

  CURSOR csr_get_element_id (p_dp_or_de   VARCHAR2) IS
  SELECT
    pet.element_type_id
  FROM
    pay_element_types_f pet
  WHERE
    pet.business_group_id = p_bg_id and
    NVL(pet.element_information3,'DP') =  p_dp_or_de and
  EXISTS
    (SELECT 'X' FROM
     pay_input_values_f piv,
     pay_balance_feeds_f pbf
    WHERE
      piv.element_type_id = pet.element_type_id AND
      piv.input_value_id = pbf.input_value_id AND
      pbf.balance_type_id = l_bal_type_id)
  UNION ALL
  SELECT DISTINCT ele.element_type_id
  FROM pay_element_types_f ele,
       pay_element_classifications pec
  WHERE ele.business_group_id is NULL
  AND   ele.legislation_code = 'CA'
  AND   pec.legislation_code = 'CA'
  AND   pec.classification_name = 'Earnings'
  AND   ele.classification_id = pec.classification_id
  AND   p_dp_or_de = 'DE';

de_element        NUMBER;
dp_element        NUMBER;

BEGIN

  OPEN cur_bal_type_id;
  FETCH cur_bal_type_id
  INTO  l_bal_type_id;
  CLOSE cur_bal_type_id;

     OPEN csr_get_element_id ('DE');
     LOOP
          FETCH csr_get_element_id
          INTO  de_element;
          EXIT WHEN csr_get_element_id%NOTFOUND;

          de_element_table(de_element).element_id := de_element;

     END LOOP;

     CLOSE csr_get_element_id;

     OPEN csr_get_element_id ('DP');
     LOOP
          FETCH csr_get_element_id
          INTO  dp_element;
          EXIT WHEN csr_get_element_id%NOTFOUND;

          dp_element_table(dp_element).element_id := dp_element;

     END LOOP;

     CLOSE csr_get_element_id;

END populate_element_table;

-------------------------------------------------------------------------------
-- Name:        date_paid_or_date_earned
--
-- Parameters:  p_element_type_id
--              p_dp_or_de
--              p_ele_info3
--
-- Return:      VARCHAR2 - 'TRUE' or 'FALSE'
--
-- Description: This function determines whether we should use date paid or date
--              earned to calculate the balance totals for the ROE report.
-------------------------------------------------------------------------------
FUNCTION date_paid_or_date_earned
                    (p_element_type_id NUMBER,
                     p_dp_or_de        VARCHAR2,
                     p_ele_info3       VARCHAR2)
RETURN VARCHAR2 IS

BEGIN

  IF p_ele_info3 IN ('DP', 'DE') THEN
       IF p_ele_info3 = p_dp_or_de THEN
            RETURN 'TRUE';
       ELSE
            RETURN 'FALSE';
       END IF;
  ELSE
       IF p_dp_or_de = 'DE' THEN
            IF de_element_table.EXISTS(p_element_type_id) THEN
                 RETURN 'TRUE';
            ELSE
                 RETURN 'FALSE';
            END IF;
       ELSE
            IF dp_element_table.EXISTS(p_element_type_id) THEN
                 RETURN 'TRUE';
            ELSE
                 RETURN 'FALSE';
            END IF;
       END IF;
  END IF;

END date_paid_or_date_earned;

END pay_ca_roe_ei_pkg;

/
