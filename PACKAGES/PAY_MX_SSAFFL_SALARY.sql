--------------------------------------------------------
--  DDL for Package PAY_MX_SSAFFL_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MX_SSAFFL_SALARY" AUTHID CURRENT_USER AS
/* $Header: paymxsalary.pkh 120.0 2005/05/29 10:56:15 appldev noship $ */
--
/*
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
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

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   03-MAY-2004  kthirmiy    115.0           Created.

*/
--
  FUNCTION get_start_date( p_business_group_id in varchar2
                          ,p_tran_gre_id  in varchar2
                          ,p_gre_id       in varchar2
                         ) RETURN VARCHAR2 ;


  PROCEDURE get_payroll_action_info(p_payroll_action_id     in        number
                                   ,p_report_mode          out nocopy varchar2
                                   ,p_period_start_date    out nocopy date
                                   ,p_period_end_date      out nocopy date
                                   ,p_start_date           out nocopy date
                                   ,p_end_date             out nocopy date
                                   ,p_business_group_id    out nocopy number
                                   ,p_tran_gre_id          out nocopy number
                                   ,p_gre_id               out nocopy number
                                   ,p_event_group_id       out nocopy number
                                   ) ;

  PROCEDURE range_cursor(p_payroll_action_id in number
                        ,p_sqlstr           out nocopy varchar2);

  PROCEDURE action_creation(p_payroll_action_id   in number
                           ,p_start_person_id in number
                           ,p_end_person_id   in number
                           ,p_chunk               in number);

  PROCEDURE archive_data(p_assignment_action_id  in number
                        ,p_effective_date        in date);


  PROCEDURE archinit(p_payroll_action_id in number);



END pay_mx_ssaffl_salary;

 

/
