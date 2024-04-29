--------------------------------------------------------
--  DDL for Package Body HR_H2PI_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_ERROR" AS
/* $Header: hrh2pier.pkb 120.0 2005/05/31 00:39:11 appldev noship $ */
--
--
-- ----------------------------------------------------------------------------
-- |--< Date_Error >-----------------------------------------------------------|
-- ----------------------------------------------------------------------------
-- Description:  Enters the error details into HR_H2PI_MESSAGE_LINES
-- ----------------------------------------------------------------------------
PROCEDURE data_error(p_from_id       number,
                     p_table_name    varchar2,
                     p_message_level varchar2,
                     p_message_name  varchar2 default null,
                     p_message_text  varchar2 default null,
                     p_api_module_id number default null) IS

l_mesg                 VARCHAR2(100);
l_message_name_encoded VARCHAR2(2000);
INVALID_PARAM EXCEPTION;
PRAGMA Exception_Init(Invalid_Param, -20001);
   --
BEGIN
  IF p_table_name IS NULL THEN
    l_mesg := 'The Parameter value for TABLE_NAME cannot be null';
    fnd_file.put_line(FND_FILE.LOG, l_mesg);
    RAISE INVALID_PARAM;
  ELSIF p_message_level IS NULL THEN
    l_mesg := 'The Parameter value for Message Level cannot be null';
    fnd_file.put_line(FND_FILE.LOG, l_mesg);
    RAISE INVALID_PARAM;
  ELSIF p_message_name IS NULL AND p_message_text IS NULL THEN
    l_mesg := 'The Parameter value for Message Name and Message Text '||
              'cannot be null';
    fnd_file.put_line(FND_FILE.LOG, l_mesg);
    RAISE INVALID_PARAM;
  END IF;

  IF UPPER(p_message_level) = 'FATAL' OR
     UPPER(p_message_level) = 'INFORMATION' OR
     UPPER(p_message_level) = 'WARNING' THEN

    IF p_message_name IS NOT NULL AND
       ( UPPER(p_message_name) = 'HR_289235_ED_DATA_REMOVED' OR
         UPPER(p_message_name) = 'HR_289236_UD_DATA_REMOVED' OR
         UPPER(p_message_name) = 'HR_289237_DATA_MISMATCH' OR
         UPPER(p_message_name) = 'HR_289238_GEOCODE_OUT_OF_SYNC' OR
         UPPER(p_message_name) = 'HR_289239_GEOCODE_DATA_CHANGED' OR
         UPPER(p_message_name) = 'HR_289240_MAPPING_ID_INVALID' OR
         UPPER(p_message_name) = 'HR_289241_MAPPING_ID_MISSING' OR
         UPPER(p_message_name) = 'HR_289259_ED_DATA_ADDED' OR
         UPPER(p_message_name) = 'HR_289260_UD_DATA_ADDED' OR
         UPPER(p_message_name) = 'HR_289269_USER_CITY_CODE' OR
         UPPER(p_message_name) = 'HR_289292_EMP_NUM_GEN_MANUAL' ) THEN

      fnd_message.set_name('PER',p_message_name);
      fnd_message.set_token('TABLE_NAME', p_table_name);
      fnd_message.set_token('FROM_ID', NVL(TO_CHAR(p_from_id), 'NULL'));
      l_message_name_encoded := fnd_message.get_encoded;
    ELSIF p_message_text IS NOT NULL THEN
      l_message_name_encoded := p_message_text;
    END IF;
    --
    INSERT INTO hr_h2pi_message_lines
       ( to_business_group_id, request_id, from_id, table_name,
         message_level, message_name_encoded, api_module_id)
    VALUES ( hr_h2pi_upload.g_to_business_group_id, hr_h2pi_upload.g_request_id,
         NVL(p_from_id, 0), p_table_name, UPPER(p_message_level),
         nvl(l_message_name_encoded,p_message_text), p_api_module_id );
  ELSE
    l_mesg := 'Invalid Message Level ' || p_message_level;
    RAISE INVALID_PARAM;
  END IF;

