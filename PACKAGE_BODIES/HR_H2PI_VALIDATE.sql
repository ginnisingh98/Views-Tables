--------------------------------------------------------
--  DDL for Package Body HR_H2PI_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_VALIDATE" AS
/* $Header: hrh2pivd.pkb 120.0 2005/05/31 00:42:19 appldev noship $ */

g_package  VARCHAR2(33) := '  hr_h2pi_validate.';
MAPPING_ID_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (MAPPING_ID_MISSING, -20010);
--
-- For bg and gre valdation
--
PROCEDURE validate_bg_and_gre(p_from_client_id VARCHAR2) IS

TYPE bg_and_gre_tab_type is TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

bg_and_gre_tab  bg_and_gre_tab_type;

CURSOR csr_bg_and_gre IS
   SELECT * FROM hr_h2pi_bg_and_gre
   WHERE  client_id = p_from_client_id;

CURSOR csr_pay_bg_and_gre IS
   SELECT organization_id
   FROM   hr_h2pi_bg_and_gre_v
   WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_hr_data_removed (p_organization_id NUMBER) IS
  SELECT organization_id
  FROM   hr_h2pi_bg_and_gre_v bg
  WHERE  bg.business_group_id = hr_h2pi_upload.g_to_business_group_Id
  AND    bg.organization_id = p_organization_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him,
                         hr_h2pi_bg_and_gre bg1
                  WHERE  him.to_id = bg.organization_id
                  AND    bg1.organization_id = him.from_id
                  AND    him.table_name = 'HR_ALL_ORGANIZATION_UNITS'
                  AND    him.to_business_group_id = bg.business_group_id);

CURSOR csr_payroll_data_added(p_organization_id NUMBER) IS
  SELECT organization_id
  FROM   hr_h2pi_bg_and_gre_v bg
  WHERE  bg.business_group_id = hr_h2pi_upload.g_to_business_group_id
  AND    bg.organization_id = p_organization_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him
                  WHERE  him.to_id = bg.organization_id
                  AND    him.table_name = 'HR_ALL_ORGANIZATION_UNITS'
                  AND    him.to_business_group_id =
                                    hr_h2pi_upload.g_to_business_group_id);

l_ed_rec               hr_h2pi_bg_and_gre_v%ROWTYPE;
l_organization_to_id   hr_h2pi_bg_and_gre.organization_id%TYPe;
l_counter              BINARY_INTEGER ;
l_organization_id      hr_h2pi_bg_and_gre.organization_id%TYPE;
l_location_id          hr_h2pi_bg_and_gre.location_id%TYPE;
l_record_ok            BOOLEAN;

l_proc         VARCHAR2(72) := g_package||'validate_bg_and_gre';

