--------------------------------------------------------
--  DDL for Package PAY_US_YEPP_MISS_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_YEPP_MISS_ASSIGN_PKG" AUTHID CURRENT_USER as
/* $Header: pyusyema.pkh 120.1 2005/08/26 11:45:34 rsethupa noship $ */
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

    Name        : pay_us_yepp_miss_assign_pkg

    Description : Packge header for Year End Archive Missing Assignments Report

    Change List
    -----------
     Date            Name      Vers     Bug No      Description
     ----            ----      ------   -------     -----------
     25-AUG-2003    rsethupa   115.0    2527077     Created.
     28-AUG-2003    rsethupa   115.1    2527077     Modified declaration of
                                                    procedure formated_assign_count
                                                    to enable check of existing
                                                    assignment set
     29-AUG-2003    rsethupa   115.2    2527077     Moved functions formated_header_string
                                                    and formated_data_string to
                                                    file pyusutil.pkh.
     29-AUG-2003    rsethupa   115.3    2527077     Added Comments.
     25-AUG-2005    rsethupa   115.4    4160436     Rewrite of package for
                                                    Multithreading of Report
*/

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/

FUNCTION  formated_header_string(
              p_output_file_type  in varchar2
             )RETURN VARCHAR2;

/***************************************************************
 Function to display the details of the selected employee
***************************************************************/

FUNCTION  formated_detail_string(
              p_output_file_type  in varchar2
             ,p_year                 varchar2
             ,p_gre                  varchar2
             ,p_Employee_name        varchar2
             ,p_employee_ssn        varchar2
             ,p_emplyee_number       varchar2

             ) RETURN varchar2;


/**************************************************************************
   Procedure to display message if no employees are selected
 *************************************************************************/

PROCEDURE  formated_zero_count(output_file_type varchar2);

/**************************************************************************
   Procedure to display the name of the assignment set to which the selected
   assignments are added
***************************************************************************/

PROCEDURE formated_assign_count(assignment_set_name in varchar2,
                                 assignment_set_id in number,
                                 record_count in number,
                                 assign_set_created in number,
                                 output_file_type in varchar2);

/**************************************************************************
Procedure to display the Elements having input values of type Money
and not feeding the YE Balances
************************************************************************/

PROCEDURE formated_element_header(
                                  p_output_file_type in VARCHAR2
                                 ,p_static_label    out nocopy VARCHAR2
                                 );

/************************************************************
  ** Procedure: formated_element_row
  ** Returns  : Formatted Element Row
  ************************************************************/

PROCEDURE formated_element_row (
                    p_element_name              in varchar2
                   ,p_classification            in varchar2
                   ,p_input_value_name          in VARCHAR2
                   ,p_output_file_type          in VARCHAR2
                   ,p_static_data             out nocopy VARCHAR2
              );


/* ******************************************************
   The procedure called from the concurrent program.
   Name: select_employee
   Description: The input parameters for the procedure are
   Date,GRE_ID,Assignment Set and output file type from
   the concurrent program. The procedure identifies the
   missing assignments , adds them to the assignment
   set entered and generates the report in the specified
   format.
   *****************************************************/

PROCEDURE select_employee(p_payroll_action_id IN NUMBER,
                          p_effective_date IN VARCHAR2,
                          p_tax_unit_id IN NUMBER,
               			  p_session_id in NUMBER);

END pay_us_yepp_miss_assign_pkg;

 

/