EXCEPTION
  WHEN INVALID_PARAM THEN
    fnd_file.put_line(FND_FILE.LOG, l_mesg);
    RAISE;
  WHEN OTHERS THEN
    fnd_file.put_line(FND_FILE.LOG, SQLERRM );
    RAISE;
END data_error;
--
--
-- ----------------------------------------------------------------------------
-- |--< Check_for_Errors >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
-- Description:  This function checks for any errors written in the table
-- HR_H2PI_MESSAGE_LINES for the passed parameter
-- P_REQUEST_ID (Concurrent Request Id) and error type Fatal
-- ----------------------------------------------------------------------------
FUNCTION check_for_errors RETURN BOOLEAN IS

l_count NUMBER(15);

BEGIN
  SELECT count(*)
    INTO l_count
    FROM hr_h2pi_message_lines
   WHERE request_id = hr_h2pi_upload.g_request_id
     AND message_level = 'FATAL';

  IF l_count > 0 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END check_for_errors;
--
--
-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- Description: This procedure is to generate the Error report by Business Group
-- ----------------------------------------------------------------------------
--
PROCEDURE generate_error_report IS

l_person_name          per_all_people_f.full_name%type;
l_location_name        hr_locations_all.location_code%type;
l_assignment_number    per_all_assignments_f.assignment_number%type;
l_pay_method_name      pay_org_payment_methods_f.org_payment_method_name%type;
l_org_name             hr_all_organization_units.name%type;
l_context              hr_organization_information.org_information_context%type;
l_org_classification   hr_organization_information.org_information1%type;
l_element_name         pay_element_types_f.element_name%type;
TYPE ErrorRecTable is TABLE of hr_h2pi_message_lines%ROWTYPE
     INDEX BY binary_integer;
ErrorRec ErrorRecTable;

CURSOR csr_err_mesg IS
  SELECT message_name_encoded,
         message_level,
         api_module_id,
         to_business_group_id,
         request_id,
         from_id,
         table_name
    FROM hr_h2pi_message_lines
   WHERE to_business_group_id = hr_h2pi_upload.g_to_business_group_id
     AND request_id           = hr_h2pi_upload.g_request_id
GROUP BY to_business_group_id,
         request_id,
         table_name,
         message_level,
         message_name_encoded,
         from_id,
         api_module_id;

l_row_count   NUMBER(15) := 0;
l_to_business_group_name per_business_groups.name%type;
l_text VARCHAR2(2000);
l_table_name hr_h2pi_message_lines.table_name%type := ' ';
--l_from_business_group_id hr_h2pi_message_lines.to_business_group_id%type;
l_from_client_id         hr_h2pi_message_lines.to_business_group_id%type;

