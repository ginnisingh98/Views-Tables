--------------------------------------------------------
--  DDL for Package Body HR_BE_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BE_VALIDATION" AS
  /* $Header: hrbevali.pkb 120.0.12010000.2 2009/12/01 09:34:43 bkeshary ship $ */
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
  (p_bank_acc_no VARCHAR2) RETURN VARCHAR2 AS
    --
    --
    -- Local exceptions.
    --
    invalid_bank_acc_no EXCEPTION;
    --
    --
    -- Local variables.
    --
    l_temp_val     NUMBER;
    l_check_digits NUMBER;
    l_10_digits    NUMBER;
  BEGIN
    --
    --
    -- Ensure the format is NN-NNNNNNN-NN
    --
    IF INSTR(p_bank_acc_no, 'N') > 0 OR NVL(translate(p_bank_acc_no, '1234567890-', 'NNNNNNNNNN-'), 'ERROR') <> 'NNN-NNNNNNN-NN' THEN
      RAISE invalid_bank_acc_no;
    END IF;
    --
    --
    -- Calculate the check digit using the following algorthmn -
    --
    -- 1. Take the first 10 digits and divide these by 97 (rounding the result).
    -- 2. Multiply the result by 97.
    -- 3. Subtract this number from ther original first 10 digits.
    -- 4. This is the check digits NB. if < 10 need to front pad with a zero.
    --
    l_10_digits    := TO_NUMBER(SUBSTR(p_bank_acc_no, 1, 3) || SUBSTR(p_bank_acc_no, 5, 7));
    l_temp_val     := TRUNC(l_10_digits / 97) * 97;
    l_check_digits := l_10_digits - l_temp_val;
    --
    --
    -- Compare the check digit with the calculated one.
    --
    IF LPAD(TO_CHAR(l_check_digits), 2, '0') <> SUBSTR(p_bank_acc_no, 13, 2) and l_check_digits <> 0 THEN
      RAISE invalid_bank_acc_no;
    END IF;
    --
    IF l_check_digits = 0 and SUBSTR(p_bank_acc_no, 13, 2) <> 97 then
      RAISE invalid_bank_acc_no;
    END IF;
    --
    -- Bank account no is OK.
    --
    RETURN success;
  EXCEPTION
    WHEN invalid_bank_acc_no THEN
      --
      --
      -- Bank account no is incorrect.
      --
      RETURN failure;
  END bank_account_no;

  ----
  -- Function added for IBAN Validation
  ----
  FUNCTION validate_iban_acc(p_account_no VARCHAR2)RETURN NUMBER IS
  BEGIN
     IF IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) = 1 then
     RETURN 1;
     else
     RETURN 0;
     END IF;
  END validate_iban_acc;

----
-- This function will get called from the bank keyflex field segments  Bug
----
 FUNCTION validate_account_entered
 (p_acc_no        IN VARCHAR2,
  p_is_iban_acc   IN varchar2 ) RETURN NUMBER IS
   --
    l_ret1 varchar2(20) ;
    l_ret  number;
  begin
 --  hr_utility.trace_on(null,'ACCVAL');
   l_ret :=0;
   hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
   hr_utility.set_location('p_account_number ' || p_acc_no,1);

   IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') then
     l_ret1 := bank_account_no(p_acc_no);
     hr_utility.set_location('l_ret1 ' || l_ret1,1);
     if l_ret1 = 'SUCCESS' then
     return 0;
     else
     RETURN 1;
     end if;
   ELSIF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'Y') then
     l_ret := validate_iban_acc(p_acc_no);
     hr_utility.set_location('l_ret ' || l_ret,3);
     RETURN l_ret;
   ELSIF (p_acc_no IS NULL AND p_is_iban_acc IS NULL) then
     hr_utility.set_location('Both Account Nos Null',4);
     RETURN 1;
   ELSE
     hr_utility.set_location('l_ret: 3 ' ,5);
     RETURN 3;
   END if;
 End validate_account_entered;
--
END hr_be_validation;

/
