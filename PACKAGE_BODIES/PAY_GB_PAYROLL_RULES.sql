--------------------------------------------------------
--  DDL for Package Body PAY_GB_PAYROLL_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_PAYROLL_RULES" AS
/* $Header: pygbprlr.pkb 120.7.12010000.2 2009/01/13 09:31:08 npannamp ship $ */

----------------------------------------------------------------------
-- Procedure: validate_update
-- Description: This is "Before Process" GB legislative hook call on
-- UPDATE_PAYROLL API to ensure a date track update or correction
-- would not lead to inconsistent PAYE Ref in a tax year
---------------------------------------------------------------------
PROCEDURE validate_update(p_effective_date IN DATE
                             ,p_datetrack_mode IN VARCHAR2
                             ,p_payroll_id IN NUMBER
                             ,p_payroll_name IN VARCHAR2
                             ,p_soft_coding_keyflex_id_in in NUMBER) IS
--
   l_cur_scl_id    NUMBER;
   l_next_scl_id   NUMBER;
   l_prev_scl_id   NUMBER;
   l_cur_eff_start DATE;
   l_cur_eff_end   DATE;
   l_first_eff_start DATE;
   l_last_eff_end    DATE;
   l_cur_paye_ref  hr_soft_coding_keyflex.segment1%TYPE;
   l_new_paye_ref  hr_soft_coding_keyflex.segment1%TYPE;
   l_next_paye_ref hr_soft_coding_keyflex.segment1%TYPE;
   l_prev_paye_ref hr_soft_coding_keyflex.segment1%TYPE;
   l_span_start    DATE;
   l_span_end      DATE;
   --
   CURSOR get_current_details IS
   SELECT soft_coding_keyflex_id, effective_start_date, effective_end_date
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id
   AND    p_effective_date BETWEEN effective_start_date and effective_end_date;
   --
   CURSOR get_next_details IS
   SELECT soft_coding_keyflex_id
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id
   AND    l_cur_eff_end+1 BETWEEN effective_start_date and effective_end_date;
   --
   CURSOR get_prev_details IS
   SELECT soft_coding_keyflex_id
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id
   AND    l_cur_eff_start-1 BETWEEN effective_start_date and effective_end_date;
   --
   CURSOR get_paye_ref(p_scl_id NUMBER) IS
   SELECT segment1
   FROM   hr_soft_coding_keyflex
   WHERE  soft_coding_keyflex_id = p_scl_id;
   --
   CURSOR get_min_max_dates IS
   SELECT min(effective_start_date) first_eff_start, max(effective_end_date)
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id;
   --
   l_found  NUMBER;
   /* Start Bug Fix 7343780 */
   l_assg_no  per_all_assignments_f.assignment_number%type;
   /* End Bug Fix 7343780 */
   --

   --
   -- to check whether any terminated asg found on the cur. payroll at effective(start) date
   --
   CURSOR csr_term_asg_exists(c_payroll_id number, c_effective_date date) is
   /* Start Bug Fix 7343780 */
   -- SELECT 1
   SELECT a.assignment_number
   /* End Bug Fix 7343780 */
   FROM   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.payroll_id = c_payroll_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('TERM_ASSIGN')
   and    c_effective_date between a.effective_start_date and a.effective_end_date;
   --

   --
   -- to check whether future payroll actions exists for the terminated assignments
   -- if found then no error, otherwise raise an error.
   --
   CURSOR csr_term_asg_future_act_exists(c_payroll_id number, c_effective_date date) is
   SELECT 1
   FROM   per_all_assignments_f a,
          per_assignment_status_types past,
          pay_assignment_actions act,
          pay_payroll_actions pact,
          per_time_periods ptp
   where  a.payroll_id = c_payroll_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('TERM_ASSIGN')
   and    c_effective_date between a.effective_start_date and a.effective_end_date
   and    pact.payroll_action_id = act.payroll_action_id
   and    pact.action_type in ('Q', 'R', 'B', 'I', 'V')
   and    act.assignment_id    = a.assignment_id
   and    pact.time_period_id  = ptp.time_period_id
   and    regular_payment_date >= c_effective_date;
   --

   l_proc VARCHAR2(100) := 'pay_gb_payroll_rules.validate_update';