BEGIN
  BEGIN
    SELECT name
      INTO l_to_business_group_name
      FROM per_business_groups
     WHERE business_group_id = hr_h2pi_upload.g_to_business_group_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(FND_FILE.LOG,
                        'FATAL - HR_H2PI_ERROR.GENERATE_ERROR_REPORT: ' ||
                         'Invalid Business Group Id');
      RAISE;
  END;

  fnd_file.new_line(FND_FILE.LOG);
  fnd_file.put_line(FND_FILE.LOG, 'Business Group: ' || l_to_business_group_name);
  fnd_file.new_line(FND_FILE.LOG);
  fnd_file.put_line(FND_FILE.LOG, 'Request Id: ' ||  hr_h2pi_upload.g_request_id);
    --
  l_from_client_id := hr_h2pi_upload.get_from_client_id;
  FOR csr_rec IN csr_err_mesg LOOP
    IF csr_rec.table_name <> l_table_name then
      l_table_name := csr_rec.table_name;
      fnd_file.new_line(FND_FILE.LOG);
      fnd_file.put_line(FND_FILE.LOG, 'Table_name: ' || csr_rec.table_name);
      fnd_file.new_line(FND_FILE.LOG);
    END IF;
    -- Included the IF clause to check for encoded characters as set_encoded
    -- returns null if the data is not encoded.
    IF INSTR(csr_rec.message_name_encoded,fnd_global.local_chr(0)) > 0 THEN
      fnd_message.set_encoded(csr_rec.message_name_encoded);
      --l_text := RPAD(csr_rec.message_level,13,' ') || '- ' ||
      --            fnd_message.get;
      --
      l_text := fnd_message.get;
    ELSE
      l_text := RPAD(csr_rec.message_level,13,' ') || '- ' ||
                  csr_rec.message_name_encoded;
    END IF;
    -- code begins
    --l_from_business_group_id := hr_h2pi_main_upload.get_from_business_group_id;
    if upper(csr_rec.table_name) = 'HR_H2PI_EMPLOYEES' then
       BEGIN
         SELECT last_name || ', ' || first_name
           INTO l_person_name
           FROM hr_h2pi_employees
          WHERE person_id = csr_rec.from_id
            --AND business_group_id = l_from_business_group_id
            AND client_id = l_from_client_id
            AND rownum < 2;
         l_text := 'Person Name: ' || l_person_name || ' - ' || l_text;
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             null;
           WHEN OTHERS THEN
             fnd_file.put_line(FND_FILE.LOG, SQLERRM);
         END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_LOCATIONS' then
      BEGIN
        SELECT location_code
          INTO l_location_name
          FROM hr_h2pi_locations
         WHERE location_id = csr_rec.from_id
           --AND business_group_id = l_from_business_group_id;
             AND client_id = l_from_client_id;
        l_text := 'Location Name: ' || l_location_name || ' - ' || l_text ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_HR_ORGANIZATIONS' then
      BEGIN
        SELECT name
          INTO l_org_name
          FROM hr_h2pi_hr_organizations
         WHERE organization_id = csr_rec.from_id
           --AND business_group_id = l_from_business_group_id;
            AND client_id = l_from_client_id;

        l_text := 'Organization Name: ' || l_org_name || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_ASSIGNMENTS' then
      BEGIN
        SELECT assignment_number
          INTO l_assignment_number
          FROM hr_h2pi_assignments
         WHERE assignment_id = csr_rec.from_id
        --   AND business_group_id = l_from_business_group_id
            AND client_id = l_from_client_id
           AND rownum < 2;

        l_text := 'Assignment No: ' || l_assignment_number || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_ELEMENT_ENTRIES' then
      BEGIN
        SELECT asg.assignment_number,
               et.element_name
          INTO l_assignment_number,
               l_element_name
          FROM hr_h2pi_element_entries ee,
               hr_h2pi_id_mapping      map,
               hr_h2pi_id_mapping      map2,
               pay_element_links_f el,
               pay_element_types_f et,
               hr_h2pi_assignments_v   asg
         WHERE ee.element_entry_id = csr_rec.from_id
           --AND ee.business_group_id = l_from_business_group_id
           AND ee.client_id = l_from_client_id
           AND ee.element_link_id = map.from_id
           AND map.table_name = 'PAY_ELEMENT_LINKS_F'
           AND map.to_business_group_id = csr_rec.to_business_group_id
           AND map.to_id = el.element_link_id
           AND el.element_type_id = et.element_type_id
           AND ee.assignment_id = map2.from_id
           AND map2.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map2.to_business_group_id = csr_rec.to_business_group_id
           AND map2.to_id = asg.assignment_id
           AND ee.effective_start_date between el.effective_start_date
                                           and el.effective_end_date
           AND el.effective_start_date between et.effective_start_date
                                           and et.effective_end_date
           AND ee.effective_start_date between asg.effective_start_date
                                           and asg.effective_end_date
           AND rownum < 2;
        l_text := 'Assignment No: ' || l_assignment_number ||
                  ' Element Name: ' || l_element_name || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_SALARIES' then
      BEGIN
        SELECT assignment_number
          INTO l_assignment_number
          FROM hr_h2pi_salaries sal,
               hr_h2pi_assignments_v asg,
               hr_h2pi_id_mapping map
         WHERE sal.pay_proposal_id = csr_rec.from_id
           --AND sal.business_group_id = l_from_business_group_id
           AND sal.client_id = l_from_client_id
           AND sal.assignment_id = map.from_id
           AND map.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map.to_business_group_id = csr_rec.to_business_group_id
           AND map.to_id = asg.assignment_id
           AND asg.business_group_id = csr_rec.to_business_group_id
           AND sal.change_date between asg.effective_start_date
                                   and asg.effective_end_date
           AND rownum < 2;

        l_text := 'Assignment No: ' || l_assignment_number || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_PAYMENT_METHODS' then
      BEGIN
        SELECT asg.assignment_number,
               opm.org_payment_method_name
          INTO l_assignment_number,
               l_pay_method_name
          FROM hr_h2pi_payment_methods ppm,
               hr_h2pi_org_payment_methods opm,
               hr_h2pi_assignments_v asg,
               hr_h2pi_id_mapping map
         WHERE personal_payment_method_id = csr_rec.from_id
           --AND ppm.business_group_id = l_from_business_group_id
           AND ppm.client_id = l_from_client_id
           AND ppm.business_group_id = opm.business_group_id
           AND ppm.org_payment_method_id = opm.org_payment_method_id
           AND asg.business_group_id = csr_rec.to_business_group_id
           AND ppm.assignment_id = map.from_id
           AND map.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map.to_id = asg.assignment_id
           AND ppm.effective_start_date between opm.effective_start_date
                                            and opm.effective_end_date
           AND ppm.effective_start_date between asg.effective_start_date
                                            and asg.effective_end_date
           AND rownum < 2;

         l_text := 'Assignment No: ' || l_assignment_number ||
                   ' Payment Method Name: ' || l_pay_method_name
                   || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_ORGANIZATION_CLASS' then
      BEGIN
        SELECT ogs.name,
               ogc.org_information1
          INTO l_org_name,
               l_org_classification
          FROM hr_h2pi_organization_class ogc,
               hr_h2pi_hr_organizations_v ogs,
               hr_h2pi_id_mapping map
         WHERE ogc.org_information_id = csr_rec.from_id
           --AND ogc.business_group_id = l_from_business_group_id
           AND ogc.client_id = l_from_client_id
           AND ogc.organization_id = map.from_id
           AND map.table_name = 'HR_ALL_ORGANIZATION_UNITS'
           AND ogs.business_group_id = csr_rec.to_business_group_id
           AND map.to_id = ogs.organization_id
           AND rownum < 2;

         l_text := 'Organization Name: ' || l_org_name ||
                   ' Org Classification: ' || l_org_classification
                   || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_ORGANIZATION_INFO' then
      BEGIN
        SELECT name,
               org_information_context
          INTO l_org_name,
               l_context
          FROM hr_h2pi_organization_info   ogi,
               hr_h2pi_hr_organizations_v  ogs,
               hr_h2pi_id_mapping map
         WHERE org_information_id = csr_rec.from_id
           --AND ogi.business_group_id = l_from_business_group_id
           AND ogi.client_id = l_from_client_id
           AND ogi.organization_id = map.from_id
           AND map.table_name = 'HR_ALL_ORGANIZATION_UNITS'
           AND ogs.business_group_id = csr_rec.to_business_group_id
           AND map.to_id = ogs.organization_id
           AND rownum < 2;

        l_text := 'Organization Name: ' || l_org_name ||
                  ' Organization Context: ' || l_context
                  || ' - ' || l_text;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
            SELECT bg.name,
                   ogi.org_information_context
              INTO l_org_name,
                   l_context
              FROM hr_h2pi_organization_info ogi,
                   hr_h2pi_bg_and_gre        bg
             WHERE ogi.org_information_id = csr_rec.from_id
               --AND ogi.business_group_id = l_from_business_group_id
               AND ogi.client_id = l_from_client_id
               AND ogi.business_group_id = bg.business_group_id
               AND ogi.organization_id = bg.organization_id
               AND rownum < 2;

            l_text := 'Organization Name: ' || l_org_name
                      || ' Organization Context: ' || l_context ||
                      ' - ' || l_text;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              null;
            WHEN OTHERS THEN
              fnd_file.put_line(FND_FILE.LOG, SQLERRM );
          END;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_ADDRESSES' then
      BEGIN
        SELECT em.last_name || ', ' || em.first_name
          INTO l_person_name
          FROM hr_h2pi_addresses   ad,
               hr_h2pi_employees_v em,
               hr_h2pi_id_mapping  map
         WHERE ad.address_id = csr_rec.from_id
           --AND ad.business_group_id = l_from_business_group_id
           AND ad.client_id = l_from_client_id
           AND em.business_group_id = csr_rec.to_business_group_id
           AND ad.person_id = map.from_id
           AND map.table_name = 'PER_ALL_PEOPLE_F'
           AND map.to_id = em.person_id
           AND rownum < 2;

        l_text := 'Person Name: ' || l_person_name || ' - ' || l_text ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_FEDERAL_TAX_RULES' then
      BEGIN
        SELECT asg.assignment_number
          INTO l_assignment_number
          FROM hr_h2pi_federal_tax_rules ftr,
               hr_h2pi_assignments_v asg,
               hr_h2pi_id_mapping map
         WHERE ftr.emp_fed_tax_rule_id = csr_rec.from_id
           --AND ftr.business_group_id = l_from_business_group_id
           AND ftr.client_id = l_from_client_id
           AND asg.business_group_id = csr_rec.to_business_group_id
           AND ftr.assignment_id = map.from_id
           AND map.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map.to_id = asg.assignment_id
           AND rownum < 2;

        l_text := 'Assignment No: ' || l_assignment_number || ' - ' || l_text ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
    elsif upper(csr_rec.table_name) = 'HR_H2PI_STATE_TAX_RULES' then
      BEGIN
        SELECT asg.assignment_number
          INTO l_assignment_number
          FROM hr_h2pi_state_tax_rules str,
               hr_h2pi_assignments_v asg,
               hr_h2pi_id_mapping map
         WHERE str.emp_state_tax_rule_id = csr_rec.from_id
           --AND str.business_group_id = l_from_business_group_id
           AND str.client_id = l_from_client_id
           AND str.assignment_id = map.from_id
           AND map.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map.to_id = asg.assignment_id
           AND asg.business_group_id = csr_rec.to_business_group_id
           AND rownum < 2;

        l_text := 'Assignment No: ' || l_assignment_number || ' - ' || l_text ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
