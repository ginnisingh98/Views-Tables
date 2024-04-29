--------------------------------------------------------
--  DDL for Package Body HR_KW_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KW_VALIDATE_PKG" AS
/* $Header: pekwvald.pkb 120.10 2006/12/29 14:19:24 spendhar noship $ */
  g_type          VARCHAR2(1) := NULL;
  g_per_type      VARCHAR2(1) := NULL;
  PROCEDURE VALIDATE
  (p_person_type_id                 in      number
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  ) IS
    v_field         varchar2(300);
    l_valid_date    varchar2(10);
    CURSOR c_type IS
    SELECT /*+ INDEX(ppt,PER_PERSON_TYPES_PK) */ 'Y'
    FROM   per_person_types ppt
    WHERE  ppt.system_person_type IN ('EMP','APL')
    AND    ppt.person_type_Id = p_person_type_id;
    CURSOR c_per_type IS
    SELECT 'Y'
    FROM   per_person_types ppt
    WHERE  ppt.system_person_type LIKE 'EMP%'
    AND    ppt.person_type_Id = p_person_type_id;
  BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    v_field := NULL;
    g_type := NULL;
    g_per_type := NULL;
    IF p_per_information_category = 'KW' THEN

    OPEN c_per_type;
    FETCH c_per_type INTO g_per_type;
    CLOSE c_per_type;

      --Validate not null fields
    IF g_per_type IS NOT NULL THEN -- for fixing Bug 4436984
      IF p_first_name IS NULL THEN
        IF v_field IS NULL THEN
          v_field := hr_general.decode_lookup('KW_FORM_LABELS','M_FIRST_NAME');
        ELSE
          v_field := v_field||', '||hr_general.decode_lookup('KW_FORM_LABELS','M_FIRST_NAME');
        END IF;
      END IF;
    END IF; -- end for EMP check


