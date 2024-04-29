--------------------------------------------------------
--  DDL for Package Body PER_ES_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_ABSENCE" AS
/* $Header: peesabsp.pkb 120.1.12000000.3 2007/06/21 15:23:26 rbaker ship $ */
--
-------------------------------------------------------------------------------
-- PERSON_ENTRY_CREATE
-------------------------------------------------------------------------------
PROCEDURE person_entry_create(p_business_group_id            IN NUMBER
                             ,p_absence_attendance_id        IN NUMBER
                             ,p_date_start                   IN DATE
                             ,p_date_end                     IN DATE
                             ,p_abs_information_category     IN VARCHAR2
                             ,p_abs_information1             IN VARCHAR2
                             ,p_abs_information2             IN VARCHAR2
                             ,p_abs_information3             IN VARCHAR2
                             ,p_abs_information4             IN VARCHAR2
                             ,p_abs_information5             IN VARCHAR2
                             ,p_abs_information6             IN VARCHAR2
                             ,p_abs_information7             IN VARCHAR2
                             ,p_abs_information8             IN VARCHAR2
                             ,p_abs_information9             IN VARCHAR2
                             ,p_abs_information10            IN VARCHAR2) IS
    --
    CURSOR csr_get_input_value_info(p_element_entry_id NUMBER
                                   ,p_input_value_name VARCHAR2
                                   ,p_date             DATE) IS
    SELECT pivf.input_value_id  iv_start_date_id
    FROM   pay_input_values_f    pivf
          ,pay_element_entries_f peef
          ,pay_element_types_f   petf
    WHERE  peef.element_entry_id  = p_element_entry_id
    AND    peef.element_type_id   = petf.element_type_id
    AND    pivf.element_type_id   = petf.element_type_id
    AND    pivf.name              = p_input_value_name
    AND    p_date                  BETWEEN peef.effective_start_date
                                   AND     peef.effective_end_date
    AND    p_date                  BETWEEN petf.effective_start_date
                                   AND     petf.effective_end_date
    AND    p_date                  BETWEEN pivf.effective_start_date
                                   AND     pivf.effective_end_date;
    --
    l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
    l_start_date_iv_id      pay_input_values_f.input_value_id%TYPE;
    l_end_date_iv_id        pay_input_values_f.input_value_id%TYPE;
    l_absence_id            pay_input_values_f.input_value_id%TYPE;
    l_ptm_percentage_iv_id  pay_input_values_f.input_value_id%TYPE;
    l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
    l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
    l_ovn                   pay_element_entries_f.object_version_number%TYPE;
    l_o_start_dt            pay_element_entries_f.effective_start_date%TYPE;
    l_o_end_dt              pay_element_entries_f.effective_end_date%TYPE;
    l_o_warning             BOOLEAN;
    --

BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    hr_utility.set_location('Entering hook Person_entry_Create',10);
    --
    IF  p_date_start IS NOT NULL THEN
        --
        IF  p_abs_information_category IN ('ES_TD','ES_M','ES_IE_AL','ES_PAR','ES_PTM') THEN
            --

            hr_utility.set_location(' IN Create User hook ',20);
            --
            hr_person_absence_api.get_absence_element
                 (p_absence_attendance_id   => p_absence_attendance_id
                 ,p_element_entry_id        => l_element_entry_id
                 ,p_effective_start_date    => l_effective_start_date
                 ,p_effective_end_date      => l_effective_end_date);
            --
            IF  l_element_entry_id IS NOT NULL THEN
                --
                hr_utility.set_location(' Updating dates for entry_id='||l_element_entry_id,30);
                hr_utility.set_location('-- Date='|| to_char(l_effective_end_date,'dd-mm-yyyy'),35);
                IF  p_date_end = to_date('31-12-4712','DD-MM-YYYY') OR
                    p_date_end IS NULL THEN
                    l_effective_end_date := NULL;
                END IF;
                --
                hr_utility.set_location('-- Date='|| to_char(l_effective_end_date,'dd-mm-yyyy'),35);

                OPEN csr_get_input_value_info(l_element_entry_id
                                             ,'Start Date'
                                             ,l_effective_start_date);
                FETCH csr_get_input_value_info INTO l_start_date_iv_id;
                CLOSE csr_get_input_value_info;
                --
                OPEN csr_get_input_value_info(l_element_entry_id
                                             ,'End Date'
                                             ,l_effective_start_date);
                FETCH csr_get_input_value_info INTO l_end_date_iv_id;
                CLOSE csr_get_input_value_info;
                --
                OPEN csr_get_input_value_info(l_element_entry_id
                                             ,'Absence ID'
                                            ,l_effective_start_date);
                FETCH csr_get_input_value_info INTO l_absence_id;
                CLOSE csr_get_input_value_info;
                --
                IF  p_abs_information_category = 'ES_PTM' THEN
                    OPEN csr_get_input_value_info(l_element_entry_id
                                                 ,'Part Time Percentage'
                                                 ,l_effective_start_date);
                    FETCH csr_get_input_value_info INTO l_ptm_percentage_iv_id;
                    CLOSE csr_get_input_value_info;
                END IF;
                --
                SELECT max(object_version_number) INTO l_ovn
                FROM   pay_element_entries_f
                WHERE  element_entry_id = l_element_entry_id;
                --
                hr_utility.set_location('~~ Before updating ',30);
                hr_utility.set_location('~~ Absence Att ID ' || to_char(p_absence_attendance_id),10);
                IF  p_abs_information_category = 'ES_PTM' THEN
                    --
                    pay_element_entry_api.update_element_entry
                         (p_validate                => FALSE
                         ,p_datetrack_update_mode   => 'CORRECTION'
                         ,p_effective_date          => l_effective_start_date
                         ,p_business_group_id       => p_business_group_id
                         ,p_element_entry_id        => l_element_entry_id
                         ,p_object_version_number   => l_ovn
                         ,p_input_value_id1         => l_start_date_iv_id
                         ,p_entry_value1            => fnd_date.date_to_displaydate(l_effective_start_date) --l_effective_start_date
                         ,p_input_value_id2         => l_end_date_iv_id
                         ,p_entry_value2            => fnd_date.date_to_displaydate(l_effective_end_date) --l_effective_end_date
                         ,p_input_value_id3         => l_absence_id
                         ,p_entry_value3            => p_absence_attendance_id
                         ,p_input_value_id4         => l_ptm_percentage_iv_id
                         ,p_entry_value4            => p_abs_information3
                         ,p_effective_start_date    => l_o_start_dt
                         ,p_effective_end_date      => l_o_end_dt
                         ,p_update_warning          => l_o_warning);

                ELSE
                    pay_element_entry_api.update_element_entry
                         (p_validate                => FALSE
                         ,p_datetrack_update_mode   => 'CORRECTION'
                         ,p_effective_date          => l_effective_start_date
                         ,p_business_group_id       => p_business_group_id
                         ,p_element_entry_id        => l_element_entry_id
                         ,p_object_version_number   => l_ovn
                         ,p_input_value_id1         => l_start_date_iv_id
                         ,p_entry_value1            => fnd_date.date_to_displaydate(l_effective_start_date) --l_effective_start_date
                         ,p_input_value_id2         => l_end_date_iv_id
                         ,p_entry_value2            => fnd_date.date_to_displaydate(l_effective_end_date) --l_effective_end_date
                         ,p_input_value_id3         => l_absence_id
                         ,p_entry_value3            => p_absence_attendance_id
                         ,p_effective_start_date    => l_o_start_dt
                         ,p_effective_end_date      => l_o_end_dt
                         ,p_update_warning          => l_o_warning);
                END IF;
                      hr_utility.set_location('~~ After updating ',30);
            END IF;
        END IF;
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving hook Person_entry_Create',90);
  --
