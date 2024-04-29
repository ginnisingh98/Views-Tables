--------------------------------------------------------
--  DDL for Package Body HR_SG_BANK_ACCT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SG_BANK_ACCT_VALIDATION" AS
/* $Header: pesgavbk.pkb 115.2 2002/09/27 03:26:50 jkarouza noship $ */
/* ==============================================================================
 * Name        : hr_sg_bank_acct_validation  (BODY)
 *
 * Description : This package to validates SG bank accounts for the following
 *               banks.
 *                 Bank of Singapore (Bank Code: 7117)
 *                 Hong Kong and Shanghai Banking Corporation (Bank Code: 7232)
 *                 Overseas Chinese Banking Corporation (Bank Code: 7339)
 *                 UCO Bank (Bank Code: 7357)
 *                 Malayan Banking Berhad (Bank Code: 7302)
 *
 *
 * Change List
 * -----------
 *
 * Version Date      Author             Bug No.   Description of Change
 * -------+---------+------------------+---------+-------------------------------
 * 115.0   30-May-02 John Karouzakis              Created
 * 115.1   11-Jun-02 John Karouzakis              Made GSCC compliant.
 * 115.2   24-Sep-02 John Karouzakis    2590076   Changed to allow 7-digit Account Numbers
 *                                                for BOS,HSBC and OCBC
 *
 * ============================================================================== */

  /* Returns 'FALSE' if Account Number is invalid for given Bank, otherwise will
     return TRUE. */

  FUNCTION validate_account (
            		     p_account_number	IN	VARCHAR2,
			     p_bank_name      	IN	VARCHAR2
                  	    )
  RETURN VARCHAR2 IS

  validation_failed	EXCEPTION;

  l_bank_code		VARCHAR2(4);
  l_return		VARCHAR2(5) := 'FALSE';

  CURSOR get_bank_code(p_bank_name VARCHAR2) IS
	 Select meaning
	 From   hr_lookups
	 Where  lookup_type = 'SG_BANK_CODE'
	 And    lookup_code = p_bank_name
	 And    application_id = 800
         And    enabled_flag = 'Y';


  BEGIN

	-- Check for valid parameters

	IF (p_bank_name is NULL) or (p_account_number is NULL)
	THEN
	    RAISE validation_failed;
	END IF;


	-- Get bank code from HR_LOOKUPS

	OPEN get_bank_code (p_bank_name);
	FETCH get_bank_code
	 INTO l_bank_code;

	IF (get_bank_code%NOTFOUND)
	THEN
	    RAISE validation_failed;
	END IF;


	-- Check that Account Number is the correct length for given bank.

        -- Validate Account Numbers for BOS, HSBC and OCBC. Must be at least 4 digits.
	IF (l_bank_code = '7117') or
	   (l_bank_code = '7232') or
	   (l_bank_code = '7339')
	THEN
	    IF (length(p_account_number) < 4)
	    THEN
		RAISE validation_failed;
	    END IF;
	END IF;


        -- Validate Account Numbers for UCO. Must be 12-digits
	IF (l_bank_code = '7357')
	THEN
	    IF (length(p_account_number) <> 12)
	    THEN
		RAISE validation_failed;
	    END IF;
	END IF;


        -- Validate Account Numbers for MBB. Must be 11-digits
	IF (l_bank_code = '7302')
	THEN
	    IF (length(p_account_number) <> 11)
	    THEN
		RAISE validation_failed;
	    END IF;
	END IF;

  	CLOSE get_bank_code;

        -- Must have passed all rules or not one of the banks to check.

        l_return := 'TRUE';
        RETURN l_return;

  EXCEPTION
	WHEN validation_failed THEN
                RETURN l_return;
	WHEN others THEN
                RETURN l_return;
  END validate_account;

END hr_sg_bank_acct_validation;

/
