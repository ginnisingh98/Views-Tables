--------------------------------------------------------
--  DDL for Package PAY_CA_USER_INIT_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_USER_INIT_DEDN" AUTHID CURRENT_USER as
/* $Header: pycauidt.pkh 120.0.12010000.1 2008/07/27 22:18:24 appldev ship $ */
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

    Name        : pycauidt
    Filename	: pycauidt.pkh
    Change List
    -----------
    Date        Name          	Vers	Bug No  Description
    ----        ----          	----	------  -----------
    10-NOV-98   R.Murthy  	110.0          	First Created.

    28-OCT-99   J.Bailie        110.1           Added function and procedure for
                                                create_user_init_garnishment
                                                delete_user_init_garnishment

    19-APR-00   Acai  	        115.0          	Rereated for 11i (no change).
    09-AUG-00   mmukherj        115.2       Added update and insert of footnote
                                         and registration no for Year end info
    11-APR-02   SSattini        115.3           Added dbdrv line.
    11-APR-2002 SSattini        115.4           Corrected GSCC complaint.
*/

/*
---------------------------------------------------------------------
 These procedures call the template engine procedures to determine
 the attributes with which a user-initiated deduction will be created
 - i.e. the appropriate balances, formulas, result rules, etc.
---------------------------------------------------------------------
*/

-- Legislation Subgroup Code for all template elements.
g_template_leg_code	VARCHAR2(30) := 'CA';
g_template_leg_subgroup	VARCHAR2(30);
--
FUNCTION create_user_init_deduction (
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
FUNCTION create_user_init_garnishment (
                p_ele_name                 in varchar2,
                p_ele_reporting_name       in varchar2,
                p_ele_description          in varchar2     default NULL,
                p_ele_classification       in varchar2,
                p_ben_class_id             in number,
                p_ele_category             in varchar2     default NULL,
                p_ele_processing_type      in varchar2,
                p_ele_priority             in number       default NULL,
                p_ele_standard_link        in varchar2     default 'N',
                p_ele_proc_runtype         in varchar2,
                p_ele_start_rule           in varchar2,
                p_ele_stop_rule            in varchar2,
                p_ele_calc_rule            in varchar2,
                p_ele_calc_rule_code       in varchar2,
                p_ele_insuff_funds         in varchar2,
                p_ele_insuff_funds_code    in varchar2,
                p_ele_t4a_footnote         in varchar2,
                p_ele_rl1_footnote         in varchar2,
                p_ele_registration_number  in varchar2,
                p_ele_eff_start_date       in date         default NULL,
                p_ele_eff_end_date         in date         default NULL,
                p_bg_id                    in number)      RETURN NUMBER;
--
PROCEDURE delete_user_init_deduction (
		p_business_group_id	in number,
		p_ele_type_id		in number,
		p_ele_name		in varchar2,
		p_ele_priority		in number,
		p_ele_info_10		in varchar2	default null,
		p_ele_info_12		in varchar2	default null,
		p_del_sess_date		in date,
		p_del_val_start_date	in date,
		p_del_val_end_date	in date);
--
PROCEDURE delete_user_init_garnishment (
                p_business_group_id        in number,
                p_ele_type_id              in number,
                p_ele_name                 in varchar2,
                p_ele_priority             in number,
                p_ele_info_10              in varchar2     default null,
                p_ele_info_12              in varchar2     default null,
                p_del_sess_date            in date,
                p_del_val_start_date       in date,
                p_del_val_end_date         in date);
--
END pay_ca_user_init_dedn;

/
