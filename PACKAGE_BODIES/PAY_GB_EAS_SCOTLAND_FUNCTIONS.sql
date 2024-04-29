--------------------------------------------------------
--  DDL for Package Body PAY_GB_EAS_SCOTLAND_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_EAS_SCOTLAND_FUNCTIONS" AS
/* $Header: pygbeasf.pkb 120.0.12010000.3 2009/12/24 13:13:14 krreddy ship $ */

g_asg_id NUMBER;
g_count_main_eas_entry NUMBER := 0;
g_eas_main_iv_id NUMBER;
g_eas_ntpp_main_iv_id NUMBER;

FUNCTION get_current_freq(p_assignment_id IN NUMBER) RETURN NUMBER IS
   --
   CURSOR get_freq IS
   SELECT ptpt.number_per_fiscal_year
   FROM   per_all_assignments_f paaf, pay_all_payrolls_f pap, per_time_period_types ptpt, fnd_sessions fs
   WHERE  fs.session_id = userenv('sessionid')
   AND    paaf.assignment_id = p_assignment_id
   AND    fs.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_Date
   AND    pap.payroll_id = paaf.payroll_id
   AND    fs.effective_date BETWEEN pap.effective_start_date AND pap.effective_end_Date
   AND    pap.period_type = ptpt.period_type;
   --
   l_freq per_time_period_types.number_per_fiscal_year%TYPE;
   --
BEGIN
   --
   hr_utility.trace('Entering GET_CURRENT_FREQ, p_assignment_id='||p_assignment_id);
   --
   OPEN get_freq;
   FETCH get_freq INTO l_freq;
   CLOSE get_freq;
   --
   hr_utility.trace('Leaving GET_CURRENT_FREQ, l_freq='||l_freq);
   RETURN l_freq;
END get_current_freq;

/*
FUNCTION get_ni_process_type(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS

   CURSOR get_value IS
   SELECT nvl(min(peev.screen_entry_value), 'NP')
   FROM   fnd_sessions fs,
          pay_element_types_f pet,
          pay_input_values_f piv,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  fs.session_id = userenv('sessionid')
   AND    pet.element_name = 'NI'
   AND    pet.business_group_id IS NULL
   AND    pet.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND    pet.element_type_id = piv.element_type_id
   AND    piv.name = 'Process Type'
   AND    piv.business_group_id IS NULL
   AND    piv.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   AND    peef.assignment_id = p_assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    peev.input_value_id = piv.input_value_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date;
   --
   l_value pay_element_entry_values_f.screen_entry_value%TYPE
BEGIN
   hr_utility.trace('Entering GET_NI_PROCESS_TYPE: p_assignment_id='||p_assignment_id);
   --
   OPEN get_value;
   FETCH get_value INTO l_value;
   CLOSE get_value;
   --
   RETURN get_value;
END get_ni_process_type;
*/

FUNCTION count_main_eas_entry(p_assignment_id IN NUMBER) RETURN NUMBER IS

   CURSOR get_asg_tax_ref IS
   SELECT scl.segment1
   FROM   hr_soft_coding_keyflex scl,
          fnd_sessions fs,
          pay_payrolls_f ppf,
          per_all_assignments_f paaf
   WHERE  paaf.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    ppf.payroll_id = paaf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_Date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
   --
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   --
   CURSOR get_input_value_id(p_ele_name IN VARCHAR2) IS
   SELECT piv.input_value_id
   FROM   fnd_sessions fs,
          pay_element_types_f pet,
          pay_input_values_f piv
   WHERE  fs.session_id = userenv('sessionid')
   AND    pet.element_name = p_ele_name
   AND    pet.business_group_id IS NULL
   AND    pet.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND    pet.element_type_id = piv.element_type_id
   AND    piv.name = 'Main Entry'
   AND    piv.business_group_id IS NULL
   AND    piv.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date;
   --
   CURSOR get_main_count(p_asg_tax_ref IN VARCHAR2) IS
   SELECT count(*) cnt
   FROM   fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id)
   AND    nvl(SCREEN_ENTRY_VALUE, 'N') = 'Y';
   --
   l_count NUMBER := 0;
   --
   CURSOR chk_prim_asg(p_asg_tax_ref IN VARCHAR2) IS
   SELECT 1 cnt
   FROM fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = p_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id);
   --