END person_entry_create;
--
-------------------------------------------------------------------------------
-- PERSON_ENTRY_UPDATE
-------------------------------------------------------------------------------
PROCEDURE person_entry_update(p_absence_attendance_id        IN NUMBER
                             ,p_date_start                   IN DATE
                             ,p_date_end                     IN DATE
                             ,p_abs_information_category     IN VARCHAR2
                             ,p_abs_information1             IN VARCHAR2
                             ,p_abs_information2             IN VARCHAR2
                             ,p_abs_information3             IN VARCHAR2
                             ,p_abs_information4             IN VARCHAR2
                             ,p_abs_information5             IN VARCHAR2
                             ,p_abs_information6             IN VARCHAR2
                             ,p_abs_information7             IN VARCHAR2
                             ,p_abs_information8             IN VARCHAR2
                             ,p_abs_information9             IN VARCHAR2
                             ,p_abs_information10            IN VARCHAR2) IS


    --
    CURSOR csr_get_input_value_info(p_element_entry_id NUMBER
                                   ,p_input_value_name VARCHAR2
                                   ,p_date             DATE) IS
    SELECT pivf.input_value_id  iv_start_date_id
    FROM   pay_input_values_f    pivf
          ,pay_element_entries_f peef
          ,pay_element_types_f   petf
    WHERE  peef.element_entry_id  = p_element_entry_id
    AND    peef.element_type_id   = petf.element_type_id
    AND    pivf.element_type_id   = petf.element_type_id
    AND    pivf.name              = p_input_value_name
    AND    p_date                  BETWEEN peef.effective_start_date
                                   AND     peef.effective_end_date
    AND    p_date                  BETWEEN petf.effective_start_date
                                   AND     petf.effective_end_date
    AND    p_date                  BETWEEN pivf.effective_start_date
                                   AND     pivf.effective_end_date;
    --
    l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
    l_start_date_iv_id      pay_input_values_f.input_value_id%TYPE;
    l_end_date_iv_id        pay_input_values_f.input_value_id%TYPE;
    l_absence_type_iv_id    pay_input_values_f.input_value_id%TYPE;
    l_ptm_percentage_iv_id  pay_input_values_f.input_value_id%TYPE;
    l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
    l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
    l_ovn                   pay_element_entries_f.object_version_number%TYPE;
    l_o_start_dt            pay_element_entries_f.effective_start_date%TYPE;
    l_o_end_dt              pay_element_entries_f.effective_end_date%TYPE;
    l_o_warning             BOOLEAN;
    l_bus_grp_id            pay_input_values_f.business_group_id%TYPE;

    --
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    hr_utility.set_location('Entering hook Person_entry_Create',10);
    --
    IF  p_date_start IS NOT NULL THEN
        --
        IF  p_abs_information_category IN ('ES_TD','ES_M','ES_IE_AL','ES_PAR','ES_PTM') THEN
            --
            hr_utility.set_location(' IN Update User hook ',20);
            --
            hr_person_absence_api.get_absence_element
                 (p_absence_attendance_id   => p_absence_attendance_id
                 ,p_element_entry_id        => l_element_entry_id
                 ,p_effective_start_date    => l_effective_start_date
                 ,p_effective_end_date      => l_effective_end_date);
            --
            IF  l_element_entry_id IS NOT NULL THEN

                hr_utility.set_location(' Updating dates for entry_id='||l_element_entry_id,30);
                --
                IF  p_date_end = to_date('31-12-4712','DD-MM-YYYY') OR
                    p_date_end IS NULL THEN
                    l_effective_end_date := NULL;
                END IF;
                --
                OPEN csr_get_input_value_info(l_element_entry_id
                                             ,'Start Date'
                                             ,l_effective_start_date);
                FETCH csr_get_input_value_info INTO l_start_date_iv_id;
                CLOSE csr_get_input_value_info;
                --
                OPEN csr_get_input_value_info(l_element_entry_id
                                             ,'End Date'
                                             ,l_effective_start_date);
                FETCH csr_get_input_value_info INTO l_end_date_iv_id;
                CLOSE csr_get_input_value_info;
                --
                OPEN csr_get_input_value_info(l_element_entry_id
                                             ,'Absence ID'
                                             ,l_effective_start_date);
                FETCH csr_get_input_value_info INTO l_absence_type_iv_id;
                CLOSE csr_get_input_value_info;
                --
                IF  p_abs_information_category = 'ES_PTM' THEN
                    OPEN csr_get_input_value_info(l_element_entry_id
                                                 ,'Part Time Percentage'
                                                 ,l_effective_start_date);
                    FETCH csr_get_input_value_info INTO l_ptm_percentage_iv_id;
                    CLOSE csr_get_input_value_info;
                END IF;
                --
                SELECT max(object_version_number) INTO l_ovn
                FROM   pay_element_entries_f
                WHERE  element_entry_id = l_element_entry_id;
                --
                SELECT business_group_id INTO l_bus_grp_id
                FROM   per_absence_attendances
                WHERE  absence_attendance_id = p_absence_attendance_id;
                --
                hr_utility.set_location('~~ Before updating ',30);
                hr_utility.set_location('~~ Absence Att ID ' || to_char(p_absence_attendance_id),10);
                --
                IF  p_abs_information_category = 'ES_PTM' THEN
                    --
                    pay_element_entry_api.update_element_entry
                         (p_validate                => FALSE
                         ,p_datetrack_update_mode   => 'CORRECTION'
                         ,p_effective_date          => l_effective_start_date
                         ,p_business_group_id       => l_bus_grp_id
                         ,p_element_entry_id        => l_element_entry_id
                         ,p_object_version_number   => l_ovn
                         ,p_input_value_id1         => l_start_date_iv_id
                         ,p_entry_value1            => fnd_date.date_to_displaydate(l_effective_start_date) --l_effective_start_date
                         ,p_input_value_id2         => l_end_date_iv_id
                         ,p_entry_value2            => fnd_date.date_to_displaydate(l_effective_end_date) --l_effective_end_date
                         ,p_input_value_id3         => l_absence_type_iv_id
                         ,p_entry_value3            => p_absence_attendance_id
                         ,p_input_value_id4         => l_ptm_percentage_iv_id
                         ,p_entry_value4            => p_abs_information3
                         ,p_effective_start_date    => l_o_start_dt
                         ,p_effective_end_date      => l_o_end_dt
                         ,p_update_warning          => l_o_warning);
                ELSE
                    pay_element_entry_api.update_element_entry
                         (p_validate                => FALSE
                         ,p_datetrack_update_mode   => 'CORRECTION'
                         ,p_effective_date          => l_effective_start_date
                         ,p_business_group_id       => l_bus_grp_id
                         ,p_element_entry_id        => l_element_entry_id
                         ,p_object_version_number   => l_ovn
                         ,p_input_value_id1         => l_start_date_iv_id
                         ,p_entry_value1            => fnd_date.date_to_displaydate(l_effective_start_date) --l_effective_start_date
                         ,p_input_value_id2         => l_end_date_iv_id
                         ,p_entry_value2            => fnd_date.date_to_displaydate(l_effective_end_date) --l_effective_end_date
                         ,p_input_value_id3         => l_absence_type_iv_id
                         ,p_entry_value3            => p_absence_attendance_id
                         ,p_effective_start_date    => l_o_start_dt
                         ,p_effective_end_date      => l_o_end_dt
                         ,p_update_warning          => l_o_warning);
                END IF;
                --
                hr_utility.set_location('~~ After updating ',30);
            END IF;
        END IF;
    END IF;
    --
  END IF;
  --
  hr_utility.set_location('Leaving hook Person_entry_Update',90);
  --
