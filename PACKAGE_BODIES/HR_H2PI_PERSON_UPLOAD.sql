--------------------------------------------------------
--  DDL for Package Body HR_H2PI_PERSON_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_PERSON_UPLOAD" AS
/* $Header: hrh2pipe.pkb 120.0 2005/05/31 00:41:20 appldev noship $ */

g_eot      DATE := TRUNC(TO_DATE('4712/12/31', 'YYYY/MM/DD'));
g_package  VARCHAR2(33) := '  hr_h2pi_person_upload.';
MAPPING_ID_MISSING EXCEPTION;
PRAGMA EXCEPTION_INIT (MAPPING_ID_MISSING, -20010);
MAPPING_ID_INVALID EXCEPTION;
PERSON_ERROR EXCEPTION;

PROCEDURE calculate_datetrack_mode(p_ud_start_date     DATE,
                                   p_ud_end_date       DATE,
                                   p_ed_start_date     DATE,
                                   p_ed_end_date       DATE,
                                   p_records_same      BOOLEAN,
                                   p_future_records    BOOLEAN,
                                   p_update_mode   OUT NOCOPY VARCHAR2,
                                   p_delete_mode   OUT NOCOPY VARCHAR2) IS

l_proc            VARCHAR2(72) := g_package||'calculate_datetrack_mode';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  p_update_mode := NULL;
  p_delete_mode := 'X';

  IF p_ud_end_date > p_ed_end_date THEN
    hr_utility.set_location(l_proc, 20);
    p_delete_mode := 'DELETE_NEXT_CHANGE';
  ELSE
    IF p_ud_start_date = p_ed_start_date THEN
      hr_utility.set_location(l_proc, 30);
      IF NOT p_records_same THEN
        hr_utility.set_location(l_proc, 40);
        p_update_mode := 'CORRECTION';
      END IF;
    ELSE
      IF p_future_records THEN
        hr_utility.set_location(l_proc, 50);
        p_update_mode := 'UPDATE_CHANGE_INSERT';
      ELSE
        hr_utility.set_location(l_proc, 60);
        p_update_mode := 'UPDATE';
      END IF;
    END IF;
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 70);

END calculate_datetrack_mode;

FUNCTION  get_costing_id_flex_num RETURN NUMBER IS

l_proc  VARCHAR2(72) := g_package||'.get_costing_id_flex_num';
l_costing_id_flex_num    varchar2(150);

CURSOR csr_costing IS
  SELECT cost_allocation_structure
  FROM   per_business_groups
  WHERE  business_group_id =  hr_h2pi_upload.g_to_business_group_id;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  OPEN csr_costing;
  FETCH csr_costing INTO l_costing_id_flex_num;
  IF csr_costing%notfound then
     hr_utility.set_location(l_proc, 20);
  END IF;
  CLOSE csr_costing;
  hr_utility.set_location('Leaving:'|| l_proc, 30);
  RETURN to_number(l_costing_id_flex_num);
END;

PROCEDURE create_end_date_records(p_from_client_id NUMBER ) IS

l_proc            VARCHAR2(72) := g_package||'create_end_date_records';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  INSERT INTO hr_h2pi_assignments
             (assignment_id,
              effective_start_date,
              effective_end_date,
              last_upd_date,
              business_group_id,
              client_id,
              person_id,
              organization_id,
              primary_flag)
  SELECT asg1.assignment_id,
         asg1.end_date+1,
         g_eot,
         g_eot,
         asg.business_group_id,
         p_from_client_id,
         asg.person_id,
         -1,
         asg.primary_flag
  FROM  (SELECT asg2.assignment_id,
                MAX(asg2.effective_end_date) end_date
         FROM hr_h2pi_assignments asg2
         WHERE asg2.client_id = p_from_client_id
         GROUP BY asg2.person_id, asg2.assignment_id
         HAVING MAX(asg2.effective_end_date) <> g_eot) asg1,
         hr_h2pi_assignments asg
  WHERE  asg.assignment_id      = asg1.assignment_id
  AND    asg.client_id          = p_from_client_id
  AND    asg.effective_end_date = asg1.end_date
  AND    asg.primary_flag       = 'Y';
  INSERT INTO hr_h2pi_assignments
             (assignment_id,
              effective_start_date,
              effective_end_date,
              last_upd_date,
              business_group_id,
              client_id,
              person_id,
              organization_id,
              primary_flag)
  SELECT asg1.assignment_id,
         asg1.end_date+1,
         g_eot,
         g_eot,
         asg.business_group_id,
         p_from_client_id,
         asg.person_id,
         -1,
         asg.primary_flag
  FROM  (SELECT asg2.assignment_id,
                MAX(asg2.effective_end_date) end_date
         FROM hr_h2pi_assignments asg2
         WHERE asg2.client_id = p_from_client_id
         GROUP BY asg2.person_id, asg2.assignment_id
         HAVING MAX(asg2.effective_end_date) <> g_eot) asg1,
         hr_h2pi_assignments asg
  WHERE  asg.assignment_id      = asg1.assignment_id
  AND    asg.client_id          = p_from_client_id
  AND    asg.effective_end_date = asg1.end_date
  AND    asg.primary_flag       = 'N'
  AND NOT EXISTS (SELECT 1
                  FROM (SELECT sasg2.assignment_id,
                               MAX(sasg2.effective_end_date) end_date
                        FROM hr_h2pi_assignments sasg2
                        WHERE sasg2.client_id = p_from_client_id
                        GROUP BY sasg2.person_id, sasg2.assignment_id
                        HAVING MAX(sasg2.effective_end_date) = g_eot) sasg1,
                        hr_h2pi_assignments sasg
                  WHERE sasg.assignment_id      = sasg1.assignment_id
                  AND   sasg.client_id          = p_from_client_id
                  AND   sasg.effective_end_date = sasg1.end_date
                  AND   sasg.last_upd_date      = g_eot
                  AND   sasg.primary_flag       = 'Y'
                  AND   sasg.effective_start_date = asg.effective_end_date + 1
                  AND   sasg.person_id          = asg.person_id);

  hr_utility.set_location(l_proc, 40);
  INSERT INTO hr_h2pi_payment_methods
             (personal_payment_method_id,
              effective_start_date,
              effective_end_date,
              last_upd_date,
              business_group_id,
              client_id,
              person_id,
              assignment_id,
              org_payment_method_id)
    SELECT personal_payment_method_id,
           MAX(effective_end_date)+1,
           g_eot,
           g_eot,
           business_group_id,
           p_from_client_id,
           person_id,
           -1,
           -1
    FROM hr_h2pi_payment_methods
    WHERE client_id = p_from_client_id
    GROUP BY person_id, personal_payment_method_id,business_group_id
    HAVING MAX(effective_end_date) <> g_eot;

  hr_utility.set_location(l_proc, 50);
  INSERT INTO hr_h2pi_cost_allocations
             (cost_allocation_id,
              effective_start_date,
              effective_end_date,
              last_upd_date,
              business_group_id,
              client_id,
              person_id,
              assignment_id,
              proportion,
              id_flex_num,
              summary_flag,
              enabled_flag)
    SELECT cost_allocation_id,
           MAX(effective_end_date)+1,
           g_eot,
           g_eot,
           business_group_id,
           p_from_client_id,
           person_id,
           -1,
           -1,
           id_flex_num,
           summary_flag,
           enabled_flag
    FROM hr_h2pi_cost_allocations
    WHERE client_id  = p_from_client_id
    GROUP BY person_id, cost_allocation_id,business_group_id,
             id_flex_num,summary_flag,enabled_flag
    HAVING MAX(effective_end_date) <> g_eot;

  hr_utility.set_location(l_proc, 60);
  INSERT INTO hr_h2pi_element_entries
             (element_entry_id,
              effective_start_date,
              effective_end_date,
              last_upd_date,
              business_group_id,
              client_id,
              person_id,
              element_link_id,
              assignment_id,
              creator_type,
              entry_type)
    SELECT element_entry_id,
           MAX(effective_end_date)+1,
           g_eot,
           g_eot,
           business_group_id,
           p_from_client_id,
           person_id,
           -1,
           -1,
           'x',
           'x'
    FROM hr_h2pi_element_entries
    WHERE client_id = p_from_client_id
    AND   creator_type <> 'UT'
    GROUP BY person_id, element_entry_id,business_group_id
    HAVING MAX(effective_end_date) <> g_eot;

  hr_utility.set_location('Leaving:'|| l_proc, 100);

END create_end_date_records;


PROCEDURE remove_staging_table_data (p_from_client_id NUMBER) IS

BEGIN

  DELETE FROM hr_h2pi_employees
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_addresses
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_assignments
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_periods_of_service
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_locations
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_pay_bases
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_hr_organizations
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_organization_class
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_organization_info
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_payrolls
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_element_types
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_input_values
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_element_links
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_bg_and_gre
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_org_payment_methods
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_federal_tax_rules
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_state_tax_rules
  WHERE  client_id  = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_county_tax_rules
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_city_tax_rules
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_salaries
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_cost_allocations
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_payment_methods
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_element_names
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_element_entries
  WHERE  client_id = p_from_client_id
  AND status = 'C';

  DELETE FROM hr_h2pi_element_entry_values
  WHERE  client_id = p_from_client_id
  AND status = 'C';


  DELETE FROM hr_h2pi_bg_and_gre
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_payrolls
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_pay_bases
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_org_payment_methods
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_types
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_input_values
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_links
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_us_modified_geocodes
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_us_city_names
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_patch_status
  WHERE  client_id = p_from_client_id;

END;


PROCEDURE upload_person_level (p_from_client_id NUMBER) IS

CURSOR csr_people (p_bg_id NUMBER) IS
  SELECT DISTINCT person_id
  FROM hr_h2pi_employees
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_addresses
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_assignments
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_periods_of_service
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_salaries
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_payment_methods
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_cost_allocations
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_element_entries
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_federal_tax_rules
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_state_tax_rules
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_county_tax_rules
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
UNION
  SELECT DISTINCT person_id
  FROM hr_h2pi_city_tax_rules
  WHERE  (status IS NULL OR status <> 'C')
  AND    client_id = p_bg_id
ORDER BY person_id;

CURSOR csr_person_detail (p_per_id NUMBER) IS
  SELECT person_id id,
         effective_start_date eff_date,
         1 ord,
         'upload_person' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_EMPLOYEES
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT address_id id,
         date_from eff_date,
         2 ord,
         'upload_address' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_ADDRESSES
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT assignment_id id,
         effective_start_date eff_date,
         3 ord,
         'upload_assignment' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_ASSIGNMENTS
  WHERE  (status IS NULL OR status <> 'C')
  AND    primary_flag = 'Y'
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT assignment_id id,
         effective_start_date eff_date,
         4 ord,
         'upload_assignment' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_ASSIGNMENTS
  WHERE  (status IS NULL OR status <> 'C')
  AND    primary_flag = 'N'
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT period_of_service_id id,
         date_start eff_date,
         5 ord,
         'upload_period_of_service' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_PERIODS_OF_SERVICE
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT pay_proposal_id id,
         change_date eff_date,
         6 ord,
         'upload_salary' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_SALARIES
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT personal_payment_method_id id,
         effective_start_date eff_date,
         7 ord,
         'upload_payment_method' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_PAYMENT_METHODS
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT cost_allocation_id id,
         effective_start_date eff_date,
         8 ord,
         'upload_cost_allocation' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_COST_ALLOCATIONS
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND    client_id = p_from_client_id
  UNION
  SELECT element_entry_id id,
         effective_start_date eff_date,
         9 ord,
         'upload_element_entry' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_ELEMENT_ENTRIES
  WHERE  (status IS NULL OR status <> 'C')
  AND   creator_type <> 'UT'
  AND   person_id = p_per_id
  AND   client_id = p_from_client_id
  UNION
  SELECT emp_fed_tax_rule_id id,
         effective_start_date eff_date,
         10 ord,
         'upload_federal_tax_record' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_FEDERAL_TAX_RULES
  WHERE  (status IS NULL OR status <> 'C')
  AND   person_id = p_per_id
  AND   client_id = p_from_client_id
  UNION
  SELECT emp_state_tax_rule_id id,
         effective_start_date eff_date,
         11 ord,
         'upload_state_tax_record' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_STATE_TAX_RULES
  WHERE  (status IS NULL OR status <> 'C')
  AND   person_id = p_per_id
  AND   client_id = p_from_client_id
  UNION
  SELECT emp_county_tax_rule_id id,
         effective_start_date eff_date,
         12 ord,
         'upload_county_tax_record' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_COUNTY_TAX_RULES
  WHERE  (status IS NULL OR status <> 'C')
  AND     person_id = p_per_id
  AND   client_id = p_from_client_id
  UNION
  SELECT emp_city_tax_rule_id id,
         effective_start_date eff_date,
         13 ord,
         'upload_city_tax_record' fn_name,
         DECODE(last_upd_date, g_eot, 1, 2) sub_order
  FROM HR_H2PI_CITY_TAX_RULES
  WHERE  (status IS NULL OR status <> 'C')
  AND    person_id = p_per_id
  AND   client_id = p_from_client_id
  ORDER BY eff_date,
           ord,
           sub_order;

l_proc            VARCHAR2(72) := g_package||'upload_person_level';

l_from_client_id NUMBER;

l_csr_handle INTEGER;
l_sql_parse  VARCHAR2(2000);
l_csr_rows   INTEGER;
l_date_char  VARCHAR2(11);


BEGIN
  l_from_client_id := p_from_client_id;

  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_h2pi_person_upload.create_end_date_records(l_from_client_id);

  FOR v_per IN csr_people(l_from_client_id) LOOP

    hr_utility.set_location(l_proc, 20);
    SAVEPOINT person_start;

    BEGIN
      delete_address(l_from_client_id,
                     v_per.person_id);

      hr_utility.set_location(l_proc, 30);
      FOR v_per_det IN csr_person_detail(v_per.person_id) LOOP

        BEGIN

          hr_utility.set_location(l_proc, 40);
          l_date_char := TO_CHAR(v_per_det.eff_date, 'YYYY/MM/DD');
          l_sql_parse :=
            'BEGIN '||fnd_global.local_chr(10)||
               'hr_h2pi_person_upload.'||
                v_per_det.fn_name||'('||l_from_client_id||','||fnd_global.local_chr(10)||
               v_per_det.id||','||fnd_global.local_chr(10)||
               'TO_DATE('||''''||l_date_char||''''||
                 ','||''''||'YYYY/MM/DD'||''''||'));'||fnd_global.local_chr(10)||
            'END;';

          hr_utility.trace(l_sql_parse);
          l_csr_handle := dbms_sql.open_cursor;
          dbms_sql.parse(l_csr_handle,
                         l_sql_parse,
                         dbms_sql.native);
          l_csr_rows := dbms_sql.execute(l_csr_handle);
          dbms_sql.close_cursor(l_csr_handle);

        EXCEPTION
          WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
          hr_utility.set_location(l_proc, 50);
          RAISE PERSON_ERROR;
          WHEN MAPPING_ID_MISSING THEN
          hr_utility.set_location(l_proc, 60);
          RAISE PERSON_ERROR;
          WHEN MAPPING_ID_INVALID THEN
          hr_utility.set_location(l_proc, 70);
          RAISE PERSON_ERROR;
        END;

      END LOOP;

    upload_tax_percentage(p_from_client_id => p_from_client_id,
                          p_person_id => v_per.person_id);


    EXCEPTION
      WHEN PERSON_ERROR THEN
        hr_utility.set_location(l_proc, 60);
        COMMIT;
    END;

  END LOOP;

  IF NOT hr_h2pi_error.check_for_errors THEN
    hr_utility.set_location(l_proc, 70);
    remove_staging_table_data(l_from_client_id);
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 100);

  COMMIT;

END;


PROCEDURE upload_person (p_from_client_id NUMBER, --
                         p_person_id              NUMBER,
                         p_effective_start_date   DATE) IS

CURSOR csr_ud_person (p_per_id NUMBER,
                      p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_employees per
  WHERE  per.person_id  = p_per_id
  AND    per.client_id  = p_from_client_id
  AND    per.effective_start_date = p_esd;

CURSOR csr_ed_person (p_per_id NUMBER,
                      p_esd    DATE) IS
  SELECT per.person_type,
         per.effective_start_date,
         per.effective_end_date
  FROM   hr_h2pi_employees_v per
  WHERE  per.person_id = p_per_id
  AND    p_esd BETWEEN per.effective_start_date
                   AND per.effective_end_date;

CURSOR csr_ed_person_ovn (p_per_id NUMBER,
                          p_esd    DATE) IS
  SELECT per.object_version_number
  FROM   per_all_people_f per
  WHERE  per.person_id = p_per_id
  AND    p_esd BETWEEN per.effective_start_date
                   AND per.effective_end_date;


l_encoded_message VARCHAR2(200);

l_proc            VARCHAR2(72) := g_package||'upload_person';

v_ud_per                 hr_h2pi_employees%ROWTYPE;

l_ud_person_id            per_all_people_f.person_id%TYPE;
l_ud_assignment_id        per_all_assignments_f.assignment_id%TYPE;
l_ud_period_of_service_id per_periods_of_service.period_of_service_id%TYPE;

l_person_id                per_all_people_f.person_id%TYPE;
l_assignment_id            per_all_assignments_f.assignment_id%TYPE;
l_period_of_service_id     per_periods_of_service.period_of_service_id%TYPE;
l_person_type              per_person_types.system_person_type%TYPE;
l_ovn                      per_all_people_f.object_version_number%TYPE;
l_asg_ovn                  per_all_people_f.object_version_number%TYPE;
l_esd                      per_all_people_f.effective_start_date%TYPE;
l_eed                      per_all_people_f.effective_end_date%TYPE;
l_comment_id               per_all_people_f.comment_id%TYPE;
l_full_name                per_all_people_f.full_name%TYPE;
l_assignment_sequence      per_all_assignments_f.assignment_sequence%TYPE;
l_assignment_number        per_all_assignments_f.assignment_number%TYPE;
l_name_combination_warning BOOLEAN;
l_assign_payroll_warning   BOOLEAN;
l_orig_hire_warning        BOOLEAN;

l_max_eed                  per_all_people_f.effective_end_date%TYPE;
l_del_ovn                  per_all_people_f.object_version_number%TYPE;
l_del_esd                  per_all_people_f.effective_start_date%TYPE;
l_del_eed                  per_all_people_f.effective_end_date%TYPE;

l_records_same             BOOLEAN;
l_future_records           BOOLEAN;
l_update_mode              VARCHAR2(30);
l_delete_mode              VARCHAR2(30);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_person(p_person_id,
                     p_effective_start_date);
  FETCH csr_ud_person INTO v_ud_per;

  l_person_id := hr_h2pi_map.get_to_id
                    (p_table_name  => 'PER_ALL_PEOPLE_F',
                     p_from_id     => p_person_id);

  IF l_person_id = -1 THEN
    hr_utility.set_location(l_proc, 20);

    hr_employee_api.create_employee (
         p_hire_date               => v_ud_per.effective_start_date
        ,p_business_group_id       => hr_h2pi_upload.g_to_business_group_id
        ,p_last_name               => v_ud_per.last_name
        ,p_sex                     => v_ud_per.sex
        ,p_date_of_birth           => v_ud_per.date_of_birth
        ,p_email_address           => v_ud_per.email_address
        ,p_employee_number         => v_ud_per.employee_number
        ,p_expense_check_send_to_addres
                                   => v_ud_per.expense_check_send_to_address
        ,p_first_name                => v_ud_per.first_name
        ,p_marital_status            => v_ud_per.marital_status
        ,p_middle_names              => v_ud_per.middle_names
      --  ,p_nationality               => v_ud_per.nationality
        ,p_national_identifier       => v_ud_per.national_identifier
        ,p_registered_disabled_flag  => v_ud_per.registered_disabled_flag
        ,p_title                     => v_ud_per.title
        ,p_attribute_category        => v_ud_per.attribute_category
        ,p_attribute1                => v_ud_per.attribute1
        ,p_attribute2                => v_ud_per.attribute2
        ,p_attribute3                => v_ud_per.attribute3
        ,p_attribute4                => v_ud_per.attribute4
        ,p_attribute5                => v_ud_per.attribute5
        ,p_attribute6                => v_ud_per.attribute6
        ,p_attribute7                => v_ud_per.attribute7
        ,p_attribute8                => v_ud_per.attribute8
        ,p_attribute9                => v_ud_per.attribute9
        ,p_attribute10               => v_ud_per.attribute10
        ,p_attribute11               => v_ud_per.attribute11
        ,p_attribute12               => v_ud_per.attribute12
        ,p_attribute13               => v_ud_per.attribute13
        ,p_attribute14               => v_ud_per.attribute14
        ,p_attribute15               => v_ud_per.attribute15
        ,p_attribute16               => v_ud_per.attribute16
        ,p_attribute17               => v_ud_per.attribute17
        ,p_attribute18               => v_ud_per.attribute18
        ,p_attribute19               => v_ud_per.attribute19
        ,p_attribute20               => v_ud_per.attribute20
        ,p_attribute21               => v_ud_per.attribute21
        ,p_attribute22               => v_ud_per.attribute22
        ,p_attribute23               => v_ud_per.attribute23
        ,p_attribute24               => v_ud_per.attribute24
        ,p_attribute25               => v_ud_per.attribute25
        ,p_attribute26               => v_ud_per.attribute26
        ,p_attribute27               => v_ud_per.attribute27
        ,p_attribute28               => v_ud_per.attribute28
        ,p_attribute29               => v_ud_per.attribute29
        ,p_attribute30               => v_ud_per.attribute30
        ,p_per_information_category  => v_ud_per.per_information_category
        ,p_per_information1          => v_ud_per.per_information1
        ,p_per_information2          => v_ud_per.per_information2
        ,p_per_information3          => v_ud_per.per_information3
        ,p_per_information4          => v_ud_per.per_information4
        ,p_per_information5          => v_ud_per.per_information5
        ,p_per_information6          => v_ud_per.per_information6
        ,p_per_information7          => v_ud_per.per_information7
        ,p_per_information8          => v_ud_per.per_information8
        ,p_per_information9          => v_ud_per.per_information9
        ,p_per_information10         => v_ud_per.per_information10
        ,p_per_information11         => v_ud_per.per_information11
        ,p_per_information12         => v_ud_per.per_information12
        ,p_per_information13         => v_ud_per.per_information13
        ,p_per_information14         => v_ud_per.per_information14
        ,p_per_information15         => v_ud_per.per_information15
        ,p_per_information16         => v_ud_per.per_information16
        ,p_per_information17         => v_ud_per.per_information17
        ,p_per_information18         => v_ud_per.per_information18
        ,p_per_information19         => v_ud_per.per_information19
        ,p_per_information20         => v_ud_per.per_information20
        ,p_per_information21         => v_ud_per.per_information21
        ,p_per_information22         => v_ud_per.per_information22
        ,p_per_information23         => v_ud_per.per_information23
        ,p_per_information24         => v_ud_per.per_information24
        ,p_per_information25         => v_ud_per.per_information25
        ,p_per_information26         => v_ud_per.per_information26
        ,p_per_information27         => v_ud_per.per_information27
        ,p_per_information28         => v_ud_per.per_information28
        ,p_per_information29         => v_ud_per.per_information29
        ,p_per_information30         => v_ud_per.per_information30
        ,p_date_of_death             => v_ud_per.date_of_death
        ,p_correspondence_language   => v_ud_per.correspondence_language
        ,p_office_number             => v_ud_per.office_number
        ,p_pre_name_adjunct          => v_ud_per.pre_name_adjunct
        ,p_suffix                    => v_ud_per.suffix
        ,p_person_id                 => l_person_id
        ,p_assignment_id             => l_assignment_id
        ,p_per_object_version_number => l_ovn
        ,p_asg_object_version_number => l_asg_ovn
        ,p_per_effective_start_date  => l_esd
        ,p_per_effective_end_date    => l_eed
        ,p_full_name                 => l_full_name
        ,p_per_comment_id            => l_comment_id
        ,p_assignment_sequence       => l_assignment_sequence
        ,p_assignment_number         => l_assignment_number
        ,p_name_combination_warning  => l_name_combination_warning
        ,p_assign_payroll_warning    => l_assign_payroll_warning
        ,p_orig_hire_warning         => l_orig_hire_warning
        );

    hr_utility.set_location(l_proc, 30);
    hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PER_ALL_PEOPLE_F',
                       p_from_id    => p_person_id,
                       p_to_id      => l_person_id);

    SELECT asg.assignment_id
    INTO   l_ud_assignment_id
    FROM   hr_h2pi_assignments asg
    WHERE  asg.person_id            = v_ud_per.person_id
    AND    asg.client_id            = p_from_client_id
    AND    asg.effective_start_date = v_ud_per.effective_start_date
    AND    asg.primary_flag         = 'Y';

    hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PER_ALL_ASSIGNMENTS_F',
                       p_from_id    => l_ud_assignment_id,
                       p_to_id      => l_assignment_id);
    BEGIN
      SELECT pos.period_of_service_id
      INTO   l_ud_period_of_service_id
      FROM   hr_h2pi_periods_of_service pos
      WHERE  pos.person_id  = v_ud_per.person_id
      AND    pos.client_id  = p_from_client_id
      AND    pos.date_start = v_ud_per.effective_start_date;

      SELECT pos.period_of_service_id
      INTO   l_period_of_service_id
      FROM   hr_h2pi_periods_of_service_v pos
      WHERE  pos.person_id  = l_person_id
      AND    pos.date_start = l_esd;

      hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PER_PERIODS_OF_SERVICE',
                       p_from_id    => l_ud_period_of_service_id,
                       p_to_id      => l_period_of_service_id);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;

  ELSE

    BEGIN
      hr_utility.set_location(l_proc, 50);
      OPEN csr_ed_person(l_person_id,
                         v_ud_per.effective_start_date);
      FETCH csr_ed_person
      INTO  l_person_type,
            l_esd,
            l_eed;
      IF csr_ed_person%NOTFOUND THEN
        hr_utility.set_location(l_proc, 60);
        CLOSE csr_ed_person;
        ROLLBACK;
        hr_h2pi_error.data_error
               (p_from_id       => l_person_id,
                p_table_name    => 'HR_H2PI_EMPLOYEES',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
        COMMIT;
        RAISE MAPPING_ID_INVALID;
      ELSE
        hr_utility.set_location(l_proc, 70);
        CLOSE csr_ed_person;
      END IF;

      OPEN csr_ed_person_ovn(l_person_id,
                             v_ud_per.effective_start_date);
      FETCH csr_ed_person_ovn
      INTO  l_ovn;
      CLOSE csr_ed_person_ovn;
    END;

    IF v_ud_per.person_type = l_person_type THEN

      hr_utility.set_location(l_proc, 80);
      l_delete_mode := 'DELETE_NEXT_CHANGE';
      LOOP
        hr_utility.set_location(l_proc, 90);
        l_records_same := FALSE;

        SELECT MAX(per.effective_end_date)
        INTO   l_max_eed
        FROM   per_all_people_f per
        WHERE  per.person_id = l_person_id;

        IF l_max_eed > l_eed THEN
          hr_utility.set_location(l_proc, 100);
          l_future_records := TRUE;
        END IF;

        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_per.effective_start_date
            ,p_ud_end_date    => v_ud_per.effective_end_date
            ,p_ed_start_date  => l_esd
            ,p_ed_end_date    => l_eed
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);

        EXIT WHEN l_delete_mode = 'X';

        IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

          hr_utility.set_location(l_proc, 110);
          per_per_del.del(p_person_id             => l_person_id
                         ,p_effective_start_date  => l_del_esd
                         ,p_effective_end_date    => l_del_eed
                         ,p_object_version_number => l_ovn
                         ,p_effective_date        => l_eed
                         ,p_datetrack_mode        => 'DELETE_NEXT_CHANGE');

          OPEN csr_ed_person(l_person_id,
                             v_ud_per.effective_start_date);
          FETCH csr_ed_person
          INTO  l_person_type,
                l_esd,
                l_eed;
          CLOSE csr_ed_person;

        END IF;

      END LOOP;

      hr_utility.set_location(l_proc, 120);
      hr_person_api.update_person(
             p_effective_date           => v_ud_per.effective_start_date
            ,p_datetrack_update_mode    => l_update_mode
            ,p_person_id                => l_person_id
            ,p_object_version_number    => l_ovn
            ,p_last_name                => v_ud_per.last_name
            ,p_date_of_birth            => v_ud_per.date_of_birth
            ,p_email_address            => v_ud_per.email_address
            ,p_employee_number          => v_ud_per.employee_number
            ,p_expense_check_send_to_addres
                                 => v_ud_per.expense_check_send_to_address
            ,p_first_name               => v_ud_per.first_name
            ,p_marital_status           => v_ud_per.marital_status
            ,p_middle_names             => v_ud_per.middle_names
          --  ,p_nationality              => v_ud_per.nationality
            ,p_national_identifier      => v_ud_per.national_identifier
            ,p_registered_disabled_flag	=> v_ud_per.registered_disabled_flag
            ,p_sex                      => v_ud_per.sex
            ,p_title                    => v_ud_per.title
            ,p_attribute_category       => v_ud_per.attribute_category
            ,p_attribute1               => v_ud_per.attribute1
            ,p_attribute2               => v_ud_per.attribute2
            ,p_attribute3               => v_ud_per.attribute3
            ,p_attribute4               => v_ud_per.attribute4
            ,p_attribute5               => v_ud_per.attribute5
            ,p_attribute6               => v_ud_per.attribute6
            ,p_attribute7               => v_ud_per.attribute7
            ,p_attribute8               => v_ud_per.attribute8
            ,p_attribute9               => v_ud_per.attribute9
            ,p_attribute10              => v_ud_per.attribute10
            ,p_attribute11              => v_ud_per.attribute11
            ,p_attribute12              => v_ud_per.attribute12
            ,p_attribute13              => v_ud_per.attribute13
            ,p_attribute14              => v_ud_per.attribute14
            ,p_attribute15              => v_ud_per.attribute15
            ,p_attribute16              => v_ud_per.attribute16
            ,p_attribute17              => v_ud_per.attribute17
            ,p_attribute18              => v_ud_per.attribute18
            ,p_attribute19              => v_ud_per.attribute19
            ,p_attribute20              => v_ud_per.attribute20
            ,p_attribute21              => v_ud_per.attribute21
            ,p_attribute22              => v_ud_per.attribute22
            ,p_attribute23              => v_ud_per.attribute23
            ,p_attribute24              => v_ud_per.attribute24
            ,p_attribute25              => v_ud_per.attribute25
            ,p_attribute26              => v_ud_per.attribute26
            ,p_attribute27              => v_ud_per.attribute27
            ,p_attribute28              => v_ud_per.attribute28
            ,p_attribute29              => v_ud_per.attribute29
            ,p_attribute30              => v_ud_per.attribute30
            ,p_per_information_category	=> v_ud_per.per_information_category
            ,p_per_information1	        => v_ud_per.per_information1
            ,p_per_information2	        => v_ud_per.per_information2
            ,p_per_information3	        => v_ud_per.per_information3
            ,p_per_information4	        => v_ud_per.per_information4
            ,p_per_information5	        => v_ud_per.per_information5
            ,p_per_information6	        => v_ud_per.per_information6
            ,p_per_information7	        => v_ud_per.per_information7
            ,p_per_information8	        => v_ud_per.per_information8
            ,p_per_information9	        => v_ud_per.per_information9
            ,p_per_information10        => v_ud_per.per_information10
            ,p_per_information11        => v_ud_per.per_information11
            ,p_per_information12        => v_ud_per.per_information12
            ,p_per_information13        => v_ud_per.per_information13
            ,p_per_information14        => v_ud_per.per_information14
            ,p_per_information15        => v_ud_per.per_information15
            ,p_per_information16        => v_ud_per.per_information16
            ,p_per_information17        => v_ud_per.per_information17
            ,p_per_information18        => v_ud_per.per_information18
            ,p_per_information19        => v_ud_per.per_information19
            ,p_per_information20        => v_ud_per.per_information20
            ,p_per_information21        => v_ud_per.per_information21
            ,p_per_information22        => v_ud_per.per_information22
            ,p_per_information23        => v_ud_per.per_information23
            ,p_per_information24        => v_ud_per.per_information24
            ,p_per_information25        => v_ud_per.per_information25
            ,p_per_information26        => v_ud_per.per_information26
            ,p_per_information27        => v_ud_per.per_information27
            ,p_per_information28        => v_ud_per.per_information28
            ,p_per_information29        => v_ud_per.per_information29
            ,p_per_information30        => v_ud_per.per_information30
            ,p_date_of_death	        => v_ud_per.date_of_death
            ,p_correspondence_language	=> v_ud_per.correspondence_language
            ,p_office_number      	=> v_ud_per.office_number
            ,p_pre_name_adjunct	        => v_ud_per.pre_name_adjunct
            ,p_suffix	                => v_ud_per.suffix
            ,p_effective_start_date     => l_esd
            ,p_effective_end_date       => l_eed
            ,p_full_name                => l_full_name
            ,p_comment_id               => l_comment_id
            ,p_name_combination_warning => l_name_combination_warning
            ,p_assign_payroll_warning   => l_assign_payroll_warning
            ,p_orig_hire_warning        => l_orig_hire_warning
            );

    ELSE

      IF v_ud_per.person_type = 'EMP' THEN

        hr_utility.set_location(l_proc, 130);
        hr_employee_api.re_hire_ex_employee(
           p_hire_date	               => v_ud_per.effective_start_date
          ,p_person_id                 => l_person_id
          ,p_per_object_version_number => l_ovn
          ,p_rehire_reason             => v_ud_per.rehire_reason
          ,p_assignment_id	       => l_assignment_id
          ,p_asg_object_version_number => l_asg_ovn
          ,p_per_effective_start_date  => l_esd
          ,p_per_effective_end_date    => l_eed
          ,p_assignment_sequence       => l_assignment_sequence
          ,p_assignment_number         => l_assignment_number
          ,p_assign_payroll_warning    => l_assign_payroll_warning
           );

        hr_utility.set_location(l_proc, 140);
        SELECT asg.assignment_id
        INTO   l_ud_assignment_id
        FROM   hr_h2pi_assignments asg
        WHERE  asg.person_id            = v_ud_per.person_id
        AND    asg.client_id            = p_from_client_id
        AND    asg.effective_start_date = v_ud_per.effective_start_date
        AND    asg.primary_flag         = 'Y';

        hr_h2pi_map.create_id_mapping
                        (p_table_name => 'PER_ALL_ASSIGNMENTS_F',
                         p_from_id    => l_ud_assignment_id,
                         p_to_id      => l_assignment_id);

        BEGIN
          hr_utility.set_location(l_proc, 150);
          SELECT pos.period_of_service_id
          INTO   l_ud_period_of_service_id
          FROM   hr_h2pi_periods_of_service pos
          WHERE  pos.person_id  = v_ud_per.person_id
          AND    pos.client_id  = p_from_client_id
          AND    pos.date_start = v_ud_per.effective_start_date ;

          SELECT pos.period_of_service_id
          INTO   l_period_of_service_id
          FROM   hr_h2pi_periods_of_service_v pos
          WHERE  pos.person_id  = l_person_id
          AND    pos.date_start = l_esd ;

          hr_h2pi_map.create_id_mapping
                        (p_table_name => 'PER_PERIODS_OF_SERVICE',
                         p_from_id    => l_ud_period_of_service_id,
                         p_to_id      => l_period_of_service_id);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN NULL;
        END;

      ELSE

        hr_utility.set_location(l_proc, 160);
        terminate_person
            (p_from_client_id => p_from_client_id,
             p_person_id              => v_ud_per.person_id,
             p_effective_start_date   => v_ud_per.effective_start_date);

      END IF;

    END IF;
  END IF;

  hr_utility.set_location(l_proc, 170);
  UPDATE hr_h2pi_employees per
  SET status = 'C'
  WHERE per.person_id = v_ud_per.person_id
  AND   per.client_id = p_from_client_id
  AND   per.effective_start_date = v_ud_per.effective_start_date
  AND   per.effective_end_date   = v_ud_per.effective_end_date;

  CLOSE csr_ud_person;
  hr_utility.set_location('Leaving:'|| l_proc, 180);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 200);
    l_encoded_message := fnd_message.get_encoded;
    hr_utility.set_location(l_encoded_message, 200);
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_per.person_id,
                p_table_name           => 'HR_H2PI_EMPLOYEES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