BEGIN
   hr_utility.trace('Entering '||l_proc);
   hr_utility.trace('p_effective_date='||fnd_date.date_to_displaydate(p_effective_date));
   hr_utility.trace('p_datetrack_mode='||p_datetrack_mode);
   hr_utility.trace('p_payroll_id='||p_payroll_id);
   hr_utility.trace('p_payroll_name='||p_payroll_name);
   hr_utility.trace('p_soft_coding_keyflex_id_in='||p_soft_coding_keyflex_id_in);
   hr_utility.trace('Fetching PAYE Ref for new scl id='|| p_soft_coding_keyflex_id_in);
   OPEN get_paye_ref(p_soft_coding_keyflex_id_in);
   FETCH get_paye_ref INTO l_new_paye_ref;
   CLOSE get_paye_ref;
   --
   hr_utility.trace('New Paye Ref is '||l_new_paye_ref);
   --
   hr_utility.trace('Fetching current payroll details');
   OPEN get_current_details;
   FETCH get_current_details INTO l_cur_scl_id, l_cur_eff_start, l_cur_eff_end;
   CLOSE get_current_details;
   --
   hr_utility.trace('Currrent l_cur_scl_id='||l_cur_scl_id);
   hr_utility.trace('Currrent l_cur_eff_start='||fnd_date.date_to_displaydate(l_cur_eff_start));
   hr_utility.trace('Currrent l_cur_eff_end='||fnd_date.date_to_displaydate(l_cur_eff_end));
   --
   hr_utility.trace('Fetching Current PAYE Ref.');
   OPEN  get_paye_ref(l_cur_scl_id);
   FETCH get_paye_ref INTO l_cur_paye_ref;
   CLOSE get_paye_ref;
   hr_utility.trace('Current PAYE Ref is '||l_cur_paye_ref);
   --
   hr_utility.trace('Fetching fiest start date and last end date of the payroll');
   OPEN get_min_max_dates;
   FETCH get_min_max_dates INTO l_first_eff_start, l_last_eff_end;
   CLOSE get_min_max_dates;
   hr_utility.trace('l_first_eff_start='||fnd_date.date_to_displaydate(l_first_eff_start));
   hr_utility.trace('l_last_eff_end='||fnd_date.date_to_displaydate(l_last_eff_end));
   --
   IF p_datetrack_mode = hr_api.g_correction THEN
      hr_utility.trace('Datetrack Action is Correction.');
      --
      IF l_new_paye_ref <> l_cur_paye_ref THEN
         hr_utility.trace('PAYE Refs is changing, validating the change');
         --
         hr_utility.trace('Fetching Previous PAYE Ref');
         OPEN get_prev_details;
         FETCH get_prev_details INTO l_prev_scl_id;
         CLOSE get_prev_details;
         --
         hr_utility.trace('l_prev_scl_id = '||l_prev_scl_id);
         OPEN get_paye_ref(l_prev_scl_id);
         FETCH get_paye_ref INTO l_prev_paye_ref;
         CLOSE get_paye_ref;
         --
         hr_utility.trace('l_prev_paye_ref = '||l_prev_paye_ref);
         --
         IF l_prev_paye_ref <> l_new_paye_ref AND
            l_cur_eff_start <> l_first_eff_start AND
            to_char(l_cur_eff_start, 'DD-MM') <> '06-04' THEN
            hr_utility.trace('New PAYE Ref does not match the previous ');
            hr_utility.trace('PAYE Ref and current effective start date ');
            hr_utility.trace('is not the first effective start date and ');
            hr_utility.trace('current effective date is not start of a ');
            hr_utility.trace('tax year therefore raise an error message.');
            --
            l_span_start := hr_gbbal.span_start(l_cur_eff_start);
            l_span_end   := hr_gbbal.span_end(l_cur_eff_start);
            --
            fnd_message.set_name('PAY', 'HR_78126_INCONSISTENT_PAYE_REF');
            fnd_message.set_token('TAX_YEAR',
             substr(fnd_date.date_to_canonical(l_span_start), 1, 4)||'-'||
             substr(fnd_date.date_to_canonical(l_span_end), 1, 4));
            fnd_message.raise_error;
         END IF;
         --
         hr_utility.trace('Change as at the start date is ok, Checking end date');
         --
         hr_utility.trace('Fetching Next PAYE Ref');
         OPEN get_next_details;
         FETCH get_next_details INTO l_next_scl_id;
         CLOSE get_next_details;
         --
         hr_utility.trace('l_next_scl_id = '||l_next_scl_id);
         OPEN get_paye_ref(l_next_scl_id);
         FETCH get_paye_ref INTO l_next_paye_ref;
         CLOSE get_paye_ref;
         --
         hr_utility.trace('l_next_paye_ref = '||l_next_paye_ref);
         --
         IF l_next_paye_ref <> l_new_paye_ref AND
            l_cur_eff_end <> l_last_eff_end AND
            to_char(l_cur_eff_end, 'DD-MM') <> '05-04' THEN
            hr_utility.trace('New PAYE Ref does not match the next ');
            hr_utility.trace('PAYE Ref and current effective end date ');
            hr_utility.trace('is not the last effective end date and ');
            hr_utility.trace('current effective date is not end of a ');
            hr_utility.trace('tax year therefore raise an error message.');
            --
            l_span_start := hr_gbbal.span_start(l_cur_eff_end);
            l_span_end   := hr_gbbal.span_end(l_cur_eff_end);
            --
            fnd_message.set_name('PAY', 'HR_78126_INCONSISTENT_PAYE_REF');
            fnd_message.set_token('TAX_YEAR',
             substr(fnd_date.date_to_canonical(l_span_start), 1, 4)||'-'||
             substr(fnd_date.date_to_canonical(l_span_end), 1, 4));
            fnd_message.raise_error;
         END IF;
         --
         hr_utility.trace('Change as at the end date is ok too.');
         --

