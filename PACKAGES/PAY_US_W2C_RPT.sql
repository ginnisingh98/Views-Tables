--------------------------------------------------------
--  DDL for Package PAY_US_W2C_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2C_RPT" AUTHID CURRENT_USER AS
/* $Header: pyusw2cr.pkh 120.0 2005/05/29 10:08:54 appldev noship $ */
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

    Name        : pay_us_w2c_rpt

    Description : This procedure is used by  W-2C Pre-Process
                  to archive data for W-2C Corrections Reporting.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   25-JAN-2001  Asasthan    115.0            Created.
*/


  PROCEDURE w2crpt_range_cursor(p_payroll_action_id in number
                               ,p_sqlstr           out nocopy varchar2);

  PROCEDURE w2crpt_action_creation(p_payroll_action_id   in number
                                  ,p_start_person_id     in number
                                  ,p_end_person_id       in number
                                  ,p_chunk               in number);

  PROCEDURE sort_action(p_payroll_action_id in     varchar2
                       ,p_sql_string        in out nocopy varchar2
                       ,p_sql_length           out nocopy   number);

  g_min_chunk    number:= -1;
  g_archive_flag varchar2(1) := 'N';
  g_bal_act_id   number:= -1;

END pay_us_w2c_rpt;

 

/
