--------------------------------------------------------
--  DDL for Package PAY_YEPP_MISS_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_YEPP_MISS_ASSIGN_PKG" AUTHID CURRENT_USER as
/* $Header: pyyeppma.pkh 120.2 2007/01/19 13:59:17 ydevi noship $ */

/******************************************************************************

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

    Name        : pay_yepp_miss_assign_pkg

    Description : Packge header for Year End Archive Missing Assignments Report

    Change List
    -----------
     Date            Name      Vers     Bug No      Description
     -----------  ----------  -------  -------   ------------------------------
     25-Oct-2005  rdhingra    115.0    4674183   Code transferred from
                                                 pyusyema.pkh. Call to
                                                 PROCEDURE formated_element_row
                                                 modified
     22-dec-2005  rdhingra    115.1    4779018   Updated Function
                                                 formated_header_string. Added
                                                 extra input parameter.
     19-JAN-2007  ydevi       115.2    4886285   adding p_pre_or_gre in the
                                                 definition of
						 formated_header_string
******************************************************************************/

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/

FUNCTION  formated_header_string(
               p_legislation_code  IN VARCHAR2
              ,p_output_file_type  IN VARCHAR2
	      ,p_pre_or_gre IN varchar2 default null
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
               --    ,p_input_value_name          in VARCHAR2
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

END pay_yepp_miss_assign_pkg;

/
