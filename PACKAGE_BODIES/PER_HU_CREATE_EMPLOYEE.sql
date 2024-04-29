--------------------------------------------------------
--  DDL for Package Body PER_HU_CREATE_EMPLOYEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_CREATE_EMPLOYEE" as
/* $Header: pehuempp.pkb 120.3.12010000.2 2009/07/15 14:24:11 parusia ship $ */
g_package   VARCHAR2(30) := 'PER_HU_CREATE_EMPLOYEE.';

PROCEDURE create_hu_employee (p_last_name           VARCHAR2
                              ,p_first_name          VARCHAR2
                              ,p_national_identifier VARCHAR2
                              ,p_per_information1    VARCHAR2
                              ,p_per_information2    VARCHAR2
                              ) is

l_proc                  VARCHAR2(72) := g_package||'CREATE_HU_EMPLOYEE';

BEGIN


       hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','FIRST_NAME'),
            p_argument_value   => p_first_name
           );
        /*hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','TAX_ID_NO'),
            p_argument_value   => p_per_information2
           );*/
        /*hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','MOTHERS_MAIDEN_NAME'),
            p_argument_value   => p_per_information1
           );*/
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
        -- Bug 8605683
	-- Suppress checking national identifier if the person is getting created
	-- using global deployments (transfer of a person from one BG to another)
        if    per_per_bus.g_global_transfer_in_process is null
	   or per_per_bus.g_global_transfer_in_process = false then
		IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') THEN
		        hr_api.mandatory_arg_error
		           (p_api_name         => l_proc,
		            p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','SS_CODE'),
		            p_argument_value   => p_national_identifier
		           );
		END IF;
        end if ;

       IF  length(p_last_name)>40 THEN
         hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
         hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('HU_FORM_LABELS','LAST_NAME'));
         hr_utility.set_message_token('COLUMN_VALUE',p_last_name);
         hr_utility.set_message_token('MAX_LENGTH','40');
         hr_utility.raise_error;
       END IF;

       IF  length(p_first_name)>40 THEN
         hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
         hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('HU_FORM_LABELS','FIRST_NAME'));
         hr_utility.set_message_token('COLUMN_VALUE',p_first_name);
         hr_utility.set_message_token('MAX_LENGTH','40');
         hr_utility.raise_error;
       END IF;
  END IF;
END create_hu_employee;

END PER_HU_CREATE_EMPLOYEE;

/
