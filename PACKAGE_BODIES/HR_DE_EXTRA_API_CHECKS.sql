--------------------------------------------------------
--  DDL for Package Body HR_DE_EXTRA_API_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_EXTRA_API_CHECKS" AS
  /* $Header: pedehkvl.pkb 115.8 2002/01/03 07:35:35 pkm ship       $ */
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
  -- Service function to validate the SCL according to the following rules.
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE validate_scl
  (p_organization_id IN NUMBER
  ,p_exempt_flag     IN VARCHAR2
  ,p_liability_prov  IN VARCHAR2
  ,p_class_of_risk   IN VARCHAR2) IS
    --
    --
    -- Local variables.
    --
    l_dummy           VARCHAR2(2000);
  BEGIN
    null;
  END validate_scl;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Assignment checks.
  --
  -- 1. Union Membership cannot be recorded.
  --
  -- 2. The information held in the SCL is valid (see service function validate_scl()
  --    for details of the rules. To be implemented!
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE assignment_checks
  (p_labour_union_member_flag IN VARCHAR2) IS
  BEGIN
    --
    --
    -- Check that the union member flag has not been set.
    --
    If p_labour_union_member_flag IS NOT NULL THEN
      hr_utility.set_message(800, 'HR_DE_INVALID_UNION_FLAG');
      hr_utility.raise_error;
    END IF;
    --
    --
    -- Check that the SCL is valid.
    --
    validate_scl
      (p_organization_id => null   --  p_organization_id
      ,p_exempt_flag     => null   --  p_segment2
      ,p_liability_prov  => null   --  p_segment3
      ,p_class_of_risk   => null); --  p_segment4);
  END assignment_checks;
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
  END org_information_checks;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Person Extra Information checks.
  --
  -- - Military Service (DE_MILITARY_SERVICE).
  --
  -- 1. The Date From (p_pei_information1) must be on or before Date To (p_pei_information2).
  --
  -- - Residence Permit (DE_RESIDENCE_PERMITS).
  --
  -- 1. The Effective Date (p_pei_information6) must be on or before Expiry Date
  --    (p_pei_information7).
  --
  -- - Work Permit (DE_WORK_PERMITS).
  --
  -- 1. The Effective Date (p_pei_information6) must be on or before Expiry Date
  --    (p_pei_information7).
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE person_information_checks
  (p_pei_information_category IN VARCHAR2
  ,p_pei_information1         IN VARCHAR2
  ,p_pei_information2         IN VARCHAR2
  ,p_pei_information6         IN VARCHAR2
  ,p_pei_information7         IN VARCHAR2) IS
    --
    --
    -- Local exceptions.
    --
    military_service_dates EXCEPTION;
    permit_dates           EXCEPTION;
    --
    --
    -- Local variables.
    --
    l_lower_date DATE := TO_DATE('01/01/0001','DD/MM/YYYY');
    l_upper_date DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
  BEGIN
    --
    --
    -- Military Service validation.
    --
    IF p_pei_information_category = 'DE_MILITARY_SERVICE' THEN
      --
      --
      -- Convert parameters to dates.
      --
      IF p_pei_information1 IS NOT NULL THEN
        l_lower_date := TRUNC(fnd_date.canonical_to_date(p_pei_information1));
      END IF;
      IF p_pei_information2 IS NOT NULL THEN
        l_upper_date := TRUNC(fnd_date.canonical_to_date(p_pei_information2));
      END IF;
      --
      --
      -- Date From > Date To so error.
      --
      IF l_lower_date > l_upper_date THEN
        RAISE military_service_dates;
      END IF;
    --
    --
    -- Residence Permit validation.
    --
    ELSIF p_pei_information_category = 'DE_RESIDENCE_PERMITS' THEN
      --
      --
      -- Convert parameters to dates.
      --
      IF p_pei_information6 IS NOT NULL THEN
        l_lower_date := TRUNC(fnd_date.canonical_to_date(p_pei_information6));
      END IF;
      IF p_pei_information7 IS NOT NULL THEN
        l_upper_date := TRUNC(fnd_date.canonical_to_date(p_pei_information7));
      END IF;
      --
      --
      -- Effective Date > Expiry Date so error.
      --
      IF l_lower_date > l_upper_date THEN
        RAISE permit_dates;
      END IF;
    --
    --
    -- Work Permit validation.
    --
    ELSIF p_pei_information_category = 'DE_WORK_PERMITS' THEN
      --
      --
      -- Convert parameters to dates.
      --
      IF p_pei_information6 IS NOT NULL THEN
        l_lower_date := TRUNC(fnd_date.canonical_to_date(p_pei_information6));
      END IF;
      IF p_pei_information7 IS NOT NULL THEN
        l_upper_date := TRUNC(fnd_date.canonical_to_date(p_pei_information7));
      END IF;
      --
      --
      -- Effective Date > Expiry Date so error.
      --
      IF l_lower_date > l_upper_date THEN
        RAISE permit_dates;
      END IF;
    END IF;
  EXCEPTION
    --
    --
    -- Date From is not on or before Date To.
    --
    WHEN military_service_dates THEN
      hr_utility.set_message(800, 'HR_DE_MILITARY_SERVICE_DATES');
      hr_utility.raise_error;
    --
    --
    -- Effective Date is not on or before Expiry Date.
    --
    WHEN permit_dates THEN
      hr_utility.set_message(800, 'HR_DE_PERMIT_DATES');
      hr_utility.raise_error;
  END person_information_checks;
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Work Incident checks.
  --
  -- 1. The Work Stop Date (p_inc_information10) must be on or after Work Incident Date
  --    (p_incident_date).
  --
  -- 2. The Payment End Date (p_inc_information9) must be on or after Work Incident Date
  --    (p_incident_date).
  --
  -- 3. The Work Resumption Date (p_inc_information11) must be on or after Work Incident Date
  --    (p_incident_date).
  --
  -- 4. The Job Start Date (p_inc_information3) must be on or before Work Incident Date
  --    (p_incident_date).
  --
  -- 5. The Work Stop Date (p_inc_information10) must be on or before Work Resumption Date
  --    (p_inc_information11).
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  PROCEDURE work_incident_checks
  (p_incident_date     IN DATE
  ,p_inc_information3  IN VARCHAR2
  ,p_inc_information9  IN VARCHAR2
  ,p_inc_information10 IN VARCHAR2
  ,p_inc_information11 IN VARCHAR2) IS
    --
    --
    -- Local exceptions.
    --
    work_stop_date_too_early     EXCEPTION;
    payment_end_date_too_early   EXCEPTION;
    work_resump_date_too_early   EXCEPTION;
    job_start_date_too_late      EXCEPTION;
    resump_date_before_stop_date EXCEPTION;
  BEGIN
    --
    --
    -- The Work Stop Date must be on or after Work Incident Date.
    --
    IF p_inc_information10 IS NOT NULL THEN
      IF p_incident_date > TRUNC(fnd_date.canonical_to_date(p_inc_information10)) THEN
        RAISE work_stop_date_too_early;
      END IF;
    END IF;
    --
    --
    -- The Payment End Date must be on or after Work Incident Date.
    --
    IF p_inc_information9 IS NOT NULL THEN
      IF p_incident_date > TRUNC(fnd_date.canonical_to_date(p_inc_information9)) THEN
        RAISE payment_end_date_too_early;
      END IF;
    END IF;
    --
    --
    -- The Work Resumption Date must be on or after Work Incident Date.
    --
    IF p_inc_information11 IS NOT NULL THEN
      IF p_incident_date > TRUNC(fnd_date.canonical_to_date(p_inc_information11)) THEN
        RAISE work_resump_date_too_early;
      END IF;
    END IF;
    --
    --
    -- The Job Start Date must be on or before Work Incident Date.
    --
    IF p_inc_information3 IS NOT NULL THEN
      IF p_incident_date < TRUNC(fnd_date.canonical_to_date(p_inc_information3)) THEN
        RAISE job_start_date_too_late;
      END IF;
    END IF;
    --
    --
    -- The Work Stop Date must be on or before Work Resumption Date.
    --
    IF p_inc_information10 IS NOT NULL AND p_inc_information11 IS NOT NULL THEN
      IF TRUNC(fnd_date.canonical_to_date(p_inc_information11)) < TRUNC(fnd_date.canonical_to_date(p_inc_information10)) THEN
        RAISE resump_date_before_stop_date;
      END IF;
    END IF;
  EXCEPTION
    --
    --
    -- Work stop date is before the work incident date.
    --
    WHEN work_stop_date_too_early THEN
      hr_utility.set_message(800, 'HR_DE_STOP_DATE_TOO_EARLY');
      hr_utility.raise_error;
    --
    --
    -- Payment stop date is before the work incident date.
    --
    WHEN payment_end_date_too_early THEN
      hr_utility.set_message(800, 'HR_DE_PYMNT_DATE_TOO_EARLY');
      hr_utility.raise_error;
    --
    --
    -- Work resumption date is before the work incident date.
    --
    WHEN work_resump_date_too_early THEN
      hr_utility.set_message(800, 'HR_DE_RESUMP_DATE_TOO_EARLY');
      hr_utility.raise_error;
    --
    --
    -- Job start date is after the work incident date.
    --
    WHEN job_start_date_too_late THEN
      hr_utility.set_message(800, 'HR_DE_JOB_START_DATE_TOO_LATE');
      hr_utility.raise_error;
    --
    --
    -- Work Stop Date is after the Work Resumption Date.
    --
    WHEN resump_date_before_stop_date THEN
      hr_utility.set_message(800, 'HR_DE_RESUMP_BEFORE_STOP_DATE');
      hr_utility.raise_error;
  END work_incident_checks;
END hr_de_extra_api_checks;

/
