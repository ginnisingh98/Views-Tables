--------------------------------------------------------
--  DDL for Package Body HR_H2PI_MAPPING_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_MAPPING_SETUP" AS
/* $Header: hrh2piim.pkb 120.0 2005/05/31 00:39:30 appldev noship $ */

g_package  VARCHAR2(33) := '  hr_h2pi_mapping_setup.';

PROCEDURE mapping_setup(p_from_client_id NUMBER) IS

  l_proc            VARCHAR2(72) := g_package||'mapping_setup';
--
-- Declaring the local variables to store the Source (HR side) and
-- Destination(payroll side) Business Group Id and Name.
--
  l_from_client_id            NUMBER(15);
  l_to_business_group_id hr_all_organization_units.business_group_id%type;
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_from_client_id       := p_from_client_id;
  l_to_business_group_id := hr_h2pi_upload.g_to_business_group_id;
--
-- Inserts the mapping records for 'HR_LOCATIONS_ALL' table.
--
  INSERT INTO hr_h2pi_id_mapping
     (from_id, to_id, to_business_group_id, table_name)
    SELECT loc1.location_id,
           loc2.location_id,
           l_to_business_group_id,
           'HR_LOCATIONS_ALL'
      FROM hr_h2pi_locations   loc1,
           hr_h2pi_locations_v loc2
     WHERE loc1.client_id         = l_from_client_id
       AND loc2.business_group_id = l_to_business_group_id
       AND loc1.location_code = loc2.location_code
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = loc1.location_id
                       OR    map.to_id      = loc2.location_id)
                       AND   map.table_name = 'HR_LOCATIONS_ALL'
                       AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'PER_PAY_BASES' table.
--
  hr_utility.set_location(l_proc, 20);
  INSERT INTO hr_h2pi_id_mapping
     (from_id, to_id, to_business_group_id, table_name)
    SELECT ppb1.pay_basis_id,
           ppb2.pay_basis_id,
           l_to_business_group_id,
           'PER_PAY_BASES'
      FROM hr_h2pi_pay_bases   ppb1,
           hr_h2pi_pay_bases_v ppb2
     WHERE ppb1.client_id         = l_from_client_id
       AND ppb2.business_group_id = l_to_business_group_id
       AND ppb1.name = ppb2.name
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = ppb1.pay_basis_id
                       OR    map.to_id      = ppb2.pay_basis_id)
                       AND   map.table_name = 'PER_PAY_BASES'
                       AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'HR_ALL_ORGANIZATION_UNITS' table.
