--------------------------------------------------------
--  DDL for Package Body IT_BANK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IT_BANK_DETAILS_PKG" AS
 -- $Header: peitbank.pkb 120.2.12010000.2 2008/09/17 07:16:46 rbabla ship $
 --
 --
 -- Validates the bank account number.
 --
 -- The format is as follows CIN-ABI-CAB-Acc where
 --
 -- CIN = check digit
 -- ABI = 5 digits representing the bank
 -- CAB = 5 digits representing the branch
 -- Acc = up to 12 characters representing the account no
 --
FUNCTION validate_iban_acc
( p_account_number IN varchar2
) RETURN NUMBER IS

l_max_acc_length    NUMBER := 34;
l_account_length    number;
l_val_digit         NUMBER := 9;
l_acc_in_new_format varchar2(34);
l_trans_acc         varchar2(70);
l_trans_acc_num     number;
l_trnc_acc_mod_97   number;
l_regen_acc         number;
BEGIN
l_account_length := LENGTH(p_account_number);
-- Validate the length of the account
   IF l_account_length > l_max_acc_length THEN
      RETURN 1;
   END IF;
--Validate the lenght of IT IBAN account
   IF substr(p_account_number,1,2)='IT' AND l_account_length <> 27 THEN
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


FUNCTION validate_non_iban_acc
(p_account_number IN VARCHAR2) RETURN NUMBER IS
  --
  TYPE OddTransform   IS TABLE OF NUMBER;
  TYPE EvenTransform  IS TABLE OF NUMBER;
  TYPE TransAlgorithm IS TABLE OF VARCHAR2(1);
  --
  oddtable OddTransform := OddTransform(1,0,5,7,9,13,15,17,19,21,2,4,18,20,11,3,6,8,
                                        12,14,16,10,22,25,24,23,27,28,26);
  eventable EvenTransform := EvenTransform(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,
                                           17,18,19,20,21,22,23,24,25,26,27,28);
  transtable TransAlgorithm := TransAlgorithm('A','B','C','D','E','F','G','H','I','J',
                                              'K','L','M','N','O','P','Q','R','S','T',
                                              'U','V','W','X','Y','Z','-','.',' ');
  --
  check_digit        VARCHAR2(1);
  new_account_number VARCHAR2(23);
  new_account_length NUMBER;
  acc_pos            NUMBER;
  acc_char           VARCHAR2(1);
  convert_value      NUMBER;
  convert_total      NUMBER;
  trans_pos          NUMBER;
  calc_rem           NUMBER;
  calc_check_digit   VARCHAR2(1);
