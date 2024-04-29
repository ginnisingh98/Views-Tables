--------------------------------------------------------
--  DDL for Package Body PAY_US_PDT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PDT_VALIDATE" AS
/* $Header: pypdtuvd.pkb 115.0 99/07/17 06:21:30 porting ship $ */
--
--
 /*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_pdt_validate

    Description : This package contains the procedure validate_business_rules,
                  which is used for user_defined validation.  The procedure
                  is called from the PayMIX package.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    11-MAR-96   RAMURTHY       1.0    345572     Created.

*/

--
--  Procedure
--     validate_business_rules
--
--  Purpose
--     Carry out user-defined business rule validation on current batch line.
--
--  Arguments
--     p_batch_type                     Batch Type
--     p_process_mode                   Process Mode
--     p_batch_id                       Batch id
--     p_line_id                        Line id
--     p_period_start_date              Start of period for this line
--     p_period_end_date                End of period for this line
--     p_num_inp_values                 Number of iv's
--     p_line_status                    Line status
--     p_assignment_id                  Assignment
--     p_element_type_id                Element Type id
--     p_hours_worked                   Hours
--     p_date_earned                    Date Earned
--  History
--     25th March 1994  Andy Taylor     Created.
--  Notes
--     This procedure has been defined with arguments required to do certain
--     edits. You may need to add more arguments if your business requires
--     extra validation rules.
--     Currently, there is commented out code to raise a duplicate entry
--     error, but you have you define the cursor (csr_duplicate_tc_entry)
--     that is is used.
--
PROCEDURE validate_business_rules   ( p_batch_type        IN     VARCHAR2,
                                      p_process_mode      IN     VARCHAR2,
                                      p_num_warnings      IN OUT NUMBER,
                                      p_batch_id          IN     NUMBER,
                                      p_line_id           IN     NUMBER,
                                      p_period_start_date IN     DATE,
                                      p_period_end_date   IN     DATE,
                                      p_num_inp_values    IN     NUMBER,
                                      p_line_status       IN OUT VARCHAR2,
                                      p_assignment_id     IN     NUMBER,
                                      p_element_type_id   IN     NUMBER,
                                      p_hours_worked      IN     NUMBER,
                                      p_date_earned       IN     DATE ) IS

--        l_duplicate_exists      VARCHAR2(1) := 'N';
--        l_exception_message     VARCHAR2(240);

BEGIN


--      OPEN csr_duplicate_tc_entry;
--      FETCH csr_duplicate_tc_entry INTO l_duplicate_exists;
--      CLOSE csr_duplicate_tc_entry;

--      hr_utility.trace('Duplicate Exists : '||l_duplicate_exists);

--      IF l_duplicate_exists = 'Y' THEN

         -- This entry already exists. Raise an error.

--         hr_utility.set_message(801, 'PAY_13175_PDT_DUP_TIMECARD');
--         l_exception_message := hr_utility.get_message;

--         IF NVL(p_line_status,'X') != 'E' THEN
--            p_line_status := 'E';
--         END IF;

--         write_exception_details( p_batch_id,
--                                p_process_mode,
--                                p_line_id,
--                                p_line_status,
--                                'E',
--                                'L',
--                                p_num_warnings,
--                                l_exception_message);
--      END IF;

return;
END validate_business_rules;

END pay_us_pdt_validate;

/
