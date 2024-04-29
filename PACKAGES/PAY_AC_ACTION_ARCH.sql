--------------------------------------------------------
--  DDL for Package PAY_AC_ACTION_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AC_ACTION_ARCH" AUTHID CURRENT_USER AS
/* $Header: pyacxfrp.pkh 120.5.12010000.4 2009/10/20 10:01:40 kagangul ship $ */
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

   Description : This package archives data that is common to
                 'US' legislation and 'CA' legislation for payslip
                 in pay_action_information table.
                 The action_information_categories that it populates are
                     - AC EARNINGS
                     - AC DEDUCTIONS

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   19-Oct-2009  kagangul   115.25  8688998  Overloaded procedure get_last_xfr_info
					    to accept additional two parameter :
					    1. p_arch_bal_info
					    2. p_legislation_code
   22-Dec-2007  sudedas    115.23  6702864  Added p_retro_base in
                                            Archive_retro_element
  03-Sep-2007    sausingh  115.22  565335   Removed the gscc compliance error.
  17-Aug-2007    sausingh  115.21  5635335  Added two procedures Archive_retro_element
                                            and Archive_addnl_elements to archive retro
                                            elements in separate rows depending upon the
                                            element_entry_id
   13-APR-2006  ahanda      115.20          Changed plsql table hbr_table
   08-Mar-2006  vpandya     115.19          Changed plsql table hbr_table
                                            to fix retro issue for Canada.
   06-OCT-2005  ahanda      115.18 4552807  Added process_baladj_elements
   06-OCT-2004  ahanda      115.17 3940380  Added parameter p_xfr_action_id
                                            to get_last_xfr_info
   30-Jul-2004  ssattini    115.16 3498653  Added a new parameter p_action_type
                                            to get_current_elements procedure.
   03-May-2004  kvsankar    115.15 3585754  Added a new global PL/SQL which
                                            stores the Balance Status of all
                                            Attributes.
   10-Sep-2003  ekim        115.14 3119792  Terminated Assignment Change.
                                   2880047  Added p_sepchk_flag to
                                            get_last_xfr_info
                                            Added global variable
                                            - g_xfr_run_exists
                                              => indicates whether the
                                                 archiver has been run or not
                                                 (T or F) for a payroll.
                                            Added procedure
                                            - process_additional_elements.
   26-JUN-2003  vpandya     115.13 2950628  Added structure lablels_rec to
                                            archive labels based on
                                            correspondence language of an
                                            employee e.g. 'CURRENT' and 'YTD'.
   07-Mar-2003  vpandya     115.12          Added structure hours_by_rate_rec.
   12-Feb-2003  vpandya     115.11          Added global variale for Multi GRE
                                            gv_multi_gre_payment
   06-Feb-2003  ekim        115.10          Added parameter p_sepchk_flag
                                            and p_assignment_id
                                            to get_xfr_elements.
   02-DEC-2002  ahanda      115.9           Changed package to fix GSCC warnings
   17-JUN-2002  ahanda      115.7  2365908  Changed package to populate tax
                                            deductions if location has changed.
   11-JUN-2002  vpandya     115.6           Added variables
                                            - gv_reporting_level
                                            - gn_taxgrp_gre_id
                                            - gv_person_lang
   14-MAY-2002  ahanda      115.5           Added procedures
                                              - get_last_xfr_info
                                              - get_last_pymt_info
   18-FEB-2002  ahanda      115.4           Moved get_multi_assignment_flag
                                            to global package (pyempxfr.pkb)
   26-JAN-2002  ahanda      115.3           Aded dbdrv commands.
   22-JAN-2001  ahanda      115.2           Changed package for Multi Asg
                                            Payments
   22-JAN-2001  asasthan    115.1           Aded dbdrv commands.
   25-JUL-2001  Asasthan    115.0           Created.
