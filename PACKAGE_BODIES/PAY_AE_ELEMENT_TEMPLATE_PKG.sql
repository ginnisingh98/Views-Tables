--------------------------------------------------------
--  DDL for Package Body PAY_AE_ELEMENT_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AE_ELEMENT_TEMPLATE_PKG" AS
/* $Header: pyaeeltm.pkb 120.19 2006/03/23 02:09:44 abppradh noship $ */
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Function get_rate_from_tab_id
  -- This function is used to obtain rate value from rate table id.
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  FUNCTION get_rate_from_tab_id
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_business_group_id IN NUMBER
    ,p_rate_id           IN NUMBER)
  RETURN NUMBER AS
    CURSOR csr_get_grade IS
    SELECT grade_id
    FROM   per_all_assignments_f
    WHERE  assignment_id = p_assignment_id
    AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;
    l_grade_id    NUMBER;

    CURSOR csr_get_grade_value IS
    SELECT pg.value
    FROM   pay_rates pr
           ,pay_grade_rules_f pg
    WHERE  pr.rate_type= 'G'
    AND    pr.rate_id = p_rate_id
    AND    pr.rate_id = pg.rate_id
    AND    pg.grade_or_spinal_point_id = l_grade_id
    AND    pg.rate_type = 'G'
    AND    pg.business_group_id = p_business_group_id
    AND    pr.business_group_id = p_business_group_id
    AND    p_date_earned BETWEEN pg.effective_start_date AND pg.effective_end_date;
    l_value       NUMBER;

  BEGIN
    l_value := 0;
    OPEN csr_get_grade;
    FETCH csr_get_grade INTO l_grade_id;
    CLOSE csr_get_grade;

    OPEN csr_get_grade_value;
    FETCH csr_get_grade_value INTO l_value;
    CLOSE csr_get_grade_value;

    RETURN l_value;

  END get_rate_from_tab_id;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Function get_rate_from_tab_name
  -- This function is used to obtain rate value from rate table name.
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  FUNCTION get_rate_from_tab_name
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_business_group_id IN NUMBER
    ,p_rate_table        IN VARCHAR2
    ,p_table_exists     OUT NOCOPY VARCHAR2)
  RETURN NUMBER AS
    CURSOR csr_get_grade IS
    SELECT grade_id
    FROM   per_all_assignments_f
    WHERE  assignment_id = p_assignment_id
    AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;
    l_grade_id    NUMBER;

    CURSOR csr_chk_grade_table IS
    SELECT 'Y'
    FROM    pay_rates pr
    WHERE  pr.rate_type = 'G'
    AND       pr.name =p_rate_table
    AND       pr.business_group_id = p_business_group_id;


    CURSOR csr_get_grade_value IS
    SELECT pg.value
    FROM   pay_rates pr
           ,pay_grade_rules_f pg
    WHERE  pr.rate_type= 'G'
    AND    pr.name = p_rate_table
    AND    pr.rate_id = pg.rate_id
    AND    pg.grade_or_spinal_point_id = l_grade_id
    AND    pg.rate_type = 'G'
    AND    pg.business_group_id = p_business_group_id
    AND    pr.business_group_id = p_business_group_id
    AND    p_date_earned BETWEEN pg.effective_start_date AND pg.effective_end_date;
    l_value       NUMBER;
    l_exist        VARCHAR2(10);

  BEGIN
    l_grade_id := NULL;
    l_value := 0;
    l_exist := 'N';
    OPEN csr_chk_grade_table;
    FETCH csr_chk_grade_table INTO l_exist;
    CLOSE csr_chk_grade_table;

    IF l_exist ='Y' THEN
      p_table_exists := 'Y';
    ELSE
      p_table_exists := 'N';
    END IF;

    OPEN csr_get_grade;
    FETCH csr_get_grade INTO l_grade_id;
    CLOSE csr_get_grade;

    IF l_grade_id IS NULL THEN
      --p_table_exists := 'N';
      l_value := 0;
    END IF;

    OPEN csr_get_grade_value;
    FETCH csr_get_grade_value INTO l_value;
    CLOSE csr_get_grade_value;

    RETURN l_value;

  END get_rate_from_tab_name;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Function get_absence_days
  -- This function is used to obtain the number of unpaid leaves in a
  -- payroll period (used in element template for Unpaid Leave Deduction)
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  FUNCTION get_absence_days
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_business_group_id IN NUMBER
    ,p_start_date        IN DATE
    ,p_end_date          IN DATE)
  RETURN NUMBER AS

    CURSOR csr_get_day_range IS
    SELECT paa.date_start start_date
           ,paa.date_end end_date
    FROM   per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_assignments_f asg
    WHERE  paat.absence_category ='UL'
    AND    paat.business_group_id = paa.business_group_id
    AND    paat.business_group_id = p_business_group_id
    AND    paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND    paa.person_id = asg.person_id
    AND    asg.assignment_id = p_assignment_id
    AND    (paa.date_start between p_start_date AND p_end_date
           AND paa.date_end between p_start_date AND p_end_date)
    UNION
    SELECT paa.date_start start_date
           ,p_end_date end_date
    FROM   per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_assignments_f asg
    WHERE  paat.absence_category ='UL'
    AND    paat.business_group_id = paa.business_group_id
    AND    paat.business_group_id = p_business_group_id
    AND    paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND    paa.person_id = asg.person_id
    AND    asg.assignment_id = p_assignment_id
    AND    (paa.date_start between p_start_date AND p_end_date
           AND paa.date_end > p_end_date)
    UNION
    SELECT p_start_date start_date
           ,paa.date_end end_date
    FROM   per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_assignments_f asg
    WHERE  paat.absence_category ='UL'
    AND    paat.business_group_id = paa.business_group_id
    AND    paat.business_group_id = p_business_group_id
    AND    paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND    paa.person_id = asg.person_id
    AND    asg.assignment_id = p_assignment_id
    AND    (paa.date_start < p_start_date
           AND paa.date_end between p_start_date AND p_end_date)
    UNION
    SELECT p_start_date start_date
           ,p_end_date end_date
    FROM   per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_assignments_f asg
    WHERE  paat.absence_category ='UL'
    AND    paat.business_group_id = paa.business_group_id
    AND    paat.business_group_id = p_business_group_id
    AND    paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND    paa.person_id = asg.person_id
    AND    asg.assignment_id = p_assignment_id
    AND    (paa.date_start < p_start_date
           AND paa.date_end > p_end_date);
    rec_get_day_range    csr_get_day_range%ROWTYPE;
    l_days               NUMBER;
    l_tot_days           NUMBER;
    l_f_stat             NUMBER;

  BEGIN
    l_days := 0;
    l_tot_days := 0;
    l_f_stat := 0;
    OPEN csr_get_day_range;
    LOOP
      FETCH csr_get_day_range INTO rec_get_day_range;
      EXIT WHEN csr_get_day_range%NOTFOUND;
      l_f_stat := hr_loc_work_schedule.calc_sch_based_dur
                  (p_assignment_id
                  ,'D'
                  ,'Y'
                  ,rec_get_day_range.start_date
                  ,rec_get_day_range.end_date
                  ,'0'
                  ,'23.59'
                  ,l_days);
      l_tot_days := l_tot_days + l_days;
    END LOOP;
    CLOSE csr_get_day_range;

    RETURN NVL(l_tot_days, 0);

  EXCEPTION
    WHEN OTHERS THEN
      l_tot_days := 0;
      RETURN l_tot_days;

  END get_absence_days;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Function get_employee_details
  -- This function is used to obtain the employee details.
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  FUNCTION get_employee_details
    (p_assignment_id     IN NUMBER
    ,p_date_earned       IN DATE
    ,p_info_type         IN VARCHAR2)
  RETURN VARCHAR2 AS
    CURSOR csr_get_marital_status IS
    SELECT marital_status
    FROM   per_all_people_f ppl
           ,per_all_assignments_f asg
    WHERE  asg.assignment_id = p_assignment_id
    AND    ppl.person_id = asg.person_id
    AND    p_date_earned BETWEEN asg.effective_start_date AND asg.effective_end_date
    AND    p_date_earned BETWEEN ppl.effective_start_date AND ppl.effective_end_date;

    CURSOR csr_get_dependent_children IS
    SELECT COUNT(DISTINCT contact_person_id)
    FROM   per_contact_relationships pcr
           ,per_all_assignments_f asg
    WHERE  asg.person_id = pcr.person_id
    AND    asg.assignment_id = p_assignment_id
    AND    pcr.contact_type = 'C'
    AND    nvl(pcr.dependent_flag, 'N') = 'Y'
    AND    p_date_earned BETWEEN NVL(pcr.date_start,p_date_earned) AND NVL(pcr.date_end, TO_DATE('4712/12/31','YYYY/MM/DD'));

    l_marital_status   VARCHAR2(80);
    l_value            VARCHAR2(100);
    l_child_cnt        NUMBER;

  BEGIN
    IF p_info_type = 'MARITAL_STATUS' THEN
      l_marital_status := NULL;
      OPEN csr_get_marital_status;
      FETCH csr_get_marital_status INTO l_marital_status;
      CLOSE csr_get_marital_status;

      l_value := l_marital_status;
      IF l_value IS NULL THEN
        l_value := 'NO_DATA_FOUND';
      END IF;
    ELSIF p_info_type = 'DEPENDENT_CHILDREN' THEN
      l_child_cnt := 0;
      OPEN csr_get_dependent_children;
      FETCH csr_get_dependent_children INTO l_child_cnt;
      CLOSE csr_get_dependent_children;

      l_value := l_child_cnt;
    END IF;
    RETURN l_value;

  END get_employee_details;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Function element_template_post_process
  -- This function is used to update input value with value set for hourly
  -- salary and grade allowance template .
  -- The function also creates balance feeds for information element of
  -- Housing and Transport allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE element_template_post_process
    (p_template_id       IN NUMBER) AS

    CURSOR csr_get_template_info IS
    SELECT base_name
           ,business_group_id
           ,template_name
    FROM   pay_element_templates
    WHERE  template_id   = p_template_id
    AND    template_type = 'U';
    rec_get_template_info     csr_get_template_info%ROWTYPE;

    CURSOR csr_get_element_type_id
     (cp_business_group_id NUMBER
     ,cp_element_name      VARCHAR2) IS
    SELECT element_type_id
    FROM   pay_element_types_f
    WHERE  business_group_id = cp_business_group_id
    AND    element_name      = cp_element_name;

    CURSOR csr_get_input_value_id (cp_name            VARCHAR2
                                  ,cp_element_type_id NUMBER) IS
    SELECT input_value_id
           ,effective_start_date
    FROM   pay_input_values_f
    WHERE  element_type_id = cp_element_type_id
    AND    name = cp_name;
    rec_get_input_value_id    csr_get_input_value_id%ROWTYPE;

    CURSOR csr_get_value_set_id IS
    SELECT flex_value_set_id
    FROM   fnd_flex_value_sets
    WHERE  flex_value_set_name = 'HR_AE_RATE_NAME';

    CURSOR csr_get_valid_element_type_id
     (cp_business_group_id NUMBER
     ,cp_element_name      VARCHAR2) IS
    SELECT pet.element_type_id
    FROM   pay_element_types_f pet
           ,pay_sub_classification_rules_f psc
           ,pay_element_classifications pec
    WHERE  pet.business_group_id = cp_business_group_id
    AND    pet.element_name      = cp_element_name
    AND    pet.element_type_id = psc.element_type_id
    AND    pet.business_group_id = psc.business_group_id
    AND    pec.classification_name = 'Subject to Social Insurance : Earnings'
    AND    pec.legislation_code = 'AE'
    AND    psc.classification_id = pec.classification_id;

    CURSOR csr_get_info_element_det
     (cp_business_group_id NUMBER
     ,cp_element_name      VARCHAR2) IS
    SELECT element_type_id
           ,effective_start_date
           ,effective_end_date
    FROM   pay_element_types_f
    WHERE  business_group_id = cp_business_group_id
    AND    element_name      = cp_element_name;
    rec_get_info_element_det  csr_get_info_element_det%ROWTYPE;

    CURSOR csr_get_classification_id IS
    SELECT classification_id
    FROM   pay_element_classifications pec
    WHERE  classification_name  = 'Subject to Social Insurance : Information'
    AND    legislation_code = 'AE';

    l_base_name                pay_element_types_f.element_name%TYPE;
    l_business_group_id        NUMBER;
    l_element_type_id          NUMBER;
    l_info_element_type_id     NUMBER;
    l_classification_id        NUMBER;
    l_input_value_id           NUMBER;
    l_template_name            pay_element_templates.template_name%TYPE;
    l_value_set_id             NUMBER;
    l_ov_number                NUMBER;
    l_effective_date           DATE;
    l_effective_start_date     DATE;
    l_effective_end_date       DATE;
    l_el_effective_start_date  DATE;
    l_el_effective_end_date    DATE;
    l_default_warning          BOOLEAN;
    l_min_max_warning          BOOLEAN;
    l_link_inp_val_warning     BOOLEAN;
    l_pay_basis_warning        BOOLEAN;
    l_formula_warning          BOOLEAN;
    l_assignment_id_warning    BOOLEAN;
    l_formula_message          VARCHAR2(100);

  BEGIN
    hr_utility.trace('Entering pay_ae_element_template_pkg.element_template_post_process');

    OPEN  csr_get_template_info;
    FETCH csr_get_template_info INTO rec_get_template_info;
    l_base_name := rec_get_template_info.base_name;
    l_business_group_id := rec_get_template_info.business_group_id;
    l_template_name := rec_get_template_info.template_name;
    CLOSE csr_get_template_info;

    IF l_template_name IN ('Hourly Salary Template', 'Grade Allowance Template') THEN
      OPEN  csr_get_element_type_id (l_business_group_id
                                    ,l_base_name);
      FETCH csr_get_element_type_id INTO l_element_type_id;
      CLOSE csr_get_element_type_id;

      OPEN csr_get_input_value_id('Grade Rate',l_element_type_id);
      FETCH csr_get_input_value_id INTO rec_get_input_value_id;
      l_input_value_id := rec_get_input_value_id.input_value_id;
      l_effective_date := rec_get_input_value_id.effective_start_date;
      CLOSE csr_get_input_value_id;

      OPEN csr_get_value_set_id;
      FETCH csr_get_value_set_id INTO l_value_set_id;
      CLOSE csr_get_value_set_id;

      IF l_value_set_id is NOT NULL THEN
        DECLARE
          CURSOR csr_get_ovn IS
          SELECT object_version_number
          FROM   pay_input_values_f
          WHERE  input_value_id = l_input_value_id;
        BEGIN
          OPEN csr_get_ovn;
          FETCH csr_get_ovn INTO l_ov_number;
          CLOSE csr_get_ovn;
        END;

        pay_input_value_api.update_input_value
          (p_validate                => FALSE
          ,p_effective_date          => l_effective_date
          ,p_datetrack_mode          => 'CORRECTION'
          ,p_input_value_id          => l_input_value_id
          ,p_object_version_number   => l_ov_number
          ,p_value_set_id            => l_value_set_id
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_default_val_warning     => l_default_warning
          ,p_min_max_warning         => l_min_max_warning
          ,p_link_inp_val_warning    => l_link_inp_val_warning
          ,p_pay_basis_warning       => l_pay_basis_warning
          ,p_formula_warning         => l_formula_warning
          ,p_assignment_id_warning   => l_assignment_id_warning
          ,p_formula_message         => l_formula_message
          );
      END IF;
    END IF;

    /*Code for updating balance feed of secondary information element*/
    IF l_template_name IN ('Housing Allowance Template') THEN
      OPEN  csr_get_valid_element_type_id (l_business_group_id
                                    ,l_base_name);
      FETCH csr_get_valid_element_type_id INTO l_element_type_id;
      CLOSE csr_get_valid_element_type_id;

      IF l_element_type_id IS NOT NULL THEN
        OPEN  csr_get_info_element_det (l_business_group_id
                                      ,l_base_name||' Information');
        FETCH csr_get_info_element_det INTO rec_get_info_element_det;
        l_info_element_type_id := rec_get_info_element_det.element_type_id;
        l_el_effective_start_date := rec_get_info_element_det.effective_start_date;
        l_el_effective_end_date := rec_get_info_element_det.effective_end_date;
        CLOSE csr_get_info_element_det;

        OPEN csr_get_classification_id;
        FETCH csr_get_classification_id INTO l_classification_id;
        CLOSE csr_get_classification_id;

        IF l_info_element_type_id IS NOT NULL and l_classification_id IS NOT NULL THEN
          DECLARE
            l_row_id  VARCHAR2(30);
            l_seq     NUMBER;
          BEGIN
            l_row_id := NULL;
            SELECT pay_sub_classification_rules_s.nextval
            INTO   l_seq
            FROM   dual;
            pay_sub_class_rules_pkg.insert_row
              ( p_rowid                     => l_row_id
              ,p_sub_classification_rule_Id => l_seq
              ,p_effective_start_date       => l_el_effective_start_date
              ,p_effective_end_date         => l_el_effective_end_date
              ,p_element_type_id            => l_info_element_type_id
              ,p_classification_id          => l_classification_id
              ,p_business_group_id          => l_business_group_id
              ,p_legislation_code           => NULL
              ,p_last_update_date           => SYSDATE
              ,p_last_updated_by            => -1
              ,p_last_update_login          => -1
              ,p_created_by                 => -1
              ,p_creation_date              => SYSDATE);
          END;
        END IF;
      END IF;
    END IF;

    --Update the input value for Housing, Transport and Shift allowance template
    IF l_template_name IN ('Housing Allowance Template', 'Transport Allowance Template','Shift Allowance Template') THEN
      OPEN  csr_get_element_type_id (l_business_group_id,l_base_name);
      FETCH csr_get_element_type_id INTO l_element_type_id;
      CLOSE csr_get_element_type_id;

      OPEN csr_get_input_value_id('Override Amount',l_element_type_id);
      FETCH csr_get_input_value_id INTO rec_get_input_value_id;
      l_input_value_id := rec_get_input_value_id.input_value_id;
      l_effective_date := rec_get_input_value_id.effective_start_date;
      CLOSE csr_get_input_value_id;

        DECLARE
          CURSOR csr_get_ovn IS
          SELECT object_version_number
          FROM   pay_input_values_f
          WHERE  input_value_id = l_input_value_id;
        BEGIN
          OPEN csr_get_ovn;
          FETCH csr_get_ovn INTO l_ov_number;
          CLOSE csr_get_ovn;
        END;

        pay_input_value_api.update_input_value
          (p_validate                => FALSE
          ,p_effective_date          => l_effective_date
          ,p_datetrack_mode          => 'CORRECTION'
          ,p_input_value_id          => l_input_value_id
          ,p_object_version_number   => l_ov_number
         -- ,p_max_value                        => '0'
          ,p_min_value                        => '0'
          ,p_warning_or_error        => 'E'
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_default_val_warning     => l_default_warning
          ,p_min_max_warning         => l_min_max_warning
          ,p_link_inp_val_warning    => l_link_inp_val_warning
          ,p_pay_basis_warning       => l_pay_basis_warning
          ,p_formula_warning         => l_formula_warning
          ,p_assignment_id_warning   => l_assignment_id_warning
          ,p_formula_message         => l_formula_message
          );

    END IF;

    --Update the input value for unpaid leave template
    IF l_template_name IN ('Unpaid Leave Template') THEN
      OPEN  csr_get_element_type_id (l_business_group_id
                                    ,l_base_name||' Arrears Payment');
      FETCH csr_get_element_type_id INTO l_element_type_id;
      CLOSE csr_get_element_type_id;

      OPEN csr_get_input_value_id('Pay Value',l_element_type_id);
      FETCH csr_get_input_value_id INTO rec_get_input_value_id;
      l_input_value_id := rec_get_input_value_id.input_value_id;
      l_effective_date := rec_get_input_value_id.effective_start_date;
      CLOSE csr_get_input_value_id;

        DECLARE
          CURSOR csr_get_ovn IS
          SELECT object_version_number
          FROM   pay_input_values_f
          WHERE  input_value_id = l_input_value_id;
        BEGIN
          OPEN csr_get_ovn;
          FETCH csr_get_ovn INTO l_ov_number;
          CLOSE csr_get_ovn;
        END;

        pay_input_value_api.update_input_value
          (p_validate                => FALSE
          ,p_effective_date          => l_effective_date
          ,p_datetrack_mode          => 'CORRECTION'
          ,p_input_value_id          => l_input_value_id
          ,p_object_version_number   => l_ov_number
          ,p_max_value                        => '0'
          ,p_warning_or_error        => 'E'
          ,p_effective_start_date    => l_effective_start_date
          ,p_effective_end_date      => l_effective_end_date
          ,p_default_val_warning     => l_default_warning
          ,p_min_max_warning         => l_min_max_warning
          ,p_link_inp_val_warning    => l_link_inp_val_warning
          ,p_pay_basis_warning       => l_pay_basis_warning
          ,p_formula_warning         => l_formula_warning
          ,p_assignment_id_warning   => l_assignment_id_warning
          ,p_formula_message         => l_formula_message
          );

    END IF;


    hr_utility.trace('Leaving pay_ae_element_template_pkg.element_template_post_process');

  END element_template_post_process;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_flat_amt_template
  -- This proceudre is used to create a flat amount template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_flat_amt_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_flat_element_id         number;
    l_flat_pay_iv             number;
    l_flat_amt_iv             number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Flat Amount Template'
    AND  template_type = 'T';
  --
  BEGIN
  ----------------------------------------------------------------------------
  -- Delete the existing template
  ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
  --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Flat Amount Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --No exclusion rules

      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_FLAT_FF'
       ,p_description               	=> 'AE Formula for flat amount'
       ,p_formula_text              	=>