BEGIN
   hr_utility.trace('Entering COUNT_MAIN_EAS_ENTRY, assignment_id='||p_assignment_id);
   -- Get tax ref of current asg.
   OPEN  get_asg_tax_ref;
   FETCH get_asg_tax_ref INTO l_asg_tax_ref;
   CLOSE get_asg_tax_ref;
   --
   hr_utility.trace('COUNT_MAIN_EAS_ENTRY: l_asg_tax_ref='||l_asg_tax_ref);
   --
   OPEN get_input_value_id('EAS Scotland');
   FETCH get_input_value_id INTO g_eas_main_iv_id;
   CLOSE get_input_value_id;
   --
   OPEN get_input_value_id('EAS Scotland NTPP');
   FETCH get_input_value_id INTO g_eas_ntpp_main_iv_id;
   CLOSE get_input_value_id;
   --
   OPEN  get_main_count(l_asg_tax_ref);
   FETCH get_main_count INTO l_count;
   CLOSE get_main_count;
   --
   hr_utility.trace('COUNT_MAIN_EAS_ENTRY: After main count, l_count='||l_count);
   IF l_count = 0 THEN
      OPEN chk_prim_asg(l_asg_tax_ref);
      FETCH chk_prim_asg INTO l_count;
      IF chk_prim_asg%NOTFOUND THEN
         l_count := 0;
      END IF;
      CLOSE chk_prim_asg;
      --
      hr_utility.trace('COUNT_MAIN_EAS_ENTRY: After check primary asg, l_count='||l_count);
      --
   END IF;
   --
   g_count_main_eas_entry := l_count;
   --
   hr_utility.trace('Leaving COUNT_MAIN_EAS_ENTRY: l_count='||l_count);
   RETURN l_count;
END count_main_eas_entry;

FUNCTION get_main_eas_pay_date(p_assignment_id IN NUMBER) RETURN DATE IS

   CURSOR get_asg_tax_ref IS
   SELECT scl.segment1, ppf.payroll_id
   FROM   hr_soft_coding_keyflex scl,
          fnd_sessions fs,
          pay_payrolls_f ppf,
          per_all_assignments_f paaf
   WHERE  paaf.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    ppf.payroll_id = paaf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_Date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
   --
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   l_asg_payroll_id pay_payrolls_f.payroll_id%TYPE;
   l_asg_period_start_date per_time_periods.start_date%TYPE;
   --
   CURSOR get_asg_period_start_date IS
   SELECT ptp.start_date
   FROM   per_time_periods ptp, fnd_sessions fs
   WHERE  fs.session_id = userenv('sessionid')
   AND    ptp.payroll_id = l_asg_payroll_id
   AND    fs.effective_date = ptp.regular_payment_date;
   --
   CURSOR get_main_payroll_id IS
   SELECT ppf.payroll_id
   FROM   fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = l_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id)
   AND    nvl(SCREEN_ENTRY_VALUE, 'N') = 'Y';
   --
   CURSOR get_prim_payroll_id IS
   SELECT ppf.payroll_id
   FROM fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = l_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id);
   --
   l_payroll_id NUMBER;
   l_pay_date   DATE;
   l_count NUMBER := 0;
   --
   CURSOR get_pay_date IS
   SELECT nvl(regular_payment_date, to_date('01-01-0001', 'DD-MM-YYYY'))
   FROM   per_time_periods ptp
   WHERE  l_asg_period_start_date BETWEEN ptp.start_date AND ptp.end_Date
   AND    ptp.payroll_id = l_payroll_id;
   --
