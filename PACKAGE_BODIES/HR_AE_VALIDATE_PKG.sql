--------------------------------------------------------
--  DDL for Package Body HR_AE_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AE_VALIDATE_PKG" AS
/* $Header: peaevald.pkb 120.9 2006/12/22 09:40:36 spendhar noship $ */
  g_type          VARCHAR2(1) := NULL;
  g_per_type      VARCHAR2(1) := NULL;
  PROCEDURE VALIDATE
  (p_date                           in      date
  ,p_person_type_id                 in      number
  ,p_sex                            in      varchar2
  ,p_first_name                     in      varchar2 default null
  ,p_last_name                      in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
  ) IS
    v_field         varchar2(300);
    v_len_field     varchar2(300);
    l_valid_date    varchar2(10);
    CURSOR c_type IS
    SELECT 'Y'
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
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN
    v_field := NULL;
    v_len_field := NULL;
    g_type := NULL;
    g_per_type := NULL;
    IF p_per_information_category = 'AE' THEN

      --Validate length of name fields
      IF length(p_first_name) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','FIRST_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','FIRST_M');
        END IF;
      END IF;
      IF length(p_last_name) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','LAST_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','LAST_M');
        END IF;
      END IF;
      IF length(p_per_information1) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','FATHER_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','FATHER_M');
        END IF;
      END IF;
      IF length(p_per_information2) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','GRANDFATHER_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','GRANDFATHER_M');
        END IF;
      END IF;
      IF length(p_per_information3) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','MOTHER_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','MOTHER_M');
        END IF;
      END IF;
      IF length(p_per_information4) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','ALT_FIRST_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','ALT_FIRST_M');
        END IF;
      END IF;
      IF length(p_per_information5) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','ALT_FATHER_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','ALT_FATHER_M');
        END IF;
      END IF;
      IF length(p_per_information6) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','ALT_GRANDFATHER_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','ALT_GRANDFATHER_M');
        END IF;
      END IF;
      IF length(p_per_information7) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','ALT_LAST_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','ALT_LAST_M');
        END IF;
      END IF;
      IF length(p_per_information8) > 60 THEN
        IF v_len_field IS NULL THEN
          v_len_field := hr_general.decode_lookup('AE_FORM_LABELS','ALT_MOTHER_M');
        ELSE
          v_len_field := v_len_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','ALT_MOTHER_M');
        END IF;
      END IF;
      IF v_len_field IS NOT NULL THEN
        fnd_message.set_name('PER', 'HR_377418_AE_INVALID_LENGTH');
        fnd_message.set_token('FIELD',v_len_field, translate => true );
        hr_utility.raise_error;
      END IF;

      --Validate not null fields
      IF g_per_type = 'Y' THEN
        IF p_first_name IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('AE_FORM_LABELS','FIRST_NAME');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','FIRST_NAME');
          END IF;
        END IF;
      END IF;
    OPEN c_per_type;
    FETCH c_per_type INTO g_per_type;
    CLOSE c_per_type;

    /*IF g_per_type IS NOT NULL THEN

        IF p_national_identifier IS NULL THEN
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('AE_FORM_LABELS','CIVIL_IDENTIFIER');
          ELSE
            v_field := v_field||hr_general.decode_lookup('AE_FORM_LABELS','CIVIL_IDENTIFIER');
          END IF;
        END IF;
    END IF;*/

      OPEN c_type;
      FETCH c_type INTO g_type;
      CLOSE c_type;
      --IF g_type IS NOT NULL THEN
        IF g_per_type = 'Y' THEN
        --IF p_nationality IS NULL THEN
          IF p_per_information18 IS NULL THEN
            IF v_field IS NULL THEN
              v_field := hr_general.decode_lookup('AE_FORM_LABELS','NATIONALITY');
            ELSE
              v_field := v_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','NATIONALITY');
            END IF;
          END IF;
        END IF;
      --END IF;
      IF v_field IS NOT NULL THEN
        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
      END IF;

      DECLARE
        CURSOR csr_get_loc_nat IS
        SELECT org_information1
        FROM   hr_organization_information hoi,
               per_person_types pty
        WHERE  pty.person_type_id = p_person_type_id
        AND    pty.business_group_id = hoi.organization_id
        AND    hoi.org_information_context = 'AE_BG_DETAILS';
        rec_get_loc_nat        csr_get_loc_nat%ROWTYPE;
        l_local_nationality    VARCHAR2(80);
      BEGIN
        l_local_nationality := NULL;
        OPEN csr_get_loc_nat;
        FETCH csr_get_loc_nat INTO rec_get_loc_nat;
        l_local_nationality := rec_get_loc_nat.org_information1;
        CLOSE csr_get_loc_nat;
        --IF p_nationality <> NVL(l_local_nationality,'*') AND p_per_information9 IS NOT NULL THEN
        IF p_per_information18 <> NVL(l_local_nationality,'*') AND (p_per_information9 IS NOT NULL AND p_per_information9 <> hr_api.g_varchar2) THEN
          IF (p_per_information16 IS NOT NULL AND p_per_information16 <> hr_api.g_varchar2) OR (p_per_information17 IS NOT NULL AND p_per_information17 <> hr_api.g_varchar2) THEN
            hr_utility.set_message(800, 'HR_377410_AE_DAT_REA_INVALID');
            hr_utility.raise_error;
          END IF;
        END IF;
      END;

      DECLARE
        l_count  NUMBER;

	CURSOR csr_fetch_bg_id IS
	SELECT distinct pty.business_group_id
	FROM per_person_types pty,
	     hr_organization_information hoi
	WHERE pty.person_type_id = p_person_type_id
	AND   pty.business_group_id = hoi.organization_id;

        CURSOR csr_val_mar_status (l_bg_id NUMBER) IS
        SELECT 'Y'
        FROM   pay_user_column_instances_f i
               ,pay_user_rows_f r
               ,pay_user_columns c
               ,pay_user_tables t
        WHERE  ((i.legislation_code = 'AE' AND i.business_group_id IS NULL)
	 	OR (i.business_group_id = l_bg_id AND i.legislation_code IS NULL))
        AND    ((r.legislation_code = 'AE' AND r.business_group_id IS NULL)
                OR (r.business_group_id = l_bg_id AND r.legislation_code IS NULL))
        AND    c.legislation_code = 'AE'
        AND    t.legislation_code = 'AE'
        AND    UPPER(t.user_table_name) = UPPER('AE_MARITAL_STATUS')
        AND    t.user_table_id = r.user_table_id
        AND    t.user_table_id = c.user_table_id
        AND    r.row_low_range_or_name = p_marital_status
        AND    r.user_row_id = i.user_row_id
        AND    UPPER(c.user_column_name) = UPPER('MARITAL STATUS')
        AND    c.user_column_id = i.user_column_id
        --AND    i.value = p_value
        AND    p_date BETWEEN r.effective_start_date AND r.effective_end_date
        AND    p_date BETWEEN i.effective_start_date AND i.effective_end_date;
        l_valid  VARCHAR2(10);
	l_bg_id  NUMBER;
      BEGIN
        l_valid := NULL;

	OPEN csr_fetch_bg_id;
	FETCH csr_fetch_bg_id INTO l_bg_id;
	CLOSE csr_fetch_bg_id;

        IF p_marital_status IS NOT NULL AND p_marital_status <> hr_api.g_varchar2 THEN
          OPEN csr_val_mar_status(l_bg_id);
          FETCH csr_val_mar_status INTO l_valid;
          CLOSE csr_val_mar_status;
          IF l_valid  IS NULL THEN
            hr_utility.set_message(800, 'HR_377405_AE_INVALID_MAR');
            hr_utility.raise_error;
          END IF;
        END IF;
      END;

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
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
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
    ,p_date                       =>  p_effective_date
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_last_name                  =>  p_last_name
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_marital_status             =>  p_marital_status
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
    ,p_per_information10          =>  p_per_information10
    ,p_per_information11          =>  p_per_information11
    ,p_per_information12          =>  p_per_information12
    ,p_per_information13          =>  p_per_information13
    ,p_per_information14          =>  p_per_information14
    ,p_per_information15          =>  p_per_information15
    ,p_per_information16          =>  p_per_information16
    ,p_per_information17          =>  p_per_information17
    ,p_per_information18          =>  p_per_information18
    ,p_per_information19          =>  p_per_information19
    ,p_per_information20          =>  p_per_information20);
    END IF;
    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN
    if g_type IS NOT NULL THEN
     if p_per_information_category = 'AE' and (p_per_information10 is not null AND p_per_information10 <> hr_api.g_varchar2) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'AE_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'AE_RELIGION'
        ,p_lookup_code           => p_per_information10
        )
      then
        --
        hr_utility.set_message(800, 'HR_377401_AE_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;

     if p_per_information_category = 'AE' and (p_per_information9 is not null AND p_per_information9 <> hr_api.g_varchar2) then
      --
      -- Check that the nationality exists in hr_lookups for the
      -- lookup type 'AE_NATIONALITY' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'AE_NATIONALITY'
        ,p_lookup_code           => p_per_information9
        )
      then
        --
        hr_utility.set_message(800, 'HR_377402_AE_INVALID_PREV_NAT');
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
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
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
    ,p_date                       =>  p_date_received
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_last_name                  =>  p_last_name
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_marital_status             =>  p_marital_status
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
    ,p_per_information10          =>  p_per_information10
    ,p_per_information11          =>  p_per_information11
    ,p_per_information12          =>  p_per_information12
    ,p_per_information13          =>  p_per_information13
    ,p_per_information14          =>  p_per_information14
    ,p_per_information15          =>  p_per_information15
    ,p_per_information16          =>  p_per_information16
    ,p_per_information17          =>  p_per_information17
    ,p_per_information18          =>  p_per_information18
    ,p_per_information19          =>  p_per_information19
    ,p_per_information20          =>  p_per_information20);

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'AE' and (p_per_information10 is not null AND p_per_information10 <> hr_api.g_varchar2) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'AE_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_date_received
        ,p_lookup_type           => 'AE_RELIGION'
        ,p_lookup_code           => p_per_information10
        )
      then
        --
        hr_utility.set_message(800, 'HR_377401_AE_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;

     if p_per_information_category = 'AE' and (p_per_information9 is not null AND p_per_information9 <> hr_api.g_varchar2) then
      --
      -- Check that the nationality exists in hr_lookups for the
      -- lookup type 'AE_NATIONALITY' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_date_received
        ,p_lookup_type           => 'AE_NATIONALITY'
        ,p_lookup_code           => p_per_information9
        )
      then
        --
        hr_utility.set_message(800, 'HR_377402_AE_INVALID_PREV_NAT');
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
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
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
    ,p_date                       =>  p_hire_date
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_last_name                  =>  p_last_name
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_marital_status             =>  p_marital_status
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
    ,p_per_information10          =>  p_per_information10
    ,p_per_information11          =>  p_per_information11
    ,p_per_information12          =>  p_per_information12
    ,p_per_information13          =>  p_per_information13
    ,p_per_information14          =>  p_per_information14
    ,p_per_information15          =>  p_per_information15
    ,p_per_information16          =>  p_per_information16
    ,p_per_information17          =>  p_per_information17
    ,p_per_information18          =>  p_per_information18
    ,p_per_information19          =>  p_per_information19
    ,p_per_information20          =>  p_per_information20);

  /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'AE' and (p_per_information10 is not null AND p_per_information10 <> hr_api.g_varchar2) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'AE_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_hire_date
        ,p_lookup_type           => 'AE_RELIGION'
        ,p_lookup_code           => p_per_information10
        )
      then
        --
        hr_utility.set_message(800, 'HR_377401_AE_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;

     if p_per_information_category = 'AE' and (p_per_information9 is not null AND p_per_information9 <> hr_api.g_varchar2) then
      --
      -- Check that the nationality exists in hr_lookups for the
      -- lookup type 'AE_NATIONALITY' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_hire_date
        ,p_lookup_type           => 'AE_NATIONALITY'
        ,p_lookup_code           => p_per_information9
        )
      then
        --
        hr_utility.set_message(800, 'HR_377402_AE_INVALID_PREV_NAT');
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
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
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
    ,p_date                       =>  p_start_date
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_last_name                  =>  p_last_name
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_marital_status             =>  p_marital_status
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
    ,p_per_information10          =>  p_per_information10
    ,p_per_information11          =>  p_per_information11
    ,p_per_information12          =>  p_per_information12
    ,p_per_information13          =>  p_per_information13
    ,p_per_information14          =>  p_per_information14
    ,p_per_information15          =>  p_per_information15
    ,p_per_information16          =>  p_per_information16
    ,p_per_information17          =>  p_per_information17
    ,p_per_information18          =>  p_per_information18
    ,p_per_information19          =>  p_per_information19
    ,p_per_information20          =>  p_per_information20);

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'AE' and (p_per_information10 is not null AND p_per_information10 <> hr_api.g_varchar2) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'AE_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_start_date
        ,p_lookup_type           => 'AE_RELIGION'
        ,p_lookup_code           => p_per_information10
        )
      then
        --
        hr_utility.set_message(800, 'HR_377401_AE_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;

     if p_per_information_category = 'AE' and (p_per_information9 is not null AND p_per_information9 <> hr_api.g_varchar2) then
      --
      -- Check that the nationality exists in hr_lookups for the
      -- lookup type 'AE_NATIONALITY' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_start_date
        ,p_lookup_type           => 'AE_NATIONALITY'
        ,p_lookup_code           => p_per_information9
        )
      then
        --
        hr_utility.set_message(800, 'HR_377402_AE_INVALID_PREV_NAT');
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
  ,p_last_name                      in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
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
  ,p_per_information11              in      varchar2 default null
  ,p_per_information12              in      varchar2 default null
  ,p_per_information13              in      varchar2 default null
  ,p_per_information14              in      varchar2 default null
  ,p_per_information15              in      varchar2 default null
  ,p_per_information16              in      varchar2 default null
  ,p_per_information17              in      varchar2 default null
  ,p_per_information18              in      varchar2 default null
  ,p_per_information19              in      varchar2 default null
  ,p_per_information20              in      varchar2 default null
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
    ,p_date                       =>  p_start_date
    ,p_sex                        =>  p_sex
    ,p_first_name                 =>  p_first_name
    ,p_last_name                  =>  p_last_name
    ,p_national_identifier        =>  p_national_identifier
    ,p_title                      =>  p_title
    ,p_marital_status             =>  p_marital_status
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
    ,p_per_information10          =>  p_per_information10
    ,p_per_information11          =>  p_per_information11
    ,p_per_information12          =>  p_per_information12
    ,p_per_information13          =>  p_per_information13
    ,p_per_information14          =>  p_per_information14
    ,p_per_information15          =>  p_per_information15
    ,p_per_information16          =>  p_per_information16
    ,p_per_information17          =>  p_per_information17
    ,p_per_information18          =>  p_per_information18
    ,p_per_information19          =>  p_per_information19
    ,p_per_information20          =>  p_per_information20);

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    if g_type IS NOT NULL THEN
     if p_per_information_category = 'AE' and (p_per_information10 is not null AND p_per_information10 <> hr_api.g_varchar2) then
      --
      -- Check that the religion exists in hr_lookups for the
      -- lookup type 'AE_RELIGION' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_start_date
        ,p_lookup_type           => 'AE_RELIGION'
        ,p_lookup_code           => p_per_information10
        )
      then
        --
        hr_utility.set_message(800, 'HR_377401_AE_INVALID_RELIGION');
        hr_utility.raise_error;
        --
      end if;
     end if;

     if p_per_information_category = 'AE' and (p_per_information9 is not null AND p_per_information9 <> hr_api.g_varchar2) then
      --
      -- Check that the nationality exists in hr_lookups for the
      -- lookup type 'AE_NATIONALITY' with an enabled flag set to 'Y' and that
      -- the effective start date of the person is between start date
      -- active and end date active in hr_lookups.
      --
      if hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_start_date
        ,p_lookup_type           => 'AE_NATIONALITY'
        ,p_lookup_code           => p_per_information9
        )
      then
        --
        hr_utility.set_message(800, 'HR_377402_AE_INVALID_PREV_NAT');
        hr_utility.raise_error;
        --
      end if;
    end if;
    end if;
  END IF;
  END CWK_VALIDATE;
  --
  -- Procedure for validating contract
  --
  PROCEDURE contract_validate
    (p_effective_date                 IN      DATE
    ,p_type                           IN      VARCHAR2
    ,p_duration                       IN      NUMBER   DEFAULT NULL
    ,p_duration_units                 IN      VARCHAR2 DEFAULT NULL
    ,p_ctr_information_category       IN      VARCHAR2 DEFAULT NULL
    ,p_ctr_information1               IN      VARCHAR2 DEFAULT NULL
    ,p_ctr_information2               IN      VARCHAR2 DEFAULT NULL
    ,p_ctr_information3               IN      VARCHAR2 DEFAULT NULL
    ,p_ctr_information4               IN      VARCHAR2 DEFAULT NULL
    ,p_ctr_information5               IN      VARCHAR2 DEFAULT NULL) IS
	--
    l_field VARCHAR2(300);
	--
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN
    --
    l_field := NULL;
	--
    IF p_ctr_information_category = '' THEN
	  --
      -- Check that the employment status exists in hr_lookups for the
      -- lookup type 'AE_EMPLOYMENT_STATUS' with an enabled flag set to 'Y'
      --
      IF p_ctr_information1 IS NOT NULL AND p_ctr_information1 <> hr_api.g_varchar2 THEN
	    --
        IF hr_api.not_exists_in_hr_lookups
          (p_effective_date        => p_effective_date
          ,p_lookup_type           => 'AE_EMPLOYMENT_STATUS'
          ,p_lookup_code           => p_ctr_information1) THEN
          --
          hr_utility.set_message(800, 'HR_377414_AE_INVALID_EMP_STAT');
          hr_utility.raise_error;
		  --
        END IF;
		--
      END IF;
      --
      IF p_ctr_information2 IS NOT NULL AND p_ctr_information2 <> hr_api.g_varchar2 THEN
        --
        IF (fnd_date.canonical_to_date(p_ctr_information2) < p_effective_date)
         THEN
          --
          hr_utility.set_message(800, 'HR_377415_AE_EXPIRY_INVALID');
          hr_utility.raise_error;
          --
        END IF;
		--
      END IF;
      --
    END IF;
      --
  END IF;

  END CONTRACT_VALIDATE;
  --

  PROCEDURE validate_address
  (p_effective_date                IN      DATE
   ,p_address_line3                IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2) IS
    CURSOR csr_validate_address
      (p_user_table_name   VARCHAR2
      ,p_row_low_name      VARCHAR2
      ,p_user_column_name  VARCHAR2
      ,p_value             VARCHAR2) IS
    SELECT 'Y'
    FROM   pay_user_column_instances_f i
           ,pay_user_rows_f r
           ,pay_user_columns c
           ,pay_user_tables t
    WHERE  i.legislation_code = 'AE'
    AND    r.legislation_code = 'AE'
    AND    c.legislation_code = 'AE'
    AND    t.legislation_code = 'AE'
    AND    UPPER(t.user_table_name) = UPPER(p_user_table_name)
    AND    t.user_table_id = r.user_table_id
    AND    t.user_table_id = c.user_table_id
    AND    r.row_low_range_or_name = p_row_low_name
    AND    r.user_row_id = i.user_row_id
    AND    UPPER(c.user_column_name) = UPPER(p_user_column_name)
    AND    c.user_column_id = i.user_column_id
    AND    i.value = p_value
    AND    p_effective_date BETWEEN r.effective_start_date AND r.effective_end_date
    AND    p_effective_date BETWEEN i.effective_start_date AND i.effective_end_date;
    l_valid VARCHAR2(1);
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    l_valid := NULL;
    IF (p_town_or_city IS NOT NULL AND p_town_or_city <> hr_api.g_varchar2) AND (p_address_line3 IS NOT NULL AND p_address_line3 <> hr_api.g_varchar2)THEN
      OPEN csr_validate_address
        ('AE_CITY_VALIDATION',p_town_or_city,'EMIRATE CODE',p_address_line3);
      FETCH csr_validate_address INTO l_valid;
      CLOSE csr_validate_address;

      IF l_valid IS NULL THEN
        hr_utility.set_message(800, 'HR_377403_AE_INVALID_CITY');
        hr_utility.raise_error;
      END IF;
    END IF;
    l_valid := NULL;
    IF (p_region_1 IS NOT NULL AND p_region_1 <> hr_api.g_varchar2) THEN --AND p_town_or_city IS NOT NULL THEN
      OPEN csr_validate_address
        ('AE_AREA_VALIDATION',p_region_1,'CITY CODE',p_town_or_city);
      FETCH csr_validate_address INTO l_valid;
      CLOSE csr_validate_address;
      IF l_valid IS NULL THEN
        hr_utility.set_message(800, 'HR_377404_AE_INVALID_AREA');
        hr_utility.raise_error;
      END IF;
    END IF;
  END IF;
  END validate_address;


  PROCEDURE create_address_validate
  (p_style                         IN      VARCHAR2
   ,p_effective_date                IN      DATE
   ,p_address_line3                IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2) IS

  BEGIN
    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    IF p_style = 'AE' THEN
      validate_address
      (p_effective_date    => p_effective_date
      ,p_address_line3     => p_address_line3
      ,p_town_or_city      => p_town_or_city
      ,p_region_1          => p_region_1);
    END IF;
  END IF;

  END create_address_validate;

  PROCEDURE update_address_validate
  (p_address_id                    IN      NUMBER
   ,p_effective_date               IN      DATE
   ,p_address_line3                IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2) IS

    CURSOR csr_get_style(l_address_id number) is
    SELECT style,person_id
    FROM   per_addresses
    WHERE  address_id = l_address_id;
    l_style     per_addresses.style%TYPE;
    l_person_id    per_addresses.person_id%TYPE;
    --
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN
    --
    OPEN csr_get_style(p_address_id);
    FETCH csr_get_style INTO l_style,l_person_id;
    CLOSE csr_get_style;
    IF l_style = 'AE' THEN
      validate_address
      (p_effective_date    => p_effective_date
      ,p_address_line3     => p_address_line3
      ,p_town_or_city      => p_town_or_city
      ,p_region_1          => p_region_1);

    END IF;

  END IF;

  END update_address_validate;

  PROCEDURE create_location_validate
  (p_style                         IN      VARCHAR2
   ,p_effective_date               IN      DATE
   ,p_address_line_3               IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2) IS

  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN
    IF p_style = 'AE' THEN
      validate_address
      (p_effective_date    => p_effective_date
      ,p_address_line3     => p_address_line_3
      ,p_town_or_city      => p_town_or_city
      ,p_region_1          => p_region_1);
    END IF;
  END IF;
  END create_location_validate;

  PROCEDURE update_location_validate
  (p_style                         IN      VARCHAR2
   ,p_effective_date               IN      DATE
   ,p_address_line_3               IN      VARCHAR2
   ,p_town_or_city                 IN      VARCHAR2
   ,p_region_1                     IN      VARCHAR2) IS
    --
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN
    --
    IF p_style = 'AE' THEN
      validate_address
      (p_effective_date    => p_effective_date
      ,p_address_line3     => p_address_line_3
      ,p_town_or_city      => p_town_or_city
      ,p_region_1          => p_region_1);

    END IF;

  END IF;
  END update_location_validate;

  PROCEDURE update_asg_validate
    (p_effective_date	           IN      DATE
     ,p_assignment_id	           IN      NUMBER
     ,p_segment1                   IN      VARCHAR2
     ,p_segment2                   IN      VARCHAR2
     ,p_segment3                   IN      VARCHAR2
     ,p_segment4                   IN      VARCHAR2
     ,p_segment5                   IN      VARCHAR2) IS

  BEGIN

   /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    IF (p_segment2 IS NOT NULL AND p_segment2 <> hr_api.g_varchar2) AND p_segment3 IS NULL THEN
      hr_utility.set_message(800, 'HR_377409_AE_SOC_SEC_REQ');
      hr_utility.raise_error;
    END IF;

    IF p_segment5 IS NOT NULL AND p_segment5 <> hr_api.g_varchar2 THEN
      DECLARE
        CURSOR csr_chk_qual IS
        SELECT qual.person_id
        FROM   per_qualifications qual,
               per_all_assignments_f asg
        WHERE  qual.person_id = asg.person_id
        AND    qual.qualification_id = p_segment5
        AND    asg.assignment_id = p_assignment_id;
        rec_chk_qual  csr_chk_qual%ROWTYPE;
        l_exist       NUMBER;
      BEGIN
        l_exist := NULL;
        OPEN csr_chk_qual;
        FETCH csr_chk_qual INTO rec_chk_qual;
        l_exist := rec_chk_qual.person_id;
        CLOSE csr_chk_qual;
        IF l_exist IS NULL THEN
          hr_utility.set_message(800, 'HR_377408_AE_INVALID_QUAL');
          hr_utility.raise_error;
        END IF;
      END;
    END IF;
  END IF;
  END update_asg_validate ;

  PROCEDURE CREATE_DISABILITY_VALIDATE
    (p_effective_date              IN     DATE
    ,p_person_id                   IN     NUMBER
    ,p_category                    IN     VARCHAR2
    ,p_degree                      IN     NUMBER   DEFAULT NULL
    ,p_dis_information_category    IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information1            IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information2            IN     VARCHAR2 DEFAULT NULL) AS
    l_count       NUMBER;
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    l_count := 0;
    IF p_dis_information_category = 'AE' and NVL(p_dis_information1,'N') = 'Y' THEN
      /*Check that Relevant to Social Security is not set to Yes for more than 1 disability in the same period*/
      SELECT COUNT(*)
      INTO   l_count
      FROM   per_disabilities_f
      WHERE  person_id = p_person_id
      AND    p_effective_date BETWEEN effective_start_date AND effective_end_date
      AND    dis_information_category = 'AE'
      AND    dis_information1 = 'Y';
      IF l_count > 0 THEN
        fnd_message.set_name('PER', 'HR_377411_AE_INVALID_DIS_SSN');
        hr_utility.raise_error;
      END IF;
    END IF;
  END IF;
  END CREATE_DISABILITY_VALIDATE;

  PROCEDURE UPDATE_DISABILITY_VALIDATE
    (p_effective_date              IN     DATE
    ,p_disability_id               IN     NUMBER
    ,p_category                    IN     VARCHAR2
    ,p_degree                      IN     NUMBER   DEFAULT NULL
    ,p_dis_information_category    IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information1            IN     VARCHAR2 DEFAULT NULL
    ,p_dis_information2            IN     VARCHAR2 DEFAULT NULL) AS
    l_person_id   NUMBER;
    l_count       NUMBER;
  BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    l_count := 0;
    SELECT person_id
    INTO   l_person_id
    FROM   per_disabilities_f
    WHERE  disability_id = p_disability_id
    AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
    IF p_dis_information_category = 'AE' and NVL(p_dis_information1,'N') = 'Y' THEN
      /*Check that Relevant to Social Security is not set to Yes for more than 1 disability in the same period*/
      SELECT COUNT(*)
      INTO   l_count
      FROM   per_disabilities_f
      WHERE  person_id = l_person_id
      AND    disability_id <> p_disability_id
      AND    p_effective_date BETWEEN effective_start_date AND effective_end_date
      AND    dis_information_category = 'AE'
      AND    dis_information1 = 'Y';
      IF l_count > 0 THEN
        fnd_message.set_name('PER', 'HR_377411_AE_INVALID_DIS_SSN');
        hr_utility.raise_error;
      END IF;
    END IF;
  END IF;
  END UPDATE_DISABILITY_VALIDATE;


