--------------------------------------------------------
--  DDL for Package Body HR_NZ_BANK_ACCT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_BANK_ACCT_VALIDATION" AS
/* $Header: penzavbk.pkb 120.0.12010000.4 2008/08/06 09:17:42 ubhat ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                   Brisbane, Australia.                         *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation          *
 *  Australia Ltd,.                                               *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_nz_bank_acct_validation  (BODY)

 Description : This package declares a function  to validate
               NZ bank accounts.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 110.0   14-May-99 pmcdonal             Created
 115.2   26-Jul-02 shoskatt   2466116   Validation of KiwiBank
 115.3   26-Jul-02 shoskatt   2466116   Validation has been corrected
 115.4   07-Aug-02 shoskatt   2501581   Cursor closed
 115.5   20-Aug-02 nanuradh   2483154   KiwiBank(38) account no validation
 115.6   21-Aug-02 nanuradh   2483154   Kiwibank Branch number validation
 115.9   28-FEB-08 mdubasi    6819926   Branch Number Validations
 ================================================================= */


  ------------------------------------------------------------
  -- Private Procedures
  ------------------------------------------------------------


  ------------------------------------------------------------
  --  Private Functions
  ------------------------------------------------------------


  -- Function to validate the Bank/Account number for banks:
  -- 01,02,03,06,11,12,13,14,15,16,17,18,19,20,21,22,23,24,27,30,35,38
  -- Returns FALSE if Bank/Account checksum calculates correctly

  FUNCTION validate_std	(
			p_bank_number    	IN VARCHAR2,
			p_branch_number   	IN VARCHAR2,
			p_account_number	IN VARCHAR2,
			p_account_suffix	IN VARCHAR2
			)
  RETURN BOOLEAN IS
	l_result NUMBER;
	l_return BOOLEAN := TRUE;
  BEGIN

	IF (TO_NUMBER(p_account_number) > 990000 AND TO_NUMBER(p_account_number) < 99999999)
	THEN
		l_result  := 	to_number(substr(p_account_number,3,1)) * 10 +
            			to_number(substr(p_account_number,4,1)) * 5 +
        			to_number(substr(p_account_number,5,1)) * 8 +
				to_number(substr(p_account_number,6,1)) * 4 +
				to_number(substr(p_account_number,7,1)) * 2 +
				to_number(substr(p_account_number,8,1)) * 1;

 		IF (mod(l_result,11) = 0)
		THEN
			l_return := FALSE;
  		END IF;
	ELSE
		l_result  :=   	to_number(substr(p_branch_number, 1,1)) * 6 +
        	    		to_number(substr(p_branch_number, 2,1)) * 3 +
            			to_number(substr(p_branch_number, 3,1)) * 7 +
            			to_number(substr(p_branch_number, 4,1)) * 9 +
            			to_number(substr(p_account_number,3,1)) * 10 +
            			to_number(substr(p_account_number,4,1)) * 5 +
        			to_number(substr(p_account_number,5,1)) * 8 +
				to_number(substr(p_account_number,6,1)) * 4 +
				to_number(substr(p_account_number,7,1)) * 2 +
				to_number(substr(p_account_number,8,1)) * 1;

  		IF (mod(l_result,11) = 0)
		THEN
			l_return := FALSE;
  		END IF;
	END IF;
	RETURN l_return;
  END validate_std;


  -- Function to validate the Bank/Account number for banks:
  -- 08
  -- Returns FALSE if Bank/Account checksum calculates correctly

  FUNCTION validate_08	(
			p_bank_number    	IN VARCHAR2,
			p_branch_number   	IN VARCHAR2,
			p_account_number	IN VARCHAR2,
			p_account_suffix	IN VARCHAR2
			)
  RETURN BOOLEAN IS
  	l_result NUMBER;
  	l_return BOOLEAN := TRUE;

  BEGIN
	l_result  :=   	to_number(substr(p_account_number,2,1)) * 7 +
       			to_number(substr(p_account_number,3,1)) * 6 +
       			to_number(substr(p_account_number,4,1)) * 5 +
      			to_number(substr(p_account_number,5,1)) * 4 +
			to_number(substr(p_account_number,6,1)) * 3 +
			to_number(substr(p_account_number,7,1)) * 2 +
			to_number(substr(p_account_number,8,1)) * 1;

	IF (mod(l_result,11) = 0)
	THEN
		l_return := FALSE;
	END IF;
  	RETURN l_return;
  END validate_08;

  -- Function to validate the Bank/Account number for banks:
  -- 09
  -- Returns FALSE if Bank/Account checksum calculates correctly

  FUNCTION validate_09	(
			p_bank_number    	IN VARCHAR2,
			p_branch_number  	IN VARCHAR2,
			p_account_number	IN VARCHAR2,
			p_account_suffix	IN VARCHAR2
			)
  RETURN BOOLEAN IS
  	l_result 	NUMBER;
  	l_return 	BOOLEAN 	:= TRUE;
	l_acc		NUMBER 		:= 0;
  BEGIN

      	l_result  := to_number(substr(p_account_number,5,1)) * 5;
 	IF (l_result > 9)
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	END IF;
	l_acc := l_acc + l_result;

	l_result  := to_number(substr(p_account_number,6,1)) * 4;
	IF (l_result > 9)
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	END IF;
	l_acc := l_acc + l_result;

	l_result  := to_number(substr(p_account_number,7,1)) * 3;
	IF (l_result > 9)
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	END IF;
	l_acc := l_acc + l_result;

	l_result  := to_number(substr(p_account_number,8,1)) * 2;
	IF (l_result > 9)
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	END IF;
	l_acc := l_acc + l_result;

	l_result  := 	to_number(substr(p_account_suffix,4,1)) * 1;
	IF (l_result > 9)
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	END IF;
	l_acc := l_acc + l_result;

	IF (mod(l_acc,11) = 0)
	THEN
		l_return := FALSE;
	END IF;
 	RETURN l_return;
  END validate_09;

  -- Function to validate the Bank/Account number for banks:
  -- 25,33
  -- Returns FALSE if Bank/Account checksum calculates correctly

  FUNCTION validate_25_33 (
			p_bank_number    	IN VARCHAR2,
			p_branch_number   	IN VARCHAR2,
			p_account_number	IN VARCHAR2,
			p_account_suffix	IN VARCHAR2
			)
  RETURN BOOLEAN IS
  	l_result NUMBER;
  	l_return BOOLEAN := TRUE;
  BEGIN
	l_result  :=   	to_number(substr(p_account_number,2,1)) * 1 +
       			to_number(substr(p_account_number,3,1)) * 7 +
       			to_number(substr(p_account_number,4,1)) * 3 +
      			to_number(substr(p_account_number,5,1)) * 1 +
			to_number(substr(p_account_number,6,1)) * 7 +
			to_number(substr(p_account_number,7,1)) * 3 +
			to_number(substr(p_account_number,8,1)) * 1;

	IF (mod(l_result,10) = 0)
	THEN
		l_return := FALSE;
	END IF;
  	RETURN l_return;
  END validate_25_33;

  -- Function to validate the Bank/Account number for banks:
  -- 26,28 and 29
  -- Returns FALSE if Bank/Account checksum calculates correctly

  FUNCTION validate_29	(
			p_bank_number    	IN VARCHAR2,
			p_branch_number   	IN VARCHAR2,
			p_account_number	IN VARCHAR2,
			p_account_suffix	IN VARCHAR2
			)
  RETURN BOOLEAN IS
  	l_result NUMBER;
  	l_return BOOLEAN := TRUE;
	l_acc	NUMBER := 0;
  BEGIN
	-- First Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,2,1)) * 1;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Second Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,3,1)) * 3;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Third Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,4,1)) * 7;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Fourth Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,5,1)) * 1;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Fifth Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,6,1)) * 3;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Sixth Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,7,1)) * 7;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Seventh Digit of the Account Number
      	l_result  := to_number(substr(p_account_number,8,1)) * 1;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- First Digit of the Suffix
      	l_result  := to_number(substr(p_account_suffix,2,1)) * 3;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Second Digit of the Suffix
      	l_result  := to_number(substr(p_account_suffix,3,1)) * 7;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 2 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	-- Third Digit of the Suffix
      	l_result  := to_number(substr(p_account_suffix,4,1)) * 1;
 	IF (l_result > 9) /* Iteration 1 */
	THEN
		l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
	 	IF (l_result > 9) /* Iteration 1 */
		THEN
			l_result := to_number(substr(to_char(l_result),1,1)) + to_number(substr(to_char(l_result),2,1));
		END IF;
	END IF;
	l_acc := l_acc + l_result;

	IF (mod(l_acc,10) = 0)
	THEN
		l_return := FALSE;
	END IF;
 	RETURN l_return;
  END validate_29;