PROCEDURE terminate_person(p_from_client_id NUMBER,
                           p_person_id              NUMBER,
                           p_effective_start_date   DATE) IS

CURSOR csr_ud_periods_of_service(p_per_id NUMBER,
                                 p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_periods_of_service pos
  WHERE  pos.person_id = p_per_id
  AND    pos.client_id = p_from_client_id
  AND    pos.actual_termination_date = p_esd - 1;

CURSOR csr_ed_periods_of_service(p_pos_id NUMBER) IS
  SELECT pos.object_version_number,
         pos.actual_termination_date,
         pos.final_process_date
  FROM   per_periods_of_service pos
  WHERE  pos.period_of_service_id = p_pos_id;

l_proc            VARCHAR2(72) := g_package||'terminate_person';

l_encoded_message VARCHAR2(200);

v_ud_pos                  hr_h2pi_periods_of_service%ROWTYPE;

l_period_of_service_id    per_periods_of_service.period_of_service_id%TYPE;
l_ovn                     per_periods_of_service.object_version_number%TYPE;
l_actual_termination_date per_periods_of_service.actual_termination_date%TYPE;
l_final_process_date      per_periods_of_service.final_process_date%TYPE;

l_supervisor_warning         BOOLEAN;
l_event_warning              BOOLEAN;
l_interview_warning          BOOLEAN;
l_review_warning             BOOLEAN;
l_recruiter_warning          BOOLEAN;
l_asg_future_changes_warning BOOLEAN;
l_entries_changed_warning    VARCHAR2(1);
l_pay_proposal_warning       BOOLEAN;
l_dod_warning                BOOLEAN;
l_org_now_no_manager_warning BOOLEAN;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_periods_of_service(p_person_id,
                                 p_effective_start_date);
  FETCH csr_ud_periods_of_service INTO v_ud_pos;
  CLOSE csr_ud_periods_of_service;

  l_period_of_service_id := hr_h2pi_map.get_to_id
                              (p_table_name  => 'PER_PERIODS_OF_SERVICE',
                               p_from_id     => v_ud_pos.period_of_service_id,
                               p_report_error => TRUE);

  OPEN csr_ed_periods_of_service(l_period_of_service_id);
  FETCH csr_ed_periods_of_service
  INTO  l_ovn,
        l_actual_termination_date,
        l_final_process_date;
  CLOSE csr_ed_periods_of_service;

  IF (l_actual_termination_date IS NULL) AND
     (v_ud_pos.actual_termination_date IS NOT NULL) THEN

    hr_utility.set_location(l_proc, 30);
    hr_ex_employee_api.actual_termination_emp(
            p_effective_date             => v_ud_pos.actual_termination_date
           ,p_period_of_service_id       => l_period_of_service_id
           ,p_object_version_number	 => l_ovn
           ,p_actual_termination_date	 => v_ud_pos.actual_termination_date
           ,p_last_standard_process_date => v_ud_pos.last_standard_process_date
           ,p_leaving_reason             => v_ud_pos.leaving_reason
           ,p_supervisor_warning         => l_supervisor_warning
           ,p_event_warning              => l_event_warning
           ,p_interview_warning          => l_interview_warning
           ,p_review_warning             => l_review_warning
           ,p_recruiter_warning          => l_recruiter_warning
           ,p_asg_future_changes_warning => l_asg_future_changes_warning
           ,p_entries_changed_warning    => l_entries_changed_warning
           ,p_pay_proposal_warning       => l_pay_proposal_warning
           ,p_dod_warning                => l_dod_warning
           );

  END IF;

  IF (l_final_process_date IS NULL) AND
     (v_ud_pos.actual_termination_date = v_ud_pos.final_process_date) THEN

    hr_utility.set_location(l_proc, 40);
    hr_ex_employee_api.final_process_emp(
             p_period_of_service_id       => l_period_of_service_id
            ,p_object_version_number      => l_ovn
            ,p_final_process_date         => v_ud_pos.final_process_date
            ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
            ,p_asg_future_changes_warning => l_asg_future_changes_warning
            ,p_entries_changed_warning    => l_entries_changed_warning
            );

  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 50);

END;


PROCEDURE delete_address (p_from_client_id NUMBER,
                          p_person_id              NUMBER) IS

CURSOR csr_ud_address (p_adr_id NUMBER) IS
  SELECT address_id,
         date_from,
         date_to
  FROM   hr_h2pi_addresses adr
  WHERE  adr.address_id = p_adr_id
  AND    adr.client_id = p_from_client_id
  AND    (adr.status IS NULL OR adr.status <> 'C');

CURSOR csr_ed_addresses (p_per_id NUMBER) IS
  SELECT address_id,
         object_version_number,
         date_from,
         date_to
  FROM   per_addresses adr
  WHERE  adr.person_id = p_per_id;

l_proc            VARCHAR2(72) := g_package||'delete_address';

l_encoded_message VARCHAR2(200);

l_person_id      per_addresses.person_id%TYPE;
l_ud_address_id  per_addresses.address_id%TYPE;
l_ud_date_from   per_addresses.date_from%TYPE;
l_ud_date_to     per_addresses.date_to%TYPE;
v_ed_adr         hr_h2pi_addresses%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  l_person_id := hr_h2pi_map.get_to_id
                      (p_table_name   => 'PER_ALL_PEOPLE_F',
                       p_from_id      => p_person_id);

  IF l_person_id <> -1 THEN

    FOR v_ed_adr IN csr_ed_addresses(l_person_id) LOOP
      hr_utility.set_location(l_proc, 20);
      l_ud_address_id := hr_h2pi_map.get_from_id
                             (p_table_name   => 'PER_ADDRESSES',
                              p_to_id        => v_ed_adr.address_id);

      IF l_ud_address_id <> -1 THEN
        hr_utility.set_location(l_proc, 30);
        OPEN csr_ud_address(l_ud_address_id);
        FETCH csr_ud_address INTO l_ud_address_id,
                                  l_ud_date_from,
                                  l_ud_date_to;
        IF (csr_ud_address%FOUND                AND
           (v_ed_adr.date_from <> l_ud_date_from OR
            v_ed_adr.date_to   <> l_ud_date_to))  THEN

          hr_utility.set_location(l_proc, 40);
          per_add_del.del
                 (p_address_id            => v_ed_adr.address_id,
                  p_object_version_number => v_ed_adr.object_version_number);

          DELETE FROM hr_h2pi_id_mapping
          WHERE table_name           = 'PER_ADDRESSES'
          AND   to_id                = v_ed_adr.address_id
          AND   to_business_group_id = hr_h2pi_upload.g_to_business_group_id;

        END IF;
        CLOSE csr_ud_address;
      END IF;
    END LOOP;
  END IF;
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 60);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => l_ud_address_id,
                p_table_name           => 'HR_H2PI_ADDRESSES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


PROCEDURE upload_address (p_from_client_id NUMBER,
                          p_address_id             NUMBER,
                          p_effective_start_date   DATE) IS

CURSOR csr_ud_address (p_adr_id NUMBER) IS
  SELECT *
  FROM   hr_h2pi_addresses adr
  WHERE  adr.address_id = p_adr_id
  AND    adr.client_id  = p_from_client_id;

CURSOR csr_ed_address (p_adr_id NUMBER) IS
  SELECT object_version_number
  FROM   per_addresses adr
  WHERE  adr.address_id = p_adr_id;

l_proc            VARCHAR2(72) := g_package||'upload_address';

l_encoded_message VARCHAR2(200);

l_person_id             per_addresses.person_id%TYPE;
l_address_id            per_addresses.address_id%TYPE;
l_ovn                   per_addresses.object_version_number%TYPE;
v_ud_adr                hr_h2pi_addresses%ROWTYPE;
l_per_start_date        per_all_people_f.effective_start_date%TYPE;
l_date_from             per_addresses.date_from%TYPE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_address(p_address_id);
  FETCH csr_ud_address INTO v_ud_adr;

  l_person_id := hr_h2pi_map.get_to_id
                      (p_table_name   => 'PER_ALL_PEOPLE_F',
                       p_from_id      => v_ud_adr.person_id,
                       p_report_error => TRUE);

  hr_utility.set_location(l_proc, 20);
  l_address_id := hr_h2pi_map.get_to_id
                      (p_table_name   => 'PER_ADDRESSES',
                       p_from_id      => v_ud_adr.address_id);

  IF l_address_id = -1 THEN
    hr_utility.set_location(l_proc, 30);
    /*
     * Check that the employee exists for the date range
     */
    SELECT MIN(per.effective_start_date)
    INTO   l_per_start_date
    FROM   per_all_people_f per
    WHERE  per.person_id = l_person_id;
    IF NVL(v_ud_adr.date_to, l_per_start_date) >= l_per_start_date THEN
      IF v_ud_adr.date_from < l_per_start_date THEN
        l_date_from := l_per_start_date;
      ELSE
        l_date_from := v_ud_adr.date_from;
      END IF;
      hr_person_address_api.create_person_address(
               p_effective_date          => v_ud_adr.date_from
              ,p_pradd_ovlapval_override => FALSE
              ,p_person_id               => l_person_id
              ,p_primary_flag            => 'Y'
              ,p_style                   => v_ud_adr.style
              ,p_date_from               => l_date_from
              ,p_date_to                 => v_ud_adr.date_to
             -- ,p_address_type            => v_ud_adr.address_type
              ,p_address_line1           => v_ud_adr.address_line1
              ,p_address_line2           => v_ud_adr.address_line2
              ,p_address_line3           => v_ud_adr.address_line3
              ,p_town_or_city            => v_ud_adr.town_or_city
              ,p_region_1	         => v_ud_adr.region_1
              ,p_region_2	         => v_ud_adr.region_2
              ,p_region_3	         => v_ud_adr.region_3
              ,p_postal_code             => v_ud_adr.postal_code
              ,p_country                 => v_ud_adr.country
              ,p_telephone_number_1      => v_ud_adr.telephone_number_1
              ,p_telephone_number_2      => v_ud_adr.telephone_number_2
              ,p_telephone_number_3      => v_ud_adr.telephone_number_3
              ,p_add_information17       => v_ud_adr.add_information17
              ,p_add_information18       => v_ud_adr.add_information18
              ,p_add_information19       => v_ud_adr.add_information19
              ,p_add_information20       => v_ud_adr.add_information20
              ,p_addr_attribute_category => v_ud_adr.addr_attribute_category
              ,p_addr_attribute1         => v_ud_adr.addr_attribute1
              ,p_addr_attribute2         => v_ud_adr.addr_attribute2
              ,p_addr_attribute3         => v_ud_adr.addr_attribute3
              ,p_addr_attribute4         => v_ud_adr.addr_attribute4
              ,p_addr_attribute5         => v_ud_adr.addr_attribute5
              ,p_addr_attribute6         => v_ud_adr.addr_attribute6
              ,p_addr_attribute7         => v_ud_adr.addr_attribute7
              ,p_addr_attribute8         => v_ud_adr.addr_attribute8
              ,p_addr_attribute9         => v_ud_adr.addr_attribute9
              ,p_addr_attribute10        => v_ud_adr.addr_attribute10
              ,p_addr_attribute11        => v_ud_adr.addr_attribute11
              ,p_addr_attribute12        => v_ud_adr.addr_attribute12
              ,p_addr_attribute13        => v_ud_adr.addr_attribute13
              ,p_addr_attribute14        => v_ud_adr.addr_attribute14
              ,p_addr_attribute15        => v_ud_adr.addr_attribute15
              ,p_addr_attribute16        => v_ud_adr.addr_attribute16
              ,p_addr_attribute17        => v_ud_adr.addr_attribute17
              ,p_addr_attribute18        => v_ud_adr.addr_attribute18
              ,p_addr_attribute19        => v_ud_adr.addr_attribute19
              ,p_addr_attribute20        => v_ud_adr.addr_attribute20
              ,p_address_id              => l_address_id
              ,p_object_version_number   => l_ovn
              );

      hr_utility.set_location(l_proc, 40);
      hr_h2pi_map.create_id_mapping
                     (p_table_name => 'PER_ADDRESSES',
                      p_from_id    => v_ud_adr.address_id,
                      p_to_id      => l_address_id);
    END IF;
  ELSE
    hr_utility.set_location(l_proc, 50);
    OPEN csr_ed_address(l_address_id);
    FETCH csr_ed_address INTO l_ovn;
    IF csr_ed_address%NOTFOUND THEN
      hr_utility.set_location(l_proc, 60);
      CLOSE csr_ed_address;
      ROLLBACK;
      hr_utility.set_location(l_proc, 70);
      hr_h2pi_error.data_error
           (p_from_id       => l_address_id,
            p_table_name    => 'HR_H2PI_ADDRESSES',
            p_message_level => 'FATAL',
            p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
      COMMIT;
      RAISE MAPPING_ID_INVALID;
    ELSE
      CLOSE csr_ed_address;
    END IF;

    hr_utility.set_location(l_proc, 80);
    hr_person_address_api.update_person_address(
             p_effective_date	           => v_ud_adr.date_from
            ,p_address_id                  => l_address_id
            ,p_object_version_number       => l_ovn
            ,p_date_from                   => v_ud_adr.date_from
            ,p_date_to                     => v_ud_adr.date_to
          --  ,p_address_type                => v_ud_adr.address_type
            ,p_address_line1               => v_ud_adr.address_line1
            ,p_address_line2               => v_ud_adr.address_line2
            ,p_address_line3               => v_ud_adr.address_line3
            ,p_town_or_city                => v_ud_adr.town_or_city
            ,p_region_1	                   => v_ud_adr.region_1
            ,p_region_2	                   => v_ud_adr.region_2
            ,p_region_3	                   => v_ud_adr.region_3
            ,p_postal_code                 => v_ud_adr.postal_code
            ,p_country	                   => v_ud_adr.country
            ,p_telephone_number_1          => v_ud_adr.telephone_number_1
            ,p_telephone_number_2          => v_ud_adr.telephone_number_2
            ,p_telephone_number_3          => v_ud_adr.telephone_number_3
            ,p_add_information17           => v_ud_adr.add_information17
            ,p_add_information18           => v_ud_adr.add_information18
            ,p_add_information19           => v_ud_adr.add_information19
            ,p_add_information20           => v_ud_adr.add_information20
            ,p_addr_attribute_category     => v_ud_adr.addr_attribute_category
            ,p_addr_attribute1             => v_ud_adr.addr_attribute1
            ,p_addr_attribute2             => v_ud_adr.addr_attribute2
            ,p_addr_attribute3             => v_ud_adr.addr_attribute3
            ,p_addr_attribute4             => v_ud_adr.addr_attribute4
            ,p_addr_attribute5             => v_ud_adr.addr_attribute5
            ,p_addr_attribute6             => v_ud_adr.addr_attribute6
            ,p_addr_attribute7             => v_ud_adr.addr_attribute7
            ,p_addr_attribute8             => v_ud_adr.addr_attribute8
            ,p_addr_attribute9             => v_ud_adr.addr_attribute9
            ,p_addr_attribute10            => v_ud_adr.addr_attribute10
            ,p_addr_attribute11            => v_ud_adr.addr_attribute11
            ,p_addr_attribute12            => v_ud_adr.addr_attribute12
            ,p_addr_attribute13            => v_ud_adr.addr_attribute13
            ,p_addr_attribute14            => v_ud_adr.addr_attribute14
            ,p_addr_attribute15            => v_ud_adr.addr_attribute15
            ,p_addr_attribute16            => v_ud_adr.addr_attribute16
            ,p_addr_attribute17            => v_ud_adr.addr_attribute17
            ,p_addr_attribute18            => v_ud_adr.addr_attribute18
            ,p_addr_attribute19            => v_ud_adr.addr_attribute19
            ,p_addr_attribute20            => v_ud_adr.addr_attribute20
            );
  END IF;

  hr_utility.set_location(l_proc, 90);
  UPDATE hr_h2pi_addresses adr
  SET status = 'C'
  WHERE  adr.address_id = v_ud_adr.address_id
  AND    adr.client_id  = p_from_client_id;
  CLOSE csr_ud_address;

  hr_utility.set_location('Leaving:'|| l_proc, 100);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 110);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_adr.address_id,
                p_table_name           => 'HR_H2PI_ADDRESSES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


PROCEDURE upload_assignment (p_from_client_id NUMBER,
                             p_assignment_id          NUMBER,
                             p_effective_start_date   DATE) IS

