--------------------------------------------------------
--  DDL for Package PAY_EMP_ACTION_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EMP_ACTION_ARCH" AUTHID CURRENT_USER AS
/* $Header: pyempxfr.pkh 120.2.12010000.1 2008/07/27 22:31:40 appldev ship $ */
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

    Name        : pay_emp_action_arch

    Description : This package populates the global data
                  for payslip in pay_action_information table.
                  The action_information_categories that it
                  populates are:
                     - EMPLOYEE DEATLS
                     - ADDRESS DETAILS
                     - EMPLOYEE NET PAY DISTRIBUTION
                     - EMPLOYEE ACCRUALS.

    Uses        :

    Change List
    -----------
    Date         Name       Vers   Bug No   Description
    -----------  ---------- ------ -------- ------------------------
    27-JUL-2001  Asasthan   115.0           Created.
    17-AUG-2001  ahanda     115.1           Added PL/SQL table and
                                            procedure.
    28-AUG-2001  asasthan   115.2           Modified get Personal Information
    29-NOV-2001  asasthan   115.3           Changes for in_house Bug 2120442
                                           #1 Added run payroll action id
                                            in get_personal_information
    11-DEc-2001  asasthan   115.4           Defaulted run_payroll_action_id
                                            to null
    22-JAN-2002  ahanda     115.5           Changed package to take care
                                            of Multi Assignment Processing.
    26-JAN-2002 ahanda      115.6           Added dbdrv commands
    19-FEB-2002 ahanda      115.7           Added functions
                                              - get_multi_legislative_rule
                                              - get_multi_assignment_flag.
    19-FEB-2002 ahanda      115.8           Removed defaulting of variables
                                              -  gv_multi_payroll_pymt
                                              - gv_multi_leg_rule
    01-Oct-2002 ekim        115.10          Added procedures:
                                              - get_employee_accruals
                                              - get_net_pay_distribution
                                              - get_employee_other_info
                                              - get_employee_addr
                                            Moved declaration to header
                                            from pkb body to make them
                                            global for other localizations
                                            to call them directly.
    02-Oct-2002 ahanda      115.11          Added initialization_process.
    19-Nov-2002 vpandya     115.12          Added set_error_message function.
    13-Mar-2003 ekim        115.13          Added assignment_id in act_info_rec.
    26-Jun-2003 vpandya     115.14          Added global variable
                                            gv_correspondence_language.
    28-Jul-2003 vpandya     115.15          Added a parameter p_ytd_balcall_aaid
                                            in to get_personal_information, and
                                            added p_ppp_source_action_id and
                                            p_ytd_balcall_aaid in to
                                            get_employee_other_info.
    24-APR-2006 pragupta    115.16          Added new procedure
                                            get_3rdparty_pay_distribution to
					    archive the Third Party Payments.
    07-MAY-2006 ahanda      115.17  5209228 Added a new overloaded procedure -
                                             - arch_pay_action_level_data
                                            to be called from de-init code
  ********************************************************************/

  TYPE act_info_rec IS RECORD
     ( action_context_id      number(15)
      ,action_context_type    varchar2(1)
      ,action_info_category   varchar2(50)
      ,jurisdiction_code      varchar2(11)
      ,assignment_id          number(20)
      ,act_info1              varchar2(300)
      ,act_info2              varchar2(300)
      ,act_info3              varchar2(300)
      ,act_info4              varchar2(300)
      ,act_info5              varchar2(300)
      ,act_info6              varchar2(300)
      ,act_info7              varchar2(300)
      ,act_info8              varchar2(300)
      ,act_info9              varchar2(300)
      ,act_info10             varchar2(300)
      ,act_info11             varchar2(300)
      ,act_info12             varchar2(300)
      ,act_info13             varchar2(300)
      ,act_info14             varchar2(300)
      ,act_info15             varchar2(300)
      ,act_info16             varchar2(300)
      ,act_info17             varchar2(300)
      ,act_info18             varchar2(300)
      ,act_info19             varchar2(300)
      ,act_info20             varchar2(300)
      ,act_info21             varchar2(300)
      ,act_info22             varchar2(300)
      ,act_info23             varchar2(300)
      ,act_info24             varchar2(300)
      ,act_info25             varchar2(300)
      ,act_info26             varchar2(300)
      ,act_info27             varchar2(300)
      ,act_info28             varchar2(300)
      ,act_info29             varchar2(300)
      ,act_info30             varchar2(300)
     );

  TYPE action_info_table IS TABLE OF
       act_info_rec
  INDEX BY BINARY_INTEGER;


  TYPE accruals_rec IS RECORD
     ( accrual_category  varchar2(100)
      ,accrual_cur_value number(10,2)
      ,accrual_net_value number(10,2)
     );

  TYPE accruals_tab_rec IS TABLE OF
       accruals_rec
  INDEX BY BINARY_INTEGER;

  TYPE two_columns IS RECORD
     ( id   number
      ,name varchar2(240));

  TYPE two_column_table IS TABLE OF
       two_columns
  INDEX BY BINARY_INTEGER;

  /**********************************************************************
  ** Procedure get_personal_information populates
  ** pay_emp_action_arch.lrr_act_tab with the following
  ** action_information_contexts :
  **
  **  EMPLOYEE DETAILS
  **  ADDRESS DETAILS
  **  EMPLOYEE NET PAY DISTRIBUTION
  **  EMPLOYEE ACCRUALS
  **
  **  It expects the following in parameters:
  **
  **  #1 p_payroll_action_id    : payroll_action_id of the Archive process
  **  #2 p_assactid             : assignment action id of the Archive process
  **  #3 p_assignment_id        : assignment_id
  **  #4 p_curr_pymt_ass_act_id : 'P','U' action which is locked by the
  **                              Archive process.
  **  #5 p_curr_eff_date        : Effective Date of the Archive Process
  **  #6 p_date_earned          : This is the date_earned for the Run
  **                              Process.
  **  #7 p_curr_pymt_eff_date   : The effective date of prepayments.
  **  #8 p_tax_unit_id          : tax_unit_id from pay_assignment_actions
  **  #9 p_time_period_id       : Time Period Id of the Run.
  ** #10 p_ppp_source_action_id : This is the source_action_id of
  **                              pay_pre_payments for the 'P','U' action.
  ** #11 p_ytd_balcall_aaid     : This is the assignment action id to call
  **                              balances other than ASG_PAYMENTS for Employee
  **                              other information.
  **********************************************************************/
  PROCEDURE get_personal_information(
                   p_payroll_action_id    in number
                  ,p_assactid             in number
                  ,p_assignment_id        in number
                  ,p_curr_pymt_ass_act_id in number
                  ,p_curr_eff_date        in date
                  ,p_date_earned          in date
                  ,p_curr_pymt_eff_date   in date
                  ,p_tax_unit_id          in number
                  ,p_time_period_id       in number
                  ,p_ppp_source_action_id in number
                  ,p_run_action_id        in number default null
                  ,p_ytd_balcall_aaid     in number default null
                 );


  PROCEDURE insert_rows_thro_api_process(
                p_action_context_id   in number
               ,p_action_context_type in varchar2
               ,p_assignment_id       in number
               ,p_tax_unit_id         in number
               ,p_curr_pymt_eff_date  in date
               ,p_tab_rec_data        in pay_emp_action_arch.action_info_table
               );

  FUNCTION get_defined_balance_id (
               p_balance_id        in number
              ,p_balance_dimension in varchar2
              ,p_legislation_code  in varchar2)
  RETURN NUMBER;


  PROCEDURE arch_pay_action_level_data(p_payroll_action_id in number
                                      ,p_payroll_id        in number
                                      ,p_effective_date    in date
                                      );

  PROCEDURE arch_pay_action_level_data(p_payroll_action_id in number
                                      ,p_effective_date    in date
                                      );



  FUNCTION get_multi_legislative_rule(p_legislation_code in varchar2)

  RETURN VARCHAR2;


  FUNCTION get_multi_assignment_flag(p_payroll_id       in number
                                    ,p_effective_date   in date)

  RETURN VARCHAR2;

  PROCEDURE get_employee_accruals(p_assactid       in number
                                 ,p_run_action_id  in number
                                 ,p_assignment_id  in number
                                 ,p_effective_date in date
                                 ,p_date_earned    in date
                                 );


  PROCEDURE get_net_pay_distribution(p_pre_pay_action_id     in number
                                    ,p_assignment_id         in number
                                    ,p_curr_pymt_eff_date    in date
                                    ,p_ppp_source_action_id  in number
                                    );

  PROCEDURE get_3rdparty_pay_distribution(p_pre_pay_action_id     in number
                                         ,p_assignment_id         in number
                                         ,p_curr_pymt_eff_date    in date
                                         ,p_ppp_source_action_id  in number
                                         ,p_payroll_id            in number
                                          );

  PROCEDURE get_employee_other_info(p_run_action_id         in number
                                    ,p_assignment_id        in number
                                    ,p_organization_id      in number
                                    ,p_business_group_id    in number
                                    ,p_curr_pymt_eff_date   in date
                                    ,p_tax_unit_id          in number
                                    ,p_ppp_source_action_id in number
                                                               default null
                                    ,p_ytd_balcall_aaid     in number
                                                               default null
                                    );

  PROCEDURE get_employee_addr(p_person_id      in number
                              ,p_effective_date in date
                              );

  FUNCTION set_error_message( p_error_message in varchar2 )
  RETURN varchar2;


  PROCEDURE initialization_process;

  lrr_act_tab     action_info_table;
  ltr_ppa_arch_data action_info_table;
  ltr_ppa_arch      action_info_table;

  ltr_assignment_accruals accruals_tab_rec;

  ltr_location      two_column_table;
  ltr_jobs          two_column_table;
  ltr_grades        two_column_table;
  ltr_pay_basis     two_column_table;
  ltr_positions     two_column_table;
  ltr_organizations two_column_table;

  gv_multi_payroll_pymt VARCHAR2(1);
  gv_multi_leg_rule     VARCHAR2(1);
  gv_error_message      VARCHAR2(2000);

  gv_correspondence_language      VARCHAR2(100) := NULL;

  g_min_chunk    number:= -1;
  g_archive_flag varchar2(1) := 'N';
  g_bal_act_id   number:= -1;


END pay_emp_action_arch;

/