/* Bug 6819926 starts */

 -- Function to validate the Branch numbers for all the banks

  -- Returns FALSE if Branch Number is valid for the respective Bank IDS

    FUNCTION validate_branch(p_bank_no IN VARCHAR2,p_branch_no IN VARCHAR2)
    RETURN BOOLEAN is
    l_return boolean := TRUE;
    BEGIN
    IF(p_bank_no = '01')
    THEN
       IF(((to_number(p_branch_no) >= 0001) and (to_number(p_branch_no) <= 0999)) or
         ((to_number(p_branch_no) >= 1100) and (to_number(p_branch_no) <= 1199)) or
         ((to_number(p_branch_no) >= 1800) and (to_number(p_branch_no) <= 1899)) )
       THEN
          l_return := FALSE;
       END IF;
   ELSIF (p_bank_no = '02')
   THEN
      IF (((to_number(p_branch_no) >= 0001) and (to_number(p_branch_no) <= 0999)) or
         ((to_number(p_branch_no) >= 1200) and (to_number(p_branch_no) <= 1299)) )
      THEN
         l_return := FALSE;
      END IF;
   ELSIF (p_bank_no = '03')
   THEN
       IF(((to_number(p_branch_no) >= 0001) and (to_number(p_branch_no) <= 0999)) or
         ((to_number(p_branch_no) >= 1300) and (to_number(p_branch_no) <= 1399)) or
         ((to_number(p_branch_no) >= 1500) and (to_number(p_branch_no) <= 1599)) or
         ((to_number(p_branch_no) >= 1700) and (to_number(p_branch_no) <= 1799)))
       THEN
         l_return := FALSE;
       END IF;
   ELSIF (p_bank_no = '06')
   THEN
       IF(((to_number(p_branch_no) >= 0001) and (to_number(p_branch_no) <= 0999)) or
         ((to_number(p_branch_no) >= 1400) and (to_number(p_branch_no) <= 1499)))
       THEN
           l_return := FALSE;
       END IF;
   ELSIF (p_bank_no = '08')
   THEN
       IF((to_number(p_branch_no) >= 6500) and (to_number(p_branch_no) <= 6599))
       THEN
          l_return := FALSE;
       END IF;
   ELSIF(p_bank_no = '09')
   THEN
       IF(to_number(p_branch_no)=0000)
       THEN
          l_return := FALSE;
       END IF;
   ELSIF(p_bank_no='11')
   THEN
       IF(((to_number(p_branch_no) >= 5000) and (to_number(p_branch_no) <= 6499)) or
         ((to_number(p_branch_no) >= 6600) and (to_number(p_branch_no) <= 8999)))
       THEN
           l_return := FALSE;
       END IF;
  ELSIF(p_bank_no = '12')
  THEN
       IF(((to_number(p_branch_no) >= 3000) and (to_number(p_branch_no) <= 3299)) or
         ((to_number(p_branch_no) >= 3400) and (to_number(p_branch_no) <= 3499)) or
         ((to_number(p_branch_no) >= 3600) and (to_number(p_branch_no) <= 3699)) )
       THEN
          l_return := FALSE;
       END IF;
  ELSIF(p_bank_no = '13')
  THEN
     IF((to_number(p_branch_no) >= 4900) and (to_number(p_branch_no) <= 4999))
     THEN
         l_return := FALSE;
    END IF;
  ELSIF(p_bank_no = '14')
  THEN
      IF((to_number(p_branch_no) >= 4700) and (to_number(p_branch_no) <= 4799))
       THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '15')
  THEN
      IF((to_number(p_branch_no) >= 3900) and (to_number(p_branch_no) <= 3999))
      THEN
          l_return := FALSE;
     END IF;
  ELSIF(p_bank_no = '16')
  THEN
     IF((to_number(p_branch_no) >= 4400) and (to_number(p_branch_no) <= 4499))
     THEN
          l_return := FALSE;
     END IF;
  ELSIF(p_bank_no = '17')
  THEN
      IF((to_number(p_branch_no) >= 3300) and (to_number(p_branch_no) <= 3399))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '18')
  THEN
      IF((to_number(p_branch_no) >= 3500) and (to_number(p_branch_no) <= 3599))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '19')
  THEN
      IF((to_number(p_branch_no) >= 4600) and (to_number(p_branch_no) <= 4649))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '20')
  THEN
      IF((to_number(p_branch_no) >= 4100) and (to_number(p_branch_no) <= 4199))
      THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '21')
  THEN
      IF((to_number(p_branch_no) >= 4800) and (to_number(p_branch_no) <= 4899))
      THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '22')
  THEN
      IF((to_number(p_branch_no) >= 4000) and (to_number(p_branch_no) <= 4049))
      THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '23')
  THEN
      IF((to_number(p_branch_no) >= 3700) and (to_number(p_branch_no) <= 3799))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '24')
  THEN
      IF((to_number(p_branch_no) >= 4300) and (to_number(p_branch_no) <= 4349))
      THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '25')
  THEN
      IF((to_number(p_branch_no) >= 2500) and (to_number(p_branch_no) <= 2599))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '26')
  THEN
      IF((to_number(p_branch_no) >= 2600) and (to_number(p_branch_no) <= 2699))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '27')
  THEN
      IF((to_number(p_branch_no) >= 3800) and (to_number(p_branch_no) <= 3849))
      THEN
           l_return := FALSE;
      END IF;
      ELSIF(p_bank_no = '28')
  THEN
      IF((to_number(p_branch_no) >= 2100) and (to_number(p_branch_no) <= 2149))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '29')
  THEN
      IF((to_number(p_branch_no) >= 2150) and (to_number(p_branch_no) <= 2299))
       THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no ='30')
  THEN
      IF((to_number(p_branch_no) >= 2900) and (to_number(p_branch_no) <= 2949))
      THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no ='31')
  THEN
      IF((to_number(p_branch_no) >= 2800) and (to_number(p_branch_no) <= 2849))
      THEN
           l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '33')
  THEN
      IF((to_number(p_branch_no) >= 6700) and (to_number(p_branch_no) <= 6799))
      THEN
          l_return := FALSE;
      END IF;
      ELSIF(p_bank_no = '35')
  THEN
      IF((to_number(p_branch_no) >= 2400) and (to_number(p_branch_no) <= 2499))
      THEN
          l_return := FALSE;
      END IF;
  ELSIF(p_bank_no = '38')
  THEN
     IF((to_number(p_branch_no) >= 9000) and (to_number(p_branch_no) <= 9499))
     THEN
          l_return := FALSE;
     END IF;
  END IF;
      RETURN l_return;
