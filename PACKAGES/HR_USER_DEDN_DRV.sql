--------------------------------------------------------
--  DDL for Package HR_USER_DEDN_DRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_DEDN_DRV" AUTHID CURRENT_USER as
/* $Header: pyusddwp.pkh 115.3 2004/01/29 05:28:11 kaverma ship $ */
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+
*/

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

    Name        : hr_user_init_dedn_drv
    Filename	: pyusddwp.pkh
    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    26-APR-98   PMADORE       1.0                First Created.
                                                 Initial Procedures
    25-Mar-02   EKIM          115.1   2276457    Added p_termination_rule
                                                 to ins_deduction_template.
    26-Mar-02   ekim          115.2              Added commit
    29-Jan-04   kaverma       115.3   3349575    Corrected GSCC warning
*/

g_template_leg_code varchar2(2) := 'US';
g_template_leg_subgroup	varchar2(30) := null;

FUNCTION ins_deduction_template (
		p_ele_name 			in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 default NULL,
		p_ele_classification 	in varchar2,
		p_ben_class_id	 	in number,
		p_ele_category 		in varchar2	default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 default 'N',
		p_ele_proc_runtype 	in varchar2,
		p_ele_start_rule		in varchar2,
		p_ele_stop_rule		in varchar2,
		p_ele_ee_bond		in varchar2	default 'N',
		p_ele_amount_rule		in varchar2,
		p_ele_paytab_name		in varchar2	default NULL,
		p_ele_paytab_col		in varchar2	default NULL,
		p_ele_paytab_row_type	in varchar2	default NULL,
		p_ele_arrearage		in varchar2	default 'N',
		p_ele_partial_dedn	in varchar2	default 'N',
		p_mix_flag			in varchar2	default NULL,
		p_ele_er_match		in varchar2	default 'N',
		p_ele_at_component	in varchar2	default 'N',
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date 	default NULL,
		p_bg_id			in number,
                p_termination_rule      in varchar2     default 'F'
                ) RETURN NUMBER;

end hr_user_dedn_drv;

 

/
