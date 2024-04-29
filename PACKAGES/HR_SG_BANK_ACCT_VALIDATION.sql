--------------------------------------------------------
--  DDL for Package HR_SG_BANK_ACCT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_BANK_ACCT_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: pesgavbk.pkh 115.1 2002/06/11 20:13:57 pkm ship        $ */
/* ===========================================================================
 * Name        : hr_sg_bank_acct_validation  (HEADER)
 *
 * Description : This package declares a function to validate SG bank accounts.
 *               for certain banks.
 *
 * Change List
 * -----------
 *
 * Version Date      Author             ER/CR No. Description of Change
 * -------+---------+------------------+---------+-------------------------------
 * 115.0   30-May-02 John Karouzakis              Created
 * 115.1   11-Jun-02 John Karouzakis              Made GSCC compliant
 *
 * ============================================================================== */

  FUNCTION validate_account (
			    p_account_number	IN VARCHAR2,
			    p_bank_name     	IN VARCHAR2
		  	    )
  RETURN VARCHAR2;

  END hr_sg_bank_acct_validation;

 

/
