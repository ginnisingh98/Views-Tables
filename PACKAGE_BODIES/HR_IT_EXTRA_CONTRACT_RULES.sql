--------------------------------------------------------
--  DDL for Package Body HR_IT_EXTRA_CONTRACT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IT_EXTRA_CONTRACT_RULES" AS
  /* $Header: hritexct.pkb 115.3 2003/01/30 15:33:39 vgunasek noship $ */
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
  -- Contract type:
  --
  -- It is validated against the list of values held in the lookup type IT_CONTRACT_TYPE.
  --
  -- Note: Supports both real and API system values (these are passed when the value has not
  --       been changed.
  --
  PROCEDURE extra_contract_checks
  (p_type IN VARCHAR2) IS
    --
    --
    -- Local variables.
    --
    l_type VARCHAR2(40);
  BEGIN
 /* The Block is Commented intentionally for the BUG # 2772080
    If val_changed(p_type) AND p_type IS NOT NULL THEN
      BEGIN
        SELECT lookup_code
        INTO   l_type
        FROM   hr_lookups
        WHERE  lookup_type = 'IT_CONTRACT_TYPE'
          AND  lookup_code = p_type;
      EXCEPTION
        WHEN no_data_found THEN
	  hr_utility.set_message(800, 'HR_IT_INVALID_CONTRACT_TYPE');
	  hr_utility.raise_error;
      END;
    END IF;
    The Block is Commented intentionally for the BUG # 2772080 */
    NULL;
  END extra_contract_checks;
END hr_it_extra_contract_rules;

/
