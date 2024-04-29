--------------------------------------------------------
--  DDL for Package HR_TEMPLATE_EXISTENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TEMPLATE_EXISTENCE" AUTHID CURRENT_USER AS
/* $Header: pytmplex.pkh 115.0 99/07/17 06:38:10 porting ship $ */
/*
*******************************************************************
   * Copyright (C) 1993 Oracle Corporation.                        	*
   *  All rights reserved.                                      		*
   *			                                                       *
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
    Name        	: hr_template_existence
    Filename	: pytmplex.pkh

    Change List
    Date                   Name          	Vers    Bug No    Description
    ----                     ----          	----      ------         -----------
    23-MAY-1996   H.Parichabutr  	40.0		Created.
    22-JUL-1996	Hparicha		40.1	373543. Removed comment from exit...
    25-JUL-1996	hparicha		40.2		Revised spr_exists, now returns
							existing spr id AND the formula
							id that it uses...p_ff_id param
							is now an output.
    06-AUG-1996	hparicha	40.3	Added functions to check for existence of
					link input values, element entry values, and
					run result values for use when upgrading
					existing earnings and deductions.
3rd Oct 1996	hparicha	40.4	398791. Added parameters for
					effective date to be used in
					all existence comparisons.
*/

/*
This package contains functions that check for the existence of the following payroll objects:
(*) Element Type
(*) Input Value
(*) Balances
(*) Defined Balances
(*) Balance Feeds
(*) Status Processing Rules
(*) Formula Result Rules

This package is called from the involuntary, earnings, and deduction generator packages before creating any record...this makes template elements re-generatable and upgradeable !!!

These functions should check for existence by doing select count(*).  If none are found, then return zero.
Calling function will perform insertion if value returned is zero.  If the object does exist, then this function
will perform a select for the id of the record found; this id is returned as the value from the function.  The calling function then knows any non-zero value returned from the function is the id of the existing record.

*/

function bal_feed_exists (	p_bal_id 	in number,
				p_iv_id		in number,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function result_rule_exists (	p_spr_id 	in number,
				p_frr_name	in varchar2,
				p_iv_id 	in number,
				p_ele_id 	in number,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function spr_exists (		p_ele_id 	in number,
				p_ff_id		out number,
				p_val_date 	in date,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function ele_ff_exists (	p_ele_name 	in varchar2,
				p_bg_id		in number,
				p_ff_name	out varchar2,
				p_ff_text	out varchar2,
				p_eff_date	in date default sysdate) return number;

function defined_bal_exists (	p_bal_id 	in number,
				p_dim_id 	in number,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function iv_name_exists (	p_ele_id 	in number,
				p_iv_name 	in varchar2,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function ele_exists (		p_ele_name 	in varchar2,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function bal_exists (		p_bal_name 	in varchar2,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number;

function upg_link_iv_exists (
	p_element_link_id	IN NUMBER,
	p_input_val_id		IN NUMBER,
	p_eff_date		in date default sysdate) RETURN NUMBER;

function upg_entry_val_exists (
	p_element_entry_id	IN NUMBER,
	p_input_val_id		IN NUMBER,
	p_eff_date		in date default sysdate) RETURN NUMBER;

function upg_result_val_exists (
	p_run_result_id		IN NUMBER,
	p_input_val_id		IN NUMBER,
	p_eff_date		in date default sysdate) RETURN NUMBER;

END hr_template_existence;

 

/
