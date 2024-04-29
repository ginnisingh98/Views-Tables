--------------------------------------------------------
--  DDL for Package Body HR_DE_EXTRA_ORG_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_EXTRA_ORG_CHECKS" AS
  /* $Header: hrdeorgv.pkb 120.0.12000000.2 2007/02/28 10:03:42 spendhar ship $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Service function to return one of two values based on the result of an
  -- expression. If the expression is true then the first value is returned
  -- otherwise the second value is returned.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  FUNCTION decode
  (p_expr IN BOOLEAN
  ,p_val1 IN NUMBER
  ,p_val2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_expr THEN
      RETURN p_val1;
    ELSE
      RETURN p_val2;
    END IF;
  END decode;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Service function to validate the betriebsnummer according to the following rules.
  --
  -- Format is xxxyyyyz (all numeric) where...
  --
  -- xxx is the ID from the unemployment office. Currently allowed values are 010
  -- to 099 or it must be larger than 110.
  --
  -- yyyy is a sequential number issued by unemployment office.
  --
  -- z is a check digit.
  --
  -- NB. the message name for the error to be raised is passed in as there is more than
  --     one betriebsnummer.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE validate_betriebsnummer
  (p_betriebsnummer IN VARCHAR2
  ,p_message_name    IN VARCHAR2) IS
    --
    --
    -- Local exceptions
    --
    invalid_format EXCEPTION;
    --
    --
    -- Local variables.
    --
    l_dummy           VARCHAR2(2000);
    l_betriebsnummer  VARCHAR2(240) := p_betriebsnummer;
    l_id_num          NUMBER;
    l_seq_num         NUMBER;
    l_check_digit     NUMBER;
    l_temp_value      NUMBER := 0;
    l_temp_sum        NUMBER := 0;
    l_temp_last_digit NUMBER := 0;
  BEGIN
    --
    --
    -- Must be an integer.
    --
    BEGIN
      hr_chkfmt.checkformat
        (value   => l_betriebsnummer
        ,format  => 'I'
        ,output  => l_dummy
        ,minimum => null
        ,maximum => null
        ,nullok  => 'N'
        ,rgeflg  => l_dummy
        ,curcode => null);
    EXCEPTION
      WHEN OTHERS THEN
        RAISE invalid_format;
    END;
    --
    --
    -- Must be 8 characters in length.
    --
    IF LENGTH(p_betriebsnummer) <> 8 THEN
      RAISE invalid_format;
    END IF;
    --
    --
    -- Extract the 3 components and convert them to numbers.
    --
    l_id_num      := TO_NUMBER(SUBSTR(p_betriebsnummer, 1, 3));
    l_seq_num     := TO_NUMBER(SUBSTR(p_betriebsnummer, 4, 4));
    l_check_digit := TO_NUMBER(SUBSTR(p_betriebsnummer, 8, 1));
    --
    --
    -- ID number validation (xxx).
    --
    IF NOT ((l_id_num >= 10 AND l_id_num <= 99) OR l_id_num > 110) THEN
      RAISE invalid_format;
    END IF;
    --
    --
    -- Sequential number validation (yyyy).
    --
    -- IF NOT (l_seq_num > 0) THEN
    --   RAISE invalid_format;
    -- END IF;
    --
    --
    -- Check digit validation (z).
    --
    -- Process the first 7 digits of the betriebsnummer to calculate the sum from
    -- which the check digit is derived.
    --
    FOR i IN 1..7 LOOP
      --
      --
      -- Each odd digit is multiplied by 1 and even digit by 2.
      --
      l_temp_value := TO_NUMBER(SUBSTR(p_betriebsnummer, i, 1)) * (MOD(i - 1, 2) + 1);
      --
      --
      -- If the result is greater than 9 then add together the individual digits e.g.
      --
      -- 18 -> 1 + 8 -> 9
      --
      IF l_temp_value > 9 THEN
        l_temp_value := TO_NUMBER(SUBSTR(TO_CHAR(l_temp_value), 1, 1)) + TO_NUMBER(SUBSTR(TO_CHAR(l_temp_value), 2, 1));
      END IF;
      --
      --
      -- Sum all the individual values. This produces the number used to derive the check digit.
      --
      l_temp_sum := l_temp_sum + l_temp_value;
    END LOOP;
    --
    --
    -- Get the last digit of the check digit sum.
    --
    l_temp_last_digit := MOD(l_temp_sum, 10);
    --
    --
    -- Format is valid.
    --
    IF NOT(l_check_digit = l_temp_last_digit
        OR l_check_digit = decode(l_temp_last_digit > 4, l_temp_last_digit - 5, l_temp_last_digit + 5)) THEN
      RAISE invalid_format;
    END IF;
  EXCEPTION
    --
    --
    -- Format is invalid.
    --
    WHEN invalid_format THEN
      hr_utility.set_message(800, p_message_name);
      hr_utility.raise_error;
  END validate_betriebsnummer;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Organization information checks.
  --
  -- - German HR organization information (DE_HR_ORG_INFO).
  --
  -- 1. Payroll betriebsnummer and Employers betriebsnummer (p_org_information1 and 2)
  --    must conform to a prescribed format (see service function validate_betriebsnummer()
  --    for details of the rules).
  --
  -- - German social insurance information (DE_SOCIAL_INSURANCE_INFO).
  --
  -- 1. West betriebsnummer and East betriebsnummer (p_org_information1 and 2)
  --    must conform to a prescribed format (see service function validate_betriebsnummer()
  --    for details of the rules).
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE org_information_checks
  (p_org_info_type_code IN VARCHAR2
  ,p_org_information1   IN VARCHAR2
  ,p_org_information2   IN VARCHAR2) IS
  BEGIN
    --
    --
    -- Check if DE is installed
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

    -- German HR organization information validation.
    --
    IF p_org_info_type_code = 'DE_HR_ORG_INFO' THEN
      --
      --
      -- Validate the Employers betriebsnummer NB. passing the error message to be raised.
      --
      IF p_org_information1 IS NOT null THEN
        validate_betriebsnummer(p_org_information1, 'HR_DE_INVL_EMPLOYER_BETRIEBESN');
      END IF;
      --
      --
      -- Validate the Payroll betriebsnummer NB. passing the error message to be raised.
      --
      IF p_org_information2 IS NOT null THEN
        validate_betriebsnummer(p_org_information2, 'HR_DE_INVL_PAYROLL_BETRIEBESN');
      END IF;
    --
    --
    -- German social insurance information validation.
    --
    ELSIF p_org_info_type_code = 'DE_SOCIAL_INSURANCE_INFO' THEN
      --
      --
      -- Validate the West betriebsnummer NB. passing the error message to be raised.
      --
      IF p_org_information1 IS NOT null THEN
        validate_betriebsnummer(p_org_information1, 'HR_DE_INVL_WEST_BETRIEBESN');
      END IF;
      --
      --
      -- Validate the East betriebsnummer NB. passing the error message to be raised.
      --
      IF p_org_information2 IS NOT null THEN
        validate_betriebsnummer(p_org_information2, 'HR_DE_INVL_EAST_BETRIEBESN');
      END IF;
    END IF;

    END IF;
  END org_information_checks;
END hr_de_extra_org_checks;

/