BEGIN
   --
   hr_utility.trace('Entering GET_MAIN_EAS_PAY_DATE, p_assignment_id='||p_assignment_id||', g_asg_id='||g_asg_id);
   --
   -- Get tax ref of current asg.
   OPEN  get_asg_tax_ref;
   FETCH get_asg_tax_ref INTO l_asg_tax_ref, l_asg_payroll_id;
   CLOSE get_asg_tax_ref;
   --
   OPEN  get_asg_period_start_date;
   FETCH get_asg_period_start_date INTO l_asg_period_start_date;
   CLOSE get_asg_period_start_date;
   --
   hr_utility.trace('GET_MAIN_EAS_PAY_DATE: l_asg_tax_ref='||l_asg_tax_ref);
   hr_utility.trace('GET_MAIN_EAS_PAY_DATE: l_asg_period_start_date='||fnd_date.date_to_displaydate(l_asg_period_start_date));
   --
   IF nvl(p_assignment_id, -1) <> nvl(g_asg_id, -999) THEN
      hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Get count again.');
      l_count := count_main_eas_entry(p_assignment_id);
   ELSE
      l_count := g_count_main_eas_entry;
   END IF;
   --
   hr_utility.trace('GET_MAIN_EAS_PAY_DATE: l_count='||l_count);
   --
   IF nvl(l_count, 0) = 1 THEN
      hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Finding pay date on main entry.');
      --
      OPEN  get_main_payroll_id;
      FETCH get_main_payroll_id INTO l_payroll_id;
      IF get_main_payroll_id%NOTFOUND THEN
         hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Main entry not found.');
         l_payroll_id := NULL;
      END IF;
      CLOSE get_main_payroll_id;
      --
      IF l_payroll_id IS NULL THEN
         hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Checking primary assignment for payroll id.');
         OPEN get_prim_payroll_id;
         FETCH get_prim_payroll_id INTO l_payroll_id;
         IF get_prim_payroll_id%NOTFOUND THEN
            hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Payroll Id not found.');
            l_payroll_id := NULL;
         END IF;
         CLOSE get_prim_payroll_id;
      END IF;
      --
      IF l_payroll_id IS NULL THEN
         hr_utility.trace('GET_MAIN_EAS_PAY_DATE: No Payroll found, Return default date.');
         RETURN  to_date('01-01-0001', 'DD-MM-YYYY');
      ELSE
         OPEN get_pay_date;
         FETCH get_pay_date INTO l_pay_date;
         IF get_pay_date%NOTFOUND THEN
            hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Pay date not found, default date.');
            l_pay_date := to_date('01-01-0001', 'DD-MM-YYYY');
         END IF;
         CLOSE get_pay_date;
      END IF;
   ELSE
      hr_utility.trace('GET_MAIN_EAS_PAY_DATE: Main entry not found, Return default date.');
      l_pay_date :=  to_date('01-01-0001', 'DD-MM-YYYY');
   END IF;
   --
   hr_utility.trace('Leaving GET_MAIN_EAS_PAY_DATE: l_pay_date='||fnd_date.date_to_displaydate(l_pay_date));
   RETURN l_pay_date;
END get_main_eas_pay_date;

FUNCTION get_main_eas_freq(p_assignment_id IN NUMBER) RETURN NUMBER IS

   CURSOR get_asg_tax_ref IS
   SELECT scl.segment1
   FROM   hr_soft_coding_keyflex scl,
          fnd_sessions fs,
          pay_payrolls_f ppf,
          per_all_assignments_f paaf
   WHERE  paaf.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    ppf.payroll_id = paaf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_Date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
   --
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   --
   CURSOR get_main_payroll_id IS
   SELECT ppf.payroll_id
   FROM   fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = l_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id)
   AND    nvl(SCREEN_ENTRY_VALUE, 'N') = 'Y';
   --
   CURSOR get_prim_payroll_id IS
   SELECT ppf.payroll_id
   FROM fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = l_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id);
   --
   l_payroll_id NUMBER;
   l_freq       NUMBER;
   l_count NUMBER := 0;
   --
   CURSOR get_freq IS
   SELECT number_per_fiscal_year
   FROM   per_time_periods ptp, per_time_period_types ptpt, fnd_sessions fs
   WHERE  fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN ptp.start_date AND ptp.end_Date
   AND    ptp.payroll_id = l_payroll_id
   AND    ptp.period_type = ptpt.period_type;
   --