l_method_of_gen_emp_num per_business_groups.method_of_generation_emp_num%TYPE;
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  BEGIN
    SELECT method_of_generation_emp_num
    INTO   l_method_of_gen_emp_num
    FROM   per_business_groups
    WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;
    IF l_method_of_gen_emp_num <> 'M' THEN
      hr_h2pi_error.data_error(p_from_id       => p_from_client_id,
                               p_table_name    => 'HR_H2PI_BG_AND_GRE',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289292_EMP_NUM_GEN_MANUAL');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  l_counter := 0;

  <<main_loop>>
  FOR v_ud_rec IN csr_bg_and_gre LOOP
    SAVEPOINT org_start;
    hr_utility.set_location(l_proc, 20);
    l_organization_to_id := hr_h2pi_map.get_to_id
                           (p_table_name        => 'HR_ALL_ORGANIZATION_UNITS',
                            p_from_id           => v_ud_rec.organization_id);

    IF l_organization_to_id = -1 THEN
      hr_utility.set_location(l_proc, 30);
      hr_h2pi_error.data_error(p_from_id       => v_ud_rec.organization_id,
                               p_table_name    => 'HR_H2PI_BG_AND_GRE',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289260_UD_DATA_ADDED');
    ELSE
      hr_utility.set_location(l_proc, 40);
      BEGIN
        SELECT DISTINCT *
        INTO   l_ed_rec
        FROM   hr_h2pi_bg_and_gre_v
        WHERE  organization_id = l_organization_to_id;

        l_counter := l_counter + 1 ;
        bg_and_gre_tab(l_counter) := l_organization_to_id;

        l_location_id := hr_h2pi_map.get_to_id
                              (p_table_name   => 'HR_LOCATIONS_ALL',
                               p_from_id      => v_ud_rec.location_id,
                               p_report_error => TRUE);
        IF l_ed_rec.date_from <> v_ud_rec.date_from OR
           l_ed_rec.date_to <> v_ud_rec.date_to OR
           NVL(l_ed_rec.location_id, -1) <> NVL(l_location_id, -1) THEN
          hr_utility.set_location(l_proc, 50);
          hr_h2pi_error.data_error(p_from_id       => v_ud_rec.organization_id,
                                   p_table_name    => 'HR_H2PI_BG_AND_GRE',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289237_DATA_MISMATCH');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 60);
        hr_h2pi_error.data_error(p_from_id      => v_ud_rec.organization_id,
                                 p_table_name   => 'HR_H2PI_BG_AND_GRE',
                                 p_message_level=> 'FATAL',
                                 p_message_name => 'HR_289235_ED_DATA_REMOVED');
        WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 70);
      END;
    END IF;
  END LOOP main_loop;

  BEGIN
    <<outer_loop>>
    hr_utility.set_location(l_proc, 80);
    FOR csr_pay_bg_and_gre_rec in csr_pay_bg_and_gre LOOP
      hr_utility.set_location(l_proc, 90);
      l_record_ok := FALSE;

      <<inner_loop>>
      FOR j IN 1..l_counter LOOP
        IF bg_and_gre_tab(j) = csr_pay_bg_and_gre_rec.organization_id THEN
          l_record_ok := TRUE;
        END IF;
      END LOOP inner_loop;

      IF NOT l_record_ok THEN
        hr_utility.set_location(l_proc, 100);
        OPEN csr_payroll_data_added(csr_pay_bg_and_gre_rec.organization_id);
        FETCH csr_payroll_data_added INTO l_organization_id;

        IF csr_payroll_data_added%FOUND then
          hr_utility.set_location(l_proc, 110);

          hr_h2pi_error.data_error(p_from_id =>  l_organization_id,
                                   p_table_name    => 'HR_H2PI_BG_AND_GRE',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289259_ED_DATA_ADDED');
          CLOSE csr_payroll_data_added;

        ELSE

          CLOSE csr_payroll_data_added;

          OPEN csr_hr_data_removed(csr_pay_bg_and_gre_rec.organization_id);
          FETCH csr_hr_data_removed into l_organization_id;
          IF csr_hr_data_removed%FOUND then
            hr_utility.set_location(l_proc, 120);
            --HR Data removed
            hr_h2pi_error.data_error(p_from_id =>  l_organization_id,
                                     p_table_name    => 'HR_H2PI_BG_AND_GRE',
                                     p_message_level => 'FATAL',
                                     p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          END IF;
          CLOSE csr_hr_data_removed;
        END IF;
      END IF;
    END LOOP outer_loop;
    hr_utility.set_location(l_proc, 130);
  END ;
  COMMIT;
  hr_utility.set_location('Leaving:' || l_proc, 140);
END validate_bg_and_gre;

--
-- For Pay Basis validation
--

PROCEDURE validate_pay_basis(p_from_client_id VARCHAR2) IS

TYPE pay_bases_tab_type is TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

pay_bases_tab  pay_bases_tab_type;

CURSOR csr_pay_bases IS
  SELECT * FROM hr_h2pi_pay_bases
  WHERE  client_id = p_from_client_id;

CURSOR csr_pay_pay_bases IS
  SELECT pay_basis_id
  FROM   hr_h2pi_pay_bases_v
  WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_hr_data_removed (p_pay_basis_id NUMBER) IS
  SELECT pay_basis_id
  FROM   hr_h2pi_pay_bases_v pay
  WHERE  pay.business_group_id = hr_h2pi_upload.g_to_business_group_Id
  AND    pay.pay_basis_id = p_pay_basis_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him,
                         hr_h2pi_pay_bases pay1
                  WHERE  him.to_id = pay.pay_basis_id
                  AND    pay1.pay_basis_id = him.from_id
                  AND    him.table_name = 'PER_PAY_BASES'
                  AND    him.to_business_group_id = pay.business_group_id);

CURSOR csr_payroll_data_added(p_pay_basis_id NUMBER) IS
  SELECT pay_basis_id
  FROM   hr_h2pi_pay_bases_v pay
  WHERE  pay.business_group_id = hr_h2pi_upload.g_to_business_group_id
  AND    pay.pay_basis_id = p_pay_basis_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him
                  WHERE  him.to_id = pay.pay_basis_id
                  AND    him.table_name = 'PER_PAY_BASES'
                  AND    him.to_business_group_id =
                                 hr_h2pi_upload.g_to_business_group_id);

l_ed_rec           hr_h2pi_pay_bases_v%ROWTYPE;
l_pay_basis_to_id  hr_h2pi_pay_bases.pay_basis_id%TYPe;
l_counter          BINARY_INTEGER ;
l_pay_basis_id     hr_h2pi_pay_bases.pay_basis_id%TYPE;
l_record_ok        BOOLEAN;

l_proc         VARCHAR2(72) := g_package||'validate_pay_basis';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_counter := 0;

  <<main_loop>>
  FOR v_ud_rec IN csr_pay_bases LOOP
    SAVEPOINT pay_basis_start;
    hr_utility.set_location(l_proc, 20);
    l_pay_basis_to_id := hr_h2pi_map.get_to_id
                           (p_table_name        => 'PER_PAY_BASES',
                            p_from_id           => v_ud_rec.pay_basis_id);

    IF l_pay_basis_to_id = -1 THEN
      hr_utility.set_location(l_proc, 30);
      hr_h2pi_error.data_error(p_from_id       => v_ud_rec.pay_basis_id,
                               p_table_name    => 'HR_H2PI_PAY_BASES',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289260_UD_DATA_ADDED');
    ELSE
      hr_utility.set_location(l_proc, 40);
      BEGIN
        SELECT *
        INTO   l_ed_rec
        FROM   hr_h2pi_pay_bases_v
        WHERE  pay_basis_id = l_pay_basis_to_id;

        l_counter := l_counter + 1 ;
        pay_bases_tab(l_counter) := l_pay_basis_to_id;

        IF l_ed_rec.name <> v_ud_rec.name OR
           l_ed_rec.pay_basis   <> v_ud_rec.pay_basis THEN
          hr_utility.set_location(l_proc, 50);
          hr_h2pi_error.data_error(p_from_id       => v_ud_rec.pay_basis_id,
                                   p_table_name    => 'HR_H2PI_PAY_BASES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289237_DATA_MISMATCH');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 60);
        hr_h2pi_error.data_error(p_from_id      => v_ud_rec.pay_basis_id,
                                 p_table_name   => 'HR_H2PI_PAY_BASES',
                                 p_message_level=> 'FATAL',
                                 p_message_name => 'HR_289235_ED_DATA_REMOVED');
        WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 70);
      END;
    END IF;
  END LOOP main_loop;

  BEGIN
    <<outer_loop>>
    FOR csr_pay_pay_bases_rec in csr_pay_pay_bases LOOP
      hr_utility.set_location(l_proc, 80);
      l_record_ok := FALSE;

      <<inner_loop>>
      FOR j IN 1..l_counter LOOP
        IF pay_bases_tab(j) = csr_pay_pay_bases_rec.pay_basis_id THEN
          l_record_ok := TRUE;
        END IF;
      END LOOP inner_loop;

      IF NOT l_record_ok THEN
        hr_utility.set_location(l_proc, 90);
        OPEN csr_payroll_data_added(csr_pay_pay_bases_rec.pay_basis_id);
        FETCH csr_payroll_data_added INTO l_pay_basis_id;

        IF csr_payroll_data_added%FOUND then
        -- Pay basis data added.
          hr_utility.set_location(l_proc, 100);
          hr_h2pi_error.data_error(p_from_id =>  l_pay_basis_id,
                                   p_table_name    => 'HR_H2PI_PAY_BASES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289259_ED_DATA_ADDED');
          CLOSE csr_payroll_data_added;

        ELSE

          hr_utility.set_location(l_proc, 110);
          CLOSE csr_payroll_data_added;

          OPEN csr_hr_data_removed(csr_pay_pay_bases_rec.pay_basis_id);
          FETCH csr_hr_data_removed into l_pay_basis_id;
          IF csr_hr_data_removed%FOUND then
            --HR Data removed
            hr_utility.set_location(l_proc, 120);
            hr_h2pi_error.data_error(p_from_id =>  l_pay_basis_id,
                                     p_table_name    => 'HR_H2PI_PAY_BASES',
                                     p_message_level => 'FATAL',
                                     p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          END IF;
          CLOSE csr_hr_data_removed;
        END IF;
      END IF;
    END LOOP outer_loop;
  END ;
  COMMIT;
  hr_utility.set_location('Leaving:' || l_proc, 130);
END validate_pay_basis;

--
-- For Payroll validation
--

PROCEDURE validate_payroll(p_from_client_id VARCHAR2) IS

TYPE payrolls_tab_type is TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

payrolls_tab  payrolls_tab_type;

CURSOR csr_payrolls IS
  SELECT * FROM hr_h2pi_payrolls
  WHERE  client_id = p_from_client_id;

CURSOR csr_pay_payrolls IS
  SELECT payroll_id
  FROM   hr_h2pi_payrolls_v
  WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_hr_data_removed (p_payroll_id NUMBER) IS
  SELECT payroll_id
  FROM   hr_h2pi_payrolls_v pay
  WHERE  pay.business_group_id = hr_h2pi_upload.g_to_business_group_Id
  AND    pay.payroll_id = p_payroll_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him,
                         hr_h2pi_payrolls pay1
                  WHERE  him.to_id = pay.payroll_id
                  AND    pay1.payroll_id = him.from_id
                  AND    him.table_name = 'PAY_ALL_PAYROLLS_F'
                  AND    him.to_business_group_id = pay.business_group_id);

CURSOR csr_payroll_data_added(p_payroll_id NUMBER) IS
  SELECT payroll_id
  FROM   hr_h2pi_payrolls_v pay
  WHERE  pay.business_group_id = hr_h2pi_upload.g_to_business_group_id
  AND    pay.payroll_id = p_payroll_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him
                  WHERE  him.to_id = pay.payroll_id
                  AND    him.table_name = 'PAY_ALL_PAYROLLS_F'
                  AND    him.to_business_group_id =
                                   hr_h2pi_upload.g_to_business_group_id);

