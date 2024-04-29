--------------------------------------------------------
--  DDL for Package Body HR_H2PI_MAIN_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_H2PI_MAIN_UPLOAD" AS
/* $Header: hrh2pimn.pkb 120.0 2005/05/31 00:39:58 appldev noship $ */

g_package  VARCHAR2(33) := '  hr_h2pi_main_upload.';

PROCEDURE clear_staging_tables (p_from_client_id NUMBER) IS

BEGIN

  DELETE FROM hr_h2pi_employees
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_addresses
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_assignments
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_periods_of_service
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_locations
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_pay_bases
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_hr_organizations
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_organization_class
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_organization_info
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_payrolls
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_types
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_input_values
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_links
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_bg_and_gre
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_org_payment_methods
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_patch_status
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_federal_tax_rules
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_state_tax_rules
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_county_tax_rules
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_city_tax_rules
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_salaries
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_cost_allocations
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_payment_methods
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_names
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_entries
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_element_entry_values
  WHERE  client_id = p_from_client_id;


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

  DELETE FROM hr_h2pi_us_city_names
  WHERE  client_id = p_from_client_id;

  DELETE FROM hr_h2pi_us_modified_geocodes
  WHERE  client_id = p_from_client_id;

END;


  FUNCTION  check_incomplete_upload RETURN BOOLEAN IS

  l_proc                    varchar2(72) := g_package|| 'check_incomplete_upload';
  l_stage_rec_count         number(10):= 0 ;
  l_from_client_id          number(15);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    l_from_client_id  := hr_h2pi_upload.get_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_addresses
    where  client_id = l_from_client_id;
    select l_stage_rec_count + count(*)

    into   l_stage_rec_count
    from   hr_h2pi_assignments
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_bg_and_gre
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_city_tax_rules
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_cost_allocations
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_county_tax_rules
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_element_entries
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_element_entry_values
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_element_links
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_element_names
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_element_types
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_employees
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_federal_tax_rules
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_hr_organizations
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_input_values
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_locations
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_organization_class
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_organization_info
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_org_payment_methods
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_patch_status
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_payment_methods
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_payrolls
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_pay_bases
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_periods_of_service
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_salaries
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_state_tax_rules
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_us_city_names
    where  client_id = l_from_client_id;

    select l_stage_rec_count + count(*)
    into   l_stage_rec_count
    from   hr_h2pi_us_modified_geocodes
    where  client_id = l_from_client_id;

    hr_utility.set_location('Leaving:'|| l_proc, 30);
    if l_stage_rec_count > 0 then
       return TRUE;
    else
       return FALSE;
    end if;
  END;

FUNCTION get_request_id (p_process VARCHAR2) RETURN NUMBER IS

  l_call_status BOOLEAN;
  l_request_id  number(15);
  l_rphase      varchar2(80);
  l_rstatus     varchar2(80);
  l_dphase      varchar2(80);
  l_dstatus     varchar2(80);
  l_message     varchar2(80);
  l_proc        varchar2(72) := g_package || 'get_request_id';
BEGIN
  hr_utility.set_location('Entering:'  || l_proc,10);
  l_call_status := fnd_concurrent.get_request_status
                            (l_request_id,
                             'PER',
                             p_process,
                             l_rphase,
                             l_rstatus,
                             l_dphase,
                             l_dstatus,
                             l_message);
  hr_utility.set_location('Leaving:' || l_proc,20);
  return l_request_id;
EXCEPTION
  when others then
    hr_utility.set_location(l_proc,30);
    fnd_message.raise_error;
END get_request_id;


FUNCTION  get_from_business_group_id RETURN NUMBER IS

l_from_business_group_id NUMBER(15);
l_proc  VARCHAR2(72) := g_package||'get_from_business_group_id';

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  l_from_business_group_id := hr_h2pi_map.get_from_id
                      (p_table_name => 'HR_ALL_ORGANIZATION_UNITS',
                       p_to_id      => hr_h2pi_upload.g_to_business_group_id);
  IF l_from_business_group_id  = -1 THEN
    hr_utility.set_location(l_proc, 20);
    hr_h2pi_error.data_error
                        (p_from_id => hr_h2pi_upload.g_to_business_group_id,
                         p_table_name    => 'HR_H2PI_BG_AND_GRE',
                         p_message_level => 'FATAL',
                         p_message_name  => 'HR_289241_MAPPING_ID_MISSING');
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 30);
  RETURN l_from_business_group_id;