-- START CHECK - Termination Assignment exists at the Effective start date
         IF (l_prev_paye_ref <> l_new_paye_ref AND
             l_cur_eff_start <> l_first_eff_start) THEN

           open csr_term_asg_exists(p_payroll_id, l_cur_eff_start);
       	   /* Start Bug Fix 7343780 */
           -- fetch csr_term_asg_exists into l_found;
           fetch csr_term_asg_exists into l_assg_no;
           /* End Bug Fix 7343780 */
           if csr_term_asg_exists%found then
              open csr_term_asg_future_act_exists(p_payroll_id, l_cur_eff_start);
              fetch csr_term_asg_future_act_exists into l_found;
              if csr_term_asg_future_act_exists%notfound then
                 close csr_term_asg_exists;
                 close csr_term_asg_future_act_exists;
                 fnd_message.set_name('PAY', 'HR_GB_78131_TERM_ASSIGN_EXIST');
                 fnd_message.set_token('EFF_DATE', fnd_date.date_to_displaydate(l_cur_eff_start));
                 fnd_message.set_token('ASSG_NO', l_assg_no); --Bug Fix 7343780
                 fnd_message.raise_error;
              end if;
              close csr_term_asg_future_act_exists;
           end if;
           close csr_term_asg_exists;
         END IF;

         IF (l_next_paye_ref <> l_new_paye_ref AND
             l_cur_eff_end <> l_last_eff_end) THEN

           open csr_term_asg_exists(p_payroll_id, l_cur_eff_end+1);
           /* Start Bug Fix 7343780 */
           -- fetch csr_term_asg_exists into l_found;
           fetch csr_term_asg_exists into l_assg_no;
           /* End Bug Fix 7343780 */
           if csr_term_asg_exists%found then
              open csr_term_asg_future_act_exists(p_payroll_id, l_cur_eff_end+1);
              fetch csr_term_asg_future_act_exists into l_found;
              if csr_term_asg_future_act_exists%notfound then
                 close csr_term_asg_exists;
                 close csr_term_asg_future_act_exists;
                 fnd_message.set_name('PAY', 'HR_GB_78131_TERM_ASSIGN_EXIST');
                 fnd_message.set_token('EFF_DATE', fnd_date.date_to_displaydate(l_cur_eff_end+1));
                 fnd_message.set_token('ASSG_NO', l_assg_no); --Bug Fix 7343780
                 fnd_message.raise_error;
              end if;
              close csr_term_asg_future_act_exists;
           end if;
           close csr_term_asg_exists;
         END IF;

