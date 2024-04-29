--------------------------------------------------------
--  DDL for Package Body HR_DE_EXTRA_PERSON_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_EXTRA_PERSON_CHECKS" AS
  /* $Header: pedepeiv.pkb 120.1 2006/09/12 10:39:03 abppradh noship $ */
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
    -- Check if DE is installed
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

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
END hr_de_extra_person_checks;

/
