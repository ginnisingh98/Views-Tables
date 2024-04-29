--------------------------------------------------------
--  DDL for Package Body HR_DE_EXTRA_WORK_INC_CHECKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_EXTRA_WORK_INC_CHECKS" AS
  /* $Header: pedeincv.pkb 120.1 2006/09/12 09:38:36 abppradh noship $ */
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
    -- Check if DE is installed
    IF hr_utility.chk_product_install('Oracle Human Resources', 'DE') THEN

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
END hr_de_extra_work_inc_checks;

/