'
/*  Description: Formula for Flat amount template in UAE legislation
*/
Inputs are Allowance_Amount
l_amount = Allowance_Amount
RETURN l_amount


/*======================== End Program =======================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --


      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_flat_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_flat_pay_iv
       ,p_element_type_id              	=> l_flat_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_flat_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_flat_amt_iv
       ,p_element_type_id              	=> l_flat_element_id
       --,p_exclusion_rule_id             => l_excl_rule_id_perc
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Allowance Amount'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_flat_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_flat_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );
      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

     BEGIN
       OPEN csr_get_class_id;
       FETCH csr_get_class_id into l_classification_id;
       CLOSE csr_get_class_id;

       INSERT INTO pay_ele_tmplt_class_usages
         (ele_template_classification_id
         ,classification_id
         ,template_id
         ,display_process_mode
         ,display_arrearage)
       VALUES
         (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
         ,l_classification_id
         ,l_template_id
         ,NULL
         ,NULL);
      END;

  END create_flat_amt_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_perc_template
  -- This proceudre is used to create a percent of earnings template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_perc_template IS
  --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_info_element_id         number;
    l_ded_element_id          number;
    l_info_amt_iv             number;
    l_info_perc_iv            number;
    l_info_pay_iv             number;
    l_ded_payvalue_iv         number;
    l_ded_repay_iv            number;
    l_ded_install_iv          number;
    l_ded_process_iv          number;
    l_bal_feed_id             number;
    l_excl_rule_id            number;
    l_excl_rule_id_amt            number;
    l_excl_rule_id_perc            number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Percentage of Basic Salary Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Percentage of Basic Salary Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_PCT_FF'
       ,p_description               	=> 'AE Formula for percentage of earnings'
       ,p_formula_text              	=>
'
/*  Description: Formula for Percent of earnings in UAE legislation
*/
Inputs are Percentage_of_earnings

