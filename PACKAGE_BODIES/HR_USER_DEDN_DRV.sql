--------------------------------------------------------
--  DDL for Package Body HR_USER_DEDN_DRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_USER_DEDN_DRV" as
/* $Header: pyusddwp.pkb 115.4 2004/01/07 07:04:49 kaverma ship $ */
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
    Filename	: pyusddwp.pkb
    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    26-APR-98   PMADORE       1.0               First Created.
                                                 Initial Procedures
    25-Mar-02   EKIM          115.1   2276457    Added p_termination_rule
                                                 to ins_deduction_template
    26-Mar-02   ekim          115.2              Added commit.
    07-Jan-04   kaverma       115.3   3349575    Modified query in insert_formula
                                                 to remove Full Table Scan
    07-Jan-04   kaverma       115.3   3349575    Modified query in insert_formula
                                                 to correct the join condition



*/



/* Cursor to get input_value_id and element_type_id given the names of the objects */

CURSOR csr_input_id(p_ele_name VARCHAR2
	, p_inp_val_name VARCHAR2
	, p_bg_id NUMBER
	, p_eff_start_date DATE) IS
  SELECT piv.input_value_id
	  ,piv.element_type_id
  FROM pay_element_types_f pet
	,pay_input_values_f  piv
  WHERE pet.element_name = p_ele_name
  AND pet.element_type_id = piv.element_type_id
  AND piv.name = p_inp_val_name
  AND	pet.business_group_id +0 = p_bg_id
  AND	p_eff_start_date 	between pet.effective_start_date
  					AND	pet.effective_end_date;

------------------------- insert_formula -----------------------

FUNCTION insert_formula (	p_ff_ele_name in varchar2,
		      p_ff_formula_name in varchar2,
		      p_ele_formula_name in varchar2,
			p_ff_bg_id		in number,
			p_eff_start_date	in date,
			p_eff_end_date in date)
RETURN number IS

/* Retrieves template formula text, replaces <ELE_NAME> in the formula with element_name
 * passed in and inserts the formula.
 */
-- local vars
r_formula_id	number;		-- Return var
--
r_description			VARCHAR2(240);
r_skeleton_formula_text		VARCHAR2(32000);
r_skeleton_formula_type_id	NUMBER(9);
r_ele_formula_text		VARCHAR2(32000);
r_ele_formula_name		VARCHAR2(80);
r_ele_name			VARCHAR2(80);

BEGIN
  hr_utility.set_location('pyusddwp.insert_formula',10);
  SELECT 	FF.formula_text, FF.formula_type_id, FF.description
  INTO		r_skeleton_formula_text, r_skeleton_formula_type_id, r_description
  FROM		ff_formulas_f	FF
  WHERE		FF.formula_name		= p_ff_formula_name
  AND		FF.business_group_id 	IS NULL
  AND		FF.legislation_code	= 'US'
  AND           p_eff_start_date between FF.effective_start_date and FF.effective_end_date
  AND           FF.formula_id           >= 0; -- Bug#3349575

-- Replace element name placeholders with current element name:
  hr_utility.set_location('pyusddwp.insert_formula',15);
  r_ele_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');

  r_ele_formula_name := SUBSTR(REPLACE(LTRIM(RTRIM(UPPER(p_ele_formula_name))),' ','_'), 1, 80);

  r_ele_formula_text := REPLACE(	r_skeleton_formula_text,
				 	'<ELE_NAME>',
					r_ele_name);
--



--
-- Insert the new formula into current business goup:
-- Get new id

  hr_utility.set_location('pyusddwp.insert_formula',30);
  SELECT 	ff_formulas_s.nextval
  INTO	r_formula_id
  FROM 	sys.dual;

  hr_utility.set_location('pyusddwp.insert_formula',40);
  INSERT INTO ff_formulas_f (
 	FORMULA_ID,
	EFFECTIVE_START_DATE,
 	EFFECTIVE_END_DATE,
 	BUSINESS_GROUP_ID,
	LEGISLATION_CODE,
	FORMULA_TYPE_ID,
	FORMULA_NAME,
 	DESCRIPTION,
	FORMULA_TEXT,
	STICKY_FLAG,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATED_BY,
	CREATION_DATE)
values (
 	r_formula_id,
 	p_eff_start_date,
	p_eff_end_date,
	p_ff_bg_id,
	NULL,
	r_skeleton_formula_type_id,
	r_ele_formula_name,
	r_description,
	r_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	p_eff_start_date);

RETURN r_formula_id;

END insert_formula;
----------------------- END insert_formula ---------------------

