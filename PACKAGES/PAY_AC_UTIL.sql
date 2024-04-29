--------------------------------------------------------
--  DDL for Package PAY_AC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AC_UTIL" AUTHID CURRENT_USER AS
/* $Header: pyacdisc.pkh 115.1 2004/02/16 16:03 vpandya noship $ */
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

    Name        : pay_ac_util

    Description : This procedure is used by  North American
                  packages and tools.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   17-OCT-2003  Asasthan    115.0            Created.
   16-FEB-2004  vpandya     115.1            Gross to Net Adhoc, Added functions
                                             get_def_bal_for_seeded_bal and
                                             get_value.
*/


  FUNCTION get_legis_parameter(p_parameter_name in varchar2,
                               p_parameter_list varchar2) return number;

  FUNCTION get_jurisdiction_name( p_jurisdiction_code in varchar2)
  return varchar2;

  FUNCTION  get_state_abbrev( p_jurisdiction_code in varchar2)
  return varchar2;

  FUNCTION get_format_value (p_business_group_id in number,
                             p_value in number)
  return varchar2;

  FUNCTION get_consolidation_set(p_business_group_id  in number
                                ,p_consolidation_set_id in number)
  return varchar2;

  FUNCTION get_payroll_name(p_business_group_id  in number
                           ,p_payroll_id in number
                           ,p_effective_date in date)

  return varchar2;

  FUNCTION format_to_date(p_char_date in varchar2)
  RETURN date;

 /********************************************************************
  ** Function : get_def_bal_for_seeded_bal
  ** Arguments: p_balance_name
  **            p_legislation_code
  ** Returns  : Defined Balance Id
  ** Purpose  : This function has 2 parameters as input. The function
  **            returns defined balance id of the seeded balance. This
  **            function also uses PL/SQL table def_bal_tbl to cache
  **            defined balance id for seeded balanced.
  *********************************************************************/
  FUNCTION get_def_bal_for_seeded_bal (p_balance_name      in varchar2
                                      ,p_legislation_code  in varchar2)
  RETURN number;

 /********************************************************************
  ** Function : get_value
  ** Arguments: p_assignment_action_id
  **            p_defined_balance_id
  **            p_tax_unit_id
  ** Returns  : Valueed Balance Id
  ** Purpose  : This function has 3 parameters as input. This function
  **            sets the context for Tax Unit Id and then calling
  **            pay_balance_pkg.get_value to get value for given
  **            assignment_action id and defined balance id.
  *********************************************************************/
  FUNCTION get_value(p_assignment_action_id in number
                    ,p_defined_balance_id   in number
                    ,p_tax_unit_id          in number)
  RETURN number;

  gn_tax_unit_id number := -1;

  TYPE defined_balance_rec IS RECORD
     ( balance_name          varchar2(240)
      ,legislation_code      varchar2(10)
      ,defined_balance_id    NUMBER
      ,balance_type_id       NUMBER
      ,balance_dimension_id  NUMBER
     );

  TYPE def_bal_tbl IS TABLE OF
      defined_balance_rec
  INDEX BY BINARY_INTEGER;

  ltr_def_bal def_bal_tbl;

END pay_ac_util;

 

/