DEFAULT FOR Percentage_of_earnings IS 0

monthly_salary = AE_GRATUITY_SALARY_FORMULA()

    l_amount = (Percentage_of_earnings * monthly_salary)/100

RETURN l_amount


/*======================== End Program =======================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_info_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_info_pay_iv
       ,p_element_type_id              	=> l_info_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_info_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_info_perc_iv
       ,p_element_type_id              	=> l_info_element_id
       --,p_exclusion_rule_id             => l_excl_rule_id_perc
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Percentage of Earnings'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_info_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_info_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_perc_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_basic_sal_template
  -- This proceudre is used to create basic salary template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_basic_sal_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_basic_element_id        number;
    l_pay_iv                  number;
    l_rate_name_iv            number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Grade Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Grade Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      -- None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_BASIC_FF'
       ,p_description               	=> 'AE Formula for basic salary'
       ,p_formula_text              	=>
'
/*  Description: Formula for Grade Allowance template in UAE legislation
*/
Inputs are Grade_Rate (TEXT)

l_amount = AE_GET_RATE_FROM_TAB_ID(TO_NUMBER(Grade_Rate))
IF l_amount = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)
ELSE
RETURN l_amount


/*======================== End Program ======================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --


      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_basic_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_basic_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_rate_name_iv
       ,p_element_type_id              	=> l_basic_element_id
       --,p_exclusion_rule_id             => l_excl_rule_id_perc
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Grade Rate'
       ,p_uom                          	=> 'C'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );


      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_basic_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );
      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_basic_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );
      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_basic_sal_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_hsg_allw_template
  -- This procedure is used to create housing allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_hsg_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_hsg_element_id          number;
    l_hsg_info_element_id     number;
    l_pay_iv                  number;
    l_usage_iv                number;
    l_override_amount_iv      number;
    l_acco_iv                 number;
    l_grade_rate_iv           number;
    l_info_pay_iv             number;
    l_info_amount_iv          number;
    l_info_acco_prov_iv       number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Housing Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
      ----------------------------------------------------------------------------
      -- Delete the existing template
      ----------------------------------------------------------------------------
      FOR c_rec in c_template LOOP
        l_template_id := c_rec.template_id;

        DELETE FROM pay_ele_tmplt_class_usages
        WHERE  template_id = l_template_id;

        pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
      END LOOP;
      --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Housing Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_HSG_FF'
       ,p_description               	=> 'AE Formula for Housing Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for housing allowance template in UAE legislation
*/