CURSOR csr_ud_assignment (p_asg_id NUMBER,
                          p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_assignments asg
  WHERE  asg.assignment_id        = p_asg_id
  AND    asg.client_id            = p_from_client_id
  AND    asg.effective_start_date = p_esd;

CURSOR csr_ed_assignment (p_asg_id NUMBER,
                          p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_assignments_v asg
  WHERE  asg.assignment_id = p_asg_id
  AND    p_esd BETWEEN asg.effective_start_date
                   AND asg.effective_end_date;

CURSOR csr_ed_assignment_ovn (p_asg_id NUMBER,
                              p_esd    DATE) IS
  SELECT asg.object_version_number
  FROM   per_all_assignments_f asg
  WHERE  asg.assignment_id = p_asg_id
  AND    p_esd BETWEEN asg.effective_start_date
                   AND asg.effective_end_date;

CURSOR csr_ed_periods_of_service(p_asg_id NUMBER,
                                 p_esd    DATE) IS
  SELECT pos.object_version_number,
         pos.period_of_service_id
  FROM   per_all_assignments_f  asg,
         per_all_people_f       per,
         per_periods_of_service pos
  WHERE  asg.assignment_id = p_asg_id
  AND    p_esd BETWEEN asg.effective_start_date
                   AND asg.effective_end_date
  AND    asg.person_id     = per.person_id
  AND    p_esd BETWEEN per.effective_start_date
                   AND per.effective_end_date
  AND    per.person_id     = pos.person_id
  AND    pos.actual_termination_date = per.effective_start_date - 1;

CURSOR csr_state_tax_rule (p_asg_id NUMBER,
                           p_date   DATE) IS
  SELECT emp_state_tax_rule_id,
         jurisdiction_code
  FROM   hr_h2pi_state_tax_rules_v
  WHERE  assignment_id = p_asg_id
  AND    p_date BETWEEN effective_start_date
                    AND effective_end_date;

CURSOR csr_county_tax_rule (p_asg_id NUMBER,
                            p_date   DATE) IS
  SELECT emp_county_tax_rule_id,
         jurisdiction_code
  FROM   hr_h2pi_county_tax_rules_v
  WHERE  assignment_id = p_asg_id
  AND    p_date BETWEEN effective_start_date
                    AND effective_end_date;

CURSOR csr_city_tax_rule (p_asg_id NUMBER,
                          p_date   DATE) IS
  SELECT emp_city_tax_rule_id,
         jurisdiction_code
  FROM   hr_h2pi_city_tax_rules_v
  WHERE  assignment_id = p_asg_id
  AND    p_date BETWEEN effective_start_date
                    AND effective_end_date;

l_encoded_message VARCHAR2(200);

l_proc            VARCHAR2(72) := g_package||'upload_assignment';

v_ud_asg                 hr_h2pi_assignments%ROWTYPE;
v_ed_asg                 hr_h2pi_assignments_v%ROWTYPE;
v_ud_pos                 hr_h2pi_periods_of_service%ROWTYPE;

l_person_id                per_all_people_f.person_id%TYPE;
l_assignment_id            per_all_assignments_f.assignment_id%TYPE;
l_period_of_service_id     per_periods_of_service.period_of_service_id%TYPE;
l_ovn                      per_all_people_f.object_version_number%TYPE;
l_pos_ovn                  per_all_people_f.object_version_number%TYPE;
l_esd                      per_all_people_f.effective_start_date%TYPE;
l_eed                      per_all_people_f.effective_end_date%TYPE;
l_assignment_sequence      per_all_assignments_f.assignment_sequence%TYPE;
l_assignment_number        per_all_assignments_f.assignment_number%TYPE;

l_max_eed                  per_all_assignments_f.effective_end_date%TYPE;
l_del_ovn                  per_all_assignments_f.object_version_number%TYPE;
l_del_esd                  per_all_assignments_f.effective_start_date%TYPE;
l_del_eed                  per_all_assignments_f.effective_end_date%TYPE;
l_val_esd                  per_all_assignments_f.effective_start_date%TYPE;
l_val_eed                  per_all_assignments_f.effective_end_date%TYPE;
l_business_group_id        per_all_assignments_f.business_group_id%TYPE;

l_records_same             BOOLEAN;
l_future_records           BOOLEAN;
l_update_mode              VARCHAR2(30);
l_delete_mode              VARCHAR2(30);

l_org_now_no_manager_warning BOOLEAN;
l_asg_future_changes_warning BOOLEAN;
l_entries_changed_warning    VARCHAR2(1);
l_pay_proposal_warning       BOOLEAN;
l_group_name                 VARCHAR2(100);
l_concatenated_segments      VARCHAR2(2000);
l_soft_coding_keyflex_id     per_all_assignments_f.soft_coding_keyflex_id%TYPE;
l_people_group_id            per_all_assignments_f.people_group_id%TYPE;
l_comment_id                 per_all_assignments_f.comment_id%TYPE;
l_other_manager_warning      BOOLEAN;
l_no_manager_warning         BOOLEAN;
l_concat_segments            hr_soft_coding_keyflex.concatenated_segments%TYPE;
l_special_ceiling_step_id   per_all_assignments_f.special_ceiling_step_id%TYPE;
l_spp_delete_warning         BOOLEAN;
l_tax_district_changed_warning BOOLEAN;

l_organization_id     per_all_assignments_f.organization_id%TYPE;
l_payroll_id          per_all_assignments_f.payroll_id%TYPE;
l_location_id         per_all_assignments_f.location_id%TYPE;
l_pay_basis_id        per_all_assignments_f.pay_basis_id%TYPE;
l_gre_id              NUMBER(15);

l_final_process_date  per_periods_of_service.final_process_date%TYPE;

l_temp_id             NUMBER(15);
l_ud_emp_fed_tax_rule_id   hr_h2pi_federal_tax_rules.emp_fed_tax_rule_id%TYPE;
l_ud_emp_state_tax_rule_id hr_h2pi_state_tax_rules.emp_state_tax_rule_id%TYPE;
l_ud_emp_county_tax_rule_id hr_h2pi_county_tax_rules.emp_county_tax_rule_id%TYPE;
l_ud_emp_city_tax_rule_id  hr_h2pi_city_tax_rules.emp_city_tax_rule_id%TYPE;
l_emp_fed_tax_rule_id      hr_h2pi_federal_tax_rules.emp_fed_tax_rule_id%TYPE;
l_emp_state_tax_rule_id    hr_h2pi_state_tax_rules.emp_state_tax_rule_id%TYPE;
l_emp_county_tax_rule_id   hr_h2pi_county_tax_rules.emp_county_tax_rule_id%TYPE;
l_emp_city_tax_rule_id     hr_h2pi_city_tax_rules.emp_city_tax_rule_id%TYPE;

l_dummy_person_type       hr_h2pi_employees_v.person_type%TYPE;
l_future_term_flag        BOOLEAN := FALSE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_assignment(p_assignment_id,
                         p_effective_start_date);
  FETCH csr_ud_assignment INTO v_ud_asg;

  IF v_ud_asg.last_upd_date = g_eot THEN

    hr_utility.set_location(l_proc, 20);
    l_assignment_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                         p_from_id      => v_ud_asg.assignment_id,
                         p_report_error => TRUE);

    IF v_ud_asg.primary_flag = 'Y' THEN

      hr_utility.set_location(l_proc, 30);
      OPEN csr_ed_periods_of_service(l_assignment_id,
                                     v_ud_asg.effective_start_date);
      FETCH csr_ed_periods_of_service
      INTO  l_ovn,
            l_period_of_service_id;
      CLOSE csr_ed_periods_of_service;

      hr_utility.set_location(l_proc, 40);
      l_final_process_date := v_ud_asg.effective_start_date - 1;
      hr_ex_employee_api.final_process_emp(
             p_period_of_service_id       => l_period_of_service_id
            ,p_object_version_number      => l_ovn
            ,p_final_process_date         => l_final_process_date
            ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
            ,p_asg_future_changes_warning => l_asg_future_changes_warning
            ,p_entries_changed_warning    => l_entries_changed_warning
            );
    ELSE
      OPEN csr_ed_assignment_ovn(l_assignment_id,
                                 v_ud_asg.effective_start_date);
      FETCH csr_ed_assignment_ovn
      INTO  l_ovn;
      CLOSE csr_ed_assignment_ovn;

      hr_utility.set_location(l_proc, 50);
      hr_assignment_api.actual_termination_emp_asg(
             p_assignment_id	          => l_assignment_id
            ,p_object_version_number      => l_ovn
            ,p_actual_termination_date    =>(v_ud_asg.effective_start_date - 1)
            ,p_effective_start_date       => l_esd
            ,p_effective_end_date         => l_esd
            ,p_asg_future_changes_warning => l_asg_future_changes_warning
            ,p_entries_changed_warning    => l_entries_changed_warning
            ,p_pay_proposal_warning       => l_pay_proposal_warning
            );

      hr_utility.set_location(l_proc, 60);
      hr_assignment_api.final_process_emp_asg(
             p_assignment_id	          => l_assignment_id
            ,p_object_version_number      => l_ovn
            ,p_final_process_date         =>(v_ud_asg.effective_start_date - 1)
            ,p_effective_start_date       => l_esd
            ,p_effective_end_date         => l_eed
            ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
            ,p_asg_future_changes_warning => l_asg_future_changes_warning
            ,p_entries_changed_warning    => l_entries_changed_warning
            );
    END IF;

  ELSE

    hr_utility.set_location(l_proc, 70);
    l_person_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PER_ALL_PEOPLE_F',
                         p_from_id      => v_ud_asg.person_id,
                         p_report_error => TRUE);

    l_organization_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'HR_ALL_ORGANIZATION_UNITS',
                         p_from_id      => v_ud_asg.organization_id,
                         p_report_error => TRUE);

    l_payroll_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PAY_ALL_PAYROLLS_F',
                         p_from_id      => v_ud_asg.payroll_id,
                         p_report_error => TRUE);

    l_location_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'HR_LOCATIONS_ALL',
                         p_from_id      => v_ud_asg.location_id,
                         p_report_error => TRUE);

    l_pay_basis_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PER_PAY_BASES',
                         p_from_id      => v_ud_asg.pay_basis_id,
                         p_report_error => TRUE);

/*****************************************************
 * US SPECIFIC - Ideally have generic flexfield mapper
 *****************************************************/
    l_gre_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'HR_ALL_ORGANIZATION_UNITS',
                         p_from_id      => v_ud_asg.segment1,
                         p_report_error => TRUE);
    v_ud_asg.segment1 := TO_CHAR(l_gre_id);

    l_assignment_id := hr_h2pi_map.get_to_id
                        (p_table_name  => 'PER_ALL_ASSIGNMENTS_F',
                         p_from_id     => v_ud_asg.assignment_id);

    IF l_assignment_id = -1 THEN
      hr_utility.set_location(l_proc, 80);

      hr_assignment_api.create_secondary_emp_asg(
             p_effective_date	      => v_ud_asg.effective_start_date
            ,p_person_id              => l_person_id
            ,p_organization_id        => l_organization_id
            ,p_payroll_id             => l_payroll_id
            ,p_location_id            => l_location_id
            ,p_pay_basis_id           => l_pay_basis_id
            ,p_assignment_number      => v_ud_asg.assignment_number
            ,p_frequency              => v_ud_asg.frequency
            ,p_normal_hours           => v_ud_asg.normal_hours
            ,p_hourly_salaried_code   => v_ud_asg.hourly_salaried_code
            ,p_time_normal_finish     => v_ud_asg.time_normal_finish
            ,p_time_normal_start      => v_ud_asg.time_normal_start
            ,p_employment_category    => v_ud_asg.employment_category
            ,p_title                  => v_ud_asg.title
            ,p_ass_attribute_category => v_ud_asg.ass_attribute_category
            ,p_ass_attribute1         => v_ud_asg.ass_attribute1
            ,p_ass_attribute2         => v_ud_asg.ass_attribute2
            ,p_ass_attribute3         => v_ud_asg.ass_attribute3
            ,p_ass_attribute4         => v_ud_asg.ass_attribute4
            ,p_ass_attribute5         => v_ud_asg.ass_attribute5
            ,p_ass_attribute6         => v_ud_asg.ass_attribute6
            ,p_ass_attribute7         => v_ud_asg.ass_attribute7
            ,p_ass_attribute8         => v_ud_asg.ass_attribute8
            ,p_ass_attribute9         => v_ud_asg.ass_attribute9
            ,p_ass_attribute10        => v_ud_asg.ass_attribute10
            ,p_ass_attribute11        => v_ud_asg.ass_attribute11
            ,p_ass_attribute12        => v_ud_asg.ass_attribute12
            ,p_ass_attribute13        => v_ud_asg.ass_attribute13
            ,p_ass_attribute14        => v_ud_asg.ass_attribute14
            ,p_ass_attribute15        => v_ud_asg.ass_attribute15
            ,p_ass_attribute16        => v_ud_asg.ass_attribute16
            ,p_ass_attribute17        => v_ud_asg.ass_attribute17
            ,p_ass_attribute18        => v_ud_asg.ass_attribute18
            ,p_ass_attribute19        => v_ud_asg.ass_attribute19
            ,p_ass_attribute20        => v_ud_asg.ass_attribute20
            ,p_ass_attribute21        => v_ud_asg.ass_attribute21
            ,p_ass_attribute22        => v_ud_asg.ass_attribute22
            ,p_ass_attribute23        => v_ud_asg.ass_attribute23
            ,p_ass_attribute24        => v_ud_asg.ass_attribute24
            ,p_ass_attribute25        => v_ud_asg.ass_attribute25
            ,p_ass_attribute26        => v_ud_asg.ass_attribute26
            ,p_ass_attribute27        => v_ud_asg.ass_attribute27
            ,p_ass_attribute28        => v_ud_asg.ass_attribute28
            ,p_ass_attribute29        => v_ud_asg.ass_attribute29
            ,p_ass_attribute30        => v_ud_asg.ass_attribute30
            ,p_scl_segment1           => v_ud_asg.segment1
        --    ,p_scl_segment2           => v_ud_asg.segment2
            ,p_scl_segment3           => v_ud_asg.segment3
        --    ,p_scl_segment4           => v_ud_asg.segment4
            ,p_scl_segment5           => v_ud_asg.segment5
            ,p_scl_segment6           => v_ud_asg.segment6
            ,p_scl_segment7           => v_ud_asg.segment7
            ,p_scl_segment8           => v_ud_asg.segment8
            ,p_scl_segment9           => v_ud_asg.segment9
            ,p_scl_segment10          => v_ud_asg.segment10
            ,p_scl_segment11          => v_ud_asg.segment11
            ,p_scl_segment12          => v_ud_asg.segment12
            ,p_scl_segment13          => v_ud_asg.segment13
            ,p_scl_segment14          => v_ud_asg.segment14
            ,p_scl_segment15          => v_ud_asg.segment15
            ,p_scl_segment16          => v_ud_asg.segment16
            ,p_scl_segment17          => v_ud_asg.segment17
            ,p_scl_segment18          => v_ud_asg.segment18
            ,p_scl_segment19          => v_ud_asg.segment19
            ,p_scl_segment20          => v_ud_asg.segment20
            ,p_scl_segment21          => v_ud_asg.segment21
            ,p_scl_segment22          => v_ud_asg.segment22
            ,p_scl_segment23          => v_ud_asg.segment23
            ,p_scl_segment24          => v_ud_asg.segment24
            ,p_scl_segment25          => v_ud_asg.segment25
            ,p_scl_segment26          => v_ud_asg.segment26
            ,p_scl_segment27          => v_ud_asg.segment27
            ,p_scl_segment28          => v_ud_asg.segment28
            ,p_scl_segment29          => v_ud_asg.segment29
            ,p_scl_segment30          => v_ud_asg.segment30
             -- added for the enhancement
            ,p_pgp_segment1           => v_ud_asg.ppg_segment1
            ,p_pgp_segment2           => v_ud_asg.ppg_segment2
            ,p_pgp_segment3           => v_ud_asg.ppg_segment3
            ,p_pgp_segment4           => v_ud_asg.ppg_segment4
            ,p_pgp_segment5           => v_ud_asg.ppg_segment5
            ,p_pgp_segment6           => v_ud_asg.ppg_segment6
            ,p_pgp_segment7           => v_ud_asg.ppg_segment7
            ,p_pgp_segment8           => v_ud_asg.ppg_segment8
            ,p_pgp_segment9           => v_ud_asg.ppg_segment9
            ,p_pgp_segment10          => v_ud_asg.ppg_segment10
            ,p_pgp_segment11          => v_ud_asg.ppg_segment11
            ,p_pgp_segment12          => v_ud_asg.ppg_segment12
            ,p_pgp_segment13          => v_ud_asg.ppg_segment13
            ,p_pgp_segment14          => v_ud_asg.ppg_segment14
            ,p_pgp_segment15          => v_ud_asg.ppg_segment15
            ,p_pgp_segment16          => v_ud_asg.ppg_segment16
            ,p_pgp_segment17          => v_ud_asg.ppg_segment17
            ,p_pgp_segment18          => v_ud_asg.ppg_segment18
            ,p_pgp_segment19          => v_ud_asg.ppg_segment19
            ,p_pgp_segment20          => v_ud_asg.ppg_segment20
            ,p_pgp_segment21          => v_ud_asg.ppg_segment21
            ,p_pgp_segment22          => v_ud_asg.ppg_segment22
            ,p_pgp_segment23          => v_ud_asg.ppg_segment23
            ,p_pgp_segment24          => v_ud_asg.ppg_segment24
            ,p_pgp_segment25          => v_ud_asg.ppg_segment25
            ,p_pgp_segment26          => v_ud_asg.ppg_segment26
            ,p_pgp_segment27          => v_ud_asg.ppg_segment27
            ,p_pgp_segment28          => v_ud_asg.ppg_segment28
            ,p_pgp_segment29          => v_ud_asg.ppg_segment29
            ,p_pgp_segment30          => v_ud_asg.ppg_segment30
            --
            ,p_group_name             => l_group_name
            ,p_concatenated_segments  => l_concatenated_segments
            ,p_assignment_id          => l_assignment_id
            ,p_soft_coding_keyflex_id => l_soft_coding_keyflex_id
            ,p_people_group_id        => l_people_group_id
            ,p_object_version_number  => l_ovn
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            ,p_assignment_sequence    => l_assignment_sequence
            ,p_comment_id             => l_comment_id
            ,p_other_manager_warning  => l_other_manager_warning
            );

      hr_utility.set_location(l_proc, 90);
      hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PER_ALL_ASSIGNMENTS_F',
                       p_from_id    => v_ud_asg.assignment_id,
                       p_to_id      => l_assignment_id);
    ELSE

      BEGIN
        hr_utility.set_location(l_proc, 100);
        OPEN csr_ed_assignment(l_assignment_id,
                               v_ud_asg.effective_start_date);
        FETCH csr_ed_assignment
        INTO  v_ed_asg;
        IF csr_ed_assignment%NOTFOUND THEN
          hr_utility.set_location(l_proc, 110);
          CLOSE csr_ed_assignment;
          ROLLBACK;
          hr_utility.set_location(l_proc, 220);
          hr_h2pi_error.data_error
               (p_from_id       => l_assignment_id,
                p_table_name    => 'HR_H2PI_ASSIGNMENTS',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
          COMMIT;
          RAISE MAPPING_ID_INVALID;
        ELSE
          CLOSE csr_ed_assignment;
        END IF;

        OPEN csr_ed_assignment_ovn(l_assignment_id,
                                   v_ud_asg.effective_start_date);
        FETCH csr_ed_assignment_ovn
        INTO  l_ovn;
        CLOSE csr_ed_assignment_ovn;
      END;

      l_delete_mode := 'DELETE_NEXT_CHANGE';
      LOOP
      hr_utility.set_location(l_proc, 120);
        l_records_same := FALSE;

        SELECT MAX(asg.effective_end_date)
        INTO   l_max_eed
        FROM   per_all_assignments_f asg
        WHERE  asg.assignment_id = l_assignment_id;

        IF l_max_eed > v_ed_asg.effective_end_date THEN
          hr_utility.set_location(l_proc, 130);
          l_future_records := TRUE;
        END IF;

        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_asg.effective_start_date
            ,p_ud_end_date    => v_ud_asg.effective_end_date
            ,p_ed_start_date  => v_ed_asg.effective_start_date
            ,p_ed_end_date    => v_ed_asg.effective_end_date
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);

        EXIT WHEN l_delete_mode = 'X';

        IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN
          hr_utility.set_location(l_proc, 134);

          BEGIN
            SELECT DISTINCT person_type
            INTO   l_dummy_person_type
            FROM   hr_h2pi_employees_v
            WHERE  person_id = l_person_id
            AND    effective_start_date < v_ud_asg.effective_end_date
            AND    effective_end_date   > v_ud_asg.effective_start_date;
         EXCEPTION
           WHEN TOO_MANY_ROWS THEN
             hr_utility.set_location(l_proc, 136);
             l_future_term_flag := TRUE;
             calculate_datetrack_mode
               (p_ud_start_date  => v_ud_asg.effective_start_date
               ,p_ud_end_date    => v_ud_asg.effective_end_date
               ,p_ed_start_date  => v_ed_asg.effective_start_date
               ,p_ed_end_date    => v_ud_asg.effective_end_date
               ,p_records_same   => l_records_same
               ,p_future_records => l_future_records
               ,p_update_mode    => l_update_mode
               ,p_delete_mode    => l_delete_mode);
          EXIT;
        END;


          hr_utility.set_location(l_proc, 140);
          per_asg_del.del(p_assignment_id         => l_assignment_id
                         ,p_effective_start_date  => l_del_esd
                         ,p_effective_end_date    => l_del_eed
                         ,p_validation_start_date => l_val_esd
                         ,p_validation_end_date   => l_val_eed
                         ,p_business_group_id     => l_business_group_id
                         ,p_org_now_no_manager_warning
                                               => l_org_now_no_manager_warning
                         ,p_object_version_number => l_ovn
                         ,p_effective_date     => v_ed_asg.effective_end_date
                         ,p_datetrack_mode        => 'DELETE_NEXT_CHANGE');

          hr_utility.set_location(l_proc, 150);
          OPEN csr_ed_assignment(l_assignment_id,
                                 v_ud_asg.effective_start_date);
          FETCH csr_ed_assignment
          INTO  v_ed_asg;
          CLOSE csr_ed_assignment;

        END IF;

      END LOOP;

      IF v_ud_asg.primary_flag = 'Y' AND
         v_ed_asg.primary_flag = 'N' THEN
        hr_utility.set_location(l_proc, 160);
        l_person_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PER_ALL_PEOPLE_F',
                         p_from_id      => v_ud_asg.person_id,
                         p_report_error => TRUE);

        hr_utility.set_location(l_proc, 170);
        hr_assignment_api.set_new_primary_asg(
               p_effective_date        => v_ud_asg.effective_start_date
              ,p_person_id             => l_person_id
              ,p_assignment_id         => l_assignment_id
              ,p_object_version_number => l_ovn
              ,p_effective_start_date  => l_esd
              ,p_effective_end_date    => l_eed
              );

        IF l_future_term_flag THEN
          calculate_datetrack_mode
            (p_ud_start_date  => v_ud_asg.effective_start_date
            ,p_ud_end_date    => v_ud_asg.effective_end_date
            ,p_ed_start_date  => l_esd
            ,p_ed_end_date    => v_ud_asg.effective_end_date
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);
        ELSE
          calculate_datetrack_mode
            (p_ud_start_date  => v_ud_asg.effective_start_date
            ,p_ud_end_date    => v_ud_asg.effective_end_date
            ,p_ed_start_date  => l_esd
            ,p_ed_end_date    => l_eed
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);
        END IF;
      END IF;

      hr_utility.set_location(l_proc, 180);
      hr_assignment_api.update_emp_asg(
             p_effective_date	         => v_ud_asg.effective_start_date
            ,p_datetrack_update_mode     => l_update_mode
            ,p_assignment_id             => l_assignment_id
            ,p_object_version_number     => l_ovn
            ,p_assignment_number         => v_ud_asg.assignment_number
            ,p_frequency                 => v_ud_asg.frequency
            ,p_normal_hours              => v_ud_asg.normal_hours
            ,p_hourly_salaried_code      => v_ud_asg.hourly_salaried_code
        --    ,p_source_type               => v_ud_asg.source_type
            ,p_time_normal_finish        => v_ud_asg.time_normal_finish
            ,p_time_normal_start         => v_ud_asg.time_normal_start
            ,p_ass_attribute_category    => v_ud_asg.ass_attribute_category
            ,p_ass_attribute1            => v_ud_asg.ass_attribute1
            ,p_ass_attribute2            => v_ud_asg.ass_attribute2
            ,p_ass_attribute3            => v_ud_asg.ass_attribute3
            ,p_ass_attribute4            => v_ud_asg.ass_attribute4
            ,p_ass_attribute5            => v_ud_asg.ass_attribute5
            ,p_ass_attribute6            => v_ud_asg.ass_attribute6
            ,p_ass_attribute7            => v_ud_asg.ass_attribute7
            ,p_ass_attribute8            => v_ud_asg.ass_attribute8
            ,p_ass_attribute9            => v_ud_asg.ass_attribute9
            ,p_ass_attribute10           => v_ud_asg.ass_attribute10
            ,p_ass_attribute11           => v_ud_asg.ass_attribute11
            ,p_ass_attribute12           => v_ud_asg.ass_attribute12
            ,p_ass_attribute13           => v_ud_asg.ass_attribute13
            ,p_ass_attribute14           => v_ud_asg.ass_attribute14
            ,p_ass_attribute15           => v_ud_asg.ass_attribute15
            ,p_ass_attribute16           => v_ud_asg.ass_attribute16
            ,p_ass_attribute17           => v_ud_asg.ass_attribute17
            ,p_ass_attribute18           => v_ud_asg.ass_attribute18
            ,p_ass_attribute19           => v_ud_asg.ass_attribute19
            ,p_ass_attribute20           => v_ud_asg.ass_attribute20
            ,p_ass_attribute21           => v_ud_asg.ass_attribute21
            ,p_ass_attribute22           => v_ud_asg.ass_attribute22
            ,p_ass_attribute23           => v_ud_asg.ass_attribute23
            ,p_ass_attribute24           => v_ud_asg.ass_attribute24
            ,p_ass_attribute25           => v_ud_asg.ass_attribute25
            ,p_ass_attribute26           => v_ud_asg.ass_attribute26
            ,p_ass_attribute27           => v_ud_asg.ass_attribute27
            ,p_ass_attribute28           => v_ud_asg.ass_attribute28
            ,p_ass_attribute29           => v_ud_asg.ass_attribute29
            ,p_ass_attribute30           => v_ud_asg.ass_attribute30
            ,p_title                     => v_ud_asg.title
            ,p_segment1                  => v_ud_asg.segment1
         --   ,p_segment2                  => v_ud_asg.segment2
            ,p_segment3                  => v_ud_asg.segment3
         --   ,p_segment4                  => v_ud_asg.segment4
            ,p_segment5                  => v_ud_asg.segment5
            ,p_segment6                  => v_ud_asg.segment6
            ,p_segment7                  => v_ud_asg.segment7
            ,p_segment8                  => v_ud_asg.segment8
            ,p_segment9                  => v_ud_asg.segment9
            ,p_segment10                 => v_ud_asg.segment10
            ,p_segment11                 => v_ud_asg.segment11
            ,p_segment12                 => v_ud_asg.segment12
            ,p_segment13                 => v_ud_asg.segment13
            ,p_segment14                 => v_ud_asg.segment14
            ,p_segment15                 => v_ud_asg.segment15
            ,p_segment16                 => v_ud_asg.segment16
            ,p_segment17                 => v_ud_asg.segment17
            ,p_segment18                 => v_ud_asg.segment18
            ,p_segment19                 => v_ud_asg.segment19
            ,p_segment20                 => v_ud_asg.segment20
            ,p_segment21                 => v_ud_asg.segment21
            ,p_segment22                 => v_ud_asg.segment22
            ,p_segment23                 => v_ud_asg.segment23
            ,p_segment24                 => v_ud_asg.segment24
            ,p_segment25                 => v_ud_asg.segment25
            ,p_segment26                 => v_ud_asg.segment26
            ,p_segment27                 => v_ud_asg.segment27
            ,p_segment28                 => v_ud_asg.segment28
            ,p_segment29                 => v_ud_asg.segment29
            ,p_segment30                 => v_ud_asg.segment30
            ,p_concatenated_segments     => l_concat_segments
            ,p_soft_coding_keyflex_id    => l_soft_coding_keyflex_id
            ,p_comment_id                => l_comment_id
            ,p_effective_start_date      => l_esd
            ,p_effective_end_date        => l_eed
            ,p_no_managers_warning       => l_no_manager_warning
            ,p_other_manager_warning     => l_other_manager_warning
            );

      hr_utility.set_location(l_proc, 190);
      IF l_future_term_flag THEN
        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_asg.effective_start_date
            ,p_ud_end_date    => v_ud_asg.effective_end_date
            ,p_ed_start_date  => l_esd
            ,p_ed_end_date    => v_ud_asg.effective_end_date
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);
      ELSE
        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_asg.effective_start_date
            ,p_ud_end_date    => v_ud_asg.effective_end_date
            ,p_ed_start_date  => l_esd
            ,p_ed_end_date    => l_eed
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);
      END IF;

      hr_assignment_api.update_emp_asg_criteria(
             p_effective_date        => v_ud_asg.effective_start_date
            ,p_datetrack_update_mode => l_update_mode
            ,p_assignment_id         => l_assignment_id
            ,p_object_version_number => l_ovn
            ,p_payroll_id            => l_payroll_id
            ,p_location_id           => l_location_id
            ,p_organization_id       => l_organization_id
            ,p_pay_basis_id          => l_pay_basis_id
            ,p_employment_category   => v_ud_asg.employment_category
             -- added for the enhancement
            ,p_segment1           => v_ud_asg.ppg_segment1
            ,p_segment2           => v_ud_asg.ppg_segment2
            ,p_segment3           => v_ud_asg.ppg_segment3
            ,p_segment4           => v_ud_asg.ppg_segment4
            ,p_segment5           => v_ud_asg.ppg_segment5
            ,p_segment6           => v_ud_asg.ppg_segment6
            ,p_segment7           => v_ud_asg.ppg_segment7
            ,p_segment8           => v_ud_asg.ppg_segment8
            ,p_segment9           => v_ud_asg.ppg_segment9
            ,p_segment10          => v_ud_asg.ppg_segment10
            ,p_segment11          => v_ud_asg.ppg_segment11
            ,p_segment12          => v_ud_asg.ppg_segment12
            ,p_segment13          => v_ud_asg.ppg_segment13
            ,p_segment14          => v_ud_asg.ppg_segment14
            ,p_segment15          => v_ud_asg.ppg_segment15
            ,p_segment16          => v_ud_asg.ppg_segment16
            ,p_segment17          => v_ud_asg.ppg_segment17
            ,p_segment18          => v_ud_asg.ppg_segment18
            ,p_segment19          => v_ud_asg.ppg_segment19
            ,p_segment20          => v_ud_asg.ppg_segment20
            ,p_segment21          => v_ud_asg.ppg_segment21
            ,p_segment22          => v_ud_asg.ppg_segment22
            ,p_segment23          => v_ud_asg.ppg_segment23
            ,p_segment24          => v_ud_asg.ppg_segment24
            ,p_segment25          => v_ud_asg.ppg_segment25
            ,p_segment26          => v_ud_asg.ppg_segment26
            ,p_segment27          => v_ud_asg.ppg_segment27
            ,p_segment28          => v_ud_asg.ppg_segment28
            ,p_segment29          => v_ud_asg.ppg_segment29
            ,p_segment30          => v_ud_asg.ppg_segment30
            --
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_group_name            => l_group_name
            ,p_people_group_id       => l_people_group_id
            ,p_special_ceiling_step_id      => l_special_ceiling_step_id
            ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
            ,p_other_manager_warning        => l_other_manager_warning
            ,p_spp_delete_warning           => l_spp_delete_warning
            ,p_entries_changed_warning      => l_entries_changed_warning
            ,p_tax_district_changed_warning => l_tax_district_changed_warning
            );

    END IF;

    hr_utility.set_location(l_proc, 200);
    BEGIN
      SELECT emp_fed_tax_rule_id
      INTO   l_emp_fed_tax_rule_id
      FROM   hr_h2pi_federal_tax_rules_v
      WHERE  assignment_id = l_assignment_id
      AND    v_ud_asg.effective_start_date BETWEEN effective_start_date
                                               AND effective_end_date;

      l_temp_id := hr_h2pi_map.get_from_id(
                               p_table_name => 'PAY_US_EMP_FED_TAX_RULES_F',
                               p_to_id      => l_emp_fed_tax_rule_id);
      IF l_temp_id = -1 THEN
        SELECT emp_fed_tax_rule_id
        INTO   l_ud_emp_fed_tax_rule_id
        FROM   hr_h2pi_federal_tax_rules
        WHERE  assignment_id = v_ud_asg.assignment_id
        AND    client_id     = p_from_client_id
        AND    v_ud_asg.effective_start_date BETWEEN effective_start_date
                                                 AND effective_end_date;

        hr_h2pi_map.create_id_mapping
                   (p_table_name => 'PAY_US_EMP_FED_TAX_RULES_F',
                    p_from_id    => l_ud_emp_fed_tax_rule_id,
                    p_to_id      => l_emp_fed_tax_rule_id);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        hr_utility.set_location(l_proc, 205);
    END;

    hr_utility.set_location(l_proc, 210);
    FOR v_sta IN csr_state_tax_rule(l_assignment_id,
                                    v_ud_asg.effective_start_date) LOOP
      l_temp_id := hr_h2pi_map.get_from_id(
                               p_table_name => 'PAY_US_EMP_STATE_TAX_RULES_F',
                               p_to_id      => v_sta.emp_state_tax_rule_id);
      IF l_temp_id = -1 THEN

        SELECT emp_state_tax_rule_id
        INTO   l_ud_emp_state_tax_rule_id
        FROM   hr_h2pi_state_tax_rules
        WHERE  assignment_id = v_ud_asg.assignment_id
        AND    client_id     = p_from_client_id
        AND    jurisdiction_code = v_sta.jurisdiction_code
        AND    v_ud_asg.effective_start_date BETWEEN effective_start_date
                                                 AND effective_end_date;

        hr_h2pi_map.create_id_mapping
                 (p_table_name => 'PAY_US_EMP_STATE_TAX_RULES_F',
                  p_from_id    => l_ud_emp_state_tax_rule_id,
                  p_to_id      => v_sta.emp_state_tax_rule_id);

      END IF;
    END LOOP;

    hr_utility.set_location(l_proc, 220);
    FOR v_cnt IN csr_county_tax_rule(l_assignment_id,
                                     v_ud_asg.effective_start_date) LOOP
      l_temp_id := hr_h2pi_map.get_from_id(
                               p_table_name=> 'PAY_US_EMP_COUNTY_TAX_RULES_F',
                               p_to_id     => v_cnt.emp_county_tax_rule_id);
      IF l_temp_id = -1 THEN

        SELECT emp_county_tax_rule_id
        INTO   l_ud_emp_county_tax_rule_id
        FROM   hr_h2pi_county_tax_rules
        WHERE  assignment_id = v_ud_asg.assignment_id
        AND    client_id     = p_from_client_id
        AND    jurisdiction_code = v_cnt.jurisdiction_code
        AND    v_ud_asg.effective_start_date BETWEEN effective_start_date
                                                 AND effective_end_date;

        hr_h2pi_map.create_id_mapping
                 (p_table_name => 'PAY_US_EMP_COUNTY_TAX_RULES_F',
                  p_from_id    => l_ud_emp_county_tax_rule_id,
                  p_to_id      => v_cnt.emp_county_tax_rule_id);

      END IF;
    END LOOP;

    hr_utility.set_location(l_proc, 230);
    FOR v_cty IN csr_city_tax_rule(l_assignment_id,
                                   v_ud_asg.effective_start_date) LOOP
      l_temp_id := hr_h2pi_map.get_from_id(
                               p_table_name => 'PAY_US_EMP_CITY_TAX_RULES_F',
                               p_to_id      => v_cty.emp_city_tax_rule_id);
      IF l_temp_id = -1 THEN

        SELECT emp_city_tax_rule_id
        INTO   l_ud_emp_city_tax_rule_id
        FROM   hr_h2pi_city_tax_rules
        WHERE  assignment_id = v_ud_asg.assignment_id
        AND    client_id     = p_from_client_id
        AND    jurisdiction_code = v_cty.jurisdiction_code
        AND    v_ud_asg.effective_start_date BETWEEN effective_start_date
                                                 AND effective_end_date;

        hr_h2pi_map.create_id_mapping
                 (p_table_name => 'PAY_US_EMP_CITY_TAX_RULES_F',
                  p_from_id    => l_ud_emp_city_tax_rule_id,
                  p_to_id      => v_cty.emp_city_tax_rule_id);

      END IF;
    END LOOP;
  END IF;

  hr_utility.set_location(l_proc, 240);
  UPDATE hr_h2pi_assignments asg
  SET status = 'C'
  WHERE asg.assignment_id = v_ud_asg.assignment_id
  AND   asg.client_id     = p_from_client_id
  AND   asg.effective_start_date = v_ud_asg.effective_start_date
  AND   asg.effective_end_date   = v_ud_asg.effective_end_date;

  CLOSE csr_ud_assignment;
  hr_utility.set_location('Leaving:'|| l_proc, 250);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 260);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_asg.assignment_id,
                p_table_name           => 'HR_H2PI_ASSIGNMENTS',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;