-- END CHECK - Termination Assignment exists at the Effective start date

      END IF; -- PAYE Ref Changing
   END IF; -- Date track mode is correction
   --
   IF p_datetrack_mode = hr_api.g_update
      OR  p_datetrack_mode = hr_api.g_update_override THEN
      hr_utility.trace('Datetrack Action is Update or Update Override.');
      --
      IF l_new_paye_ref <> l_cur_paye_ref THEN
         hr_utility.trace('PAYE Refs is changing, validating the change');
         --
         IF l_cur_paye_ref <> l_new_paye_ref AND
            p_effective_date <> l_first_eff_start AND
            to_char(p_effective_date, 'DD-MM') <> '06-04' THEN
            hr_utility.trace('New PAYE Ref does not match the current ');
            hr_utility.trace('PAYE Ref and new effective start date ');
            hr_utility.trace('is not the first effective start date and ');
            hr_utility.trace('new effective date is not start of a ');
            hr_utility.trace('tax year therefore raise an error message.');
            --
            l_span_start := hr_gbbal.span_start(p_effective_date);
            l_span_end   := hr_gbbal.span_end(p_effective_date);
            --
            fnd_message.set_name('PAY', 'HR_78126_INCONSISTENT_PAYE_REF');
            fnd_message.set_token('TAX_YEAR',
             substr(fnd_date.date_to_canonical(l_span_start), 1, 4)||'-'||
             substr(fnd_date.date_to_canonical(l_span_end), 1, 4));
            fnd_message.raise_error;
         END IF;
         --
         hr_utility.trace('Change as at the new effective date ok, no need to check as at the effective end date');
         --

-- START CHECK - Termination Assignment exists at the Effective start date
         IF l_cur_paye_ref <> l_new_paye_ref AND
            p_effective_date <> l_first_eff_start THEN

           open csr_term_asg_exists(p_payroll_id, p_effective_date);
           /* Start Bug Fix 7343780 */
           -- fetch csr_term_asg_exists into l_found;
           fetch csr_term_asg_exists into l_assg_no;
           /* End Bug Fix 7343780 */
           if csr_term_asg_exists%found then
              open csr_term_asg_future_act_exists(p_payroll_id, p_effective_date);
              fetch csr_term_asg_future_act_exists into l_found;
              if csr_term_asg_future_act_exists%notfound then
                 close csr_term_asg_exists;
                 close csr_term_asg_future_act_exists;
                 fnd_message.set_name('PAY', 'HR_GB_78131_TERM_ASSIGN_EXIST');
                 fnd_message.set_token('EFF_DATE', fnd_date.date_to_displaydate(p_effective_date));
                 fnd_message.set_token('ASSG_NO', l_assg_no); --Bug Fix 7343780
                 fnd_message.raise_error;
              end if;
              close csr_term_asg_future_act_exists;
           end if;
           close csr_term_asg_exists;

         END IF;
-- END CHECK - Termination Assignment exists at the Effective start date

      END IF; -- PAYE Ref Changing
   END IF; -- Date track update or update override
   --
   IF p_datetrack_mode = hr_api.g_update_change_insert THEN
      hr_utility.trace('Datetrack Action is Update Change Insert.');
      --
      IF l_new_paye_ref <> l_cur_paye_ref THEN
         hr_utility.trace('PAYE Refs is changing, validating the change');
         --
         IF l_cur_paye_ref <> l_new_paye_ref AND
            p_effective_date <> l_first_eff_start AND
            to_char(p_effective_date, 'DD-MM') <> '06-04' THEN
            hr_utility.trace('New PAYE Ref does not match the current ');
            hr_utility.trace('PAYE Ref and new effective start date ');
            hr_utility.trace('is not the first effective start date and ');
            hr_utility.trace('new effective date is not start of a ');
            hr_utility.trace('tax year therefore raise an error message.');
            --
            l_span_start := hr_gbbal.span_start(p_effective_date);
            l_span_end   := hr_gbbal.span_end(p_effective_date);
            --
            fnd_message.set_name('PAY', 'HR_78126_INCONSISTENT_PAYE_REF');
            fnd_message.set_token('TAX_YEAR',
             substr(fnd_date.date_to_canonical(l_span_start), 1, 4)||'-'||
             substr(fnd_date.date_to_canonical(l_span_end), 1, 4));
            fnd_message.raise_error;
         END IF;
         --
         hr_utility.trace('Change as at the new effective date ok, Checking as at the effective end date');
         --
         --
         hr_utility.trace('Fetching Next PAYE Ref');
         OPEN get_next_details;
         FETCH get_next_details INTO l_next_scl_id;
         CLOSE get_next_details;
         --
         hr_utility.trace('l_next_scl_id = '||l_next_scl_id);
         OPEN get_paye_ref(l_next_scl_id);
         FETCH get_paye_ref INTO l_next_paye_ref;
         CLOSE get_paye_ref;
         --
         hr_utility.trace('l_next_paye_ref = '||l_next_paye_ref);
         --
         IF l_next_paye_ref <> l_new_paye_ref AND
            l_cur_eff_end <> l_last_eff_end AND
            to_char(l_cur_eff_end, 'DD-MM') <> '05-04' THEN
            hr_utility.trace('New PAYE Ref does not match the next ');
            hr_utility.trace('PAYE Ref and current effective end date ');
            hr_utility.trace('is not the last effective end date and ');
            hr_utility.trace('current effective date is not end of a ');
            hr_utility.trace('tax year therefore raise an error message.');
            --
            l_span_start := hr_gbbal.span_start(l_cur_eff_end);
            l_span_end   := hr_gbbal.span_end(l_cur_eff_end);
            --
            fnd_message.set_name('PAY', 'HR_78126_INCONSISTENT_PAYE_REF');
            fnd_message.set_token('TAX_YEAR',
             substr(fnd_date.date_to_canonical(l_span_start), 1, 4)||'-'||
             substr(fnd_date.date_to_canonical(l_span_end), 1, 4));
            fnd_message.raise_error;
         END IF;
         --
         hr_utility.trace('Change as at the end date is ok too.');
         --

