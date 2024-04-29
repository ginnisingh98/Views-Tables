--------------------------------------------------------
--  DDL for Package Body HR_AU_PER_PAY_METHOD_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_PER_PAY_METHOD_LEG_HOOK" AS
/* $Header: peaulhpp.pkb 120.0.12000000.1 2007/08/17 10:48:39 vamittal noship $ */
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
	Filename: hraulhpp.pkb (BODY)
        Author: Varun Mittal
 	Description: Creates the user hook seed data for the AU legislation
                     validation in HR_PERSONAL_PAYMENT_METHOD_API.

 	Change List
 	-----------

 	Version Date      Author     ER/CR No. Description of Change
 	-------+---------+-----------+---------+--------------------------
         115.0   6-Aug-07  vamittal   6315194   Initial Version

 ================================================================= */
  --
  -- Package Variables
  --
  g_package  VARCHAR2(33) := 'HR_AU_PER_PAY_METHOD_LEG_HOOK.';
  g_debug    boolean;

  PROCEDURE VALIDATE_BANK_ACCT 	(p_segment2	IN VARCHAR2) IS

  l_proc        VARCHAR2(72) := g_package||'VALIDATE_BANK_ACCT';
  l_validate	VARCHAR2(5);

  BEGIN

    g_debug := hr_utility.debug_enabled;

     IF g_debug THEN
         hr_utility.set_location('Entering:'|| l_proc, 10);
     END if;


    IF ((p_segment2 IS NULL) OR (p_segment2 = hr_api.g_varchar2))
        THEN
         IF g_debug THEN
         hr_utility.trace('Invalid value passed for the segments. No validation');
         END if;

    ELSE
	l_validate := HR_AU_BANK_ACCT_VALIDATION.VALIDATE_ACC_NUM(p_segment2);
        IF (l_validate <> 'TRUE')
       	THEN
          -- Bank/Acct Number is not valid
           hr_utility.set_message(801, 'HR_AU_INVALID_BANK_DETAILS');
           hr_utility.raise_error;
        END IF;
    END IF;

     IF g_debug THEN
         hr_utility.set_location('Leaving:'|| l_proc, 10);
     END if;

  END VALIDATE_BANK_ACCT;
END HR_AU_PER_PAY_METHOD_LEG_HOOK;

/