END;



PROCEDURE upload_period_of_service (p_from_client_id NUMBER,
                                    p_period_of_service_id   NUMBER,
                                    p_effective_start_date   DATE) IS

CURSOR csr_ud_periods_of_service(p_pos_id NUMBER) IS
  SELECT *
  FROM   hr_h2pi_periods_of_service pos
  WHERE  pos.period_of_service_id = p_pos_id
  AND    pos.client_id  = p_from_client_id;

CURSOR csr_ed_periods_of_service(p_pos_id NUMBER) IS
  SELECT pos.object_version_number
  FROM   per_periods_of_service pos
  WHERE  pos.period_of_service_id = p_pos_id;

l_proc            VARCHAR2(72) := g_package||'upload_period_of_service';

l_encoded_message VARCHAR2(200);

v_ud_pos                  hr_h2pi_periods_of_service%ROWTYPE;
l_period_of_service_id    per_periods_of_service.period_of_service_id%TYPE;
l_ovn                     per_periods_of_service.object_version_number%TYPE;
l_actual_termination_date per_periods_of_service.actual_termination_date%TYPE;
l_final_process_date      per_periods_of_service.final_process_date%TYPE;
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_periods_of_service(p_period_of_service_id);
  FETCH csr_ud_periods_of_service INTO v_ud_pos;

  l_period_of_service_id := hr_h2pi_map.get_to_id
                              (p_table_name   => 'PER_PERIODS_OF_SERVICE',
                               p_from_id      => v_ud_pos.period_of_service_id,
                               p_report_error => TRUE);

  OPEN csr_ed_periods_of_service(l_period_of_service_id);
  FETCH csr_ed_periods_of_service INTO l_ovn;
  CLOSE csr_ed_periods_of_service;

  hr_utility.set_location(l_proc, 30);
  hr_ex_employee_api.update_term_details_emp(
         p_effective_date	       => v_ud_pos.date_start
        ,p_period_of_service_id	       => l_period_of_service_id
        ,p_object_version_number       => l_ovn
  --      ,p_accepted_termination_date   => v_ud_pos.accepted_termination_date
        ,p_leaving_reason              => v_ud_pos.leaving_reason
  --      ,p_notified_termination_date   => v_ud_pos.notified_termination_date
  --      ,p_projected_termination_date  => v_ud_pos.projected_termination_date
           );

  hr_utility.set_location(l_proc, 40);
  UPDATE hr_h2pi_periods_of_service pos
  SET status = 'C'
  WHERE  pos.period_of_service_id = v_ud_pos.period_of_service_id
  AND    pos.client_id            = p_from_client_id;

  CLOSE csr_ud_periods_of_service;
  hr_utility.set_location('Leaving:'|| l_proc, 50);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 70);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_pos.period_of_service_id,
                p_table_name           => 'HR_H2PI_PERIODS_OF_SERVICE',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;



PROCEDURE upload_salary (p_from_client_id NUMBER,
                         p_pay_proposal_id        NUMBER,
                         p_effective_start_date   DATE) IS

CURSOR csr_ud_salary (p_ppp_id NUMBER) IS
  SELECT *
  FROM   hr_h2pi_salaries ppp
  WHERE  ppp.pay_proposal_id = p_ppp_id
  AND    ppp.client_id       = p_from_client_id;

CURSOR csr_ed_salary (p_ppp_id NUMBER) IS
  SELECT object_version_number
  FROM   per_pay_proposals ppp
  WHERE  ppp.pay_proposal_id = p_ppp_id;

CURSOR csr_sal_ee (p_asg_id NUMBER,
                   p_date   DATE) IS
  SELECT element_entry_id
  FROM   pay_element_entries_f
  WHERE  creator_type = 'SP'
  AND    p_date BETWEEN effective_start_date and effective_end_date
  AND    assignment_id = p_asg_id;

l_proc               VARCHAR2(72) := g_package||'upload_salary';

l_encoded_message VARCHAR2(200);

l_assignment_id         per_pay_proposals.assignment_id%TYPE;
l_pay_proposal_id       per_pay_proposals.pay_proposal_id%TYPE;
l_ovn                   per_pay_proposals.object_version_number%TYPE;
v_ud_ppp                hr_h2pi_salaries%ROWTYPE;

l_element_entry_id           pay_element_entries_f.element_entry_id%TYPE;
l_inv_next_sal_date_warning  BOOLEAN;
l_proposed_salary_warning    BOOLEAN;
l_approved_warning           BOOLEAN;
l_payroll_warning            BOOLEAN;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_salary(p_pay_proposal_id);
  FETCH csr_ud_salary INTO v_ud_ppp;

  l_assignment_id := hr_h2pi_map.get_to_id
                      (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                       p_from_id      => v_ud_ppp.assignment_id,
                       p_report_error => TRUE);

  hr_utility.set_location(l_proc, 20);
  l_pay_proposal_id := hr_h2pi_map.get_to_id
                         (p_table_name   => 'PER_PAY_PROPOSALS',
                          p_from_id      => v_ud_ppp.pay_proposal_id);

  OPEN csr_sal_ee(l_assignment_id,
                  v_ud_ppp.change_date);
  FETCH csr_sal_ee INTO l_element_entry_id;
  hr_utility.set_location(l_proc, 25);
  CLOSE csr_sal_ee;

  IF l_pay_proposal_id = -1 THEN
    hr_utility.set_location(l_proc, 30);
    hr_maintain_proposal_api.insert_salary_proposal(
             p_assignment_id       => l_assignment_id
            ,p_business_group_id   => hr_h2pi_upload.g_to_business_group_id
            ,p_change_date         => v_ud_ppp.change_date
            ,p_proposed_salary_n   => v_ud_ppp.proposed_salary_n
            ,p_attribute_category  => v_ud_ppp.attribute_category
            ,p_attribute1          => v_ud_ppp.attribute1
            ,p_attribute2          => v_ud_ppp.attribute2
            ,p_attribute3          => v_ud_ppp.attribute3
            ,p_attribute4          => v_ud_ppp.attribute4
            ,p_attribute5          => v_ud_ppp.attribute5
            ,p_attribute6          => v_ud_ppp.attribute6
            ,p_attribute7          => v_ud_ppp.attribute7
            ,p_attribute8          => v_ud_ppp.attribute8
            ,p_attribute9          => v_ud_ppp.attribute9
            ,p_attribute10         => v_ud_ppp.attribute10
            ,p_attribute11         => v_ud_ppp.attribute11
            ,p_attribute12         => v_ud_ppp.attribute12
            ,p_attribute13         => v_ud_ppp.attribute13
            ,p_attribute14         => v_ud_ppp.attribute14
            ,p_attribute15         => v_ud_ppp.attribute15
            ,p_attribute16         => v_ud_ppp.attribute16
            ,p_attribute17         => v_ud_ppp.attribute17
            ,p_attribute18         => v_ud_ppp.attribute18
            ,p_attribute19         => v_ud_ppp.attribute19
            ,p_attribute20         => v_ud_ppp.attribute20
            ,p_object_version_number     => l_ovn
            ,p_multiple_components       => 'N'
            ,p_approved	                 => 'Y'
            ,p_element_entry_id          => l_element_entry_id
            ,p_inv_next_sal_date_warning => l_inv_next_sal_date_warning
            ,p_proposed_salary_warning   => l_proposed_salary_warning
            ,p_approved_warning          => l_approved_warning
            ,p_payroll_warning           => l_payroll_warning
            ,p_pay_proposal_id           => l_pay_proposal_id
             );

    hr_utility.set_location(l_proc || ' 2. Assignment_id..' || l_assignment_id, 101);
    hr_utility.set_location(l_proc || ' 2. Element_Entry_ID..' || l_element_entry_ID, 102);
    hr_utility.set_location(l_proc || ' 2. Proposed_salary_n..' || v_ud_ppp.proposed_salary_n, 103);
    hr_utility.set_location(l_proc || ' 2. Change_Date..' || v_ud_ppp.change_date, 104);
    hr_utility.set_location(l_proc, 40);
    hr_h2pi_map.create_id_mapping
                   (p_table_name => 'PER_PAY_PROPOSALS',
                    p_from_id    => v_ud_ppp.pay_proposal_id,
                    p_to_id      => l_pay_proposal_id);

  ELSE
    hr_utility.set_location(l_proc, 50);
    OPEN csr_ed_salary(l_pay_proposal_id);
    FETCH csr_ed_salary INTO l_ovn;
    IF csr_ed_salary%NOTFOUND THEN
      hr_utility.set_location(l_proc, 60);
      CLOSE csr_ed_salary;
      ROLLBACK;
      hr_utility.set_location(l_proc, 70);
      hr_h2pi_error.data_error
           (p_from_id       => l_pay_proposal_id,
            p_table_name    => 'HR_H2PI_SALARIES',
            p_message_level => 'FATAL',
            p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
      COMMIT;
      RAISE MAPPING_ID_INVALID;
    ELSE
      CLOSE csr_ed_salary;
    END IF;

    hr_utility.set_location(l_proc, 80);
    hr_maintain_proposal_api.update_salary_proposal(
             p_pay_proposal_id	     => l_pay_proposal_id
            ,p_object_version_number => l_ovn
            ,p_change_date           => v_ud_ppp.change_date
            ,p_proposed_salary_n     => v_ud_ppp.proposed_salary_n
            ,p_attribute_category    => v_ud_ppp.attribute_category
            ,p_attribute1            => v_ud_ppp.attribute1
            ,p_attribute2            => v_ud_ppp.attribute2
            ,p_attribute3            => v_ud_ppp.attribute3
            ,p_attribute4            => v_ud_ppp.attribute4
            ,p_attribute5            => v_ud_ppp.attribute5
            ,p_attribute6            => v_ud_ppp.attribute6
            ,p_attribute7            => v_ud_ppp.attribute7
            ,p_attribute8            => v_ud_ppp.attribute8
            ,p_attribute9            => v_ud_ppp.attribute9
            ,p_attribute10           => v_ud_ppp.attribute10
            ,p_attribute11           => v_ud_ppp.attribute11
            ,p_attribute12           => v_ud_ppp.attribute12
            ,p_attribute13           => v_ud_ppp.attribute13
            ,p_attribute14           => v_ud_ppp.attribute14
            ,p_attribute15           => v_ud_ppp.attribute15
            ,p_attribute16           => v_ud_ppp.attribute16
            ,p_attribute17           => v_ud_ppp.attribute17
            ,p_attribute18           => v_ud_ppp.attribute18
            ,p_attribute19           => v_ud_ppp.attribute19
            ,p_attribute20           => v_ud_ppp.attribute20
            ,p_approved	             => 'Y'
            ,p_inv_next_sal_date_warning => l_inv_next_sal_date_warning
            ,p_proposed_salary_warning   => l_proposed_salary_warning
            ,p_approved_warning          => l_approved_warning
            ,p_payroll_warning           => l_payroll_warning
            );
  END IF;

  hr_utility.set_location(l_proc, 90);
  UPDATE hr_h2pi_salaries ppp
  SET status = 'C'
  WHERE  ppp.pay_proposal_id = v_ud_ppp.pay_proposal_id
  AND    ppp.client_id       = p_from_client_id;
  CLOSE csr_ud_salary;

  hr_utility.set_location('Leaving:'|| l_proc, 100);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 110);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_ppp.pay_proposal_id,
                p_table_name           => 'HR_H2PI_SALARIES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


PROCEDURE upload_payment_method (p_from_client_id     NUMBER,
                                 p_personal_payment_method_id NUMBER,
                                 p_effective_start_date   DATE) IS