BEGIN
  --
  --
  -- Minimum account no length is 15 characters.
  --
  IF LENGTH(p_account_number) < 15 THEN
    RETURN 1;
  END IF;
  --
  --
  -- Check separators exist at the correct places within the account no.
  --
  IF SUBSTR(p_account_number,2,1) <> '-' THEN
    RETURN 1;
  END IF;
  IF SUBSTR(p_account_number,8,1) <> '-' THEN
    RETURN 1;
  END IF;
  IF SUBSTR(p_account_number,14,1) <> '-' THEN
    RETURN 1;
  END IF;
  --
  --
  -- Ensure the ABI consists only of digits.
  --
  IF SUBSTR(p_account_number,3,1) < '0' OR SUBSTR(p_account_number,3,1) > '9' or
     SUBSTR(p_account_number,4,1) < '0' OR SUBSTR(p_account_number,4,1) > '9' or
     SUBSTR(p_account_number,5,1) < '0' OR SUBSTR(p_account_number,5,1) > '9' or
     SUBSTR(p_account_number,6,1) < '0' OR SUBSTR(p_account_number,6,1) > '9' or
     SUBSTR(p_account_number,7,1) < '0' OR SUBSTR(p_account_number,7,1) > '9' THEN
       RETURN 1;
  END IF;
  --
  --
  -- Ensure the CAB consists only of digits.
  --
  IF SUBSTR(p_account_number,9,1) < '0' OR SUBSTR(p_account_number,9,1) > '9' or
     SUBSTR(p_account_number,10,1) < '0' OR SUBSTR(p_account_number,10,1) > '9' or
     SUBSTR(p_account_number,11,1) < '0' OR SUBSTR(p_account_number,11,1) > '9' or
     SUBSTR(p_account_number,12,1) < '0' OR SUBSTR(p_account_number,12,1) > '9' or
     SUBSTR(p_account_number,13,1) < '0' OR SUBSTR(p_account_number,13,1) > '9' THEN
       RETURN 1;
  END IF;
  --
  --
  -- CIN must be a letter from A to Z.
  --
  check_digit := SUBSTR(p_account_number,1,1);
  IF check_digit < 'A' OR check_digit > 'Z' THEN
    RETURN 1;
  END IF;
  --
  --
  -- Remove the separators and re-combine the account no.
  --
  new_account_number := SUBSTR(p_account_number,3,5)||
                        SUBSTR(p_account_number,9,5)||
                        SUBSTR(p_account_number,15,12);
  --
  --
  -- Transform each character in the account to a value based on its position i.e. odd or even using
  -- separate odd and even transforms. Total them all up into a single figure. Divide this by 26 and
  -- then use the remainder in a further transform to derive the check digit.
  --
  new_account_length := length(new_account_number);
  convert_total := 0;
  for acc_pos in 1..22
  LOOP
    IF acc_pos > new_account_length THEN
      acc_char := ' ';
    ELSE
      acc_char := SUBSTR(new_account_number,acc_pos,1);
    END IF;
    IF (acc_pos MOD 2) > 0 THEN
      IF acc_char < '0' OR acc_char > '9' THEN
        trans_pos := 0;
        LOOP
          trans_pos := trans_pos + 1;
          IF trans_pos > 29 THEN
            RETURN 1;
            EXIT;
          END IF;
          IF transtable(trans_pos) = acc_char THEN
            convert_value := oddtable(trans_pos);
            EXIT;
          END IF;
        END LOOP;
      ELSE
        convert_value := oddtable(TO_NUMBER(acc_char)+1);
      END IF;
    ELSE
      IF acc_char < '0' OR acc_char > '9' THEN
        trans_pos := 0;
        LOOP
          trans_pos := trans_pos + 1;
          IF trans_pos > 29 THEN
            RETURN 1;
            EXIT;
          END IF;
          IF transtable(trans_pos) = acc_char THEN
            convert_value := eventable(trans_pos);
            EXIT;
          END IF;
        END LOOP;
      ELSE
        convert_value := eventable(TO_NUMBER(acc_char)+1);
      END IF;
    END IF;
    convert_total := convert_total + convert_value;
  END LOOP;
  calc_rem := convert_total MOD 26;
  calc_check_digit := transtable(calc_rem + 1);
  IF calc_check_digit <> check_digit THEN
    RETURN 1;
  END IF;
  RETURN 0;
END validate_non_iban_acc;


FUNCTION validate_account_number
 ( p_account_number IN VARCHAR2
 , p_is_iban_acc    IN varchar2) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
 -- hr_utility.trace_on(null,'ITACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_account_number ' || p_account_number,1);

  IF (p_account_number IS NOT NULL AND p_is_iban_acc = 'N') then
    l_ret := validate_non_iban_acc(p_account_number);
    hr_utility.set_location('l_ret ' || l_ret,1);
    RETURN l_ret;
  ELSIF (p_account_number IS NOT NULL AND p_is_iban_acc = 'Y') then
    l_ret := validate_iban_acc(p_account_number);
    hr_utility.set_location('l_ret ' || l_ret,3);
    RETURN l_ret;
  ELSIF (p_account_number IS NULL AND p_is_iban_acc IS NULL) then
    hr_utility.set_location('Both Account Nos Null',4);
    RETURN 1;
  ELSE
    hr_utility.set_location('l_ret: 3 ' ,5);
    RETURN 3;
    /*Changed for Bug 7028494 as changes done in default value of segments so that cross
      validation rules are fired properly in self service pages */
  END if;


 END validate_account_number;


END it_bank_details_pkg;

/