END;

PROCEDURE upload_core (p_from_client_id NUMBER) IS

l_proc            VARCHAR2(72) := g_package||'upload_core';
l_message         VARCHAR2(2000);

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_h2pi_validate.validate_bg_and_gre(p_from_client_id);
  hr_h2pi_validate.validate_pay_basis(p_from_client_id);
  hr_h2pi_validate.validate_payroll(p_from_client_id);
  hr_h2pi_validate.validate_org_payment_method(p_from_client_id);
  hr_h2pi_validate.validate_element_type(p_from_client_id);
  hr_h2pi_validate.validate_element_link(p_from_client_id);
  hr_h2pi_validate.validate_geocode(p_from_client_id);
  IF hr_h2pi_error.check_for_errors THEN
    hr_utility.set_location(l_proc, 20);
    hr_h2pi_error.generate_error_report;
    clear_staging_tables(p_from_client_id);
    return;
  END IF;

  hr_utility.set_location(l_proc, 30);
  hr_h2pi_bg_upload.upload_location(p_from_client_id);
  hr_h2pi_bg_upload.upload_hr_organization(p_from_client_id);
  hr_h2pi_bg_upload.upload_element_type(p_from_client_id);
  IF hr_h2pi_error.check_for_errors THEN
    hr_utility.set_location(l_proc, 40);
    hr_h2pi_error.generate_error_report;
    return;
  END IF;

  hr_utility.set_location(l_proc, 50);
  hr_h2pi_person_upload.upload_person_level(p_from_client_id);
  IF hr_h2pi_error.check_for_errors THEN
    hr_utility.set_location(l_proc, 60);
    hr_h2pi_error.generate_error_report;
    return;
  ELSE
    DELETE FROM hr_h2pi_message_lines
    WHERE to_business_group_id = hr_h2pi_upload.g_to_business_group_id;
    fnd_message.set_name('PER', 'HR_289295_UPLOAD_SUCCESSFULL');
    l_message := fnd_message.get_string('PER','HR_289295_UPLOAD_SUCCESSFULL');
    fnd_file.put_line(FND_FILE.LOG,l_message);
  END IF;

  hr_utility.set_location('Leaving:'|| l_proc, 70);

END;

PROCEDURE upload (p_errbuf      OUT NOCOPY  VARCHAR2,
                  p_retcode     OUT NOCOPY  NUMBER,
                  p_file_name         VARCHAR2,
                  p_business_group_id NUMBER) IS


l_proc            VARCHAR2(72) := g_package||'upload';

l_from_business_group_id hr_all_organization_units.organization_id%TYPE;
l_from_client_id         hr_all_organization_units.organization_id%TYPE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  hr_h2pi_upload.g_request_id := get_request_id('H2PI_UPLOAD');
  hr_h2pi_upload.g_to_business_group_id := p_business_group_id;
  l_from_client_id := hr_h2pi_upload.get_from_client_id;

  IF check_incomplete_upload THEN
    upload_core(l_from_client_id);
    hr_utility.set_location('Leaving:'|| l_proc, 20);
  ELSE
    hr_h2pi_upload.upload(p_errbuf    => p_errbuf,
                          p_retcode   => p_retcode,
                          p_file_name => p_file_name);

    upload_core(l_from_client_id);
    hr_utility.set_location('Leaving:'|| l_proc, 20);
  END IF;
END;

-- Remove retry upload after removing concurrent program.
--
PROCEDURE retry_upload (p_errbuf      OUT NOCOPY  VARCHAR2,
                        p_retcode     OUT NOCOPY  NUMBER,
                        p_business_group_id NUMBER) IS

l_proc            VARCHAR2(72) := g_package||'upload';

l_from_business_group_id hr_all_organization_units.organization_id%TYPE;
l_from_client_id         hr_all_organization_units.organization_id%TYPE;

BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_h2pi_upload.g_request_id := get_request_id('H2PI_RETRY_UPLOAD');
  hr_h2pi_upload.g_to_business_group_id := p_business_group_id;
  l_from_client_id := hr_h2pi_upload.get_from_client_id;

  --upload_core(l_from_client_id);
  hr_utility.set_location('Leaving:'|| l_proc, 20);
END;
--
END hr_h2pi_main_upload;

/
