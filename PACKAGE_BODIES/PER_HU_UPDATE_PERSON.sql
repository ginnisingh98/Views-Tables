--------------------------------------------------------
--  DDL for Package Body PER_HU_UPDATE_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HU_UPDATE_PERSON" as
/* $Header: pehuperp.pkb 120.4 2006/09/21 09:13:50 mgettins noship $ */
g_package   VARCHAR2(30) := 'PER_HU_UPDATE_PERSON.';

PROCEDURE update_hu_person (p_person_id           NUMBER
                           ,p_last_name           VARCHAR2
                           ,p_first_name          VARCHAR2
                           ,p_national_identifier VARCHAR2
                           ,p_per_information1    VARCHAR2
                           ,p_per_information2    VARCHAR2
                           ,p_effective_date      DATE
                           ) is


l_proc          VARCHAR2(72) := g_package||'UPDATE_HU_PERSON';
CURSOR csr_person_type IS
    SELECT  ppt.system_person_type,ppt.seeded_person_type_key
    FROM    per_person_types ppt,per_person_type_usages_f ptu
	WHERE   ppt.person_type_id = ptu.person_type_id
    AND     p_effective_date BETWEEN ptu.effective_start_date AND ptu.effective_end_date
    AND     ptu.person_id = p_person_id;

l_person_type       per_person_types.system_person_type%TYPE;
l_seed_person_type  per_person_types.seeded_person_type_key%TYPE;
BEGIN
  --
  -- Added for GSI Bug 5472781
  --
  IF hr_utility.chk_product_install('Oracle Human Resources', 'HU') THEN
    --
    OPEN csr_person_type;
    FETCH csr_person_type into l_person_type,l_seed_person_type;
    CLOSE csr_person_type;

        hr_api.mandatory_arg_error
               (p_api_name         => l_proc,
                p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','LAST_NAME'),
                p_argument_value   => p_last_name
               );
        IF  length(p_last_name)>40 THEN
            hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
            hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('HU_FORM_LABELS','LAST_NAME'));
            hr_utility.set_message_token('COLUMN_VALUE',p_last_name);
            hr_utility.set_message_token('MAX_LENGTH','40');
            hr_utility.raise_error;
        END IF;

        /* hr_api.mandatory_arg_error
	        (p_api_name         => l_proc,
	         p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','FIRST_NAME'),
	         p_argument_value   => p_first_name
	        );*/
         IF  length(p_first_name)>40 THEN
            hr_utility.set_message(800, 'HR_289712_UTF8_LENGTH_EXCEEDED');
            hr_utility.set_message_token('COLUMN_NAME',hr_general.decode_lookup('HU_FORM_LABELS','FIRST_NAME'));
            hr_utility.set_message_token('COLUMN_VALUE',p_first_name);
            hr_utility.set_message_token('MAX_LENGTH','40');
            hr_utility.raise_error;
         END IF;

-- For bug 4665225
/*IF l_person_type ='EMP' or  l_seed_person_type='CONTACT' THEN
    hr_api.mandatory_arg_error
    (p_api_name         => l_proc,
     p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','MOTHERS_MAIDEN_NAME'),
     p_argument_value   => p_per_information1
    );
END IF;*/

    IF l_person_type='EMP' THEN
    /*    hr_api.mandatory_arg_error
    (p_api_name         => l_proc,
     p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','TAX_ID_NO'),
     p_argument_value   => p_per_information2
    );
    */

      IF fnd_profile.value('PER_NATIONAL_IDENTIFIER_VALIDATION') in ('ERROR','WARN') THEN
        hr_api.mandatory_arg_error
          (p_api_name         => l_proc,
           p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','SS_CODE'),
           p_argument_value   => p_national_identifier
          );
      END IF;
      hr_api.mandatory_arg_error
        (p_api_name         => l_proc,
         p_argument         => hr_general.decode_lookup('HU_FORM_LABELS','FIRST_NAME'),
         p_argument_value   => p_first_name
        );
    END IF;
    --
  END IF;
  --
END update_hu_person;
--
END PER_HU_UPDATE_PERSON;

/