-- START CHECK - Termination Assignment exists at the Effective start date
         IF (l_cur_paye_ref <> l_new_paye_ref AND
             p_effective_date <> l_first_eff_start) THEN

           open csr_term_asg_exists(p_payroll_id, p_effective_date);
           /* Start Bug Fix 7343780 */
           -- fetch csr_term_asg_exists into l_found;
           fetch csr_term_asg_exists into l_assg_no;
           /* End Bug Fix 7343780 */
           if csr_term_asg_exists%found then
              open csr_term_asg_future_act_exists(p_payroll_id, p_effective_date);
              fetch csr_term_asg_future_act_exists into l_found;
              if csr_term_asg_future_act_exists%notfound then
                 close csr_term_asg_exists;
                 close csr_term_asg_future_act_exists;
                 fnd_message.set_name('PAY', 'HR_GB_78131_TERM_ASSIGN_EXIST');
                 fnd_message.set_token('EFF_DATE', fnd_date.date_to_displaydate(p_effective_date));
                 fnd_message.set_token('ASSG_NO', l_assg_no); --Bug Fix 7343780
                 fnd_message.raise_error;
              end if;
              close csr_term_asg_future_act_exists;
           end if;
           close csr_term_asg_exists;
         END IF;

         IF (l_next_paye_ref <> l_new_paye_ref AND
             l_cur_eff_end <> l_last_eff_end) THEN

           open csr_term_asg_exists(p_payroll_id, l_cur_eff_end+1);
           /* Start Bug Fix 7343780 */
           -- fetch csr_term_asg_exists into l_found;
           fetch csr_term_asg_exists into l_assg_no;
           /* End Bug Fix 7343780 */
           if csr_term_asg_exists%found then
              open csr_term_asg_future_act_exists(p_payroll_id, l_cur_eff_end+1);
              fetch csr_term_asg_future_act_exists into l_found;
              if csr_term_asg_future_act_exists%notfound then
                 close csr_term_asg_exists;
                 close csr_term_asg_future_act_exists;
                 fnd_message.set_name('PAY', 'HR_GB_78131_TERM_ASSIGN_EXIST');
                 fnd_message.set_token('EFF_DATE', fnd_date.date_to_displaydate(l_cur_eff_end+1));
                 fnd_message.set_token('ASSG_NO', l_assg_no); --Bug Fix 7343780
                 fnd_message.raise_error;
              end if;
              close csr_term_asg_future_act_exists;
           end if;
           close csr_term_asg_exists;
         END IF;
-- END CHECK - Termination Assignment exists at the Effective start date

      END IF; -- PAYE Ref Changing
   END IF; -- Date track update change insert
   --

   hr_utility.trace('No problem with this update/correction.');
   hr_utility.trace('Leaving pay_gb_payroll_rules.validate_update');
END validate_update;