l_ed_rec         hr_h2pi_payrolls_v%ROWTYPE;
l_payroll_to_id  pay_all_payrolls_f.payroll_id%TYPe;
l_counter        BINARY_INTEGER ;
l_payroll_id     pay_all_payrolls_f.payroll_id%TYPE;
l_record_ok      BOOLEAN;

l_proc         VARCHAR2(72) := g_package||'validate_payroll';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  l_counter := 0;

  <<main_loop>>
  FOR v_ud_rec IN csr_payrolls LOOP
    SAVEPOINT payroll_start;
    hr_utility.set_location(l_proc, 20);
    l_payroll_to_id := hr_h2pi_map.get_to_id
                          (p_table_name        => 'PAY_ALL_PAYROLLS_F',
                           p_from_id           => v_ud_rec.payroll_id);

    IF l_payroll_to_id = -1 THEN
      hr_utility.set_location(l_proc, 30);
      hr_h2pi_error.data_error(p_from_id       => v_ud_rec.payroll_id,
                               p_table_name    => 'HR_H2PI_PAYROLLS',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289260_UD_DATA_ADDED');
    ELSE
      BEGIN
        hr_utility.set_location(l_proc, 40);
        SELECT *
        INTO   l_ed_rec
        FROM   hr_h2pi_payrolls_v
        WHERE  payroll_id = l_payroll_to_id
          AND  effective_start_date = v_ud_rec.effective_start_date
          AND  effective_end_date   = v_ud_rec.effective_end_date;

        l_counter := l_counter + 1 ;
        payrolls_tab(l_counter) := l_payroll_to_id;

        IF l_ed_rec.payroll_name          <> v_ud_rec.payroll_name OR
           l_ed_rec.first_period_end_date <> v_ud_rec.first_period_end_date OR
           l_ed_rec.number_of_years       <> v_ud_rec.number_of_years OR
           l_ed_rec.period_type           <> v_ud_rec.period_type OR
           l_ed_rec.effective_start_date  <> v_ud_rec.effective_start_date OR
           l_ed_rec.effective_end_date    <> v_ud_rec.effective_end_date THEN
          hr_utility.set_location(l_proc, 50);
          hr_h2pi_error.data_error(p_from_id       => v_ud_rec.payroll_id,
                                   p_table_name    => 'HR_H2PI_PAYROLLS',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289237_DATA_MISMATCH');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 60);
        hr_h2pi_error.data_error(p_from_id      => v_ud_rec.payroll_id,
                                 p_table_name   => 'HR_H2PI_PAYROLLS',
                                 p_message_level=> 'FATAL',
                                 p_message_name => 'HR_289235_ED_DATA_REMOVED');
        WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 70);
      END;
    END IF;
  END LOOP main_loop;

  BEGIN
    <<outer_loop>>
    FOR csr_pay_payrolls_rec in csr_pay_payrolls LOOP
    hr_utility.set_location(l_proc, 80);
      l_record_ok := FALSE;

      <<inner_loop>>
      FOR j IN 1..l_counter LOOP
        IF payrolls_tab(j) = csr_pay_payrolls_rec.payroll_id THEN
          l_record_ok := TRUE;
        END IF;
      END LOOP inner_loop;

      IF NOT l_record_ok THEN
        hr_utility.set_location(l_proc, 90);
        OPEN csr_payroll_data_added(csr_pay_payrolls_rec.payroll_id);
        FETCH csr_payroll_data_added INTO l_payroll_id;

        IF csr_payroll_data_added%FOUND then
          -- Payroll Data added.
          hr_utility.set_location(l_proc, 100);
          hr_h2pi_error.data_error(p_from_id =>  l_payroll_id,
                                   p_table_name    => 'HR_H2PI_PAYROLLS',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289259_ED_DATA_ADDED');
          CLOSE csr_payroll_data_added;

        ELSE

          hr_utility.set_location(l_proc, 110);
          CLOSE csr_payroll_data_added;

          OPEN csr_hr_data_removed(csr_pay_payrolls_rec.payroll_id);
          FETCH csr_hr_data_removed into l_payroll_id;
          IF csr_hr_data_removed%FOUND then
            --HR Data removed
            hr_utility.set_location(l_proc, 120);
            hr_h2pi_error.data_error(p_from_id =>  l_payroll_id,
                                     p_table_name    => 'HR_H2PI_PAYROLLS',
                                     p_message_level => 'FATAL',
                                     p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          END IF;
        CLOSE csr_hr_data_removed;
        END IF;
      END IF;
    END LOOP outer_loop;
  END ;
  COMMIT;
  hr_utility.set_location('Leaving:' || l_proc, 130);
END validate_payroll;

--
-- For Element Type validation
--

PROCEDURE validate_element_type(p_from_client_id VARCHAR2) IS

TYPE element_type_tab_type is TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

element_type_tab  element_type_tab_type;

CURSOR csr_element_type IS
  SELECT * FROM hr_h2pi_element_types
  WHERE  client_id = p_from_client_id
  AND    legislation_code IS NULL;

CURSOR csr_pay_element_type IS
  SELECT element_type_id
  FROM   hr_h2pi_element_types_v
  WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_hr_data_removed (p_element_type_id NUMBER) IS
  SELECT element_type_id
  FROM   hr_h2pi_element_types_v ele
  WHERE  ele.business_group_id = hr_h2pi_upload.g_to_business_group_Id
  AND    ele.element_type_id = p_element_type_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him,
                         hr_h2pi_element_types ele1
                  WHERE  him.to_id = ele.element_type_id
                  AND    ele1.element_type_id = him.from_id
                  AND    him.table_name = 'PAY_ELEMENT_TYPES_F'
                  AND    him.to_business_group_id = ele.business_group_id);

CURSOR csr_payroll_data_added(p_element_type_id NUMBER) IS
  SELECT element_type_id
  FROM   hr_h2pi_element_types_v ele
  WHERE  ele.business_group_id = hr_h2pi_upload.g_to_business_group_id
  AND    ele.element_type_id = p_element_type_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him
                  WHERE  him.to_id = ele.element_type_id
                  AND    him.table_name = 'PAY_ELEMENT_TYPES_F'
                  AND    him.to_business_group_id =
                                hr_h2pi_upload.g_to_business_group_id);

l_ed_rec               hr_h2pi_element_types_v%ROWTYPE;
l_element_type_to_id   hr_h2pi_element_types.element_type_id%TYPe;
l_counter              BINARY_INTEGER ;
l_element_type_id      hr_h2pi_element_types.element_type_id%TYPE;
l_record_ok            BOOLEAN;

l_proc         VARCHAR2(72) := g_package||'validate_element_type';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  l_counter := 0;

  <<main_loop>>
  FOR v_ud_rec IN csr_element_type LOOP
    SAVEPOINT element_type_start;
    hr_utility.set_location(l_proc, 20);
    l_element_type_to_id := hr_h2pi_map.get_to_id
                           (p_table_name        => 'PAY_ELEMENT_TYPES_F',
                            p_from_id           => v_ud_rec.element_type_id);

    IF l_element_type_to_id = -1 THEN
      hr_utility.set_location(l_proc, 30);
      hr_h2pi_error.data_error(p_from_id       => v_ud_rec.element_type_id,
                               p_table_name    => 'HR_H2PI_ELEMENT_TYPES',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289260_UD_DATA_ADDED');
    ELSE
      BEGIN
        hr_utility.set_location(l_proc, 40);
        SELECT *
        INTO   l_ed_rec
        FROM   hr_h2pi_element_types_v
        WHERE  element_type_id = l_element_type_to_id
          AND  effective_start_date = v_ud_rec.effective_start_date
          AND  effective_end_date   = v_ud_rec.effective_end_date;

        l_counter := l_counter + 1 ;
        element_type_tab(l_counter) := l_element_type_to_id;

        IF l_ed_rec.element_name         <> v_ud_rec.element_name OR
           l_ed_rec.processing_type      <> v_ud_rec.processing_type OR
           l_ed_rec.effective_start_date <> v_ud_rec.effective_start_date OR
           l_ed_rec.effective_end_date   <> v_ud_rec.effective_end_date THEN
          hr_utility.set_location(l_proc, 50);
          hr_h2pi_error.data_error(p_from_id       => v_ud_rec.element_type_id,
                                   p_table_name    => 'HR_H2PI_ELEMENT_TYPES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289237_DATA_MISMATCH');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 60);
        hr_h2pi_error.data_error(p_from_id      => v_ud_rec.element_type_id,
                                 p_table_name   => 'HR_H2PI_ELEMENT_TYPES',
                                 p_message_level=> 'FATAL',
                                 p_message_name => 'HR_289235_ED_DATA_REMOVED');
        WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 70);
      END;
    END IF;
  END LOOP main_loop;

  BEGIN
    <<outer_loop>>
    FOR csr_pay_element_type_rec in csr_pay_element_type LOOP
    hr_utility.set_location(l_proc, 80);
      l_record_ok := FALSE;

      <<inner_loop>>
      FOR j IN 1..l_counter LOOP
        IF element_type_tab(j) = csr_pay_element_type_rec.element_type_id THEN
          l_record_ok := TRUE;
        END IF;
      END LOOP inner_loop;

      IF NOT l_record_ok THEN
        hr_utility.set_location(l_proc, 90);
        OPEN csr_payroll_data_added(csr_pay_element_type_rec.element_type_id);
        FETCH csr_payroll_data_added INTO l_element_type_id;

        IF csr_payroll_data_added%FOUND then

          hr_utility.set_location(l_proc, 100);
          hr_h2pi_error.data_error(p_from_id =>  l_element_type_id,
                                   p_table_name    => 'HR_H2PI_ELEMENT_TYPES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289259_ED_DATA_ADDED');
          CLOSE csr_payroll_data_added;

        ELSE

          hr_utility.set_location(l_proc, 110);
          CLOSE csr_payroll_data_added;

          OPEN csr_hr_data_removed(csr_pay_element_type_rec.element_type_id);
          FETCH csr_hr_data_removed into l_element_type_id;
          IF csr_hr_data_removed%FOUND then
            hr_utility.set_location(l_proc, 130);
            --HR Data removed
            hr_h2pi_error.data_error(p_from_id =>  l_element_type_id,
                                     p_table_name    => 'HR_H2PI_ELEMENT_TYPES',
                                     p_message_level => 'FATAL',
                                     p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          END IF;
          CLOSE csr_hr_data_removed;
        END IF;
      END IF;
    END LOOP outer_loop;
  END ;
  COMMIT;
  hr_utility.set_location('Leaving:' || l_proc, 130);
END validate_element_type;

--
-- For org payment method validation
--
PROCEDURE validate_org_payment_method(p_from_client_id VARCHAR2) IS

TYPE org_payment_method_tab_type is TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

org_payment_method_tab  org_payment_method_tab_type;

CURSOR csr_org_payment_method IS
  SELECT * FROM hr_h2pi_org_payment_methods
  WHERE  client_id = p_from_client_id;

CURSOR csr_pay_org_payment_method IS
  SELECT org_payment_method_id
  FROM   hr_h2pi_org_payment_methods_v
  WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_hr_data_removed (p_org_payment_method_id NUMBER) IS
  SELECT org_payment_method_id
  FROM   hr_h2pi_org_payment_methods_v ele
  WHERE  ele.business_group_id = hr_h2pi_upload.g_to_business_group_Id
  AND    ele.org_payment_method_id = p_org_payment_method_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him,
                         hr_h2pi_org_payment_methods ele1
                  WHERE  him.to_id = ele.org_payment_method_id
                  AND    ele1.org_payment_method_id = him.from_id
                  AND    him.table_name = 'PAY_ORG_PAYMENT_METHODS_F'
                  AND    him.to_business_group_id = ele.business_group_id);

