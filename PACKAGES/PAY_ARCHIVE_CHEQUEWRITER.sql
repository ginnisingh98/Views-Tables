--------------------------------------------------------
--  DDL for Package PAY_ARCHIVE_CHEQUEWRITER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ARCHIVE_CHEQUEWRITER" AUTHID CURRENT_USER as
/* $Header: paychqarch.pkh 120.0.12010000.2 2008/08/06 06:31:21 ubhat ship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : PAY_ARCHIVE_CHECKWRITER
    Package File Name   : payuschkdp.pkh

    Description : Used by Archive Cheque Writer (Generic) that produces
                  XML Output.

        Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sausingh      24-May-2007 115.0   5635335 Created.
    sudedas
    sudedas       15-Sep-2007 115.1           Added Order By Clause in Cursor
                                              GET_MAG_ASG_ACT
    sudedas       12-Feb-2008 115.2   6802173 Added Package Level TABLE Type
    ========================================================================*/

  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data needed for Archive Check
                  Writer Process, converts it to XML format and appends to
                  pay_mag_tape.g_clob_value.
  *****************************************************************************/
  PROCEDURE generate_xml;


    g_mag_gre_id        number;
    g_mag_mode          varchar2(10);
    g_mag_start_date    varchar2(25);
    g_mag_end_date      varchar2(25);
    level_cnt           number;
--
--
-- Global Variables for Cheque Number Generation
g_chq_asg_action_id   NUMBER;
g_arch_asg_action_id  NUMBER;
--
--
TYPE ltr_char_tab_typ  IS TABLE OF VARCHAR2(500) INDEX BY BINARY_INTEGER;

/* Following Cursors to be used by (Archived) Cheque Writer Process
   (Process Name = 'CHEQUE')
*/

CURSOR GET_CURR_ACT_ID IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

CURSOR GET_MAG_ASG_ACT IS
    SELECT 'TRANSFER_ACT_ID=P',
           assignment_action_id
      FROM pay_assignment_actions
     WHERE payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
     ORDER BY serial_number asc;

END pay_archive_chequewriter;

/
