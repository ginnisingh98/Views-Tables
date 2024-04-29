--------------------------------------------------------
--  DDL for Package PAY_MX_ANNUAL_WRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_ANNUAL_WRI" AUTHID CURRENT_USER as
/* $Header: paymxannualwri.pkh 120.0.12000000.1 2007/02/22 16:24:53 vmehta noship $ */
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
    Package Name        : PAY_MX_ANNUAL_WRI
    Package File Name   : paymxannualwri.pkh

    Description : Used for Annual Work Risk Incidents report.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sdahiya       18-Oct-2006 115.0           Created.
   ***************************************************************************/

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
           '<MX_ANN_WRI>',
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

END PAY_MX_ANNUAL_WRI;

 

/
