--------------------------------------------------------
--  DDL for Package PAY_US_ACTION_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ACTION_ARCH" AUTHID CURRENT_USER AS
/* $Header: pyusxfrp.pkh 120.0.12010000.3 2009/03/31 10:22:02 sudedas ship $ */
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

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   25-JAN-2001  Asasthan    115.0           Created.
   04-APR-2001  Asasthan    115.4           Changed action29 to number.
   13-JUN-2001  Asasthan    115.5           Added Effective date.
   15-AUG-2001  Asasthan    115.6           Payslip changes.
   22-JAN-2002  ahanda      115.5           Changed package to take care
                                            of Multi Assignment Processing.
   17-JUN-2002  ahanda      115.10 2365908  Changed package to populate tax
                                            deductions if location has changed.
   15-OCT-2002  tmehra      115.11          Added Function to check for Alien.
   02-DEC-2002  ahanda      115.13          Changed package to fix GSCC warnings.
   04-DEC-2003  vpandya     115.14          Added variable gv_act_param_val
                                            which is being used in pyusxfrp.pkb
                                            version 115.80 or above.
   03-NOV-2004  ahanda      115.15          Changed parameter for action_creation
                                            procedure.
   31-MAR-2009  sudedas     115.17 3816988  Introduced procedure -
                                            action_archdeinit

*/
--

  PROCEDURE get_payroll_action_info(p_payroll_action_id   in         number
                                   ,p_end_date            out nocopy date
                                   ,p_start_date          out nocopy date
                                   ,p_business_group_id   out nocopy number
                                   ,p_cons_set_id         out nocopy number
                                   ,p_payroll_id          out nocopy number
                                   );

  PROCEDURE action_range_cursor(p_payroll_action_id in number
                               ,p_sqlstr           out nocopy varchar2);

  PROCEDURE action_action_creation(p_payroll_action_id in number
                                  ,p_start_person_id   in number
                                  ,p_end_person_id     in number
                                  ,p_chunk             in number);

  PROCEDURE action_archive_data(p_xfr_action_id  in number,
                                p_effective_date in date);


  PROCEDURE action_archinit(p_payroll_action_id in number);

  PROCEDURE action_archdeinit(p_payroll_action_id IN NUMBER);

  FUNCTION check_alien(
                p_assignment_action_id   in number)
  RETURN VARCHAR2;


  TYPE state_tax_info_rec IS RECORD
     ( sit_exists     varchar2(1)
      ,sui_ee_exists  varchar2(1)
      ,sui_er_exists  varchar2(1)
      ,sdi_ee_exists  varchar2(1)
      ,sdi_er_exists  varchar2(1)
     );

  TYPE state_tax_info_table IS TABLE OF
      state_tax_info_rec
  INDEX BY BINARY_INTEGER;

  TYPE county_tax_info_rec IS RECORD
     ( jurisdiction_code    varchar2(11)
      ,cnty_tax_exists      varchar2(1)
      ,cnty_head_tax_exists varchar2(1)
      ,cnty_sd_tax_exists   varchar2(1)
     );

  TYPE county_tax_info_table IS TABLE OF
      county_tax_info_rec
  INDEX BY BINARY_INTEGER;

  TYPE jurisdiction_rec IS RECORD
     ( action_info_category varchar2(25)
      ,balance_name         varchar2(80)
      ,balance_type_id      number
      ,payment_def_bal_id   number
      ,asg_run_def_bal_id   number
      ,ytd_def_bal_id       number
     );

  TYPE jurisdiction_tab IS TABLE OF
      jurisdiction_rec
  INDEX BY BINARY_INTEGER;

  TYPE school_jd_rec IS RECORD
     (school_jd varchar2(11));

  TYPE school_jd_tab IS TABLE OF
      school_jd_rec
  INDEX BY BINARY_INTEGER;

  ltr_state_tax_info    state_tax_info_table;
  ltr_county_tax_info   county_tax_info_table;

  ltr_fed_tax_bal       jurisdiction_tab;
  ltr_state_tax_bal     jurisdiction_tab;
  ltr_state2_tax_bal     jurisdiction_tab;
  ltr_county_tax_bal    jurisdiction_tab;
  ltr_city_tax_bal      jurisdiction_tab;
  ltr_schdist_tax_bal   jurisdiction_tab;

  g_min_chunk    number:= -1;
  g_archive_flag varchar2(1) := 'N';
  g_bal_act_id   number:= -1;

  gv_act_param_val varchar2(240);

END pay_us_action_arch;

/
