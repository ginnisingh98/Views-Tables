--------------------------------------------------------
--  DDL for Package PER_MX_SS_AFFILIATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_SS_AFFILIATION" AUTHID CURRENT_USER as
/* $Header: permxssaffiltion.pkh 120.2.12010000.2 2008/11/07 17:12:32 vvijayku ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004, Oracle India Pvt. Ltd., Hyderabad         *
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
    Package Name        : PER_MX_SS_AFFILIATION
    Package File Name   : permxssaffiltion.pkh

    Description : Used for Social Security Affiliation report.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sdahiya       28-Jan-2007 115.0           Created.
    sdahiya       22-Apr-2007 115.1           Procedure process_transactions
                                              added.
    sdahiya       16-May-2007 115.2           Version uprev after establishing
                                              dual maintenance.
    vvijayku      07-Nov-2008 115.3           Modified the transaction_rec with the
                                              variable reporting_option.
   ***************************************************************************/



-- Global declarations
TYPE transaction_rec IS RECORD (
    act_info_id NUMBER,
    tran_type   VARCHAR2(2),
    tran_date   VARCHAR2(30),
    idw         NUMBER,
    reporting_option VARCHAR2(4));
TYPE transactions IS TABLE OF transaction_rec INDEX BY BINARY_INTEGER;

  /****************************************************************************
    Name        : GET_START_DATE
    Description : This procedure fetches start date of reporting period.
  *****************************************************************************/
FUNCTION GET_START_DATE
(
    P_TRANS_GRE number
) RETURN VARCHAR2;

  /************************************************************
    Name      : DERIVE_GRE_FROM_LOC_SCL
    Purpose   : This function derives the gre from the parmeters
                location, BG and soft-coded keyflex.
  ************************************************************/
FUNCTION DERIVE_GRE_FROM_LOC_SCL(
    P_LOCATION_ID               NUMBER,
    P_BUSINESS_GROUP_ID         NUMBER,
    P_SOFT_CODING_KEYFLEX_ID    NUMBER,
    P_EFFECTIVE_DATE            DATE)
RETURN NUMBER;

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
    Description : This procedure creates assignment actions.
  *****************************************************************************/
PROCEDURE ACTION_CREATION
(
    P_PAYROLL_ACTION_ID number,
    P_START_PERSON_ID   number,
    P_END_PERSON_ID     number,
    P_CHUNK             number
);


  /****************************************************************************
    Name        : INIT
    Description : Initialization code.
  *****************************************************************************/
PROCEDURE INIT
(
    P_PAYROLL_ACTION_ID number
);


  /****************************************************************************
    Name        : PROCESS_TRANSACTIONS
    Description : This procedures runs through transactions to eliminate
                  redundant ones as explained below: -
                  08 - Hire transactions are always reported unless followed
                       by a termination transaction (02) within the reporting
                       period.
                  07 - Salary modification transaction will be reported only
                       if there has been a change in IDW amount since the
                       previous salary modification. Salary modification
                       transactions archived with hire/re-hire will be
                       suppressed.
                  02 - Termination transactions are always reported unless
                       preceeded by a hire transaction within the reporting
                       period.
  *****************************************************************************/
PROCEDURE PROCESS_TRANSACTIONS
(
    P_PERSON_ID         NUMBER,
    P_GRE_ID            NUMBER,
    P_END_DATE          DATE,
    P_REPORT_TYPE       VARCHAR2,
    P_REPORT_QUALIFIER  VARCHAR2,
    P_REPORT_CATEGORY   VARCHAR2,
    P_TRANSACTIONS IN OUT NOCOPY transactions
);

  /****************************************************************************
    Name        : GEN_XML_HEADER
    Description : This procedure generates XML header information to XML BLOB
  *****************************************************************************/
PROCEDURE GEN_XML_HEADER;


  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GENERATE_XML;


  /****************************************************************************
    Name        : GEN_XML_FOOTER
    Description : This procedure generates XML footer.
  *****************************************************************************/
PROCEDURE GEN_XML_FOOTER;


level_cnt           number;


CURSOR GET_CURR_ACT_ID IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value(
                                                'TRANSFER_ACT_ID')
      FROM DUAL;

CURSOR GET_XML_VER IS
    SELECT 'ROOT_XML_TAG=P',
           '<MX_SS_AFFL>',
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


END PER_MX_SS_AFFILIATION;

/