CURSOR csr_ud_payment_method (p_ppm_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_payment_methods ppm
  WHERE  ppm.personal_payment_method_id = p_ppm_id
  AND    ppm.client_id  = p_from_client_id
  AND    ppm.effective_start_date   = p_esd;

CURSOR csr_ed_payment_method (p_ppm_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_payment_methods_v ppm
  WHERE  ppm.personal_payment_method_id = p_ppm_id
  AND    p_esd BETWEEN ppm.effective_start_date
                   AND ppm.effective_end_date;

CURSOR csr_ed_payment_method_ovn (p_ppm_id NUMBER,
                                  p_esd    DATE) IS
  SELECT ppm.object_version_number
  FROM   pay_personal_payment_methods_f ppm
  WHERE  ppm.personal_payment_method_id = p_ppm_id
  AND    p_esd BETWEEN ppm.effective_start_date
                   AND ppm.effective_end_date;


l_encoded_message    VARCHAR2(200);

l_proc               VARCHAR2(72) := g_package||'upload_payment_method';

v_ud_ppm             hr_h2pi_payment_methods%ROWTYPE;
v_ed_ppm             hr_h2pi_payment_methods_v%ROWTYPE;

l_assignment_id      per_all_assignments_f.assignment_id%TYPE;
l_personal_pay_method_id
               pay_personal_payment_methods_f.personal_payment_method_id%TYPE;
l_org_pay_method_id  pay_personal_payment_methods_f.org_payment_method_id%TYPE;
l_ovn                pay_personal_payment_methods_f.object_version_number%TYPE;
l_esd                pay_personal_payment_methods_f.effective_start_date%TYPE;
l_eed                pay_personal_payment_methods_f.effective_end_date%TYPE;

l_max_eed            pay_personal_payment_methods_f.effective_end_date%TYPE;
l_del_ovn            pay_personal_payment_methods_f.object_version_number%TYPE;
l_del_esd            pay_personal_payment_methods_f.effective_start_date%TYPE;
l_del_eed            pay_personal_payment_methods_f.effective_end_date%TYPE;
l_val_esd            pay_personal_payment_methods_f.effective_start_date%TYPE;
l_val_eed            pay_personal_payment_methods_f.effective_end_date%TYPE;
l_business_group_id  pay_personal_payment_methods_f.business_group_id%TYPE;

l_records_same       BOOLEAN;
l_future_records     BOOLEAN;
l_update_mode        VARCHAR2(30);
l_delete_mode        VARCHAR2(30);

l_external_account_id pay_personal_payment_methods_f.external_account_id%TYPE;
l_comment_id          pay_personal_payment_methods_f.comment_id%TYPE;

--
l_payee_id            pay_personal_payment_methods_f.payee_id%TYPE;
l_payee_type          pay_personal_payment_methods_f.payee_type%TYPE;
--

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_payment_method(p_personal_payment_method_id,
                             p_effective_start_date);
  FETCH csr_ud_payment_method INTO v_ud_ppm;

  IF v_ud_ppm.last_upd_date = g_eot THEN

    hr_utility.set_location(l_proc, 20);
    l_personal_pay_method_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                         p_from_id      => v_ud_ppm.personal_payment_method_id,
                         p_report_error => TRUE);

    hr_utility.set_location(l_proc, 30);
    OPEN csr_ed_payment_method_ovn(l_personal_pay_method_id,
                                   v_ud_ppm.effective_start_date);
    FETCH csr_ed_payment_method_ovn
    INTO  l_ovn;

    IF csr_ed_payment_method_ovn%FOUND THEN

      l_delete_mode := 'DELETE';
      hr_personal_pay_method_api.delete_personal_pay_method(
             p_effective_date             => v_ud_ppm.effective_start_date-1
            ,p_datetrack_delete_mode      => l_delete_mode
            ,p_personal_payment_method_id => l_personal_pay_method_id
            ,p_object_version_number      => l_ovn
            ,p_effective_start_date       => l_esd
            ,p_effective_end_date         => l_eed
            );
    END IF;

    CLOSE csr_ed_payment_method_ovn;

  ELSE

    hr_utility.set_location(l_proc, 70);
    l_assignment_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                             p_from_id      => v_ud_ppm.assignment_id,
                             p_report_error => TRUE);

    l_org_pay_method_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PAY_ORG_PAYMENT_METHODS_F',
                             p_from_id      => v_ud_ppm.org_payment_method_id,
                             p_report_error => TRUE);

    l_personal_pay_method_id := hr_h2pi_map.get_to_id
                        (p_table_name  => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                         p_from_id     => v_ud_ppm.personal_payment_method_id);

    --
    IF v_ud_ppm.payee_type = 'O'  THEN
      hr_utility.set_location(l_proc, 71);
      l_payee_type :=  v_ud_ppm.payee_type;
      l_payee_id :=  hr_h2pi_map.get_to_id
                        (p_table_name  => 'HR_ALL_ORGANIZATION_UNITS',
                         p_from_id     => v_ud_ppm.payee_id);

    ELSIF v_ud_ppm.payee_type = 'P' THEN
      hr_utility.set_location(l_proc, 72);
      l_payee_type := null;
      l_payee_id := null;
      hr_h2pi_error.data_error
                (p_from_id       => v_ud_ppm.payee_id,
                 p_table_name    => 'HR_H2PI_EMPLOYEES',
                 p_message_level => 'FATAL',
                 p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
    ELSE
      l_payee_type := v_ud_ppm.payee_type;
      l_payee_id   := v_ud_ppm.payee_id;
    END IF;
    --

    IF l_personal_pay_method_id = -1 THEN
      hr_utility.set_location(l_proc, 80);
      hr_personal_pay_method_api.create_personal_pay_method(
             p_effective_date             => v_ud_ppm.effective_start_date
            ,p_assignment_id              => l_assignment_id
            ,p_org_payment_method_id      => l_org_pay_method_id
            ,p_amount                     => v_ud_ppm.amount
            ,p_percentage                 => v_ud_ppm.percentage
            ,p_priority	                  => v_ud_ppm.priority
            ,p_attribute_category         => v_ud_ppm.attribute_category
            ,p_attribute1                 => v_ud_ppm.attribute1
            ,p_attribute2                 => v_ud_ppm.attribute2
            ,p_attribute3                 => v_ud_ppm.attribute3
            ,p_attribute4                 => v_ud_ppm.attribute4
            ,p_attribute5                 => v_ud_ppm.attribute5
            ,p_attribute6                 => v_ud_ppm.attribute6
            ,p_attribute7                 => v_ud_ppm.attribute7
            ,p_attribute8                 => v_ud_ppm.attribute8
            ,p_attribute9                 => v_ud_ppm.attribute9
            ,p_attribute10                => v_ud_ppm.attribute10
            ,p_attribute11                => v_ud_ppm.attribute11
            ,p_attribute12                => v_ud_ppm.attribute12
            ,p_attribute13                => v_ud_ppm.attribute13
            ,p_attribute14                => v_ud_ppm.attribute14
            ,p_attribute15                => v_ud_ppm.attribute15
            ,p_attribute16                => v_ud_ppm.attribute16
            ,p_attribute17                => v_ud_ppm.attribute17
            ,p_attribute18                => v_ud_ppm.attribute18
            ,p_attribute19                => v_ud_ppm.attribute19
            ,p_attribute20                => v_ud_ppm.attribute20
            ,p_territory_code             => v_ud_ppm.territory_code
            ,p_segment1                   => v_ud_ppm.segment1
            ,p_segment2                   => v_ud_ppm.segment2
            ,p_segment3                   => v_ud_ppm.segment3
            ,p_segment4                   => v_ud_ppm.segment4
            ,p_segment5                   => v_ud_ppm.segment5
            ,p_segment6                   => v_ud_ppm.segment6
            ,p_segment7                   => v_ud_ppm.segment7
            ,p_segment8                   => v_ud_ppm.segment8
            ,p_segment9                   => v_ud_ppm.segment9
            ,p_segment10                  => v_ud_ppm.segment10
            ,p_segment11                  => v_ud_ppm.segment11
            ,p_segment12                  => v_ud_ppm.segment12
            ,p_segment13                  => v_ud_ppm.segment13
            ,p_segment14                  => v_ud_ppm.segment14
            ,p_segment15                  => v_ud_ppm.segment15
            ,p_segment16                  => v_ud_ppm.segment16
            ,p_segment17                  => v_ud_ppm.segment17
            ,p_segment18                  => v_ud_ppm.segment18
            ,p_segment19                  => v_ud_ppm.segment19
            ,p_segment20                  => v_ud_ppm.segment20
            ,p_segment21                  => v_ud_ppm.segment21
            ,p_segment22                  => v_ud_ppm.segment22
            ,p_segment23                  => v_ud_ppm.segment23
            ,p_segment24                  => v_ud_ppm.segment24
            ,p_segment25                  => v_ud_ppm.segment25
            ,p_segment26                  => v_ud_ppm.segment26
            ,p_segment27                  => v_ud_ppm.segment27
            ,p_segment28                  => v_ud_ppm.segment28
            ,p_segment29                  => v_ud_ppm.segment29
            ,p_segment30                  => v_ud_ppm.segment30
             --
            ,p_payee_type                 => l_payee_type
            ,p_payee_id                   => l_payee_id
             --
            ,p_personal_payment_method_id => l_personal_pay_method_id
            ,p_external_account_id        => l_external_account_id
            ,p_object_version_number      => l_ovn
            ,p_effective_start_date       => l_esd
            ,p_effective_end_date         => l_eed
            ,p_comment_id                 => l_comment_id
            );

      hr_utility.set_location(l_proc, 90);
      hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                       p_from_id    => v_ud_ppm.personal_payment_method_id,
                       p_to_id      => l_personal_pay_method_id);
    ELSE

      BEGIN
        hr_utility.set_location(l_proc, 100);
        OPEN csr_ed_payment_method(l_personal_pay_method_id,
                                   v_ud_ppm.effective_start_date);
        FETCH csr_ed_payment_method
        INTO  v_ed_ppm;
        IF csr_ed_payment_method%NOTFOUND THEN
          hr_utility.set_location(l_proc, 110);
          CLOSE csr_ed_payment_method;
          ROLLBACK;
          hr_utility.set_location(l_proc, 120);
          hr_h2pi_error.data_error
               (p_from_id       => l_personal_pay_method_id,
                p_table_name    => 'HR_H2PI_PAYMENT_METHODS',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
          COMMIT;
          RAISE MAPPING_ID_INVALID;
        ELSE
          CLOSE csr_ed_payment_method;
        END IF;

        OPEN csr_ed_payment_method_ovn(l_personal_pay_method_id,
                                       v_ud_ppm.effective_start_date);
        FETCH csr_ed_payment_method_ovn
        INTO  l_ovn;
        CLOSE csr_ed_payment_method_ovn;
      END;

      l_delete_mode := 'DELETE_NEXT_CHANGE';
      LOOP
      hr_utility.set_location(l_proc, 120);
        l_records_same := FALSE;

        SELECT MAX(ppm.effective_end_date)
        INTO   l_max_eed
        FROM   pay_personal_payment_methods_f ppm
        WHERE  ppm.personal_payment_method_id = l_personal_pay_method_id;

        IF l_max_eed > v_ed_ppm.effective_end_date THEN
          hr_utility.set_location(l_proc, 130);
          l_future_records := TRUE;
        ELSE
          hr_utility.set_location(l_proc, 135);
          l_future_records := FALSE;
        END IF;

        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_ppm.effective_start_date
            ,p_ud_end_date    => v_ud_ppm.effective_end_date
            ,p_ed_start_date  => v_ed_ppm.effective_start_date
            ,p_ed_end_date    => v_ed_ppm.effective_end_date
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);

        EXIT WHEN l_delete_mode = 'X';

        IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

          hr_utility.set_location(l_proc, 140);
          hr_personal_pay_method_api.delete_personal_pay_method(
               p_effective_date             => v_ud_ppm.effective_start_date
              ,p_datetrack_delete_mode      => l_delete_mode
              ,p_personal_payment_method_id => l_personal_pay_method_id
              ,p_object_version_number      => l_ovn
              ,p_effective_start_date       => l_esd
              ,p_effective_end_date         => l_eed
              );

          hr_utility.set_location(l_proc, 150);
          OPEN csr_ed_payment_method(l_personal_pay_method_id,
                                     v_ud_ppm.effective_start_date);
          FETCH csr_ed_payment_method
          INTO  v_ed_ppm;
          CLOSE csr_ed_payment_method;

        END IF;

      END LOOP;

      hr_personal_pay_method_api.update_personal_pay_method(
             p_effective_date        => v_ud_ppm.effective_start_date
            ,p_datetrack_update_mode => l_update_mode
            ,p_amount                => v_ud_ppm.amount
            ,p_percentage            => v_ud_ppm.percentage
            ,p_priority	             => v_ud_ppm.priority
            ,p_attribute_category    => v_ud_ppm.attribute_category
            ,p_attribute1            => v_ud_ppm.attribute1
            ,p_attribute2            => v_ud_ppm.attribute2
            ,p_attribute3            => v_ud_ppm.attribute3
            ,p_attribute4            => v_ud_ppm.attribute4
            ,p_attribute5            => v_ud_ppm.attribute5
            ,p_attribute6            => v_ud_ppm.attribute6
            ,p_attribute7            => v_ud_ppm.attribute7
            ,p_attribute8            => v_ud_ppm.attribute8
            ,p_attribute9            => v_ud_ppm.attribute9
            ,p_attribute10           => v_ud_ppm.attribute10
            ,p_attribute11           => v_ud_ppm.attribute11
            ,p_attribute12           => v_ud_ppm.attribute12
            ,p_attribute13           => v_ud_ppm.attribute13
            ,p_attribute14           => v_ud_ppm.attribute14
            ,p_attribute15           => v_ud_ppm.attribute15
            ,p_attribute16           => v_ud_ppm.attribute16
            ,p_attribute17           => v_ud_ppm.attribute17
            ,p_attribute18           => v_ud_ppm.attribute18
            ,p_attribute19           => v_ud_ppm.attribute19
            ,p_attribute20           => v_ud_ppm.attribute20
            ,p_territory_code        => v_ud_ppm.territory_code
            ,p_segment1              => v_ud_ppm.segment1
            ,p_segment2              => v_ud_ppm.segment2
            ,p_segment3              => v_ud_ppm.segment3
            ,p_segment4              => v_ud_ppm.segment4
            ,p_segment5              => v_ud_ppm.segment5
            ,p_segment6              => v_ud_ppm.segment6
            ,p_segment7              => v_ud_ppm.segment7
            ,p_segment8              => v_ud_ppm.segment8
            ,p_segment9              => v_ud_ppm.segment9
            ,p_segment10             => v_ud_ppm.segment10
            ,p_segment11             => v_ud_ppm.segment11
            ,p_segment12             => v_ud_ppm.segment12
            ,p_segment13             => v_ud_ppm.segment13
            ,p_segment14             => v_ud_ppm.segment14
            ,p_segment15             => v_ud_ppm.segment15
            ,p_segment16             => v_ud_ppm.segment16
            ,p_segment17             => v_ud_ppm.segment17
            ,p_segment18             => v_ud_ppm.segment18
            ,p_segment19             => v_ud_ppm.segment19
            ,p_segment20             => v_ud_ppm.segment20
            ,p_segment21             => v_ud_ppm.segment21
            ,p_segment22             => v_ud_ppm.segment22
            ,p_segment23             => v_ud_ppm.segment23
            ,p_segment24             => v_ud_ppm.segment24
            ,p_segment25             => v_ud_ppm.segment25
            ,p_segment26             => v_ud_ppm.segment26
            ,p_segment27             => v_ud_ppm.segment27
            ,p_segment28             => v_ud_ppm.segment28
            ,p_segment29             => v_ud_ppm.segment29
            ,p_segment30             => v_ud_ppm.segment30
            ,p_personal_payment_method_id => l_personal_pay_method_id
            ,p_object_version_number => l_ovn
            ,p_external_account_id   => l_external_account_id
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_comment_id            => l_comment_id
            );

    END IF;
  END IF;

  hr_utility.set_location(l_proc, 200);
  UPDATE hr_h2pi_payment_methods ppm
  SET status = 'C'
  WHERE  ppm.personal_payment_method_id = v_ud_ppm.personal_payment_method_id
  AND    ppm.client_id  = p_from_client_id
  AND    ppm.effective_start_date       = v_ud_ppm.effective_start_date
  AND    ppm.effective_end_date         = v_ud_ppm.effective_end_date;

  CLOSE csr_ud_payment_method;
  hr_utility.set_location('Leaving:'|| l_proc, 210);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 230);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_ppm.personal_payment_method_id,
                p_table_name           => 'HR_H2PI_PAYMENT_METHODS',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;
END;


PROCEDURE upload_cost_allocation (p_from_client_id NUMBER,
                                  p_cost_allocation_id     NUMBER,
                                  p_effective_start_date   DATE) IS

CURSOR csr_ud_cost_allocation (p_cost_allocation_id NUMBER,
                               p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_cost_allocations hca
  WHERE  hca.cost_allocation_id = p_cost_allocation_id
  AND    hca.client_id                  = p_from_client_id
  AND    hca.effective_start_date       = p_esd;

CURSOR csr_ed_cost_allocation (p_cost_allocation_id NUMBER,
                               p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_cost_allocations_v hca
  WHERE  hca.cost_allocation_id = p_cost_allocation_id
  AND    p_esd BETWEEN hca.effective_start_date
                   AND hca.effective_end_date;

CURSOR csr_ed_cost_allocation_ovn (p_cost_allocation_id NUMBER,
                                  p_esd    DATE) IS
  SELECT pca.object_version_number
  FROM   pay_cost_allocations_f pca
  WHERE  pca.cost_allocation_id = p_cost_allocation_id
  AND    p_esd BETWEEN pca.effective_start_date
                   AND pca.effective_end_date;

l_encoded_message              VARCHAR2(200);
l_proc                         VARCHAR2(72) := g_package||'upload_cost_allocation';

v_ud_hca                       hr_h2pi_cost_allocations%ROWTYPE;
v_ed_hca                       hr_h2pi_cost_allocations_v%ROWTYPE;

l_assignment_id                pay_cost_allocations_f.assignment_id%TYPE;
l_cost_allocation_id           pay_cost_allocations_f.cost_allocation_id%TYPE;
l_combination_name             VARCHAR2(240);
l_cost_allocation_keyflex_id   pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
l_ovn                          pay_cost_allocations_f.object_version_number%TYPE;
l_esd                          pay_cost_allocations_f.effective_start_date%TYPE;
l_eed                          pay_cost_allocations_f.effective_end_date%TYPE;

l_max_eed                      pay_cost_allocations_f.effective_end_date%TYPE;
l_del_ovn                      pay_cost_allocations_f.object_version_number%TYPE;
l_del_esd                      pay_cost_allocations_f.effective_start_date%TYPE;
l_del_eed                      pay_cost_allocations_f.effective_end_date%TYPE;
l_val_esd                      pay_cost_allocations_f.effective_start_date%TYPE;
l_val_eed                      pay_cost_allocations_f.effective_end_date%TYPE;
l_business_group_id            pay_cost_allocations_f.business_group_id%TYPE;

l_records_same       BOOLEAN;
l_future_records     BOOLEAN;
l_update_mode        VARCHAR2(30);
l_delete_mode        VARCHAR2(30);


BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_cost_allocation(p_cost_allocation_id,
                              p_effective_start_date);
  FETCH csr_ud_cost_allocation INTO v_ud_hca;

  IF v_ud_hca.last_upd_date = g_eot THEN

    hr_utility.set_location(l_proc, 20);
    l_cost_allocation_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PAY_COST_ALLOCATIONS_F',
                         p_from_id      => v_ud_hca.cost_allocation_id,
                         p_report_error => TRUE);

    hr_utility.set_location(l_proc, 30);
    OPEN csr_ed_cost_allocation_ovn(l_cost_allocation_id,
                                    v_ud_hca.effective_start_date);
    FETCH csr_ed_cost_allocation_ovn
    INTO  l_ovn;

    IF csr_ed_cost_allocation_ovn%FOUND THEN

       l_delete_mode := 'DELETE';
       pay_cost_allocation_api.delete_cost_allocation(
            p_validate              => FALSE
           ,p_effective_date        => v_ud_hca.effective_start_date - 1
           ,p_datetrack_delete_mode => l_delete_mode
           ,p_cost_allocation_id    => l_cost_allocation_id
           ,p_object_version_number => l_ovn
           ,p_effective_start_date  => l_esd
           ,p_effective_end_date    => l_eed);

    END IF;

    CLOSE csr_ed_cost_allocation_ovn;
  ELSE

    hr_utility.set_location(l_proc, 40);
    l_assignment_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                             p_from_id      => v_ud_hca.assignment_id,
                             p_report_error => TRUE);

    l_cost_allocation_id := hr_h2pi_map.get_to_id
                             (p_table_name  => 'PAY_COST_ALLOCATIONS_F',
                              p_from_id     => v_ud_hca.cost_allocation_id);

    IF l_cost_allocation_id = -1 THEN
      hr_utility.set_location(l_proc, 50);
      pay_cost_allocation_api.create_cost_allocation(
          p_effective_date                => v_ud_hca.effective_start_date
         ,p_assignment_id                 => l_assignment_id
         ,p_proportion                    => v_ud_hca.proportion
         ,p_business_group_id             => hr_h2pi_upload.g_to_business_group_id
         ,p_segment1                      => v_ud_hca.segment1
         ,p_segment2                      => v_ud_hca.segment2
         ,p_segment3                      => v_ud_hca.segment3
         ,p_segment4                      => v_ud_hca.segment4
         ,p_segment5                      => v_ud_hca.segment5
         ,p_segment6                      => v_ud_hca.segment6
         ,p_segment7                      => v_ud_hca.segment7
         ,p_segment8                      => v_ud_hca.segment8
         ,p_segment9                      => v_ud_hca.segment9
         ,p_segment10                     => v_ud_hca.segment10
         ,p_segment11                     => v_ud_hca.segment11
         ,p_segment12                     => v_ud_hca.segment12
         ,p_segment13                     => v_ud_hca.segment13
         ,p_segment14                     => v_ud_hca.segment14
         ,p_segment15                     => v_ud_hca.segment15
         ,p_segment16                     => v_ud_hca.segment16
         ,p_segment17                     => v_ud_hca.segment17
         ,p_segment18                     => v_ud_hca.segment18
         ,p_segment19                     => v_ud_hca.segment19
         ,p_segment20                     => v_ud_hca.segment20
         ,p_segment21                     => v_ud_hca.segment21
         ,p_segment22                     => v_ud_hca.segment22
         ,p_segment23                     => v_ud_hca.segment23
         ,p_segment24                     => v_ud_hca.segment24
         ,p_segment25                     => v_ud_hca.segment25
         ,p_segment26                     => v_ud_hca.segment26
         ,p_segment27                     => v_ud_hca.segment27
         ,p_segment28                     => v_ud_hca.segment28
         ,p_segment29                     => v_ud_hca.segment29
         ,p_segment30                     => v_ud_hca.segment30
         ,p_concat_segments               => v_ud_hca.concatenated_segments
         ,p_combination_name              => l_combination_name
         ,p_cost_allocation_id            => l_cost_allocation_id
         ,p_effective_start_date          => l_esd
         ,p_effective_end_date            => l_eed
         ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
         ,p_object_version_number         => l_ovn );

      hr_utility.set_location(l_proc, 60);
      hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PAY_COST_ALLOCATIONS_F',
                       p_from_id    => v_ud_hca.cost_allocation_id,
                       p_to_id      => l_cost_allocation_id);
    ELSE

      BEGIN
        hr_utility.set_location(l_proc, 70);
        OPEN csr_ed_cost_allocation(l_cost_allocation_id,
                                    v_ud_hca.effective_start_date);
        FETCH csr_ed_cost_allocation
        INTO  v_ed_hca;
        IF csr_ed_cost_allocation%NOTFOUND THEN
          hr_utility.set_location(l_proc, 80);
          CLOSE csr_ed_cost_allocation;
          ROLLBACK;
          hr_utility.set_location(l_proc, 90);
          hr_h2pi_error.data_error
               (p_from_id       => l_cost_allocation_id,
                p_table_name    => 'HR_H2PI_COST_ALLOCATIONS',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
          COMMIT;
          RAISE MAPPING_ID_INVALID;
        ELSE
          CLOSE csr_ed_cost_allocation;
        END IF;

        OPEN csr_ed_cost_allocation_ovn(l_cost_allocation_id,
                                        v_ud_hca.effective_start_date);
        FETCH csr_ed_cost_allocation_ovn
        INTO  l_ovn;
        CLOSE csr_ed_cost_allocation_ovn;
      END;

      l_delete_mode := 'DELETE_NEXT_CHANGE';
      LOOP
      hr_utility.set_location(l_proc, 100);
        l_records_same := FALSE;

        SELECT MAX(caf.effective_end_date)
        INTO   l_max_eed
        FROM   pay_cost_allocations_f caf
        WHERE  caf.cost_allocation_id = l_cost_allocation_id;

        IF l_max_eed > v_ed_hca.effective_end_date THEN
          hr_utility.set_location(l_proc, 110);
          l_future_records := TRUE;
        ELSE
          hr_utility.set_location(l_proc, 120);
          l_future_records := FALSE;
        END IF;

        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_hca.effective_start_date
            ,p_ud_end_date    => v_ud_hca.effective_end_date
            ,p_ed_start_date  => v_ed_hca.effective_start_date
            ,p_ed_end_date    => v_ed_hca.effective_end_date
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);

        EXIT WHEN l_delete_mode = 'X';
        hr_utility.set_location(l_proc, 130);

        IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

          hr_utility.set_location(l_proc, 140);
          pay_cost_allocation_api.delete_cost_allocation(
               p_effective_date         => v_ud_hca.effective_start_date
              ,p_datetrack_delete_mode  => l_delete_mode
              ,p_cost_allocation_id     => l_cost_allocation_id
              ,p_object_version_number  => l_ovn
              ,p_effective_start_date   => l_esd
              ,p_effective_end_date     => l_eed );

          hr_utility.set_location(l_proc, 150);
          OPEN csr_ed_cost_allocation(l_cost_allocation_id,
                                      v_ud_hca.effective_start_date);
          FETCH csr_ed_cost_allocation
          INTO  v_ed_hca;
          CLOSE csr_ed_cost_allocation;

        END IF;

      END LOOP;

      hr_utility.set_location(l_proc, 160);
      pay_cost_allocation_api.update_cost_allocation(
          p_effective_date                => v_ud_hca.effective_start_date
         ,p_datetrack_update_mode         => l_update_mode
         ,p_cost_allocation_id            => l_cost_allocation_id
         ,p_object_version_number         => l_ovn
         ,p_proportion                    => v_ud_hca.proportion
         ,p_segment1                      => v_ud_hca.segment1
         ,p_segment2                      => v_ud_hca.segment2
         ,p_segment3                      => v_ud_hca.segment3
         ,p_segment4                      => v_ud_hca.segment4
         ,p_segment5                      => v_ud_hca.segment5
         ,p_segment6                      => v_ud_hca.segment6
         ,p_segment7                      => v_ud_hca.segment7
         ,p_segment8                      => v_ud_hca.segment8
         ,p_segment9                      => v_ud_hca.segment9
         ,p_segment10                     => v_ud_hca.segment10
         ,p_segment11                     => v_ud_hca.segment11
         ,p_segment12                     => v_ud_hca.segment12
         ,p_segment13                     => v_ud_hca.segment13
         ,p_segment14                     => v_ud_hca.segment14
         ,p_segment15                     => v_ud_hca.segment15
         ,p_segment16                     => v_ud_hca.segment16
         ,p_segment17                     => v_ud_hca.segment17
         ,p_segment18                     => v_ud_hca.segment18
         ,p_segment19                     => v_ud_hca.segment19
         ,p_segment20                     => v_ud_hca.segment20
         ,p_segment21                     => v_ud_hca.segment21
         ,p_segment22                     => v_ud_hca.segment22
         ,p_segment23                     => v_ud_hca.segment23
         ,p_segment24                     => v_ud_hca.segment24
         ,p_segment25                     => v_ud_hca.segment25
         ,p_segment26                     => v_ud_hca.segment26
         ,p_segment27                     => v_ud_hca.segment27
         ,p_segment28                     => v_ud_hca.segment28
         ,p_segment29                     => v_ud_hca.segment29
         ,p_segment30                     => v_ud_hca.segment30
         ,p_concat_segments               => v_ud_hca.concatenated_segments
         ,p_combination_name              => l_combination_name
         ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
         ,p_effective_start_date          => l_esd
         ,p_effective_end_date            => l_eed );

    END IF;
  END IF;

  hr_utility.set_location(l_proc, 170);
  UPDATE hr_h2pi_cost_allocations hca
  SET status = 'C'
  WHERE  hca.cost_allocation_id   = v_ud_hca.cost_allocation_id
  AND    hca.client_id            = p_from_client_id
  AND    hca.effective_start_date = v_ud_hca.effective_start_date
  AND    hca.effective_end_date   = v_ud_hca.effective_end_date;

  CLOSE csr_ud_cost_allocation;
  hr_utility.set_location('Leaving:'|| l_proc, 180);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 190);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_hca.cost_allocation_id,
                p_table_name           => 'HR_H2PI_COST_ALLOCATIONS',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


PROCEDURE upload_element_entry (p_from_client_id NUMBER,
                                p_element_entry_id       NUMBER,
                                p_effective_start_date   DATE) IS