DEFAULT FOR Override_Amount IS 0
DEFAULT FOR SCL_ASG_AE_ACCOMMODATION_PROVIDED IS ''N''

Inputs are Rate_Value_to_be_used_as (TEXT)
           ,Override_Amount

IF Override_Amount > 0 AND SCL_ASG_AE_ACCOMMODATION_PROVIDED = ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377441_AE_INV_AMT_HSG'')
RETURN l_mesg)

IF Override_Amount > 0 AND SCL_ASG_AE_ACCOMMODATION_PROVIDED = ''N'' THEN
 (l_amount = Override_Amount
  RETURN l_amount)
ELSE
(


l_amount = 0
l_info_type = ''MARITAL_STATUS''
l_marital_status = AE_GET_EMP_DETAILS(l_info_type)

IF l_marital_status = ''NO_DATA_FOUND'' THEN
( l_mesg = AE_GET_MESSAGE(''PER'',''HR_377440_AE_NO_MAR_STATUS'',''ELEMENT:''||ELEMENT_NAME)
 RETURN l_mesg)

IF l_marital_status = ''M'' THEN
 l_grade_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''HSG_ALLOWANCE_GRADE_RATE_TABLE_MARRIED'')
ELSE
 l_grade_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''HSG_ALLOWANCE_GRADE_RATE_TABLE_SINGLE'')

l_table_exists = ''Y''
l_allowance_value = AE_GET_RATE_FROM_TAB_NAME(l_grade_rate_table_name,l_table_exists)

IF l_table_exists <> ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377435_AE_INV_GRADE_RATE'')
RETURN l_mesg)

IF l_allowance_value = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)

IF Rate_Value_to_be_used_as = ''P'' THEN
 (
 monthly_salary = AE_GRATUITY_SALARY_FORMULA()
 l_amount = (l_allowance_value * monthly_salary)/100
 IF l_marital_status = ''M'' THEN
 l_amount = LEAST(GREATEST(L_AMOUNT, TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''HSG_ALLOWANCE_MARRIED_MIN''))),TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''HSG_ALLOWANCE_MARRIED_MAX'')))
 ELSE
   l_amount = LEAST(GREATEST(L_AMOUNT, TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''HSG_ALLOWANCE_SINGLE_MIN''))),TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''HSG_ALLOWANCE_SINGLE_MAX'')))
 )

ELSE
 l_amount = l_allowance_value

 l_monthly_allowance = l_amount

l_accomodation_provided = SCL_ASG_AE_ACCOMMODATION_PROVIDED

IF l_accomodation_provided = ''Y'' THEN
  (l_amount = 0
  l_subject_to_si = l_monthly_allowance)

RETURN l_amount
       ,l_monthly_allowance
       ,l_accomodation_provided
       ,l_subject_to_si
       ,l_allowance_value
)


/*====================== End Program ===================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_hsg_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_hsg_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Usage
      pay_siv_ins.ins
       (p_input_value_id               	=> l_usage_iv
       ,p_element_type_id              	=> l_hsg_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Rate value to be used as'
       ,p_uom                          	=> 'C'
       ,p_lookup_type                   => 'AE_ALLOWANCE_USAGE'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Usage
      pay_siv_ins.ins
       (p_input_value_id               	=> l_override_amount_iv
       ,p_element_type_id              	=> l_hsg_element_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'N'
       ,p_name                         	=> 'Override Amount'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Acco
      pay_siv_ins.ins
       (p_input_value_id               	=> l_acco_iv
       ,p_element_type_id              	=> l_hsg_element_id
       ,p_display_sequence             	=> 4
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Accommodation Provided'
       ,p_uom                          	=> 'C'
       ,p_lookup_type                   => 'YES_NO'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Grade Rate Value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_grade_rate_iv
       ,p_element_type_id              	=> l_hsg_element_id
       ,p_display_sequence             	=> 5
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Grade Rate Value'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_set_ins.ins
       (p_element_type_id              	=> l_hsg_info_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ' Information'
       --,p_reporting_name              => ' r'
       ,p_relative_processing_priority 	=> 50
       ,p_processing_type              	=> 'N'
       ,p_classification_name          	=> 'Information'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'Y'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       --,p_payroll_formula_id           	=> l_formula_id
       --,p_skip_formula                 	=> ''
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      pay_siv_ins.ins
       (p_input_value_id               	=> l_info_acco_prov_iv
       ,p_element_type_id              	=> l_hsg_info_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Accommodation Provided'
       ,p_uom                          	=> 'C'
       ,p_lookup_type                   => 'YES_NO'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Amount, feeds no balances.
      pay_siv_ins.ins
       (p_input_value_id               	=> l_info_pay_iv
       ,p_element_type_id              	=> l_hsg_info_element_id
       --,p_exclusion_rule_id               => l_flat_amt_Xrule_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_info_amount_iv
       ,p_element_type_id              	=> l_hsg_info_element_id
       --,p_exclusion_rule_id               => l_flat_amt_Xrule_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Monthly Allowance'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_element_type_id              	=> l_hsg_info_element_id
       ,p_input_value_id               	=> l_info_acco_prov_iv
       ,p_result_name                  	=> 'L_ACCOMODATION_PROVIDED'
       ,p_result_rule_type             	=> 'I'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_acco_iv
       ,p_result_name                  	=> 'L_ACCOMODATION_PROVIDED'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_grade_rate_iv
       ,p_result_name                  	=> 'L_ALLOWANCE_VALUE'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_element_type_id              	=> l_hsg_info_element_id
       ,p_input_value_id               	=> l_info_amount_iv
       ,p_result_name                  	=> 'L_MONTHLY_ALLOWANCE'
       ,p_result_rule_type             	=> 'I'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_element_type_id              	=> l_hsg_info_element_id
       ,p_input_value_id               	=> l_info_pay_iv
       ,p_result_name                  	=> 'L_SUBJECT_TO_SI'
       ,p_result_rule_type             	=> 'I'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hsg_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );
      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;
  END create_hsg_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_trn_allw_template
  -- This procedure is used to create transportation allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_trn_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_trn_element_id          number;
    l_pay_iv                  number;
    l_override_amount_iv      number;
    l_usage_iv                number;
    l_grade_rate_iv           number;
    l_trn_prov_iv             number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Transport Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Transport Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      -- None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_TRN_FF'
       ,p_description               	=> 'AE Formula for Transport Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for transportation allowance in UAE legislation
*/


