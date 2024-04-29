--------------------------------------------------------
--  DDL for Package Body PAY_CA_PAYROLL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_PAYROLL_UTILS" AS
/* $Header: pycautil.pkb 120.1 2006/09/13 11:48:30 ssmukher noship $ */
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

    Name        : pay_ca_payroll_utils

    Description : The package has the common functions used in
                  CA Payroll.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  ------------------------------------
    24-JUN-2003 ssouresr   115.0            Created.
    18-MAR-2004 sdahiya    115.1            Modified check_balance_status to act as
                                            wrapper for pay_us_payroll_utils.check_balance_status.
    13-Sep-2006 ssmukher   115.2            Added the new procedure delete_actionid.

  /*****************************************************************************
   Name      : check_balance_status
   Purpose   : Function should be used to identify whether the balances relevant
               to partcular attribute are valid for use of BRA.
   Arguments : 1. Start Date
               2. Business Group Id
               3. Atttribute Name
   Return    : 'Y' for valid status and 'N' for invalid status of balance
   Notes     : It will used by Canadian Reports to find
               if all the balances related to a report are valid or not
  *****************************************************************************/

  FUNCTION check_balance_status(
              p_start_date        in date,
              p_business_group_id in hr_organization_units.organization_id%type,
              p_attribute_name    in varchar2)
  RETURN VARCHAR2
  IS

     lv_package_stage    VARCHAR2(50) := 'pay_ca_payroll_utils.check_balance_status';

  BEGIN
     hr_utility.trace('Start of Procedure '||lv_package_stage);
     hr_utility.set_location(lv_package_stage,10);
     RETURN (pay_us_payroll_utils.check_balance_status(p_start_date, p_business_group_id, p_attribute_name, 'CA'));

  EXCEPTION
    WHEN others THEN
      hr_utility.set_location(lv_package_stage,20);
      hr_utility.trace('Invalid Attribute Name');
      raise_application_error(-20101, 'Error in pay_ca_payroll_utils.check_balance_status');
      raise;
  END check_balance_status;

  PROCEDURE delete_actionid(p_payroll_action_id IN NUMBER) IS

   CURSOR c_get_report_type(p_payactid NUMBER) IS
   SELECT
         ppa.report_type
   FROM
         pay_payroll_actions ppa
   WHERE
         ppa.payroll_action_id = p_payactid;

   CURSOR c_get_file_payroll_asgact (p_payactid NUMBER) IS
   SELECT
          pfd.file_detail_id
   FROM   pay_file_details pfd
   WHERE  pfd.source_id = p_payactid;

   CURSOR c_get_file_asgact (p_payactid NUMBER) IS
   SELECT
          pfd.file_detail_id
   FROM   pay_file_details pfd
   WHERE  pfd.source_id in (
	  SELECT assignment_action_id
	  FROM   pay_assignment_actions
	  WHERE  payroll_action_id = p_payactid);

l_file_detid  pay_file_details.file_detail_id%type;
type asg_act_list is table of pay_assignment_actions.assignment_action_id%type;
aalist asg_act_list;

BEGIN
       open  c_get_file_payroll_asgact (p_payroll_action_id);
       fetch c_get_file_payroll_asgact
       into  l_file_detid;
       close c_get_file_payroll_asgact;

       DELETE
       FROM   pay_file_details
       WHERE  file_detail_id = l_file_detid;

       open  c_get_file_asgact(p_payroll_action_id);
       loop
            fetch c_get_file_asgact bulk collect into aalist limit 1000;
               forall i in 1..aalist.count
                delete from pay_file_details
                where file_detail_id = aalist(i);

                exit when c_get_file_asgact%notfound;
        end loop;
        close c_get_file_asgact;

/* Calling the core procedure to delete the Payroll actions
   and Assignment actions */
   pay_archive.remove_report_actions(p_payroll_action_id);

END delete_actionid;

END pay_ca_payroll_utils;

/
