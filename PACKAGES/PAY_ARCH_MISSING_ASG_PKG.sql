--------------------------------------------------------
--  DDL for Package PAY_ARCH_MISSING_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ARCH_MISSING_ASG_PKG" AUTHID CURRENT_USER AS
/* $Header: pymissarch.pkh 120.0.12000000.1 2007/01/17 22:44:30 appldev noship $ */
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
   *  manual, or otherwise, or disCLOSEd to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

--
   Name        : PAY_ARCH_MISSING_ASG_PKG
   Description : This package contains the logic for Multi-threading of the
                 Year End Archive Missing Assignments Report
--

   Change List
   -----------
     Date         Name        Vers     Bug No    Description
     -----------  ----------  -------  -------   ------------------------------
     25-OCT-2005  rdhingra    115.0    4674183   Code transferred from
                                                 payusyem.pkh.


******************************************************************************/
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

END pay_arch_missing_asg_pkg;

 

/
