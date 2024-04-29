--------------------------------------------------------
--  DDL for Package PAY_ARCHIVE_MISSING_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ARCHIVE_MISSING_ASG_PKG" AUTHID CURRENT_USER as
/* $Header: payusyem.pkh 120.0 2005/10/17 18:18:52 djoshi noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2005 Oracle Corporation                         *
   *                                                                *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

--
   Name        : PAY_ARCHIVE_MISSING_ASG_PKG
   Description : This package contains the logic for Multi-threading of the
                 Year End Archive Missing Assignments Report
--

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   10-AUG-2005  rsethupa    115.0           Created
   16-SEP-2005  sdhole      115.1   4613898 Added g_payroll_action_id global
                                            variable.
-------------------------------------------------------------------------------
*/
procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );

procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );

Procedure ARCHIVE_DEINIT(p_payroll_action_id IN NUMBER);
Procedure ARCHIVE_CODE (p_assignment_action_id  IN NUMBER, p_effective_date in date);
Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER);

--
-- Global Variables
g_effective_date date;
g_tax_unit_id pay_assignment_actions.tax_unit_id%TYPE;
g_run_balance_status varchar2(1);
g_session_id NUMBER;
g_payroll_action_id pay_payroll_actions.payroll_action_id%TYPE;

TYPE balance_status_rec is RECORD (attribute varchar2(100),
                                   attribute_id number(15)
                                  );
TYPE balance_status_tab is TABLE OF balance_status_rec
INDEX BY BINARY_INTEGER;

ltr_def_bal_status balance_status_tab;

end pay_archive_missing_asg_pkg;

 

/