--
  hr_utility.set_location(l_proc, 30);
  INSERT INTO hr_h2pi_id_mapping
     (from_id, to_id, to_business_group_id, table_name)
  SELECT v1.from_org_id,
         v2.to_org_id,
         l_to_business_group_id,
         'HR_ALL_ORGANIZATION_UNITS'
    FROM ( SELECT distinct org.organization_id from_org_id,
                  org.business_group_id,
                  org.name
             FROM hr_h2pi_bg_and_gre org
            WHERE org.client_id = l_from_client_id) v1,
         ( SELECT distinct org.organization_id to_org_id,
                  org.business_group_id,
                  org.name
             FROM hr_h2pi_bg_and_gre_v   org
            WHERE org.business_group_id = l_to_business_group_id) v2
   WHERE v1.name = v2.name
     AND NOT EXISTS (SELECT 1
                     FROM   hr_h2pi_id_mapping map
                     WHERE (map.from_id   = v1.from_org_id
                     OR    map.to_id      = v2.to_org_id)
                     AND   map.table_name = 'HR_ALL_ORGANIZATION_UNITS'
                     AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'HR_ORGANIZATION_INFORMATION' table.
--
  hr_utility.set_location(l_proc, 40);
  INSERT INTO hr_h2pi_id_mapping
     (from_id, to_id, to_business_group_id, table_name)
  SELECT v1.from_org_info_id,
         v2.to_org_info_id,
         l_to_business_group_id,
         'HR_ORGANIZATION_INFORMATION'
    FROM ( SELECT distinct ogi.org_information_id from_org_info_id,
                  org.business_group_id,
                  org.name org_name,
                  ogi.org_information_context org_info_name
             FROM hr_h2pi_bg_and_gre        org,
                  hr_h2pi_organization_info ogi
            WHERE org.organization_id = ogi.organization_id
              AND ogi.org_information_context <> 'CLASS'
              AND org.client_id = l_from_client_id) v1,
         ( SELECT distinct ogi.org_information_id to_org_info_id,
                  org.business_group_id,
                  org.name org_name,
                  ogi.org_information_context org_info_name
             FROM hr_h2pi_bg_and_gre_v        org,
                  hr_h2pi_organization_info_v ogi
            WHERE org.organization_id = ogi.organization_id
              AND ogi.org_information_context <> 'CLASS'
              AND org.business_group_id = l_to_business_group_id) v2
   WHERE v1.org_name      = v2.org_name
     AND v1.org_info_name = v2.org_info_name
     AND NOT EXISTS (SELECT 1
                     FROM   hr_h2pi_id_mapping map
                     WHERE (map.from_id   = v1.from_org_info_id
                     OR    map.to_id      = v2.to_org_info_id)
                     AND   map.table_name = 'HR_ORGANIZATION_INFORMATION'
                     AND   map.to_business_group_id = l_to_business_group_id);

--
-- Inserts the mapping records for 'PAY_ALL_PAYROLLS_F' table.
--
  hr_utility.set_location(l_proc, 50);
  INSERT INTO hr_h2pi_id_mapping
      (from_id, to_id, to_business_group_id, table_name)
    SELECT pay1.payroll_id,
           pay2.payroll_id,
           l_to_business_group_id,
           'PAY_ALL_PAYROLLS_F'
      FROM hr_h2pi_payrolls   pay1,
           hr_h2pi_payrolls_v pay2
     WHERE pay1.payroll_name = pay2.payroll_name
       AND pay1.client_id         = l_from_client_id
       AND pay2.business_group_id = l_to_business_group_id
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = pay1.payroll_id
                       OR    map.to_id      = pay2.payroll_id)
                       AND   map.table_name = 'PAY_ALL_PAYROLLS_F'
                       AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'PAY_ELEMENT_TYPES_F' table.
--
  hr_utility.set_location(l_proc, 60);
  INSERT INTO hr_h2pi_id_mapping
    (from_id, to_id, to_business_group_id, table_name)
    SELECT et1.element_type_id,
           et2.element_type_id,
           l_to_business_group_id,
           'PAY_ELEMENT_TYPES_F'
      FROM hr_h2pi_element_types et1,
           pay_element_types_f   et2
     WHERE ((et2.business_group_id IS NULL
         AND et2.legislation_code  = 'US')
        OR  (et2.business_group_id = l_to_business_group_id
         AND et2.attribute2        = 'Y'))
       AND et1.client_id           = l_from_client_id
       AND et1.element_name = et2.element_name
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = et1.element_type_id
                       OR    map.to_id      = et2.element_type_id)
                       AND   map.table_name = 'PAY_ELEMENT_TYPES_F'
                       AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'PAY_INPUT_VALUES_F' table.
--
  hr_utility.set_location(l_proc, 70);
  INSERT INTO hr_h2pi_id_mapping
    (from_id, to_id, to_business_group_id, table_name)
    SELECT iv1.input_value_id,
           iv2.input_value_id,
           l_to_business_group_id,
           'PAY_INPUT_VALUES_F'
      FROM hr_h2pi_input_values  iv1,
           pay_input_values_f    iv2,
           hr_h2pi_element_types et1,
           pay_element_types_f   et2
     WHERE ((et2.business_group_id IS NULL
         AND et2.legislation_code  = 'US')
        OR  (et2.business_group_id = l_to_business_group_id
         AND et2.attribute2        = 'Y'))
       AND et1.client_id           = l_from_client_id
       AND iv1.name                = iv2.name
       AND et1.element_name        = et2.element_name
       AND iv1.element_type_id     = et1.element_type_id
       AND iv2.element_type_id     = et2.element_type_id
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = iv1.input_value_id
                       OR    map.to_id      = iv2.input_value_id)
                       AND   map.table_name = 'PAY_INPUT_VALUES_F'
                       AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'PAY_ELEMENT_LINKS_F' table.
