--------------------------------------------------------
--  DDL for Package Body IBAN_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBAN_VALIDATION_PKG" AS
--  /* $Header: peribanval.pkb 120.0.12010000.1 2009/11/20 11:52:53 dchindar noship $ */
--
--
-- Exceptions
hr_application_error exception;
pragma exception_init (hr_application_error, -20001);


--******************************************************************************
--* Returns the Discription for a lookup code of a IBAN_ACC_LOOKUP type.
--******************************************************************************
Function  get_acc_length ( p_lookup_code   VARCHAR2) RETURN  VARCHAR2  IS
--
CURSOR  csr_lookup IS
        SELECT  DESCRIPTION
        FROM     hr_lookups
        WHERE    lookup_type     = 'IBAN_ACC_LOOKUP'
        AND      lookup_code     = p_lookup_code;
--
v_description       varchar2(80) := NULL;
--
BEGIN
--
-- Only open the cursor if the parameters are going to retrieve anything
--
IF p_lookup_code IS  NOT NULL THEN
  --
  OPEN  csr_lookup;
  FETCH  csr_lookup INTO  v_description;
  CLOSE  csr_lookup;
  --
END IF ;
--
RETURN  v_description;
--
END  get_acc_length;


--******************************************************************************
--* This function will validate the IBAN account number.
--******************************************************************************

FUNCTION validate_iban_acc
(
  p_account_number IN varchar2
) RETURN NUMBER IS

l_max_acc_length    NUMBER := 34;
l_account_length    NUMBER ;
l_val_digit         NUMBER := 9;
l_acc_in_new_format VARCHAR2 (34);
l_trans_acc         VARCHAR2 (70);
l_trans_acc_num     NUMBER ;
l_trnc_acc_mod_97   NUMBER ;
l_regen_acc         NUMBER ;
BEGIN
l_account_length := LENGTH(p_account_number);
-- Validate the length of the account
   IF l_account_length > l_max_acc_length THEN
      RETURN 1;
   END IF;

   --Validate the lenght and 1st 2 characters of IBAN account

    IF NVL(get_acc_length(substr(p_account_number,1,2)), 1) <> l_account_length then
      RETURN 1;
    END IF;


--- validating the format OF the account
   IF TRANSLATE(p_account_number,  'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                        '999999999999999999999999999999999999')
                <>       RPAD(l_val_digit, l_account_length, '9') THEN
      RETURN 1;
   END IF;

--- validating first 2 digits of account

   IF TRANSLATE(substr(p_account_number, 1, 2), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
			 '99999999999999999999999999')
			<> '99' THEN
      RETURN 1;
   END IF;

--- Validating the 3 and 4 digit for Iban

   IF substr(p_account_number, 3, 1) NOT IN(0,1,2,3,4,5,6,7,8,9)  THEN
	RETURN 1;

   ELSIF substr(p_account_number, 4, 1) NOT IN(0,1,2,3,4,5,6,7,8,9)  THEN
	 RETURN 1;
   END IF;
   --- new format the forst 4 digit placed at the end
   l_acc_in_new_format := SUBSTR(p_account_number, 5, l_account_length) || SUBSTR(p_account_number, 1, 4);

   l_trans_acc := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
             REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_acc_in_new_format,
             'A', '10'), 'B', '11'), 'C', '12'), 'D', '13'), 'E', '14'),
             'F', '15'), 'G', '16'), 'H', '17'),'I', '18'), 'J', '19'),
             'K', '20'), 'L', '21'), 'M', '22'), 'N', '23'), 'O', '24'),
             'P', '25'), 'Q', '26'), 'R', '27'), 'S', '28'), 'T', '29'),
             'U', '30'), 'V', '31'), 'W', '32'), 'X', '33'), 'Y', '34'),
             'Z', '35');

   begin
    l_trans_acc_num  :=  TO_NUMBER(l_trans_acc);

   exception
      WHEN OTHERS then
        RETURN 1;
   END;

     l_trnc_acc_mod_97 := trunc((l_trans_acc_num-1)/97);
     l_regen_acc  := l_trnc_acc_mod_97 * 97;
   --
--   IF l_mod <> 1 THEN
   IF l_regen_acc <> l_trans_acc_num-1 then
      RETURN 1;
   END IF;

RETURN 0;
END validate_iban_acc;

END IBAN_VALIDATION_PKG;


/
