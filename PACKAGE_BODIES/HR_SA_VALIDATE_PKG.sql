--------------------------------------------------------
--  DDL for Package Body HR_SA_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SA_VALIDATE_PKG" AS
/* $Header: pesavald.pkb 120.7.12010000.2 2009/11/13 06:09:55 bkeshary ship $ */
  g_type          VARCHAR2(1) := NULL;
  PROCEDURE validate
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
    v_field         varchar2(300) := NULL;
    l_valid_date    varchar2(10);
    CURSOR c_type IS
    SELECT /*+ INDEX(ppt,PER_PERSON_TYPES_PK) */ 'Y'
    FROM   per_person_types ppt
    WHERE  ppt.system_person_type IN ('CWK','EMP','APL')
    AND    ppt.person_type_Id = p_person_type_id;
    CURSOR c_emp_type IS
    SELECT 'Y'
    FROM   per_person_types
    WHERE  system_person_type LIKE 'EMP%'
    AND    person_type_Id = p_person_type_id;
    l_emp_type       varchar2(10);
  BEGIN

  /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    l_emp_type:= NULL;
    g_type := NULL;
    IF p_per_information_category = 'SA' THEN
      OPEN c_emp_type;
      FETCH c_emp_type INTO l_emp_type;
      CLOSE c_emp_type;
      --Validate not null fields
      /*IF p_title IS NULL THEN
        v_field := hr_general.decode_lookup('SA_FORM_LABELS','TITLE');
      END IF;      */  /* To Fix Bug 4432530*/
      IF l_emp_type = 'Y' THEN -- To Fix Bug 4432530
      IF p_first_name IS NULL THEN
        IF v_field IS NULL THEN
          v_field := hr_general.decode_lookup('SA_FORM_LABELS','M_FIRST_NAME');
        ELSE
          v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','M_FIRST_NAME');
        END IF;
      END IF;
      END IF; -- For EMP check
      /* IF p_per_information1 IS NULL THEN
        IF v_field IS NULL THEN
          v_field := hr_general.decode_lookup('SA_FORM_LABELS','M_FATHER_NAME');
        ELSE
          v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','M_FATHER_NAME');
        END IF;
      END IF;          */ --Removed as per enhancement bug 3580573
      --Validate grandfather is not null if nationality is saudi
      IF UPPER(p_nationality) = FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') THEN
        /*IF p_per_information2 IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('SA_FORM_LABELS','M_GRANDFATHER_NAME');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','M_GRANDFATHER_NAME');
          END IF;
        END IF;*/
        IF p_national_identifier IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('SA_FORM_LABELS','CIVIL_IDENTITY');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','CIVIL_IDENTITY');
          END IF;
        END IF;
      END IF;
    /*  IF l_emp_type = 'Y' THEN
        IF p_per_information3 IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('SA_FORM_LABELS','M_ALT_FIRST_NAME');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','M_ALT_FIRST_NAME');
          END IF;
        END IF;          */ --Removed as per bug 4150446
       /* IF p_per_information4 IS NULL THEN
        IF v_field IS NULL THEN
          v_field := hr_general.decode_lookup('SA_FORM_LABELS','M_ALT_FATHER_NAME');
        ELSE
          v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','M_ALT_FATHER_NAME');
        END IF;
      END IF;        */ --Removed as per enhancement bug 3580573
     /*   IF p_per_information6 IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('SA_FORM_LABELS','M_ALT_FAMILY_NAME');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','M_ALT_FAMILY_NAME');
         END IF;
        END IF;
      END IF;*/ --Removed as per bug 4150446
      OPEN c_type;
      FETCH c_type INTO g_type;
      CLOSE c_type;
      IF g_type IS NOT NULL THEN
        /*IF p_per_information7 IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('SA_FORM_LABELS','RELIGION');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','RELIGION');
          END IF;
        END IF;*/
	IF    per_per_bus.g_global_transfer_in_process IS NULL
	   OR per_per_bus.g_global_transfer_in_process = FALSE THEN   -- To Fix for Bug 9109692
	IF l_emp_type = 'Y' THEN -- To Fix Bug 4438655
        IF p_nationality IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('SA_FORM_LABELS','NATIONALITY');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','NATIONALITY');
          END IF;
        END IF;
	END IF; -- To Fix Bug 4438655
       END IF; -- To fix for bug 9109692
      END IF;
      IF v_field IS NOT NULL THEN
        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
      END IF;
      --Validate the gender/title combination.
      IF p_sex IS NOT NULL THEN
        IF (p_sex = 'M'
        AND UPPER(p_title) IN ('PRINCESS','MISS','MRS.','MS.'))
        OR
        (p_sex = 'F'
        AND UPPER(p_title) IN ('HH','PRINCE','MR.'))  THEN
          --  Error: Values for Sex and Title are inconsistent.
          fnd_message.set_name('PAY', 'HR_6527_PERSON_SEX_AND_TITLE');
  	hr_utility.raise_error;
        END IF;
      END IF;
      --Validate that the Hijrah Birth Date is a valid hijrah date
      IF p_per_information8 is not null THEN
        hr_sa_hijrah_functions.validate_date(p_per_information8,l_valid_date);
      END IF;
    END IF;
  END IF;
  END VALIDATE;
  --Procedure for validating person
  PROCEDURE person_validate
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
  BEGIN
    OPEN csr_person_type_id;
    FETCH csr_person_type_id INTO l_person_type_id;
    CLOSE csr_person_type_id;
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
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'SA' and p_per_information7 is not null then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'SA_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'SA_RELIGION'
        ,p_lookup_code           => p_per_information7
        )
      then
        --
        hr_utility.set_message(800, 'HR_374803_SA_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;
    end if;
  END IF;
  END person_validate;
  --Procedure for validating applicant
  PROCEDURE applicant_validate
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
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'SA' and p_per_information7 is not null then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'SA_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_date_received
        ,p_lookup_type           => 'SA_RELIGION'
        ,p_lookup_code           => p_per_information7
        )
      then
        --
        hr_utility.set_message(800, 'HR_374803_SA_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;
    end if;
  END IF;
  END applicant_validate;
  --Procedure for validating employee
  PROCEDURE employee_validate
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
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'SA' and p_per_information7 is not null then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'SA_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_hire_date
        ,p_lookup_type           => 'SA_RELIGION'
        ,p_lookup_code           => p_per_information7
        )
      then
        --
        hr_utility.set_message(800, 'HR_374803_SA_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;
      --Validate that the Hijrah Hire Date is a valid hijrah date
     if p_per_information_category = 'SA' and p_per_information9 is not null then
       hr_sa_hijrah_functions.validate_date(p_per_information9,l_valid_date);
     end if;
    end if;
  END IF;
  END employee_validate;
  --Procedure for validating contact/cwk
  PROCEDURE contact_cwk_validate
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
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'SA' and p_per_information7 is not null then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'SA_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_start_date
        ,p_lookup_type           => 'SA_RELIGION'
        ,p_lookup_code           => p_per_information7
        )
      then
        --
        hr_utility.set_message(800, 'HR_374803_SA_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;
    end if;
  END IF;
  END contact_cwk_validate;
--Procedure for validating previous_employer
  PROCEDURE previous_employer_validate
  (p_employer_name              IN      varchar2  default hr_api.g_varchar2
  ,p_start_date                 IN      date      default hr_api.g_date
  ,p_pem_information_category   IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information1           IN      varchar2  default hr_api.g_varchar2
  )   IS
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    if p_pem_information_category = 'SA' then
     if p_employer_name is null then
        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',p_employer_name, translate => true );
        hr_utility.raise_error;
     end if;
     end if;
  END IF;
  END previous_employer_validate;
  --Procedure for validating contract
  PROCEDURE contract_validate
  (p_effective_date                 in      date
  ,p_type                           in      varchar2
  ,p_duration                       in      number   default null
  ,p_duration_units                 in      varchar2 default null
  ,p_contractual_job_title          in      varchar2 default null
  ,p_ctr_information_category       in      varchar2 default null
  ,p_ctr_information1               in      varchar2 default null
  ,p_ctr_information2               in      varchar2 default null
  ,p_ctr_information3               in      varchar2 default null
  ,p_ctr_information4               in      varchar2 default null
  ,p_ctr_information5               in      varchar2 default null
  ) is
    l_field VARCHAR2(300) := NULL;
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    IF p_ctr_information_category = 'SA' THEN
      IF p_type = 'SPECIFIED_PERIOD' THEN
        IF p_duration IS NULL THEN
          l_field := hr_general.decode_lookup('SA_FORM_LABELS','DURATION');
        END IF;
        IF p_duration_units IS NULL THEN
          IF l_field IS NULL THEN
            l_field := hr_general.decode_lookup('SA_FORM_LABELS','DURATION_UNITS');
          ELSE
            l_field := l_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','DURATION_UNITS');
          END IF;
        END IF;
      END IF;
      IF p_contractual_job_title IS NULL THEN
        IF l_field IS NULL THEN
          l_field := hr_general.decode_lookup('SA_FORM_LABELS','PROFESSION');
        ELSE
          l_field := l_field||', '||hr_general.decode_lookup('SA_FORM_LABELS','PROFESSION');
        END IF;
      END IF;
      IF l_field IS NOT NULL THEN
        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',l_field, translate => true );
        hr_utility.raise_error;
      END IF;
      -- Check that the employment status exists in hr_lookups for the
      -- lookup type 'SA_EMPLOYMENT_STATUS' with an enabled flag set to 'Y'
      --
      IF p_ctr_information1 IS NOT NULL THEN
        IF hr_api.not_exists_in_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_lookup_type           => 'SA_EMPLOYMENT_STATUS'
          ,p_lookup_code           => p_ctr_information1
          )
         THEN
          --
          hr_utility.set_message(800, 'HR_374804_SA_INVALID_EMP_STAT');
          hr_utility.raise_error;
          --
        END IF;
      END IF;
    END IF;
  END IF;
  END contract_validate;
  PROCEDURE periods_of_service_validate
  (p_period_of_service_id           IN      number
  ,p_pds_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pds_information1               IN      varchar2  default hr_api.g_varchar2
  ) is
  l_hijrah_date   varchar2(10);
  l_valid_date    varchar2(10);
  BEGIN
    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN
    IF p_pds_information_category = 'SA' THEN
      l_hijrah_date := p_pds_information1;
      hr_sa_hijrah_functions.validate_date(l_hijrah_date,l_valid_date);
    END IF;
  END IF;
  END periods_of_service_validate;

  PROCEDURE person_eit_validate
  (p_pei_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information1               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information2               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information3               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information4               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information5               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information6               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information7               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information8               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information9               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information10              IN      varchar2  default hr_api.g_varchar2
  ) is
  l_valid_date1    varchar2(10);
  l_valid_date2    varchar2(10);
  BEGIN
    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN
    IF p_pei_information_category = 'SA_IQAMA' and p_pei_information3 is not null THEN
      hr_sa_hijrah_functions.validate_date(p_pei_information3,l_valid_date1);
    END IF;
    IF p_pei_information_category = 'SA_IQAMA' and p_pei_information4 is not null THEN
      hr_sa_hijrah_functions.validate_date(p_pei_information4,l_valid_date2);
    END IF;
  END IF;
  END person_eit_validate;



  PROCEDURE create_person_eit_validate
  (p_person_id			    IN 	    number
  ,p_pei_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information1               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information2               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information3               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information4               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information5               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information6               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information7               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information8               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information9               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information10              IN      varchar2  default hr_api.g_varchar2
  ) is
  l_valid_date1    varchar2(10);
  l_valid_date2    varchar2(10);
  l_nationality		varchar2(30);
	CURSOR csr_get_nationality (l_person_id number) IS
	Select nationality
	From per_all_people_f ppf , fnd_sessions fnd
	Where ppf.person_id = l_person_id
	and    fnd.session_id = userenv('sessionid')
	And fnd.effective_date between ppf.effective_start_date and ppf.effective_end_date;
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    IF p_pei_information_category = 'SA_IQAMA' and p_pei_information3 is not null THEN
      hr_sa_hijrah_functions.validate_date(p_pei_information3,l_valid_date1);
    END IF;
    IF p_pei_information_category = 'SA_IQAMA' and p_pei_information4 is not null THEN
      hr_sa_hijrah_functions.validate_date(p_pei_information4,l_valid_date2);
    END IF;
    IF p_pei_information_category = 'SA_HAFIZA' and p_pei_information1 is not null THEN
	OPEN  csr_get_nationality(p_person_id);
	FETCH csr_get_nationality into l_nationality;
	CLOSE csr_get_nationality ;
	if upper(l_nationality) <> FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') THEN
      		hr_utility.set_message(800, 'HR_374813_SA_INVALID_HAFIZA');
          	hr_utility.raise_error;
	end if;
    END IF;
  END IF;
  END create_person_eit_validate;


  PROCEDURE update_person_eit_validate
  (p_person_extra_info_id	    IN 	    number
  ,p_pei_information_category       IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information1               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information2               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information3               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information4               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information5               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information6               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information7               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information8               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information9               IN      varchar2  default hr_api.g_varchar2
  ,p_pei_information10              IN      varchar2  default hr_api.g_varchar2
  ) is
  l_valid_date1    varchar2(10);
  l_valid_date2    varchar2(10);
  l_nationality		varchar2(30);
  l_person_id		number;
	CURSOR csr_get_pid (l_person_extra_info_id number) IS
	Select person_id
	From per_people_extra_info
	Where person_extra_info_id = l_person_extra_info_id;
	CURSOR csr_get_nationality (l_person_id number) IS
	Select nationality
	From per_all_people_f ppf , fnd_sessions fnd
	Where ppf.person_id = l_person_id
	and    fnd.session_id = userenv('sessionid')
	And fnd.effective_date between ppf.effective_start_date and ppf.effective_end_date;
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

    IF p_pei_information_category = 'SA_IQAMA' and p_pei_information3 is not null THEN
      hr_sa_hijrah_functions.validate_date(p_pei_information3,l_valid_date1);
    END IF;
    IF p_pei_information_category = 'SA_IQAMA' and p_pei_information4 is not null THEN
      hr_sa_hijrah_functions.validate_date(p_pei_information4,l_valid_date2);
    END IF;
    IF p_pei_information_category = 'SA_HAFIZA' and p_pei_information1 is not null THEN
	OPEN csr_get_pid(p_person_extra_info_id);
	FETCH csr_get_pid into l_person_id;
	CLOSE csr_get_pid;
	OPEN  csr_get_nationality(l_person_id);
	FETCH csr_get_nationality into l_nationality;
	CLOSE csr_get_nationality ;
	if upper(l_nationality) <> FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') THEN
      		hr_utility.set_message(800, 'HR_374813_SA_HAFIZA_INVALID');
          	hr_utility.raise_error;
	end if;
    END IF;
  END IF;
  END update_person_eit_validate;

   PROCEDURE assignment_annuities_validate
	(p_segment3		IN		VARCHAR2
	,p_effective_date	IN		DATE
	,p_assignment_id	IN		NUMBER	) IS
	l_nationality varchar2(40);
	l_annuities varchar2(40);
	l_person_id number;
	CURSOR csr_nationality IS
		SELECT NATIONALITY
		FROM   per_all_people_f
		WHERE  person_id = l_person_id
	AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'SA') THEN

	SELECT person_id
	INTO l_person_id
	FROM per_all_assignments_f
	WHERE assignment_id = p_assignment_id
	AND p_effective_date BETWEEN effective_start_date AND effective_end_date;
	open csr_nationality;
	fetch csr_nationality into l_nationality;
	close csr_nationality;
	IF p_segment3 = 'Y' and UPPER(l_nationality) <> FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY') THEN
		hr_utility.set_message(800, 'HR_374811_SA_INVALID_ANNUITIES');
          	hr_utility.raise_error;
	END IF;
  END IF;
  END assignment_annuities_validate;
END hr_sa_validate_pkg;

/
