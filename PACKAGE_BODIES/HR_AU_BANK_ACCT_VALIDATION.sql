--------------------------------------------------------
--  DDL for Package Body HR_AU_BANK_ACCT_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_BANK_ACCT_VALIDATION" AS
/* $Header: peauavbk.pkb 120.0.12000000.1 2007/08/17 10:48:26 vamittal noship $ */
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
 Name        : HR_AU_BANK_ACCT_VALIDATION  (BODY)

 Description : This package declares a function  to validate
               AU Bank Account Number.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 115.0   03-Aug-07 vamittal             Created
 115.1   09-Aug-07 vamittal   6315194   Comment for Ascii Code is added
                                        Trace is removed.return_val is initialized with TRUE

 ================================================================= */

                            /******************************
                             Ascii Values for characters
                            *******************************

                            Characters         Ascii Value
                            ------------------------------
                             A-Z                65-90
                             a-z                97-122
                             0-9                48-57
                             <space>            32
                             hyphen              45

                            *******************************/

 g_debug                       boolean;

  FUNCTION VALIDATE_ACC_NUM(acc_num VARCHAR2)
     RETURN VARCHAR2 AS
     len                           INTEGER := 0;
     i                             INTEGER;
     asciivar                      INTEGER;
     charvar                       VARCHAR(30);
     return_val                    VARCHAR(30)   := 'TRUE';
     digit_char_count              INTEGER := 0;
     zero_count                    INTEGER := 0;
     g_debug                       boolean;
  BEGIN

     g_debug := hr_utility.debug_enabled;
     IF g_debug THEN
         hr_utility.set_location('Entering FUNCTION VALIDATE_ACC_NUM',1);
         hr_utility.set_location('In Parameter acc_num '||acc_num,1);
     END if;


     len:= LENGTH(acc_num);

     i := 1;

     WHILE(i < len + 1)
     LOOP
          asciivar := ASCII(SUBSTR(acc_num, i, 1));
          charvar := SUBSTR(acc_num, i, 1);

        IF         ((asciivar = 45)
                OR ((asciivar = 32) AND ((i > 1) AND (i < len)))
                OR ((asciivar >= 65) AND (asciivar <= 90))
                OR ((asciivar >= 97) AND (asciivar <= 122))
                OR ((asciivar >= 48) AND (asciivar <= 57)))
        THEN
             IF ( asciivar <> 32 AND asciivar <> 45)  /* id character is number of alphabet then increment counter */
             THEN
	          digit_char_count := digit_char_count + 1;
                  IF (asciivar = 48 ) /* to count number of zeros */
                  THEN
                  zero_count := zero_count + 1;
                  END IF;
             END IF;
        ELSE
             return_val := 'FALSE';
             exit;
        END IF;
        i := i + 1;

     END LOOP;
     IF ( zero_count = digit_char_count) /* if all character are zeros */
     THEN
     return_val := 'FALSE';
     END IF;

     IF g_debug THEN
         hr_utility.set_location('Leaving FUNCTION VALIDATE_ACC_NUM',1);
	 hr_utility.set_location('Retutning Value : ' || return_val,1);
     END if;

     RETURN return_val;
  END VALIDATE_ACC_NUM;

END HR_AU_BANK_ACCT_VALIDATION;

/