------------------------- do_employer_match -----------------------

PROCEDURE do_employer_match (p_ename IN VARCHAR2
		, p_bg_id IN NUMBER
		, p_start_date IN DATE
		, p_end_date IN DATE
		, p_leg_code IN VARCHAR2
		, p_er_ename IN VARCHAR2) IS

v_formula_id	number;
v_stat_proc_rule_id number;
v_inpval_id		number;
v_frr_iv_ele_id	number;
v_fres_rule_id 	number;
v_inpval_name 	varchar2(80):= 'Pay Value';
v_formula_name	varchar2(80);

/* Creates the 'Employer Match' formula for an element, creates the Status Processing Rule
 * and inserts the Result Rule for the formula
 */

BEGIN
    hr_utility.set_location('pyusddwp.do_employer_match',10);
    v_formula_name :=   p_er_ename;

    v_formula_id:= insert_formula (
			p_ff_ele_name	=> p_ename,
			p_ff_formula_name	=> 'EMPLOYER_MATCH_TEMPLATE',
			p_ele_formula_name=> v_formula_name,
			p_ff_bg_id		=> p_bg_id,
			p_eff_start_date	=> p_start_date,
			p_eff_end_date	=> p_end_date);

    hr_utility.set_location('pyusddwp.do_employer_match',20);
    -- get input values, element_id
    OPEN csr_input_id(p_er_ename,v_inpval_name,p_bg_id, p_start_date);
    FETCH csr_input_id INTO
	 v_inpval_id
	,v_frr_iv_ele_id;
    IF csr_input_id%FOUND THEN
	hr_utility.set_location('pyusddwp.do_employer_match',30);
	v_stat_proc_rule_id :=
	pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> p_leg_code,
		p_effective_start_date 		=> p_start_date,
		p_effective_end_date 		=> p_end_date,
		p_element_type_id 		=> v_frr_iv_ele_id,
		p_assignment_status_type_id 	=> NULL,
		p_formula_id 			=> v_formula_id,
		p_processing_rule		=> 'P');


      hr_utility.set_location('pyusddwp.do_employer_match',40);

	v_fres_rule_id := pay_formula_results.ins_form_res_rule (
	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
	p_legislation_subgroup		=> p_leg_code,
	p_effective_start_date		=> p_start_date,
	p_effective_end_date         	=> p_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id			=> v_inpval_id,
	p_result_name			=> 'ER_Match',
	p_result_rule_type		=> 'D',
	p_severity_level			=> NULL,
	p_element_type_id			=> v_frr_iv_ele_id);

	hr_utility.set_location('pyusddwp.do_employer_match',50);
    END IF;
    CLOSE csr_input_id;

END do_employer_match;

----------------------- END do_employer_match ---------------------


---------------------- Begin do_passthru_feed --------------------
PROCEDURE do_passthru_feed( p_src_ele IN VARCHAR2
		, p_bg_id IN NUMBER
		, p_src_iv IN VARCHAR2
		, p_targ_bal IN VARCHAR2
		, p_eff_start_date IN DATE
		, p_eff_end_date IN DATE) IS


/* Create the balance feed for the "overlimit" balance which is checked by the aftertax
 * components
 */

l_row			rowid;
l_balance_feed_id number;
l_balance_type_id number;
l_inpval_id		number;
l_dummy		number;

CURSOR csr_bal (p_bal_name IN VARCHAR2)IS
  SELECT balance_type_id
  FROM   pay_balance_types
  WHERE  balance_name = p_bal_name
  AND    business_group_id + 0 = p_bg_id;


BEGIN
  hr_utility.set_location('pyusddwp.do_passthru_feed',10);
  OPEN csr_input_id(p_src_ele,p_src_iv,p_bg_id,p_eff_start_date);
  FETCH csr_input_id INTO
	 l_inpval_id
	,l_dummy;
  IF csr_input_id%NOTFOUND THEN
	hr_utility.set_location('pyusddwp.do_passthru_feed',20);
  ELSE
	hr_utility.set_location('pyusddwp.do_passthru_feed',30);
	OPEN csr_bal(p_targ_bal);
	FETCH csr_bal INTO l_balance_type_id;
	IF csr_bal%FOUND THEN
	  pay_balance_feeds_f_pkg.insert_row (l_row,
			l_balance_feed_id,
			p_eff_start_date,
			p_eff_end_date,
			p_bg_id,
			g_template_leg_code,
			l_balance_type_id,
			l_inpval_id,
			1,
			g_template_leg_subgroup);
	ELSE
		hr_utility.set_location('pyusddwp.do_passthru_feed',40);
	END IF;
	CLOSE csr_bal;
	hr_utility.set_location('pyusddwp.do_passthru_feed',50);

  END IF; -- input _id
  CLOSE csr_input_id;
  hr_utility.set_location('pyusddwp.do_passthru_feed',60);