*******************************************************************************/

  TYPE emp_elements_rec IS RECORD
     (element_type_id             NUMBER
     ,element_classfn             VARCHAR2(80)
     ,jurisdiction_code           VARCHAR2(80)
     ,element_primary_balance_id  NUMBER
     ,element_processing_priority NUMBER
     ,element_reporting_name      VARCHAR2(80)
     ,element_hours_balance_id    NUMBER
     );

  TYPE emp_element_table IS TABLE OF
       emp_elements_rec
  INDEX BY BINARY_INTEGER;

  TYPE emp_jd_rec IS RECORD
     (emp_jd varchar2(11));

  TYPE emp_jd_rec_table IS TABLE OF
      emp_jd_rec
  INDEX BY BINARY_INTEGER;

  TYPE emp_rec IS RECORD
     ( emp_jd varchar2(11),
       emp_parent_jd varchar2(11)
     );

  TYPE emp_rec_table IS TABLE OF
      emp_rec
  INDEX BY BINARY_INTEGER;

  TYPE hours_by_rate_rec IS RECORD
     ( element_type_id     NUMBER
      ,element_name        VARCHAR2(150)
      ,processing_priority NUMBER
      ,rate                NUMBER
      ,multiple            NUMBER
      ,hours               NUMBER
      ,amount              NUMBER
      ,run_asg_act_id      NUMBER
     );

  TYPE hbr_table IS TABLE OF
      hours_by_rate_rec
  INDEX BY BINARY_INTEGER;

  TYPE labels_rec IS RECORD ( language            varchar2(30),
                              lookup_code         varchar2(30),
                              meaning             varchar2(80));

  TYPE labels_tbl IS TABLE OF labels_rec INDEX BY BINARY_INTEGER;