Inputs are Rate_Value_to_be_used_as (TEXT)
           ,Override_Amount

DEFAULT FOR SCL_ASG_AE_TRANSPORTATION_PROVIDED IS ''N''
DEFAULT FOR Override_Amount IS 0

IF Override_Amount > 0 AND SCL_ASG_AE_TRANSPORTATION_PROVIDED = ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377442_AE_INV_AMT_TRN'')
RETURN l_mesg)

IF Override_Amount > 0 AND SCL_ASG_AE_TRANSPORTATION_PROVIDED = ''N'' THEN
 (l_amount = Override_Amount
  RETURN l_amount)
ELSE
(

l_amount = 0

/*Check if Local Nationality is defined*/
l_exists = AE_LOCAL_NATIONALITY_NOT_DEFINED()

IF l_exists = ''NOTEXISTS'' THEN
(
	l_mesg = AE_GET_MESSAGE(''PER'',''HR_377425_AE_LOC_NAT_NOT_DEF'')
	return l_mesg
)

l_local_nat = AE_GET_LOCAL_NATIONALITY()
l_matches = AE_LOCAL_NATIONALITY_MATCHES()

IF l_matches = ''MATCH'' THEN
 l_local = ''Y''
ELSE
 l_local = ''N''


IF l_local = ''Y'' THEN
 l_grade_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''TRN_ALLOWANCE_GRADE_RATE_TABLE_NATIONAL'')
ELSE
 l_grade_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''TRN_ALLOWANCE_GRADE_RATE_TABLE_NON_NATIONAL'')

l_table_exists = ''Y''
l_allowance_value = AE_GET_RATE_FROM_TAB_NAME(l_grade_rate_table_name,l_table_exists)

IF l_table_exists <> ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377435_AE_INV_GRADE_RATE'')
RETURN l_mesg)

IF l_allowance_value = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)

IF Rate_Value_to_be_used_as = ''P'' THEN
 (
 monthly_salary = AE_GRATUITY_SALARY_FORMULA()
 l_amount = (l_allowance_value * monthly_salary)/100
 l_amount = LEAST(GREATEST(L_AMOUNT, TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''TRN_ALLOWANCE_MIN''))),TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''TRN_ALLOWANCE_MAX'')))
 )

ELSE
 l_amount = l_allowance_value

 l_monthly_allowance = l_amount

l_transportation_provided = SCL_ASG_AE_TRANSPORTATION_PROVIDED

IF l_transportation_provided = ''Y'' THEN
  (l_amount = 0)

RETURN l_amount
       ,l_allowance_value
       ,l_transportation_provided

)


/*====================== End Program ===================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_trn_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_trn_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Usage
      pay_siv_ins.ins
       (p_input_value_id               	=> l_usage_iv
       ,p_element_type_id              	=> l_trn_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Rate value to be used as'
       ,p_uom                          	=> 'C'
       ,p_lookup_type                   => 'AE_ALLOWANCE_USAGE'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Override amount
      pay_siv_ins.ins
       (p_input_value_id               	=> l_override_amount_iv
       ,p_element_type_id              	=> l_trn_element_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'N'
       ,p_name                         	=> 'Override Amount'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Trans provided
      pay_siv_ins.ins
       (p_input_value_id               	=> l_trn_prov_iv
       ,p_element_type_id              	=> l_trn_element_id
       ,p_display_sequence             	=> 4
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Transportation Provided'
       ,p_uom                          	=> 'C'
       ,p_lookup_type                   => 'YES_NO'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Grade Rate value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_grade_rate_iv
       ,p_element_type_id              	=> l_trn_element_id
       --,p_exclusion_rule_id               => l_flat_amt_Xrule_id
       ,p_display_sequence             	=> 5
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Grade Rate Value'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_trn_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_trn_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_trn_prov_iv
       ,p_result_name                  	=> 'L_TRANSPORTATION_PROVIDED'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_trn_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_grade_rate_iv
       ,p_result_name                  	=> 'L_ALLOWANCE_VALUE'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_trn_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_trn_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_col_allw_template
  -- This procedure is used to create cost of living allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_col_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_col_element_id          number;
    l_pay_iv                  number;
    l_max_iv                  number;
    l_min_iv                  number;
    l_percent_iv              number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Cost of Living Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Cost of Living Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_COL_FF'
       ,p_description               	=> 'AE Formula for Cost of Living Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for cost of living template in UAE legislation
*/

l_percent = TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''COST_OF_LIVING_ALLOWANCE_PERCENT''))
l_max_value = TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''COST_OF_LIVING_ALLOWANCE_MAX''))
l_min_value = TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''COST_OF_LIVING_ALLOWANCE_MIN''))

monthly_salary = AE_GRATUITY_SALARY_FORMULA()
    l_amount = (l_percent * monthly_salary)/100

    /*Amount = LEAST(GREATEST(AMOUNT, TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''COST_OF_LIVING_ALLOWANCE_MIN''))),TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''COST_OF_LIVING_ALLOWANCE_MAX'')))*/

  l_amount = LEAST(GREATEST(l_amount,l_min_value),l_max_value)


RETURN l_amount
       ,l_percent
       ,l_min_value
       ,l_max_value


/*====================== End Program ==================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_col_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_col_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Percent
      pay_siv_ins.ins
       (p_input_value_id               	=> l_percent_iv
       ,p_element_type_id              	=> l_col_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Percentage of Earnings'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      pay_siv_ins.ins
       (p_input_value_id               	=> l_max_iv
       ,p_element_type_id              	=> l_col_element_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Maximum Amount for Allowance'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      pay_siv_ins.ins
       (p_input_value_id               	=> l_min_iv
       ,p_element_type_id              	=> l_col_element_id
       ,p_display_sequence             	=> 4
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Minimum Amount for Allowance'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_col_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_col_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_percent_iv
       ,p_result_name                  	=> 'L_PERCENT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_col_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_max_iv
       ,p_result_name                  	=> 'L_MAX_VALUE'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_col_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_min_iv
       ,p_result_name                  	=> 'L_MIN_VALUE'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_col_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_child_allw_template
  -- This procedure is used to create chiild allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_child_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_child_element_id        number;
    l_pay_iv                  number;
    l_num_child_iv            number;
    l_allowance_iv            number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Children Social Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Children Social Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      -- None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_CA_FF'
       ,p_description               	=> 'AE Formula for Children Social Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for child allowance template in UAE legislation
*/
/*Check if Local Nationality is defined*/
l_exists = AE_LOCAL_NATIONALITY_NOT_DEFINED()

IF l_exists = ''NOTEXISTS'' THEN
(
	l_mesg = AE_GET_MESSAGE(''PER'',''HR_377425_AE_LOC_NAT_NOT_DEF'')
	return l_mesg
)

l_local_nat = AE_GET_LOCAL_NATIONALITY()
l_matches = AE_LOCAL_NATIONALITY_MATCHES()
IF l_matches = ''MATCH'' THEN
 (
 l_amount = 0
 l_info_type = ''DEPENDENT_CHILDREN''
 l_count_child = AE_GET_EMP_DETAILS(l_info_type)

 l_child_allowance = TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''CHILDREN_SOCIAL_ALLOWANCE''))
 l_count = TO_NUMBER(l_count_child)
  l_amount = l_child_allowance * l_count


 RETURN l_amount, l_count, l_child_allowance
 )
