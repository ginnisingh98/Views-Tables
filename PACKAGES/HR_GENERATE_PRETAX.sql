--------------------------------------------------------
--  DDL for Package HR_GENERATE_PRETAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GENERATE_PRETAX" AUTHID CURRENT_USER AS
/* $Header: pygenptx.pkh 115.5 2002/12/28 01:15:28 meshah ship $ */
/*
+======================================================================+
| Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA     |
|                       All rights reserved.    |
+======================================================================+

Name		: hr_generate_pretax
Filename	: pygenptx.pkh

Change List
-----------
Date            Name         	Vers    Bug No	Description
-----------     ----          	----    ------	-----------
07-JUN-96	H.Parichabutr	40.0	Created.
03-JAN-97       M Reid          40.1    434903  Moved header line
29-APR-97	PMadore		40.2		Added p_ele_er_match parameter
15-AUG-2000     ahanda 	       110.4            Added commit before exit stmt.
27-DEC-2002     meshah         115.5            fixed gscc warnings/errors.
*/

g_template_leg_code varchar2(2) := 'US';
g_template_leg_subgroup	varchar2(30) := null;

FUNCTION pretax_deduction_template (
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
		p_ele_start_rule   	in varchar2,
		p_ele_stop_rule		in varchar2,
		p_ele_ee_bond		in varchar2	default 'N',
		p_ele_amount_rule	in varchar2,
		p_ele_paytab_name	in varchar2	default NULL,
		p_ele_paytab_col   	in varchar2	default NULL,
		p_ele_paytab_row_type	in varchar2	default NULL,
		p_ele_arrearage		in varchar2	default 'N',
		p_ele_partial_dedn	in varchar2	default 'N',
		p_mix_flag		in varchar2	default NULL,
		p_ele_er_match		in varchar2	default 'N',
		p_ele_eff_start_date	in date     	default NULL,
		p_ele_eff_end_date	in date     	default NULL,
		p_bg_id			in number)
					RETURN NUMBER;

end hr_generate_pretax;

 

/