END validate_branch;



  ------------------------------------------------------------
  --  Private Cursors
  ------------------------------------------------------------




 ------------------------------------------------------------
 --  Public Functions
 ------------------------------------------------------------

  -- Main Entry point to the Bank/Account number validation function
  -- Calculates the checksums for all known NZ bank/account combinations
  -- Returns TRUE if Bank/Account checksum calculates correctly

  FUNCTION validate_acct (
  			p_bank_branch_number		IN	VARCHAR2,
           		p_account_number		IN	VARCHAR2,
			p_account_suffix		IN	VARCHAR2
                  	)
  RETURN VARCHAR2 IS

  validation_failed	EXCEPTION;

  CURSOR bank_cursor(p_bank_no VARCHAR2) IS
	SELECT MEANING
	FROM HR_LOOKUPS
	WHERE LOOKUP_TYPE = 'NZ_BANK' AND
	      LOOKUP_CODE = p_bank_no AND
		  ENABLED_FLAG = 'Y';

  	l_bank_no	VARCHAR2(2);
  	l_bank_name	VARCHAR2(80);
	l_branch_no	VARCHAR2(6);
 	l_acct_no	VARCHAR2(8);
  	l_acct_suffix	VARCHAR2(4);
  	l_return	VARCHAR2(5) := 'FALSE';

  BEGIN

	-- Check for valid parameters

	l_bank_no   := substr(p_bank_branch_number,1,2);
	/*Bug 6819926*/
	--To pad the branch number,account number and suffix with zeros
	l_branch_no := lpad(substr(p_bank_branch_number,3),4,0);
	l_acct_no := lpad(p_account_number,8,0);
	l_acct_suffix := lpad(p_account_suffix,4,0);


        OPEN bank_cursor (l_bank_no);
	FETCH bank_cursor INTO l_bank_name;
	IF (bank_cursor%NOTFOUND)
	THEN
		RAISE validation_failed;
	END IF;
        CLOSE bank_cursor; /* Bug 2501851 */


         --Validating Branch Number
	 /*Bug 6819926*/
         IF(validate_branch(l_bank_no,l_branch_no))
         THEN
         RAISE validation_failed;
         END IF;



	IF (p_account_suffix is NULL)
	THEN
		RAISE validation_failed;
	END IF;

	-- These accounts are always valid

	IF (to_number(l_acct_no) NOT IN ('0998800','0998907','0999993','9999977','9999985','9999993','9999999'))
	THEN


		-- Select the correct validation routine for the bank

		IF (l_bank_no = '08')
		THEN
			IF (validate_08(l_bank_no, l_branch_no, l_acct_no, p_account_suffix))
			THEN
				RAISE validation_failed;
			END IF;
		ELSIF (l_bank_no = '09')
		THEN
			IF (validate_09(l_bank_no, l_branch_no, l_acct_no, p_account_suffix))
			THEN
				RAISE validation_failed;
			END IF;
		ELSIF (l_bank_no = '25' OR l_bank_no = '33')
		THEN
			IF (validate_25_33(l_bank_no, l_branch_no, l_acct_no, p_account_suffix))
			THEN
				RAISE validation_failed;
			END IF;
		ELSIF (l_bank_no = '26' OR l_bank_no = '28' OR l_bank_no = '29') /*Bug 6819926*/
		THEN
			IF (validate_29(l_bank_no, l_branch_no, l_acct_no, p_account_suffix))
			THEN
				RAISE validation_failed;
			END IF;
		ELSIF (l_bank_no = '31')    /*Bug 6819926*/
		THEN
			l_return := 'TRUE';

		ELSE
			IF (validate_std(l_bank_no, l_branch_no, l_acct_no, p_account_suffix))
			THEN
				RAISE validation_failed;
			END IF;
		END IF;
	END IF;

	-- Must have passed all rules

	l_return := 'TRUE';
	RETURN l_return;

  EXCEPTION
	WHEN validation_failed THEN
                RETURN l_return;
	WHEN others THEN
                RETURN l_return;
  END validate_acct;

END hr_nz_bank_acct_validation;

/
