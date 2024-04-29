--------------------------------------------------------
--  DDL for Package Body PER_AU_ASG_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AU_ASG_LEG_HOOK" AS
/* $Header: peaulhas.pkb 120.2 2006/07/07 13:43:24 ksingla noship $ */

 PROCEDURE UPDATE_AU_ASG
 (p_assignment_id       IN   NUMBER
 ,p_effective_date      IN   DATE
 ,p_segment1            IN  VARCHAR2
 ) AS

  CURSOR c_check_actions
  (c_assignment_id per_all_assignments_f.assignment_id%TYPE
  ,c_effective_date  DATE
  ) IS
      SELECT 'Y'
      FROM  per_all_assignments_f paaf
      ,     pay_payroll_actions   ppa
      ,     pay_assignment_actions paa
      WHERE paaf.assignment_id     = c_assignment_id
      AND   paaf.assignment_id     = paa.assignment_id
      AND   paaf.business_group_id = ppa.business_group_id
      AND   ppa.payroll_action_id  = paa.payroll_action_id
      AND   ppa.effective_date    >=    (SELECT ptp.start_date
                      FROM per_time_periods ptp
                      WHERE ptp.payroll_id = ppa.payroll_id
                      AND c_effective_date BETWEEN ptp.start_date AND ptp.end_date)
      and  ppa.action_type IN ('Q','R','B','I','V');

  CURSOR c_tax_unit_id
  (c_assignment_id per_all_assignments_f.assignment_id%TYPE
  ,c_effective_date DATE
  ) IS
      SELECT hsc.segment1
      FROM   per_all_assignments_f a
      ,      hr_soft_coding_keyflex hsc
      WHERE  a.assignment_id             = c_assignment_id
      AND    hsc.soft_coding_keyflex_id  = a.soft_coding_keyflex_id
      AND    c_effective_date BETWEEN a.effective_start_date AND a.effective_end_date;
      g_debug               BOOLEAN;
      l_org_id              NUMBER;
      l_eff_start_date      DATE;
      l_eff_end_date        DATE;
      l_business_group_id   NUMBER;
      l_actions_exist       VARCHAR2(3);
      l_tax_unit_id         hr_soft_coding_keyflex.segment1%type;
BEGIN
      g_debug := hr_utility.debug_enabled;

      IF g_debug THEN
        hr_utility.set_location('Start of PER_AU_ASG_LEG_HOOK.UPDATE_AU_ASG',1);
      END if;

      OPEN c_tax_unit_id( p_assignment_id,p_effective_date);
      FETCH c_tax_unit_id into l_tax_unit_id;
      CLOSE c_tax_unit_id;

 IF p_segment1 <> hr_api.g_varchar2 THEN  /* Added for bug 5375920*/
      IF p_segment1 <> l_tax_unit_id THEN
         OPEN c_check_actions(p_assignment_id, p_effective_date);
         FETCH c_check_actions into l_actions_exist;
         CLOSE c_check_actions;

          IF l_actions_exist  = 'Y' THEN
            hr_utility.set_message(801, 'HR_AU_LE_CHANGE_VAL');
            hr_utility.raise_error;
          END IF;
       End if;
   END IF;

       IF g_debug THEN
         hr_utility.set_location('End of PER_AU_ASG_LEG_HOOK.UPDATE_AU_ASG',2);
       END if;
EXCEPTION
  WHEN OTHERS THEN
    IF g_debug THEN
      hr_utility.set_location('Error in PER_AU_ASG_LEG_HOOK.UPDATE_AU_ASG',100);
    END IF;
    RAISE;


END UPDATE_AU_ASG ;

END PER_AU_ASG_LEG_HOOK;

/
