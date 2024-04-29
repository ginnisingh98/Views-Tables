--------------------------------------------------------
--  DDL for Package PAY_HK_IR56
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_HK_IR56" 
/* $Header: pyhkir56.pkh 120.1 2005/12/13 20:12:41 snimmala noship $
**
**  Copyright (C) 2001 Oracle Corporation
**  All Rights Reserved
**
**  Change List
**
**  Date        Author   Bug     Ver    Description
**  ===============================================================================
**  06-MAR-2001 sclarke  N/A     115.0  Created
**  02-DEC-2002 srrajago 2689229 115.1  Included 'nocopy' option in all 'OUT' parameters of the procedure get_emoluments.
**  12-DEC-2003 srrajago 3193217 115.2  Modified the 'get_emoluments' function. Included record type g_emol_details_rec,
**                                      declaration of g_balance_value_tab and a new procedure 'populate_defined_balance_ids'.
**  14-Dec-2005 snimmala 4864213 115.6  Added a new function get_quarters_start_date and AUTHID CURRENT_USER is used in the view
**                                      pay_hk_ir56_quarters_info_v.
*/
as

  TYPE g_emol_details_rec IS RECORD
    ( balance_name         pay_balance_types.balance_name%TYPE
    , balance_value        number
    , period_dates         varchar2(23)
    , particulars          hr_lookups.description%TYPE);

  TYPE g_emol_details_tab IS TABLE OF g_emol_details_rec INDEX BY BINARY_INTEGER;

  g_emol_details   g_emol_details_tab;

  FUNCTION get_emoluments
    ( p_assignment_id         in per_assignments_f.assignment_id%TYPE
    , p_assignment_action_id  in pay_assignment_actions.assignment_action_id%TYPE
    , p_tax_unit_id           in pay_assignment_actions.tax_unit_id%TYPE
    , p_reporting_year        in number) RETURN g_emol_details_tab;

  g_balance_value_tab  pay_balance_pkg.t_balance_value_tab;

  PROCEDURE populate_defined_balance_ids;

  function get_tax_year_start
  (p_assignment_id        in number
  ,p_calculation_date     in date
  ) return date;

/*
 * Bug 4864213 - Added the following function get_quarters_start_date to return the quaters start date
 */

  function get_quarters_start_date
     (p_assignment_id         in per_assignments_f.assignment_id%TYPE,
      p_source_id             in pay_hk_ir56_quarters_actions_v.l_source_id%TYPE)
  return DATE;

end pay_hk_ir56;

 

/
