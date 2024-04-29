--------------------------------------------------------
--  DDL for Package PAY_CA_EOY_RL2_AMEND_REG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EOY_RL2_AMEND_REG" AUTHID CURRENT_USER AS
/* $Header: pycarl2cr.pkh 120.0.12000000.1 2007/01/17 17:20:27 appldev noship $ */
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

    Name        : pay_ca_eoy_rl2_amend_reg

    Description : This Package is used by RL2 Amendment Register
                  and RL2 Amendment Paper Reports.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   04-FEB-2006  SSouresr    115.0            Created.
*/


  PROCEDURE get_payroll_action_info(p_payroll_action_id   in number
                                   ,p_end_date            out nocopy date
                                   ,p_start_date          out nocopy date
                                   ,p_business_group_id   out nocopy number
                                   ,p_pre_org_id          out nocopy number
                                   ,p_person_id           out nocopy number
                                   ,p_asg_set             out nocopy number
                                   ,p_print               out nocopy varchar2
                                   ,p_report_type         out nocopy varchar2
                                   );


  PROCEDURE range_cursor(p_payroll_action_id in number
                        ,p_sqlstr           out nocopy varchar2);

  PROCEDURE action_creation(p_payroll_action_id   in number
                           ,p_start_person_id     in number
                           ,p_end_person_id       in number
                           ,p_chunk               in number);


  FUNCTION get_parameter(name in varchar2,
                         parameter_list varchar2) return varchar2;

  PROCEDURE sort_action (payactid   in     varchar2,
                         sqlstr     in out nocopy varchar2,
                         len        out nocopy   number);

  g_min_chunk    number:= -1;
  g_archive_flag varchar2(1) := 'N';
  g_bal_act_id   number:= -1;

END pay_ca_eoy_rl2_amend_reg;

 

/
