--------------------------------------------------------
--  DDL for Package Body HR_HK_PEOPLE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HK_PEOPLE_LEG_HOOK" AS
/* $Header: hrhklhpp.pkb 120.1.12010000.3 2009/05/06 09:22:42 pmatamsr ship $ */
--
  g_package  VARCHAR2(33) := 'hr_hk_people_leg_hook.';
--


  PROCEDURE check_hkid_passport(         p_person_type_id           NUMBER
                                        ,p_national_identifier      VARCHAR2
                                        ,p_per_information1         VARCHAR2
                                        ,p_per_information2         VARCHAR2
                                        ,p_per_information3         VARCHAR2
                                        ,p_per_information4         VARCHAR2) IS

    l_proc               VARCHAR2(200) := g_package||'check_hkid_passport';
    l_system_person_type per_person_types.system_person_type%type;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

   /*Bug 8457005 - Removed the condition and modified the existing check such that the validation of
                   national identifier and passport number is performed,only if Payroll for HK Legislation
                   is installed ,otherwise the validation is skipped */

    IF NOT hr_utility.chk_product_install('Oracle Payroll', 'HK') THEN
       hr_utility.trace ('HK Legislation not installed. Not performing the validations');
       RETURN;
    END IF;

      OPEN  csr_val_person_type(p_person_type_id);
      FETCH csr_val_person_type INTO
            l_system_person_type;
      CLOSE csr_val_person_type;

   -- Check if the Person is Employee - Bug No : 2817820. The cursor csr_val_person_type included to fetch the
   -- person_type using person_type_id.
      IF l_system_person_type like 'EMP%' THEN
         IF p_national_identifier IS NULL THEN
           IF ((p_per_information1 IS NULL)
              OR (p_per_information2 IS NULL)
              OR (p_per_information3 IS NULL)
              OR (p_per_information4 IS NULL)) THEN
           -- Error
             hr_utility.set_message(800,'HR_HK_HKID_OR_PASSPORT_INFO');
             hr_utility.raise_error;
            END IF;
          END IF;
      END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 20);
  END check_hkid_passport;



/* Bug No : 2737948 - Included a new procedure check_hongkong_name for Hong Kong Name validation */

 PROCEDURE check_hongkong_name( p_person_type_id NUMBER
                               ,p_per_information6  VARCHAR2) IS

   l_proc      VARCHAR2(200) := g_package|| 'check_hongkong_name';
   l_system_person_type  per_person_types.system_person_type%type;

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'HK') THEN
       hr_utility.trace ('HK Legislation not installed. Not performing the validations');
       RETURN;
    END IF;

    OPEN  csr_val_person_type(p_person_type_id);
    FETCH csr_val_person_type INTO
          l_system_person_type;
    CLOSE csr_val_person_type;

    IF l_system_person_type like 'EMP%' THEN
       IF (p_per_information6 IS NULL) THEN
          hr_utility.set_message('800', 'HR_HK_HONGKONG_NAME');
          hr_utility.raise_error;
       END IF;
    END IF;

    hr_utility.set_location(' Leaving:'||l_proc, 20);
  EXCEPTION
    WHEN OTHERS THEN
     hr_utility.trace('Error in ' || l_proc );
     raise;
  END check_hongkong_name;


END hr_hk_people_leg_hook;

/
