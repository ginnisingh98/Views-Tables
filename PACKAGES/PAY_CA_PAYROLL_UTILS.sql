--------------------------------------------------------
--  DDL for Package PAY_CA_PAYROLL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_PAYROLL_UTILS" AUTHID CURRENT_USER AS
/* $Header: pycautil.pkh 120.1 2006/09/13 11:41:23 ssmukher noship $ */
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

    Description : The package has common functions used in
                  CA Payroll.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    24-JUN-2003 ssouresr   115.0            Created.
    13-Sep-2006 ssmukher   115.1            Added a new procedure to delete
                                            data from pay_file_details,
					    pay_payroll_actions and assginment actions.
  *****************************************************************************/


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
  RETURN VARCHAR2;

PROCEDURE delete_actionid(p_payroll_action_id IN NUMBER);

end pay_ca_payroll_utils;

/