-- For enhancement 4522277. Making national id non mandatory for all person types.

      /*IF g_per_type IS NOT NULL THEN

        IF p_national_identifier IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('KW_FORM_LABELS','CIVIL_IDENTIFIER');
          ELSE
            v_field := v_field||hr_general.decode_lookup('KW_FORM_LABELS','CIVIL_IDENTIFIER');
          END IF;
        END IF;
    END IF;*/

    /*IF g_per_type IS NOT NULL THEN
      IF p_per_information3 IS NULL THEN
        IF v_field IS NULL THEN
          v_field := hr_general.decode_lookup('KW_FORM_LABELS','M_ALT_FIRST_NAME');
        ELSE
          v_field := v_field||', '||hr_general.decode_lookup('KW_FORM_LABELS','M_ALT_FIRST_NAME');
        END IF;
      END IF;
    END IF;

    IF g_per_type IS NOT NULL THEN
      IF p_per_information6 IS NULL THEN
        IF v_field IS NULL THEN
          v_field := hr_general.decode_lookup('KW_FORM_LABELS','M_ALT_FAMILY_NAME');
        ELSE
          v_field := v_field||', '||hr_general.decode_lookup('KW_FORM_LABELS','M_ALT_FAMILY_NAME');
        END IF;
      END IF;
    END IF;*/ -- Removed with reference to bug #4150446

      OPEN c_type;
      FETCH c_type INTO g_type;
      CLOSE c_type;
      IF g_per_type IS NOT NULL THEN -- for fixing Bug 4436984
        IF p_nationality IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('KW_FORM_LABELS','NATIONALITY');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('KW_FORM_LABELS','NATIONALITY');
          END IF;
        END IF;
      END IF;
      IF v_field IS NOT NULL THEN
        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
      END IF;
    END IF;
  END IF;
  END VALIDATE;
  --Procedure for validating person
  PROCEDURE PERSON_VALIDATE
  (p_person_id                      in      number
  ,p_person_type_id                 in      number
  ,p_effective_date                 in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  ) IS
   CURSOR csr_person_type_id IS
   SELECT person_type_id
   FROM   per_all_people_f
   WHERE  person_id = p_person_id
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
   l_person_type_id  NUMBER;
   l_person_type     VARCHAR2(20);
   CURSOR chk_person_type IS
   SELECT 'Y'
   FROM   per_person_types ppt
   WHERE  ppt.system_person_type IN ('CWK')
   AND    ppt.person_type_id = p_person_type_id;
  BEGIN
    OPEN csr_person_type_id;
    FETCH csr_person_type_id INTO l_person_type_id;
    CLOSE csr_person_type_id;
    l_person_type := NULL;
    OPEN chk_person_type;
    FETCH chk_person_type INTO l_person_type;
    CLOSE chk_person_type;
    IF  NVL(l_person_type,'N') <> 'Y' THEN
    validate
    (p_person_type_id             =>  l_person_type_id
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_nationality                =>  p_nationality
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_per_information_category   =>  p_per_information_category
    ,p_per_information1           =>  p_per_information1
    ,p_per_information2           =>  p_per_information2
    ,p_per_information3           =>  p_per_information3
    ,p_per_information4           =>  p_per_information4
    ,p_per_information5           =>  p_per_information5
    ,p_per_information6           =>  p_per_information6
    ,p_per_information7           =>  p_per_information7
    ,p_per_information8           =>  p_per_information8
    ,p_per_information9           =>  p_per_information9
    ,p_per_information10          =>  p_per_information10);
    END IF;

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    if g_type IS NOT NULL THEN

     if p_per_information_category = 'KW' and (p_per_information8 is not null and p_per_information8 <> hr_api.g_varchar2 ) then
  	    --
	      -- Check that the religion exists in hr_lookups for the
	      -- lookup type 'GCC_RELIGION' with an enabled flag set to 'Y' and that
	      -- the effective start date of the person is between start date
	      -- active and end date active in hr_lookups.
	      --
	      if hr_api.not_exists_in_hr_lookups
	        (p_effective_date        => p_effective_date
	        ,p_lookup_type           => 'GCC_RELIGION'
	        ,p_lookup_code           => p_per_information8
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375407_KW_INVALID_RELIGION');
	        hr_utility.raise_error;
	        --
	      end if;
      end if;

	/* Added for previous nationality check */

      if p_per_information_category = 'KW' and (p_per_information7 is not null and p_per_information7 <> hr_api.g_varchar2 )then

	      if hr_api.not_exists_in_hr_lookups
        	(p_effective_date        => p_effective_date
	        ,p_lookup_type           => 'NATIONALITY'
	        ,p_lookup_code           => p_per_information7
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375411_KW_INVALID_PREV_NAT');
	        hr_utility.raise_error;
	        --
	      end if;
     end if;

    end if;
  END IF;
  END PERSON_VALIDATE;
  --Procedure for validating applicant
  PROCEDURE APPLICANT_VALIDATE
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_date_received                  in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  ) IS
    l_person_type_id  NUMBER;
   BEGIN
    per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => p_business_group_id
    ,p_expected_sys_type => 'APL'
    );
    validate
    (p_person_type_id             =>  l_person_type_id
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_nationality                =>  p_nationality
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_per_information_category   =>  p_per_information_category
    ,p_per_information1           =>  p_per_information1
    ,p_per_information2           =>  p_per_information2
    ,p_per_information3           =>  p_per_information3
    ,p_per_information4           =>  p_per_information4
    ,p_per_information5           =>  p_per_information5
    ,p_per_information6           =>  p_per_information6
    ,p_per_information7           =>  p_per_information7
    ,p_per_information8           =>  p_per_information8
    ,p_per_information9           =>  p_per_information9
    ,p_per_information10          =>  p_per_information10);

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    if g_type IS NOT NULL THEN

     if p_per_information_category = 'KW' and (p_per_information8 is not null  and p_per_information8 <> hr_api.g_varchar2 ) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'GCC_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
	      if hr_api.not_exists_in_hr_lookups
        	(p_effective_date        => p_date_received
	        ,p_lookup_type           => 'GCC_RELIGION'
	        ,p_lookup_code           => p_per_information8
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375407_KW_INVALID_RELIGION');
	        hr_utility.raise_error;
	        --
      	      end if;
      end if;

        /* Added for previous nationality check */
      if p_per_information_category = 'KW' and (p_per_information7 is not null and p_per_information7 <> hr_api.g_varchar2 ) then

	      if hr_api.not_exists_in_hr_lookups
        	(p_effective_date        => p_date_received
	        ,p_lookup_type           => 'NATIONALITY'
	        ,p_lookup_code           => p_per_information7
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375411_KW_INVALID_PREV_NAT');
	        hr_utility.raise_error;
	        --
	      end if;
     end if;
    end if;
  END IF;
  END APPLICANT_VALIDATE;
  --Procedure for validating employee
  PROCEDURE EMPLOYEE_VALIDATE
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_hire_date                      in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  ) IS
   l_person_type_id  number;
   l_valid_date      varchar2(10);
  BEGIN
    per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => p_business_group_id
    ,p_expected_sys_type => 'EMP'
    );

    validate
    (p_person_type_id             =>  l_person_type_id
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_nationality                =>  p_nationality
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_per_information_category   =>  p_per_information_category
    ,p_per_information1           =>  p_per_information1
    ,p_per_information2           =>  p_per_information2
    ,p_per_information3           =>  p_per_information3
    ,p_per_information4           =>  p_per_information4
    ,p_per_information5           =>  p_per_information5
    ,p_per_information6           =>  p_per_information6
    ,p_per_information7           =>  p_per_information7
    ,p_per_information8           =>  p_per_information8
    ,p_per_information9           =>  p_per_information9
    ,p_per_information10          =>  p_per_information10);

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'KW' and (p_per_information8 is not null  and p_per_information8 <> hr_api.g_varchar2 ) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'GCC_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
	      if hr_api.not_exists_in_hr_lookups
        	(p_effective_date        => p_hire_date
	        ,p_lookup_type           => 'GCC_RELIGION'
	        ,p_lookup_code           => p_per_information8
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375407_KW_INVALID_RELIGION');
	        hr_utility.raise_error;
	        --
	      end if;
      end if;

        /* Added for previous nationality check */
      if p_per_information_category = 'KW' and (p_per_information7 is not null  and p_per_information7 <> hr_api.g_varchar2 )  then

	      if hr_api.not_exists_in_hr_lookups
	        (p_effective_date        => p_hire_date
	        ,p_lookup_type           => 'NATIONALITY'
        	,p_lookup_code           => p_per_information7
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375411_KW_INVALID_PREV_NAT');
	        hr_utility.raise_error;
	        --
	      end if;
      end if;

    end if;
  END IF;
  END EMPLOYEE_VALIDATE;

  --Procedure for validating contact
  PROCEDURE CONTACT_VALIDATE
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_start_date                     in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  ) IS
   l_person_type_id        	NUMBER;
  BEGIN
    per_per_bus.chk_person_type
     (p_person_type_id    => l_person_type_id
     ,p_business_group_id => p_business_group_id
     ,p_expected_sys_type => 'OTHER'
     );
    validate
    (p_person_type_id             =>  l_person_type_id
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_nationality                =>  p_nationality
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_per_information_category   =>  p_per_information_category
    ,p_per_information1           =>  p_per_information1
    ,p_per_information2           =>  p_per_information2
    ,p_per_information3           =>  p_per_information3
    ,p_per_information4           =>  p_per_information4
    ,p_per_information5           =>  p_per_information5
    ,p_per_information6           =>  p_per_information6
    ,p_per_information7           =>  p_per_information7
    ,p_per_information8           =>  p_per_information8
    ,p_per_information9           =>  p_per_information9
    ,p_per_information10          =>  p_per_information10);

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'KW' and (p_per_information8 is not null  and p_per_information8 <> hr_api.g_varchar2 ) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'GCC_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
	      if hr_api.not_exists_in_hr_lookups
	        (p_effective_date        => p_start_date
	        ,p_lookup_type           => 'GCC_RELIGION'
	        ,p_lookup_code           => p_per_information8
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375407_KW_INVALID_RELIGION');
	        hr_utility.raise_error;
	        --
	      end if;
      end if;

        /* Added for previous nationality check */
      if p_per_information_category = 'KW' and (p_per_information7 is not null  and p_per_information7 <> hr_api.g_varchar2 )  then

	      if hr_api.not_exists_in_hr_lookups
	        (p_effective_date        => p_start_date
	        ,p_lookup_type           => 'NATIONALITY'
	        ,p_lookup_code           => p_per_information7
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375411_KW_INVALID_PREV_NAT');
	        hr_utility.raise_error;
	        --
	      end if;
     end if;

    end if;
  END IF;
  END CONTACT_VALIDATE;

  PROCEDURE CWK_VALIDATE
  (p_business_group_id              in      number
  ,p_person_type_id                 in      number
  ,p_start_date                     in      date
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_per_information_category       in      varchar2 default null
  ,p_per_information1               in      varchar2 default null
  ,p_per_information2               in      varchar2 default null
  ,p_per_information3               in      varchar2 default null
  ,p_per_information4               in      varchar2 default null
  ,p_per_information5               in      varchar2 default null
  ,p_per_information6               in      varchar2 default null
  ,p_per_information7               in      varchar2 default null
  ,p_per_information8               in      varchar2 default null
  ,p_per_information9               in      varchar2 default null
  ,p_per_information10              in      varchar2 default null
  ) IS
   l_person_type_id        	NUMBER;
  BEGIN
    per_per_bus.chk_person_type
     (p_person_type_id    => l_person_type_id
     ,p_business_group_id => p_business_group_id
     ,p_expected_sys_type => 'CWK'
     );
    validate
    (p_person_type_id             =>  l_person_type_id
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_nationality                =>  p_nationality
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_per_information_category   =>  p_per_information_category
    ,p_per_information1           =>  p_per_information1
    ,p_per_information2           =>  p_per_information2
    ,p_per_information3           =>  p_per_information3
    ,p_per_information4           =>  p_per_information4
    ,p_per_information5           =>  p_per_information5
    ,p_per_information6           =>  p_per_information6
    ,p_per_information7           =>  p_per_information7
    ,p_per_information8           =>  p_per_information8
    ,p_per_information9           =>  p_per_information9
    ,p_per_information10          =>  p_per_information10);

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'KW' and (p_per_information8 is not null  and p_per_information8 <> hr_api.g_varchar2 ) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'GCC_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
	      if hr_api.not_exists_in_hr_lookups
	        (p_effective_date        => p_start_date
	        ,p_lookup_type           => 'GCC_RELIGION'
	        ,p_lookup_code           => p_per_information8
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375407_KW_INVALID_RELIGION');
	        hr_utility.raise_error;
	        --
	      end if;
      end if;

        /* Added for previous nationality check */
      if p_per_information_category = 'KW' and (p_per_information7 is not null  and p_per_information7 <> hr_api.g_varchar2 ) then

	      if hr_api.not_exists_in_hr_lookups
        	(p_effective_date        => p_start_date
	        ,p_lookup_type           => 'NATIONALITY'
	        ,p_lookup_code           => p_per_information7
	        )
	      then
	        --
	        hr_utility.set_message(800, 'HR_375411_KW_INVALID_PREV_NAT');
	        hr_utility.raise_error;
	        --
	      end if;
     end if;

    end if;
  END IF;
  END CWK_VALIDATE;


--Procedure for validating contract
  PROCEDURE CONTRACT_VALIDATE
  (p_effective_date                 in      date
  ,p_type                           in      varchar2
  ,p_duration                       in      number   default null
  ,p_duration_units                 in      varchar2 default null
  ,p_ctr_information_category       in      varchar2 default null
  ,p_ctr_information1               in      varchar2 default null
  ,p_ctr_information2               in      varchar2 default null
  ,p_ctr_information3               in      varchar2 default null
  ,p_ctr_information4               in      varchar2 default null
  ,p_ctr_information5               in      varchar2 default null
  ) is
    l_field VARCHAR2(300);
  BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

    l_field := NULL;


    IF p_ctr_information_category = 'KW' THEN
            -- Check that the employment status exists in hr_lookups for the
      -- lookup type 'KW_EMPLOYMENT_STATUS' with an enabled flag set to 'Y'
      --
      IF p_ctr_information1 IS NOT NULL THEN
        IF hr_api.not_exists_in_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_lookup_type           => 'KW_EMPLOYMENT_STATUS'
          ,p_lookup_code           => p_ctr_information1
          )
         THEN
          --
          hr_utility.set_message(800, 'HR_375405_KW_INVALID_EMP_STAT');
          hr_utility.raise_error;
        END IF;
      END IF;

          --
      IF p_ctr_information2 IS NOT NULL THEN

        IF (fnd_date.canonical_to_date(p_ctr_information2) < p_effective_date)
         THEN
          --
          hr_utility.set_message(800, 'HR_375406_KW_EXPIRY_INVALID');
          hr_utility.raise_error;
          --
        END IF;
      END IF;

    END IF;
  END IF;
  END CONTRACT_VALIDATE;

--Procedure for validating previous_employer
  PROCEDURE PREVIOUS_EMPLOYER_VALIDATE
  (p_employer_name              IN      varchar2  default hr_api.g_varchar2
  ,p_effective_date             IN      date      default hr_api.g_date
  ,p_pem_information_category   IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information1           IN      varchar2  default hr_api.g_varchar2
  )   IS

  v_field			VARCHAR2(300);

  BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

  v_field := NULL;
    IF p_pem_information_category = 'KW' then
     IF p_employer_name is null then
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('KW_FORM_LABELS','PREVIOUS_EMPLOYER');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('KW_FORM_LABELS','PREVIOUS_EMPLOYER');
          END IF;

        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
     END IF;

     IF p_pem_information1 IS NOT NULL THEN
     IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'LEAV_REAS'
        ,p_lookup_code           => p_pem_information1
        )
     THEN
     hr_utility.set_message(800, 'HR_375410_KW_INVALID_LEAV_REAS');
     hr_utility.raise_error;
     END IF;
     END IF;
     END IF;
  END IF;
  END PREVIOUS_EMPLOYER_VALIDATE;

  PROCEDURE VALIDATE_CREATE_ORG_INF(
      p_effective_date                 IN  DATE
     ,p_organization_id                IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT null
     ,p_org_information2               IN  VARCHAR2 DEFAULT null
     ,p_org_information3               IN  VARCHAR2 DEFAULT null
     ,p_org_information4               IN  VARCHAR2 DEFAULT null
     ,p_org_information5               IN  VARCHAR2 DEFAULT null
     ,p_org_information6               IN  VARCHAR2 DEFAULT null
     ,p_org_information7               IN  VARCHAR2 DEFAULT null
     ,p_org_information8               IN  VARCHAR2 DEFAULT null
     ,p_org_information9               IN  VARCHAR2 DEFAULT null
     ,p_org_information10              IN  VARCHAR2 DEFAULT null
 )

AS
return_value VARCHAR2(100);
invalid_mesg VARCHAR2(100);
l_civil_id VARCHAR2(100);

l_length  NUMBER;
l_var1 NUMBER;
m_s NUMBER;
m_total NUMBER;
m_rem NUMBER;
m_num NUMBER;
BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

  l_length := 0;
  l_var1 := 0;
  m_s := 0;
  IF p_org_info_type_code = 'KW_LEGAL_EMPLOYER_DETAILS' THEN
    IF p_org_information6 IS NOT NULL THEN
        return_value := p_org_information6;

         l_length := LENGTH(p_org_information6);

         IF(l_length > 8) THEN

        return_value := '0';
        fnd_message.set_name('PER', 'HR_375403_KW_INVALID_EMPCID_LN');
        hr_utility.raise_error;

        ELSIF(l_length = 8) THEN

        l_var1 := TO_NUMBER(SUBSTR(p_org_information6,1,2));
            IF( l_var1 = 32 OR l_var1 = 34 OR l_var1 = 35 OR
                l_var1 = 36 OR l_var1 = 39 OR l_var1 = 41 OR
                l_var1 = 91 ) THEN
            return_value := p_org_information6; --, invalid_mesg
            ELSE
            fnd_message.set_name('PER', 'HR_375404_KW_INVALID_EMPCID');
            hr_utility.raise_error;
            END IF;

        ELSIF(l_length < 8) THEN

        l_civil_id := LPAD(p_org_information6,7,'0');

        m_s := TO_NUMBER (SUBSTR(l_civil_id,-1,1));
        m_total := 0;
        m_total := m_total +
                  (TO_NUMBER(SUBSTR(l_civil_id,1,1))*1) +
                  (TO_NUMBER(SUBSTR(l_civil_id,2,1))*6) +
                  (TO_NUMBER(SUBSTR(l_civil_id,3,1))*3) +
                  (TO_NUMBER(SUBSTR(l_civil_id,4,1))*7) +
                  (TO_NUMBER(SUBSTR(l_civil_id,5,1))*9) +
                  (TO_NUMBER(SUBSTR(l_civil_id,6,1))*10);

       m_rem := MOD(m_total,11);
       m_num := 11 - m_rem;

           IF(m_num <> m_s) THEN
            fnd_message.set_name('PER', 'HR_375404_KW_INVALID_EMPCID');
            hr_utility.raise_error;
           END IF;

       END IF;

    END IF; --not null check

    IF p_org_information4 IS NOT NULL THEN

         l_length := LENGTH(p_org_information4);

         IF(l_length > 9) THEN
            fnd_message.set_name('PER', 'HR_375402_KW_SSN_INVALID');
            hr_utility.raise_error;
         END IF;
    END IF;

  END IF; -- legcode check
  END IF;
END VALIDATE_CREATE_ORG_INF;

PROCEDURE VALIDATE_UPDATE_ORG_INF(
      p_effective_date                 IN  DATE
     ,p_org_information_id             IN  NUMBER
     ,p_org_info_type_code             IN  VARCHAR2
     ,p_org_information1               IN  VARCHAR2 DEFAULT null
     ,p_org_information2               IN  VARCHAR2 DEFAULT null
     ,p_org_information3               IN  VARCHAR2 DEFAULT null
     ,p_org_information4               IN  VARCHAR2 DEFAULT null
     ,p_org_information5               IN  VARCHAR2 DEFAULT null
     ,p_org_information6               IN  VARCHAR2 DEFAULT null
     ,p_org_information7               IN  VARCHAR2 DEFAULT null
     ,p_org_information8               IN  VARCHAR2 DEFAULT null
     ,p_org_information9               IN  VARCHAR2 DEFAULT null
     ,p_org_information10              IN  VARCHAR2 DEFAULT null
 )
AS
return_value VARCHAR2(100);
invalid_mesg VARCHAR2(100);
l_civil_id VARCHAR2(100);

l_length  NUMBER;
l_var1 NUMBER;
m_s NUMBER;
m_total NUMBER;
m_rem NUMBER;
m_num NUMBER;
BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

  l_length := 0;
  l_var1 := 0;
  m_s := 0;
  IF p_org_info_type_code = 'KW_LEGAL_EMPLOYER_DETAILS' THEN
    IF p_org_information6 IS NOT NULL THEN

        return_value := p_org_information6;

         l_length := LENGTH(p_org_information6);

         IF(l_length > 8) THEN

        return_value := '0';
        fnd_message.set_name('PER', 'HR_375403_KW_INVALID_EMPCID_LN');
        hr_utility.raise_error;

        ELSIF(l_length = 8) THEN

        l_var1 := TO_NUMBER(SUBSTR(p_org_information6,1,2));
            IF( l_var1 = 32 OR l_var1 = 34 OR l_var1 = 35 OR
                l_var1 = 36 OR l_var1 = 39 OR l_var1 = 41 OR
                l_var1 = 91 ) THEN
            return_value := p_org_information6; --, invalid_mesg
            ELSE
            fnd_message.set_name('PER', 'HR_375404_KW_INVALID_EMPCID');
            hr_utility.raise_error;
            END IF;

        ELSIF(l_length < 8) THEN

        l_civil_id := LPAD(p_org_information6,7,'0');

        m_s := TO_NUMBER (SUBSTR(l_civil_id,-1,1));
        m_total := 0;
        m_total := m_total +
                  (TO_NUMBER(SUBSTR(l_civil_id,1,1))*1) +
                  (TO_NUMBER(SUBSTR(l_civil_id,2,1))*6) +
                  (TO_NUMBER(SUBSTR(l_civil_id,3,1))*3) +
                  (TO_NUMBER(SUBSTR(l_civil_id,4,1))*7) +
                  (TO_NUMBER(SUBSTR(l_civil_id,5,1))*9) +
                  (TO_NUMBER(SUBSTR(l_civil_id,6,1))*10);

       m_rem := MOD(m_total,11);
       m_num := 11 - m_rem;

           IF(m_num <> m_s) THEN
            fnd_message.set_name('PER', 'HR_375404_KW_INVALID_EMPCID');
            hr_utility.raise_error;
           END IF;

       END IF;

    END IF; --not null check
    IF p_org_information4 IS NOT NULL THEN

         l_length := LENGTH(p_org_information4);

         IF(l_length > 9) THEN
            fnd_message.set_name('PER', 'HR_375402_KW_SSN_INVALID');
            hr_utility.raise_error;
         END IF;
    END IF;

  END IF; -- legcode check
  END IF;
END VALIDATE_UPDATE_ORG_INF;

PROCEDURE ASSIGNMENT_VALIDATE(
      p_segment2                       IN  VARCHAR2
     ,p_effective_date	               IN  DATE
     ,p_assignment_id                  IN  NUMBER
   ) IS

	l_nationality		VARCHAR2(40);
	l_annuities		VARCHAR2(40);
	l_person_id		NUMBER;
	l_organization_id	NUMBER;
	l_local_nationality	VARCHAR2(40);
	v_field			VARCHAR2(300) := NULL;

	CURSOR csr_nationality IS
        SELECT NATIONALITY
	FROM   per_all_people_f
	WHERE  person_id = l_person_id
	AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

	SELECT person_id
	INTO l_person_id
	FROM per_all_assignments_f
	WHERE assignment_id = p_assignment_id;

	open csr_nationality;
	fetch csr_nationality into l_nationality;
	close csr_nationality;

	--Fetch Local Nationality
	BEGIN
	l_organization_id := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
	SELECT Org_Information1
	INTO l_local_nationality
	FROM HR_ORGANIZATION_INFORMATION
	WHERE ORG_INFORMATION_CONTEXT = 'KW_BG_DETAILS'
	AND ORGANIZATION_ID = l_organization_id;
	EXCEPTION
	WHEN no_data_found THEN
	NULL;
	END;

	/*IF UPPER(l_nationality) = l_local_nationality THEN
	IF (p_segment2 IS NULL) THEN
		IF v_field IS NULL THEN
		 v_field := hr_general.decode_lookup('KW_FORM_LABELS','SOCIAL_SEC_NUMBER');
		ELSE
	         v_field := v_field||', '||hr_general.decode_lookup('KW_FORM_LABELS','SOCIAL_SEC_NUMBER');
		END IF;
	END IF;
	END IF;*/


	IF v_field IS NOT NULL THEN
        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
      END IF;
  END IF;
  END ASSIGNMENT_VALIDATE;

   PROCEDURE DISABILITY_VALIDATE(
       p_effective_date                in     date
      ,p_category                      in     varchar2
      ,p_degree                        in     number   default null
      ,p_dis_information_category      in     varchar2 default null
      ,p_dis_information1              in     varchar2 default null
      ,p_dis_information2              in     varchar2 default null
   )
   AS
   BEGIN

      /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'KW') THEN

	IF p_dis_information_category = 'KW' THEN
		IF (p_degree IS NOT NULL AND p_dis_information1 IS NOT NULL) THEN
			fnd_message.set_name('PER', 'HR_375408_KW_DISABILITY');
		        hr_utility.raise_error;
		END IF;
	END IF;

   END IF;
   END DISABILITY_VALIDATE;

END HR_KW_VALIDATE_PKG;

/