END do_passthru_feed;
----------------------- END do_passthru_feed ---------------------
-------------------- BEGIN Main Driver Program -------------------

FUNCTION ins_deduction_template (
		p_ele_name 	        in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 default NULL,
		p_ele_classification 	in varchar2,
		p_ben_class_id	 	in number,
		p_ele_category 		in varchar2    default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number      default NULL,
		p_ele_standard_link 	in varchar2    default 'N',
		p_ele_proc_runtype 	in varchar2,
		p_ele_start_rule        in varchar2,
		p_ele_stop_rule		in varchar2,
		p_ele_ee_bond		in varchar2     default 'N',
		p_ele_amount_rule       in varchar2,
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
                ) RETURN NUMBER IS

l_er_ename		varchar2(80) := substr(p_ele_name,1,77)||' ER';
l_at_ename		varchar2(80) := substr(p_ele_name,1,77)||' AT';
l_ele_id 		number;
l_ele_at_id 	number;


l_limit_bal		varchar2(80):= substr(p_ele_name,1,67)||' AT Overlimit';
l_withhold_ele	varchar2(80):= substr(p_ele_name,1,68 )||' Withholding';
l_withhold_iv	varchar2(80):= 'Pass To Aftertax';



--
BEGIN
 IF p_ele_classification = 'Pre-Tax Deductions' THEN

 hr_utility.set_location('pyusddwp.ins_deduction_template',10);

 l_ele_id:=
     hr_generate_pretax.pretax_deduction_template (
		p_ele_name 			=> p_ele_name,
		p_ele_reporting_name 	=> p_ele_reporting_name,
		p_ele_description 	=> p_ele_description ,
		p_ele_classification 	=> p_ele_classification ,
		p_ben_class_id	 	=> p_ben_class_id,
		p_ele_category 		=> p_ele_category,
		p_ele_processing_type 	=> p_ele_processing_type ,
		p_ele_priority 		=> p_ele_priority ,
		p_ele_standard_link 	=> p_ele_standard_link,
		p_ele_proc_runtype 	=> p_ele_proc_runtype ,
		p_ele_start_rule   	=> p_ele_start_rule,
		p_ele_stop_rule		=> p_ele_stop_rule,
		p_ele_ee_bond		=> p_ele_ee_bond,
		p_ele_amount_rule		=> p_ele_amount_rule,
		p_ele_paytab_name		=> p_ele_paytab_name,
		p_ele_paytab_col   	=> p_ele_paytab_col,
		p_ele_paytab_row_type	=> p_ele_paytab_row_type,
		p_ele_arrearage		=> p_ele_arrearage,
		p_ele_partial_dedn	=> p_ele_partial_dedn,
		p_mix_flag			=> p_mix_flag,
		p_ele_er_match		=> p_ele_er_match,
		p_ele_eff_start_date	=> p_ele_eff_start_date,
		p_ele_eff_end_date	=> p_ele_eff_end_date,
		p_bg_id			=> p_bg_id);

 	-- Add Employer Match Formula for Pre-Tax --
 	IF p_ele_er_match = 'Y' THEN
	 --
	hr_utility.set_location('pyusddwp.ins_deduction_template',20);

		do_employer_match(
		  p_ename 		=> p_ele_name
		, p_bg_id 		=> p_bg_id
		, p_start_date 	=> p_ele_eff_start_date
		, p_end_date 	=> p_ele_eff_end_date
		, p_leg_code 	=> g_template_leg_subgroup
		, p_er_ename 	=> l_er_ename);
	END IF; -- Employer Match