CURSOR csr_payroll_data_added(p_org_payment_method_id NUMBER) IS
  SELECT org_payment_method_id
  FROM   hr_h2pi_org_payment_methods_v ele
  WHERE  ele.business_group_id = hr_h2pi_upload.g_to_business_group_id
  AND    ele.org_payment_method_id = p_org_payment_method_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him
                  WHERE  him.to_id = ele.org_payment_method_id
                  AND    him.table_name = 'PAY_ORG_PAYMENT_METHODS_F'
                  AND    him.to_business_group_id =
                                hr_h2pi_upload.g_to_business_group_id);

l_ed_rec         hr_h2pi_org_payment_methods_v%ROWTYPE;
l_org_payment_method_to_id
                 hr_h2pi_org_payment_methods.org_payment_method_id%TYPe;
l_counter        BINARY_INTEGER ;
l_org_payment_method_id
                 hr_h2pi_org_payment_methods.org_payment_method_id%TYPE;
l_record_ok      BOOLEAN;

l_proc         VARCHAR2(72) := g_package||'validate_org_payment_methods';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_counter := 0;

  <<main_loop>>
  FOR v_ud_rec IN csr_org_payment_method LOOP
    SAVEPOINT org_payment_start;
    hr_utility.set_location(l_proc, 20);
    l_org_payment_method_to_id := hr_h2pi_map.get_to_id
                        (p_table_name        => 'PAY_ORG_PAYMENT_METHODS_F',
                         p_from_id           => v_ud_rec.org_payment_method_id);

    IF l_org_payment_method_to_id = -1 THEN
      hr_utility.set_location(l_proc, 30);
      hr_h2pi_error.data_error(p_from_id      => v_ud_rec.org_payment_method_id,
                               p_table_name    => 'HR_H2PI_ORG_PAYMENT_METHODS',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289260_UD_DATA_ADDED');
    ELSE
      hr_utility.set_location(l_proc, 40);
      BEGIN
        SELECT *
        INTO   l_ed_rec
        FROM   hr_h2pi_org_payment_methods_v
        WHERE  org_payment_method_id = l_org_payment_method_to_id
          AND  effective_start_date  = v_ud_rec.effective_start_date
          AND  effective_end_date    = v_ud_rec.effective_end_date;

        l_counter := l_counter + 1 ;
        org_payment_method_tab(l_counter) := l_org_payment_method_to_id;

        IF l_ed_rec.org_payment_method_name <> v_ud_rec.org_payment_method_name OR
           l_ed_rec.effective_start_date <> v_ud_rec.effective_start_date OR
           l_ed_rec.effective_end_date   <> v_ud_rec.effective_end_date OR
           --l_ed_rec.external_account_id   <> v_ud_rec.external_account_id OR
           l_ed_rec.currency_code <> v_ud_rec.currency_code OR
           l_ed_rec.payment_type_name <> v_ud_rec.payment_type_name OR
           l_ed_rec.territory_code <> v_ud_rec.territory_code THEN
          hr_utility.set_location(l_proc, 50);
          hr_h2pi_error.data_error(p_from_id  => v_ud_rec.org_payment_method_id,
                                 p_table_name => 'HR_H2PI_ORG_PAYMENT_METHODS',
                                 p_message_level => 'FATAL',
                                 p_message_name  => 'HR_289237_DATA_MISMATCH');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 60);
        hr_h2pi_error.data_error(p_from_id    => v_ud_rec.org_payment_method_id,
                                 p_table_name => 'HR_H2PI_ORG_PAYMENT_METHODS',
                                 p_message_level =>'FATAL',
                                 p_message_name  =>'HR_289235_ED_DATA_REMOVED');
        WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 70);
      END;
    END IF;
  END LOOP main_loop;

  BEGIN
    <<outer_loop>>
    FOR csr_pay_org_payment_method_rec in csr_pay_org_payment_method LOOP
      hr_utility.set_location(l_proc, 80);
      l_record_ok := FALSE;

      <<inner_loop>>
      FOR j IN 1..l_counter LOOP
        IF org_payment_method_tab(j) = csr_pay_org_payment_method_rec.org_payment_method_id THEN
          l_record_ok := TRUE;
        END IF;
      END LOOP inner_loop;

      IF NOT l_record_ok THEN
        hr_utility.set_location(l_proc, 90);
        OPEN csr_payroll_data_added(csr_pay_org_payment_method_rec.org_payment_method_id);
        FETCH csr_payroll_data_added INTO l_org_payment_method_id;

        IF csr_payroll_data_added%FOUND then
          hr_utility.set_location(l_proc, 100);

          hr_h2pi_error.data_error(p_from_id =>  l_org_payment_method_id,
                                   p_table_name    => 'HR_H2PI_ORG_PAYMENT_METHODS',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289259_ED_DATA_ADDED');
          CLOSE csr_payroll_data_added;

        ELSE

          hr_utility.set_location(l_proc, 110);
          CLOSE csr_payroll_data_added;

          OPEN csr_hr_data_removed(csr_pay_org_payment_method_rec.org_payment_method_id);
          FETCH csr_hr_data_removed into l_org_payment_method_id;
          hr_utility.set_location(l_proc, 120);
          IF csr_hr_data_removed%FOUND then
            --HR Data removed
            hr_h2pi_error.data_error(p_from_id    => l_org_payment_method_id,
                                     p_table_name => 'HR_H2PI_ORG_PAYMENT_METHODS',
                                     p_message_level => 'FATAL',
                                     p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          END IF;
          CLOSE csr_hr_data_removed;
        END IF;
      END IF;
    END LOOP outer_loop;
  END ;
  COMMIT;
  hr_utility.set_location('Leaving: '|| l_proc, 130);
END validate_org_payment_method;

--
-- For Element Link validation
--

PROCEDURE validate_element_link(p_from_client_id VARCHAR2) IS

TYPE element_link_tab_type is TABLE OF NUMBER(15)
  INDEX BY BINARY_INTEGER;

element_link_tab  element_link_tab_type;

CURSOR csr_element_link IS
  SELECT el.* FROM hr_h2pi_element_links el,
                   hr_h2pi_element_types et
  WHERE  el.client_id = p_from_client_id
  AND    el.element_type_id = et.element_type_id
  AND    el.effective_start_date BETWEEN et.effective_start_date
                                     AND et.effective_end_date
  AND    et.legislation_code IS NULL
  AND    et.client_id = p_from_client_id;

CURSOR csr_pay_element_link IS
   SELECT element_link_id
   FROM   hr_h2pi_element_links_v
   WHERE  business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_hr_data_removed (p_element_link_id NUMBER) IS
  SELECT element_link_id
  FROM   hr_h2pi_element_links_v ele
  WHERE  ele.business_group_id = hr_h2pi_upload.g_to_business_group_Id
  AND    ele.element_link_id = p_element_link_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him,
                         hr_h2pi_element_links ele1
                  WHERE  him.to_id = ele.element_link_id
                  AND    ele1.element_link_id = him.from_id
                  AND    him.table_name = 'PAY_ELEMENT_LINKS_F'
                  AND    him.to_business_group_id = ele.business_group_id);

CURSOR csr_payroll_data_added(p_element_link_id NUMBER) IS
  SELECT element_link_id
  FROM   hr_h2pi_element_links_v ele
  WHERE  ele.business_group_id = hr_h2pi_upload.g_to_business_group_id
  AND    ele.element_link_id = p_element_link_id
  AND NOT EXISTS (SELECT 'X'
                  FROM   hr_h2pi_id_mapping him
                  WHERE  him.to_id = ele.element_link_id
                  AND    him.table_name = 'PAY_ELEMENT_LINKS_F'
                  AND    him.to_business_group_id =
                                hr_h2pi_upload.g_to_business_group_id);

l_ed_rec               hr_h2pi_element_links_v%ROWTYPE;
l_element_link_to_id   hr_h2pi_element_links.element_link_id%TYPe;
l_counter              BINARY_INTEGER ;
l_element_link_id      hr_h2pi_element_links.element_link_id%TYPE;
l_payroll_id           hr_h2pi_element_links.payroll_id%TYPE;
l_pay_basis_id         hr_h2pi_element_links.pay_basis_id%TYPE;
l_organization_id      hr_h2pi_element_links.organization_id%TYPE;
l_record_ok            BOOLEAN;

l_proc         VARCHAR2(72) := g_package||'validate_element_link';

BEGIN
  hr_utility.set_location('Leaving: '|| l_proc, 10);
  l_counter := 0;

  <<main_loop>>
  FOR v_ud_rec IN csr_element_link LOOP
    SAVEPOINT element_link_start;
    hr_utility.set_location(l_proc, 20);
    l_element_link_to_id := hr_h2pi_map.get_to_id
                           (p_table_name        => 'PAY_ELEMENT_LINKS_F',
                            p_from_id           => v_ud_rec.element_link_id);

    IF l_element_link_to_id = -1 THEN
      hr_utility.set_location(l_proc, 30);
      hr_h2pi_error.data_error(p_from_id       => v_ud_rec.element_link_id,
                               p_table_name    => 'HR_H2PI_ELEMENT_LINKS',
                               p_message_level => 'FATAL',
                               p_message_name  => 'HR_289260_UD_DATA_ADDED');
    ELSE
      BEGIN
        hr_utility.set_location(l_proc, 40);
        SELECT *
        INTO   l_ed_rec
        FROM   hr_h2pi_element_links_v
        WHERE  element_link_id = l_element_link_to_id
          AND  effective_start_date  = v_ud_rec.effective_start_date
          AND  effective_end_date    = v_ud_rec.effective_end_date;

        l_counter := l_counter + 1 ;
        element_link_tab(l_counter) := l_element_link_to_id;

        l_payroll_id := hr_h2pi_map.get_to_id
                         (p_table_name        => 'PAY_ALL_PAYROLLS_F',
                          p_from_id           => v_ud_rec.payroll_id,
                          p_report_error      => TRUE);
        l_organization_id := hr_h2pi_map.get_to_id
                         (p_table_name        => 'HR_ALL_ORGANIZATIONS_UNITS',
                          p_from_id           => v_ud_rec.organization_id,
                          p_report_error      => TRUE);
        l_pay_basis_id := hr_h2pi_map.get_to_id
                         (p_table_name        => 'PER_PAY_BASES',
                          p_from_id           => v_ud_rec.pay_basis_id,
                          p_report_error      => TRUE);
        IF l_ed_rec.effective_start_date <> v_ud_rec.effective_start_date OR
           l_ed_rec.effective_end_date   <> v_ud_rec.effective_end_date OR
           NVL(l_ed_rec.payroll_id,-1) <> NVL(l_payroll_id, -1) OR
           l_ed_rec.cost_allocation_keyflex_id
                                  <> v_ud_rec.cost_allocation_keyflex_id OR
           NVL(l_ed_rec.organization_id, -1)
                                  <> NVL(l_organization_id, -1) OR
           NVL(l_ed_rec.pay_basis_id, -1) <> NVL(l_pay_basis_id, -1) OR
           l_ed_rec.link_to_all_payrolls_flag
                                  <> v_ud_rec.link_to_all_payrolls_flag THEN
          hr_utility.set_location(l_proc, 50);
          hr_h2pi_error.data_error(p_from_id       => v_ud_rec.element_link_id,
                                   p_table_name    => 'HR_H2PI_ELEMENT_LINKS',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289237_DATA_MISMATCH');
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 60);
        hr_h2pi_error.data_error(p_from_id      => v_ud_rec.element_link_id,
                                 p_table_name   => 'HR_H2PI_ELEMENT_LINKS',
                                 p_message_level=> 'FATAL',
                                 p_message_name => 'HR_289235_ED_DATA_REMOVED');
        WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 70);
      END;
    END IF;
  END LOOP main_loop;

  BEGIN
    <<outer_loop>>
    FOR csr_pay_element_link_rec in csr_pay_element_link LOOP
      hr_utility.set_location(l_proc, 80);
      l_record_ok := FALSE;

      <<inner_loop>>
      FOR j IN 1..l_counter LOOP
        IF element_link_tab(j) = csr_pay_element_link_rec.element_link_id THEN
          l_record_ok := TRUE;
        END IF;
      END LOOP inner_loop;

      IF NOT l_record_ok THEN
        hr_utility.set_location(l_proc, 90);
        OPEN csr_payroll_data_added(csr_pay_element_link_rec.element_link_id);
        FETCH csr_payroll_data_added INTO l_element_link_id;

        IF csr_payroll_data_added%FOUND then
          hr_utility.set_location(l_proc, 100);

          hr_h2pi_error.data_error(p_from_id =>  l_element_link_id,
                                   p_table_name    => 'HR_H2PI_ELEMENT_LINKS',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289259_ED_DATA_ADDED');
          CLOSE csr_payroll_data_added;

        ELSE

          hr_utility.set_location(l_proc, 110);
          CLOSE csr_payroll_data_added;

          OPEN csr_hr_data_removed(csr_pay_element_link_rec.element_link_id);
          FETCH csr_hr_data_removed into l_element_link_id;
          IF csr_hr_data_removed%FOUND then
            --HR Data removed
            hr_utility.set_location(l_proc, 120);
            hr_h2pi_error.data_error(p_from_id =>  l_element_link_id,
                                     p_table_name    => 'HR_H2PI_ELEMENT_LINKS',
                                     p_message_level => 'FATAL',
                                     p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          END IF;
          CLOSE csr_hr_data_removed;
        END IF;
      END IF;
    END LOOP outer_loop;
  END ;
  COMMIT;
  hr_utility.set_location('Leaving: '|| l_proc, 130);
END validate_element_link;
--
-- This procedure checks for the GEOCODE changes on HR and Payroll system
-- If HR or Payroll systems are more then one patches out of sync then
-- this procedure insert a record in hr_h2pi_message lines table with message
-- for the same.
--
-- Following are other three cases
-- HR is one version ahead of Payroll
-- Payroll is one version ahead of HR
-- HR and Payroll are on same version of Geocode patch
--
--
PROCEDURE validate_geocode(p_from_client_id VARCHAR2) IS

CURSOR csr_ud_geocode IS
  SELECT NVL(MAX(patch_name),'GEOCODE_1900_Q1') FROM hr_h2pi_patch_status
  WHERE  client_id = p_from_client_id;
CURSOR csr_ed_geocode IS
  SELECT NVL(MAX(patch_name),'GEOCODE_1900_Q1') FROM hr_h2pi_patch_status_v;

l_geocode_status   VARCHAR2(30);

l_ud_geocode      hr_h2pi_patch_status.patch_name%TYPE;
l_ed_geocode      hr_h2pi_patch_status.patch_name%TYPE;

l_jurisdiction_code      hr_h2pi_city_tax_rules.jurisdiction_code%TYPE;
l_jurisdiction_code_comp hr_h2pi_city_tax_rules.jurisdiction_code%TYPE;

l_state_code              hr_h2pi_us_modified_geocodes.state_code%TYPE;
l_county_code             hr_h2pi_us_modified_geocodes.county_code%TYPE;
l_city_code               hr_h2pi_us_modified_geocodes.old_city_code%TYPE;

--
l_input_value1            hr_h2pi_input_values.input_value_id%Type;
l_input_value2            hr_h2pi_input_values.input_value_id%Type;
--

-- Cursor to find out input_value_id for VERTEX and Worker Compensation
CURSOR csr_input_values IS
  SELECT iv.input_value_id
  FROM   pay_input_values_f  iv,
         pay_element_types_f et
  WHERE  et.element_name IN ('VERTEX','Workers Compensation')
  AND    iv.name = 'Jurisdiction'
  AND    iv.element_type_id = et.element_type_id;

CURSOR csr_ud_city_tax IS
  SELECT  jurisdiction_code jurisdiction_code
  FROM    hr_h2pi_city_tax_rules
  WHERE   client_id = p_from_client_id
  UNION ALL
  SELECT screen_entry_value jurisdiction_code
  FROM   hr_h2pi_element_entry_values
  WHERE  input_value_id in ( l_input_value1, l_input_value2)
  AND    screen_entry_value IS NOT NULL
  AND    client_id = p_from_client_id;

CURSOR csr_ud_city_tax_comp(p_state_code  VARCHAR2,
                            p_county_code VARCHAR2,
                            p_city_code   VARCHAR2) IS
  SELECT old_city_code
  FROM  hr_h2pi_us_modified_geocodes
  WHERE state_code    = p_state_code
  AND   county_code   = p_county_code
  AND   new_city_code = p_city_code;

CURSOR csr_ed_city_tax IS
  SELECT jurisdiction_code jurisdiction_code
  FROM  hr_h2pi_city_tax_rules_v
  WHERE business_group_id = hr_h2pi_upload.g_to_business_group_id
  UNION ALL
  SELECT screen_entry_value jurisdiction_code
  FROM   hr_h2pi_element_entry_values_v eev,
         pay_input_values_f  iv,
         pay_element_types_f    et
  WHERE  screen_entry_value is NOT NULL
  AND    iv.element_type_id = et.element_type_id
  AND    eev.input_value_id = iv.input_value_id
  AND    et.element_name IN ('VERTEX','Workers Compensation')
  AND    iv.name = 'Jurisdiction'
  AND    eev.business_group_id = hr_h2pi_upload.g_to_business_group_id;

CURSOR csr_ed_city_tax_comp(p_state_code VARCHAR2,
                            p_county_code VARCHAR2,
                            p_city_code VARCHAR2) IS
  SELECT new_city_code
  FROM   hr_h2pi_us_modified_geocodes_v
  WHERE  state_code    = p_state_code
  AND    county_code   = p_county_code
  AND    new_city_code = p_city_code;

e_ud_more_then_two_ver_ahead   EXCEPTION;
e_ed_more_then_two_ver_ahead   EXCEPTION;

l_ud_more_then_two_ver_ahead   NUMBER(3);
l_ed_more_then_two_ver_ahead   NUMBER(3);

l_proc         VARCHAR2(72) := g_package||'validate_geocodes';

BEGIN
  SAVEPOINT geocode_start;
  hr_utility.set_location('Entering:'|| l_proc, 10);
  OPEN csr_ud_geocode;
  OPEN csr_ed_geocode;
  FETCH csr_ud_geocode INTO l_ud_geocode;
  SELECT count(*)
  INTO   l_ed_more_then_two_ver_ahead
  FROM   hr_h2pi_patch_status_v
  WHERE  patch_name > l_ud_geocode;

  IF l_ed_more_then_two_ver_ahead > 1 then
    hr_utility.set_location(l_proc, 20);
    RAISE e_ed_more_then_two_ver_ahead;
  END IF;

  FETCH csr_ed_geocode INTO l_ed_geocode;
  SELECT count(*)
  INTO   l_ud_more_then_two_ver_ahead
  FROM   hr_h2pi_patch_status
  WHERE  patch_name > l_ed_geocode
  AND    client_id = p_from_client_id;

  IF l_ud_more_then_two_ver_ahead > 1 then
    hr_utility.set_location(l_proc, 30);
    RAISE e_ud_more_then_two_ver_ahead;
  END IF;
  IF l_ud_geocode < l_ed_geocode THEN
    hr_utility.set_location(l_proc, 40);
    l_geocode_status := 'UD LATER';
  ELSIF l_ud_geocode > l_ed_geocode THEN
    hr_utility.set_location(l_proc, 50);
    l_geocode_status := 'ED LATER';
  ELSE
    hr_utility.set_location(l_proc, 60);
    l_geocode_status := 'MATCHES';
  END IF;
  CLOSE csr_ud_geocode;
  CLOSE csr_ed_geocode;

  IF l_geocode_status = 'ED LATER'  then
    hr_utility.set_location(l_proc, 70);
    --
    open csr_input_values;
    fetch csr_input_values into l_input_value1;
    fetch csr_input_values into l_input_value2;
    l_input_value1 :=
               hr_h2pi_map.get_from_id(p_table_name=>'PAY_INPUT_VALUES_F',
                           p_to_id => l_input_value1,
                           p_report_error => TRUE);
    l_input_value2 :=
               hr_h2pi_map.get_from_id(p_table_name=>'PAY_INPUT_VALUES_F',
                           p_to_id => l_input_value2,
                           p_report_error => TRUE);

    --
    FOR csr_ud_city_tax_rec IN csr_ud_city_tax LOOP
      hr_utility.set_location(l_proc, 80);
      l_state_code := substr(csr_ud_city_tax_rec.jurisdiction_code,1,2);
      l_county_code := substr(csr_ud_city_tax_rec.jurisdiction_code,4,3);
      l_city_code := substr(csr_ud_city_tax_rec.jurisdiction_code,8,4);
      -- This is user defined city write an error
      FOR csr_ud_city_tax_comp_rec IN csr_ud_city_tax_comp(l_state_code,
                                                           l_county_code,
                                                           l_city_code) LOOP
        IF l_city_code LIKE  'U%' THEN
          hr_utility.set_location(l_proc, 90);
          hr_h2pi_error.data_error(p_from_id    =>  l_state_code  ||
                                                    l_county_code ||
                                                    REPLACE(l_city_code,'U',0),
                                   p_table_name => 'HR_H2PI_US_MODIFIED_GEOCODES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289269_USER_CITY_CODE');
                                   -- Message name to be changed.
        ELSIF csr_ud_city_tax_comp%FOUND THEN
          hr_utility.set_location(l_proc, 100);
          hr_h2pi_error.data_error(p_from_id    => l_state_code  ||
                                                   l_county_code ||
                                                   REPLACE(l_city_code,'U',0),
                                   p_table_name => 'HR_H2PI_US_MODIFIED_GEOCODES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289236_UD_DATA_REMOVED');
          EXIT;
        ELSE
          NULL;
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
  ELSIF l_geocode_status = 'UD LATER' then
    hr_utility.set_location(l_proc, 110);
    FOR csr_ed_city_tax_rec IN csr_ed_city_tax LOOP
      l_state_code := substr(csr_ed_city_tax_rec.jurisdiction_code,1,2);
      l_county_code := substr(csr_ed_city_tax_rec.jurisdiction_code,4,3);
      l_city_code := substr(csr_ed_city_tax_rec.jurisdiction_code,8,4);
      hr_utility.set_location(l_proc, 120);
      FOR csr_ed_city_tax_comp_rec IN csr_ed_city_tax_comp(l_state_code,
                                                           l_county_code,
                                                           l_city_code) LOOP
        IF l_city_code LIKE  'U%' THEN

          hr_h2pi_error.data_error(p_from_id    =>  l_state_code  ||
                                                    l_county_code ||
                                                    REPLACE(l_city_code,'U',0),
                                   p_table_name => 'HR_H2PI_US_MODIFIED_GEOCODES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289269_USER_CITY_CODE');
        ELSIF csr_ed_city_tax_comp%FOUND THEN
          hr_h2pi_error.data_error(p_from_id   =>  l_state_code  ||
                                                   l_county_code ||
                                                   REPLACE(l_city_code,'U',0),
                                   p_table_name => 'HR_H2PI_US_MODIFIED_GEOCODES',
                                   p_message_level => 'FATAL',
                                   p_message_name  => 'HR_289235_ED_DATA_REMOVED');

          EXIT;
        ELSE
          NULL;
          EXIT;
        END IF;
      END LOOP;
    END LOOP;
  END IF;
  COMMIT;
  hr_utility.set_location('Leaving:'|| l_proc, 130);
EXCEPTION
  WHEN e_ed_more_then_two_ver_ahead THEN
    hr_utility.set_location(l_proc, 140);
    hr_h2pi_error.data_error(p_from_id       =>  '99999',
                             p_table_name    => 'HR_H2PI_US_MODIFIED_GEOCODES',
                             p_message_level => 'FATAL',
                             p_message_name  => 'HR_289235_ED_DATA_REMOVED');
    --RAISE;
  WHEN e_ud_more_then_two_ver_ahead THEN
    hr_utility.set_location(l_proc, 150);
    hr_h2pi_error.data_error(p_from_id       =>  '99999',
                             p_table_name    => 'HR_H2PI_US_MODIFIED_GEOCODES',
                             p_message_level => 'FATAL',
                             p_message_name  => 'HR_289235_ED_DATA_REMOVED');
    --RAISE;
  WHEN MAPPING_ID_MISSING THEN
    hr_utility.set_location(l_proc, 160);

END validate_geocode;

END hr_h2pi_validate;

/