-- Procedure added for Personal payment method check

  PROCEDURE CREATE_PAYMENT_METHOD_VALIDATE
    (P_EFFECTIVE_DATE		   IN     DATE
    ,P_ASSIGNMENT_ID               IN     NUMBER
    ,P_ORG_PAYMENT_METHOD_ID	   IN     NUMBER
    ,P_PPM_INFORMATION1            IN     VARCHAR2 DEFAULT NULL) IS

    l_count		number;

  BEGIN
  	  /* Added for GSI Bug 5472781 */
  	IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

  		l_count := 0;

  		IF NVL(P_PPM_INFORMATION1,'N') = 'Y' THEN

  			/* Check if more than one personal payment method does not have "EOS" flag as Yes */

  			SELECT	count(*)
  			INTO	l_count
  			FROM	PAY_PERSONAL_PAYMENT_METHODS_F
  			WHERE	ASSIGNMENT_ID = P_ASSIGNMENT_ID
/*  			AND	ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID */
  			AND     P_EFFECTIVE_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
  			AND     PPM_INFORMATION_CATEGORY = 'AE_AE DIRECT DEPOSIT AED'
  			AND	PPM_INFORMATION1 = 'Y';

  			IF l_count >= 1 THEN
			        fnd_message.set_name('PER', 'HR_377444_AE_INVALID_EOS_FLAG');
			        hr_utility.raise_error;
			END IF;

  		END IF;

  	END IF;

  END CREATE_PAYMENT_METHOD_VALIDATE;

  PROCEDURE UPDATE_PAYMENT_METHOD_VALIDATE
    (P_EFFECTIVE_DATE              IN     DATE
    ,P_PERSONAL_PAYMENT_METHOD_ID  IN     NUMBER
    ,P_PPM_INFORMATION1            IN     VARCHAR2) IS

    l_count		number;
    l_assignment_id	number;

  BEGIN
  	  /* Added for GSI Bug 5472781 */
  	IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

  		l_count := 0;

  		SELECT	ASSIGNMENT_ID
  		INTO	l_assignment_id
  		FROM	PAY_PERSONAL_PAYMENT_METHODS_F
  		WHERE	PERSONAL_PAYMENT_METHOD_ID = P_PERSONAL_PAYMENT_METHOD_ID
  		AND	P_EFFECTIVE_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

  		IF NVL(P_PPM_INFORMATION1,'N') = 'Y' THEN
  		/* Check if more than one personal payment method does not have "EOS" flag as Yes */

  			SELECT	COUNT(*)
  			INTO    l_count
  			FROM	PAY_PERSONAL_PAYMENT_METHODS_F
  			WHERE	ASSIGNMENT_ID = l_assignment_id
  			AND	PERSONAL_PAYMENT_METHOD_ID <> P_PERSONAL_PAYMENT_METHOD_ID
  			AND	P_EFFECTIVE_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
  			AND	PPM_INFORMATION_CATEGORY = 'AE_AE DIRECT DEPOSIT AED'
  			AND	PPM_INFORMATION1 = 'Y';

		        IF l_count > 0 THEN
				fnd_message.set_name('PER', 'HR_377444_AE_INVALID_EOS_FLAG');
				hr_utility.raise_error;
		        END IF;

  		END IF;


  	END IF;

  END UPDATE_PAYMENT_METHOD_VALIDATE;

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
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    v_field := NULL;
    IF p_pem_information_category = 'AE' then
     IF p_employer_name is null then
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('AE_FORM_LABELS','PREVIOUS_EMPLOYER');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','PREVIOUS_EMPLOYER');
          END IF;

        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
     END IF;

     IF (p_pem_information1 IS NOT NULL AND p_pem_information1 <> hr_api.g_varchar2) THEN
     IF hr_api.not_exists_in_hr_lookups
        (p_effective_date        => p_effective_date
        ,p_lookup_type           => 'LEAV_REAS'
        ,p_lookup_code           => p_pem_information1
        )
     THEN
     hr_utility.set_message(800, 'HR_377417_AE_INVALID_LEAV_REAS');
     hr_utility.raise_error;
     END IF;
     END IF;
     END IF;
  END IF;
  END PREVIOUS_EMPLOYER_VALIDATE;