BEGIN
   --
   hr_utility.trace('Entering GET_MAIN_EAS_FREQ, p_assignment_id='||p_assignment_id||', g_asg_id='||g_asg_id);
   --
   -- Get tax ref of current asg.
   OPEN  get_asg_tax_ref;
   FETCH get_asg_tax_ref INTO l_asg_tax_ref;
   CLOSE get_asg_tax_ref;
   --
   hr_utility.trace('GET_MAIN_EAS_FREQ: l_asg_tax_ref='||l_asg_tax_ref);
   --
   IF nvl(p_assignment_id, -1) <> nvl(g_asg_id, -999) THEN
      hr_utility.trace('GET_MAIN_EAS_FREQ: Get count again.');
      l_count := count_main_eas_entry(p_assignment_id);
   ELSE
      l_count := g_count_main_eas_entry;
   END IF;
   --
   hr_utility.trace('GET_MAIN_EAS_FREQ: l_count='||l_count);
   --
   IF nvl(l_count, 0) = 1 THEN
      hr_utility.trace('GET_MAIN_EAS_FREQ: Finding frequency on main entry.');
      --
      OPEN  get_main_payroll_id;
      FETCH get_main_payroll_id INTO l_payroll_id;
      IF get_main_payroll_id%NOTFOUND THEN
         hr_utility.trace('GET_MAIN_EAS_FREQ: Main entry not found.');
         l_payroll_id := NULL;
      END IF;
      CLOSE get_main_payroll_id;
      --
      IF l_payroll_id IS NULL THEN
         hr_utility.trace('GET_MAIN_EAS_FREQ: Checking primary assignment for payroll id.');
         OPEN get_prim_payroll_id;
         FETCH get_prim_payroll_id INTO l_payroll_id;
         IF get_prim_payroll_id%NOTFOUND THEN
            hr_utility.trace('GET_MAIN_EAS_FREQ: Payroll Id not found.');
            l_payroll_id := NULL;
         END IF;
         CLOSE get_prim_payroll_id;
      END IF;
      --
      IF l_payroll_id IS NULL THEN
         hr_utility.trace('GET_MAIN_EAS_FREQ: No Payroll found, Return 0.');
         RETURN 0;
      ELSE
         OPEN get_freq;
         FETCH get_freq INTO l_freq;
         IF get_freq%NOTFOUND THEN
            hr_utility.trace('GET_MAIN_EAS_FREQ: Frequency  not found, default to 0.');
            l_freq := 0;
         END IF;
         CLOSE get_freq;
      END IF;
      --
   ELSE
      hr_utility.trace('GET_MAIN_EAS_FREQ: Main entry not found, Return 0.');
      l_freq := 0;
   END IF;
   --
   hr_utility.trace('Leaving GET_MAIN_EAS_FREQ: l_freq='||l_freq);
      RETURN l_freq;
END get_main_eas_freq;

FUNCTION get_main_entry_value(p_assignment_id IN NUMBER,
                              p_input_value_name IN VARCHAR2,
                              p_count OUT NOCOPY NUMBER) RETURN VARCHAR2 IS

   CURSOR get_asg_tax_ref IS
   SELECT scl.segment1
   FROM   hr_soft_coding_keyflex scl,
          fnd_sessions fs,
          pay_payrolls_f ppf,
          per_all_assignments_f paaf
   WHERE  paaf.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    ppf.payroll_id = paaf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_Date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id;
   --
   l_asg_tax_ref hr_soft_coding_keyflex.segment1%TYPE;
   --
   CURSOR get_input_value_id(p_ele_name IN VARCHAR2, p_iv_name IN VARCHAR2) IS
   SELECT piv.input_value_id
   FROM   fnd_sessions fs,
          pay_element_types_f pet,
          pay_input_values_f piv
   WHERE  fs.session_id = userenv('sessionid')
   AND    pet.element_name = p_ele_name
   AND    pet.business_group_id IS NULL
   AND    pet.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND    pet.element_type_id = piv.element_type_id
   AND    piv.name = p_iv_name
   AND    piv.business_group_id IS NULL
   AND    piv.legislation_code = 'GB'
   AND    fs.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date;
   --
   l_eas_iv_id    NUMBER;
   l_eas_ntpp_iv_id NUMBER;
   --
   CURSOR get_main_entry_id IS
   SELECT peef.element_entry_id
   FROM   fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = l_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id)
   AND    nvl(SCREEN_ENTRY_VALUE, 'N') = 'Y'
   AND    peef.target_entry_id IS NULL;
   --
   CURSOR chk_prim_entry_id IS
   SELECT peef.element_entry_id
   FROM fnd_sessions fs,
          per_all_assignments_f paaf1,
          per_all_assignments_f paaf2,
          pay_all_payrolls_f ppf,
          hr_soft_coding_keyflex scl,
          pay_element_entries_f peef,
          pay_element_entry_values_f peev
   WHERE  paaf1.assignment_id = p_assignment_id
   AND    fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
   AND    paaf1.person_id = paaf2.person_id
   AND    nvl(paaf2.primary_flag, 'N') = 'Y'
   AND    fs.effective_date BETWEEN paaf2.effective_start_date AND paaf2.effective_end_date
   AND    paaf2.payroll_id = ppf.payroll_id
   AND    fs.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND    ppf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    scl.segment1 = l_asg_tax_ref
   AND    paaf2.assignment_id = peef.assignment_id
   AND    fs.effective_date BETWEEN peef.effective_start_date AND peef.effective_end_date
   AND    peef.element_entry_id = peev.element_entry_id
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.input_value_id IN (g_eas_main_iv_id, g_eas_ntpp_main_iv_id)
   AND    peef.target_entry_id IS NULL;
   --
   l_entry_id NUMBER;
   --
   CURSOR get_value IS
   SELECT peev.screen_entry_value
   FROM   fnd_sessions fs, pay_element_entry_values_f peev
   WHERE  fs.session_id = userenv('sessionid')
   AND    fs.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   AND    peev.element_entry_id = l_entry_id
   AND    peev.input_value_id IN (l_eas_iv_id, l_eas_ntpp_iv_id);
   --
   l_value  pay_element_entry_values_f.screen_entry_value%TYPE;
   l_count   NUMBER;
   --