-- Bug 3585754
  TYPE run_bal_stat_rec IS RECORD
     ( attribute_name    VARCHAR2(50),
       valid_status      VARCHAR2(1)
     );

  TYPE run_bal_stat_tab IS TABLE OF
       run_bal_stat_rec
  INDEX BY BINARY_INTEGER;

  ltr_summary_labels   labels_tbl;

  emp_state_jd         emp_jd_rec_table;
  emp_city_jd          emp_jd_rec_table;
  emp_county_jd        emp_jd_rec_table;
  emp_school_jd        emp_rec_table;
  emp_elements_tab     emp_element_table;
  run_bal_stat         run_bal_stat_tab;

  lrr_act_tab          pay_emp_action_arch.action_info_table ;

  g_min_chunk          NUMBER:= -1;
  g_archive_flag       VARCHAR2(1) := 'N';
  g_bal_act_id         NUMBER:= -1;

  gv_reporting_level       VARCHAR2(30) := 'GRE'; --or 'TAXGRP'
  gv_person_lang           VARCHAR2(30) := 'US';
  gv_ytd_balance_dimension VARCHAR2(80) := '_ASG_GRE_YTD';
  gv_multi_gre_payment varchar2(1) := 'Y';
  g_xfr_run_exists      varchar2(1) := 'T';

  PROCEDURE initialization_process;

  PROCEDURE get_last_xfr_info(p_assignment_id        in        number
                             ,p_curr_effective_date  in        date
                             ,p_action_info_category in        varchar2
                             ,p_xfr_action_id        in        number
                             ,p_sepchk_flag          in        varchar2
                             ,p_last_xfr_eff_date   out nocopy date
                             ,p_last_xfr_action_id  out nocopy number
                             );

  /* Start : Bug 8688998 */
  PROCEDURE get_last_xfr_info(p_assignment_id        in        number
                             ,p_curr_effective_date  in        date
                             ,p_action_info_category in        varchar2
                             ,p_xfr_action_id        in        number
                             ,p_sepchk_flag          in        varchar2
                             ,p_last_xfr_eff_date   out nocopy date
                             ,p_last_xfr_action_id  out nocopy number
			     ,p_arch_bal_info	     in        varchar2
			     ,p_legislation_code     IN        varchar2
                             );
  /* End : Bug 8688998 */

  PROCEDURE get_last_pymt_info(p_assignment_id        in        number
                              ,p_curr_pymt_eff_date   in        date
                              ,p_last_pymt_eff_date  out nocopy date
                              ,p_last_pymt_action_id out nocopy number
                              );

  PROCEDURE get_current_elements(p_xfr_action_id        in number
                                ,p_curr_pymt_action_id  in number
                                ,p_curr_pymt_eff_date   in date
                                ,p_assignment_id        in number
                                ,p_tax_unit_id          in number
                                ,p_sepchk_run_type_id   in number
                                ,p_sepchk_flag          in varchar2
                                ,p_pymt_balcall_aaid    in number
                                ,p_ytd_balcall_aaid     in number
                                ,p_legislation_code     in varchar2
                                ,p_action_type          in varchar2
                                                        default null
                                );

  PROCEDURE get_xfr_elements(p_xfr_action_id       in number
                            ,p_last_xfr_action_id  in number
                            ,p_ytd_balcall_aaid    in number
                            ,p_pymt_eff_date       in date
                            ,p_legislation_code    in varchar2
                            ,p_sepchk_flag         in varchar2
                            ,p_assignment_id       in number
                            );

  PROCEDURE get_missing_xfr_info(p_xfr_action_id        in number
                                ,p_tax_unit_id          in number
                                ,p_assignment_id        in number
                                ,p_last_pymt_action_id  in number
                                ,p_last_pymt_eff_date   in date
                                ,p_last_xfr_eff_date    in date
                                ,p_ytd_balcall_aaid     in number
                                ,p_pymt_eff_date        in date
                                ,p_legislation_code     in varchar2
                                );

  PROCEDURE first_time_process(p_assignment_id       in number
                              ,p_xfr_action_id       in number
                              ,p_curr_pymt_action_id in number
                              ,p_curr_pymt_eff_date  in date
                              ,p_curr_eff_date       in date
                              ,p_tax_unit_id         in number
                              ,p_sepchk_run_type_id  in number
                              ,p_ytd_balcall_aaid    in number
                              ,p_pymt_balcall_aaid   in number
                              ,p_sepchk_flag         in varchar2
                              ,p_legislation_code    in varchar2
                              );

  PROCEDURE populate_summary(p_xfr_action_id in number);

  PROCEDURE process_additional_elements(p_assignment_id in number
                                  ,p_assignment_action_id in number
                                  ,p_curr_eff_date in date
                                  ,p_xfr_action_id in number
                                  ,p_legislation_code in varchar2
                                  ,p_tax_unit_id in number
                                  );

  PROCEDURE process_baladj_elements(
                               p_assignment_id        in number
                              ,p_xfr_action_id        in number
                              ,p_last_xfr_action_id   in number
                              ,p_curr_pymt_action_id  in number
                              ,p_curr_pymt_eff_date   in date
                              ,p_ytd_balcall_aaid     in number
                              ,p_sepchk_flag          in varchar2
                              ,p_sepchk_run_type_id   in number
                              ,p_payroll_id           in number
                              ,p_consolidation_set_id in number
                              ,p_legislation_code     in varchar2
                              ,p_tax_unit_id          in number);



  Procedure Archive_addnl_elements  (p_application_column_name     in varchar2
                                    ,p_xfr_action_id               in  number
                                    ,p_assignment_id               in number
                                    ,p_pymt_assignment_action_id   in number
                                    ,p_pymt_eff_date               in date
                                    ,p_element_type_id             in number
                                    ,p_primary_balance_id          in number
                                    ,p_hours_balance_id            in number
                                    ,p_processing_priority         in number
                                    ,p_element_classification_name in varchar2
                                    ,p_reporting_name              in varchar2
                                    ,p_tax_unit_id                 in number
                                    ,p_ytd_balcall_aaid            in number
                                    ,p_pymt_balcall_aaid           in number
                                    ,p_legislation_code            in varchar2
                                    ,p_sepchk_flag                 in varchar2
                                    ,p_sepchk_run_type_id          in number
                                    ,p_action_type                 in varchar2
                                    ,p_run_assignment_action_id    in number
                                    ,p_multiple                    in number
                                    ,p_rate                        in number
                                    );
 PROCEDURE Archive_retro_element  (
                                     p_xfr_action_id               in  number
                                    ,p_assignment_id               in number
                                    ,p_pymt_assignment_action_id   in number
                                    ,p_pymt_eff_date               in date
                                    ,p_element_type_id             in number
                                    ,p_primary_balance_id          in number
                                    ,p_hours_balance_id            in number
                                    ,p_processing_priority         in number
                                    ,p_element_classification_name in varchar2
                                    ,p_reporting_name              in varchar2
                                    ,p_tax_unit_id                 in number
                                    ,p_ytd_balcall_aaid            in number
                                    ,p_pymt_balcall_aaid           in number
                                    ,p_legislation_code            in varchar2
                                    ,p_sepchk_flag                 in varchar2
                                    ,p_sepchk_run_type_id          in number
                                    ,p_action_type                 in varchar2
                                    ,p_run_assignment_action_id    in number
                                    ,p_multiple                    in number
                                    ,p_rate                        in number
				    ,p_retro_base                  in varchar2 DEFAULT 'N'
                                    );
END pay_ac_action_arch;

/