--
    elsif upper(csr_rec.table_name) = 'HR_H2PI_COUNTY_TAX_RULES' then
      BEGIN
        SELECT asg.assignment_number
          INTO l_assignment_number
          FROM hr_h2pi_county_tax_rules ctr,
               hr_h2pi_assignments_v asg,
               hr_h2pi_id_mapping map
         WHERE ctr.emp_county_tax_rule_id = csr_rec.from_id
           --AND ctr.business_group_id = l_from_business_group_id
           AND ctr.client_id = l_from_client_id
           AND ctr.assignment_id = csr_rec.from_id
           AND map.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map.to_id = asg.assignment_id
           AND asg.business_group_id = csr_rec.to_business_group_id
           AND rownum < 2;

        l_text := 'Assignment No: ' || l_assignment_number || ' - ' || l_text ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
--
    elsif upper(csr_rec.table_name) = 'HR_H2PI_CITY_TAX_RULES' then
      BEGIN
        SELECT asg.assignment_number
          INTO l_assignment_number
          FROM hr_h2pi_city_tax_rules ctr,
               hr_h2pi_assignments_v asg,
               hr_h2pi_id_mapping map
         WHERE ctr.emp_city_tax_rule_id = csr_rec.from_id
           --AND ctr.business_group_id = l_from_business_group_id
           AND ctr.client_id = l_from_client_id
           AND ctr.assignment_id = map.from_id
           AND map.table_name = 'PER_ALL_ASSIGNMENTS_F'
           AND map.to_id = asg.assignment_id
           AND asg.business_group_id = csr_rec.to_business_group_id
           AND rownum < 2;

        l_text := 'Assignment No: ' || l_assignment_number || ' - ' || l_text ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          null;
        WHEN OTHERS THEN
          fnd_file.put_line(FND_FILE.LOG, SQLERRM);
      END;
--
    end if;
     -- code ends
    fnd_file.put_line(FND_FILE.LOG, l_text);
    fnd_message.clear;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.clear;
    fnd_file.put_line(FND_FILE.LOG, SQLERRM );
    RAISE;
END generate_error_report;
END hr_h2pi_error;

/