PROCEDURE validate_delete(p_effective_date IN DATE
                          ,p_datetrack_mode IN VARCHAR2
                          ,p_payroll_id IN NUMBER) IS

   --
   l_cur_scl_id              NUMBER;
   l_next_to_next_scl_id     NUMBER;
   l_cur_eff_end             DATE;
   l_next_eff_end            DATE;
   l_first_eff_start         DATE;
   l_last_eff_end            DATE;
   l_cur_paye_ref            hr_soft_coding_keyflex.segment1%TYPE;
   l_next_to_next_paye_ref   hr_soft_coding_keyflex.segment1%TYPE;
   l_span_start              DATE;
   l_span_end                DATE;
   --
   CURSOR get_current_details IS
   SELECT soft_coding_keyflex_id, effective_end_date
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id
   AND    p_effective_date BETWEEN effective_start_date and effective_end_date;
   --
   CURSOR get_next_details IS
   SELECT effective_end_date
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id
   AND    l_cur_eff_end+1 BETWEEN effective_start_date and effective_end_date;
   --
   CURSOR get_next_to_next_details IS
   SELECT soft_coding_keyflex_id
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id
   AND    l_next_eff_end+1 BETWEEN effective_start_date and effective_end_date;
   --
   CURSOR get_paye_ref(p_scl_id NUMBER) IS
   SELECT segment1
   FROM   hr_soft_coding_keyflex
   WHERE  soft_coding_keyflex_id = p_scl_id;
   --
   CURSOR get_min_max_dates IS
   SELECT min(effective_start_date) first_eff_start, max(effective_end_date)
   FROM   pay_all_payrolls_f
   WHERE  payroll_id = p_payroll_id;
   --
   l_found           NUMBER;
   /* Start Bug Fix 7343780 */
   l_assg_no  per_all_assignments_f.assignment_number%type;
   /* End Bug Fix 7343780 */
   --

   --
   -- to check whether any terminated asg found on the cur. payroll at effective(start) date
   --
   CURSOR csr_term_asg_exists(c_payroll_id number, c_effective_date date) is
   /* Start Bug Fix 7343780 */
   -- SELECT 1
   SELECT a.assignment_number
   /* End Bug Fix 7343780 */
   FROM   per_all_assignments_f a,
          per_assignment_status_types past
   where  a.payroll_id = c_payroll_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('TERM_ASSIGN')
   and    c_effective_date between a.effective_start_date and a.effective_end_date;
   --

   --
   -- to check whether future payroll actions exists for the terminated assignments
   -- if found then no error, otherwise raise an error.
   --
   CURSOR csr_term_asg_future_act_exists(c_payroll_id number, c_effective_date date) is
   SELECT 1
   FROM   per_all_assignments_f a,
          per_assignment_status_types past,
          pay_assignment_actions act,
          pay_payroll_actions pact,
          per_time_periods ptp
   where  a.payroll_id = c_payroll_id
   and    a.assignment_status_type_id = past.assignment_status_type_id
   and    past.per_system_status IN ('TERM_ASSIGN')
   and    c_effective_date between a.effective_start_date and a.effective_end_date
   and    pact.payroll_action_id = act.payroll_action_id
   and    pact.action_type in ('Q', 'R', 'B', 'I', 'V')
   and    act.assignment_id    = a.assignment_id
   and    pact.time_period_id  = ptp.time_period_id
   and    regular_payment_date >= c_effective_date;
   --

   l_proc VARCHAR2(100) := 'pay_gb_payroll_rules.validate_delete';
