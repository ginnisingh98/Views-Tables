--------------------------------------------------------
--  DDL for Package Body HR_BE_EXTRA_PERSON_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BE_EXTRA_PERSON_RULES" AS
  /* $Header: pebeexpr.pkb 120.0.12010000.2 2008/08/06 09:05:01 ubhat ship $ */
  --
  --
  -- Service functions to return TRUE if the value passed has been changed.
  --
  FUNCTION val_changed(p_value IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_number);
  END val_changed;
  --
  FUNCTION val_changed(p_value IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_varchar2);
  END val_changed;
  --
  FUNCTION val_changed(p_value IN DATE) RETURN BOOLEAN IS
  BEGIN
    RETURN (p_value IS NULL OR p_value <> hr_api.g_date);
  END val_changed;
  --
  --
  -- Correspondance language:
  --
  -- It is mandatory for an employee and must be one of the following languages -
  -- 'NL' - Dutch, 'F' - French, or 'D' - German.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  procedure extra_language_checks
  (p_person_type_id          IN NUMBER
  ,p_correspondence_language IN VARCHAR2) IS
    --
    CURSOR c_system_person_type(p_person_type_id NUMBER) IS
      SELECT system_person_type
      FROM   per_person_types
      WHERE  person_type_id = p_person_type_id;
    --
    l_system_person_type per_person_types.system_person_type%TYPE;
  BEGIN
  -- Added the validation for the Bug No. 6469769 to check whether the Belgium Legislation is installed or not.
  -- Only if it is installed,the validation is performed.
    IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'BE') THEN
       hr_utility.trace ('BE Legislation not installed. Not performing the validations');
       RETURN;
    END IF;

    IF val_changed(p_correspondence_language) THEN
      --
      OPEN  c_system_person_type(p_person_type_id);
      FETCH c_system_person_type INTO l_system_person_type;
      CLOSE c_system_person_type;
      --
      IF l_system_person_type IN ('EMP', 'EMP_APL') THEN
        IF p_correspondence_language IS NULL THEN
          hr_utility.set_message(800, 'HR_BE_LANGUAGE_CODE_NULL');
          hr_utility.raise_error;
        ELSIf p_correspondence_language NOT IN ('NL','F','D') THEN
          hr_utility.set_message(800, 'HR_BE_LANGUAGE_CODE_WRONG');
          hr_utility.raise_error;
        END IF;
      END IF;
    END IF;
  END extra_language_checks;
  --
  --
  -- Region of birth:
  --
  -- It cannot be entered.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_person_checks
  (p_region_of_birth IN VARCHAR2) IS
  BEGIN
  -- Added the validation for the Bug No. 6469769 to check whether the Belgium Legislation is installed or not.
  -- Only if it is installed,the validation is performed.
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'BE') THEN
       hr_utility.trace ('BE Legislation not installed. Not performing the validations');
       RETURN;
    END IF;
    If val_changed(p_region_of_birth) AND p_region_of_birth IS NOT NULL THEN
      hr_utility.set_message(800, 'HR_BE_REGION_OF_BIRTH_NOT_NULL');
      hr_utility.raise_error;
    END IF;
  END extra_person_checks;

  --
  --
  -- Employee Category:
  --
  -- It cannot be null.
  --
  --
  PROCEDURE extra_assignment_checks
  (p_employee_category IN VARCHAR2) IS
  BEGIN
  -- Added the validation for the Bug No. 6469769 to check whether the Belgium Legislation is installed or not.
  -- Only if it is installed,the validation is performed.
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'BE') THEN
       hr_utility.trace ('BE Legislation not installed. Not performing the validations');
       RETURN;
    END IF;
    If p_employee_category IS NULL THEN
      hr_utility.set_message(800, 'HR_BE_EMPLOYEE_CAT_NOT_NULL');
      hr_utility.raise_error;
    END IF;
  END extra_assignment_checks;



END hr_be_extra_person_rules;

/
