--------------------------------------------------------
--  DDL for Package HR_BE_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_BE_VALIDATION" AUTHID CURRENT_USER AS
  /* $Header: hrbevali.pkh 120.0.12010000.2 2009/12/01 09:29:53 bkeshary ship $ */
  --
  --
  -- Constants representing the success or failure of a particular piece of
  -- validation.
  --
  success CONSTANT VARCHAR2(7) := 'SUCCESS';
  failure CONSTANT VARCHAR2(7) := 'FAILURE';
  --
  --
  -- This function validates that the bank account no is valid (see comments
  -- within code for details of correct format and check digit calculation).
  --
  -- Its primary usage is within the bank account key flexfield definition
  -- where it is used to drive some cross validation rules.
  --
  -- This function returns either:
  --
  -- Bank account no is OK      - hr_be_validation.success
  -- Bank account no is invalid - hr_be_validation.failure
  --
  FUNCTION bank_account_no
  (p_bank_acc_no VARCHAR2) RETURN VARCHAR2;

  FUNCTION validate_account_entered
  (p_acc_no        IN VARCHAR2,
   p_is_iban_acc   IN varchar2) RETURN NUMBER;

END hr_be_validation;

/