BEGIN
   hr_utility.trace('Entering '||l_proc);
   hr_utility.trace('p_effective_date='||fnd_date.date_to_displaydate(p_effective_date));
   hr_utility.trace('p_datetrack_mode='||p_datetrack_mode);
   hr_utility.trace('p_payroll_id='||p_payroll_id);
   --
   hr_utility.trace('Fetching current payroll details');
   OPEN get_current_details;
   FETCH get_current_details INTO l_cur_scl_id, l_cur_eff_end;
   CLOSE get_current_details;
   --
   hr_utility.trace('Currrent l_cur_scl_id='||l_cur_scl_id);
   hr_utility.trace('Currrent l_cur_eff_end='||fnd_date.date_to_displaydate(l_cur_eff_end));
   --
   hr_utility.trace('Fetching Current PAYE Ref.');
   OPEN  get_paye_ref(l_cur_scl_id);
   FETCH get_paye_ref INTO l_cur_paye_ref;
   CLOSE get_paye_ref;
   hr_utility.trace('Current PAYE Ref is '||l_cur_paye_ref);
   --
   hr_utility.trace('Fetching fiest start date and last end date of the payroll');
   OPEN get_min_max_dates;
   FETCH get_min_max_dates INTO l_first_eff_start, l_last_eff_end;
   CLOSE get_min_max_dates;
   hr_utility.trace('l_first_eff_start='||fnd_date.date_to_displaydate(l_first_eff_start));
   hr_utility.trace('l_last_eff_end='||fnd_date.date_to_displaydate(l_last_eff_end));
   --
   IF p_datetrack_mode = hr_api.g_delete_next_change THEN
      hr_utility.trace('Datetrack Mode is Delete next change.');
      hr_utility.trace('Fetching end date of next instance.');
      OPEN  get_next_details;
      FETCH get_next_details INTO l_next_eff_end;
      CLOSE get_next_details;
      --
      hr_utility.trace('l_next_eff_date='||fnd_date.date_to_displaydate(l_next_eff_end));
      hr_utility.trace('Fetching PAYE Ref on  next to next instance.');
      OPEN  get_next_to_next_details;
      FETCH get_next_to_next_details INTO l_next_to_next_scl_id;
      CLOSE get_next_to_next_details;
      hr_utility.trace('l_next_to_next_scl_id='||l_next_to_next_scl_id);
      --
      OPEN  get_paye_ref(l_next_to_next_scl_id);
      FETCH get_paye_ref INTO l_next_to_next_paye_ref;
      CLOSE get_paye_ref;
      hr_utility.trace('l_next_to_next_paye_ref='||l_next_to_next_paye_ref);
      --
      IF l_next_to_next_paye_ref <> l_cur_paye_ref AND
         l_next_eff_end <> l_last_eff_end AND
         to_char(l_next_eff_end, 'DD-MM') <> '05-04' THEN
         --
         hr_utility.trace('Current PAYE Ref does not match the PAYE ');
         hr_utility.trace('Ref on next to next instance and next effective ');
         hr_utility.trace('end date is not the last effective end date and ');
         hr_utility.trace('next effective end date is not end of a ');
         hr_utility.trace('tax year therefore raise an error message.');
         --
         l_span_start := hr_gbbal.span_start(l_next_eff_end);
         l_span_end   := hr_gbbal.span_end(l_next_eff_end);
         --
         fnd_message.set_name('PAY', 'HR_78126_INCONSISTENT_PAYE_REF');
         fnd_message.set_token('TAX_YEAR',
          substr(fnd_date.date_to_canonical(l_span_start), 1, 4)||'-'||
          substr(fnd_date.date_to_canonical(l_span_end), 1, 4));
         fnd_message.raise_error;
      END IF;
      --

-- START CHECK - Termination Assignment exists at the Effective start date
      IF l_next_to_next_paye_ref <> l_cur_paye_ref AND
         l_next_eff_end <> l_last_eff_end THEN

         open csr_term_asg_exists(p_payroll_id, l_next_eff_end+1);
         /* Start Bug Fix 7343780 */
         -- fetch csr_term_asg_exists into l_found;
         fetch csr_term_asg_exists into l_assg_no;
         /* End Bug Fix 7343780 */
         if csr_term_asg_exists%found then
            open csr_term_asg_future_act_exists(p_payroll_id, l_next_eff_end+1);
            fetch csr_term_asg_future_act_exists into l_found;
            if csr_term_asg_future_act_exists%notfound then
               close csr_term_asg_exists;
               close csr_term_asg_future_act_exists;
               fnd_message.set_name('PAY', 'HR_GB_78131_TERM_ASSIGN_EXIST');
               fnd_message.set_token('EFF_DATE', fnd_date.date_to_displaydate(l_next_eff_end+1));
               fnd_message.set_token('ASSG_NO', l_assg_no); --Bug Fix 7343780
               fnd_message.raise_error;
            end if;
            close csr_term_asg_future_act_exists;
         end if;
         close csr_term_asg_exists;

      END IF;
-- END CHECK - Termination Assignment exists at the Effective start date

   END IF; -- Datetrack mode is Remove next change
   --
   hr_utility.trace('No problem with this delete.');
   hr_utility.trace('Leaving pay_gb_payroll_rules.validate_delete');
END validate_delete;

END;

/