END person_entry_update;
-------------------------------------------------------------------------------
-- VALIDATE_ABS_CREATE
-------------------------------------------------------------------------------
PROCEDURE validate_abs_create(p_business_group_id            IN NUMBER
                             ,p_person_id                    IN NUMBER
                             ,p_absence_attendance_type_id   IN NUMBER
                             ,p_date_start                   IN DATE
                             ,p_time_start                   IN VARCHAR2
                             ,p_date_end                     IN DATE
                             ,p_time_end                     IN VARCHAR2
                             ,p_abs_information_category     IN VARCHAR2
                             ,p_abs_information1             IN VARCHAR2
                             ,p_abs_information2             IN VARCHAR2
                             ,p_abs_information3             IN VARCHAR2
                             ,p_abs_information4             IN VARCHAR2
                             ,p_abs_information5             IN VARCHAR2
                             ,p_abs_information6             IN VARCHAR2
                             ,p_abs_information7             IN VARCHAR2
                             ,p_abs_information8             IN VARCHAR2
                             ,p_abs_information9             IN VARCHAR2
                             ,p_abs_information10            IN VARCHAR2) IS
    --
    CURSOR csr_get_absence_category(p_absence_attendance_type_id  NUMBER) IS
    SELECT absence_category
    FROM   per_absence_attendance_types
    WHERE  absence_attendance_type_id = p_absence_attendance_type_id;
    --
    CURSOR csr_get_other_absences(p_person_id  NUMBER
                                 ,p_date_start DATE
                                 ,p_date_end   DATE) IS
    SELECT PAAT.absence_category
    FROM   per_absence_attendances      PAA
          ,per_absence_attendance_types PAAT
    WHERE  PAA.person_id                   = p_person_id
    AND    PAAT.absence_attendance_type_id = PAA.absence_attendance_type_id
    AND    (( p_date_start             BETWEEN  PAA.date_start
                                      AND      NVL(PAA.date_end,to_date('31-12-4712','DD-MM-YYYY')))
    OR     (PAA.date_start             BETWEEN  p_date_start
                                      AND      NVL(p_date_end,to_date('31-12-4712','DD-MM-YYYY'))));
    --
    CURSOR csr_validate_ptm(p_person_id  NUMBER
                           ,p_date_start DATE) IS
    SELECT nvl(to_number(max(PAA.date_end) - max(PAA.date_start)+1),0)
    FROM   per_absence_attendances      PAA
          ,per_absence_attendance_types PAAT
    WHERE  PAA.person_id                   = p_person_id
    AND    PAAT.absence_attendance_type_id = PAA.absence_attendance_type_id
    AND    PAAT.absence_category           = 'M'
    AND    p_date_start                    = PAA.date_end + 1 ;
    --  AND    p_date_start                    > PAA.date_end;
    --

    CURSOR csr_validate_sex_par(p_person_id NUMBER) IS
    SELECT ppf.sex
    FROM   per_people_f ppf
    WHERE  ppf.person_id = p_person_id ;

    l_sex                    per_people_f.sex%TYPE;

    l_maternity_benefit_days NUMBER;
    l_absence_category       per_absence_attendance_types.absence_category%TYPE;
    --
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    -- get the values of the person_id profile
    fnd_profile.put('HR_FR_PERSON_ID',p_person_id);
    -- get the value of the absence_start_date
    fnd_profile.put('HR_FR_ABSENCE_START_DATE',fnd_date.date_to_canonical(p_date_start));
    --
    --IF  p_date_start IS NOT NULL THEN
        --
        OPEN csr_get_absence_category(p_absence_attendance_type_id);
        FETCH csr_get_absence_category INTO l_absence_category ;
        CLOSE csr_get_absence_category;
        --
        IF  l_absence_category IN ('TD') THEN
            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('TD') THEN
                    hr_utility.set_message(800,'HR_ES_TD_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('V') THEN
                    hr_utility.set_message(800,'HR_ES_V_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('ZZB') THEN
                    hr_utility.set_message(800,'HR_ES_STRIKE_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information3 = 'GROSS_PAY' ) AND (p_abs_information4 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('V') THEN
            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('TD') THEN
                    hr_utility.set_message(800,'HR_ES_TD_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('V') THEN
                    hr_utility.set_message(800,'HR_ES_V_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
        END IF;
        --
        IF  l_absence_category IN ('ZZB') THEN
            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('TD') THEN
                    hr_utility.set_message(800,'HR_ES_TD_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('ZZB') THEN
                    hr_utility.set_message(800,'HR_ES_STRIKE_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
        END IF;
        --
        IF  l_absence_category IN ('M') THEN
            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('M') THEN
                    hr_utility.set_message(800,'HR_ES_M_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('PAR') THEN
                    hr_utility.set_message(800,'HR_ES_PAR_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information5 = 'GROSS_PAY' ) AND (p_abs_information6 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('PAR') THEN

            OPEN csr_validate_sex_par (p_person_id);
            FETCH csr_validate_sex_par INTO l_sex ;
            CLOSE csr_validate_sex_par;
                  IF l_sex = 'M' THEN
                  hr_utility.set_message(800,'HR_ES_PAR_CHK_SEX');
                  hr_utility.raise_error;
                  END IF;

            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('PAR') THEN
                    hr_utility.set_message(800,'HR_ES_PAR_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information2= 'GROSS_PAY' ) AND (p_abs_information3 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('IE_AL') THEN
            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('IE_AL') THEN
                    hr_utility.set_message(800,'HR_ES_ADOPTION_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information2 = 'GROSS_PAY' ) AND (p_abs_information3 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('PTM') THEN
            FOR i IN csr_get_other_absences(p_person_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('M') THEN
                    hr_utility.set_message(800,'HR_ES_M_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('PTM') THEN
                    hr_utility.set_message(800,'HR_ES_PTM_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            --
            OPEN csr_validate_ptm (p_person_id
                                  ,p_date_start);
            FETCH csr_validate_ptm INTO l_maternity_benefit_days ;
            CLOSE csr_validate_ptm;
            --
            IF l_maternity_benefit_days = 0 THEN
                hr_utility.set_message(800,'HR_ES_M_NOT_FOUND');
                hr_utility.raise_error;
            END IF;
            --
            IF l_maternity_benefit_days < 42 THEN
                hr_utility.set_message(800,'HR_ES_PTM_CANT_COMMENCE');
                hr_utility.raise_error;
            END IF;
            --
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information4 = 'GROSS_PAY' ) AND (p_abs_information5 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
  END IF;
  --
END validate_abs_create;
--
-------------------------------------------------------------------------------
-- VALIDATE_ABS_UPDATE
-------------------------------------------------------------------------------
PROCEDURE validate_abs_update(p_absence_attendance_id        IN NUMBER
                             ,p_date_start                   IN DATE
                             ,p_time_start                   IN VARCHAR2
                             ,p_date_end                     IN DATE
                             ,p_time_end                     IN VARCHAR2
                             ,p_abs_information_category     IN VARCHAR2
                             ,p_abs_information1             IN VARCHAR2
                             ,p_abs_information2             IN VARCHAR2
                             ,p_abs_information3             IN VARCHAR2
                             ,p_abs_information4             IN VARCHAR2
                             ,p_abs_information5             IN VARCHAR2
                             ,p_abs_information6             IN VARCHAR2
                             ,p_abs_information7             IN VARCHAR2
                             ,p_abs_information8             IN VARCHAR2
                             ,p_abs_information9             IN VARCHAR2
                             ,p_abs_information10            IN VARCHAR2) IS
    --
    CURSOR csr_get_absence_category(p_absence_attendance_id  NUMBER) IS
    SELECT paat.absence_category
    FROM   per_absence_attendance_types paat
          ,per_absence_attendances      paa
    WHERE  paa.absence_attendance_id       = p_absence_attendance_id
    AND    paat.absence_attendance_type_id = paa.absence_attendance_type_id;
    --
    CURSOR csr_get_other_absences(p_absence_attendance_id  NUMBER
                                 ,p_date_start             DATE
                                 ,p_date_end               DATE) IS
    SELECT PAAT.absence_category
    FROM   per_absence_attendances      PAA1
          ,per_absence_attendances      PAA2
          ,per_absence_attendance_types PAAT
    WHERE  PAA1.absence_attendance_id      = p_absence_attendance_id
    AND    PAA2.person_id                  = PAA1.person_id
    AND    PAAT.absence_attendance_type_id = PAA2.absence_attendance_type_id
    AND    PAA1.absence_attendance_id      <> PAA2.absence_attendance_id
    AND    (( p_date_start            BETWEEN  PAA2.date_start
                                      AND      NVL(PAA2.date_end,to_date('31-12-4712','DD-MM-YYYY')))
    OR     (PAA2.date_start            BETWEEN  p_date_start
                                      AND      NVL(p_date_end,to_date('31-12-4712','DD-MM-YYYY'))));
    --
    CURSOR csr_validate_ptm(p_absence_attendance_id  NUMBER
                           ,p_date_start             DATE) IS
    SELECT nvl(to_number(max(PAA2.date_end) - max(PAA2.date_start)+1),0)
    FROM   per_absence_attendances      PAA1
          ,per_absence_attendances      PAA2
          ,per_absence_attendance_types PAAT
    WHERE  PAA1.absence_attendance_id      = p_absence_attendance_id
    AND    PAA2.person_id                  = PAA1.person_id
    AND    PAAT.absence_attendance_type_id = PAA2.absence_attendance_type_id
    AND    PAA1.absence_attendance_id      <> PAA2.absence_attendance_id
    AND    PAAT.absence_category           = 'M'
    AND    p_date_start                    = PAA2.date_end + 1;
    --   AND    p_date_start                    > PAA2.date_end;
    --
    CURSOR get_person_id(p_absence_attendance_id in number) is
    SELECT person_id
    FROM   per_absence_attendances
    WHERE  absence_attendance_id =p_absence_attendance_id;
    --

    CURSOR csr_validate_sex_par(p_person_id NUMBER) IS
    SELECT ppf.sex
    FROM   per_people_f ppf
    WHERE  ppf.person_id = p_person_id ;

    l_sex                    per_people_f.sex%TYPE;

    l_maternity_benefit_days NUMBER;
    l_absence_category       per_absence_attendance_types.absence_category%TYPE;
    l_person_id per_absence_attendances.person_id%TYPE;
    --
BEGIN
   --
   -- Added for GSI Bug 5472781
   --
   IF hr_utility.chk_product_install('Oracle Human Resources', 'ES') THEN
     --
    --
    OPEN  get_person_id(p_absence_attendance_id);
    FETCH get_person_id into l_person_id;
    CLOSE get_person_id;

    -- get the values of the person_id profile
    fnd_profile.put('HR_FR_PERSON_ID',l_person_id);
    -- get the value of the absence_start_date
    fnd_profile.put('HR_FR_ABSENCE_START_DATE',fnd_date.date_to_canonical(p_date_start));
    --
    --IF  p_date_start IS NOT NULL THEN
        --
        OPEN csr_get_absence_category(p_absence_attendance_id);
        FETCH csr_get_absence_category INTO l_absence_category;
        CLOSE csr_get_absence_category;
        --
        IF  l_absence_category IN ('TD') THEN
            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('TD') THEN
                    hr_utility.set_message(800,'HR_ES_TD_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('V') THEN
                    hr_utility.set_message(800,'HR_ES_V_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('ZZB') THEN
                    hr_utility.set_message(800,'HR_ES_STRIKE_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information3 = 'GROSS_PAY' ) AND (p_abs_information4 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('V') THEN
            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('V') THEN
                    hr_utility.set_message(800,'HR_ES_V_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('TD') THEN
                    hr_utility.set_message(800,'HR_ES_TD_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
        END IF;
        --
        IF  l_absence_category IN ('ZZB') THEN
            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('TD') THEN
                    hr_utility.set_message(800,'HR_ES_TD_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('ZZB') THEN
                    hr_utility.set_message(800,'HR_ES_STRIKE_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
        END IF;
        --
        IF  l_absence_category IN ('M') THEN
            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF  i.absence_category IN ('M') THEN
                    hr_utility.set_message(800,'HR_ES_M_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF  i.absence_category IN ('PAR') THEN
                    hr_utility.set_message(800,'HR_ES_PAR_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information5 = 'GROSS_PAY' ) AND (p_abs_information6 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('PAR') THEN

            OPEN csr_validate_sex_par (l_person_id);
            FETCH csr_validate_sex_par INTO l_sex ;
            CLOSE csr_validate_sex_par;
                  IF l_sex = 'M' THEN
                  hr_utility.set_message(800,'HR_ES_PAR_CHK_SEX');
                  hr_utility.raise_error;
                  END IF;


            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('PAR') THEN
                    hr_utility.set_message(800,'HR_ES_PAR_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information2= 'GROSS_PAY' ) AND (p_abs_information3 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('IE_AL') THEN
            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('IE_AL') THEN
                    hr_utility.set_message(800,'HR_ES_ADOPTION_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information2 = 'GROSS_PAY' ) AND (p_abs_information3 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
        IF  l_absence_category IN ('PTM') THEN
            FOR i IN csr_get_other_absences(p_absence_attendance_id
                                           ,p_date_start
                                           ,p_date_end) LOOP
                IF i.absence_category IN ('PTM') THEN
                    hr_utility.set_message(800,'HR_ES_PTM_OVERLAP');
                    hr_utility.raise_error;
                END IF;
                IF i.absence_category IN ('M') THEN
                    hr_utility.set_message(800,'HR_ES_M_OVERLAP');
                    hr_utility.raise_error;
                END IF;
            END LOOP;
            --
            OPEN csr_validate_ptm (p_absence_attendance_id
                                  ,p_date_start);
            FETCH csr_validate_ptm INTO l_maternity_benefit_days ;
            CLOSE csr_validate_ptm;
            --
            IF l_maternity_benefit_days = 0 THEN
                hr_utility.set_message(800,'HR_ES_M_NOT_FOUND');
                hr_utility.raise_error;
            END IF;
            --
            IF l_maternity_benefit_days < 42 THEN
                hr_utility.set_message(800,'HR_ES_PTM_CANT_COMMENCE');
                hr_utility.raise_error;
            END IF;
            -- BU Gross Pay Daily Rate Formula validation
            IF  (p_abs_information4 = 'GROSS_PAY' ) AND (p_abs_information5 IS NULL) THEN
                hr_utility.set_message(800, 'HR_ES_BU_RATE_FORMULA_MISSING');
                hr_utility.raise_error;
            END IF;
            --
        END IF;
        --
  END IF;
  --
END validate_abs_update;
--
END per_es_absence;

/