--
  hr_utility.set_location(l_proc, 80);
  INSERT INTO hr_h2pi_id_mapping
    (from_id, to_id, to_business_group_id, table_name)
    SELECT el1.element_link_id,
           el2.element_link_id,
           l_to_business_group_id,
           'PAY_ELEMENT_LINKS_F'
      FROM hr_h2pi_element_links el1,
           pay_element_links_f   el2,
           hr_h2pi_element_types et1,
           pay_element_types_f   et2
     WHERE ((et2.business_group_id IS NULL
         AND et2.legislation_code = 'US')
        OR  (et2.business_group_id = l_to_business_group_id
         AND et2.attribute2        = 'Y'))
       AND el1.client_id           = l_from_client_id
       AND el1.element_type_id     = et1.element_type_id
       AND el2.element_type_id     = et2.element_type_id
       AND el2.business_group_id   = l_to_business_group_id
       AND et1.client_id           = l_from_client_id
       AND et1.element_name        = et2.element_name
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = el1.element_link_id
                       OR    map.to_id      = el2.element_link_id)
                       AND   map.table_name = 'PAY_ELEMENT_LINKS_F'
                       AND   map.to_business_group_id = l_to_business_group_id);
--
-- Inserts the mapping records for 'PAY_ORG_PAYMENT_METHODS_F' table.
--
  hr_utility.set_location(l_proc, 90);
  INSERT INTO hr_h2pi_id_mapping
    (from_id, to_id, to_business_group_id, table_name)
    SELECT opm1.org_payment_method_id,
           opm2.org_payment_method_id,
           l_to_business_group_id,
           'PAY_ORG_PAYMENT_METHODS_F'
      FROM hr_h2pi_org_payment_methods   opm1,
           hr_h2pi_org_payment_methods_v opm2
     WHERE opm1.client_id         = l_from_client_id
       AND opm2.business_group_id = l_to_business_group_id
       AND opm1.org_payment_method_name = opm2.org_payment_method_name
       AND NOT EXISTS (SELECT 1
                       FROM   hr_h2pi_id_mapping map
                       WHERE (map.from_id   = opm1.org_payment_method_id
                       OR    map.to_id      = opm2.org_payment_method_id)
                       AND   map.table_name = 'PAY_ORG_PAYMENT_METHODS_F'
                       AND   map.to_business_group_id = l_to_business_group_id);
  hr_utility.set_location('Leaving:'|| l_proc, 100);
  COMMIT;
END mapping_setup;
--
PROCEDURE mapping_id_upload (p_errbuf      OUT  NOCOPY VARCHAR2,
                             p_retcode     OUT  NOCOPY NUMBER,
                             p_file_name         VARCHAR2,
                             p_business_group_id NUMBER) IS


l_proc            VARCHAR2(72) := g_package||'mapping_id_upload';

l_from_business_group_id hr_all_organization_units.organization_id%TYPE;
l_from_client_id         hr_all_organization_units.organization_id%TYPE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_h2pi_upload.g_request_id :=
              hr_h2pi_main_upload.get_request_id('H2PI_MAPPING_ID_SETUP');
  hr_h2pi_upload.g_to_business_group_id := p_business_group_id;
  l_from_client_id := hr_h2pi_upload.get_from_client_id;

  hr_utility.set_location(l_proc, 20);
  hr_utility.set_location(p_file_name, 20);
  hr_h2pi_upload.upload(p_errbuf    => p_errbuf,
                        p_retcode   => p_retcode,
                        p_file_name => p_file_name);

  hr_utility.set_location(l_proc, 30);
  mapping_setup(l_from_client_id);
  hr_h2pi_validate.validate_bg_and_gre(l_from_client_id);
  hr_h2pi_validate.validate_pay_basis(l_from_client_id);
  hr_h2pi_validate.validate_payroll(l_from_client_id);
  hr_h2pi_validate.validate_org_payment_method(l_from_client_id);
  hr_h2pi_validate.validate_element_type(l_from_client_id);
  hr_h2pi_validate.validate_element_link(l_from_client_id);
  hr_utility.set_location(l_proc, 40);
  IF hr_h2pi_error.check_for_errors THEN
    hr_utility.set_location(l_proc, 50);
    hr_h2pi_error.generate_error_report;
  END IF;
  hr_utility.set_location(l_proc, 60);
  hr_h2pi_main_upload.clear_staging_tables(l_from_client_id);

  hr_utility.set_location('Leaving:'|| l_proc, 70);
END;

END hr_h2pi_mapping_setup;

/