--
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

v_field                       VARCHAR2(300);

l_length  NUMBER;

BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    v_field := NULL;
    l_length := 0;

    IF p_org_info_type_code = 'AE_LEGAL_EMPLOYER_DETAILS' THEN

     IF p_org_information1 is null then
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('AE_FORM_LABELS','SOCIAL_SEC_NUMBER');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','SOCIAL_SEC_NUMBER');
          END IF;

        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
     END IF;

    IF (p_org_information1 IS NOT NULL AND p_org_information1 <> hr_api.g_varchar2) THEN

         l_length := LENGTH(p_org_information1);

         IF(l_length > 12) THEN
            fnd_message.set_name('PER', 'HR_377407_AE_INVALID_SOC_SEC');
            hr_utility.raise_error;
         END IF;
    END IF;

    END IF;

  END IF;

END VALIDATE_CREATE_ORG_INF;
--
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
l_length  NUMBER;
l_var1 NUMBER;
v_field                       VARCHAR2(300);

BEGIN

    /* Added for GSI Bug 5472781 */
  IF hr_utility.chk_product_install('Oracle Human Resources', 'AE') THEN

    l_length := 0;
    l_var1 := 0;
    v_field := NULL;

    IF p_org_info_type_code = 'AE_LEGAL_EMPLOYER_DETAILS' THEN

     IF p_org_information1 is null then
          IF v_field IS NULL THEN
            v_field := hr_general.decode_lookup('AE_FORM_LABELS','SOCIAL_SEC_NUMBER');
          ELSE
            v_field := v_field||', '||hr_general.decode_lookup('AE_FORM_LABELS','SOCIAL_SEC_NUMBER');
          END IF;

        fnd_message.set_name('PER', 'PQH_FR_MANDATORY_MSG');
        fnd_message.set_token('NAME',v_field, translate => true );
        hr_utility.raise_error;
     END IF;

    IF (p_org_information1 IS NOT NULL AND p_org_information1 <> hr_api.g_varchar2)  THEN

         l_length := LENGTH(p_org_information1);

         IF(l_length > 12) THEN
            fnd_message.set_name('PER', 'HR_377407_AE_INVALID_SOC_SEC');
            hr_utility.raise_error;
         END IF;
    END IF;

   END IF;

  END IF;


END VALIDATE_UPDATE_ORG_INF;
--



END HR_AE_VALIDATE_PKG;

/
