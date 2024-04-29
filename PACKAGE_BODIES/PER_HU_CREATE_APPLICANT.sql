--------------------------------------------------------
--  DDL for Package Body PER_HU_CREATE_APPLICANT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_CREATE_APPLICANT" as
/* $Header: pehuappp.pkb 120.2 2006/09/20 16:31:36 mgettins noship $ */
g_package   VARCHAR2(30) := 'PER_HU_CREATE_APPLICANT.';

PROCEDURE create_hu_applicant (p_last_name           VARCHAR2
                              ,p_first_name          VARCHAR2
                              ,p_per_information1    VARCHAR2
                              ,p_per_information2    VARCHAR2
                               ) is

l_proc                  VARCHAR2(72) := g_package||'CREATE_HU_APPLICANT';

BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --

       --Bug 4411143
       /*hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','FIRST_NAME'),
            p_argument_value   => p_first_name
           );*/

      /*  hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'Tax Identification Number',
            p_argument_value   => p_per_information2
           );

        hr_api.mandatory_arg_error
           (p_api_name         => l_proc,
            p_argument         => 'Mothers Maiden Name',
            p_argument_value   => p_per_information1
           );*/

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
END create_hu_applicant;

END PER_HU_CREATE_APPLICANT;

/