BEGIN
   hr_utility.trace('Entering GET_MAIN_ENTRY_VALUE, p_assignment_id='||p_assignment_id||', p_input_value_name='||p_input_value_name);
   --
   -- Get tax ref of current asg.
   OPEN  get_asg_tax_ref;
   FETCH get_asg_tax_ref INTO l_asg_tax_ref;
   CLOSE get_asg_tax_ref;
   --
   hr_utility.trace('GET_MAIN_EAS_ENTRY_VALUE: l_asg_tax_ref='||l_asg_tax_ref);
   --
   IF nvl(p_assignment_id, -1) <> nvl(g_asg_id, -999) THEN
      hr_utility.trace('GET_MAIN_ENTRY_VALUE: Get count again.');
      l_count := count_main_eas_entry(p_assignment_id);
   ELSE
      l_count := g_count_main_eas_entry;
   END IF;
   --
   hr_utility.trace('GET_MAIN_ENTRY_VALUE: l_count='||l_count||
                    ', g_asg_id='||g_asg_id||
                    ', g_eas_main_iv_id='||g_eas_main_iv_id||
                    ', g_eas_ntpp_main_iv_id='||g_eas_ntpp_main_iv_id);
   p_count := l_count;
   --
   IF nvl(l_count, 0) = 1 THEN
      hr_utility.trace('GET_MAIN_ENTRY_VALUE: Finding input value on main entry.');
      --
      OPEN get_input_value_id('EAS Scotland', p_input_value_name);
      FETCH get_input_value_id INTO l_eas_iv_id;
      CLOSE get_input_value_id;
      --
      OPEN get_input_value_id('EAS Scotland NTPP', p_input_value_name);
      FETCH get_input_value_id INTO l_eas_ntpp_iv_id;
      CLOSE get_input_value_id;
      --
      hr_utility.trace('GET_MAIN_ENTRY_VALUE: l_eas_iv_id='||l_eas_iv_id||', l_eas_ntpp_iv_id='||l_eas_ntpp_iv_id);
      --
      OPEN get_main_entry_id;
      FETCH get_main_entry_id INTO l_entry_id;
      hr_utility.trace('GET_MAIN_ENTRY_VALUE: After get_main_entry_id, l_entry_id='||l_entry_id);
      IF get_main_entry_id%NOTFOUND THEN
         hr_utility.trace('GET_MAIN_ENTRY_VALUE: Input value not found on main entry, checking primary assignment.');
         OPEN chk_prim_entry_id;
         FETCH chk_prim_entry_id INTO l_entry_id;
         CLOSE chk_prim_entry_id;
         hr_utility.trace('GET_MAIN_ENTRY_VALUE: After chk_prim_entry_id, l_entry_id='||l_entry_id);
      END IF;
      CLOSE get_main_entry_id;
      --
      hr_utility.trace('GET_MAIN_ENTRY_VALUE: l_elntry_id='||l_entry_id);
      --
      OPEN get_value;
      FETCH get_value INTO l_value;
      CLOSE get_value;
      --
      hr_utility.trace('GET_MAIN_ENTRY_VALUE: l_value='||l_value);
   ELSE
      l_value := NULL;
   END IF;
   --
   hr_utility.trace('GET_MAIN_ENTRY_VALUE: Returning l_value='||l_value);
   RETURN l_value;
END get_main_entry_value;

FUNCTION get_main_initial_debt(p_assignment_id IN NUMBER) RETURN NUMBER IS
   l_value NUMBER;
   l_count NUMBER;