ELSE
 (l_mesg = AE_GET_MESSAGE(''PER'',''HR_377436_AE_CHILD_ALLW_NA'',''LEGISLATION:''||l_local_nat)
 RETURN l_mesg)




/*====================== End Program ==================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_child_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_child_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Number of Dep. Childs
      pay_siv_ins.ins
       (p_input_value_id               	=> l_num_child_iv
       ,p_element_type_id              	=> l_child_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Number of Dependent Children'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -- Allowance per child
      pay_siv_ins.ins
       (p_input_value_id               	=> l_allowance_iv
       ,p_element_type_id              	=> l_child_element_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Allowance Per Child'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_child_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_child_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_num_child_iv
       ,p_result_name                  	=> 'L_COUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_child_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_allowance_iv
       ,p_result_name                  	=> 'L_CHILD_ALLOWANCE'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_child_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );
      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_child_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_social_allw_template
  -- This procedure is used to create social allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_social_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_soc_element_id          number;
    l_pay_iv                  number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Social Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Social Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_SOC_FF'
       ,p_description               	=> 'AE Formula for Social Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for social allowance template in UAE legislation
*/
/*Check if Local Nationality is defined*/
l_exists = AE_LOCAL_NATIONALITY_NOT_DEFINED()

IF l_exists = ''NOTEXISTS'' THEN
(
	l_mesg = AE_GET_MESSAGE(''PER'',''HR_377425_AE_LOC_NAT_NOT_DEF'')
	return l_mesg
)

l_local_nat = AE_GET_LOCAL_NATIONALITY()
l_matches = AE_LOCAL_NATIONALITY_MATCHES()
IF l_matches = ''MATCH'' THEN
 (
l_amount = 0
l_info_type = ''MARITAL_STATUS''
l_marital_status = AE_GET_EMP_DETAILS(l_info_type)
IF l_marital_status = ''NO_DATA_FOUND'' THEN
( l_mesg = AE_GET_MESSAGE(''PER'',''HR_377440_AE_NO_MAR_STATUS'',''ELEMENT:''||ELEMENT_NAME)
 RETURN l_mesg)

IF l_marital_status = ''M'' THEN
  l_amount = TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''SOCIAL_ALLOWANCE_MARRIED''))
ELSE
  l_amount = TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''SOCIAL_ALLOWANCE_SINGLE''))

RETURN l_amount,l_marital_status
)
ELSE
 (l_mesg = AE_GET_MESSAGE(''PER'',''HR_377437_AE_SOCIAL_ALLW_NA'',''LEGISLATION:''||l_local_nat)
 RETURN l_mesg)


/*====================== End Program =================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_soc_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_soc_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );


      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_soc_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_soc_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_social_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_shift_allw_template
  -- This procedure is used to create shift allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_shift_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_shift_element_id        number;
    l_pay_iv                  number;
    l_override_amount_iv      number;
    l_usage_iv                number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Shift Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Shift Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_SH_FF'
       ,p_description               	=> 'AE Formula for Shift Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for shift allowance template in UAE legislation
*/


Inputs are Rate_Value_to_be_used_as (TEXT)
           ,Override_Amount

DEFAULT FOR Override_Amount IS 0

IF Override_Amount > 0 THEN
 (l_amount = Override_Amount
  RETURN l_amount)
ELSE
(

l_amount = 0

/*Check if Local Nationality is defined*/
l_exists = AE_LOCAL_NATIONALITY_NOT_DEFINED()

IF l_exists = ''NOTEXISTS'' THEN
(
	l_mesg = AE_GET_MESSAGE(''PER'',''HR_377425_AE_LOC_NAT_NOT_DEF'')
	return l_mesg
)

l_local_nat = AE_GET_LOCAL_NATIONALITY()

l_matches = AE_LOCAL_NATIONALITY_MATCHES()

IF l_matches = ''MATCH'' THEN
 l_local = ''Y''
ELSE
 l_local = ''N''


IF l_local = ''Y'' THEN
 l_grade_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''SHIFT_ALLOWANCE_GRADE_RATE_TABLE_NATIONAL'')
ELSE
 l_grade_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''SHIFT_ALLOWANCE_GRADE_RATE_TABLE_NON_NATIONAL'')

l_table_exists = ''Y''
l_allowance_value = AE_GET_RATE_FROM_TAB_NAME(l_grade_rate_table_name,l_table_exists)

IF l_table_exists <> ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377435_AE_INV_GRADE_RATE'')
RETURN l_mesg)

If l_allowance_value = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)

IF Rate_Value_to_be_used_as = ''P'' THEN
 (
 monthly_salary = AE_GRATUITY_SALARY_FORMULA()
 l_amount = (l_allowance_value * monthly_salary)/100
 l_amount = LEAST(GREATEST(L_AMOUNT, TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''SHIFT_ALLOWANCE_MIN''))),TO_NUMBER(GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''SHIFT_ALLOWANCE_MAX'')))
 )

ELSE
 l_amount = l_allowance_value

RETURN l_amount

)


/*==================== End Program =================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_shift_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_shift_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --
      pay_siv_ins.ins
       (p_input_value_id               	=> l_usage_iv
       ,p_element_type_id              	=> l_shift_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Rate value to be used as'
       ,p_uom                          	=> 'C'
       ,p_lookup_type                   => 'AE_ALLOWANCE_USAGE'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_override_amount_iv
       ,p_element_type_id              	=> l_shift_element_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'N'
       ,p_name                         	=> 'Override Amount'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_shift_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_shift_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_shift_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_hrly_basic_sal_template
  -- This procedure is used to create hourly basic salary template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_hrly_basic_sal_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_hrly_element_id         number;
    l_pay_iv                  number;
    l_hrs_worked_iv           number;
    l_rate_name_iv            number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Hourly Salary Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Hourly Salary Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_HOURLY_FF'
       ,p_description               	=> 'AE Formula for hourly salary'
       ,p_formula_text              	=>
'
/*  Description: Formula for hourly basic salary template in UAE legislation
*/
Inputs are Hours_Worked_in_a_Month
           ,Grade_Rate (TEXT)

Hourly_Rate = AE_GET_RATE_FROM_TAB_ID(TO_NUMBER(Grade_Rate))

If Hourly_Rate = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)
ELSE
(l_amount = Hours_Worked_in_a_Month * Hourly_Rate

RETURN l_amount
)

/*====================== End Program ================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_hrly_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'R'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_hrly_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_hrs_worked_iv
       ,p_element_type_id              	=> l_hrly_element_id
       --,p_exclusion_rule_id             => l_excl_rule_id_perc
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Hours Worked in a Month'
       ,p_uom                          	=> 'H_DECIMAL2'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_siv_ins.ins
       (p_input_value_id               	=> l_rate_name_iv
       ,p_element_type_id              	=> l_hrly_element_id
       --,p_exclusion_rule_id             => l_excl_rule_id_perc
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Grade Rate'
       ,p_uom                          	=> 'C'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hrly_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_hrly_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_hrly_basic_sal_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_ot_allw_template
  -- This procedure is used to create overtime allowance template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_ot_allw_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id             number;
    l_defined_bal_id          number;
    l_effective_date          date;
    l_ovn                     number;
    l_formula_id              number;
    l_rr_id                   number;
    l_primary_bal_id          number;
    l_secondary_bal_id        number;
    l_ot_element_id           number;
    l_pay_iv                  number;
    l_hrs_regular_iv          number;
    l_hrs_rest_iv             number;
    l_rate_regular_iv         number;
    l_rate_rest_iv            number;
    l_bal_feed_id             number;
    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Overtime Allowance Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Overtime Allowance Template'
       ,p_base_processing_priority	=> 2500
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      -- None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_OT_FF'
       ,p_description               	=> 'AE Formula for Overtime Allowance'
       ,p_formula_text              	=>
'
/*  Description: Formula for overtime allowance in UAE legislation
*/

Inputs are Extra_Hours_Worked
           ,Hours_Worked_on_rest_days

