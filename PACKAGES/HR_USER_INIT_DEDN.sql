--------------------------------------------------------
--  DDL for Package HR_USER_INIT_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_INIT_DEDN" AUTHID CURRENT_USER as
/* $Header: pyusuidt.pkh 120.0.12010000.1 2008/07/27 23:58:16 appldev ship $ */
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

    Name        : hr_user_init_dedn
    Filename	: pyusuidt.pkh
    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    29-OCT-93   H.Parichabutr   1.0              First Created.
                                                 Initial Procedures
    04-NOV-93	hparicha	1.1		 Completed initial version;
					 	 Added locking and delete
						 procedures.
    14-JUN-95	hparicha	40.6	286491	 Deletion of all balances via
						 assoc bal ids held in
						 ELEMENT_INFORMATIONxx columns.
						 New params to "do_deletions".
    ???		???		40.7

    5-Nov-1996	hparicha	40.8	413211	 Added params to deletion
						 procedure to handle latest
						 dedn configurations - esp.
    30-APR-98	pmadore	        40.9	         Added additional parameters
                                                 for employer match
						 and Aftertax Component
    25-Mar-02   ekim            115.3            Added p_termination_rule to
                                                 ins_deduction_template
    27-DEC-2002 meshah          115.4            fixed gscc warnings.
*/

/* NOTE:
	Data used for certain inserts depend on the calculation method
        (or Amount Rule for deductions)
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
This package contains calls to core API used to insert records comprising an
entire deduction template.

The procedures responsible for creating
appropriate records based on data entered on the User-Initiated Deductions form
must perform simple logic to determine the exact attributes required for the
deduction template.  Attributes (and their determining factors) are:
- skip rules (Start Rule, Deduction Frequency): will be determined
during insert of ele type.
- calculation formulas (Amount Rule, EE Bond, Arrearage, Stop Rule)
- status processing rules (CalcMeth)
- input values (Class/Cat, Calc Method)
- formula result rules (CalcMeth)
---------------------------------------------------------------------
*/

-- Legislation Subgroup Code for all template elements.
g_template_leg_code	VARCHAR2(30) := 'US';
g_template_leg_subgroup	VARCHAR2(30) := 'TEMPLATE';
--
-- Controlling procedure that calls all insert procedures according to
-- locking ladder.  May perform some simple logic.  More involved logic
-- is handled inside various insertion procedures as required,
-- especially ins_uie_formula_processing.
FUNCTION ins_deduction_template (
		p_ele_name 		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ben_class_id	 	in number,
		p_ele_category 		in varchar2	default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N',
		p_ele_proc_runtype 	in varchar2,
		p_ele_start_rule	in varchar2,
		p_ele_stop_rule		in varchar2,
		p_ele_ee_bond		in varchar2	default 'N',
		p_ele_amount_rule	in varchar2,
		p_ele_paytab_name	in varchar2	default NULL,
		p_ele_paytab_col	in varchar2	default NULL,
		p_ele_paytab_row_type	in varchar2	default NULL,
		p_ele_arrearage		in varchar2	default 'N',
		p_ele_partial_dedn	in varchar2	default 'N',
		p_mix_flag		in varchar2	default NULL,
		p_ele_er_match		in varchar2	default 'N',
		p_ele_at_component	in varchar2	default 'N',
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
		p_ele_category		in varchar2	default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N');
--
PROCEDURE do_deletions (p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_ele_priority		in number,
			p_ele_amount_rule	in varchar2,
			p_ele_ee_bond		in varchar2,
			p_ele_arrearage		in varchar2,
			p_ele_stop_rule		in varchar2,
			p_ele_info_10		in varchar2 default null,
			p_ele_info_11		in varchar2 default null,
			p_ele_info_12		in varchar2 default null,
			p_ele_info_13		in varchar2 default null,
			p_ele_info_14		in varchar2 default null,
			p_ele_info_15		in varchar2 default null,
			p_ele_info_16		in varchar2 default null,
			p_ele_info_17		in varchar2 default null,
			p_ele_info_18		in varchar2 default null,
			p_ele_info_19		in varchar2 default null,
			p_ele_info_20		in varchar2 default null,
			p_del_sess_date		in date,
			p_del_val_start_date	in date,
			p_del_val_end_date	in date);
--

FUNCTION get_assoc_ele(p_ele_type_id 	in NUMBER
				,p_suffix		in VARCHAR2
				,p_eff_start_date	in DATE
				,p_bg_id		in NUMBER) RETURN varchar2;
PRAGMA RESTRICT_REFERENCES(get_assoc_ele, WNDS);
END hr_user_init_dedn;

/
