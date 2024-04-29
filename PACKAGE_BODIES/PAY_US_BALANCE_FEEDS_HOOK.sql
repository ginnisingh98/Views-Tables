--------------------------------------------------------
--  DDL for Package Body PAY_US_BALANCE_FEEDS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_BALANCE_FEEDS_HOOK" AS
/* $Header: pyuspbfr.pkb 120.0 2006/03/05 22:08:37 rdhingra noship $ */
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

    Name        : PAY_US_BALANCE_FEEDS_HOOK
    File Name   : pyuspbfr.pkb

    Description : This package is called from the AFTER INSERT/UPDATE
                  User Hooks. The following are the functionalities present
                  in User Hook

                  1. Puts time_definition_type as 'G' in pay_element_types_f
		     whenever that element feeds a balance for which defined
		     balance exists with dimensions:
		     _ASG_GRE_TD_RUN
		     _ASG_GRE_TD_BD_RUN

    Change List
    -----------
    Name           Date          Version Bug      Text
    -------------- -----------   ------- -------  -----------------------------
    rdhingra       06-MAR-2006   115.0   5073515  Created

  *****************************************************************************/

-----------------------------INSERT SECTION STARTS HERE--------------------------
/******************************************************************************
   Name        : INSERT_TIMEDEF_TYPE
   Scope       : LOCAL
   Description : This procedure is called by AFTER INSERT Row Level handler
                 User Hook.
******************************************************************************/
PROCEDURE INSERT_TIMEDEF_TYPE(
                    p_effective_date    IN DATE
                   ,p_balance_type_id   IN NUMBER
                   ,p_input_value_id	IN NUMBER
                   ,p_business_group_id IN NUMBER
                   ,p_legislation_code  IN VARCHAR2
                   ) IS

-- Check if defined balance exist for given dimension names
CURSOR get_defined_bal_status( cp_balance_type_id   NUMBER
                              ,cp_business_group_id NUMBER
			     ) IS
   select 'Y'
    from dual
   where exists
               ( select 1
                   from pay_defined_balances pdb
                  where pdb.balance_type_id = cp_balance_type_id
                    and ((pdb.business_group_id IS NULL AND pdb.legislation_code = 'US') OR              -- For Seeded
                         (pdb.business_group_id = cp_business_group_id AND pdb.legislation_code IS NULL) -- For Custom
                        )
                    and exists
                             (
                              select 1
                                from pay_balance_dimensions pbd
                               where pbd.balance_dimension_id = pdb.balance_dimension_id
                                 /*Dimension names are used in place of database_item_suffix to utilize
                                   PAY_BALANCE_DIMENSIONS_UK2 index*/
				 and pbd.dimension_name in ('Assignment Within GRE Time Definition Run'
                                                           ,'Assignment Within GRE Time Definition BD Run')
                                 and pbd.legislation_code = 'US' -- Seeded Dimensions
                                 and pbd.business_group_id IS NULL
                             )
               );


 -- Get element_type_id corresponding to an input_value_id
 CURSOR get_element_type_id(cp_input_value_id    NUMBER
                           ,cp_business_group_id NUMBER
			   ,cp_effective_date    DATE
                           ) IS
   select element_type_id
     from pay_input_values_f
    where input_value_id = cp_input_value_id
      and ((business_group_id IS NULL AND legislation_code = 'US') OR              -- For Seeded
           (business_group_id = cp_business_group_id AND legislation_code IS NULL) -- For Custom
          )
      and cp_effective_date between effective_start_date and effective_end_date;

-- Declare Local Variables
lv_defined_bal_status     VARCHAR2(1);
ln_element_type_id        NUMBER;

BEGIN
   hr_utility.trace('Entering PAY_US_BALANCE_FEEDS_HOOK.INSERT_TIMEDEF_TYPE');

   /*Initialize local variables*/
   lv_defined_bal_status := 'N';
   ln_element_type_id    := NULL;

   /*Check if a valid defined_balance_id exists*/
   OPEN get_defined_bal_status( p_balance_type_id
                               ,p_business_group_id
			      );
   FETCH get_defined_bal_status INTO lv_defined_bal_status;
   IF ((get_defined_bal_status%NOTFOUND) OR (lv_defined_bal_status = 'N')) THEN
      hr_utility.trace('No required defined balance exists');
   ELSE
      /*Get the element_type_id to update*/
      OPEN get_element_type_id(p_input_value_id
                              ,p_business_group_id
			      ,p_effective_date
                              );
      FETCH get_element_type_id INTO ln_element_type_id;
      IF ((get_element_type_id%NOTFOUND) OR (ln_element_type_id IS NULL)) THEN
         hr_utility.trace('No required element_type_id exists');
      ELSE
         /*Update the time_definition_type to G for the element found above*/
	 UPDATE pay_element_types_f
            SET time_definition_type = 'G'
          WHERE element_type_id = ln_element_type_id
            AND ((business_group_id IS NULL AND legislation_code = 'US') OR               -- For Seeded
                 (business_group_id = p_business_group_id AND legislation_code IS NULL)   -- For Custom
                )
	    AND time_definition_type IS NULL;
      END IF;
      CLOSE get_element_type_id;

   END IF;
   CLOSE get_defined_bal_status;


   hr_utility.trace('Leaving PAY_US_BALANCE_FEEDS_HOOK.INSERT_TIMEDEF_TYPE');
END INSERT_TIMEDEF_TYPE;


/******************************************************************************
   Name        : INSERT_USER_HOOK
   Scope       : GLOBAL
   Description : This procedure is called by AFTER INSERT Row Level handler
                 User Hook.
******************************************************************************/
PROCEDURE INSERT_USER_HOOK(
   p_effective_date     IN  DATE
  ,p_balance_type_id	IN  NUMBER
  ,p_input_value_id	IN  NUMBER
  ,p_scale		IN  NUMBER    DEFAULT NULL
  ,p_business_group_id  IN  NUMBER    DEFAULT NULL
  ,p_legislation_code	IN  VARCHAR2  DEFAULT NULL
  ) IS
BEGIN

   hr_utility.trace('Entering PAY_US_BALANCE_FEEDS_HOOK.INSERT_USER_HOOK');

   -- Call INSERT_TIMEDEF_TYPE
   -- The local procedure inserts time_definition_type as 'G' in pay_element_types_f
   -- whenever that element feeds a balance for which defined balance exists with dimensions:
   -- _ASG_GRE_TD_RUN and _ASG_GRE_TD_BD_RUN. These checks are handled as a part of the
   -- local procedure
   INSERT_TIMEDEF_TYPE(
                       p_effective_date    => p_effective_date
                      ,p_balance_type_id   => p_balance_type_id
                      ,p_input_value_id	   => p_input_value_id
                      ,p_business_group_id => p_business_group_id
                      ,p_legislation_code  => p_legislation_code
                      );


   hr_utility.trace('Leaving PAY_US_BALANCE_FEEDS_HOOK.INSERT_USER_HOOK');
END INSERT_USER_HOOK;

-----------------------------INSERT SECTION ENDS HERE--------------------------


END PAY_US_BALANCE_FEEDS_HOOK;

/
