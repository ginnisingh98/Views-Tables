--------------------------------------------------------
--  DDL for Package PER_MX_SSAFFL_DISPMAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_SSAFFL_DISPMAG" AUTHID CURRENT_USER AS
/* $Header: permxdispmag.pkh 120.0 2005/06/01 01:01:12 appldev noship $ */
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
   20-Jul-2004  kthirmiy    115.1           Added two parameters to
                                            format_dispmag_emp_record

*/
--


   -- 'level_cnt' will allow the cursors to select function results,
   -- whether it is a standard fuction such as to_char or a function
   -- defined in a package (with the correct pragma restriction).

     level_cnt	NUMBER;

   -- cursors

   cursor dispmag_submitter is
   select
   'TAX_UNIT_ID=C', pay_magtape_generic.get_parameter_value ('TRANS_GRE'),
   'PAYROLL_ACTION_ID=C',  pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'),
   'TRANS_GRE_ID=P',pay_magtape_generic.get_parameter_value ('TRANS_GRE'),
   'GRE_ID=P'      ,pay_magtape_generic.get_parameter_value ('GRE_ID'),
   'AFFL_TYPE=P' , ppa.report_qualifier
   from
          pay_payroll_actions ppa
    where ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value
                                        ('TRANSFER_PAYROLL_ACTION_ID') ;

   cursor dispmag_employee is
   select 'TRANSFER_ASSIGNMENT_ACTION_ID=C', paa.assignment_action_id,
	  'ASSIGNMENT_ACTION_ID=C'  , paa.assignment_action_id,
	  'ASSIGNMENT_ID=C'         , paa.assignment_id,
	  'ASSIGNMENT_ID=P'         , paa.assignment_id
   from	  pay_assignment_actions paa,
          pay_payroll_actions    ppa
   where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value
				   ('TRANSFER_PAYROLL_ACTION_ID')
     and  paa.payroll_action_id = ppa.payroll_action_id ;




  PROCEDURE get_payroll_action_info(p_payroll_action_id   in         number
                                   ,p_business_group_id   out nocopy number
                                   ,p_trans_gre_id        out nocopy number
                                   ,p_gre_id              out nocopy number
                                   ,p_affl_type           out nocopy varchar2
                                   );

  PROCEDURE range_cursor(p_payroll_action_id in number
                        ,p_sqlstr           out nocopy varchar2);

  PROCEDURE action_creation(p_payroll_action_id   in number
                           ,p_start_assignment_id in number
                           ,p_end_assignment_id   in number
                           ,p_chunk               in number);


  PROCEDURE archinit(p_payroll_action_id in number);




  FUNCTION format_data_string
             (p_input_string     in varchar2
             )
  RETURN VARCHAR2 ;

  FUNCTION format_dispmag_emp_record ( p_assignment_action_id    in number, -- context
                           p_affl_type               in varchar2,
                           p_flat_out                out nocopy varchar2,
                           p_csvr_out                out nocopy varchar2,
                           p_flat_ret_str_len        out nocopy number,
                           p_csvr_ret_str_len        out nocopy number,
                           p_error_flag              out nocopy varchar2,
                           p_error_mesg              out nocopy varchar2
   ) RETURN VARCHAR2 ;

  FUNCTION format_dispmag_total_record(
                           p_trans_gre               in number,
                           p_gre_id                  in number,
                           p_total_emps              in number,
                           p_flat_out                out nocopy varchar2,
                           p_csvr_out                out nocopy varchar2,
                           p_flat_ret_str_len        out nocopy number,
                           p_csvr_ret_str_len        out nocopy number
   ) RETURN VARCHAR2 ;


END per_mx_ssaffl_dispmag;

 

/
