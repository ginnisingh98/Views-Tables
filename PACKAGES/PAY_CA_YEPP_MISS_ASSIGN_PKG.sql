--------------------------------------------------------
--  DDL for Package PAY_CA_YEPP_MISS_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_YEPP_MISS_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: pycayema.pkh 120.0 2005/05/29 03:56 appldev noship $ */
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
    Name        : pay_ca_yepp_miss_assign_pkg

    Description : Package header for Year End Archive Missing
                  Assignments Report
    Change List
    -----------
    Date            Name      Vers     Bug No      Description
    ----            ----      ------   -------     -----------
    08-OCT-2004    ssouresr   115.0    3562508     Created.
*/

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/
FUNCTION  formated_header_string(p_output_file_type  in varchar2)
RETURN varchar2;

/**********************************************************************
 Function to display the Titles of the columns of the employee details
**********************************************************************/
FUNCTION  formated_header_string_rl(p_output_file_type  in varchar2)
RETURN varchar2;

/***************************************************************
 Function to display the details of the selected employee
***************************************************************/
FUNCTION  formated_detail_string(p_output_file_type  in varchar2
                                ,p_year                 varchar2
                                ,p_gre                  varchar2
                                ,p_employee_name        varchar2
                                ,p_employee_sin         varchar2
                                ,p_employee_number      varchar2)
RETURN varchar2;

/***************************************************************
 Function to display the details of the selected employee
***************************************************************/
FUNCTION  formated_detail_string_rl(p_output_file_type  in varchar2
                                   ,p_year                 varchar2
                                   ,p_pre                  varchar2
                                   ,p_employee_name        varchar2
                                   ,p_employee_sin         varchar2
                                   ,p_employee_number      varchar2)
RETURN varchar2;


/**************************************************************************
   Procedure to display message if no employees are selected
 *************************************************************************/

PROCEDURE  formated_zero_count(output_file_type varchar2);

/**************************************************************************
   Procedure to display the name of the assignment set to which the selected
   assignments are added
***************************************************************************/
PROCEDURE formated_assign_count(assignment_set_name in varchar2,
                                assignment_set_id   in number,
                                record_count        in number,
                                assign_set_created  in number,
                                output_file_type    in varchar2);

/* ******************************************************
   The procedure called from the concurrent program.
   Name: select_employee
   Description: The input parameters for the procedure are
   Date,GRE/PRE,Assignment Set and output file type from
   the concurrent program. The procedure identifies the
   missing assignments , adds them to the assignment
   set entered and generates the report in the specified
   format.
   *****************************************************/
PROCEDURE select_employee(errbuf             out  nocopy  varchar2,
                          retcode            out  nocopy  number,
                          p_effective_date   in           varchar2,
                          p_bus_grp          in           number,
                          p_report_type      in           varchar2,
                          p_dummy1           in           varchar2,
                          p_gre_id           in           number,
                          p_dummy2           in           varchar2,
                          p_pre_id           in           number,
                          p_assign_set       in           varchar2,
			  p_output_file_type in           varchar2);

/*********************************************************
     The Function returns the value of the parameter been
     passed from the Legislative parameter list.
 ********************************************************/
FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2)
return varchar2;

pragma restrict_references(get_parameter, WNDS, WNPS);

END pay_ca_yepp_miss_assign_pkg;
 

/