--hr_utility.trace_on;

	-- Check to see if Aftertax components need to be created
      IF p_ele_at_component = 'Y' THEN

	  hr_utility.set_location('pyusddwp.ins_deduction_template',30);

	  -- This Pre-tax deduction has an associated Aftertax Component
	  -- Redefine element names for Aftertax components

	  l_er_ename := substr(l_at_ename,1,77)||' ER';


	  l_ele_at_id:=
        hr_user_init_dedn.ins_deduction_template (
		p_ele_name 			=> l_at_ename,
		p_ele_reporting_name 	=> p_ele_reporting_name||' AT',
		p_ele_description 	=> p_ele_description||' - Aftertax Component',
		p_ele_classification 	=> 'Voluntary Deductions',
		p_ben_class_id	 	=> p_ben_class_id,
		p_ele_category 		=> NULL,
		p_ele_processing_type 	=> p_ele_processing_type ,
		p_ele_priority 		=> 5750,
		p_ele_standard_link 	=> p_ele_standard_link,
		p_ele_proc_runtype 	=> p_ele_proc_runtype,
		p_ele_start_rule   	=> p_ele_start_rule,
		p_ele_stop_rule		=> p_ele_stop_rule,
		p_ele_ee_bond		=> p_ele_ee_bond,
		p_ele_amount_rule		=> p_ele_amount_rule,
		p_ele_paytab_name		=> p_ele_paytab_name,
		p_ele_paytab_col   	=> p_ele_paytab_col,
		p_ele_paytab_row_type	=> p_ele_paytab_row_type,
		p_ele_arrearage		=> p_ele_arrearage,
		p_ele_partial_dedn	=> p_ele_partial_dedn,
		p_mix_flag			=> p_mix_flag,
		p_ele_er_match		=> p_ele_er_match,
		p_ele_at_component	=> p_ele_at_component,
		p_ele_eff_start_date	=> p_ele_eff_start_date,
		p_ele_eff_end_date	=> p_ele_eff_end_date,
		p_bg_id			=> p_bg_id,
                p_termination_rule      => p_termination_rule);

	  hr_utility.set_location('pyusddwp.ins_deduction_template',40);

	  -- Add Employer Match Formula for AT component--
	  IF p_ele_er_match = 'Y' THEN
	  --
	  hr_utility.set_location('pyusddwp.ins_deduction_template',50);

	  do_employer_match(
		  p_ename 		=> l_at_ename
		, p_bg_id 		=> p_bg_id
		, p_start_date 	=> p_ele_eff_start_date
		, p_end_date 	=> p_ele_eff_end_date
		, p_leg_code 	=> g_template_leg_code
		, p_er_ename 	=> l_er_ename);
	  END IF; -- Employer Match

	hr_utility.set_location('pyusddwp.ins_deduction_template',60);

	do_passthru_feed(
		  p_src_ele 	=> l_withhold_ele
		, p_bg_id		=> p_bg_id
		, p_src_iv 		=> l_withhold_iv
		, p_targ_bal	=> l_limit_bal
		, p_eff_start_date=> p_ele_eff_start_date
		, p_eff_end_date	=> p_ele_eff_end_date);

	hr_utility.set_location('pyusddwp.ins_deduction_template',70);


  END IF; -- AT Component = 'Y'

ELSE
 --  Not a 'PRE-Tax' Deduction element, do standard processing

 hr_utility.set_location('pyusddwp.ins_deduction_template',90);

 l_ele_id:=
     hr_user_init_dedn.ins_deduction_template (
		p_ele_name 			=> p_ele_name,
		p_ele_reporting_name 	=> p_ele_reporting_name,
		p_ele_description 	=> p_ele_description,
		p_ele_classification 	=> p_ele_classification,
		p_ben_class_id	 	=> p_ben_class_id,
		p_ele_category 		=> p_ele_category,
		p_ele_processing_type 	=> p_ele_processing_type,
		p_ele_priority 		=> p_ele_priority,
		p_ele_standard_link 	=> p_ele_standard_link,
		p_ele_proc_runtype 	=> p_ele_proc_runtype,
		p_ele_start_rule   	=> p_ele_start_rule,
		p_ele_stop_rule		=> p_ele_stop_rule,
		p_ele_ee_bond		=> p_ele_ee_bond,
		p_ele_amount_rule		=> p_ele_amount_rule,
		p_ele_paytab_name		=> p_ele_paytab_name,
		p_ele_paytab_col   	=> p_ele_paytab_col,
		p_ele_paytab_row_type	=> p_ele_paytab_row_type,
		p_ele_arrearage		=> p_ele_arrearage,
		p_ele_partial_dedn	=> p_ele_partial_dedn,
		p_mix_flag			=> p_mix_flag,
		p_ele_er_match		=> p_ele_er_match,
		p_ele_eff_start_date	=> p_ele_eff_start_date,
		p_ele_eff_end_date	=> p_ele_eff_end_date,
		p_bg_id			=> p_bg_id,
                p_termination_rule      => p_termination_rule);

hr_utility.set_location('pyusddwp.ins_deduction_template',100);

END IF ; -- Classification = 'Pre-tax'

--hr_utility.trace_off;
hr_utility.set_location('pyusddwp.ins_deduction_template',110);

RETURN l_ele_id;

end ins_deduction_template;

end hr_user_dedn_drv;


/
