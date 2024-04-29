--------------------------------------------------------
--  DDL for Package PAY_MX_SOE_SS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_SOE_SS_PKG" AUTHID CURRENT_USER as
/* $Header: paymxsoe.pkh 120.0 2005/05/29 02:40:14 appldev noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Description: This package is used to show SS SOE for Mexico.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   11-AUG-2004  vpandya     115.0            Created.
   06-Jan-2005  vpandya     115.1            Added following functions:
                                             - summary_balances
                                             - hourly_earnings
                                             - tax_balances
                                             - deductions
                                             - taxable_benefits
                                             - other_balances
  26-Jan-2005   vmehta      115.2  4145267   Changed curr_val and ytd_val
                                             in summ_bal to varchar2(15)
  08-Feb-2005   vpandya     115.3  4145833   Added function setParameters
*/
--

  FUNCTION employee_earnings( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION employee_taxes( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION tax_calc_details( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION summary_balances( p_assignment_action_id in NUMBER )
  RETURN LONG;

  TYPE summ_bal  IS RECORD ( bal_name            varchar2(240),
                             reporting_name      varchar2(240),
                             curr_def_bal_id     number(15),
                             ytd_def_bal_id      number(15),
                             curr_val            varchar2(15),
                             ytd_val             varchar2(15));

  TYPE summary_bal IS TABLE OF summ_bal INDEX BY BINARY_INTEGER;

  FUNCTION hourly_earnings( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION taxable_benefits( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION tax_balances( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION deductions( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION other_balances( p_assignment_action_id in NUMBER )
    RETURN LONG;

  FUNCTION setParameters(p_assignment_action_id number)
    RETURN VARCHAR2;

  FUNCTION setParameters( p_person_id in number
                        , p_assignment_id number
                        , p_effective_date date)
    RETURN VARCHAR2;

  g_currency_code varchar2(10);

END pay_mx_soe_ss_pkg;

 

/
