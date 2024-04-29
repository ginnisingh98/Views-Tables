--------------------------------------------------------
--  DDL for Package HR_NZ_BANK_ACCT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_BANK_ACCT_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: penzavbk.pkh 120.0.12010000.1 2008/07/28 05:03:52 appldev ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                     Brisbane, Australia.                       *
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
 Name        : hr_nz_bank_acct_validation  (HEADER)

 Description : This package declares a function  to validate
               NZ bank accounts.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 110.0   14-May-99 pmcdonal             Created

 ================================================================= */

  FUNCTION validate_acct (
			p_bank_branch_number	IN VARCHAR2,
			p_account_number	IN VARCHAR2,
			p_account_suffix	IN VARCHAR2
		  	)
  RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(validate_acct, WNDS);

  END hr_nz_bank_acct_validation;

/
