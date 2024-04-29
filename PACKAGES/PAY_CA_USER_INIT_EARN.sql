--------------------------------------------------------
--  DDL for Package PAY_CA_USER_INIT_EARN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_USER_INIT_EARN" AUTHID CURRENT_USER as
/* $Header: pycauiet.pkh 120.0.12010000.1 2008/07/27 22:18:29 appldev ship $ */
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

    Name        : pycauiet
    Filename	: pycauiet.pkh
    Change List
    -----------
    Date        Name          	Vers	Bug No  Description
    ----        ----          	----	------  -----------
    10-NOV-98   R.Murthy  	110.0          	First Created.
    17-FEB-2000 RThirlby        110.2           Added new procedure
                                                update_jd_level_on_balance.
                                                This updates jurisdiction_level
                                                on pay_balance_types for all
                                                balances. This procedure will
                                                be used by balances created by
                                                the deductions template too
                                                (pycauidt.pkb).
   18-FEB-2000 RThirlby         115.5           Added p_ele_eoy_type
   20-FEB-2001 ekim             115.3           Added Procedure
                                                update_ntg_element.
   11-APR-2002 SSattini         115.4           Added dbdrv
   11-APR-2002 SSattini         115.5           Corrected GSCC complaint.
   22-MAR-2004 ssmukher         115.6           Bug#2646705 Enhancement for Termination rule
                                                Added  p_termination_rule in the
                                                create_user_init_earn function
*/

/*
---------------------------------------------------------------------
 These procedures call the template engine procedures to determine
 the attributes with which a user-initiated earning will be created
 - i.e. the appropriate balances, formulas, result rules, etc.
---------------------------------------------------------------------
*/

-- Legislation Subgroup Code for all template elements.
g_template_leg_code	VARCHAR2(30) := 'CA';
g_template_leg_subgroup	VARCHAR2(30);
--
FUNCTION create_user_init_earning (
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
                p_termination_rule      in varchar2     default 'F')-- Bug2646705
                RETURN NUMBER;
--
PROCEDURE delete_user_init_earning (
		 	p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_del_sess_date		in date,
			p_del_val_start_date	in date,
			p_del_val_end_date	in date);
--
PROCEDURE UPDATE_JD_LEVEL_ON_BALANCE(p_template_id in number);
--
PROCEDURE update_ntg_element(p_base_element_type_id in number,
                             p_ele_eff_start_date   in date,
                             p_bg_id                in number);
--
END pay_ca_user_init_earn;

/
