--------------------------------------------------------
--  DDL for Package Body HR_IT_EXTRA_ASSGT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IT_EXTRA_ASSGT_RULES" AS
  /* $Header: hritexas.pkb 115.2 2002/01/04 05:57:54 pkm ship       $ */
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
  -- Employment category:
  --
  -- It  is validated against the list of values held in the lookup type IT_EMP_CAT.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_assignment_checks
  (p_employment_category IN VARCHAR2) IS
    --
    --
    -- Local variables.
    --
    l_emp_cat VARCHAR2(40);
  BEGIN
    IF val_changed(p_employment_category) AND p_employment_category IS NOT NULL THEN
      BEGIN
        SELECT lookup_code
        INTO   l_emp_cat
        FROM   hr_lookups
        WHERE  lookup_type = 'IT_EMP_CAT'
          AND  lookup_code = p_employment_category;
      EXCEPTION
        WHEN no_data_found THEN
	  hr_utility.set_message(800, 'HR_IT_INVALID_EMP_CAT');
	  hr_utility.raise_error;
      END;
    END IF;
  END extra_assignment_checks;
END hr_it_extra_assgt_rules;

/