DEFAULT FOR Extra_Hours_Worked IS 0
DEFAULT FOR Hours_Worked_on_rest_days IS 0

l_amount = 0
l_monthly_salary = AE_GRATUITY_SALARY_FORMULA()
l_hrly_salary = (l_monthly_salary * 12)/(365 * 8)

l_regular_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''OVERTIME_ALLOWANCE_TABLE_REGULAR_DAYS'')

l_table_exists = ''Y''
l_regular_ot = AE_GET_RATE_FROM_TAB_NAME(l_regular_rate_table_name,l_table_exists)

IF l_table_exists <> ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377435_AE_INV_GRADE_RATE'')
RETURN l_mesg)

If l_regular_ot = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)

l_rest_days_rate_table_name = GET_TABLE_VALUE(''AE_ALLOWANCE_VALUES'',''ALLOWANCE_NAME'',''OVERTIME_ALLOWANCE_TABLE_REST_DAYS'')

l_table_exists = ''Y''
l_rest_days_ot = AE_GET_RATE_FROM_TAB_NAME(l_rest_days_rate_table_name,l_table_exists)

IF l_table_exists <> ''Y'' THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377435_AE_INV_GRADE_RATE'')
RETURN l_mesg)

If l_rest_days_ot = 0 THEN
(l_mesg = AE_GET_MESSAGE(''PER'',''HR_377434_AE_NO_GRADE_ALLW'')
RETURN l_mesg)

l_amount = (Extra_Hours_Worked * (l_regular_ot/100) * l_hrly_salary) + (Hours_Worked_on_rest_days * (l_rest_days_ot/100) * l_hrly_salary)

RETURN l_amount
       ,l_regular_ot
       ,l_rest_days_ot


/*=================== End Program =================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_ot_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 0
       ,p_processing_type              	=> 'N'
       ,p_classification_name             => 'Earnings'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_ot_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Hours outside regular hours
      pay_siv_ins.ins
       (p_input_value_id               	=> l_hrs_regular_iv
       ,p_element_type_id              	=> l_ot_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'N'
       ,p_name                         	=> 'Extra Hours Worked'
       ,p_uom                          	=> 'H_DECIMAL2'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Hours on Rest Days
      pay_siv_ins.ins
       (p_input_value_id               	=> l_hrs_rest_iv
       ,p_element_type_id              	=> l_ot_element_id
       ,p_display_sequence             	=> 3
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'N'
       ,p_name                         	=> 'Hours Worked on Rest Days'
       ,p_uom                          	=> 'H_DECIMAL2'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Normal Day Rate
      pay_siv_ins.ins
       (p_input_value_id               	=> l_rate_regular_iv
       ,p_element_type_id              	=> l_ot_element_id
       ,p_display_sequence             	=> 4
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Normal Day Rate'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Hours on Rest Days
      pay_siv_ins.ins
       (p_input_value_id               	=> l_rate_rest_iv
       ,p_element_type_id              	=> l_ot_element_id
       ,p_display_sequence             	=> 5
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Rest Day Rate'
       ,p_uom                          	=> 'N'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ot_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ot_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_rate_regular_iv
       ,p_result_name                  	=> 'L_REGULAR_OT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ot_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_rate_rest_iv
       ,p_result_name                  	=> 'L_REST_DAYS_OT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -- Message (Information)
      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ot_element_id
       ,p_result_name                  	=> 'L_MESG'
       ,p_result_rule_type             	=> 'M'
       ,p_severity_level               	=> 'I'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Earnings';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_ot_allw_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_unp_leave_dedn_template
  -- This procedure is used to create unpaid leave deduction template
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_unp_leave_dedn_template IS
    --
    TYPE Char80_Table    IS TABLE OF VARCHAR2(80)  INDEX BY BINARY_INTEGER;
    t_dim                Char80_Table;
    --
    l_template_id                number;
    l_defined_bal_id             number;
    l_effective_date             date;
    l_ovn                        number;
    l_formula_id                 number;
    l_rr_id                      number;
    l_primary_bal_id             number;
    l_secondary_bal_id           number;
    l_ul_element_id              number;
    l_ul_arrears_element_id      number;
    l_ul_arr_payment_element_id  number;
    l_pay_iv                     number;
    l_days_iv                    number;
    l_ul_arrear_pay_iv           number;
    l_arrear_payment_iv          number;
    l_bal_feed_id                number;


    --
    CURSOR c_template IS
    SELECT template_id
    FROM   pay_element_templates
    WHERE  template_name = 'Unpaid Leave Template'
    AND  template_type = 'T';
    --
  BEGIN
    ----------------------------------------------------------------------------
    -- Delete the existing template
    ----------------------------------------------------------------------------
    FOR c_rec in c_template LOOP
      l_template_id := c_rec.template_id;

      DELETE FROM pay_ele_tmplt_class_usages
      WHERE  template_id = l_template_id;

      pay_element_template_api.delete_user_structure
             (p_validate              =>     false
             ,p_drop_formula_packages =>     true
             ,p_template_id           =>     l_template_id);
    END LOOP;
    --
      l_effective_date := to_date('0001/01/01', 'YYYY/MM/DD');
      ------------------------------------------------------------------------
      --   SECTION1 :
      ------------------------------------------------------------------------
      pay_etm_ins.ins
       (p_template_id             	=> l_template_id
       ,p_effective_date          	=> l_effective_date
       ,p_template_type           	=> 'T'
       ,p_template_name           	=> 'Unpaid Leave Template'
       ,p_base_processing_priority	=> 1750
       ,p_max_base_name_length    	=> 50
       ,p_version_number          	=> 1
       ,p_legislation_code        	=> 'AE'
       ,p_object_version_number   	=> l_ovn
       );
      -----------------------------------------------------------------------
      -- SECTION2 : Exclusion Rules.
      -----------------------------------------------------------------------
      --None
      ------------------------------------------------------------------------
      -- SECTION 3 : Formulas
      ------------------------------------------------------------------------
      ------------------------
      -- a) Formula
      ------------------------
       pay_sf_ins.ins
       (p_formula_id                	=> l_formula_id
       ,p_template_type             	=> 'T'
       ,p_legislation_code          	=> 'AE'
       ,p_formula_name              	=> '_UL_FF'
       ,p_description               	=> 'AE Formula for Unpaid Leave'
       ,p_formula_text              	=>
'
/*  Description: Formula for unpaid leave deduction template in UAE legislation
*/

Default for PAY_PROC_PERIOD_END_DATE_DP is ''4712/12/31 00:00:00'' (DATE)
Default for PAY_PROC_PERIOD_START_DATE_DP is ''0001/01/01 00:00:00'' (DATE)

DEFAULT for SUBJECT_TO_UNPAID_LEAVE_ASG_RUN IS 0

l_amount = 0

l_subjected_earnings = SUBJECT_TO_UNPAID_LEAVE_ASG_RUN

l_unpaid_leave_days = AE_GET_ABSENCE_DAYS(PAY_PROC_PERIOD_START_DATE_DP, PAY_PROC_PERIOD_END_DATE_DP)

l_amount = ((l_subjected_earnings * 12)/365) * l_unpaid_leave_days

IF NET_ASG_RUN < l_amount THEN
 (l_arrears = l_amount - NET_ASG_RUN
 l_ul_amount = l_amount - l_arrears
 l_ul_amount = - l_ul_amount)
ELSE
 l_ul_amount = - l_amount

RETURN l_ul_amount, l_unpaid_leave_days, l_arrears


