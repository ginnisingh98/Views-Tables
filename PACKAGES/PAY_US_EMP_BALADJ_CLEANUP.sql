--------------------------------------------------------
--  DDL for Package PAY_US_EMP_BALADJ_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EMP_BALADJ_CLEANUP" AUTHID CURRENT_USER AS
/* $Header: payusbaladjclean.pkh 120.0 2005/05/29 11:53 appldev noship $ */
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

    Name        : payusbaladjclean.pkh

    Description :


    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    10-JUL-2004 ahanda     115.0            Created.
    14-JUL-2004 ahanda     115.1            Added ltr_misc_er_tax_bal

  ********************************************************************/

  PROCEDURE get_payroll_action_info(
                       p_payroll_action_id     in        number
                      ,p_end_date             out nocopy date
                      ,p_start_date           out nocopy date
                      ,p_business_group_id    out nocopy number
                      ,p_state_abbrev         out nocopy varchar2
                      ,p_cons_set_id          out nocopy number
                      ,p_payroll_id           out nocopy number
                      );

  FUNCTION get_input_value_id(p_element_type_id  in number
                             ,p_input_value_name in varchar2
                             ,p_effective_date   in date)
  RETURN NUMBER;

  PROCEDURE range_cursor(
                    p_payroll_action_id in        number
                   ,p_sqlstr           out nocopy varchar2);


  PROCEDURE action_creation(
                 p_payroll_action_id   in number
                ,p_start_person_id in number
                ,p_end_person_id   in number
                ,p_chunk               in number);


  PROCEDURE initialize(
                p_payroll_action_id in number);


  PROCEDURE deinitialize(
                p_payroll_action_id in number);

  PROCEDURE run_preprocess(
                p_assignment_action_id number
               ,p_effective_date in date);


  TYPE balance_rec IS RECORD
     ( balance_name     varchar2(80)
      ,ytd_def_bal_id   number
      ,element_name     varchar2(50)
      ,element_type_id  number
      ,input_name       varchar2(50)
      ,input_value_id   number
     );

  TYPE balance_tab IS TABLE OF
      balance_rec
  INDEX BY BINARY_INTEGER;

  ltr_sit_tax_bal       balance_tab;
  ltr_sdi_er_tax_bal    balance_tab;
  ltr_misc_er_tax_bal   balance_tab;

  g_adj_state_code VARCHAR2(2);
  g_proc_init      BOOLEAN;
  g_min_chunk      NUMBER;

end pay_us_emp_baladj_cleanup;

 

/
