--------------------------------------------------------
--  DDL for Package PAY_CA_YEPP_ADD_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_YEPP_ADD_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pycayeaa.pkh 120.0.12010000.1 2008/07/27 22:19:08 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Name        : pay_ca_yepp_add_actions_pkg

    Description : Package used to report the Employees which are not
                  picked up by the Year End Process and mark them for
                  retry.


    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    18-Oct-2004 ssouresr   115.0            Created.

  ********************************************************************/


 /********************************************************************
  Declare PL SQL Tables to store Processed/Eligible/Not Eligible
  Assignments from the assignment set.
  ********************************************************************/

  TYPE yepp_assigments_rec IS RECORD
      (c_assignment_id   per_all_assignments_f.assignment_id%TYPE);

  TYPE yepp_assigments_table IS TABLE OF yepp_assigments_rec INDEX BY BINARY_INTEGER;

  l_yepp_prc_asg_table         yepp_assigments_table; -- Processed Assignments
  l_yepp_elgble_asg_table      yepp_assigments_table; -- Eligible Assignments
  l_yepp_not_elgble_asg_table  yepp_assigments_table; -- Not Eligible Assignments

  l_all_reported_asg_table     yepp_assigments_table; -- All reported assignments


 /********************************************************************
  Function to display the Titles of the columns of the employee details
  ********************************************************************/

  FUNCTION  formated_header_string(p_report_type      in varchar2,
                                   p_output_file_type in varchar2)
  RETURN varchar2;


 /*******************************************************************
  Function to display the details of the selected employee
  ********************************************************************/

  FUNCTION  formated_detail_string(p_output_file_type  in varchar2
             			  ,p_year              in varchar2
             			  ,p_gre_name          in varchar2
             			  ,p_pre_name          in varchar2
             			  ,p_employee_name     in varchar2
             			  ,p_employee_sin      in varchar2
             			  ,p_employee_number   in varchar2
             			  ,p_report_type       in varchar2)
  RETURN varchar2;


 /********************************************************************
  Procedure to display message if no employees are selected
  ********************************************************************/

  PROCEDURE  formated_zero_count(output_file_type in varchar2,
                                 p_flag           in varchar2);


 /********************************************************************
  The procedure called from the concurrent program.
  Name: add_actions_to_yepp
  ********************************************************************/

 PROCEDURE add_actions_to_yepp(errbuf             out  nocopy    varchar2,
                               retcode            out  nocopy    number,
                               p_effective_date   in             varchar2,
                               p_bus_grp          in             number,
                               p_report_type      in             varchar2,
                               p_dummy1           in             varchar2,
                               p_gre_id           in             number,
                               p_dummy2           in             varchar2,
                               p_pre_id           in             number,
                               p_assign_set       in             varchar2,
                               p_output_file_type in             varchar2);

 /*********************************************************
     The Function returns the value of the parameter been
     passed from the legislative parameter list.
  ********************************************************/

 FUNCTION get_parameter(name in varchar2,
                        parameter_list varchar2)
 RETURN varchar2;

 pragma restrict_references(get_parameter, WNDS, WNPS);


END pay_ca_yepp_add_actions_pkg;

/
