--------------------------------------------------------
--  DDL for Package HR_USER_INIT_EARN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_INIT_EARN" AUTHID CURRENT_USER as
/* $Header: pyusuiet.pkh 115.5 2002/10/10 23:08:24 ekim ship $ */
/*
*/
--
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

    Name        : hr_pyusuiet
    Filename	: pyusuiet.pkh
    Change List
    -----------
    Date        Name          	Vers	Bug No  Description
    ----        ----          	----	------  -----------
    21-SEP-93   H.Parichabutr  	1.0          	First Created.
                                      		    Initial Procedures
    03-NOV-93	hparicha	    1.1		        Added in locking and deletion
                                                procedures.
    22-NOV-94	hparicha        40.4    G1529   Fixes for decoupling
					                    G1601   "Deduction Processing" inpval
                                                from Separate Check processing.
    19-DEC-94	hparicha        40.13   G1564   New calculation of OT Base
                                                Rate
    15-JUN-95	hparicha        40.6            Use "associated balance" ids
                                                for deletion of those balances.
                                                New params for do_deletions.
    09-MAY-96	hparicha        40.8    337007  Added param for p_reduce_regular
                                        340391  new seggie on ele type ddf.
                                                Requires client side
                                                PAYSUDEE.fmb
    17-Mar-02   ekim           115.4            Added p_termination_rule
    10-Oct-02   ekim           115.5            fixed GSCC warning.
*/

/* NOTE:
	Data used for certain inserts depend on the calculation method
	selected.  Calls to these procedures may be bundled in a procedure
       	that will handle putting together a logical set of calls - ie.
       	instead of repeating the same logic in each of the insert procedures,
       	the logic can be performed once and the appropriate calls made
       	immediately.  The data involved includes input values, status
       	processing rules, formula result rules, and skip rules.
	See ins_uie_formula below.

	Also note, *could* make insertion (and validation) procedures
	externally callable.  Consider usefulness of such a design.
*/

/*
---------------------------------------------------------------------
The procedures responsible for creating
appropriate records based on data entered on the User-Initiated Earnings form
must perform simple logic to determine the exact attributes required for the
earnings template.  Attributes (and their determining factors) are:
- skip rules (Class): will be determined during insert of ele type.
- calculation formulas (CalcMeth)
- status processing rules (CalcMeth)
- input values (Class/Cat, Calc Method)
- formula result rules (CalcMeth)
---------------------------------------------------------------------
*/

-- Legislation Subgroup Code for all template elements.
g_template_leg_code	VARCHAR2(30) := 'US';
g_template_leg_subgroup	VARCHAR2(30);
--
FUNCTION do_insertions (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ele_category 		in varchar2	default NULL,
		p_ele_ot_base 		in varchar2 	default 'N',
		p_flsa_hours 		in varchar2 	default 'N',
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
		p_ele_calc_ff_id 	in number,
		p_ele_calc_ff_name 	in varchar2	default NULL,
		p_sep_check_option	in varchar2	default 'N',
		p_dedn_proc		in varchar2	default 'A',
		p_mix_flag		in varchar2	default 'N',
		p_reduce_regular		in varchar2	default 'N',
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date 	default NULL,
		p_bg_id			in number,
                p_termination_rule      in varchar2     default 'F'
                ) RETURN NUMBER;
--
PROCEDURE lock_template_rows (
		p_ele_type_id 		in number,
		p_ele_eff_start_date	in date		default NULL,
		p_ele_eff_end_date	in date		default NULL,
		p_ele_name		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ele_category 		in varchar2	default NULL,
		p_ele_ot_base 		in varchar2 	default 'N',
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
		p_ele_calculation_rule 	in varchar2);
--
PROCEDURE do_deletions (p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_ele_priority		in number,
			p_ele_info_10		in varchar2	default null,
			p_ele_info_12		in varchar2	default null,
			p_del_sess_date		in date,
			p_del_val_start_date	in date,
			p_del_val_end_date	in date);
--
END hr_user_init_earn;

 

/
