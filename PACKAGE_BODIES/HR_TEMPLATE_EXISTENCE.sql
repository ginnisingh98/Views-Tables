--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_EXISTENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_EXISTENCE" AS
/* $Header: pytmplex.pkb 115.0 99/07/17 06:38:07 porting ship $ */
/*
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

    Name        	: hr_template_existence

    Filename	: pytmplex.pkb


    Change List
    -----------
    Date                   Name          	Vers    Bug No    Description
    ----                     ----          	----      ------         -----------
    23-MAY-1996   H.Parichabutr  	40.0		Created.  For upgrades to earnings
							and dedns current as of today - ie.
							sysdate.
    25-JUL-1996	hparicha		40.1		Revised spr_exists, now returns
							existing spr id AND the formula
							id that it uses...p_ff_id param
							is now an output.
    06-AUG-1996	hparicha	40.2	Added functions for existence of link input values,
					element entry values, and run result values for
					upgrading existing earnings and deductions.

3rd Oct 1996	hparicha	40.3	398791. Added parameters for
					effective date to be used in
					all existence comparisons.

3rd Jan 1997    mreid           40.4   434903 - moved header line.

*/
--
/*

This file contains functions that check for the existence of the following payroll objects:

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
				p_eff_date	in date default sysdate)
return number is

already_exists	number := 0;

begin

hr_utility.set_location('hr_template_existence.bal_feed_exists',10);

select 	bf.balance_feed_id
into	already_exists
from	pay_balance_feeds_f	bf
where	bf.balance_type_id 	= p_bal_id
and	bf.input_value_id		= p_iv_id
and	bf.business_group_id	= p_bg_id
and	p_eff_date	between	bf.effective_start_date
			and	bf.effective_end_date;

hr_utility.set_location('hr_template_existence.bal_feed_exists',20);

return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.bal_feed_DOES_NOT_exist',999);

   return already_exists;  -- ie. zero.

end bal_feed_exists;



function result_rule_exists (	p_spr_id 	in number,
				p_frr_name	in varchar2,
				p_iv_id 	in number,
				p_ele_id 	in number,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number is

already_exists	number := 0;

begin

  hr_utility.set_location('hr_template_existence.result_rule_exists',10);

  select   frr.formula_result_rule_id
  into     already_exists
  from    pay_formula_result_rules_f		frr
  where   frr.status_processing_rule_id 		= p_spr_id
  and      frr.result_name 				= p_frr_name
  and	frr.business_group_id			= p_bg_id
  and      nvl(frr.input_value_id, nvl(p_iv_id, 0))	= nvl(p_iv_id, 0)
  and      nvl(frr.element_type_id, nvl(p_ele_id, 0))	= nvl(p_ele_id, 0)
  and     p_eff_date between frr.effective_start_date and frr.effective_end_date;

  -- Note, the above sql checks for result rules which have been
  -- created without providing an element type id...just an input value id...

  hr_utility.set_location('hr_template_existence.result_rule_exists',20);

  return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.result_rule_DOES_NOT_exist',999);

   return already_exists;  -- ie. zero.

end result_rule_exists;


--
-- Check for existence of "standard" Status Processing Rule - ie. proc rule where
-- assignment status type is null.  This function returns the existing spr id, and the
-- formula id on that spr (or null if none).
--
function spr_exists (		p_ele_id	in number,
				p_ff_id		out number,
				p_val_date 	in date,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number is

already_exists	number := 0;

begin

  hr_utility.set_location('hr_template_existence.spr_exists',10);

  select	spr.status_processing_rule_id,
	spr.formula_id
  into	already_exists,
	p_ff_id
  from	pay_status_processing_rules_f	spr
  where	spr.element_type_id 		= p_ele_id
  and	spr.assignment_status_type_id	IS NULL
  and	spr.business_group_id		= p_bg_id
  and	p_val_date between 		spr.effective_start_date
		           and 		spr.effective_end_date;

hr_utility.set_location('hr_template_existence.spr_exists',20);

return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.spr_DOES_NOT_exist',999);

   p_ff_id := NULL;
   return already_exists;  -- ie. zero.

end spr_exists;



function ele_ff_exists (		p_ele_name 	in varchar2,
				p_bg_id		in number,
				p_ff_name	out varchar2,
				p_ff_text	out varchar2,
				p_eff_date	in date default sysdate) return number is

already_exists	number := 0;

begin

hr_utility.set_location('hr_template_existence.ele_ff_exists',10);

select	ff.formula_id,
	ff.formula_name,
	ff.formula_text
into	already_exists,
	p_ff_name,
	p_ff_text
from	pay_element_types_f		pet,
	pay_status_processing_rules_f	spr,
	ff_formulas_f			ff
where	upper(pet.element_name)		= upper(p_ele_name)
and	pet.business_group_id		= p_bg_id
and	p_eff_date		between		pet.effective_start_date
			and		pet.effective_end_date
and	spr.element_type_id		= pet.element_type_id
and	spr.assignment_status_type_id	is null
and	spr.business_group_id		= p_bg_id
and	p_eff_date	between		spr.effective_start_date
			and		spr.effective_end_date
and	ff.formula_id			= spr.formula_id
and	ff.business_group_id		= p_bg_id
and	p_eff_date	between		ff.effective_start_date
			and		ff.effective_end_date;

hr_utility.set_location('hr_template_existence.ele_ff_exists',20);

return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.ele_ff_DOES_NOT_exist',999);
   return already_exists;  -- ie. zero.

end ele_ff_exists;



function defined_bal_exists (	p_bal_id 	in number,
				p_dim_id 	in number,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number is

already_exists	number	:= 0;

begin

hr_utility.set_location('hr_template_existence.defined_bal_exists',10);

    SELECT	pdb.defined_balance_id
    INTO  	already_exists
    FROM  	pay_defined_balances 		pdb
    WHERE  	pdb.balance_type_id 		= p_bal_id
    AND  	pdb.balance_dimension_id 	= p_dim_id
    AND		pdb.business_group_id		= p_bg_id;

hr_utility.set_location('hr_template_existence.defined_bal_exists',20);

return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.defined_bal_DOES_NOT_exist',999);

   return already_exists;  -- ie. zero.

end defined_bal_exists;



function iv_name_exists (	p_ele_id 	in number,
				p_iv_name 	in varchar2,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number is

already_exists	number	:= 0;

begin

     hr_utility.set_location('hr_template_existence.iv_name_exists',10);

      SELECT  piv.input_value_id
      INTO  already_exists
      FROM  pay_input_values_f piv
      WHERE piv.name = p_iv_name
      AND  piv.element_type_id = p_ele_id
      AND  piv.business_group_id = p_bg_id
      AND  p_eff_date between piv.effective_start_date and piv.effective_end_date;

hr_utility.set_location('hr_template_existence.iv_name_exists',20);

return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.iv_name_DOES_NOT_exist',999);

   return already_exists;  -- ie. zero.

end iv_name_exists;





function ele_exists (		p_ele_name 	in varchar2,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number is

already_exists	number	:= 0;

begin

hr_utility.set_location('hr_template_existence.ele_exists',10);

  SELECT  pet.element_type_id
  INTO  already_exists
  FROM  pay_element_types_f pet
  WHERE pet.element_name = p_ele_name
  AND      pet.business_group_id = p_bg_id
  AND      p_eff_date between pet.effective_start_date and pet.effective_end_date;

hr_utility.set_location('hr_template_existence.ele_exists',20);

return already_exists;

exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.ele_name_DOES_NOT_exist',999);

   return already_exists;  -- ie. zero.

end ele_exists;



function bal_exists (		p_bal_name 	in varchar2,
				p_bg_id		in number,
				p_eff_date	in date default sysdate) return number is

-- Note: Pass in bal name as mixed case; finds exact match only.

already_exists	number := 0;

begin

  hr_utility.set_location('hr_template_existence.bal_exists',10);

  SELECT	pbt.balance_type_id
  INTO  		already_exists
  FROM  	pay_balance_types	pbt
  WHERE 	pbt.balance_name 	= p_bal_name
  AND		pbt.business_group_id	= p_bg_id;

  hr_utility.set_location('hr_template_existence.bal_exists',20);

  return already_exists;

 exception when NO_DATA_FOUND then

   hr_utility.set_location('hr_template_existence.bal_DOES_NOT_exist',999);

   return already_exists;  -- ie. zero.

end bal_exists;


function upg_link_iv_exists (
	p_element_link_id	IN NUMBER,
	p_input_val_id		IN NUMBER,
	p_eff_date	in date default sysdate) RETURN NUMBER IS

count_exists	number;

begin

select count(0)
into   count_exists
from   pay_link_input_values_f liv
where  liv.element_link_id = p_element_link_id
and    liv.input_value_id = p_input_val_id;

return count_exists;

end upg_link_iv_exists;


function upg_entry_val_exists (
	p_element_entry_id	IN NUMBER,
	p_input_val_id		IN NUMBER,
	p_eff_date	in date default sysdate) RETURN NUMBER IS

entry_val_exists	number := 0;

begin

select distinct pev.element_entry_value_id
into   entry_val_exists
from   pay_element_entry_values_f pev
where  pev.element_entry_id = p_element_entry_id
and    pev.input_value_id = p_input_val_id;

return entry_val_exists;

exception when no_data_found then

  entry_val_exists := 0;
  return entry_val_exists;

end upg_entry_val_exists;


function upg_result_val_exists (
	p_run_result_id		IN NUMBER,
	p_input_val_id		IN NUMBER,
	p_eff_date	in date default sysdate) RETURN NUMBER IS

count_exists	number;

begin

select count(0)
into   count_exists
from   pay_run_result_values rrv
where  rrv.run_result_id = p_run_result_id
and    rrv.input_value_id = p_input_val_id;

return count_exists;

end upg_result_val_exists;


END hr_template_existence;


/
