--------------------------------------------------------
--  DDL for Package Body HR_NZ_PER_PAY_METHOD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_PER_PAY_METHOD_LEG_HOOK" AS
/* $Header: hrnzlhpp.pkb 115.3 2003/11/12 03:46:59 srrajago ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                     Brisbane, Australia.                       *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  the material is also     *
 *  protected by copyright law.  no part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation          *
 *  Australia Ltd,.                                               *
 *                                                                *
 ******************************************************************/

/*
	Filename: hrnzlhas.pkb (BODY)
    Author: Philip Macdonald
 	Description: Creates the user hook seed data for the HR_ASSIGNMENT_API package procedures.

 	File Information
 	================

	Note for Oracle HRMS Developers: The data defined in the
	create API calls cannot be changed once this script has
	been shipped to customers. Explicit update or delete API
	calls will need to be added to the end of the script.


 	Change List
 	-----------

 	Version Date      Author     ER/CR No. Description of Change
 	-------+---------+-----------+---------+--------------------------
 	110.0   25-Jun-99 P.Macdonald           Created
        110.1   09-Jun-99 A. Di Vincenzo        Added exit to end of script.
        110.2   12-Nov-03 R.Sree Ranjani        Bug No : 3241922 - Added an IF check before validation call.

 ================================================================= */
  --
  -- Package Variables
  --
  g_package  VARCHAR2(33) := 'hr_nz_per_pay_method_leg_hook.';

  PROCEDURE validate_bank_acct 	(p_segment1	IN VARCHAR2
								,p_segment2	IN VARCHAR2
								,p_segment3	IN VARCHAR2) IS

  l_proc        VARCHAR2(72) := g_package||'validate_bank_acct';
  l_validate	VARCHAR2(5);

  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    IF (((p_segment1 IS NULL) OR (p_segment1 = hr_api.g_varchar2)) OR
        ((p_segment2 IS NULL) OR (p_segment2 = hr_api.g_varchar2)) OR
        ((p_segment3 IS NULL) OR (p_segment3 = hr_api.g_varchar2))) THEN
        hr_utility.trace('Invalid value passed for the segments. No validation');
    ELSE
	l_validate := hr_nz_bank_acct_validation.validate_acct(p_segment1, p_segment2, p_segment3);
        IF (l_validate <> 'TRUE')
       	THEN
          -- Bank/Acct Number is not valid
           hr_utility.set_message(801, 'HR_NZ_INVALID_BANK_DETAILS');
           hr_utility.raise_error;
        END IF;
    END IF;
    hr_utility.set_location(' Leaving:'||l_proc, 20);
  END validate_bank_acct;
END hr_nz_per_pay_method_leg_hook;

/
