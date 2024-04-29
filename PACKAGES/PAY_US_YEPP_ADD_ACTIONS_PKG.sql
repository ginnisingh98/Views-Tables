--------------------------------------------------------
--  DDL for Package PAY_US_YEPP_ADD_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_YEPP_ADD_ACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusyeaa.pkh 120.0.12000000.1 2007/01/18 03:14:51 appldev noship $ */
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

    Name        : pay_us_yepp_add_actions_pkg

    Description : Package used to report the Employees which are not
                  picked up by the Year End Process and mark them for
                  retry. It is used by the concurrent request -
                 'Add Assignment Actions To The Year End Pre-Process'


    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    01-Sep-2003 kaverma    115.0   2222748  Created.
    03-Sep-2003 kaverma    115.1   2222748  Removed extra lines from the
                                            package


  ********************************************************************/


 /********************************************************************
  Declare PL SQL Tables to strore Processed/Eligible/Not Eligible
  Assignments from the assignment set.
  ********************************************************************/

 TYPE yepp_assigments_rec IS RECORD
     (c_assignment_id           per_all_assignments_f.assignment_id%TYPE);

 TYPE yepp_assigments_table IS TABLE OF yepp_assigments_rec INDEX BY BINARY_INTEGER;

 l_yepp_prc_asg_table         yepp_assigments_table; -- Processed Assignments
 l_yepp_elgble_asg_table      yepp_assigments_table; -- Eligible Assignments
 l_yepp_not_elgble_asg_table  yepp_assigments_table; -- Not Eligible Assignments

 l_gre_reported_asg_table     yepp_assigments_table; -- All reported assignments
						     -- in the GRE



 /********************************************************************
  Function to display the Titles of the columns of the employee details
  ********************************************************************/

 FUNCTION  formated_header_string(p_output_file_type in varchar2)
                                 RETURN varchar2;


 /*******************************************************************
  Function to display the details of the selected employee
  ********************************************************************/

  FUNCTION  formated_detail_string(p_output_file_type  in varchar2
             			  ,p_year              in varchar2
             			  ,p_gre               in varchar2
             			  ,p_Employee_name     in varchar2
             			  ,p_employee_ssn      in varchar2
             			  ,p_emplyee_number    in varchar2)
             			  RETURN varchar2;


 /********************************************************************
  Procedure to display message if no employees are selected
  ********************************************************************/

  PROCEDURE  formated_zero_count(output_file_type in varchar2,
                                 p_flag           in varchar2);



 /********************************************************************
  The procedure called from the concurrent program.
  Name: add_actions_to_yepp

  Description: The input parameters for the procedure are Date,GRE_ID,
               Assignment Set and output file type fromthe concurrent
               program. The procedure identifies the eligible/processed
               /not eligible and secondary assignments from the
               Assignment set and report them as the output in the
               specified format.

  ********************************************************************/

 PROCEDURE add_actions_to_yepp(errbuf             out nocopy varchar2,
                               retcode            out nocopy number,
                               p_effective_date   in  varchar2,
                               p_gre_id           in  number,
                               p_assign_set       in  number,
			       p_output_file_type in  varchar2);

END pay_us_yepp_add_actions_pkg ;
 

/