BEGIN
    hr_utility.trace('Entering GET_MAIN_INITIAL_DEBT: p_assignment_id='||p_assignment_id);
    --
    l_value := nvl(to_number(get_main_entry_value(p_assignment_id, 'Initial Debt', l_count)), 0);
    --
    hr_utility.trace('Leaving GET_MAIN_INITIAL_DEBT: l_value='||l_value);
    RETURN l_value;
END get_main_initial_debt;

FUNCTION get_main_fee(p_assignment_id IN NUMBER) RETURN NUMBER IS
   l_value  NUMBER;
   l_count NUMBER;
BEGIN
   hr_utility.trace('Entering GET_MAIN_FEE, p_assignment_id='||p_assignment_id);
   --
   l_value := nvl(to_number(get_main_entry_value(p_assignment_id, 'Fee', l_count)), 0);
   --
   hr_utility.trace('Leaving GET_MAIN_FEE: l_value='||l_value);
   RETURN l_value;
END get_main_fee;

FUNCTION check_ref(p_assignment_id IN NUMBER, p_reference IN VARCHAR2) RETURN VARCHAR2 IS
   l_main_ref  pay_element_entry_values_f.screen_entry_value%TYPE;
   l_count NUMBER;
BEGIN
   hr_utility.trace('Entering CHECK_REF, p_assignment_id='||p_assignment_id||
                                      ', p_reference='||p_reference);
   --
   l_main_ref := nvl(get_main_entry_value(p_assignment_id, 'Reference', l_count), 'Unknown');
   hr_utility.trace('CHECK_REF: Main ref='||l_main_ref||', l_count='||l_count);
   --
   IF nvl(l_count, 0) = 1 AND l_main_ref = p_reference THEN
      -- Valid reference
      RETURN 'Y';
   ELSE
      -- Invalid Reference
      RETURN 'N';
   END IF;
END check_ref;

/* Added for 9165203 bug. call to this function from
   GET_EAS_VALUE formula function. */
function get_eas_value (p_table_name        in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date)
         return number is

l_effective_date    date :=p_effective_date;

l_col_name varchar2(30);

l_value             number := 0;
l_fixed_amount      number := 0;
l_percent           number := 0;
l_limit             number := 0;
l_operator          varchar2(20);

cursor table_range_value(l_table_name        in varchar2,
                       l_row_value         in varchar2,
                       l_effective_date    in date) is
        select  /*+ INDEX(C PAY_USER_COLUMNS_FK1)
                    INDEX(R PAY_USER_ROWS_F_FK1)
                    INDEX(CINST PAY_USER_COLUMN_INSTANCES_N1)
                    ORDERED */
                CINST.value, C.user_column_name
        from    pay_user_tables                    TAB
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_column_instances_f        CINST
        where   TAB.user_table_name              = l_table_name
        and     TAB.legislation_code             = 'GB'
        and     C.user_table_id                  = TAB.user_table_id
        and     C.legislation_code                 = 'GB'
        and     C.user_column_name       in ('AMOUNT','PERCENT','PREV_BAND_LIMIT','OPERATOR')
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     l_effective_date           between R.effective_start_date
        and     R.effective_end_date
        and     R.legislation_code               = 'GB'
        and     fnd_number.canonical_to_number (l_row_value)
        between fnd_number.canonical_to_number (R.row_low_range_or_name)
        and     fnd_number.canonical_to_number (R.row_high_range)
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     l_effective_date           between CINST.effective_start_date
        and     CINST.effective_end_date
        and     CINST.legislation_code           = 'GB';

begin

for l_rec in table_range_value(p_table_name, p_row_value, l_effective_date)
loop
   if l_rec.user_column_name = 'AMOUNT' then
        l_fixed_amount := l_rec.value;
   elsif l_rec.user_column_name = 'PERCENT' then
        l_percent := l_rec.value;
   elsif l_rec.user_column_name = 'PREV_BAND_LIMIT' then
        l_limit := l_rec.value;
   elsif l_rec.user_column_name = 'OPERATOR' then
        l_operator := l_rec.value;
   end if;
end loop;

l_value := trunc(((l_percent * (p_row_value - l_limit))/100) + 0.0049, 2);

if l_operator = 'Addition' then
   l_value := l_fixed_amount + l_value;
else
   if l_fixed_amount > l_value then
      l_value := l_fixed_amount;
   end if;
end if;

return l_value;
end get_eas_value;

END pay_gb_eas_scotland_functions;

/