/*================== End Program =================*/'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      --
      ---------------------------------------------------------------------------------
      -- SECTION 3 : Balances and Classification
      ---------------------------------------------------------------------------------
      t_dim(1)  := 'Assignment Inception To Date';
      t_dim(2)  := 'Assignment Run';
      --================
      -- Primary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_primary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ''
       ,p_reporting_name               => ''
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_primary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      --
      --================
      -- Secondary Balance
      --================
      pay_sbt_ins.ins
       (p_balance_type_id              => l_secondary_bal_id
       ,p_template_id                  => l_template_id
       ,p_assignment_remuneration_flag => 'N'
       ,p_balance_name                 => ' Arrears'
       ,p_reporting_name               => ' Arrears'
       ,p_comments                     => null
       ,p_balance_uom                  => 'M'
       ,p_currency_code		       => 'AED'
       ,p_object_version_number        => l_ovn
       ,p_effective_date               => l_effective_date
       );
      -- create the defined balances
      FOR i IN 1..2 LOOP
         pay_sdb_ins.ins
          (p_defined_balance_id        => l_defined_bal_id
          ,p_balance_type_id           => l_secondary_bal_id
          ,p_dimension_name            => t_dim(i)
          ,p_object_version_number     => l_ovn
          ,p_effective_date            => l_effective_date
         );
      END LOOP;
      ---------------------------------------------------------------------------------
      -- SECTION 4 : Elements
      ---------------------------------------------------------------------------------
      --====================
      -- b) 'Base' element.
      --====================
      pay_set_ins.ins
       (p_element_type_id              	=> l_ul_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ''
       ,p_reporting_name               	=> ''
       ,p_relative_processing_priority 	=> 1350 --(this element should process after earnings classification )
       ,p_processing_type              	=> 'N'
       ,p_classification_name             => 'Absence'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'F'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       ,p_payroll_formula_id           	=> l_formula_id
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      -- Pay value
      pay_siv_ins.ins
       (p_input_value_id               	=> l_pay_iv
       ,p_element_type_id              	=> l_ul_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Leave Days
      pay_siv_ins.ins
       (p_input_value_id               	=> l_days_iv
       ,p_element_type_id              	=> l_ul_element_id
       ,p_display_sequence             	=> 2
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Number of Unpaid Leaves'
       ,p_uom                          	=> 'ND'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Indirect element for Arrears
      pay_set_ins.ins
       (p_element_type_id              	=> l_ul_arrears_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ' Arrears'
       ,p_relative_processing_priority 	=> 1400
       ,p_processing_type              	=> 'N'
       ,p_classification_name          	=> 'Information'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'L'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'Y'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       --,p_payroll_formula_id           	=> l_formula_id
       --,p_skip_formula                 	=> ''
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      pay_siv_ins.ins
       (p_input_value_id               	=> l_ul_arrear_pay_iv
       ,p_element_type_id              	=> l_ul_arrears_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'X'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_secondary_bal_id
       ,p_input_value_id               	=> l_ul_arrear_pay_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      --Element for Arrears Payment
      pay_set_ins.ins
       (p_element_type_id              	=> l_ul_arr_payment_element_id
       ,p_template_id                  	=> l_template_id
       ,p_element_name                 	=> ' Arrears Payment'
       ,p_relative_processing_priority 	=> 1450
       ,p_processing_type              	=> 'N'
       ,p_classification_name          	=> 'Absence'
       ,p_input_currency_code          	=> 'AED'
       ,p_output_currency_code         	=> 'AED'
       ,p_multiple_entries_allowed_fla 	=> 'N'
       ,p_post_termination_rule        	=> 'L'
       ,p_process_in_run_flag          	=> 'Y'
       ,p_additional_entry_allowed_fla 	=> 'N'
       ,p_adjustment_only_flag         	=> 'N'
       ,p_closed_for_entry_flag        	=> 'N'
       ,p_indirect_only_flag           	=> 'N'
       ,p_multiply_value_flag          	=> 'N'
       ,p_standard_link_flag           	=> 'N'
       --,p_payroll_formula_id           	=> l_formula_id
       --,p_skip_formula                 	=> ''
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );
      --
      pay_siv_ins.ins
       (p_input_value_id               	=> l_arrear_payment_iv
       ,p_element_type_id              	=> l_ul_arr_payment_element_id
       ,p_display_sequence             	=> 1
       ,p_generate_db_items_flag       	=> 'Y'
       ,p_hot_default_flag             	=> 'N'
       ,p_mandatory_flag               	=> 'Y'
       ,p_name                         	=> 'Pay Value'
       ,p_uom                          	=> 'M'
      -- ,p_max_value                       => 100
       ---,p_min_value                       => 10
      -- ,p_warning_or_error             => 'W'
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_secondary_bal_id
       ,p_input_value_id               	=> l_arrear_payment_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      pay_sbf_ins.ins
       (p_balance_feed_id              	=> l_bal_feed_id
       ,p_balance_type_id              	=> l_primary_bal_id
       ,p_input_value_id               	=> l_arrear_payment_iv
       ,p_scale                        	=> 1
       ,p_object_version_number        	=> l_ovn
       ,p_effective_date            	=> l_effective_date
       );

      -------------------------------------------------------------------------
      -- SECTION 6 : Formula rules
      -------------------------------------------------------------------------

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ul_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_pay_iv
       ,p_result_name                  	=> 'L_UL_AMOUNT'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ul_element_id
       ,p_element_type_id              	=> ''
       ,p_input_value_id               	=> l_days_iv
       ,p_result_name                  	=> 'L_UNPAID_LEAVE_DAYS'
       ,p_result_rule_type             	=> 'D'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      pay_sfr_ins.ins
       (p_formula_result_rule_id       	=> l_rr_id
       ,p_shadow_element_type_id       	=> l_ul_element_id
       ,p_element_type_id              	=> l_ul_arrears_element_id
       ,p_input_value_id               	=> l_ul_arrear_pay_iv
       ,p_result_name                  	=> 'L_ARREARS'
       ,p_result_rule_type             	=> 'I'
       ,p_object_version_number       	=> l_ovn
       ,p_effective_date            	=> l_effective_date
      );

      -------------------------------------------------------------------------
      -- SECTION 7 : Insert into pay_ele_tmplt_class_usages
      -------------------------------------------------------------------------
      DECLARE
        CURSOR csr_get_class_id IS
        SELECT classification_id
        FROM   pay_element_classifications
        WHERE  legislation_code = 'AE'
        AND    classification_name = 'Absence';
        l_classification_id       NUMBER;

      BEGIN
        OPEN csr_get_class_id;
        FETCH csr_get_class_id into l_classification_id;
        CLOSE csr_get_class_id;

        INSERT INTO pay_ele_tmplt_class_usages
          (ele_template_classification_id
          ,classification_id
          ,template_id
          ,display_process_mode
          ,display_arrearage)
        VALUES
          (PAY_ELE_TMPLT_CLASS_USG_S.NEXTVAL
          ,l_classification_id
          ,l_template_id
          ,NULL
          ,NULL);
      END;

  END create_unp_leave_dedn_template;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  -- Procedure create_templates
  -- This procedure calls the procedures for creating the templates.
  -- The procedure gets called from hrglobal
  ------------------------------------------------------------------------
  ------------------------------------------------------------------------
  PROCEDURE create_templates IS

    l_enabled_flag    FND_CURRENCIES.ENABLED_FLAG%TYPE;
    CURSOR csr_get_currency IS
    SELECT enabled_flag
    FROM   fnd_currencies
    WHERE  currency_code = 'AED';

  BEGIN
    OPEN csr_get_currency;
    FETCH csr_get_currency INTO l_enabled_flag;
    CLOSE csr_get_currency;

    /* Enable AED Currency */
    UPDATE fnd_currencies
    SET enabled_flag = 'Y'
    WHERE currency_code = 'AED'
    AND   enabled_flag <> 'Y';

    create_flat_amt_template;

    create_perc_template;

    create_basic_sal_template;

    create_hsg_allw_template;

    create_trn_allw_template;

    create_col_allw_template;

    create_child_allw_template;

    create_social_allw_template;

    create_shift_allw_template;

    create_hrly_basic_sal_template;

    create_ot_allw_template;

    create_unp_leave_dedn_template;

    UPDATE fnd_currencies
    SET enabled_flag = l_enabled_flag
    WHERE currency_code = 'AED';

  END create_templates;

  ------------------------------------------------------------------------
  ------------------------------------------------------------------------

END pay_ae_element_template_pkg;

/
