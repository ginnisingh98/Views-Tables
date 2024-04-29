--------------------------------------------------------
--  DDL for Package PAY_MX_SUBSIDY_EMP_PD_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_SUBSIDY_EMP_PD_RPT" AUTHID CURRENT_USER as
/* $Header: paymxsubemplpaid.pkh 120.0.12010000.1 2009/02/09 06:11:41 sivanara noship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_mx_subsidy_emp_pd_rpt
    Package File Name   : paymxsubemprpt.pkh

    Description : Used for ISR Subsidy For Employment Paid Report

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sivanara     07-JAN-2008 115.0           Initial Version
    ========================================================================*/


  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed.
  *****************************************************************************/
  PROCEDURE RANGE_CURSOR
  (
    P_PAYROLL_ACTION_ID         number,
    P_SQLSTR                    OUT NOCOPY varchar2
  );

  /****************************************************************************
    Name        : ACTION_CREATION
    Description : This procedure creates assignment actions for ISR Subsidy
                  for employment report process.
  *****************************************************************************/
  PROCEDURE ACTION_CREATION
  (
    P_PAYROLL_ACTION_ID number,
    P_START_PERSON_ID   number,
    P_END_PERSON_ID     number,
    P_CHUNK             number
  );


  /****************************************************************************
    Name        : GENERATE_XML_HEADER
    Description : This procedure generates XML header information and appends to
                  pay_mag_tape.g_clob_value.
  *****************************************************************************/
  PROCEDURE GENERATE_XML_HEADER;


  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_clob_value.
  *****************************************************************************/
  PROCEDURE GENERATE_XML;


  /****************************************************************************
    Name        : GENERATE_XML_FOOTER
    Description : This procedure generates XML information for GRE and the final
                  closing tag. Final result is appended to
                  pay_mag_tape.g_clob_value.
  *****************************************************************************/
  PROCEDURE GENERATE_XML_FOOTER;

  g_mag_gre_id        number;
  g_mag_mode          varchar2(10);
  g_mag_start_date    varchar2(25);
  g_mag_end_date      varchar2(25);
  level_cnt           number;


  CURSOR GET_CURR_ACT_ID IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

  CURSOR GET_XML_VER IS
    SELECT 'ROOT_XML_TAG=P',
           '<ISR_SUBSIDY_EMP_MAIN>',
           'PAYROLL_ACTION_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_PAYROLL_ACTION_ID')
      FROM dual;

  CURSOR GET_MAG_ASG_ACT IS
    SELECT 'TRANSFER_ACT_ID=P',
           assignment_action_id
      FROM pay_assignment_actions
     WHERE payroll_action_id = pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_PAYROLL_ACTION_ID');

  TYPE xml_rec IS RECORD
     (name    VARCHAR2(80)
     ,value   VARCHAR2(240)
     );

  TYPE xml_tbl IS TABLE OF xml_rec INDEX BY BINARY_INTEGER;

END PAY_MX_SUBSIDY_EMP_PD_RPT;

/
