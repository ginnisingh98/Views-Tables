--------------------------------------------------------
--  DDL for Package PAY_MX_SOC_SEC_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_SOC_SEC_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: paymxsocsecarch.pkh 120.9.12010000.2 2008/09/01 14:29:31 swamukhe ship $ */
/*
 +=========================================================================+
 |                Copyright (c) 2003 Oracle Corporation                    |
 |                   Redwood Shores, California, USA                       |
 |                        All rights reserved.                             |
 +=========================================================================+
 Package Header Name : pay_mx_soc_sec_archive
 Package File Name   : paymxsocsecarch.pkh

 Description : Used for Social Security Archiver.


 Change List:
 ------------

 Name          Date        Version Bug     Text
 ------------- ----------- ------- ------- --------------------------------
 vpandya       28-Apr-2005 115.0           Initial Version
 vpandya       02-May-2005 115.1   4409303 Added PL/SQL tables.
 vpandya       18-Jul-2005 115.2           Added a few global variables.
 vpandya       28-Jul-2005 115.3           Added a global variables
                                           gv_periodic_end_date.
 sdahiya       28-Dec-2005 115.4           Added function seniority_changed
                                           to support salary change
                                           transaction due to implicit
                                           changes in seniority of EEs.
 sdahiya       23-Mar-2006 115.5           Added segments to transaction_rec
 sdahiya       28-Jun-2006 115.6   5355325 Increased widths of abs_start_date
                                           and abs_end_date in transaction_rec
 sdahiya       24-Jan-2007 115.7           Function arch_exists_without_upgrade
                                           added.
 vpandya       20-Mar-2007 115.8   5944540 Leapfrog ver 115.6 to resolve R12
                                           Branch Line issue.
 vpandya       20-Mar-2007 115.9           This is the same as 115.7.
 ===========================================================================*/


  FUNCTION get_start_date( p_gre_id       IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE range_cursor( p_payroll_action_id IN  NUMBER
                         ,p_sqlstr            OUT NOCOPY VARCHAR2);

  PROCEDURE action_creation( p_payroll_action_id   IN NUMBER
                            ,p_start_person_id     IN NUMBER
                            ,p_end_person_id       IN NUMBER
                            ,p_chunk               IN NUMBER);

  PROCEDURE archive_data(p_asg_action_id  IN NUMBER,
                         p_effective_date IN DATE);

  PROCEDURE archinit(p_payroll_action_id IN NUMBER);

  FUNCTION get_dates_for_valueset(p_date IN VARCHAR2)
  RETURN varchar2;

  FUNCTION seniority_changed(p_person_id    IN NUMBER
                            ,p_curr_date    IN DATE
                            ,p_prev_date    IN DATE) RETURN VARCHAR2;

  FUNCTION arch_exists_without_upgrade
    (
        p_business_group_id NUMBER
    ) RETURN VARCHAR2;

  TYPE perasg IS RECORD ( person_id     NUMBER(15)
                         ,assignment_id NUMBER(15));

  TYPE person_assignment IS TABLE OF perasg INDEX BY BINARY_INTEGER;

  per_asg      person_assignment;

  lrr_act_tab  pay_emp_action_arch.action_info_table;

  TYPE datedtbls IS RECORD ( table_name     VARCHAR2(150) );

  TYPE dated_tables IS TABLE OF datedtbls INDEX BY BINARY_INTEGER;

  dated_tbls   dated_tables;

  TYPE fix_var_idw_rec IS RECORD ( idw_type    VARCHAR2(15)
                                  ,idw_date    DATE );

  TYPE fixed_variable_idw IS TABLE OF fix_var_idw_rec INDEX BY BINARY_INTEGER;

  TYPE hire_sep_rec  IS RECORD ( trn_type    VARCHAR2(15)
                                ,trn_date    DATE );

  TYPE hire_separation IS TABLE OF hire_sep_rec  INDEX BY BINARY_INTEGER;

  TYPE transaction_rec IS RECORD ( type                   VARCHAR2(15)
                                  ,date                   VARCHAR2(50)
                                  ,dis_num                VARCHAR2(50)
                                  ,abs_days               NUMBER
                                  ,idw_vol_contr          NUMBER
                                  ,salary_type            VARCHAR2(50)
                                  ,abs_start_date         VARCHAR2(20)
                                  ,abs_end_date           VARCHAR2(20)
                                  ,subsidized_days        per_disabilities_f.dis_information2%type
                                  ,disability_percent     NUMBER
                                  ,dis_insurance_type     per_disabilities_f.dis_information3%type
                                  ,risk_type              per_work_incidents.inc_information1%type
                                  ,consequence            per_disabilities_f.dis_information4%type
                                  ,disability_control     per_disabilities_f.dis_information5%type
                                  ,credit_number          pay_element_entry_values_f.screen_entry_value%type
                                  ,discount_type          pay_element_entry_values_f.screen_entry_value%type
                                  ,discount_value         pay_element_entry_values_f.screen_entry_value%type
                                  ,redxn_table_applies    pay_element_entry_values_f.screen_entry_value%type);

  TYPE transaction IS TABLE OF transaction_rec  INDEX BY BINARY_INTEGER;

  gv_mode VARCHAR2(10);
  gv_periodic_start_date VARCHAR2(22);
  gv_periodic_end_date   VARCHAR2(22);

END PAY_MX_SOC_SEC_ARCHIVE;

/
