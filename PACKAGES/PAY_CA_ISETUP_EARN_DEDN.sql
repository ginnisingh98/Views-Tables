--------------------------------------------------------
--  DDL for Package PAY_CA_ISETUP_EARN_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_ISETUP_EARN_DEDN" AUTHID CURRENT_USER as
/* $Header: paycaisetuped.pkh 120.0 2005/05/29 11:10 appldev noship $ */
/*
*/
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1998 Oracle Corporation.                        *
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

    Name        : pay_ca_isetup_earn_dedn
    Filename	: paycaisetuped.pkh
    Change List
    -----------
    Date        Name          	Vers	Bug No  Description
    ----        ----          	----	------  -----------
    13-JUL-04   P.Ganguly  	115.0          	First Created.
*/

FUNCTION create_isetup_earnings (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ele_category 		in varchar2	default NULL,
                p_ele_calc_method       in varchar2,
                p_ele_eoy_type          in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
		p_ele_ot_earnings	in varchar2 	default 'N',
		p_ele_ot_hours 		in varchar2 	default 'N',
		p_ele_ei_hours 		in varchar2 	default 'N',
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
		p_ele_calc_rule 	in varchar2,
		p_ele_calc_rule_code 	in varchar2	default NULL,
		p_sep_check_option	in varchar2	default 'N',
		p_reduce_regular	in varchar2	default 'N',
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date 	default NULL,
		p_bg_id			in number,
                p_termination_rule      in varchar2     default 'F')
                RETURN NUMBER;
--

FUNCTION create_isetup_deductions (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
                p_ben_class_id          in number,
		p_ele_category 		in varchar2	default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
                p_ele_proc_runtype      in varchar2,
                p_ele_start_rule        in varchar2,
                p_ele_stop_rule         in varchar2,
		p_ele_calc_rule 	in varchar2,
		p_ele_calc_rule_code 	in varchar2,
                p_ele_insuff_funds      in varchar2,
		p_ele_insuff_funds_code	in varchar2,
                p_ele_t4a_footnote      in varchar2,
                p_ele_rl1_footnote      in varchar2,
                p_ele_registration_number in varchar2,
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date 	default NULL,
		p_bg_id			in number) RETURN NUMBER;
--
END pay_ca_isetup_earn_dedn;

 

/
