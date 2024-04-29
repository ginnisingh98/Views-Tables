--------------------------------------------------------
--  DDL for Package PAY_MX_SUA_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_SUA_MAG" AUTHID CURRENT_USER as
/* $Header: paymxsuamag.pkh 120.4.12010000.1 2008/07/27 21:51:27 appldev ship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_mx_sua_mag
    Package File Name   : paymxsuamag.pkh

    Description : Used for SUA Interface Extract

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    vpandya       29-Apr-2005 115.0           Initial Version
    sdahiya       11-Jul-2005 115.1           Added range code, action creation
                                              code and XML generation mechanism.
    sdahiya       20-Dec-2005 115.2           Dynamically fetch IANA charset
                                              to identify XML encoding.
    sdahiya       22-Dec-2005 115.3           Removed XML header information.
                                              PYUGEN will generate XML headers.
    nragavar      12-Jul-2007 115.32 6198089  added new procedure INIT
    ========================================================================*/

  /****************************************************************************
    Name        : GET_START_DATE
    Description : This function returns start date.
  *****************************************************************************/
FUNCTION GET_START_DATE
(
    P_MODE              varchar2, -- FULL/INCREMENT
    P_GRE_ID            number
) RETURN varchar2;


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
    Description : This procedure creates assignment actions for SUA magnetic
                  tape process.
  *****************************************************************************/
PROCEDURE ACTION_CREATION
(
    P_PAYROLL_ACTION_ID number,
    P_START_PERSON_ID   number,
    P_END_PERSON_ID     number,
    P_CHUNK             number
);


  /****************************************************************************
    Name        : GEN_XML_HEADER
    Description : This procedure generates XML header information and appends to
                  pay_mag_tape.g_clob_value.
  *****************************************************************************/
PROCEDURE GEN_XML_HEADER;


  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_clob_value.
  *****************************************************************************/
PROCEDURE GENERATE_XML;

  /****************************************************************************
    Name        : INIT
    Description : Initialization code.
  *****************************************************************************/
PROCEDURE INIT
(
    P_PAYROLL_ACTION_ID number
);


  /****************************************************************************
    Name        : GEN_XML_FOOTER
    Description : This procedure generates XML information for GRE and the final
                  closing tag. Final result is appended to
                  pay_mag_tape.g_clob_value.
  *****************************************************************************/
PROCEDURE GEN_XML_FOOTER;


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
           '<SUA_MAG>',
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

END pay_mx_sua_mag;

/
