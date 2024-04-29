--------------------------------------------------------
--  DDL for Package Body PAY_ES_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_RULES" AS
/* $Header: pyesrule.pkb 120.3 2005/07/05 05:30:45 grchandr noship $ */
--
-------------------------------------------------------------------------------
-- get_main_tax_unit_id
-------------------------------------------------------------------------------
PROCEDURE get_main_tax_unit_id(p_assignment_id   IN     NUMBER
                              ,p_effective_date  IN     DATE
                              ,p_tax_unit_id     IN OUT NOCOPY NUMBER) IS
    --
    CURSOR csr_get_wc_details IS
    SELECT scl.segment2                 work_center
    FROM   per_all_assignments_f        paaf
          ,hr_soft_coding_keyflex       scl
    WHERE  paaf.assignment_id           = p_assignment_id
    AND    paaf.soft_coding_keyflex_id  = scl.soft_coding_keyflex_id
    AND    p_effective_date             BETWEEN effective_start_date
                                        AND     effective_end_date;
    --
    CURSOR csr_get_le_details (p_wc_organization_id NUMBER) IS
    SELECT hoi.organization_id          le_id
    FROM   hr_organization_information  hoi
    WHERE  hoi.org_information1         = p_wc_organization_id
    AND    hoi.org_information_context  = 'ES_WORK_CENTER_REF';
    --
    l_wc_id hr_all_organization_units.organization_id%TYPE;
    --
BEGIN
    --
    p_tax_unit_id := NULL;
    l_wc_id       := NULL;
    --
    OPEN  csr_get_wc_details;
    FETCH csr_get_wc_details INTO l_wc_id;
    CLOSE csr_get_wc_details;
    --
    IF  l_wc_id IS NOT NULL THEN
        OPEN  csr_get_le_details(l_wc_id);
        FETCH csr_get_le_details INTO p_tax_unit_id;
        CLOSE csr_get_le_details;
    END IF;
    --
 END get_main_tax_unit_id;
-------------------------------------------------------------------------------
-- get_source_text_context
-------------------------------------------------------------------------------
PROCEDURE get_source_text_context(p_asg_act_id  NUMBER
                                 ,p_ee_id       NUMBER
                                 ,p_source_text IN OUT NOCOPY VARCHAR2) IS
    --
    CURSOR csr_get_payment_key(p_assignment_action_id NUMBER) IS
    SELECT eev.screen_entry_value payment_key
    FROM   pay_element_entries_f pee
          ,pay_element_entry_values_f eev
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,pay_assignment_actions paa
          ,pay_payroll_actions    ppa
    WHERE  paa.assignment_action_id = p_assignment_action_id
    AND    ppa.payroll_action_id    = paa.payroll_action_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'Payment Key'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
    AND    pee.assignment_id        = paa.assignment_id
    AND    pet.element_name         = 'Tax Details'
    AND    pet.legislation_code     = 'ES'
    AND    ppa.effective_date       BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date
    AND    ppa.effective_date       BETWEEN eev.effective_start_date
                                    AND     eev.effective_end_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date;
    --
    l_payment_key VARCHAR2(1);
BEGIN
    --
    l_payment_key := 'X';
    --
    hr_utility.set_location('pay_es_rules.get_source_text_context',1);
    --
    OPEN  csr_get_payment_key(p_asg_act_id);
    FETCH csr_get_payment_key INTO l_payment_key;
    CLOSE csr_get_payment_key;
    --
    p_source_text := NVL(l_payment_key,' ');
    --
    hr_utility.set_location('pay_es_rules.get_source_text_context='|| p_source_text,2);
    --
END get_source_text_context;
-------------------------------------------------------------------------------
-- get_source_text_context
-------------------------------------------------------------------------------
PROCEDURE get_source_text2_context(p_asg_act_id   NUMBER
                                  ,p_ee_id        NUMBER
                                  ,p_source_text2 IN OUT NOCOPY VARCHAR2) IS
BEGIN
    --
    p_source_text2 := '0';
    --
END get_source_text2_context;
-------------------------------------------------------------------------------
-- get_source_number_context
-------------------------------------------------------------------------------
PROCEDURE get_source_number_context(p_asg_act_id    NUMBER
                                   ,p_ee_id         NUMBER
                                   ,p_source_number IN OUT NOCOPY VARCHAR2) IS
    --
    CURSOR csr_get_epigraph_code(p_assignment_action_id NUMBER) IS
    SELECT eev.screen_entry_value epigraph_code
    FROM   pay_element_entries_f pee
          ,pay_element_entry_values_f eev
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,pay_assignment_actions paa
          ,pay_payroll_actions    ppa
          ,per_time_periods       ptp
    WHERE  paa.assignment_action_id = p_assignment_action_id
    AND    ppa.payroll_action_id    = paa.payroll_action_id
    AND    ppa.payroll_id           = ptp.payroll_id
    AND    ppa.time_period_id       = ptp.time_period_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'SS Epigraph Code'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
    AND    pee.assignment_id        = paa.assignment_id
    AND    pet.element_name         = 'Social Security Details'
    AND    pet.legislation_code     = 'ES'
    AND    pee.effective_end_date   = eev.effective_end_date
    AND    eev.effective_end_date   >= ptp.start_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
    ORDER BY eev.effective_start_date;
    --
BEGIN
    --
    p_source_number := '0';
    OPEN  csr_get_epigraph_code(p_asg_act_id);
    FETCH csr_get_epigraph_code INTO p_source_number;
    CLOSE csr_get_epigraph_code;
    --p_source_number := '110';
    --
END get_source_number_context;
-------------------------------------------------------------------------------
-- get_source_number2_context
-------------------------------------------------------------------------------
PROCEDURE get_source_number2_context(p_asg_act_id     NUMBER
                                    ,p_ee_id          NUMBER
                                    ,p_source_number2 IN OUT NOCOPY VARCHAR2) IS
    --
    CURSOR csr_get_cac(p_assignment_action_id NUMBER) IS
    SELECT eev.screen_entry_value sec_cac
    FROM   pay_element_entries_f pee
          ,pay_element_entry_values_f eev
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,pay_assignment_actions paa
          ,pay_payroll_actions    ppa
          ,per_time_periods       ptp
    WHERE  paa.assignment_action_id = p_assignment_action_id
    AND    ppa.payroll_action_id    = paa.payroll_action_id
    AND    ppa.payroll_id           = ptp.payroll_id
    AND    ppa.time_period_id       = ptp.time_period_id
    AND    pee.element_entry_id     = eev.element_entry_id
    AND    eev.input_value_id + 0   = piv.input_value_id
    AND    piv.name                 = 'Work Center CAC'
    AND    piv.element_type_id      = pet.element_type_id
    AND    ppa.effective_date       BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
    AND    pee.assignment_id        = paa.assignment_id
    AND    pet.element_name         = 'Multiple Employment Details'
    AND    pet.legislation_code     = 'ES'
    AND    pee.effective_end_date   = eev.effective_end_date
    AND    eev.effective_end_date   >= ptp.start_date
    AND    ppa.effective_date       BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
    ORDER BY eev.effective_start_date;
    --
BEGIN
    --
    p_source_number2 := '0';
    OPEN  csr_get_cac(p_asg_act_id);
    FETCH csr_get_cac INTO p_source_number2;
    CLOSE csr_get_cac;
    --
END get_source_number2_context;

END pay_es_rules;

/