CURSOR csr_ud_element_entry (p_ele_id NUMBER,
                             p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_element_entries ele
  WHERE  ele.element_entry_id = p_ele_id
  AND    ele.client_id        = p_from_client_id
  AND    ele.effective_start_date   = p_esd;

CURSOR csr_ud_element_entry_value (p_ele_id NUMBER,
                                   p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_element_entry_values eev
  WHERE  eev.element_entry_id     = p_ele_id
  AND    eev.screen_entry_value   IS NOT NULL
  AND    eev.client_id  = p_from_client_id
  AND    p_esd BETWEEN eev.effective_start_date
                   AND eev.effective_end_date;

CURSOR csr_ed_element_entry (p_ele_id NUMBER,
                             p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_element_entries_v ele
  WHERE  ele.element_entry_id = p_ele_id
  AND    p_esd BETWEEN ele.effective_start_date
                   AND ele.effective_end_date;

CURSOR csr_ed_element_entry_ovn (p_ele_id NUMBER,
                                 p_esd    DATE) IS
  SELECT ele.object_version_number
  FROM   pay_element_entries_f ele
  WHERE  ele.element_entry_id = p_ele_id
  AND    p_esd BETWEEN ele.effective_start_date
                   AND ele.effective_end_date;

l_encoded_message    VARCHAR2(200);

l_proc               VARCHAR2(72) := g_package||'upload_element_entry';


TYPE eev_array IS VARRAY(15) OF hr_h2pi_element_entry_values.screen_entry_value%TYPE;
TYPE iv_array IS VARRAY(15) OF hr_h2pi_element_entry_values.input_value_id%TYPE;

v_ud_ele             hr_h2pi_element_entries%ROWTYPE;
a_ud_sev             eev_array := eev_array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                       NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
v_ed_ele             hr_h2pi_element_entries_v%ROWTYPE;

l_index              NUMBER;
a_input_value_id     iv_array := iv_array(NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                     NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
l_assignment_id      per_all_assignments_f.assignment_id%TYPE;
l_element_entry_id   pay_element_entries_f.element_entry_id%TYPE;
l_element_link_id    pay_element_entries_f.element_link_id%TYPE;
l_cost_allocation_keyflex_id
                     pay_element_entries_f.cost_allocation_keyflex_id%TYPE;
l_id_flex_num        pay_cost_allocation_keyflex.id_flex_num%TYPE;
l_ovn                pay_element_entries_f.object_version_number%TYPE;
l_esd                pay_element_entries_f.effective_start_date%TYPE;
l_eed                pay_element_entries_f.effective_end_date%TYPE;
l_uom                pay_input_values_f.uom%TYPE;

l_max_eed            pay_element_entries_f.effective_end_date%TYPE;
l_del_ovn            pay_element_entries_f.object_version_number%TYPE;
l_del_esd            pay_element_entries_f.effective_start_date%TYPE;
l_del_eed            pay_element_entries_f.effective_end_date%TYPE;
l_val_esd            pay_element_entries_f.effective_start_date%TYPE;
l_val_eed            pay_element_entries_f.effective_end_date%TYPE;

l_records_same       BOOLEAN;
l_future_records     BOOLEAN;
l_update_mode        VARCHAR2(30);
l_delete_mode        VARCHAR2(30);

l_create_warning     BOOLEAN;
l_delete_warning     BOOLEAN;
l_update_warning     BOOLEAN;
l_ee_personal_pay_method_id pay_element_entries_f.personal_payment_method_id%TYPE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_element_entry(p_element_entry_id,
                             p_effective_start_date);
  FETCH csr_ud_element_entry INTO v_ud_ele;

  IF v_ud_ele.last_upd_date = g_eot THEN

    hr_utility.set_location(l_proc, 20);
    l_element_entry_id := hr_h2pi_map.get_to_id
                        (p_table_name   => 'PAY_ELEMENT_ENTRIES_F',
                         p_from_id      => v_ud_ele.element_entry_id,
                         p_report_error => TRUE);

    hr_utility.set_location(l_proc, 30);
    OPEN csr_ed_element_entry_ovn(l_element_entry_id,
                                   v_ud_ele.effective_start_date);
    FETCH csr_ed_element_entry_ovn
    INTO  l_ovn;

    IF csr_ed_element_entry_ovn%FOUND THEN

      l_delete_mode := 'DELETE';
      py_element_entry_api.delete_element_entry(
             p_effective_date        => v_ud_ele.effective_start_date-1
            ,p_datetrack_delete_mode => l_delete_mode
            ,p_element_entry_id      => l_element_entry_id
            ,p_object_version_number => l_ovn
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_delete_warning        => l_delete_warning
            );
    END IF;

    CLOSE csr_ed_element_entry_ovn;

  ELSE
    l_index := 1;
    FOR v_ud_eev IN csr_ud_element_entry_value
                       (v_ud_ele.element_entry_id,
                        v_ud_ele.effective_start_date) LOOP
      a_input_value_id(l_index) := hr_h2pi_map.get_to_id
                               (p_table_name   => 'PAY_INPUT_VALUES_F',
                                p_from_id      => v_ud_eev.input_value_id,
                                p_report_error => TRUE);
      BEGIN
        SELECT uom
        INTO   l_uom
        FROM   pay_input_values_f
        WHERE  input_value_id = a_input_value_id(l_index)
        AND    v_ud_ele.effective_start_date BETWEEN effective_start_date
                                                 AND effective_end_date;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ROLLBACK;
          hr_utility.set_location(l_proc, 35);
          hr_h2pi_error.data_error
               (p_from_id       => a_input_value_id(l_index),
                p_table_name    => 'HR_H2PI_ELEMENT_ENTRY_VALUES',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
          COMMIT;
        RAISE MAPPING_ID_INVALID;
      END;

      IF l_uom = 'D' THEN
        a_ud_sev(l_index) := TO_CHAR(TRUNC(TO_DATE(v_ud_eev.screen_entry_value,
                                     'YYYY/MM/DD HH24:MI:SS')), 'DD-MON-YYYY');
      ELSE
        a_ud_sev(l_index) := v_ud_eev.screen_entry_value;
      END IF;
      l_index := l_index + 1;
    END LOOP;

    hr_utility.set_location(l_proc, 40);
    l_assignment_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                             p_from_id      => v_ud_ele.assignment_id,
                             p_report_error => TRUE);

    l_element_entry_id := hr_h2pi_map.get_to_id
                        (p_table_name  => 'PAY_ELEMENT_ENTRIES_F',
                         p_from_id     => v_ud_ele.element_entry_id);

    IF  v_ud_ele.personal_payment_method_id IS NOT NULL THEN
      l_ee_personal_pay_method_id := hr_h2pi_map.get_to_id
                          (p_table_name  => 'PAY_PERSONAL_PAYMENT_METHODS_F',
                           p_from_id     => v_ud_ele.personal_payment_method_id);
    ELSE
      l_ee_personal_pay_method_id := NULL;
    END IF;

    -- If no mapping found then set personal_payment_method_id to null
    IF l_ee_personal_pay_method_id = -1 THEN
      l_ee_personal_pay_method_id := NULL;
    END IF;

    hr_utility.set_location('l_ee_personal_pay_method_id = '||
                                 to_char(l_ee_personal_pay_method_id),1010);

    hr_utility.set_location('Getting cost_allocation_keyflex 1',1011);

    -- Get id_flex_num using function
    l_id_flex_num := get_costing_id_flex_num;

    /* l_id_flex_num := hr_h2pi_map.get_to_id
                        (p_table_name  => 'COST_ALLOCATION_KEYFLEX',
                         p_from_id     => v_ud_ele.id_flex_num);
    */

    hr_utility.set_location('cost_allocation_keyflex 1' || l_id_flex_num, 1020);

    IF l_element_entry_id = -1 THEN
      hr_utility.set_location(l_proc, 50);
      l_element_link_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PAY_ELEMENT_LINKS_F',
                             p_from_id      => v_ud_ele.element_link_id,
                             p_report_error => TRUE);

      l_cost_allocation_keyflex_id := hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => l_id_flex_num
           ,p_cost_allocation_keyflex_id => -1
           ,p_concatenated_segments      => v_ud_ele.concatenated_segments
           ,p_summary_flag               => v_ud_ele.summary_flag
           ,p_start_date_active          => v_ud_ele.start_date_active
           ,p_end_date_active            => v_ud_ele.end_date_active
           ,p_segment1                   => v_ud_ele.segment1
           ,p_segment2                   => v_ud_ele.segment2
           ,p_segment3                   => v_ud_ele.segment3
           ,p_segment4                   => v_ud_ele.segment4
           ,p_segment5                   => v_ud_ele.segment5
           ,p_segment6                   => v_ud_ele.segment6
           ,p_segment7                   => v_ud_ele.segment7
           ,p_segment8                   => v_ud_ele.segment8
           ,p_segment9                   => v_ud_ele.segment9
           ,p_segment10                  => v_ud_ele.segment10
           ,p_segment11                  => v_ud_ele.segment11
           ,p_segment12                  => v_ud_ele.segment12
           ,p_segment13                  => v_ud_ele.segment13
           ,p_segment14                  => v_ud_ele.segment14
           ,p_segment15                  => v_ud_ele.segment15
           ,p_segment16                  => v_ud_ele.segment16
           ,p_segment17                  => v_ud_ele.segment17
           ,p_segment18                  => v_ud_ele.segment18
           ,p_segment19                  => v_ud_ele.segment19
           ,p_segment20                  => v_ud_ele.segment20
           ,p_segment21                  => v_ud_ele.segment21
           ,p_segment22                  => v_ud_ele.segment22
           ,p_segment23                  => v_ud_ele.segment23
           ,p_segment24                  => v_ud_ele.segment24
           ,p_segment25                  => v_ud_ele.segment25
           ,p_segment26                  => v_ud_ele.segment26
           ,p_segment27                  => v_ud_ele.segment27
           ,p_segment28                  => v_ud_ele.segment28
           ,p_segment29                  => v_ud_ele.segment29
           ,p_segment30                  => v_ud_ele.segment30
           );

      py_element_entry_api.create_element_entry(
             p_effective_date	   => v_ud_ele.effective_start_date
            ,p_business_group_id   => hr_h2pi_upload.g_to_business_group_id
            ,p_assignment_id	   => l_assignment_id
            ,p_element_link_id	   => l_element_link_id
            ,p_entry_type	   => v_ud_ele.entry_type
    --        ,p_subpriority	   => v_ud_ele.subpriority
            ,p_date_earned	   => v_ud_ele.date_earned
            ,p_personal_payment_method_id => l_ee_personal_pay_method_id
            ,p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id
            ,p_attribute_category  => v_ud_ele.attribute_category
            ,p_attribute1          => v_ud_ele.attribute1
            ,p_attribute2          => v_ud_ele.attribute2
            ,p_attribute3          => v_ud_ele.attribute3
            ,p_attribute4          => v_ud_ele.attribute4
            ,p_attribute5          => v_ud_ele.attribute5
            ,p_attribute6          => v_ud_ele.attribute6
            ,p_attribute7          => v_ud_ele.attribute7
            ,p_attribute8          => v_ud_ele.attribute8
            ,p_attribute9          => v_ud_ele.attribute9
            ,p_attribute10         => v_ud_ele.attribute10
            ,p_attribute11         => v_ud_ele.attribute11
            ,p_attribute12         => v_ud_ele.attribute12
            ,p_attribute13         => v_ud_ele.attribute13
            ,p_attribute14         => v_ud_ele.attribute14
            ,p_attribute15         => v_ud_ele.attribute15
            ,p_attribute16         => v_ud_ele.attribute16
            ,p_attribute17         => v_ud_ele.attribute17
            ,p_attribute18         => v_ud_ele.attribute18
            ,p_attribute19         => v_ud_ele.attribute19
            ,p_attribute20         => v_ud_ele.attribute20
            ,p_input_value_id1 	   => a_input_value_id(1)
            ,p_input_value_id2 	   => a_input_value_id(2)
            ,p_input_value_id3 	   => a_input_value_id(3)
            ,p_input_value_id4 	   => a_input_value_id(4)
            ,p_input_value_id5 	   => a_input_value_id(5)
            ,p_input_value_id6 	   => a_input_value_id(6)
            ,p_input_value_id7 	   => a_input_value_id(7)
            ,p_input_value_id8     => a_input_value_id(8)
            ,p_input_value_id9 	   => a_input_value_id(9)
            ,p_input_value_id10	   => a_input_value_id(10)
            ,p_input_value_id11	   => a_input_value_id(11)
            ,p_input_value_id12	   => a_input_value_id(12)
            ,p_input_value_id13	   => a_input_value_id(13)
            ,p_input_value_id14	   => a_input_value_id(14)
            ,p_input_value_id15	   => a_input_value_id(15)
            ,p_entry_value1 	   => a_ud_sev(1)
            ,p_entry_value2 	   => a_ud_sev(2)
            ,p_entry_value3 	   => a_ud_sev(3)
            ,p_entry_value4 	   => a_ud_sev(4)
            ,p_entry_value5 	   => a_ud_sev(5)
            ,p_entry_value6 	   => a_ud_sev(6)
            ,p_entry_value7 	   => a_ud_sev(7)
            ,p_entry_value8 	   => a_ud_sev(8)
            ,p_entry_value9 	   => a_ud_sev(9)
            ,p_entry_value10 	   => a_ud_sev(10)
            ,p_entry_value11 	   => a_ud_sev(11)
            ,p_entry_value12 	   => a_ud_sev(12)
            ,p_entry_value13 	   => a_ud_sev(13)
            ,p_entry_value14 	   => a_ud_sev(14)
            ,p_entry_value15 	   => a_ud_sev(15)
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_element_entry_id      => l_element_entry_id
            ,p_object_version_number => l_ovn
            ,p_create_warning        => l_create_warning
             );

      hr_utility.set_location(l_proc, 60);
      hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PAY_ELEMENT_ENTRIES_F',
                       p_from_id    => v_ud_ele.element_entry_id,
                       p_to_id      => l_element_entry_id);

    ELSE

      BEGIN
        hr_utility.set_location(l_proc, 70);
        OPEN csr_ed_element_entry(l_element_entry_id,
                                  v_ud_ele.effective_start_date);
        FETCH csr_ed_element_entry
        INTO  v_ed_ele;
        IF csr_ed_element_entry%NOTFOUND THEN
          hr_utility.set_location(l_proc, 80);
          CLOSE csr_ed_element_entry;
          ROLLBACK;
          hr_utility.set_location(l_proc, 90);
          hr_h2pi_error.data_error
               (p_from_id       => l_element_entry_id,
                p_table_name    => 'HR_H2PI_ELEMENT_ENTRIES',
                p_message_level => 'FATAL',
                p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
          COMMIT;
          RAISE MAPPING_ID_INVALID;
        ELSE
          CLOSE csr_ed_element_entry;
        END IF;

        OPEN csr_ed_element_entry_ovn(l_element_entry_id,
                                      v_ud_ele.effective_start_date);
        FETCH csr_ed_element_entry_ovn
        INTO  l_ovn;
        CLOSE csr_ed_element_entry_ovn;
      END;

      l_delete_mode := 'DELETE_NEXT_CHANGE';
      LOOP
      hr_utility.set_location(l_proc, 100);
        l_records_same := FALSE;

        SELECT MAX(ele.effective_end_date)
        INTO   l_max_eed
        FROM   pay_element_entries_f ele
        WHERE  ele.element_entry_id = l_element_entry_id;

        IF l_max_eed > v_ed_ele.effective_end_date THEN
          hr_utility.set_location(l_proc, 110);
          l_future_records := TRUE;
        ELSE
          hr_utility.set_location(l_proc, 120);
          l_future_records := FALSE;
        END IF;

        calculate_datetrack_mode
            (p_ud_start_date  => v_ud_ele.effective_start_date
            ,p_ud_end_date    => v_ud_ele.effective_end_date
            ,p_ed_start_date  => v_ed_ele.effective_start_date
            ,p_ed_end_date    => v_ed_ele.effective_end_date
            ,p_records_same   => l_records_same
            ,p_future_records => l_future_records
            ,p_update_mode    => l_update_mode
            ,p_delete_mode    => l_delete_mode);

        EXIT WHEN l_delete_mode = 'X';
        hr_utility.set_location(l_proc, 130);

        IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

          hr_utility.set_location(l_proc, 140);
          py_element_entry_api.delete_element_entry(
               p_effective_date        => v_ud_ele.effective_start_date
              ,p_datetrack_delete_mode => l_delete_mode
              ,p_element_entry_id      => l_element_entry_id
              ,p_object_version_number => l_ovn
              ,p_effective_start_date  => l_esd
              ,p_effective_end_date    => l_eed
              ,p_delete_warning        => l_delete_warning
              );

          hr_utility.set_location(l_proc, 150);
          OPEN csr_ed_element_entry(l_element_entry_id,
                                    v_ud_ele.effective_start_date);
          FETCH csr_ed_element_entry
          INTO  v_ed_ele;
          CLOSE csr_ed_element_entry;

        END IF;

      END LOOP;

      hr_utility.set_location(l_proc, 160);
      l_cost_allocation_keyflex_id := hr_entry.maintain_cost_keyflex(
            p_cost_keyflex_structure     => l_id_flex_num
           ,p_cost_allocation_keyflex_id => -1
           ,p_concatenated_segments      => v_ud_ele.concatenated_segments
           ,p_summary_flag               => v_ud_ele.summary_flag
           ,p_start_date_active          => v_ud_ele.start_date_active
           ,p_end_date_active            => v_ud_ele.end_date_active
           ,p_segment1                   => v_ud_ele.segment1
           ,p_segment2                   => v_ud_ele.segment2
           ,p_segment3                   => v_ud_ele.segment3
           ,p_segment4                   => v_ud_ele.segment4
           ,p_segment5                   => v_ud_ele.segment5
           ,p_segment6                   => v_ud_ele.segment6
           ,p_segment7                   => v_ud_ele.segment7
           ,p_segment8                   => v_ud_ele.segment8
           ,p_segment9                   => v_ud_ele.segment9
           ,p_segment10                  => v_ud_ele.segment10
           ,p_segment11                  => v_ud_ele.segment11
           ,p_segment12                  => v_ud_ele.segment12
           ,p_segment13                  => v_ud_ele.segment13
           ,p_segment14                  => v_ud_ele.segment14
           ,p_segment15                  => v_ud_ele.segment15
           ,p_segment16                  => v_ud_ele.segment16
           ,p_segment17                  => v_ud_ele.segment17
           ,p_segment18                  => v_ud_ele.segment18
           ,p_segment19                  => v_ud_ele.segment19
           ,p_segment20                  => v_ud_ele.segment20
           ,p_segment21                  => v_ud_ele.segment21
           ,p_segment22                  => v_ud_ele.segment22
           ,p_segment23                  => v_ud_ele.segment23
           ,p_segment24                  => v_ud_ele.segment24
           ,p_segment25                  => v_ud_ele.segment25
           ,p_segment26                  => v_ud_ele.segment26
           ,p_segment27                  => v_ud_ele.segment27
           ,p_segment28                  => v_ud_ele.segment28
           ,p_segment29                  => v_ud_ele.segment29
           ,p_segment30                  => v_ud_ele.segment30
            );

      py_element_entry_api.update_element_entry(
             p_datetrack_update_mode => l_update_mode
            ,p_effective_date        => v_ud_ele.effective_start_date
            ,p_business_group_id     => hr_h2pi_upload.g_to_business_group_id
            ,p_element_entry_id      => l_element_entry_id
            ,p_object_version_number => l_ovn
            ,p_cost_allocation_keyflex_id => l_cost_allocation_keyflex_id
     --       ,p_subpriority         => v_ud_ele.subpriority
            ,p_date_earned           => v_ud_ele.date_earned
            ,p_personal_payment_method_id => l_ee_personal_pay_method_id
            ,p_attribute_category    => v_ud_ele.attribute_category
            ,p_attribute1            => v_ud_ele.attribute1
            ,p_attribute2            => v_ud_ele.attribute2
            ,p_attribute3            => v_ud_ele.attribute3
            ,p_attribute4            => v_ud_ele.attribute4
            ,p_attribute5            => v_ud_ele.attribute5
            ,p_attribute6            => v_ud_ele.attribute6
            ,p_attribute7            => v_ud_ele.attribute7
            ,p_attribute8            => v_ud_ele.attribute8
            ,p_attribute9            => v_ud_ele.attribute9
            ,p_attribute10           => v_ud_ele.attribute10
            ,p_attribute11           => v_ud_ele.attribute11
            ,p_attribute12           => v_ud_ele.attribute12
            ,p_attribute13           => v_ud_ele.attribute13
            ,p_attribute14           => v_ud_ele.attribute14
            ,p_attribute15           => v_ud_ele.attribute15
            ,p_attribute16           => v_ud_ele.attribute16
            ,p_attribute17           => v_ud_ele.attribute17
            ,p_attribute18           => v_ud_ele.attribute18
            ,p_attribute19           => v_ud_ele.attribute19
            ,p_attribute20           => v_ud_ele.attribute20
            ,p_input_value_id1       => a_input_value_id(1)
            ,p_input_value_id2       => a_input_value_id(2)
            ,p_input_value_id3       => a_input_value_id(3)
            ,p_input_value_id4       => a_input_value_id(4)
            ,p_input_value_id5       => a_input_value_id(5)
            ,p_input_value_id6       => a_input_value_id(6)
            ,p_input_value_id7       => a_input_value_id(7)
            ,p_input_value_id8       => a_input_value_id(8)
            ,p_input_value_id9       => a_input_value_id(9)
            ,p_input_value_id10      => a_input_value_id(10)
            ,p_input_value_id11      => a_input_value_id(11)
            ,p_input_value_id12      => a_input_value_id(12)
            ,p_input_value_id13      => a_input_value_id(13)
            ,p_input_value_id14      => a_input_value_id(14)
            ,p_input_value_id15      => a_input_value_id(15)
            ,p_entry_value1          => a_ud_sev(1)
            ,p_entry_value2          => a_ud_sev(2)
            ,p_entry_value3          => a_ud_sev(3)
            ,p_entry_value4          => a_ud_sev(4)
            ,p_entry_value5          => a_ud_sev(5)
            ,p_entry_value6          => a_ud_sev(6)
            ,p_entry_value7          => a_ud_sev(7)
            ,p_entry_value8          => a_ud_sev(8)
            ,p_entry_value9          => a_ud_sev(9)
            ,p_entry_value10         => a_ud_sev(10)
            ,p_entry_value11         => a_ud_sev(11)
            ,p_entry_value12         => a_ud_sev(12)
            ,p_entry_value13         => a_ud_sev(13)
            ,p_entry_value14         => a_ud_sev(14)
            ,p_entry_value15         => a_ud_sev(15)
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_update_warning        => l_update_warning
            );


    END IF;
  END IF;

  hr_utility.set_location(l_proc, 170);
  UPDATE hr_h2pi_element_entries ele
  SET status = 'C'
  WHERE  ele.element_entry_id     = v_ud_ele.element_entry_id
  AND    ele.client_id            = p_from_client_id
  AND    ele.effective_start_date = v_ud_ele.effective_start_date
  AND    ele.effective_end_date   = v_ud_ele.effective_end_date;

  UPDATE hr_h2pi_element_entry_values eev
  SET status = 'C'
  WHERE  eev.element_entry_id     = v_ud_ele.element_entry_id
  AND    eev.client_id            = p_from_client_id
  AND    eev.effective_start_date = v_ud_ele.effective_start_date
  AND    eev.effective_end_date   = v_ud_ele.effective_end_date;

  CLOSE csr_ud_element_entry;
  hr_utility.set_location('Leaving:'|| l_proc, 180);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 190);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_ele.element_entry_id,
                p_table_name           => 'HR_H2PI_ELEMENT_ENTRIES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;
END;



PROCEDURE upload_federal_tax_record (p_from_client_id NUMBER,
                                     p_emp_fed_tax_rule_id    NUMBER,
                                     p_effective_start_date   DATE) IS

CURSOR csr_ud_federal_tax_rule (p_fed_id NUMBER,
                                p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_federal_tax_rules fed
  WHERE  fed.emp_fed_tax_rule_id = p_fed_id
  AND    fed.client_id           = p_from_client_id
  AND    fed.effective_start_date   = p_esd;

CURSOR csr_ed_federal_tax_rule (p_fed_id NUMBER,
                                p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_federal_tax_rules_v fed
  WHERE  fed.emp_fed_tax_rule_id = p_fed_id
  AND    p_esd BETWEEN fed.effective_start_date
                   AND fed.effective_end_date;

CURSOR csr_ed_federal_tax_rule_ovn (p_fed_id NUMBER,
                                    p_esd    DATE) IS
  SELECT fed.object_version_number
  FROM   pay_us_emp_fed_tax_rules_f fed
  WHERE  fed.emp_fed_tax_rule_id = p_fed_id
  AND    p_esd BETWEEN fed.effective_start_date
                   AND fed.effective_end_date;

l_encoded_message    VARCHAR2(200);

l_proc               VARCHAR2(72) := g_package||'upload_federal_tax_rule';

v_ud_fed            hr_h2pi_federal_tax_rules%ROWTYPE;
v_ed_fed            hr_h2pi_federal_tax_rules_v%ROWTYPE;

l_assignment_id     per_all_assignments_f.assignment_id%TYPE;
l_emp_fed_tax_rule_id  pay_us_emp_fed_tax_rules_f.emp_fed_tax_rule_id%TYPE;
l_ovn               pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
l_esd               pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
l_eed               pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;

l_max_eed           pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
l_del_ovn           pay_us_emp_fed_tax_rules_f.object_version_number%TYPE;
l_del_esd           pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
l_del_eed           pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
l_val_esd           pay_us_emp_fed_tax_rules_f.effective_start_date%TYPE;
l_val_eed           pay_us_emp_fed_tax_rules_f.effective_end_date%TYPE;
l_business_group_id pay_us_emp_fed_tax_rules_f.business_group_id%TYPE;

l_records_same      BOOLEAN;
l_future_records    BOOLEAN;
l_update_mode       VARCHAR2(30);
l_delete_mode       VARCHAR2(30);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_federal_tax_rule(p_emp_fed_tax_rule_id,
                             p_effective_start_date);
  FETCH csr_ud_federal_tax_rule INTO v_ud_fed;

  hr_utility.set_location(l_proc, 40);
  l_emp_fed_tax_rule_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PAY_US_EMP_FED_TAX_RULES_F',
                             p_from_id      => v_ud_fed.emp_fed_tax_rule_id,
                             p_report_error => TRUE);


  BEGIN
    hr_utility.set_location(l_proc, 70);
    OPEN csr_ed_federal_tax_rule(l_emp_fed_tax_rule_id,
                                   v_ud_fed.effective_start_date);
    FETCH csr_ed_federal_tax_rule
    INTO  v_ed_fed;
    IF csr_ed_federal_tax_rule%NOTFOUND THEN
      hr_utility.set_location(l_proc, 80);
      CLOSE csr_ed_federal_tax_rule;
      ROLLBACK;
      hr_utility.set_location(l_proc, 90);
      hr_h2pi_error.data_error
           (p_from_id       => l_emp_fed_tax_rule_id,
            p_table_name    => 'HR_H2PI_FEDERAL_TAX_RULES',
            p_message_level => 'FATAL',
            p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
      COMMIT;
      RAISE MAPPING_ID_INVALID;
    ELSE
      CLOSE csr_ed_federal_tax_rule;
    END IF;

    OPEN csr_ed_federal_tax_rule_ovn(l_emp_fed_tax_rule_id,
                                     v_ud_fed.effective_start_date);
    FETCH csr_ed_federal_tax_rule_ovn
    INTO  l_ovn;
    CLOSE csr_ed_federal_tax_rule_ovn;
  END;

  l_delete_mode := 'DELETE_NEXT_CHANGE';
  LOOP
  hr_utility.set_location(l_proc, 100);
    l_records_same := FALSE;

    SELECT MAX(fed.effective_end_date)
    INTO   l_max_eed
    FROM   pay_us_emp_fed_tax_rules_f fed
    WHERE  fed.emp_fed_tax_rule_id = l_emp_fed_tax_rule_id;

    IF l_max_eed > v_ed_fed.effective_end_date THEN
      hr_utility.set_location(l_proc, 110);
      l_future_records := TRUE;
    ELSE
      hr_utility.set_location(l_proc, 120);
      l_future_records := FALSE;
    END IF;

    calculate_datetrack_mode
        (p_ud_start_date  => v_ud_fed.effective_start_date
        ,p_ud_end_date    => v_ud_fed.effective_end_date
        ,p_ed_start_date  => v_ed_fed.effective_start_date
        ,p_ed_end_date    => v_ed_fed.effective_end_date
        ,p_records_same   => l_records_same
        ,p_future_records => l_future_records
        ,p_update_mode    => l_update_mode
        ,p_delete_mode    => l_delete_mode);

    EXIT WHEN l_delete_mode = 'X';
    hr_utility.set_location(l_proc, 130);

    IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

      hr_utility.set_location(l_proc, 140);
      pay_federal_tax_rule_api.update_fed_tax_rule(
             p_effective_date           => v_ud_fed.effective_start_date
            ,p_datetrack_update_mode    => 'UPDATE_OVERRIDE'
            ,p_emp_fed_tax_rule_id      => l_emp_fed_tax_rule_id
            ,p_object_version_number    => l_ovn
            ,p_sui_state_code           => v_ud_fed.sui_state_code
            ,p_additional_wa_amount     => v_ud_fed.additional_wa_amount
            ,p_filing_status_code       => v_ud_fed.filing_status_code
            ,p_fit_override_amount      => v_ud_fed.fit_override_amount
            ,p_fit_override_rate        => v_ud_fed.fit_override_rate
            ,p_withholding_allowances   => v_ud_fed.withholding_allowances
            ,p_cumulative_taxation      => v_ud_fed.cumulative_taxation
            ,p_eic_filing_status_code   => v_ud_fed.eic_filing_status_code
            ,p_fit_additional_tax       => v_ud_fed.fit_additional_tax
            ,p_fit_exempt               => v_ud_fed.fit_exempt
            ,p_futa_tax_exempt          => v_ud_fed.futa_tax_exempt
            ,p_medicare_tax_exempt      => v_ud_fed.medicare_tax_exempt
            ,p_ss_tax_exempt            => v_ud_fed.ss_tax_exempt
            ,p_statutory_employee       => v_ud_fed.statutory_employee
            ,p_w2_filed_year            => v_ud_fed.w2_filed_year
            ,p_supp_tax_override_rate   => v_ud_fed.supp_tax_override_rate
            ,p_excessive_wa_reject_date => v_ud_fed.excessive_wa_reject_date
            ,p_effective_start_date     => l_esd
            ,p_effective_end_date       => l_eed
            );
/*
      pay_fed_del.del(
           p_effective_date        => v_ud_fed.effective_start_date
          ,p_datetrack_mode        => l_delete_mode
          ,p_emp_fed_tax_rule_id   => l_emp_fed_tax_rule_id
          ,p_object_version_number => l_ovn
          ,p_effective_start_date  => l_esd
          ,p_effective_end_date    => l_eed
          ,p_delete_routine        => NULL
          );
        */
      hr_utility.set_location(l_proc, 150);
      OPEN csr_ed_federal_tax_rule(l_emp_fed_tax_rule_id,
                                   v_ud_fed.effective_start_date);
      FETCH csr_ed_federal_tax_rule
      INTO  v_ed_fed;
      CLOSE csr_ed_federal_tax_rule;

    END IF;

  END LOOP;

  hr_utility.set_location(l_proc, 160);
  pay_federal_tax_rule_api.update_fed_tax_rule(
             p_effective_date           => v_ud_fed.effective_start_date
            ,p_datetrack_update_mode    => l_update_mode
            ,p_emp_fed_tax_rule_id      => l_emp_fed_tax_rule_id
            ,p_object_version_number    => l_ovn
            ,p_sui_state_code           => v_ud_fed.sui_state_code
            ,p_additional_wa_amount     => v_ud_fed.additional_wa_amount
            ,p_filing_status_code       => v_ud_fed.filing_status_code
            ,p_fit_override_amount      => v_ud_fed.fit_override_amount
            ,p_fit_override_rate        => v_ud_fed.fit_override_rate
            ,p_withholding_allowances   => v_ud_fed.withholding_allowances
            ,p_cumulative_taxation      => v_ud_fed.cumulative_taxation
            ,p_eic_filing_status_code   => v_ud_fed.eic_filing_status_code
            ,p_fit_additional_tax       => v_ud_fed.fit_additional_tax
            ,p_fit_exempt               => v_ud_fed.fit_exempt
            ,p_futa_tax_exempt          => v_ud_fed.futa_tax_exempt
            ,p_medicare_tax_exempt      => v_ud_fed.medicare_tax_exempt
            ,p_ss_tax_exempt            => v_ud_fed.ss_tax_exempt
            ,p_statutory_employee       => v_ud_fed.statutory_employee
            ,p_w2_filed_year            => v_ud_fed.w2_filed_year
            ,p_supp_tax_override_rate   => v_ud_fed.supp_tax_override_rate
            ,p_excessive_wa_reject_date => v_ud_fed.excessive_wa_reject_date
            ,p_effective_start_date     => l_esd
            ,p_effective_end_date       => l_eed
            );

  hr_utility.set_location(l_proc, 170);
  UPDATE hr_h2pi_federal_tax_rules fed
  SET status = 'C'
  WHERE  fed.emp_fed_tax_rule_id   = v_ud_fed.emp_fed_tax_rule_id
  AND    fed.client_id             = p_from_client_id
  AND    fed.effective_start_date  = v_ud_fed.effective_start_date
  AND    fed.effective_end_date    = v_ud_fed.effective_end_date;

  CLOSE csr_ud_federal_tax_rule;
  hr_utility.set_location('Leaving:'|| l_proc, 180);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 190);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_fed.emp_fed_tax_rule_id,
                p_table_name           => 'HR_H2PI_FEDERAL_TAX_RULES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;



PROCEDURE upload_state_tax_record (p_from_client_id NUMBER,
                                   p_emp_state_tax_rule_id  NUMBER,
                                   p_effective_start_date   DATE) IS

CURSOR csr_ud_state_tax_rule (p_sta_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_state_tax_rules sta
  WHERE  sta.emp_state_tax_rule_id = p_sta_id
  AND    sta.client_id             = p_from_client_id
  AND    sta.effective_start_date   = p_esd;

CURSOR csr_ed_state_tax_rule (p_sta_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_state_tax_rules_v sta
  WHERE  sta.emp_state_tax_rule_id = p_sta_id
  AND    p_esd BETWEEN sta.effective_start_date
                   AND sta.effective_end_date;

CURSOR csr_ed_state_tax_rule_ovn (p_sta_id NUMBER,
                                  p_esd    DATE) IS
  SELECT sta.object_version_number
  FROM   pay_us_emp_state_tax_rules_f sta
  WHERE  sta.emp_state_tax_rule_id = p_sta_id
  AND    p_esd BETWEEN sta.effective_start_date
                   AND sta.effective_end_date;

l_encoded_message    VARCHAR2(200);

l_proc               VARCHAR2(72) := g_package||'upload_state_tax_rule';

v_ud_sta             hr_h2pi_state_tax_rules%ROWTYPE;
v_ed_sta             hr_h2pi_state_tax_rules_v%ROWTYPE;

l_assignment_id      per_all_assignments_f.assignment_id%TYPE;
l_emp_state_tax_rule_id
               pay_us_emp_state_tax_rules_f.emp_state_tax_rule_id%TYPE;
l_ovn                pay_us_emp_state_tax_rules_f.object_version_number%TYPE;
l_esd                pay_us_emp_state_tax_rules_f.effective_start_date%TYPE;
l_eed                pay_us_emp_state_tax_rules_f.effective_end_date%TYPE;

l_max_eed            pay_us_emp_state_tax_rules_f.effective_end_date%TYPE;
l_del_ovn            pay_us_emp_state_tax_rules_f.object_version_number%TYPE;
l_del_esd            pay_us_emp_state_tax_rules_f.effective_start_date%TYPE;
l_del_eed            pay_us_emp_state_tax_rules_f.effective_end_date%TYPE;
l_val_esd            pay_us_emp_state_tax_rules_f.effective_start_date%TYPE;
l_val_eed            pay_us_emp_state_tax_rules_f.effective_end_date%TYPE;
l_business_group_id  pay_us_emp_state_tax_rules_f.business_group_id%TYPE;

l_records_same       BOOLEAN;
l_future_records     BOOLEAN;
l_update_mode        VARCHAR2(30);
l_delete_mode        VARCHAR2(30);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_state_tax_rule(p_emp_state_tax_rule_id,
                             p_effective_start_date);
  FETCH csr_ud_state_tax_rule INTO v_ud_sta;

  hr_utility.set_location(l_proc, 20);
  l_assignment_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                             p_from_id      => v_ud_sta.assignment_id,
                             p_report_error => TRUE);

  l_emp_state_tax_rule_id := hr_h2pi_map.get_to_id
                        (p_table_name  => 'PAY_US_EMP_STATE_TAX_RULES_F',
                         p_from_id     => v_ud_sta.emp_state_tax_rule_id);

  IF l_emp_state_tax_rule_id = -1 THEN
    hr_utility.set_location(l_proc, 30);

    pay_state_tax_rule_api.create_state_tax_rule(
             p_effective_date           => v_ud_sta.effective_start_date
            ,p_assignment_id            => l_assignment_id
            ,p_state_code               => v_ud_sta.state_code
            ,p_additional_wa_amount     => v_ud_sta.additional_wa_amount
            ,p_filing_status_code       => v_ud_sta.filing_status_code
            ,p_remainder_percent        => v_ud_sta.remainder_percent
            ,p_secondary_wa             => v_ud_sta.secondary_wa
            ,p_sit_additional_tax       => v_ud_sta.sit_additional_tax
            ,p_sit_override_amount      => v_ud_sta.sit_override_amount
            ,p_sit_override_rate        => v_ud_sta.sit_override_rate
            ,p_withholding_allowances   => v_ud_sta.withholding_allowances
            ,p_excessive_wa_reject_date => v_ud_sta.excessive_wa_reject_date
            ,p_sdi_exempt               => v_ud_sta.sdi_exempt
            ,p_sit_exempt               => v_ud_sta.sit_exempt
            ,p_sit_optional_calc_ind    => v_ud_sta.sit_optional_calc_ind
            ,p_state_non_resident_cert  => v_ud_sta.state_non_resident_cert
            ,p_sui_exempt               => v_ud_sta.sui_exempt
            ,p_wc_exempt                => v_ud_sta.wc_exempt
            ,p_sui_wage_base_override_amoun =>
                                       v_ud_sta.sui_wage_base_override_amount
            ,p_supp_tax_override_rate   => v_ud_sta.supp_tax_override_rate
            ,p_emp_state_tax_rule_id    => l_emp_state_tax_rule_id
            ,p_object_version_number    => l_ovn
            ,p_effective_start_date     => l_esd
            ,p_effective_end_date       => l_eed
            );

    hr_utility.set_location(l_proc, 40);
    hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PAY_US_EMP_STATE_TAX_RULES_F',
                       p_from_id    => v_ud_sta.emp_state_tax_rule_id,
                       p_to_id      => l_emp_state_tax_rule_id);
  ELSE

    BEGIN
      hr_utility.set_location(l_proc, 50);
      OPEN csr_ed_state_tax_rule(l_emp_state_tax_rule_id,
                                   v_ud_sta.effective_start_date);
      FETCH csr_ed_state_tax_rule
      INTO  v_ed_sta;
      IF csr_ed_state_tax_rule%NOTFOUND THEN
        hr_utility.set_location(l_proc, 60);
        CLOSE csr_ed_state_tax_rule;
        ROLLBACK;
        hr_utility.set_location(l_proc, 70);
        hr_h2pi_error.data_error
             (p_from_id       => l_emp_state_tax_rule_id,
              p_table_name    => 'HR_H2PI_STATE_TAX_RULES',
              p_message_level => 'FATAL',
              p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
        COMMIT;
        RAISE MAPPING_ID_INVALID;
      ELSE
        CLOSE csr_ed_state_tax_rule;
      END IF;

      OPEN csr_ed_state_tax_rule_ovn(l_emp_state_tax_rule_id,
                                     v_ud_sta.effective_start_date);
      FETCH csr_ed_state_tax_rule_ovn
      INTO  l_ovn;
      CLOSE csr_ed_state_tax_rule_ovn;
    END;

    l_delete_mode := 'DELETE_NEXT_CHANGE';
    LOOP
      hr_utility.set_location(l_proc, 80);
      l_records_same := FALSE;

      SELECT MAX(sta.effective_end_date)
      INTO   l_max_eed
      FROM   pay_us_emp_state_tax_rules_f sta
      WHERE  sta.emp_state_tax_rule_id = l_emp_state_tax_rule_id;

      IF l_max_eed > v_ed_sta.effective_end_date THEN
        hr_utility.set_location(l_proc, 90);
        l_future_records := TRUE;
      ELSE
        hr_utility.set_location(l_proc, 100);
        l_future_records := FALSE;
      END IF;

      calculate_datetrack_mode
          (p_ud_start_date  => v_ud_sta.effective_start_date
          ,p_ud_end_date    => v_ud_sta.effective_end_date
          ,p_ed_start_date  => v_ed_sta.effective_start_date
          ,p_ed_end_date    => v_ed_sta.effective_end_date
          ,p_records_same   => l_records_same
          ,p_future_records => l_future_records
          ,p_update_mode    => l_update_mode
          ,p_delete_mode    => l_delete_mode);

      EXIT WHEN l_delete_mode = 'X';
      hr_utility.set_location(l_proc, 110);

      IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

        hr_utility.set_location(l_proc, 120);
        pay_state_tax_rule_api.update_state_tax_rule(
             p_effective_date	        => v_ud_sta.effective_start_date
            ,p_datetrack_update_mode    => 'UPDATE_OVERRIDE'
            ,p_object_version_number    => l_ovn
            ,p_emp_state_tax_rule_id    => l_emp_state_tax_rule_id
            ,p_additional_wa_amount     => v_ud_sta.additional_wa_amount
            ,p_filing_status_code       => v_ud_sta.filing_status_code
            ,p_remainder_percent        => v_ud_sta.remainder_percent
            ,p_secondary_wa             => v_ud_sta.secondary_wa
            ,p_sit_additional_tax       => v_ud_sta.sit_additional_tax
            ,p_sit_override_amount      => v_ud_sta.sit_override_amount
            ,p_sit_override_rate        => v_ud_sta.sit_override_rate
            ,p_withholding_allowances   => v_ud_sta.withholding_allowances
            ,p_excessive_wa_reject_date => v_ud_sta.excessive_wa_reject_date
            ,p_sdi_exempt               => v_ud_sta.sdi_exempt
            ,p_sit_exempt               => v_ud_sta.sit_exempt
            ,p_sit_optional_calc_ind    => v_ud_sta.sit_optional_calc_ind
            ,p_state_non_resident_cert  => v_ud_sta.state_non_resident_cert
            ,p_sui_exempt               => v_ud_sta.sui_exempt
            ,p_wc_exempt                => v_ud_sta.wc_exempt
            ,p_sui_wage_base_override_amoun
                                   => v_ud_sta.sui_wage_base_override_amount
            ,p_supp_tax_override_rate   => v_ud_sta.supp_tax_override_rate
            ,p_effective_start_date     => l_esd
            ,p_effective_end_date       => l_eed
            );
/*
        pay_sta_del.del(
             p_effective_date        => v_ud_sta.effective_start_date
            ,p_datetrack_mode        => l_delete_mode
            ,p_emp_state_tax_rule_id => l_emp_state_tax_rule_id
            ,p_object_version_number => l_ovn
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_delete_routine        => NULL
            );
*/

        hr_utility.set_location(l_proc, 130);
        OPEN csr_ed_state_tax_rule(l_emp_state_tax_rule_id,
                                   v_ud_sta.effective_start_date);
        FETCH csr_ed_state_tax_rule
        INTO  v_ed_sta;
        CLOSE csr_ed_state_tax_rule;

      END IF;

    END LOOP;

    hr_utility.set_location(l_proc, 140);
    pay_state_tax_rule_api.update_state_tax_rule(
             p_effective_date	        => v_ud_sta.effective_start_date
            ,p_datetrack_update_mode    => l_update_mode
            ,p_object_version_number    => l_ovn
            ,p_emp_state_tax_rule_id    => l_emp_state_tax_rule_id
            ,p_additional_wa_amount     => v_ud_sta.additional_wa_amount
            ,p_filing_status_code       => v_ud_sta.filing_status_code
            ,p_remainder_percent        => v_ud_sta.remainder_percent
            ,p_secondary_wa             => v_ud_sta.secondary_wa
            ,p_sit_additional_tax       => v_ud_sta.sit_additional_tax
            ,p_sit_override_amount      => v_ud_sta.sit_override_amount
            ,p_sit_override_rate        => v_ud_sta.sit_override_rate
            ,p_withholding_allowances   => v_ud_sta.withholding_allowances
            ,p_excessive_wa_reject_date => v_ud_sta.excessive_wa_reject_date
            ,p_sdi_exempt               => v_ud_sta.sdi_exempt
            ,p_sit_exempt               => v_ud_sta.sit_exempt
            ,p_sit_optional_calc_ind    => v_ud_sta.sit_optional_calc_ind
            ,p_state_non_resident_cert  => v_ud_sta.state_non_resident_cert
            ,p_sui_exempt               => v_ud_sta.sui_exempt
            ,p_wc_exempt                => v_ud_sta.wc_exempt
            ,p_sui_wage_base_override_amoun
                                   => v_ud_sta.sui_wage_base_override_amount
            ,p_supp_tax_override_rate   => v_ud_sta.supp_tax_override_rate
            ,p_effective_start_date     => l_esd
            ,p_effective_end_date       => l_eed
            );

  END IF;

  hr_utility.set_location(l_proc, 150);
  UPDATE hr_h2pi_state_tax_rules sta
  SET status = 'C'
  WHERE  sta.emp_state_tax_rule_id = v_ud_sta.emp_state_tax_rule_id
  AND    sta.client_id             = p_from_client_id
  AND    sta.effective_start_date  = v_ud_sta.effective_start_date
  AND    sta.effective_end_date    = v_ud_sta.effective_end_date;

  CLOSE csr_ud_state_tax_rule;
  hr_utility.set_location('Leaving:'|| l_proc, 160);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 170);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_sta.emp_state_tax_rule_id,
                p_table_name           => 'HR_H2PI_STATE_TAX_RULES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;



PROCEDURE upload_county_tax_record (p_from_client_id NUMBER,
                                    p_emp_county_tax_rule_id NUMBER,
                                    p_effective_start_date   DATE) IS

CURSOR csr_ud_county_tax_rule (p_cnt_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_county_tax_rules cnt
  WHERE  cnt.emp_county_tax_rule_id = p_cnt_id
  AND    cnt.client_id              = p_from_client_id
  AND    cnt.effective_start_date   = p_esd;

CURSOR csr_ed_county_tax_rule (p_cnt_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_county_tax_rules_v cnt
  WHERE  cnt.emp_county_tax_rule_id = p_cnt_id
  AND    p_esd BETWEEN cnt.effective_start_date
                   AND cnt.effective_end_date;

CURSOR csr_ed_county_tax_rule_ovn (p_cnt_id NUMBER,
                                  p_esd    DATE) IS
  SELECT cnt.object_version_number
  FROM   pay_us_emp_county_tax_rules_f cnt
  WHERE  cnt.emp_county_tax_rule_id = p_cnt_id
  AND    p_esd BETWEEN cnt.effective_start_date
                   AND cnt.effective_end_date;

l_encoded_message    VARCHAR2(200);

l_proc               VARCHAR2(72) := g_package||'upload_county_tax_rule';

v_ud_cnt             hr_h2pi_county_tax_rules%ROWTYPE;
v_ed_cnt             hr_h2pi_county_tax_rules_v%ROWTYPE;

l_assignment_id      per_all_assignments_f.assignment_id%TYPE;
l_emp_county_tax_rule_id
               pay_us_emp_county_tax_rules_f.emp_county_tax_rule_id%TYPE;
l_ovn                pay_us_emp_county_tax_rules_f.object_version_number%TYPE;
l_esd                pay_us_emp_county_tax_rules_f.effective_start_date%TYPE;
l_eed                pay_us_emp_county_tax_rules_f.effective_end_date%TYPE;

l_max_eed            pay_us_emp_county_tax_rules_f.effective_end_date%TYPE;
l_del_ovn            pay_us_emp_county_tax_rules_f.object_version_number%TYPE;
l_del_esd            pay_us_emp_county_tax_rules_f.effective_start_date%TYPE;
l_del_eed            pay_us_emp_county_tax_rules_f.effective_end_date%TYPE;
l_val_esd            pay_us_emp_county_tax_rules_f.effective_start_date%TYPE;
l_val_eed            pay_us_emp_county_tax_rules_f.effective_end_date%TYPE;
l_business_group_id  pay_us_emp_county_tax_rules_f.business_group_id%TYPE;

l_records_same       BOOLEAN;
l_future_records     BOOLEAN;
l_update_mode        VARCHAR2(30);
l_delete_mode        VARCHAR2(30);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_county_tax_rule(p_emp_county_tax_rule_id,
                             p_effective_start_date);
  FETCH csr_ud_county_tax_rule INTO v_ud_cnt;

  hr_utility.set_location(l_proc, 20);
  l_assignment_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                             p_from_id      => v_ud_cnt.assignment_id,
                             p_report_error => TRUE);

  l_emp_county_tax_rule_id := hr_h2pi_map.get_to_id
                        (p_table_name  => 'PAY_US_EMP_COUNTY_TAX_RULES_F',
                         p_from_id     => v_ud_cnt.emp_county_tax_rule_id);

  IF l_emp_county_tax_rule_id = -1 THEN
    hr_utility.set_location(l_proc, 30);
    pay_county_tax_rule_api.create_county_tax_rule(
             p_effective_date         => v_ud_cnt.effective_start_date
            ,p_assignment_id          => l_assignment_id
            ,p_state_code             => v_ud_cnt.state_code
            ,p_county_code            => v_ud_cnt.county_code
            ,p_additional_wa_rate     => v_ud_cnt.additional_wa_rate
            ,p_filing_status_code     => v_ud_cnt.filing_status_code
            ,p_lit_additional_tax     => v_ud_cnt.lit_additional_tax
            ,p_lit_override_amount    => v_ud_cnt.lit_override_amount
            ,p_lit_override_rate      => v_ud_cnt.lit_override_rate
            ,p_withholding_allowances => v_ud_cnt.withholding_allowances
            ,p_lit_exempt             => v_ud_cnt.lit_exempt
            ,p_sd_exempt              => v_ud_cnt.sd_exempt
            ,p_ht_exempt              => v_ud_cnt.ht_exempt
            ,p_school_district_code   => v_ud_cnt.school_district_code
            ,p_object_version_number  => l_ovn
            ,p_emp_county_tax_rule_id => l_emp_county_tax_rule_id
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            );

    hr_utility.set_location(l_proc, 40);
    hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PAY_US_EMP_COUNTY_TAX_RULES_F',
                       p_from_id    => v_ud_cnt.emp_county_tax_rule_id,
                       p_to_id      => l_emp_county_tax_rule_id);
  ELSE

    BEGIN
      hr_utility.set_location(l_proc, 50);
      OPEN csr_ed_county_tax_rule(l_emp_county_tax_rule_id,
                                   v_ud_cnt.effective_start_date);
      FETCH csr_ed_county_tax_rule
      INTO  v_ed_cnt;
      IF csr_ed_county_tax_rule%NOTFOUND THEN
        hr_utility.set_location(l_proc, 60);
        CLOSE csr_ed_county_tax_rule;
        ROLLBACK;
        hr_utility.set_location(l_proc, 70);
        hr_h2pi_error.data_error
             (p_from_id       => l_emp_county_tax_rule_id,
              p_table_name    => 'HR_H2PI_COUNTY_TAX_RULES',
              p_message_level => 'FATAL',
              p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
        COMMIT;
        RAISE MAPPING_ID_INVALID;
      ELSE
        CLOSE csr_ed_county_tax_rule;
      END IF;

      OPEN csr_ed_county_tax_rule_ovn(l_emp_county_tax_rule_id,
                                     v_ud_cnt.effective_start_date);
      FETCH csr_ed_county_tax_rule_ovn
      INTO  l_ovn;
      CLOSE csr_ed_county_tax_rule_ovn;
    END;

    l_delete_mode := 'DELETE_NEXT_CHANGE';
    LOOP
      hr_utility.set_location(l_proc, 80);
      l_records_same := FALSE;

      SELECT MAX(cnt.effective_end_date)
      INTO   l_max_eed
      FROM   pay_us_emp_county_tax_rules_f cnt
      WHERE  cnt.emp_county_tax_rule_id = l_emp_county_tax_rule_id;

      IF l_max_eed > v_ed_cnt.effective_end_date THEN
        hr_utility.set_location(l_proc, 90);
        l_future_records := TRUE;
      ELSE
        hr_utility.set_location(l_proc, 100);
        l_future_records := FALSE;
      END IF;

      calculate_datetrack_mode
          (p_ud_start_date  => v_ud_cnt.effective_start_date
          ,p_ud_end_date    => v_ud_cnt.effective_end_date
          ,p_ed_start_date  => v_ed_cnt.effective_start_date
          ,p_ed_end_date    => v_ed_cnt.effective_end_date
          ,p_records_same   => l_records_same
          ,p_future_records => l_future_records
          ,p_update_mode    => l_update_mode
          ,p_delete_mode    => l_delete_mode);

      EXIT WHEN l_delete_mode = 'X';
      hr_utility.set_location(l_proc, 110);

      IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

        hr_utility.set_location(l_proc, 120);
        pay_county_tax_rule_api.update_county_tax_rule(
             p_effective_date	      => v_ud_cnt.effective_start_date
            ,p_datetrack_mode         => 'UPDATE_OVERRIDE'
            ,p_object_version_number  => l_ovn
            ,p_emp_county_tax_rule_id => l_emp_county_tax_rule_id
            ,p_additional_wa_rate     => v_ud_cnt.additional_wa_rate
            ,p_filing_status_code     => v_ud_cnt.filing_status_code
            ,p_lit_additional_tax     => v_ud_cnt.lit_additional_tax
            ,p_lit_override_amount    => v_ud_cnt.lit_override_amount
            ,p_lit_override_rate      => v_ud_cnt.lit_override_rate
            ,p_withholding_allowances => v_ud_cnt.withholding_allowances
            ,p_lit_exempt             => v_ud_cnt.lit_exempt
            ,p_sd_exempt              => v_ud_cnt.sd_exempt
            ,p_ht_exempt              => v_ud_cnt.ht_exempt
            ,p_school_district_code   => v_ud_cnt.school_district_code
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            );
/*
        pay_cnt_del.del(
             p_effective_date         => v_ud_cnt.effective_start_date
            ,p_datetrack_mode         => l_delete_mode
            ,p_emp_county_tax_rule_id => l_emp_county_tax_rule_id
            ,p_object_version_number  => l_ovn
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            ,p_delete_routine         => NULL
            );
*/

        hr_utility.set_location(l_proc, 130);
        OPEN csr_ed_county_tax_rule(l_emp_county_tax_rule_id,
                                   v_ud_cnt.effective_start_date);
        FETCH csr_ed_county_tax_rule
        INTO  v_ed_cnt;
        CLOSE csr_ed_county_tax_rule;

      END IF;

    END LOOP;

    hr_utility.set_location(l_proc, 140);
    pay_county_tax_rule_api.update_county_tax_rule(
             p_effective_date	      => v_ud_cnt.effective_start_date
            ,p_datetrack_mode         => l_update_mode
            ,p_object_version_number  => l_ovn
            ,p_emp_county_tax_rule_id => l_emp_county_tax_rule_id
            ,p_additional_wa_rate     => v_ud_cnt.additional_wa_rate
            ,p_filing_status_code     => v_ud_cnt.filing_status_code
            ,p_lit_additional_tax     => v_ud_cnt.lit_additional_tax
            ,p_lit_override_amount    => v_ud_cnt.lit_override_amount
            ,p_lit_override_rate      => v_ud_cnt.lit_override_rate
            ,p_withholding_allowances => v_ud_cnt.withholding_allowances
            ,p_lit_exempt             => v_ud_cnt.lit_exempt
            ,p_sd_exempt              => v_ud_cnt.sd_exempt
            ,p_ht_exempt              => v_ud_cnt.ht_exempt
            ,p_school_district_code   => v_ud_cnt.school_district_code
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            );
  END IF;

  hr_utility.set_location(l_proc, 150);
  UPDATE hr_h2pi_county_tax_rules cnt
  SET status = 'C'
  WHERE  cnt.emp_county_tax_rule_id = v_ud_cnt.emp_county_tax_rule_id
  AND    cnt.client_id              = p_from_client_id
  AND    cnt.effective_start_date  = v_ud_cnt.effective_start_date
  AND    cnt.effective_end_date    = v_ud_cnt.effective_end_date;

  CLOSE csr_ud_county_tax_rule;
  hr_utility.set_location('Leaving:'|| l_proc, 160);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 170);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_cnt.emp_county_tax_rule_id,
                p_table_name           => 'HR_H2PI_COUNTY_TAX_RULES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


PROCEDURE upload_city_tax_record (p_from_client_id NUMBER,
                                  p_emp_city_tax_rule_id   NUMBER,
                                  p_effective_start_date   DATE) IS

CURSOR csr_ud_city_tax_rule (p_cty_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_city_tax_rules cty
  WHERE  cty.emp_city_tax_rule_id = p_cty_id
  AND    cty.client_Id            = p_from_client_id
  AND    cty.effective_start_date = p_esd;

CURSOR csr_ed_city_tax_rule (p_cty_id NUMBER,
                              p_esd    DATE) IS
  SELECT *
  FROM   hr_h2pi_city_tax_rules_v cty
  WHERE  cty.emp_city_tax_rule_id = p_cty_id
  AND    p_esd BETWEEN cty.effective_start_date
                   AND cty.effective_end_date;

CURSOR csr_ed_city_tax_rule_ovn (p_cty_id NUMBER,
                                  p_esd    DATE) IS
  SELECT cty.object_version_number
  FROM   pay_us_emp_city_tax_rules_f cty
  WHERE  cty.emp_city_tax_rule_id = p_cty_id
  AND    p_esd BETWEEN cty.effective_start_date
                   AND cty.effective_end_date;

l_encoded_message    VARCHAR2(200);

l_proc               VARCHAR2(72) := g_package||'upload_city_tax_rule';

v_ud_cty             hr_h2pi_city_tax_rules%ROWTYPE;
v_ed_cty             hr_h2pi_city_tax_rules_v%ROWTYPE;

l_assignment_id      per_all_assignments_f.assignment_id%TYPE;
l_emp_city_tax_rule_id
               pay_us_emp_city_tax_rules_f.emp_city_tax_rule_id%TYPE;
l_ovn                pay_us_emp_city_tax_rules_f.object_version_number%TYPE;
l_esd                pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
l_eed                pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;

l_max_eed            pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
l_del_ovn            pay_us_emp_city_tax_rules_f.object_version_number%TYPE;
l_del_esd            pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
l_del_eed            pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
l_val_esd            pay_us_emp_city_tax_rules_f.effective_start_date%TYPE;
l_val_eed            pay_us_emp_city_tax_rules_f.effective_end_date%TYPE;
l_business_group_id  pay_us_emp_city_tax_rules_f.business_group_id%TYPE;

l_records_same       BOOLEAN;
l_future_records     BOOLEAN;
l_update_mode        VARCHAR2(30);
l_delete_mode        VARCHAR2(30);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ud_city_tax_rule(p_emp_city_tax_rule_id,
                             p_effective_start_date);
  FETCH csr_ud_city_tax_rule INTO v_ud_cty;

  hr_utility.set_location(l_proc, 20);
  l_assignment_id := hr_h2pi_map.get_to_id
                            (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                             p_from_id      => v_ud_cty.assignment_id,
                             p_report_error => TRUE);

  l_emp_city_tax_rule_id := hr_h2pi_map.get_to_id
                        (p_table_name  => 'PAY_US_EMP_CITY_TAX_RULES_F',
                         p_from_id     => v_ud_cty.emp_city_tax_rule_id);

  IF l_emp_city_tax_rule_id = -1 THEN
    hr_utility.set_location(l_proc, 30);
    pay_city_tax_rule_api.create_city_tax_rule(
             p_effective_date         => v_ud_cty.effective_start_date
            ,p_assignment_id          => l_assignment_id
            ,p_state_code             => v_ud_cty.state_code
            ,p_county_code            => v_ud_cty.county_code
            ,p_city_code              => v_ud_cty.city_code
            ,p_additional_wa_rate     => v_ud_cty.additional_wa_rate
            ,p_filing_status_code     => v_ud_cty.filing_status_code
            ,p_lit_additional_tax     => v_ud_cty.lit_additional_tax
            ,p_lit_override_amount    => v_ud_cty.lit_override_amount
            ,p_lit_override_rate      => v_ud_cty.lit_override_rate
            ,p_withholding_allowances => v_ud_cty.withholding_allowances
            ,p_lit_exempt             => v_ud_cty.lit_exempt
            ,p_sd_exempt              => v_ud_cty.sd_exempt
            ,p_ht_exempt              => v_ud_cty.ht_exempt
            ,p_school_district_code   => v_ud_cty.school_district_code
            ,p_object_version_number  => l_ovn
            ,p_emp_city_tax_rule_id   => l_emp_city_tax_rule_id
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            );

    hr_utility.set_location(l_proc, 40);
    hr_h2pi_map.create_id_mapping
                      (p_table_name => 'PAY_US_EMP_CITY_TAX_RULES_F',
                       p_from_id    => v_ud_cty.emp_city_tax_rule_id,
                       p_to_id      => l_emp_city_tax_rule_id);
  ELSE

    BEGIN
      hr_utility.set_location(l_proc, 50);
      OPEN csr_ed_city_tax_rule(l_emp_city_tax_rule_id,
                                   v_ud_cty.effective_start_date);
      FETCH csr_ed_city_tax_rule
      INTO  v_ed_cty;
      IF csr_ed_city_tax_rule%NOTFOUND THEN
        hr_utility.set_location(l_proc, 60);
        CLOSE csr_ed_city_tax_rule;
        ROLLBACK;
        hr_utility.set_location(l_proc, 70);
        hr_h2pi_error.data_error
             (p_from_id       => l_emp_city_tax_rule_id,
              p_table_name    => 'HR_H2PI_CITY_TAX_RULES',
              p_message_level => 'FATAL',
              p_message_name  => 'HR_289240_MAPPING_ID_INVALID');
        COMMIT;
        RAISE MAPPING_ID_INVALID;
      ELSE
        CLOSE csr_ed_city_tax_rule;
      END IF;

      OPEN csr_ed_city_tax_rule_ovn(l_emp_city_tax_rule_id,
                                     v_ud_cty.effective_start_date);
      FETCH csr_ed_city_tax_rule_ovn
      INTO  l_ovn;
      CLOSE csr_ed_city_tax_rule_ovn;
    END;

    l_delete_mode := 'DELETE_NEXT_CHANGE';
    LOOP
      hr_utility.set_location(l_proc, 80);
      l_records_same := FALSE;

      SELECT MAX(sta.effective_end_date)
      INTO   l_max_eed
      FROM   pay_us_emp_city_tax_rules_f sta
      WHERE  sta.emp_city_tax_rule_id = l_emp_city_tax_rule_id;

      IF l_max_eed > v_ed_cty.effective_end_date THEN
        hr_utility.set_location(l_proc, 90);
        l_future_records := TRUE;
      ELSE
        hr_utility.set_location(l_proc, 100);
        l_future_records := FALSE;
      END IF;

      calculate_datetrack_mode
          (p_ud_start_date  => v_ud_cty.effective_start_date
          ,p_ud_end_date    => v_ud_cty.effective_end_date
          ,p_ed_start_date  => v_ed_cty.effective_start_date
          ,p_ed_end_date    => v_ed_cty.effective_end_date
          ,p_records_same   => l_records_same
          ,p_future_records => l_future_records
          ,p_update_mode    => l_update_mode
          ,p_delete_mode    => l_delete_mode);

      EXIT WHEN l_delete_mode = 'X';
      hr_utility.set_location(l_proc, 110);

      IF l_delete_mode = 'DELETE_NEXT_CHANGE' THEN

        hr_utility.set_location(l_proc, 120);
        pay_city_tax_rule_api.update_city_tax_rule(
             p_effective_date         => v_ud_cty.effective_start_date
            ,p_datetrack_mode	      => 'UPDATE_OVERRIDE'
            ,p_object_version_number  => l_ovn
            ,p_emp_city_tax_rule_id   => l_emp_city_tax_rule_id
            ,p_additional_wa_rate     => v_ud_cty.additional_wa_rate
            ,p_filing_status_code     => v_ud_cty.filing_status_code
            ,p_lit_additional_tax     => v_ud_cty.lit_additional_tax
            ,p_lit_override_amount    => v_ud_cty.lit_override_amount
            ,p_lit_override_rate      => v_ud_cty.lit_override_rate
            ,p_withholding_allowances => v_ud_cty.withholding_allowances
            ,p_lit_exempt             => v_ud_cty.lit_exempt
            ,p_sd_exempt              => v_ud_cty.sd_exempt
            ,p_ht_exempt              => v_ud_cty.ht_exempt
            ,p_school_district_code   => v_ud_cty.school_district_code
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            );
        pay_cty_del.del(
             p_effective_date        => v_ud_cty.effective_start_date
            ,p_datetrack_mode        => l_delete_mode
            ,p_emp_city_tax_rule_id  => l_emp_city_tax_rule_id
            ,p_object_version_number => l_ovn
            ,p_effective_start_date  => l_esd
            ,p_effective_end_date    => l_eed
            ,p_delete_routine        => NULL
            );

        hr_utility.set_location(l_proc, 130);
        OPEN csr_ed_city_tax_rule(l_emp_city_tax_rule_id,
                                   v_ud_cty.effective_start_date);
        FETCH csr_ed_city_tax_rule
        INTO  v_ed_cty;
        CLOSE csr_ed_city_tax_rule;

      END IF;

    END LOOP;

    hr_utility.set_location(l_proc, 140);
    pay_city_tax_rule_api.update_city_tax_rule(
             p_effective_date         => v_ud_cty.effective_start_date
            ,p_datetrack_mode	      => l_update_mode
            ,p_object_version_number  => l_ovn
            ,p_emp_city_tax_rule_id   => l_emp_city_tax_rule_id
            ,p_additional_wa_rate     => v_ud_cty.additional_wa_rate
            ,p_filing_status_code     => v_ud_cty.filing_status_code
            ,p_lit_additional_tax     => v_ud_cty.lit_additional_tax
            ,p_lit_override_amount    => v_ud_cty.lit_override_amount
            ,p_lit_override_rate      => v_ud_cty.lit_override_rate
            ,p_withholding_allowances => v_ud_cty.withholding_allowances
            ,p_lit_exempt             => v_ud_cty.lit_exempt
            ,p_sd_exempt              => v_ud_cty.sd_exempt
            ,p_ht_exempt              => v_ud_cty.ht_exempt
            ,p_school_district_code   => v_ud_cty.school_district_code
            ,p_effective_start_date   => l_esd
            ,p_effective_end_date     => l_eed
            );
  END IF;

  hr_utility.set_location(l_proc, 150);
  UPDATE hr_h2pi_city_tax_rules sta
  SET status = 'C'
  WHERE  sta.emp_city_tax_rule_id = v_ud_cty.emp_city_tax_rule_id
  AND    sta.client_id            = p_from_client_id
  AND    sta.effective_start_date  = v_ud_cty.effective_start_date
  AND    sta.effective_end_date    = v_ud_cty.effective_end_date;

  CLOSE csr_ud_city_tax_rule;
  hr_utility.set_location('Leaving:'|| l_proc, 160);
  COMMIT;

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 170);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => v_ud_cty.emp_city_tax_rule_id,
                p_table_name           => 'HR_H2PI_CITY_TAX_RULES',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;

END;


/*********************************************************************
 * US SPECIFIC
 ********************************************************************/
PROCEDURE upload_tax_percentage (p_from_client_id  NUMBER,
                                 p_person_id       NUMBER) IS

CURSOR csr_ed_assignment (p_per_id NUMBER) IS
  SELECT DISTINCT asg.assignment_id
  FROM   hr_h2pi_assignments_v asg
  WHERE  asg.person_id = p_per_id;

CURSOR csr_city_pct (p_ud_iv_id1 NUMBER,
                       p_ud_iv_id2 NUMBER,
                       p_ud_asg_id NUMBER,
                       p_ed_iv_id1 NUMBER,
                       p_ed_iv_id2 NUMBER,
                       p_ed_asg_id NUMBER,
                       p_county    VARCHAR2) IS
SELECT SUBSTR(fr_eev.screen_entry_value, 8, 4) city_code,
       SUM (fr_eev2.screen_entry_value)        percentage,
       SUM (fr_eev2.screen_entry_value) - SUM (to_eev2.screen_entry_value) pct_diff
  FROM  hr_h2pi_element_entry_values_v to_eev,
        hr_h2pi_element_entry_values_v to_eev2,
        hr_h2pi_element_entries_v to_ele,
        hr_h2pi_element_entry_values fr_eev,
        hr_h2pi_element_entry_values fr_eev2,
        hr_h2pi_element_entries fr_ele
  WHERE to_ele.element_entry_id = to_eev.element_entry_id
  AND   to_eev.input_value_id = p_ed_iv_id1
  AND   to_eev2.input_value_id = p_ed_iv_id2
  AND   fr_eev.input_value_id = p_ud_iv_id1
  AND   fr_eev.client_id      = p_from_client_id --
  AND   fr_eev2.input_value_id = p_ud_iv_id2
  AND   fr_eev2.client_id     = p_from_client_id --
  AND   to_ele.effective_start_date =  (SELECT MAX(to_ele_t.effective_start_date)
                                        from hr_h2pi_element_entries_v to_ele_t
                                        WHERE to_ele_t.element_entry_id = to_ele.element_entry_id)
  AND   to_eev.effective_start_date BETWEEN to_ele.effective_start_date
                                        AND to_ele.effective_end_date
  AND   to_ele.element_entry_id = to_eev2.element_entry_id
  AND   to_eev2.effective_start_date BETWEEN to_ele.effective_start_date
                                        AND to_ele.effective_end_date
  AND   to_ele.creator_type = 'UT'
  AND   fr_ele.element_entry_id = fr_eev.element_entry_id
  AND   fr_ele.client_id        = p_from_client_id --
  AND   fr_ele.effective_start_date =  (SELECT MAX(fr_ele_t.effective_start_date)
                                        from hr_h2pi_element_entries fr_ele_t
                                        WHERE fr_ele_t.element_entry_id = fr_ele.element_entry_id
                                        AND   fr_ele_t.client_id = p_from_client_id)
  AND   fr_eev.effective_start_date BETWEEN fr_ele.effective_start_date
                                        AND fr_ele.effective_end_date
  AND   fr_ele.element_entry_id = fr_eev2.element_entry_id
  --AND   fr_eev.effective_start_date BETWEEN fr_ele.effective_start_date
  --                                      AND fr_ele.effective_end_date
  AND   fr_eev2.effective_start_date BETWEEN fr_ele.effective_start_date
                                        AND fr_ele.effective_end_date
  AND   fr_ele.creator_type = 'UT'
  and fr_ele.assignment_id = p_ud_asg_id
  and to_ele.assignment_id = p_ed_asg_id
  and to_eev.screen_entry_value = fr_eev.screen_entry_value
  and SUBSTR(to_eev.screen_entry_value,8,4) <> '0000'
  and SUBSTR(fr_eev.screen_entry_value,1,6) = p_county
  group by SUBSTR(fr_eev.screen_entry_value, 8, 4)

  order by 3;

CURSOR csr_county_pct (p_ud_iv_id1 NUMBER,
                       p_ud_iv_id2 NUMBER,
                       p_ud_asg_id NUMBER,
                       p_ed_iv_id1 NUMBER,
                       p_ed_iv_id2 NUMBER,
                       p_ed_asg_id NUMBER,
                       p_state     VARCHAR2) IS
SELECT SUBSTR(fr_eev.screen_entry_value,4,3) county_code,
       SUM (fr_eev2.screen_entry_value)      percentage,
       SUM (fr_eev2.screen_entry_value) - SUM (to_eev2.screen_entry_value) pct_diff
  FROM  hr_h2pi_element_entry_values_v to_eev,
        hr_h2pi_element_entry_values_v to_eev2,
        hr_h2pi_element_entries_v to_ele,
        hr_h2pi_element_entry_values fr_eev,
        hr_h2pi_element_entry_values fr_eev2,
        hr_h2pi_element_entries fr_ele
  WHERE to_ele.element_entry_id = to_eev.element_entry_id
  AND   to_eev.input_value_id = p_ed_iv_id1
  AND   to_eev2.input_value_id = p_ed_iv_id2
  AND   fr_eev.input_value_id = p_ud_iv_id1
  AND   fr_eev.client_id      = p_from_client_id --
  AND   fr_eev2.input_value_id = p_ud_iv_id2
  AND   fr_eev2.client_id     = p_from_client_id --
  AND   to_ele.effective_start_date =  (SELECT MAX(to_ele_t.effective_start_date)
                                        from hr_h2pi_element_entries_v to_ele_t
                                        WHERE to_ele_t.element_entry_id = to_ele.element_entry_id)
  AND   to_eev.effective_start_date BETWEEN to_ele.effective_start_date
                                        AND to_ele.effective_end_date
  AND   to_ele.element_entry_id = to_eev2.element_entry_id
  AND   to_eev2.effective_start_date BETWEEN to_ele.effective_start_date
                                        AND to_ele.effective_end_date
  AND   to_ele.creator_type = 'UT'
  AND   fr_ele.element_entry_id = fr_eev.element_entry_id
  AND   fr_ele.client_id        = p_from_client_id --
  AND   fr_ele.effective_start_date =  (SELECT MAX(fr_ele_t.effective_start_date)
                                        from hr_h2pi_element_entries fr_ele_t
                                        WHERE fr_ele_t.element_entry_id = fr_ele.element_entry_id
                                        AND   fr_ele_t.client_id = p_from_client_id)
  AND   fr_eev.effective_start_date BETWEEN fr_ele.effective_start_date
                                        AND fr_ele.effective_end_date
  AND   fr_ele.element_entry_id = fr_eev2.element_entry_id
  --AND   fr_eev.effective_start_date BETWEEN fr_ele.effective_start_date
  --                                      AND fr_ele.effective_end_date
  AND   fr_eev2.effective_start_date BETWEEN fr_ele.effective_start_date
                                        AND fr_ele.effective_end_date
  AND   fr_ele.creator_type = 'UT'
  and fr_ele.assignment_id = p_ud_asg_id
  and to_ele.assignment_id = p_ed_asg_id
  and to_eev.screen_entry_value = fr_eev.screen_entry_value
  and SUBSTR(to_eev.screen_entry_value,4,8) <> '000-0000'
  and SUBSTR(fr_eev.screen_entry_value,1,2) = p_state
  group by SUBSTR(fr_eev.screen_entry_value,4,3)
  order by 3;

CURSOR csr_state_pct (p_ud_iv_id1 NUMBER,
                       p_ud_iv_id2 NUMBER,
                       p_ud_asg_id NUMBER,
                       p_ed_iv_id1 NUMBER,
                       p_ed_iv_id2 NUMBER,
                       p_ed_asg_id NUMBER) IS
SELECT SUBSTR(fr_eev.screen_entry_value,1,2) state_code,
       SUM (fr_eev2.screen_entry_value)      percentage,
       SUM (fr_eev2.screen_entry_value) - SUM (to_eev2.screen_entry_value) pct_diff
  FROM  hr_h2pi_element_entry_values_v to_eev,
        hr_h2pi_element_entry_values_v to_eev2,
        hr_h2pi_element_entries_v to_ele,
        hr_h2pi_element_entry_values fr_eev,
        hr_h2pi_element_entry_values fr_eev2,
        hr_h2pi_element_entries fr_ele
  WHERE to_ele.element_entry_id = to_eev.element_entry_id
  AND   to_eev.input_value_id = p_ed_iv_id1
  AND   to_eev2.input_value_id = p_ed_iv_id2
  AND   fr_eev.input_value_id = p_ud_iv_id1
  AND   fr_eev.client_id      = p_from_client_id --
  AND   fr_eev2.input_value_id = p_ud_iv_id2
  AND   fr_eev2.client_id     = p_from_client_id --
  AND   to_ele.effective_start_date =  (SELECT MAX(to_ele_t.effective_start_date)
                                        from hr_h2pi_element_entries_v to_ele_t
                                        WHERE to_ele_t.element_entry_id = to_ele.element_entry_id)
  AND   to_eev.effective_start_date BETWEEN to_ele.effective_start_date
                                        AND to_ele.effective_end_date
  AND   to_ele.element_entry_id = to_eev2.element_entry_id
  AND   to_eev2.effective_start_date BETWEEN to_ele.effective_start_date
                                        AND to_ele.effective_end_date
  AND   to_ele.creator_type = 'UT'
  AND   fr_ele.element_entry_id = fr_eev.element_entry_id
  AND   fr_ele.client_id        = p_from_client_id --
  AND   fr_ele.effective_start_date =  (SELECT MAX(fr_ele_t.effective_start_date)
                                        from hr_h2pi_element_entries fr_ele_t
                                        WHERE fr_ele_t.element_entry_id = fr_ele.element_entry_id
                                        AND   fr_ele_t.client_id = p_from_client_id)
  AND   fr_eev.effective_start_date BETWEEN fr_ele.effective_start_date
                                        AND fr_ele.effective_end_date
  AND   fr_ele.element_entry_id = fr_eev2.element_entry_id
  --AND   fr_eev.effective_start_date BETWEEN fr_ele.effective_start_date
  --                                      AND fr_ele.effective_end_date
  AND   fr_eev2.effective_start_date BETWEEN fr_ele.effective_start_date
                                        AND fr_ele.effective_end_date
  AND   fr_ele.creator_type = 'UT'
  and fr_ele.assignment_id = p_ud_asg_id
  and to_ele.assignment_id = p_ed_asg_id
  and to_eev.screen_entry_value = fr_eev.screen_entry_value
  group by SUBSTR(fr_eev.screen_entry_value,1,2)
  order by 3;

CURSOR csr_ed_input_values IS
  SELECT ipv1.input_value_id,
         ipv2.input_value_id
  FROM   pay_input_values_f ipv1,
         pay_input_values_f ipv2,
         pay_element_types_f elt
  WHERE  element_name = 'VERTEX'
  AND    elt.element_type_id = ipv1.element_type_id
  AND    elt.element_type_id = ipv2.element_type_id
  AND    ipv1.name = 'Jurisdiction'
  AND    ipv2.name = 'Percentage';

CURSOR csr_element_entry (p_asg_id NUMBER) IS
  SELECT emp_state_tax_rule_id,
         jurisdiction_code
  FROM   hr_h2pi_state_tax_rules_v
  WHERE  assignment_id = p_asg_id;

l_proc               VARCHAR2(72) := g_package||'upload_tax_percentage';

l_encoded_message    VARCHAR2(200);

l_input_value_id1    pay_input_values_f.input_value_id%TYPE;
l_input_value_id2    pay_input_values_f.input_value_id%TYPE;
l_ud_input_value_id1 pay_input_values_f.input_value_id%TYPE;
l_ud_input_value_id2 pay_input_values_f.input_value_id%TYPE;
l_ud_assignment_id   per_all_assignments_f.assignment_id%TYPE;
l_person_id          per_all_people_f.person_id%TYPE;

l_effective_date DATE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_person_id := hr_h2pi_map.get_to_id
                           (p_table_name   => 'PER_ALL_PEOPLE_F',
                            p_from_id      => p_person_id,
                            p_report_error => TRUE);

  FOR v_asg IN csr_ed_assignment(l_person_id) LOOP

    hr_utility.set_location(l_proc, 20);
    l_ud_assignment_id := hr_h2pi_map.get_from_id
                              (p_table_name   => 'PER_ALL_ASSIGNMENTS_F',
                               p_to_id        => v_asg.assignment_id,
                               p_report_error => TRUE);

    SELECT MAX(effective_end_date)
    INTO   l_effective_date
    FROM   hr_h2pi_element_entries
    WHERE  assignment_id = l_ud_assignment_id;

    OPEN csr_ed_input_values;
    FETCH csr_ed_input_values INTO l_input_value_id1,
                                   l_input_value_id2;
    CLOSE csr_ed_input_values;

    l_ud_input_value_id1 := hr_h2pi_map.get_from_id
                              (p_table_name   => 'PAY_INPUT_VALUES_F',
                               p_to_id        => l_input_value_id1,
                               p_report_error => TRUE);
    l_ud_input_value_id2 := hr_h2pi_map.get_from_id
                              (p_table_name   => 'PAY_INPUT_VALUES_F',
                               p_to_id        => l_input_value_id2,
                               p_report_error => TRUE);


    FOR v_sta IN csr_state_pct(l_ud_input_value_id1,
                               l_ud_input_value_id2,
                               l_ud_assignment_id,
                               l_input_value_id1,
                               l_input_value_id2,
                               v_asg.assignment_id) LOOP
      hr_utility.set_location(l_proc, 30);
      IF v_sta.pct_diff > 0 THEN
        hr_utility.set_location(l_proc, 40);
        pay_us_tax_api.correct_tax_percentage(
             p_assignment_id  => v_asg.assignment_id
            ,p_effective_date => l_effective_date
            ,p_state_code     => v_sta.state_code
            ,p_county_code    => '000'
            ,p_city_code      => '0000'
            ,p_percentage     => v_sta.percentage);
      END IF;

      FOR v_cnt IN csr_county_pct(l_ud_input_value_id1,
                                  l_ud_input_value_id2,
                                  l_ud_assignment_id,
                                  l_input_value_id1,
                                  l_input_value_id2,
                                  v_asg.assignment_id,
                                  v_sta.state_code) LOOP
        hr_utility.set_location(l_proc, 50);
        IF v_cnt.pct_diff > 0 THEN
        hr_utility.set_location(l_proc, 60);
          pay_us_tax_api.correct_tax_percentage(
             p_assignment_id  => v_asg.assignment_id
            ,p_effective_date => l_effective_date
            ,p_state_code     => v_sta.state_code
            ,p_county_code    => v_cnt.county_code
            ,p_city_code      => '0000'
            ,p_percentage     => v_cnt.percentage);
        END IF;

        FOR v_cty IN csr_city_pct(l_ud_input_value_id1,
                                  l_ud_input_value_id2,
                                  l_ud_assignment_id,
                                  l_input_value_id1,
                                  l_input_value_id2,
                                  v_asg.assignment_id,
                                  v_sta.state_code||'-'||v_cnt.county_code) LOOP
          hr_utility.set_location(l_proc, 70);
          IF v_cty.pct_diff <> 0 THEN
            hr_utility.set_location(l_proc, 80);
            pay_us_tax_api.correct_tax_percentage(
             p_assignment_id  => v_asg.assignment_id
            ,p_effective_date => l_effective_date
            ,p_state_code     => v_sta.state_code
            ,p_county_code    => v_cnt.county_code
            ,p_city_code      => v_cty.city_code
            ,p_percentage     => v_cty.percentage);
          END IF;
        END LOOP;

        hr_utility.set_location(l_proc, 90);
        IF v_cnt.pct_diff < 0 THEN
          hr_utility.set_location(l_proc, 100);
          pay_us_tax_api.correct_tax_percentage(
             p_assignment_id  => v_asg.assignment_id
            ,p_effective_date => l_effective_date
            ,p_state_code     => v_sta.state_code
            ,p_county_code    => v_cnt.county_code
            ,p_city_code      => '0000'
            ,p_percentage     => v_cnt.percentage);
        END IF;

      END LOOP;

      hr_utility.set_location(l_proc, 110);
      IF v_sta.pct_diff < 0 THEN
        hr_utility.set_location(l_proc, 120);
        pay_us_tax_api.correct_tax_percentage(
             p_assignment_id  => v_asg.assignment_id
            ,p_effective_date => l_effective_date
            ,p_state_code     => v_sta.state_code
            ,p_county_code    => '000'
            ,p_city_code      => '0000'
            ,p_percentage     => v_sta.percentage);
      END IF;

    END LOOP;

  END LOOP;

  hr_utility.set_location(l_proc, 125);
  UPDATE hr_h2pi_element_entry_values eev
  SET eev.status = 'C'
  WHERE eev.element_entry_id IN (SELECT ee.element_entry_id
                                 FROM   hr_h2pi_element_entries ee
                                 WHERE  ee.person_id = p_person_id
                                 AND    ee.creator_type = 'UT'
                                 AND    ee.client_id = p_from_client_id);

  UPDATE hr_h2pi_element_entries ee
  SET ee.status = 'C'
  WHERE  ee.person_id  = p_person_id
  AND    ee.creator_type = 'UT'
  AND    ee.client_id = p_from_client_id;

  hr_utility.set_location('Entering:'|| l_proc, 130);

EXCEPTION
  WHEN APP_EXCEPTIONS.APPLICATION_EXCEPTION THEN
    ROLLBACK;
    hr_utility.set_location(l_proc, 140);
    l_encoded_message := fnd_message.get_encoded;
    hr_h2pi_error.data_error
               (p_from_id              => l_ud_assignment_id,
                p_table_name           => 'HR_H2PI_ASSIGNMENTS',
                p_message_level        => 'FATAL',
                p_message_text         => l_encoded_message);
    COMMIT;
    RAISE;
  WHEN MAPPING_ID_MISSING THEN
    hr_utility.set_location(l_proc, 150);
    RAISE PERSON_ERROR;

END;

END hr_h2pi_person_upload;

/
