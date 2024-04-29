--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EXTRACT_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EXTRACT_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: pyelerpd.pkh 120.0 2005/05/29 04:33:30 appldev noship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_element_extract_data_pkg

    Description : Package for the Elements Reports.
                  The package can be used by the users to add columns
                  which they want on the report.

                  The data is printed at the end of the report for
                  each assignment. The package is passed the following
                  paramaters to the report which can be used for
                  retreiving data.
                        - assignment_id
                        - person_id
                        - assignment_action_id
                        - effective_date from pay_payroll_actions


    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     04-AUG-2000 ahanda    115.0             Created.

*/

  TYPE tab_char IS TABLE OF varchar(100)
  INDEX BY BINARY_INTEGER;

  TYPE tab_number IS TABLE OF number(12,2)
  INDEX BY BINARY_INTEGER;


  /***********************************************************
  ** PL/SQL table used for printing data for Element Register
  ** Report.
  ***********************************************************/
  ltt_element_extract_label tab_char;
  ltt_element_extract_data  tab_number;

  /***********************************************************
  ** Procedure called from the main Reports package:
  ** pay_element_extract_pkg.
  ** PL/SQL table LTT_ELEMENT_EXTRACT_LABEL is first read to
  ** print all the labels and then the PL/SQL table
  ** LTT_ELEMENT_EXTRACT_DATA is read to print the data.
  ** The PL/SQL table should be refreshed for each employee
  ** assignment record.
  ***********************************************************/
  PROCEDURE populate_table (p_assignment_id         in number
                           ,p_person_id             in number
                           ,p_assignment_action_id  in number
                           ,p_effective_date        in date
                           );

END pay_element_extract_data_pkg;

 

/
