--------------------------------------------------------
--  DDL for Package PAY_US_W2C_ARCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2C_ARCH" AUTHID CURRENT_USER AS
/* $Header: pyusw2cp.pkh 120.0.12010000.1 2008/07/27 23:59:09 appldev ship $ */
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

    Name        : pay_us_w2c_arch

    Description : This procedure is used by  W-2C Pre-Process
                  to archive data for W-2C Corrections Reporting.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   25-JAN-2001  Asasthan    115.0            Created.
*/


  PROCEDURE get_payroll_action_info(p_payroll_action_id   in number
                                   ,p_end_date            out nocopy date
                                   ,p_start_date          out nocopy date
                                   ,p_business_group_id   out nocopy number
                                   ,p_tax_unit_id         out nocopy number
                                   ,p_person_id           out nocopy number
                                   ,p_asg_set             out nocopy number
                                   );


  PROCEDURE w2c_range_cursor(p_payroll_action_id in number
                            ,p_sqlstr           out nocopy varchar2);

  PROCEDURE w2c_action_creation(p_payroll_action_id   in number
                               ,p_start_person_id     in number
                               ,p_end_person_id       in number
                               ,p_chunk               in number);


  FUNCTION get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;

  g_min_chunk    number:= -1;
  g_archive_flag varchar2(1) := 'N';
  g_bal_act_id   number:= -1;

END pay_us_w2c_arch;

/
