--------------------------------------------------------
--  DDL for Package Body HR_GENERATE_PRETAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GENERATE_PRETAX" AS
/* $Header: pygenptx.pkb 115.16 2002/12/28 01:15:16 meshah ship $ */

/*
+======================================================================+
| Copyright (c) 1993 Oracle Corporation                                |
|                   Redwood Shores, California, USA                    |
|                       All rights reserved.                           |
+======================================================================+

Name		: hr_generate_pretax
Filename	: pygenptx.pkb

Change List
-----------
Date            Name         	Vers    Bug No	Description
-----------     ----          	----    ------	-----------
07-JUN-96	H.Parichabutr	40.0	Created.
22-JUL-1996	HParicha	40.1	373543. Removed comment from exit...
25-JUL-1996	hparicha	40.2	Changes required during SWAMP QA.
					Added category feeds from calculator
					element pay value.
				40.3	Changed handling of call to spr_exists.
13-AUG-1996	hparicha	40.4	No longer sets ben class id on
					Calculator ele...affects link screen.
14-AUG-1996	hparicha	40.5	Added new variable for l_upgrade_mode.
					Upgrade mode is implied by existence
					of the base element.
					Now calls new API to create
					link_input_values,
					element_entry_values,
					and run_result_values if template
					is being upgraded.
					Also, added feeds from Cancel Calc Amount
					to same feeds as base pay value - ie. cat feeds.
					Also, Coverage iv for benefits is no longer mandatory.
..-SEP-1996	hparicha	40.6	373543 - again...rework of solution
					such that 2 separate element entries
					are not required for processing of
					pre-tax deductions.

3rd Oct 1996	hparicha	40.7	398791 - Passing new parameter
					to hr_template_existence functions.
					which now uses start date of element
					in existence comparisons.

4th Nov 1996	hparicha	40.8	Fixes to base input values creation.
					Names and l_num_base_ivs not set
					correctly for start rule inputs.
					Found and corrected during
					customer upgrade of ptx dedns
					in Megapatch 9.

6th Nov 1996	hparicha	40.9	413211. Minor fixes concerning
					deletion of ptx dedns...namely,
					ensuring legislation code on
					formula record is null (not US).
14 Nov 1996 hparicha   40.10	419766	Withholding element is nonrecurring
					and needed std link flag set to No,
					instead of using param for std link
					for base element.
04 Jan 1997 tzlacey    40.11            Removed line between create package
					and header.
21 Jan 1997 hparicha   40.12           Making changes for new pretax
                                       configuration (M9 cleanup).
10 Jul 1997 mmukherj   40.15   502307  Updated do_defined_balances
                                       procedure.Included business_group_id
                                       in where condition while checking
                                       pay_defined_balnce has already exist
                                       for that balance_name for that busines_
                                       group_id or not
21 Jul 1997 mmukherj    40.16          Added some comments in do_defined_balances
                                       procedure related to Bug no 502307.  No
                                       other change in the code. Changed the
                                       select statement of the same proceduer
                                       to avoid using index on
                                       business_group_id.
30 Apr 1998 pmadore     40.17          Added additonal input values, formula
                                       result rules, elements, and balances to
                                       support the Employer match components
                                       of a pretax deduction in category of
                                       Deferred Comp 401k.
                                       The logic to create these objects
                                       depends upon the values of a new
                                       parameter to the main package function:
                                       p_ele_er_match
10 Mar 1999 ahanda      40.19          Changed GRE_ITD to ASG_ITD as GRE_ITD
                                       is already there in suffixes(26) and
                                       ASG_ITD is missing in the
                                       pretax_deduction_template. Bug 820068
16-jun-1999 achauhan   110.10          Replaced dbms_output with hr_utility
09-jul-1999 vmehta     110.11          Added check for legislation_code
                                       while retrieving classification for
                                       employer match   BUG 912994
27-oct-1999 dscully                    Added check for legislation_code while
                                       looking up skip rules
12-Jul-2000 kthirmiy   110.14          Added ELEMENT_INFORMATION_CATEGORY=
                                             'US_EMPLOYER LIABILITIES'
                                       while updating PAY_ELEMENT_TYPES_F for
                                       pretax ER element to show the desc flex
                                       field in the element description screen
                                       for pretax ER element
*******************************************************************************
22-JAN-2002 ahanda     115.13          Added call to create defined bal for
                                       Assignment Payments.
23-DEC-2002 tclewis    115.15          11.5.9 performance fixes and inspected
                                       file to add nocopy directive.  I found
                                       no procedures requireing it.
27-DEC-2002 meshah     115.16          fixed gscc warnings/errors.
*******************************************************************************/

/*
This package contains calls to core API used to insert records comprising an
entire pretax deduction template.  Migration to published (ie. supported) api
from core is an essential move when these become available.

The procedures responsible for creating
appropriate records based on data entered on the Deductions form
must perform simple logic to determine the exact attributes required for the
deductions template.  We do this to keep extraneous information
to a minimum - especially regarding input values and formula
result rules.  Attributes (and their determining factors) are:

- skip rules (Classification)
- status processing rules (Calculation Method)
- input values (Classification/Category, Calculation Method)
- formula result rules (Calculation Method)
*/

--
------------------------- upgrade_deduction_template ------------------------
--

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
		p_bg_id			in number) RETURN NUMBER IS

-- global vars

TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
TYPE num_table IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;

g_eff_start_date	date;
g_eff_end_date		date;

g_invol_class_name		varchar2(80)	:= 'INVOLUNTARY DEDUCTIONS';
g_arrears_contr_inpval_id	NUMBER(9);
g_adj_arrears_inpval_id		NUMBER(9);
g_to_tot_inpval_id		NUMBER(9);
g_topurch_inpval_id		NUMBER(9);
g_ele_info_cat			VARCHAR2(30);

  dedn_iv_seq	number;
  dedn_base_seq	number;
  dedn_wh_seq	number;
  dedn_er_seq	number;


  dedn_ele_names	text_table;
  dedn_ele_repnames	text_table;
  dedn_ele_class	text_table;
  dedn_ele_cat		text_table;
  dedn_ele_proc_type	text_table;
  dedn_ele_desc		text_table;
  dedn_ele_priority	num_table;
  dedn_indirect_only	text_table;
  dedn_ele_start_rule   text_table;
  dedn_mix_category	text_table;
  dedn_ot_base		text_table;
  dedn_std_link		text_table;
  dedn_pay_formula	text_table;
  dedn_skip_formula	text_table;
  dedn_ele_ids		num_table;
  dedn_statproc_rule_id	num_table;
  dedn_third_party_pay  text_table;
  dedn_payval_id        num_table;

  dedn_wh_frr_name	text_table;
  dedn_wh_frr_type	text_table;
  dedn_wh_frr_ele_id	num_table;
  dedn_wh_frr_iv_id	num_table;
  dedn_wh_frr_severity	text_table;

  dedn_calc_frr_name	text_table;
  dedn_calc_frr_type	text_table;
  dedn_calc_frr_ele_id	num_table;
  dedn_calc_frr_iv_id	num_table;
  dedn_calc_frr_severity	text_table;

  dedn_base_feed_iv_id	num_table;
  dedn_base_feed_bal_id	num_table;

  dedn_si_feed_iv_id	num_table;
  dedn_si_feed_bal_id	num_table;

  dedn_sf_feed_iv_id	num_table;
  dedn_sf_feed_bal_id	num_table;

  l_num_wh_resrules	number;
  l_num_calc_resrules	number;

  l_num_base_feeds	number;
  l_num_si_feeds      	number;
  l_num_sf_feeds      	number;
  l_num_er_feeds      	number;


  dedn_assoc_bal_names	text_table;
  dedn_assoc_bal_rep_names  text_table;
  dedn_assoc_bal_uom	text_table;
  dedn_assoc_bal_ids	num_table;

  dedn_base_iv_names	text_table;
  dedn_base_iv_seq	num_table;
  dedn_base_iv_mand	text_table;
  dedn_base_iv_uom	text_table;
  dedn_base_iv_dbi	text_table;
  dedn_base_iv_lkp	text_table;
  dedn_base_iv_dflt	text_table;
  dedn_base_iv_ids	num_table;

  dedn_wh_iv_names	text_table;
  dedn_wh_iv_seq	num_table;
  dedn_wh_iv_mand	text_table;
  dedn_wh_iv_uom	text_table;
  dedn_wh_iv_dbi	text_table;
  dedn_wh_iv_lkp	text_table;
  dedn_wh_iv_dflt	text_table;
  dedn_wh_iv_ids	num_table;

  dedn_si_iv_names	text_table;
  dedn_si_iv_seq	num_table;
  dedn_si_iv_mand	text_table;
  dedn_si_iv_uom	text_table;
  dedn_si_iv_dbi	text_table;
  dedn_si_iv_lkp	text_table;
  dedn_si_iv_dflt	text_table;
  dedn_si_iv_ids	num_table;

  dedn_sf_iv_names	text_table;
  dedn_sf_iv_seq	num_table;
  dedn_sf_iv_mand	text_table;
  dedn_sf_iv_uom	text_table;
  dedn_sf_iv_dbi	text_table;
  dedn_sf_iv_lkp	text_table;
  dedn_sf_iv_dflt	text_table;
  dedn_sf_iv_ids	num_table;

  dedn_er_iv_names	text_table;
  dedn_er_iv_seq	num_table;
  dedn_er_iv_mand	text_table;
  dedn_er_iv_uom	text_table;
  dedn_er_iv_dbi	text_table;
  dedn_er_iv_lkp	text_table;
  dedn_er_iv_dflt	text_table;
  dedn_er_iv_ids	num_table;


  l_num_eles		number;

  l_num_assoc_bals	number;

  l_num_base_ivs	number;
  l_num_wh_ivs		number;
  l_num_si_ivs		number;
  l_num_sf_ivs		number;
  l_num_er_ivs		number;


  h			number;
  x			number;
  i			number;
  k			number;
  m			number;
  n			number;
  o			number;
  p			number;
  q			number;
  r			number;
  s			number;
  t			number;
  c			number;
  vf			number;
  sif			number;
  scf			number;
  sf			number;
  siv			number;
  sfv			number;
  l			number;


  already_exists      	number;

-- local constants

 c_end_of_time  CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');

-- local vars

v_bg_name		VARCHAR2(60);	-- Get from bg short name passed in.
v_ele_type_id		NUMBER(9); 	-- insertion of element type.
v_primary_class_id	NUMBER(9);
v_class_lo_priority	NUMBER(9);
v_class_hi_priority	NUMBER(9);
v_shadow_ele_type_id	NUMBER(9); -- Populated by insertion of element type.
v_shadow_ele_name	VARCHAR2(80); -- Name of shadow element type.
v_inputs_ele_type_id	NUMBER(9); -- Populated by insertion of element type.
v_inputs_ele_name	VARCHAR2(80); -- Name of shadow element type.
v_ele_repname		VARCHAR2(30);
v_bal_type_id		NUMBER(9);	-- Pop'd by insertion of balance type.
v_dedn_bal_uom		VARCHAR2(30)	:= 'M';
v_balance_name		VARCHAR2(80);	-- Additional balances req'd by dedn.
v_bal_rpt_name		VARCHAR2(30);
v_bal_dim		VARCHAR2(80);
v_inpval_id		NUMBER(9);
v_payval_id		NUMBER(9);	-- ID of payval for bal feed insert.
v_payval_name		VARCHAR2(80);	-- Name of payval.
v_pay_value_name	VARCHAR2(80);	-- Name of payval for this legislation.
v_shadow_info_payval_id	NUMBER(9);
v_inputs_info_payval_id	NUMBER(9);
v_payval_formula_id	NUMBER(9); -- ID of formula for payvalue validation.
v_totowed_bal_type_id	NUMBER(9);
v_eepurch_bal_type_id	NUMBER(9);
v_arrears_bal_type_id	NUMBER(9);
v_notaken_bal_type_id	NUMBER(9);
v_able_bal_type_id	NUMBER(9);
v_sect125_bal_type_id	NUMBER(9);
v_401k_bal_type_id	NUMBER(9);
v_topurch_eletype_id	NUMBER(9);
v_er_charge_eletype_id	NUMBER(9);
v_er_charge_baltype_id	NUMBER(9);
v_er_charge_payval_id	NUMBER(9); -- inpval id of ER charge PAY VALUE.
v_topurch_ele_name	VARCHAR2(80);
v_er_charge_ele_name	VARCHAR2(80);
v_skip_formula_id	NUMBER(9);

l_invol_dflt_prio	number(9);
l_wh_ele_priority	number(9);
v_emp_liab_dflt_prio	number(9);

l_iv_defaults_ff_text	varchar2(32000);
l_calc_dedn_ff_text	varchar2(32000);
l_placeholder_ele_name	varchar2(80);

l_upgrade_mode		varchar2(1) := 'N';

l_reg_earn_classification_id 	number(9);
l_reg_earn_business_group_id	number(15);
l_reg_earn_legislation_code	varchar2(30);
l_reg_earn_balance_type_id	number(9);
l_reg_earn_input_value_id	number(9);
l_reg_earn_scale		number(5);
l_reg_earn_element_type_id	number(9);

cursor get_reg_earn_feeds(p_bg_id number) is
SELECT /*+ no_merge(pbf) */
       bc.CLASSIFICATION_ID, pbf.BUSINESS_GROUP_ID,
       pbf.LEGISLATION_CODE, pbf.BALANCE_TYPE_ID,
       pbf.INPUT_VALUE_ID, pbf.SCALE, pbf.ELEMENT_TYPE_ID
FROM PAY_BALANCE_FEEDS_V pbf,
     pay_balance_classifications bc
WHERE NVL(pbf.BALANCE_INITIALIZATION_FLAG,'N') = 'N'
AND ((pbf.BUSINESS_GROUP_ID IS NULL OR pbf.BUSINESS_GROUP_ID = p_bg_id)
      AND (pbf.LEGISLATION_CODE IS NULL OR pbf.LEGISLATION_CODE = 'US'))
and (pbf.BALANCE_NAME = 'Regular Earnings')
and bc.balance_type_id = pbf.balance_type_id
order by pbf.element_name;

PROCEDURE do_defined_balances (	p_bal_name	IN VARCHAR2,
				p_bg_name	IN VARCHAR2,
				p_no_payments	IN BOOLEAN default FALSE) IS

-- local vars

TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  suffixes	text_table;
  dim_id	number(9);
  dim_name	varchar2(80);
  num_suffixes  number;

  already_exists 	number;
  v_business_group_id number;

BEGIN

hr_utility.set_location('hr_generate_pretax.do_defined_balances ',10);

suffixes(1)  := '_ASG_RUN';
suffixes(2)  := '_ASG_PTD';
suffixes(3)  := '_ASG_MONTH';
suffixes(4)  := '_ASG_QTD';
suffixes(5)  := '_ASG_YTD';
suffixes(6)  := '_ASG_GRE_RUN';
suffixes(7)  := '_ASG_GRE_PTD';
suffixes(8)  := '_ASG_GRE_MONTH';
suffixes(9)  := '_ASG_GRE_QTD';
suffixes(10) := '_ASG_GRE_YTD';

suffixes(11) := '_PER_RUN';
suffixes(12) := '_PER_MONTH';
suffixes(13) := '_PER_QTD';
suffixes(14) := '_PER_YTD';
suffixes(15) := '_PER_GRE_RUN';
suffixes(16) := '_PER_GRE_MONTH';
suffixes(17) := '_PER_GRE_QTD';
suffixes(18) := '_PER_GRE_YTD';

suffixes(19) := '_PAYMENTS';

suffixes(20) := '_ASG_GRE_LTD';
suffixes(21) := '_ASG_LTD';

suffixes(22) := '_PER_GRE_LTD';
suffixes(23) := '_PER_LTD';

/* WWBug 133133 start */

/* Add defbals required for company level, summary reporting. */

suffixes(24) := '_GRE_RUN';
suffixes(25) := '_GRE_YTD';
suffixes(26) := '_GRE_ITD';

/* WWBug 350540 start */
/* Need defbals on arrears bal for ASG_GRE_ITD and GRE_ITD. */

suffixes(27) := '_ASG_GRE_ITD';

/* Changed GRE_ITD to ASG_ITD as GRE_ITD is already there in
   suffixes(26) and ASG_ITD is missing. Bug 820068 */

suffixes(28) := '_ASG_ITD';
suffixes(29) := '_ASG_PAYMENTS';

num_suffixes := 29;

  select business_group_id
  into   v_business_group_id
  from   per_business_groups
  where  upper(name) = upper(p_bg_name);

/* WWBug 133133, 350540 finish */

    for i in 1..num_suffixes loop

      hr_utility.set_location('hr_generate_pretax.do_defined_balances ',20);

      select dimension_name, balance_dimension_id
      into dim_name, dim_id
      from pay_balance_dimensions
      where database_item_suffix = suffixes(i)
      and legislation_code = g_template_leg_code
      and business_group_id IS NULL;

      hr_utility.set_location('hr_generate_pretax.do_defined_balances ',30);

/* added line to include business_group_id in the where clause of the select
statement below. So that it checkes the existence of data for a the given
business_group_id Bug No: 502307.
*/
      SELECT	count(0)
      INTO  	already_exists
      FROM  	pay_defined_balances 	db,
            	pay_balance_types 	bt
      WHERE  	db.balance_type_id 	= bt.balance_type_id
      AND  	upper(bt.balance_name) 	= upper(p_bal_name)
      AND       bt.business_group_id + 0  = v_business_group_id
      AND  	db.balance_dimension_id	= dim_id;

      if (already_exists = 0) then

       IF p_no_payments = TRUE and suffixes(i) = '_PAYMENTS' THEN

         hr_utility.set_location('hr_generate_pretax.do_defined_balances ',40);

         NULL;

       ELSE

         hr_utility.set_location('hr_generate_pretax.do_defined_balances ',50);

         pay_db_pay_setup.create_defined_balance(
		p_balance_name 		=> p_bal_name,
		p_balance_dimension 	=> dim_name,
		p_business_group_name 	=> p_bg_name,
		p_legislation_code 	=> NULL);

       END IF;

     end if;

    end loop;

    hr_utility.set_location('hr_generate_pretax.do_defined_balances ',60);

END do_defined_balances;

--
---------------------------- ins_dedn_ele_type -------------------------------
--

FUNCTION ins_dedn_ele_type (	p_ele_name 		in varchar2,
				p_ele_reporting_name 	in varchar2,
				p_ele_description 	in varchar2,
				p_ele_class 		in varchar2,
				p_ele_category 		in varchar2,
				p_ele_start_rule	in varchar2,
				p_ele_processing_type 	in varchar2,
				p_ele_priority 		in number,
				p_ele_standard_link 	in varchar2,
				p_skip_formula_id	in number default NULL,
				p_ind_only_flag		in varchar2,
				p_ele_eff_start_date	in date,
				p_ele_eff_end_date	in date,
				p_bg_name		in varchar2,
				p_bg_id			in number) RETURN number IS

-- local vars


ret			NUMBER;
v_mult_entries_allowed	VARCHAR2(1)	:= 'N';
v_third_ppm		VARCHAR2(30)	:= 'N';

already_exists		number;

BEGIN

hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',10);

IF p_ele_processing_type = 'N' THEN

  hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',20);

  v_mult_entries_allowed := 'Y';

END IF;

hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',50);

already_exists := hr_template_existence.ele_exists(
					p_ele_name	=> p_ele_name,
					p_bg_id		=> p_bg_id,
					p_eff_date	=> p_ele_eff_start_date);

if already_exists = 0 then

  hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',55);

  ret := pay_db_pay_setup.create_element(
		p_element_name 		=> p_ele_name,
		p_description 		=> p_ele_description,
		p_classification_name 	=> p_ele_class,
		p_post_termination_rule	=> 'Final Close',
		p_reporting_name	=> p_ele_reporting_name,
		p_processing_type	=> p_ele_processing_type,
		p_mult_entries_allowed	=> v_mult_entries_allowed,
		p_indirect_only_flag	=> p_ind_only_flag,
		p_formula_id 		=> p_skip_formula_id,
		p_processing_priority	=> p_ele_priority,
		p_standard_link_flag	=> p_ele_standard_link,
		p_business_group_name	=> p_bg_name,
		p_effective_start_date 	=> p_ele_eff_start_date,
		p_effective_end_date	=> p_ele_eff_end_date,
		p_legislation_code 	=> NULL,
		p_third_party_pay_only	=> v_third_ppm);

   hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',80);

else

   hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',90);

   if p_ele_name = dedn_ele_names(1) then

-- Base element already exists, this MUST be called via upgrade mechanism.
-- Set upgrade mode flag for addition of input values, link input values, entry values,
-- and run result values.

     l_upgrade_mode := 'Y';

   end if;

   ret := already_exists;

end if;

hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',100);

RETURN ret;

EXCEPTION WHEN NO_DATA_FOUND THEN

  hr_utility.set_location('hr_generate_pretax.ins_dedn_ele_type',999);

  RETURN ret;

END ins_dedn_ele_type;


--
------------------------- ins_base_formula -----------------------
--
FUNCTION ins_base_formula (	p_ff_ele_name	in varchar2,
				p_spr_ele_name	in varchar2,
				p_ff_desc	in varchar2,
				p_ff_bg_id	in number)
				RETURN NUMBER IS

-- Note, the ff_ele_name is used for ele name placeholder substitution in formula text...
-- ie. the base element name...while the spr ele name is the element this formula
-- will be attached to...

v_formula_id			number;		-- Return var.
v_skeleton_formula_text		VARCHAR2(32000);
v_skeleton_formula_type_id	NUMBER(9);
v_orig_ele_formula_id		NUMBER(9);
v_orig_ele_formula_name		VARCHAR2(80);
v_orig_ele_formula_text		varchar2(32000);
v_new_ele_formula_id		NUMBER(9);
v_new_ele_formula_name		VARCHAR2(80);
v_new_ele_formula_text		VARCHAR2(32000);
v_ele_name			VARCHAR2(80);
v_new_ele_name			varchar2(80);

l_placehold_ele_name	varchar2(80);
l_count_already		number;
already_exists		number;

BEGIN

  hr_utility.set_location('hr_generate_pretax.ins_base_formula',10);

  SELECT 	FF.formula_text,
		FF.formula_type_id
  INTO		v_skeleton_formula_text,
 		v_skeleton_formula_type_id
  FROM		ff_formulas_f	FF
  WHERE		FF.formula_name		= 'PRETAX_WITHHOLDING_FORMULA'
  AND		FF.business_group_id 	IS NULL
  AND		FF.legislation_code	= 'US'
  AND		g_eff_start_date	>= FF.effective_start_date
  AND		g_eff_start_date	<= FF.effective_end_date;

-- Replace element name placeholders with current element name:

  hr_utility.set_location('hr_generate_pretax.ins_base_formula',15);

  l_placehold_ele_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');
  v_new_ele_formula_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');
  v_new_ele_formula_text := REPLACE(	v_skeleton_formula_text,
					'<ELE_NAME>',
					v_new_ele_formula_name);

  v_new_ele_formula_name := v_new_ele_formula_name || '_WITHHOLDING';
  v_new_ele_formula_name := SUBSTR(v_new_ele_formula_name, 1, 80);

-- Call function to check existence of formula to get id.
-- Get original formula id, name, and text for this element currently,
-- ie. before putting in new ff text.

hr_utility.set_location('hr_generate_pretax.ins_base_formula',20);

already_exists := hr_template_existence.ele_ff_exists(
				p_ele_name	=> p_spr_ele_name,
				p_bg_id		=> p_ff_bg_id,
				p_ff_name	=> v_orig_ele_formula_name,
				p_ff_text	=> v_orig_ele_formula_text,
				p_eff_date	=> g_eff_start_date);

if already_exists = 0 then

-- Insert the new formula text into current business group since
-- there is no formula for this element currently.
--
-- Get new id for formula

hr_utility.set_location('hr_generate_pretax.ins_base_formula',30);

  SELECT 	ff_formulas_s.nextval
  INTO		v_new_ele_formula_id
  FROM	 	sys.dual;

  hr_utility.set_location('hr_generate_pretax.ins_base_formula',40);

-- hr_utility.trace('Inserting ff '||v_new_ele_formula_name||' for ele '||p_ff_ele_name);

  INSERT INTO ff_formulas_f (	FORMULA_ID,
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
	v_new_ele_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_ff_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_new_ele_formula_name,
	p_ff_desc,
	v_new_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	g_eff_start_date);

else

-- Element already has formula attached via stat proc rule...
-- original formula name and text have been populated as outputs
-- from check for existence.

    hr_utility.set_location('hr_generate_pretax.ins_base_formula',50);

    v_new_ele_formula_id := already_exists;

-- Update existing formula with new ff name and text.

--   hr_utility.trace('existing FF '||v_new_ele_formula_id||' being updated');
--  hr_utility.trace(v_new_ele_formula_name);

   hr_utility.set_location('hr_generate_pretax.ins_base_formula',70);

/*
    UPDATE	ff_formulas_f
    SET		formula_name	= v_new_ele_formula_name,
		formula_text	= v_new_ele_formula_text
    WHERE	formula_id	= v_new_ele_formula_id
    AND		business_group_id = p_ff_bg_id
    AND		g_eff_start_date BETWEEN effective_start_date
                                                         AND effective_end_date;
*/
    UPDATE	ff_formulas_f
    SET		formula_text	= v_new_ele_formula_text
    WHERE	formula_id	= v_new_ele_formula_id
    AND		business_group_id = p_ff_bg_id
    AND		g_eff_start_date BETWEEN effective_start_date
                                                         AND effective_end_date;

--
-- Insert the original formula into current business group to preserve customer mods.
--
-- hr_utility.trace('FF '||v_orig_ele_formula_name||' already exists for ele '||p_ff_ele_name);

select count(0)
into l_count_already
from ff_formulas_f
where upper(formula_name) like upper('%'||l_placehold_ele_name||'%');


  hr_utility.set_location('hr_generate_pretax.ins_base_formula',35);

-- hr_utility.trace('Preserving text for '||v_orig_ele_formula_name);

  v_orig_ele_formula_name := 'OLD'||l_count_already||'_'||v_orig_ele_formula_name;
  v_orig_ele_formula_name := substr(v_orig_ele_formula_name,1,80);

-- hr_utility.trace('Renamed ff name is '||v_orig_ele_formula_name);

  hr_utility.set_location('hr_generate_pretax.ins_base_formula',30);

  SELECT 	ff_formulas_s.nextval
  INTO		v_orig_ele_formula_id
  FROM	 	sys.dual;

  hr_utility.set_location('hr_generate_pretax.ins_base_formula',40);

 INSERT INTO ff_formulas_f (	FORMULA_ID,
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
 	v_orig_ele_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_ff_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_orig_ele_formula_name,
	p_ff_desc,
	v_orig_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	g_eff_start_date);

end if;

return v_new_ele_formula_id;

EXCEPTION WHEN NO_DATA_FOUND THEN NULL;

END ins_base_formula;



--
------------------------- ins_calc_formula -----------------------
--

FUNCTION ins_calc_formula (
			p_ff_ele_name		in varchar2,
			p_spr_ele_name		in varchar2,
			p_ff_suffix		in varchar2,
			p_ff_desc		in varchar2,
			p_ff_bg_id		in number,
			p_amt_rule		in varchar2 default NULL,
			p_row_type		in varchar2 default NULL,
			p_iv_dflts_text		in varchar2 default ' ',
			p_calc_dedn_text	in varchar2)
			RETURN number IS

-- Note, the ff_ele_name is used for ele name placeholder substitution in formula text...
-- ie. the base element name...while the spr ele name is the element this formula
-- will be attached to...

-- local vars

v_formula_id			number;		-- Return var.
v_skeleton_formula_text		VARCHAR2(32000);
v_skeleton_formula_type_id	NUMBER(9);
v_orig_ele_formula_text		VARCHAR2(32000);
v_new_ele_formula_text		VARCHAR2(32000);
v_orig_ele_formula_name		VARCHAR2(80);
v_new_ele_formula_name		VARCHAR2(80);
v_orig_ele_formula_id		NUMBER(9);
v_new_ele_formula_id		NUMBER(9);
v_ele_name			VARCHAR2(80);

l_placehold_ele_name	varchar2(80);
l_count_already		number;
already_exists		number;

BEGIN

  hr_utility.set_location('hr_generate_pretax.ins_calc_formula',10);

  SELECT 	FF.formula_text,
		FF.formula_type_id
  INTO		v_skeleton_formula_text,
 		v_skeleton_formula_type_id
  FROM		ff_formulas_f	FF
  WHERE	FF.formula_name	= 'PRETAX_CALCULATION_FORMULA'
  AND		FF.business_group_id 	IS NULL
  AND		FF.legislation_code	= 'US'
  AND		g_eff_start_date 		>= FF.effective_start_date
  AND		g_eff_start_date		<= FF.effective_end_date;

-- Replace element name placeholders with current element name:

  hr_utility.set_location('hr_generate_pretax.ins_calc_formula',15);

  l_placehold_ele_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');
  v_new_ele_formula_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');
  v_new_ele_formula_text := REPLACE(	v_skeleton_formula_text,
					'<ELE_NAME>',
					v_new_ele_formula_name);

/* No longer required with 40.6 :
-- Make replacements for input entry value defaults
  v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<IV_ENTRY_VALUE_DEFAULTS_SECTION>',
					p_iv_dflts_text);
*/

-- Make replacement for deduction calculation section
  v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<CALC_DEDN_AMOUNT_FF_TEXT>',
					p_calc_dedn_text);

--
-- Make <ROW_TYPE> replacements if necessary.
--

  IF p_amt_rule = 'PT' THEN

    IF p_row_type NOT IN ('Salary Range', 'Age Range') THEN

      hr_utility.set_location('hr_generate_pretax.ins_calc_formula',17);

      v_new_ele_formula_text := REPLACE(v_new_ele_formula_text,
				 	'<ROW_TYPE>',
					REPLACE(LTRIM(RTRIM(p_row_type)),' ','_'));

      hr_utility.set_location('hr_generate_pretax.ins_calc_formula',19);

      v_new_ele_formula_text := REPLACE(v_new_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					'default for ' || REPLACE(LTRIM(RTRIM(p_row_type)),' ','_') || ' (text) is ''NOT ENTERED''');

      hr_utility.set_location('hr_generate_pretax.ins_calc_formula',21);

      v_new_ele_formula_text := REPLACE(v_new_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					',' || REPLACE(LTRIM(RTRIM(p_row_type)),' ','_') || ' (text)');

    ELSE

      hr_utility.set_location('hr_generate_pretax.ins_calc_formula',20);

      v_new_ele_formula_text := REPLACE(v_new_ele_formula_text,
					'<ROW_TYPE>',
					'To_Char(PER_AGE)');

      hr_utility.set_location('hr_generate_pretax.ins_calc_formula',22);

      v_new_ele_formula_text := REPLACE(v_new_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					' ');

      hr_utility.set_location('hr_generate_pretax.ins_calc_formula',24);

      v_new_ele_formula_text := REPLACE(v_new_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					' ');

    END IF;

--
--  "Zero" benefits
--
      hr_utility.set_location('hr_user_init_dedn.ins_formula',23);
     v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					l_placehold_ele_name || '_BEN_EE_CONTR_VALUE',
					'0');

     v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					l_placehold_ele_name || '_BEN_ER_CONTR_VALUE',
					'0');

     v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<DEFAULT_BEN_EE_LINE>',
					' ');

     v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<DEFAULT_BEN_ER_LINE>',
					' ');

  ELSIF p_amt_rule = 'BT' THEN

--
--  Using benefits, <ELE_NAME>_BEN_EE_CONTR_VALUE is already taken care of.
--
    hr_utility.set_location('hr_user_init_dedn.ins_formula',25);
    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<DEFAULT_BEN_EE_LINE>',
					'default for ' || l_placehold_ele_name || '_BEN_EE_CONTR_VALUE is 0');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<DEFAULT_BEN_ER_LINE>',
					'default for ' || l_placehold_ele_name || '_BEN_ER_CONTR_VALUE is 0');

-- Clear out <ROW_TYPE>
    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
				 	'<ROW_TYPE>',
					'''NOT ENTERED''');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					' ');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					' ');

  ELSE

--
-- Clear out everything!
-- Clear out <ROW_TYPE>
    hr_utility.set_location('hr_user_init_dedn.ins_formula',27);
    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
				 	'<ROW_TYPE>',
					'''NOT ENTERED''');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					' ');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					' ');

--
--  "Zero" benefits
--
    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					l_placehold_ele_name || '_BEN_EE_CONTR_VALUE',
					'0');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					l_placehold_ele_name || '_BEN_ER_CONTR_VALUE',
					'0');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<DEFAULT_BEN_EE_LINE>',
					' ');

    v_new_ele_formula_text := REPLACE(	v_new_ele_formula_text,
					'<DEFAULT_BEN_ER_LINE>',
					' ');

  END IF;

  v_new_ele_formula_name := v_new_ele_formula_name || UPPER(p_ff_suffix);
  v_new_ele_formula_name := SUBSTR(v_new_ele_formula_name, 1, 80);

-- Call function to check existence of formula to get id.
-- Get original formula id, name, and text for this element currently,
-- ie. before putting in new ff text.

hr_utility.set_location('hr_generate_pretax.ins_calc_formula',20);

already_exists := hr_template_existence.ele_ff_exists(
				p_ele_name	=> p_spr_ele_name,
				p_bg_id		=> p_ff_bg_id,
				p_ff_name	=> v_orig_ele_formula_name,
				p_ff_text	=> v_orig_ele_formula_text,
				p_eff_date	=> g_eff_start_date);

if already_exists = 0 then

-- Insert the new formula text into current business group since
-- there is no formula for this element currently.
--
-- Get new id for formula

hr_utility.set_location('hr_generate_pretax.ins_calc_formula',30);

  SELECT 	ff_formulas_s.nextval
  INTO		v_new_ele_formula_id
  FROM	 	sys.dual;

  hr_utility.set_location('hr_generate_pretax.ins_calc_formula',40);

  INSERT INTO ff_formulas_f (	FORMULA_ID,
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
	v_new_ele_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_ff_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_new_ele_formula_name,
	p_ff_desc,
	v_new_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	g_eff_start_date);

else

-- Element already has formula attached via stat proc rule...
-- original formula name and text have been populated as outputs
-- from check for existence.

    hr_utility.set_location('hr_generate_pretax.ins_calc_formula',50);

    v_new_ele_formula_id := already_exists;

-- Update existing formula with new ff name and text.

   hr_utility.set_location('hr_generate_pretax.ins_calc_formula',70);

--  hr_utility.trace('existing FF '||v_new_ele_formula_id||' being updated');
--  hr_utility.trace(v_new_ele_formula_name);

/* Hitting constraint error FF_FORMULAS_F_UK2 with...
    UPDATE	ff_formulas_f
    SET		formula_name	= v_new_ele_formula_name,
		formula_text	= v_new_ele_formula_text
    WHERE	formula_id	= v_new_ele_formula_id
    AND		business_group_id = p_ff_bg_id
    AND		g_eff_start_date BETWEEN effective_start_date
                                                         AND effective_end_date;
*/
-- So trying without updating ff name...
    UPDATE	ff_formulas_f
    SET		formula_text	= v_new_ele_formula_text
    WHERE	formula_id	= v_new_ele_formula_id
    AND		business_group_id = p_ff_bg_id
    AND		g_eff_start_date BETWEEN effective_start_date
                                                         AND effective_end_date;

--
-- Insert the original formula into current business group to preserve customer mods.
--
-- hr_utility.trace('FF '||v_orig_ele_formula_name||' already exists for ele '||p_ff_ele_name);

select count(0)
into l_count_already
from ff_formulas_f
where upper(formula_name) like upper('%'||l_placehold_ele_name||'%');

-- hr_utility.trace('Preserving text for '||v_orig_ele_formula_name);

  hr_utility.set_location('hr_generate_pretax.ins_calc_formula',80);

  v_orig_ele_formula_name := 'OLD'||l_count_already||'_'||v_orig_ele_formula_name;
  v_orig_ele_formula_name := substr(v_orig_ele_formula_name,1,80);

-- hr_utility.trace('Original formula now in ff called '||v_orig_ele_formula_name);

  hr_utility.set_location('hr_generate_pretax.ins_calc_formula',90);

  SELECT 	ff_formulas_s.nextval
  INTO		v_orig_ele_formula_id
  FROM	 	sys.dual;

  hr_utility.set_location('hr_generate_pretax.ins_calc_formula',100);

 INSERT INTO ff_formulas_f (	FORMULA_ID,
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
 	v_orig_ele_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_ff_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_orig_ele_formula_name,
	p_ff_desc,
	v_orig_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	g_eff_start_date);

end if;

RETURN v_new_ele_formula_id;

EXCEPTION WHEN NO_DATA_FOUND THEN

  NULL;

END ins_calc_formula;


--
------------------------- ins_dedn_formula_processing -----------------------
--

PROCEDURE ins_dedn_formula_processing (
				p_ele_name 		in varchar2,
				p_primary_class_id	in number,
				p_ele_class_name	in varchar2,
				p_ele_cat		in varchar2,
				p_ele_proc_type		in varchar2,
				p_amount_rule 		in varchar2,
				p_proc_runtype	 	in varchar2 	default 'R',
				p_start_rule		in varchar2	default NULL,
				p_stop_rule		in varchar2	default NULL,
				p_ee_bond		in varchar2	default 'N',
				p_paytab_name		in varchar2	default NULL,
				p_paytab_col		in varchar2	default NULL,
				p_paytab_row_type	in varchar2	default NULL,
				p_arrearage		in varchar2	default 'N',
				p_partial_dedn		in varchar2	default 'N',
				p_er_charge_eletype_id	in number	default NULL,
				p_er_charge_payval_id	in number	default NULL,
				p_bg_id 			in number,
				p_mix_category		in varchar2	default NULL,
				p_eff_start_date 		in date 		default NULL,
				p_eff_end_date 		in date 		default NULL,
				p_bg_name 		in varchar2) IS

-- local vars

v_fname			VARCHAR2(80);
v_ftype_id		NUMBER(9);
v_fdesc			VARCHAR2(240);
v_ftext			VARCHAR2(32000); -- "Safe" max length of varchar2.
v_sticky_flag		VARCHAR2(1);
v_asst_status_type_id 	NUMBER(9)	:= NULL;
v_stat_proc_rule_id	NUMBER(9);
v_fres_rule_id		NUMBER(9);
v_proc_rule		VARCHAR2(1) := 'P'; -- Provide "Process" proc rule.
v_calc_rule_formula_id 	NUMBER(9);
v_wh_formula_id 	NUMBER(9);
v_spr_formula_id 	NUMBER(9);
v_er_contr_inpval_id	NUMBER(9); -- inpval id of ER Contr to feed ER chrg.
v_er_payval_id		NUMBER(9); -- paybal id of ER Contr (if not passed in).
v_bondrefund_inpval_id	NUMBER(9); -- inpval id "Bond Refund" to feed DirPay.
v_to_owed_inpval_id	NUMBER(9); -- inpval id for Tot Reached stop rule
v_to_arrears_inpval_id	NUMBER(9); -- inpval id for To Arrears rule
v_notaken_inpval_id	NUMBER(9); -- inpval id for Not Taken (arrears = 'Y')
v_inpval_id		NUMBER(9);
v_inpval_name		VARCHAR2(80);
v_inpval_uom		VARCHAR2(80);
v_ele_sev_level		VARCHAR2(1);
v_gen_dbi		VARCHAR2(1);
v_dflt_value		VARCHAR2(60);
v_amt_rule_formula 	VARCHAR2(80);
v_lkp_type		VARCHAR2(30);
v_val_formula_id	NUMBER(9);
v_class_name		VARCHAR2(80);
v_paytab_id		NUMBER(9);
v_row_code		VARCHAR2(30);
v_age_code		VARCHAR2(30);
v_sal_code		VARCHAR2(30);
v_cre_row_inpval	VARCHAR2(1);
v_user_row_title		VARCHAR2(80);

l_ff_suffix		varchar2(30);
l_ff_desc		varchar2(80);

/*
This procedure performs the following:
. Manually update DDF segments on various associated element types.

Make direct calls to CORE_API packaged procedures to:
. Insert status proc rule of 'PROCESS' for Asst status type 'ACTIVE_ASSIGN'
and appropriate formula according to calculation method
. Setup calculation formula and status proc rule on calculator element.
. Setup withholding formula and status proc rule on base (withholding) element.
. Insert input values according to calculation method
. Insert formula result rules as appropriate for formula and amount rule.

-- In the case of deductions elements, the formulae are fully defined in advance
-- based on calculation rule only.  These pre-packaged formulae are seeded
-- as startup data - such that bg_id is NULL, in the appropriate legislation.
-- The formula_name will closely resemble the calc rule.
-- For deductions, formula is "pieced together" according to calc_rule
-- and other attributes.
-- To copy a formula from seed data to the customer business group, we can
-- select the formula_text LONG field into a VARCHAR2; the LONG field
-- in the table can then accept the VARCHAR2 formula text as long as it
-- does not exceed 32767 bytes (varchar2 will be 32000 to be safe).
*/

BEGIN

-- Check for percentage amount rule...
IF UPPER(p_amount_rule) = 'PE' THEN

-- Set DDF segments

   hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',05);

-- For CALCULATOR ele, set mix flag and ben class if approp...
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= dedn_ele_ids(1)
    AND		business_group_id + 0 		= p_bg_id;

-- For WITHHOLDING element, do not set mix flag or ben class...
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		benefit_classification_id	= NULL
    WHERE	element_type_id 		= dedn_ele_ids(2)
    AND		business_group_id + 0 		= p_bg_id;

hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',05);

    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= dedn_ele_ids(4)
    AND		business_group_id + 0 		= p_bg_id;

hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',05);

    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
   WHERE	element_type_id 		= dedn_ele_ids(3)
   AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',15);

-- Check for payroll table amount rule...
ELSIF UPPER(p_amount_rule) = 'PT' THEN

-- Find table id

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',53);

  SELECT 	user_table_id
  INTO		v_paytab_id
  FROM		pay_user_tables
  WHERE		UPPER(user_table_name) 	= UPPER(p_paytab_name)
  AND		NVL(business_group_id, p_bg_id)	= p_bg_id;

-- Find row code

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',55);

  SELECT	lookup_code
  INTO		v_row_code
  FROM		hr_lookups
  WHERE		UPPER(meaning) 	= UPPER(p_paytab_row_type)
  AND		lookup_type	= 'US_TABLE_ROW_TYPES';

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',57);

-- For CALCULATOR, set mix flag and ben class...
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= dedn_ele_ids(1)
    AND		business_group_id + 0 		= p_bg_id;

-- For WITHHOLDING element, do not set mix flag or ben class...
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code,
		benefit_classification_id	= NULL
    WHERE	element_type_id 		= dedn_ele_ids(2)
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',57);


    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code
    WHERE	element_type_id 		= dedn_ele_ids(4)
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',57);


    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code
    WHERE	element_type_id 		= dedn_ele_ids(3)
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',59);


-- Check for Benefits Table amount rule...
ELSIF UPPER(p_amount_rule) = 'BT' THEN

-- Set mix flag and ben class on CALCULATOR element...
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= dedn_ele_ids(1)
    AND		business_group_id + 0 		= p_bg_id;

-- For WITHHOLDING element, do not set mix flag or ben class...
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		benefit_classification_id	= NULL
    WHERE	element_type_id 		= dedn_ele_ids(2)
    AND		business_group_id + 0 		= p_bg_id;


  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',83);


    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= dedn_ele_ids(4)
    AND		business_group_id + 0 		= p_bg_id;


  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',83);

    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= dedn_ele_ids(3)
    AND		business_group_id + 0 		= p_bg_id;


  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',85);

ELSE
--
-- Default to Flat Amount processing of deduction.
-- Set DDF Segment values:
--

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',81);

-- Set mix flag and ben class on CALCULATOR element...
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= dedn_ele_ids(1)
    AND		business_group_id + 0 		= p_bg_id;

-- Do not set mix flag or ben class on WITHHOLDING element...
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		benefit_classification_id	= NULL
    WHERE	element_type_id 		= dedn_ele_ids(2)
    AND		business_group_id + 0 		= p_bg_id;


  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',81);


    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= dedn_ele_ids(4)
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',81);


    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= dedn_ele_ids(3)
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',15);

END IF; -- Amount rule checks for formula insertion...


/*
Now create calc formula for element by selecting "skeleton" calculation formula
and performing string substitutions for element name in proper placeholders.
The formula is then inserted into the current business group.
Other placeholders will be substituted based on other attributes (ie.
balances and arrears).  When finished, the formula can be compiled.
*/

l_placeholder_ele_name	:= REPLACE(LTRIM(RTRIM(UPPER(p_ele_name))),' ','_');

IF UPPER(p_amount_rule) = 'PE' THEN

  l_iv_defaults_ff_text	:= ' default for '||l_placeholder_ele_name||'_PERCENTAGE_ENTRY_VALUE is 0';

  select ff.formula_text
  into   l_calc_dedn_ff_text
  from   ff_formulas_f ff
  where  ff.formula_name = 'PRETAX_PERCENTAGE_FF_TEXT'
  and    ff.business_group_id is null
  and    ff.legislation_code = 'US'
  and    sysdate between ff.effective_start_date
                     and ff.effective_end_date;

  l_calc_dedn_ff_text := REPLACE(	l_calc_dedn_ff_text,
					'<ELE_NAME>',
					l_placeholder_ele_name);

  l_ff_suffix := '_PERCENTAGE_PTX';
  l_ff_desc   := 'Percentage calculation for deductions.';

 hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',17);

ELSIF UPPER(p_amount_rule) = 'PT' THEN

  l_iv_defaults_ff_text	:= ' default for '||l_placeholder_ele_name||'_TABLE_COLUMN_ENTRY_VALUE IS ''NOT ENTERED'' ';

  IF p_paytab_row_type NOT IN ('Salary Range', 'Age Range') THEN

    hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',75);
    l_iv_defaults_ff_text := l_iv_defaults_ff_text||' default for ' || REPLACE(LTRIM(RTRIM(p_paytab_row_type)),' ','_') || ' (text) is ''NOT ENTERED'' ';

  END IF;

  select ff.formula_text
  into   l_calc_dedn_ff_text
  from   ff_formulas_f ff
  where  ff.formula_name = 'PRETAX_PAYROLL_TABLE_FF_TEXT'
  and    ff.business_group_id is null
  and    ff.legislation_code = 'US'
  and    sysdate between ff.effective_start_date
                     and ff.effective_end_date;

  l_calc_dedn_ff_text := REPLACE(	l_calc_dedn_ff_text,
					'<ELE_NAME>',
					l_placeholder_ele_name);

  l_ff_suffix := '_PAYROLL_PTX';
  l_ff_desc   := 'Payroll table calculation for deductions.';

ELSIF UPPER(p_amount_rule) = 'BT' THEN

  l_iv_defaults_ff_text	:= ' default for '||l_placeholder_ele_name||'_EE_CONTR_ENTRY_VALUE IS 0 ';
  l_iv_defaults_ff_text	:= l_iv_defaults_ff_text||' default for '||l_placeholder_ele_name||'_ER_CONTR_ENTRY_VALUE IS 0 ';
  l_iv_defaults_ff_text	:= l_iv_defaults_ff_text||' default for '||l_placeholder_ele_name||'_COVERAGE_ENTRY_VALUE IS ''NOT ENTERED'' ';

  select ff.formula_text
  into   l_calc_dedn_ff_text
  from   ff_formulas_f ff
  where  ff.formula_name = 'PRETAX_BENEFIT_FF_TEXT'
  and    ff.business_group_id is null
  and    ff.legislation_code = 'US'
  and    sysdate between ff.effective_start_date
                     and ff.effective_end_date;

  l_calc_dedn_ff_text := REPLACE(	l_calc_dedn_ff_text,
					'<ELE_NAME>',
					l_placeholder_ele_name);

  l_ff_suffix := '_BENEFIT_PTX';
  l_ff_desc   := 'Benefit table calculation for deductions.';


ELSE /* Flat Amount calc rule */

  l_iv_defaults_ff_text	:= ' default for '||l_placeholder_ele_name||'_AMOUNT_ENTRY_VALUE IS 0';

  select ff.formula_text
  into   l_calc_dedn_ff_text
  from   ff_formulas_f ff
  where  ff.formula_name = 'PRETAX_FLAT_AMOUNT_FF_TEXT'
  and    ff.business_group_id is null
  and    ff.legislation_code = 'US'
  and    sysdate between ff.effective_start_date
                     and ff.effective_end_date;

  l_calc_dedn_ff_text := REPLACE(	l_calc_dedn_ff_text,
					'<ELE_NAME>',
					l_placeholder_ele_name);

  l_ff_suffix := '_FLAT_PTX';
  l_ff_desc   := 'Flat Amount calculation for deductions.';

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',119);

END IF;


IF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN

  l_iv_defaults_ff_text	:= l_iv_defaults_ff_text||' default for '||l_placeholder_ele_name||'_TOTAL_OWED_ENTRY_VALUE IS 0 ';
  l_iv_defaults_ff_text	:= l_iv_defaults_ff_text||' default for '||l_placeholder_ele_name||'_TOWARDS_OWED_ENTRY_VALUE IS ''NOT ENTERED'' ';

END IF;

--
-- Calculation formula goes on CALCULATION element - ie. base ele.
--
v_calc_rule_formula_id := ins_calc_formula  (
	p_ff_ele_name	=> dedn_ele_names(1),
	p_spr_ele_name	=> dedn_ele_names(1),
	p_ff_suffix	=> l_ff_suffix,
	p_ff_desc	=> l_ff_desc,
	p_ff_bg_id	=> p_bg_id,
	p_amt_rule	=> p_amount_rule,
	p_row_type	=> NULL,
        p_iv_dflts_text => l_iv_defaults_ff_text,
        p_calc_dedn_text => l_calc_dedn_ff_text );

hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',87);

--
-- Now setup withholding formula on WITHHOLDING element...
--
v_wh_formula_id := ins_base_formula  (
	p_ff_ele_name	=> dedn_ele_names(1),
	p_spr_ele_name	=> dedn_ele_names(2),
	p_ff_desc	=> 'Pretax withholding formula.',
	p_ff_bg_id	=> p_bg_id);

--
-- check for existence of status proc rule...function returns id if it does...
--
hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',119);

-- hr_utility.trace('spr exists checking...');
-- hr_utility.trace(dedn_ele_ids(1)||' '||v_calc_rule_formula_id);
-- hr_utility.trace(p_bg_id||' '||p_eff_start_date);
-- Calculator status proc rule...
already_exists := hr_template_existence.spr_exists (
				p_ele_id	=> dedn_ele_ids(1),
				p_ff_id		=> v_spr_formula_id,
				p_bg_id		=> p_bg_id,
				p_val_date	=> p_eff_start_date);

if already_exists = 0 then

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',121);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> p_eff_start_date,
		p_effective_end_date 		=> p_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(1),
		p_assignment_status_type_id 	=> v_asst_status_type_id,
		p_formula_id 			=> v_calc_rule_formula_id,
		p_processing_rule		=> v_proc_rule);

  dedn_statproc_rule_id(1) := v_stat_proc_rule_id;

else

-- Statproc rule already exists for calculator element.

    hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',123);

    v_stat_proc_rule_id := already_exists;
    dedn_statproc_rule_id(1) := v_stat_proc_rule_id;

    IF v_calc_rule_formula_id = v_spr_formula_id THEN

      NULL;

    ELSE

      UPDATE pay_status_processing_rules_f
      SET formula_id = v_calc_rule_formula_id
      WHERE status_processing_rule_id = already_exists
      AND p_eff_start_date BETWEEN effective_start_date
                                               AND effective_end_date;

     END IF;

end if;

-- hr_utility.trace('spr exists checking...');
-- hr_utility.trace(dedn_ele_ids(2)||' '||v_wh_formula_id);
-- hr_utility.trace(p_bg_id||' '||p_eff_start_date);
-- Check for base status proc rule existence...
already_exists := hr_template_existence.spr_exists (
				p_ele_id	=> dedn_ele_ids(2),
				p_ff_id		=> v_spr_formula_id,
				p_bg_id		=> p_bg_id,
				p_val_date	=> p_eff_start_date);

if already_exists = 0 then

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',125);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> p_eff_start_date,
		p_effective_end_date 		=> p_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(2),
		p_assignment_status_type_id 	=> v_asst_status_type_id,
		p_formula_id 			=> v_wh_formula_id,
		p_processing_rule		=> v_proc_rule);

  dedn_statproc_rule_id(2) := v_stat_proc_rule_id;

else

-- Statproc rule already exists for calculator element.

    hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',127);

    v_stat_proc_rule_id := already_exists;
    dedn_statproc_rule_id(2) := v_stat_proc_rule_id;

    IF v_wh_formula_id = v_spr_formula_id THEN

      NULL;

    ELSE

      UPDATE pay_status_processing_rules_f
      SET formula_id = v_wh_formula_id
      WHERE status_processing_rule_id = already_exists
      AND p_eff_start_date BETWEEN effective_start_date
                                               AND effective_end_date;

     END IF;

end if;


-- Create Input Values for elements.
-- These are the input values that are dependent on calc rule or other attributes
-- selected on the Deductions screen...ie. arrears, ee bond, stop/start rules...
-- We may want to put the generic input values in here too - ie the ivs common to
-- all deduction templates.
-- This will give us the ability to refer to ivs by number, especially for creating
-- formula result rules...

IF UPPER(p_amount_rule) = 'PE' THEN

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',65);

  dedn_base_iv_names(1)		:= 'Percentage';
  dedn_base_iv_uom(1)		:= 'Number';
  dedn_base_iv_mand(1)		:= 'N';
  dedn_base_iv_dbi(1)		:= 'Y';
  dedn_base_iv_lkp(1)		:= NULL;
  dedn_base_iv_dflt(1)		:= NULL;

  dedn_base_iv_names(2)		:= NULL;
  dedn_base_iv_names(3)		:= NULL;

  l_num_base_ivs := 3;

ELSIF UPPER(p_amount_rule) = 'PT' THEN

-- Insert input vals;
-- "Table Column" (default to p_ele_paytab_col)
-- Also requires input value for "Table Row" if value in
-- p_ele_paytab_row is NOT a database item.  If it IS a dbi_name,
-- then we do not create inpval for it, the value is stored on
-- the SCL and formula picks it up from there.  This will amount
-- to an input value required when the user enters a value OTHER
-- then "Salary Range" or "Age Range" in the Row Type field.

   hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',65);

   dedn_base_iv_names(1)	:= 'Table Column';
   dedn_base_iv_uom(1)		:= 'Character';
   dedn_base_iv_mand(1)	:= 'N';
   dedn_base_iv_dbi(1)		:= 'N';
   dedn_base_iv_lkp(1)		:= NULL;
   dedn_base_iv_dflt(1)		:= p_paytab_col;

   dedn_base_iv_names(2)	:= NULL;
   dedn_base_iv_names(3)	:= NULL;

   l_num_base_ivs := 3;

   hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',65);

-- Place logic determining to create or not create additional input value here:
-- 1) If p_paytab_row_type = 'Age Range' or 'Salary Range' then DO NOT create
--	addl inpval;
-- 2) Compare p_paytab_row_type with database item names:
	-- If p_paytab_row_type = dbi.name then DO NOT create addl inpval;
	-- Else create addl inpval where name = PAY_USER_TABLES.USER_ROW_TITLE
--			(and user_table_name = p_paytab_name)
--

  IF p_paytab_row_type NOT IN ('Salary Range', 'Age Range') THEN

      hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',75);

     dedn_base_iv_names(2)	:= p_paytab_row_type;
     dedn_base_iv_uom(2)	:= 'Character';
     dedn_base_iv_mand(2)	:= 'N';
     dedn_base_iv_dbi(2)		:= 'Y';
     dedn_base_iv_lkp(2)		:= NULL;
     dedn_base_iv_dflt(2)		:= NULL;

     dedn_base_iv_names(3)	:= NULL;

     l_num_base_ivs := 3;

  END IF; -- rowtype = dbi name check.

ELSIF UPPER(p_amount_rule) = 'BT' THEN

   hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',65);

   dedn_base_iv_names(1)	:= 'Coverage';
   dedn_base_iv_uom(1)		:= 'Character';
   dedn_base_iv_mand(1)	:= 'N';
   dedn_base_iv_dbi(1)		:= 'Y';
   dedn_base_iv_lkp(1)		:= 'US_BENEFIT_COVERAGE';
   dedn_base_iv_dflt(1)		:= 'EMP ONLY';

   dedn_base_iv_names(2)	:= 'ER Contr';
   dedn_base_iv_uom(2)		:= 'Money';
   dedn_base_iv_mand(2)	:= 'N';
   dedn_base_iv_dbi(2)		:= 'Y';
   dedn_base_iv_lkp(2)		:= NULL;
   dedn_base_iv_dflt(2)		:= NULL;

   dedn_base_iv_names(3)	:= 'EE Contr';
   dedn_base_iv_uom(3)		:= 'Money';
   dedn_base_iv_mand(3)	:= 'N';
   dedn_base_iv_dbi(3)		:= 'Y';
   dedn_base_iv_lkp(3)		:= NULL;
   dedn_base_iv_dflt(3)		:= NULL;

   l_num_base_ivs := 3;

ELSE

-- Flat Amount calc rule...

   dedn_base_iv_names(1)	:= 'Amount';
   dedn_base_iv_uom(1)		:= 'Money';
   dedn_base_iv_mand(1)	:= 'N';
   dedn_base_iv_dbi(1)		:= 'Y';
   dedn_base_iv_lkp(1)		:= NULL;
   dedn_base_iv_dflt(1)		:= NULL;

   dedn_base_iv_names(2)	:= NULL;
   dedn_base_iv_names(3)	:= NULL;

   l_num_base_ivs := 3;

END IF; -- Amount rule checks for input value creation...

-- More input values are required for particular functionality...
/*
Start Rule input values are
  dedn_base_iv_names(4)
  dedn_base_iv_names(5)
*/

IF p_ele_start_rule = 'ET' THEN

   dedn_base_iv_names(4) := 'Threshold Amount';
   dedn_base_iv_uom(4)	:= 'Money';
   dedn_base_iv_mand(4)	:= 'N';
   dedn_base_iv_dbi(4)	:= 'Y';
   dedn_base_iv_lkp(4)	:= NULL;
   dedn_base_iv_dflt(4)	:= NULL;

/* 40.8 set iv name(5) to null. */
   dedn_base_iv_names(5) := NULL;
   l_num_base_ivs	:= 5;

ELSIF p_ele_start_rule = 'CHAINED' THEN

/* 40.8 set iv name(4) to null. */
   dedn_base_iv_names(4) := NULL;

   dedn_base_iv_names(5) := 'Chained To';
   dedn_base_iv_uom(5)	:= 'Character';
   dedn_base_iv_mand(5)	:= 'N';
   dedn_base_iv_dbi(5)	:= 'Y';
   dedn_base_iv_lkp(5)	:= NULL;
   dedn_base_iv_dflt(5)	:= NULL;

   l_num_base_ivs	:= 5;

ELSE

  dedn_base_iv_names(4)		:= NULL;
  dedn_base_iv_names(5)		:= NULL;

  l_num_base_ivs := 5;

END IF; -- Start Rule checks for input value creation...

/*
Stop Rule input values are
  dedn_base_iv_names(6)
  dedn_base_iv_names(7)
*/

IF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN

   dedn_base_iv_names(6) := 'Total Owed';
   dedn_base_iv_uom(6)	:= 'Money';
   dedn_base_iv_mand(6)	:= 'N';
   dedn_base_iv_dbi(6)	:= 'N';
   dedn_base_iv_lkp(6)	:= NULL;
   dedn_base_iv_dflt(6)	:= NULL;

   dedn_base_iv_names(7) := 'Towards Owed';
   dedn_base_iv_uom(7)	:= 'Character';
   dedn_base_iv_mand(7)	:= 'N';
   dedn_base_iv_dbi(7)	:= 'Y';
   dedn_base_iv_lkp(7)	:= 'YES_NO';
   dedn_base_iv_dflt(7)	:= 'Y';

   l_num_base_ivs	 := 7;

   dedn_sf_iv_names(1)	:= 'Accrued';
   dedn_sf_iv_uom(1)	:= 'Money';
   dedn_sf_iv_mand(1)	:= 'N';
   dedn_sf_iv_dbi(1)	:= 'N';
   dedn_sf_iv_lkp(1)	:= NULL;
   dedn_sf_iv_dflt(1)	:= NULL;

   l_num_sf_ivs		:= 1;

ELSE

  dedn_base_iv_names(6)		:= NULL;
  dedn_base_iv_names(7)		:= NULL;

  l_num_base_ivs := 7;

  dedn_sf_iv_names(1)	:= NULL;
  l_num_sf_ivs		:= 1;

END IF;  -- Stop Rule checks for creation of input values.

/*
Arrearage input values are
  dedn_base_iv_names(8)
*/
IF p_arrearage = 'Y' THEN

--  create input values for:
--  (*) "Clear Arrears" (on base ele)
--  (*) "Arrears Contr" (on Special Features ele Feeds "Arrears" balance)

   dedn_base_iv_names(8) := 'Clear Arrears';
   dedn_base_iv_uom(8)	:= 'Character';
   dedn_base_iv_mand(8)	:= 'N';
   dedn_base_iv_dbi(8)	:= 'N';
   dedn_base_iv_lkp(8)	:= 'YES_NO';
   dedn_base_iv_dflt(8)	:= 'N';

   l_num_base_ivs := 8;

   dedn_sf_iv_names(2)	:= 'Arrears Contr';
   dedn_sf_iv_uom(2)	:= 'Money';
   dedn_sf_iv_mand(2)	:= 'N';
   dedn_sf_iv_dbi(2)	:= 'N';
   dedn_sf_iv_lkp(2)	:= NULL;
   dedn_sf_iv_dflt(2)	:= NULL;

   l_num_sf_ivs		:= 2;

ELSE

  dedn_base_iv_names(8)		:= NULL;
  l_num_base_ivs := 8;

  dedn_sf_iv_names(2)	:= NULL;
  l_num_sf_ivs		:= 2;

END IF;  -- Arrears input value creation...

/*
Input values passed from calculator to withholding element are
  dedn_wh_iv_names(1) = Calc Dedn Amt
W/H FF INPUTS:
             Calc_Dedn_Amt
	   , Total_Owed
	   , Towards_Owed (text)
	   , Clear_Arrears (text)
	   , Arrears_Bal
	   , Accrued_Bal
	   , Partial_Dedns (text)

*/

  dedn_wh_iv_names(1) := 'Calc Dedn Amt';
  dedn_wh_iv_uom(1)	:= 'Money';
  dedn_wh_iv_mand(1)	:= 'N';
  dedn_wh_iv_dbi(1)	:= 'N';
  dedn_wh_iv_lkp(1)	:= NULL;
  dedn_wh_iv_dflt(1)	:= NULL;

  dedn_wh_iv_names(2) := 'Total Owed';
  dedn_wh_iv_uom(2)	:= 'Money';
  dedn_wh_iv_mand(2)	:= 'N';
  dedn_wh_iv_dbi(2)	:= 'N';
  dedn_wh_iv_lkp(2)	:= NULL;
  dedn_wh_iv_dflt(2)	:= NULL;

  dedn_wh_iv_names(3) := 'Towards Owed';
  dedn_wh_iv_uom(3)	:= 'Character';
  dedn_wh_iv_mand(3)	:= 'N';
  dedn_wh_iv_dbi(3)	:= 'N';
  dedn_wh_iv_lkp(3)	:= 'YES_NO';
  dedn_wh_iv_dflt(3)	:= 'Y';

  dedn_wh_iv_names(4) := 'Clear Arrears';
  dedn_wh_iv_uom(4)	:= 'Character';
  dedn_wh_iv_mand(4)	:= 'N';
  dedn_wh_iv_dbi(4)	:= 'N';
  dedn_wh_iv_lkp(4)	:= 'YES_NO';
  dedn_wh_iv_dflt(4)	:= 'N';

  dedn_wh_iv_names(5) := 'Arrears Bal';
  dedn_wh_iv_uom(5)	:= 'Money';
  dedn_wh_iv_mand(5)	:= 'N';
  dedn_wh_iv_dbi(5)	:= 'N';
  dedn_wh_iv_lkp(5)	:= NULL;
  dedn_wh_iv_dflt(5)	:= NULL;

  dedn_wh_iv_names(6) := 'Accrued Bal';
  dedn_wh_iv_uom(6)	:= 'Money';
  dedn_wh_iv_mand(6)	:= 'N';
  dedn_wh_iv_dbi(6)	:= 'N';
  dedn_wh_iv_lkp(6)	:= NULL;
  dedn_wh_iv_dflt(6)	:= NULL;

  dedn_wh_iv_names(7) := 'Partial Dedns';
  dedn_wh_iv_uom(7)	:= 'Character';
  dedn_wh_iv_mand(7)	:= 'N';
  dedn_wh_iv_dbi(7)	:= 'N';
  dedn_wh_iv_lkp(7)	:= 'YES_NO';
  dedn_wh_iv_dflt(7)	:= 'N';

  dedn_wh_iv_names(8) := 'Pass To Aftertax';
  dedn_wh_iv_uom(8)	:= 'Money';
  dedn_wh_iv_mand(8)	:= 'X';
  dedn_wh_iv_dbi(8)	:= 'N';
  dedn_wh_iv_lkp(8)	:= NULL;
  dedn_wh_iv_dflt(8)	:= NULL;

  l_num_wh_ivs := 8;



-- Create input values on base element...
FOR h in 1..l_num_base_ivs LOOP

 IF dedn_base_iv_names(h) IS NOT NULL THEN

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',300);

    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> dedn_ele_ids(1),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> dedn_base_iv_names(h),
				p_eff_date	=> g_eff_start_date);

     if already_exists = 0 then

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',310);

      select max(display_sequence)
      into    dedn_base_seq
      from   pay_input_values_f
      where  element_type_id = dedn_ele_ids(1)
      and      g_eff_start_date	between effective_start_date
			and effective_end_date;

      dedn_base_seq := dedn_base_seq + 1;

/* 40.4 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

         v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> dedn_ele_names(1),
			p_name 			=> dedn_base_iv_names(h),
			p_uom 			=> dedn_base_iv_uom(h),
                     	p_uom_code             	=> NULL,
			p_mandatory_flag 	=> dedn_base_iv_mand(h),
			p_generate_db_item_flag => dedn_base_iv_dbi(h),
              		p_default_value        	=> dedn_base_iv_dflt(h),
       	         	p_min_value            	=> NULL,
                       	p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
               		p_lookup_type          	=> dedn_base_iv_lkp(h),
                      	p_formula_id           	=> NULL,
       	         	p_hot_default_flag 	=> 'N',
			p_display_sequence 	=> dedn_base_seq,
			p_business_group_name 	=> p_bg_name,
			p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

          dedn_base_iv_ids(h) := v_inpval_id;

          hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',320);

          hr_input_values.chk_input_value(
 		p_element_type_id 		=> dedn_ele_ids(1),
		p_legislation_code 		=> g_template_leg_code,
	        p_val_start_date	 	=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_base_iv_ids(h),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_base_iv_mand(h),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_base_iv_names(h),
		p_uom 				=> dedn_base_iv_uom(h),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_base_iv_dflt(h),
		p_lookup_type 			=> dedn_base_iv_lkp(h),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_base_iv_dbi(h),
		p_warning_or_error 		=> NULL);

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',330);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(1),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_base_iv_ids(h),
		p_default_value 		=> dedn_base_iv_dflt(h),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_base_iv_names(h),
		p_db_items_flag 		=> dedn_base_iv_dbi(h),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

         v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> dedn_ele_names(1),
			p_name 			=> dedn_base_iv_names(h),
			p_uom 			=> dedn_base_iv_uom(h),
                     	p_uom_code             	=> NULL,
			p_mandatory_flag 	=> dedn_base_iv_mand(h),
			p_generate_db_item_flag => dedn_base_iv_dbi(h),
              		p_default_value        	=> dedn_base_iv_dflt(h),
       	         	p_min_value            	=> NULL,
                       	p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
               		p_lookup_type          	=> dedn_base_iv_lkp(h),
                      	p_formula_id           	=> NULL,
       	         	p_hot_default_flag 	=> 'N',
			p_display_sequence 	=> dedn_base_seq,
			p_business_group_name 	=> p_bg_name,
			p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

          dedn_base_iv_ids(h) := v_inpval_id;

          hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',320);

          pay_template_ivs.chk_input_value(
 		p_element_type_id 		=> dedn_ele_ids(1),
		p_legislation_code 		=> g_template_leg_code,
	        p_val_start_date	 	=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_base_iv_ids(h),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_base_iv_mand(h),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_base_iv_names(h),
		p_uom 				=> dedn_base_iv_uom(h),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_base_iv_dflt(h),
		p_lookup_type 			=> dedn_base_iv_lkp(h),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_base_iv_dbi(h),
		p_warning_or_error 		=> NULL);

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',330);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(1),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_base_iv_ids(h),
		p_default_value 		=> dedn_base_iv_dflt(h),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_base_iv_names(h),
		p_db_items_flag 		=> dedn_base_iv_dbi(h),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> dedn_ele_ids(1),
			p_input_value_id  	=> dedn_base_iv_ids(h),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> dedn_base_iv_dflt(h),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

     hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',340);

      v_inpval_id := already_exists;
      dedn_base_iv_ids(h) := v_inpval_id;

    end if;

  ELSE

-- BASE IV name is null...do not need to create...

    NULL;

  END IF;

END LOOP;

FOR k in 1..l_num_wh_ivs LOOP

 IF dedn_wh_iv_names(k) IS NOT NULL THEN

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',300);

    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> dedn_ele_ids(2),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> dedn_wh_iv_names(k),
				p_eff_date	=> g_eff_start_date);

     if already_exists = 0 then

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',310);

      select max(display_sequence)
      into    dedn_wh_seq
      from   pay_input_values_f
      where  element_type_id = dedn_ele_ids(2)
      and    g_eff_start_date	between effective_start_date
			and effective_end_date;

      dedn_wh_seq := dedn_wh_seq + 1;

-- 40.4 : Call new API to add input value over life of element if
--           upgrade mode = Yes


      IF l_upgrade_mode = 'N' THEN

         v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 	=> dedn_ele_names(2),
			p_name 			=> dedn_wh_iv_names(k),
			p_uom 			=> dedn_wh_iv_uom(k),
                     	p_uom_code             	=> NULL,
			p_mandatory_flag 	=> dedn_wh_iv_mand(k),
			p_generate_db_item_flag => dedn_wh_iv_dbi(k),
              		p_default_value        	=> dedn_wh_iv_dflt(k),
       	         	p_min_value            	=> NULL,
                       	p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
               		p_lookup_type          	=> dedn_wh_iv_lkp(k),
                      	p_formula_id           	=> NULL,
       	         	p_hot_default_flag 	=> 'N',
			p_display_sequence 	=> dedn_wh_seq,
			p_business_group_name 	=> p_bg_name,
			p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

          dedn_wh_iv_ids(k) := v_inpval_id;

          hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',320);

          hr_input_values.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(2),
		p_legislation_code 		=> g_template_leg_code,
	        p_val_start_date	 	=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_wh_iv_ids(k),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_wh_iv_mand(k),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_wh_iv_names(k),
		p_uom 				=> dedn_wh_iv_uom(k),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_wh_iv_dflt(k),
		p_lookup_type 			=> dedn_wh_iv_lkp(k),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_wh_iv_dbi(k),
		p_warning_or_error 		=> NULL);

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',330);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(2),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_wh_iv_ids(k),
		p_default_value 		=> dedn_wh_iv_dflt(k),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_wh_iv_names(k),
		p_db_items_flag 		=> dedn_wh_iv_dbi(k),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

         v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 	=> dedn_ele_names(2),
			p_name 			=> dedn_wh_iv_names(k),
			p_uom 			=> dedn_wh_iv_uom(k),
                     	p_uom_code             	=> NULL,
			p_mandatory_flag 	=> dedn_wh_iv_mand(k),
			p_generate_db_item_flag => dedn_wh_iv_dbi(k),
              		p_default_value        	=> dedn_wh_iv_dflt(k),
       	         	p_min_value            	=> NULL,
                       	p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
               		p_lookup_type          	=> dedn_wh_iv_lkp(k),
                      	p_formula_id           	=> NULL,
       	         	p_hot_default_flag 	=> 'N',
			p_display_sequence 	=> dedn_wh_seq,
			p_business_group_name 	=> p_bg_name,
			p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

          dedn_wh_iv_ids(k) := v_inpval_id;

          hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',320);

          pay_template_ivs.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(2),
		p_legislation_code 		=> g_template_leg_code,
	        p_val_start_date	 	=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_wh_iv_ids(k),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_wh_iv_mand(k),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_wh_iv_names(k),
		p_uom 				=> dedn_wh_iv_uom(k),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_wh_iv_dflt(k),
		p_lookup_type 			=> dedn_wh_iv_lkp(k),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_wh_iv_dbi(k),
		p_warning_or_error 		=> NULL);

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',330);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(2),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_wh_iv_ids(k),
		p_default_value 		=> dedn_wh_iv_dflt(k),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_wh_iv_names(k),
		p_db_items_flag 		=> dedn_wh_iv_dbi(k),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> dedn_ele_ids(2),
			p_input_value_id  	=> dedn_wh_iv_ids(k),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> dedn_wh_iv_dflt(k),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

     hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',340);

      v_inpval_id := already_exists;
      dedn_wh_iv_ids(k) := v_inpval_id;

    end if;

  ELSE

-- WITHHOLDING IV name is null...do not need to create...

    NULL;

  END IF;

END LOOP;

--
-- Create inpvals for "Special Inputs"
--

  hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',110);

  dedn_si_iv_names(1)	:= 'Replace Amt';
  dedn_si_iv_uom(1)	:= 'Money';
  dedn_si_iv_mand(1)	:= 'N';
  dedn_si_iv_dbi(1)	:= 'N';
  dedn_si_iv_lkp(1)	:= NULL;
  dedn_si_iv_dflt(1)	:= NULL;

  dedn_si_iv_names(2)	:= 'Addl Amt';
  dedn_si_iv_uom(2)	:= 'Money';
  dedn_si_iv_mand(2)	:= 'N';
  dedn_si_iv_dbi(2)	:= 'N';
  dedn_si_iv_lkp(2)	:= NULL;
  dedn_si_iv_dflt(2)	:= NULL;

  dedn_si_iv_names(3)	:= 'Adjust Arrears';
  dedn_si_iv_uom(3)	:= 'Money';
  dedn_si_iv_mand(3)	:= 'N';
  dedn_si_iv_dbi(3)	:= 'N';
  dedn_si_iv_lkp(3)	:= NULL;
  dedn_si_iv_dflt(3)	:= NULL;

  l_num_si_ivs		:= 3;

--
-- Now create all special inputs element input values.
--
  FOR siv in 1..l_num_si_ivs LOOP

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',120);

   already_exists := hr_template_existence.iv_name_exists(
				p_ele_id		=> dedn_ele_ids(3),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> dedn_si_iv_names(siv),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',130);

        select max(display_sequence)
        into    dedn_iv_seq
        from   pay_input_values_f
        where  element_type_id = dedn_ele_ids(3)
        and    g_eff_start_date	between effective_start_date
			and effective_end_date;

        dedn_iv_seq := dedn_iv_seq + 1;

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',140);

/* 40.4 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> dedn_ele_names(3),
			p_name 			=> dedn_si_iv_names(siv),
			p_uom 			=> dedn_si_iv_uom(siv),
                      	p_uom_code              => NULL,
			p_mandatory_flag 	=> dedn_si_iv_mand(siv),
			p_generate_db_item_flag => dedn_si_iv_dbi(siv),
      	        	p_default_value         => dedn_si_iv_dflt(siv),
               		p_min_value             => NULL,
                      	p_max_value             => NULL,
              	     	p_warning_or_error      => NULL,
              		p_lookup_type           => dedn_si_iv_lkp(siv),
                     	p_formula_id            => NULL,
       	         	p_hot_default_flag      => 'N',
			p_display_sequence 	=> dedn_iv_seq,
			p_business_group_name 	=> v_bg_name,
	               	p_effective_start_date	=> g_eff_start_date,
               		p_effective_end_date   	=> g_eff_end_date);

      dedn_si_iv_ids(siv) := v_inpval_id;

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',150);

      hr_input_values.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(3),
		p_legislation_code 		=> g_template_leg_code,
		p_val_start_date		=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_si_iv_ids(siv),
		p_rowid 			=> NULL,
		p_recurring_flag		=> 'N',
		p_mandatory_flag 		=> dedn_si_iv_mand(siv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_si_iv_names(siv),
		p_uom 				=> dedn_si_iv_uom(siv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_si_iv_dflt(siv),
		p_lookup_type 			=> dedn_si_iv_lkp(siv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_si_iv_dbi(siv),
		p_warning_or_error 		=> NULL);

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',160);

     hr_input_values.ins_3p_input_values(
		p_val_start_date		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(3),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_si_iv_ids(siv),
		p_default_value 		=> dedn_si_iv_dflt(siv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag		=> NULL,
		p_input_value_name 		=> dedn_si_iv_names(siv),
		p_db_items_flag        		=> dedn_si_iv_dbi(siv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> dedn_ele_names(3),
			p_name 			=> dedn_si_iv_names(siv),
			p_uom 			=> dedn_si_iv_uom(siv),
                      	p_uom_code              => NULL,
			p_mandatory_flag 	=> dedn_si_iv_mand(siv),
			p_generate_db_item_flag => dedn_si_iv_dbi(siv),
      	        	p_default_value         => dedn_si_iv_dflt(siv),
               		p_min_value             => NULL,
                      	p_max_value             => NULL,
              	     	p_warning_or_error      => NULL,
              		p_lookup_type           => dedn_si_iv_lkp(siv),
                     	p_formula_id            => NULL,
       	         	p_hot_default_flag      => 'N',
			p_display_sequence 	=> dedn_iv_seq,
			p_business_group_name 	=> v_bg_name,
	               	p_effective_start_date	=> g_eff_start_date,
               		p_effective_end_date   	=> g_eff_end_date);

      dedn_si_iv_ids(siv) := v_inpval_id;

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',150);

      pay_template_ivs.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(3),
		p_legislation_code 		=> g_template_leg_code,
		p_val_start_date		=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_si_iv_ids(siv),
		p_rowid 			=> NULL,
		p_recurring_flag		=> 'N',
		p_mandatory_flag 		=> dedn_si_iv_mand(siv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_si_iv_names(siv),
		p_uom 				=> dedn_si_iv_uom(siv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_si_iv_dflt(siv),
		p_lookup_type 			=> dedn_si_iv_lkp(siv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_si_iv_dbi(siv),
		p_warning_or_error 		=> NULL);

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',160);

     pay_template_ivs.ins_3p_input_values(
		p_val_start_date		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(3),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_si_iv_ids(siv),
		p_default_value 		=> dedn_si_iv_dflt(siv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag		=> NULL,
		p_input_value_name 		=> dedn_si_iv_names(siv),
		p_db_items_flag        		=> dedn_si_iv_dbi(siv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> dedn_ele_ids(3),
			p_input_value_id  	=> dedn_si_iv_ids(siv),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> dedn_si_iv_dflt(siv),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',170);

      v_inpval_id := already_exists;

      dedn_si_iv_ids(siv) := v_inpval_id;

    end if;

  END LOOP;

--
-- Create inpvals for "Special Features"
--

  hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',180);

  dedn_sf_iv_names(3)	:= 'Replacement Amt';
  dedn_sf_iv_uom(3)	:= 'Money';
  dedn_sf_iv_mand(3)	:= 'N';
  dedn_sf_iv_dbi(3)	:= 'N';
  dedn_sf_iv_lkp(3)	:= NULL;
  dedn_sf_iv_dflt(3)	:= NULL;

  dedn_sf_iv_names(4)	:= 'Additional Amt';
  dedn_sf_iv_uom(4)	:= 'Money';
  dedn_sf_iv_mand(4)	:= 'N';
  dedn_sf_iv_dbi(4)	:= 'N';
  dedn_sf_iv_lkp(4)	:= NULL;
  dedn_sf_iv_dflt(4)	:= NULL;

  dedn_sf_iv_names(5)	:= 'Not Taken';
  dedn_sf_iv_uom(5)	:= 'Money';
  dedn_sf_iv_mand(5)	:= 'N';
  dedn_sf_iv_dbi(5)	:= 'N';
  dedn_sf_iv_lkp(5)	:= NULL;
  dedn_sf_iv_dflt(5)	:= NULL;

  dedn_sf_iv_names(6)	:= 'Cancel Ptx Amt';
  dedn_sf_iv_uom(6)	:= 'Money';
  dedn_sf_iv_mand(6)	:= 'N';
  dedn_sf_iv_dbi(6)	:= 'N';
  dedn_sf_iv_lkp(6)	:= NULL;
  dedn_sf_iv_dflt(6)	:= NULL;

  dedn_sf_iv_names(7)	:= 'Ptx Amt';
  dedn_sf_iv_uom(7)	:= 'Money';
  dedn_sf_iv_mand(7)	:= 'N';
  dedn_sf_iv_dbi(7)	:= 'N';
  dedn_sf_iv_lkp(7)	:= NULL;
  dedn_sf_iv_dflt(7)	:= NULL;

  l_num_sf_ivs		:= 7;

--
-- Now create all special features element input values.
--
  FOR sfv in 1..l_num_sf_ivs LOOP

   IF dedn_sf_iv_names(sfv) IS NOT NULL THEN

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',190);

    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> dedn_ele_ids(4),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> dedn_sf_iv_names(sfv),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',200);

       select max(display_sequence)
        into    dedn_iv_seq
        from   pay_input_values_f
        where  element_type_id = dedn_ele_ids(4)
        and    g_eff_start_date	between effective_start_date
				and effective_end_date;

        dedn_iv_seq := dedn_iv_seq + 1;

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',210);

/* 40.4 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> dedn_ele_names(4),
			p_name 			=> dedn_sf_iv_names(sfv),
			p_uom 			=> dedn_sf_iv_uom(sfv),
  	                p_uom_code              => NULL,
			p_mandatory_flag 	=> dedn_sf_iv_mand(sfv),
			p_generate_db_item_flag => dedn_sf_iv_dbi(sfv),
              	        p_default_value        	=> dedn_sf_iv_dflt(sfv),
                       	p_min_value            	=> NULL,
	                p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
                       	p_lookup_type          	=> dedn_sf_iv_lkp(sfv),
	                p_formula_id           	=> NULL,
              	        p_hot_default_flag     	=> 'N',
			p_display_sequence 	=> dedn_iv_seq,
			p_business_group_name 	=> v_bg_name,
	               	p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

       dedn_sf_iv_ids(sfv) := v_inpval_id;

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',220);

      hr_input_values.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(4),
		p_legislation_code 		=> g_template_leg_code,
		p_val_start_date 		=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_sf_iv_ids(sfv),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_sf_iv_mand(sfv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_sf_iv_names(sfv),
		p_uom 				=> dedn_sf_iv_uom(sfv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value	 		=> dedn_sf_iv_dflt(sfv),
		p_lookup_type 			=> dedn_sf_iv_lkp(sfv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_sf_iv_dbi(sfv),
		p_warning_or_error 		=> NULL);

       hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',230);

      hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(4),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_sf_iv_ids(sfv),
		p_default_value			=> dedn_sf_iv_dflt(sfv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_sf_iv_names(sfv),
		p_db_items_flag 		=> dedn_sf_iv_dbi(sfv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> dedn_ele_names(4),
			p_name 			=> dedn_sf_iv_names(sfv),
			p_uom 			=> dedn_sf_iv_uom(sfv),
  	                p_uom_code              => NULL,
			p_mandatory_flag 	=> dedn_sf_iv_mand(sfv),
			p_generate_db_item_flag => dedn_sf_iv_dbi(sfv),
              	        p_default_value        	=> dedn_sf_iv_dflt(sfv),
                       	p_min_value            	=> NULL,
	                p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
                       	p_lookup_type          	=> dedn_sf_iv_lkp(sfv),
	                p_formula_id           	=> NULL,
              	        p_hot_default_flag     	=> 'N',
			p_display_sequence 	=> dedn_iv_seq,
			p_business_group_name 	=> v_bg_name,
	               	p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

       dedn_sf_iv_ids(sfv) := v_inpval_id;

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',220);

      pay_template_ivs.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(4),
		p_legislation_code 		=> g_template_leg_code,
		p_val_start_date 		=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_sf_iv_ids(sfv),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_sf_iv_mand(sfv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_sf_iv_names(sfv),
		p_uom 				=> dedn_sf_iv_uom(sfv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value	 		=> dedn_sf_iv_dflt(sfv),
		p_lookup_type 			=> dedn_sf_iv_lkp(sfv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_sf_iv_dbi(sfv),
		p_warning_or_error 		=> NULL);

       hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',230);

      pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(4),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_sf_iv_ids(sfv),
		p_default_value			=> dedn_sf_iv_dflt(sfv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_sf_iv_names(sfv),
		p_db_items_flag 		=> dedn_sf_iv_dbi(sfv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> dedn_ele_ids(4),
			p_input_value_id  	=> dedn_sf_iv_ids(sfv),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> dedn_sf_iv_dflt(sfv),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',240);

      v_inpval_id := already_exists;
      dedn_sf_iv_ids(sfv) := v_inpval_id;

    end if;

   ELSE

-- SF IV NAME is null, no need to create.

      NULL;

  END IF;

END LOOP;


/*
Create Input values passed from withholding element to ER element are
  dedn_er_iv_names(1) =
ER Match FF INPUTS:
           Deduction Actually Taken

*/

IF p_ele_er_match = 'Y' THEN
  dedn_er_iv_names(1) := 'Deduction Actually Taken';
  dedn_er_iv_uom(1)	:= 'Money';
  dedn_er_iv_mand(1)	:= 'X';
  dedn_er_iv_dbi(1)	:= 'N';
  dedn_er_iv_lkp(1)	:= NULL;
  dedn_er_iv_dflt(1)	:= NULL;
ELSE
  dedn_er_iv_names(1) := NULL;
END IF;
  l_num_er_ivs := 1;

FOR m in 1..l_num_er_ivs LOOP

 IF dedn_er_iv_names(m)IS NOT NULL THEN

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',400);

    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> dedn_ele_ids(5),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> dedn_er_iv_names(m),
				p_eff_date	=> g_eff_start_date);

     if already_exists = 0 then

      hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',410);

      select max(display_sequence)
      into    dedn_er_seq
      from   pay_input_values_f
      where  element_type_id = dedn_ele_ids(5)
      and    g_eff_start_date	between effective_start_date
			and effective_end_date;

      dedn_er_seq := dedn_er_seq + 1;

-- 40.4 : Call new API to add input value over life of element if
--           upgrade mode = Yes


      IF l_upgrade_mode = 'N' THEN

         v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 	=> dedn_ele_names(5),
			p_name 			=> dedn_er_iv_names(m),
			p_uom 			=> dedn_er_iv_uom(m),
                     	p_uom_code             	=> NULL,
			p_mandatory_flag 	=> dedn_er_iv_mand(m),
			p_generate_db_item_flag => dedn_er_iv_dbi(m),
              		p_default_value        	=> dedn_er_iv_dflt(m),
       	         	p_min_value            	=> NULL,
                       	p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
               		p_lookup_type          	=> dedn_er_iv_lkp(m),
                      	p_formula_id           	=> NULL,
       	         	p_hot_default_flag 	=> 'N',
			p_display_sequence 	=> dedn_er_seq,
			p_business_group_name 	=> p_bg_name,
			p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

          dedn_er_iv_ids(m) := v_inpval_id;

          hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',420);

          hr_input_values.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(5),
		p_legislation_code 		=> g_template_leg_code,
	        p_val_start_date	 	=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_er_iv_ids(m),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_er_iv_mand(m),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_er_iv_names(m),
		p_uom 				=> dedn_er_iv_uom(m),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_er_iv_dflt(m),
		p_lookup_type 			=> dedn_er_iv_lkp(m),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_er_iv_dbi(m),
		p_warning_or_error 		=> NULL);

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',430);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(5),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_er_iv_ids(m),
		p_default_value 		=> dedn_er_iv_dflt(m),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_er_iv_names(m),
		p_db_items_flag 		=> dedn_er_iv_dbi(m),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

         v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 	=> dedn_ele_names(5),
			p_name 			=> dedn_er_iv_names(m),
			p_uom 			=> dedn_er_iv_uom(m),
                     	p_uom_code             	=> NULL,
			p_mandatory_flag 	=> dedn_er_iv_mand(m),
			p_generate_db_item_flag => dedn_er_iv_dbi(m),
              		p_default_value        	=> dedn_er_iv_dflt(m),
       	         	p_min_value            	=> NULL,
                       	p_max_value            	=> NULL,
              	     	p_warning_or_error     	=> NULL,
               		p_lookup_type          	=> dedn_er_iv_lkp(m),
                      	p_formula_id           	=> NULL,
       	         	p_hot_default_flag 	=> 'N',
			p_display_sequence 	=> dedn_er_seq,
			p_business_group_name 	=> p_bg_name,
			p_effective_start_date	=> g_eff_start_date,
                       	p_effective_end_date   	=> g_eff_end_date);

          dedn_er_iv_ids(m) := v_inpval_id;

          hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',420);

          pay_template_ivs.chk_input_value(
		p_element_type_id 		=> dedn_ele_ids(5),
		p_legislation_code 		=> g_template_leg_code,
	        p_val_start_date	 	=> g_eff_start_date,
              	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> dedn_er_iv_ids(m),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> dedn_er_iv_mand(m),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> dedn_er_iv_names(m),
		p_uom 				=> dedn_er_iv_uom(m),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> dedn_er_iv_dflt(m),
		p_lookup_type 			=> dedn_er_iv_lkp(m),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> dedn_er_iv_dbi(m),
		p_warning_or_error 		=> NULL);

        hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',430);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> dedn_ele_ids(5),
		p_primary_classification_id 	=> p_primary_class_id,
		p_input_value_id 		=> dedn_er_iv_ids(m),
		p_default_value 		=> dedn_er_iv_dflt(m),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> dedn_er_iv_names(m),
		p_db_items_flag 		=> dedn_er_iv_dbi(m),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> dedn_ele_ids(5),
			p_input_value_id  	=> dedn_er_iv_ids(m),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> dedn_er_iv_dflt(m),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

     hr_utility.set_location('hr_upgrade_earnings.ins_uie_formula_processing',440);

      v_inpval_id := already_exists;
      dedn_er_iv_ids(m) := v_inpval_id;

    end if;

  ELSE

-- ER IV name is null...do not need to create...

    NULL;

  END IF;

END LOOP;
--
-- Now insert appropriate formula_result_rules for elements
--
/*
PRETAX CALCULATION FORMULA return section
RETURNS:      dedn_amt
	    , pretax_calc_amount
	    , bene_er_contr
	    , clear_repl_amt
	    , clear_addl_amt
	    , accrued_balance
	    , arrears_balance
	    , clear_arrears_flag
	    , partial_dedns_flag
	    , total_owed_amt
	    , towards_owed_flag
	    , aftertax_calc_amount
*/

dedn_calc_frr_name(1)		:= 'DEDN_AMT';
dedn_calc_frr_type(1)		:= 'I';
dedn_calc_frr_ele_id(1)		:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(1)		:= dedn_wh_iv_ids(1);
dedn_calc_frr_severity(1)	:= NULL;

dedn_calc_frr_name(2)		:= 'PRETAX_CALC_AMOUNT';
dedn_calc_frr_type(2)		:= 'I';
dedn_calc_frr_ele_id(2)		:= dedn_ele_ids(4);
dedn_calc_frr_iv_id(2)		:= dedn_sf_iv_ids(7);
dedn_calc_frr_severity(2)	:= NULL;

dedn_calc_frr_name(3)		:= 'MESG';
dedn_calc_frr_type(3)		:= 'M';
dedn_calc_frr_ele_id(3)		:= NULL;
dedn_calc_frr_iv_id(3)		:= NULL;
dedn_calc_frr_severity(3)	:= 'W';

l_num_calc_resrules		:= 3;

 hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',47);

IF UPPER(p_amount_rule) = 'BT' THEN

--
-- In order to create indirect result feeding Employer Charge element for
-- this benefit, we must find the input_value_id for the pay_value of the
-- employer charge element.
--

  hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',115);

  dedn_calc_frr_name(4)		:= 'BENE_ER_CONTR';
  dedn_calc_frr_type(4)		:= 'I';
  dedn_calc_frr_ele_id(4)	:= dedn_ele_ids(5);
  dedn_calc_frr_iv_id(4)	:= dedn_payval_id(5);
  dedn_calc_frr_severity(4)	:= NULL;

  l_num_calc_resrules		:= 4;

ELSE

  dedn_calc_frr_name(4)		:= NULL;

  l_num_calc_resrules		:= 4;

END IF;

IF p_ele_proc_type = 'R' THEN

  hr_utility.set_location('hr_generate_pretax.ins_uie_inp_values',90);

  dedn_calc_frr_name(5)		:= 'CLEAR_REPL_AMT';
  dedn_calc_frr_type(5)		:= 'I';
  dedn_calc_frr_ele_id(5)	:= dedn_ele_ids(4);
  dedn_calc_frr_iv_id(5)	:= dedn_sf_iv_ids(3);
  dedn_calc_frr_severity(5)	:= NULL;

  dedn_calc_frr_name(6)		:= 'CLEAR_ADDL_AMT';
  dedn_calc_frr_type(6)		:= 'I';
  dedn_calc_frr_ele_id(6)	:= dedn_ele_ids(4);
  dedn_calc_frr_iv_id(6)	:= dedn_sf_iv_ids(4);
  dedn_calc_frr_severity(6)	:= NULL;

  l_num_calc_resrules 		:= 6;

ELSE

  dedn_calc_frr_name(5)		:= NULL;
  dedn_calc_frr_name(6)		:= NULL;

  l_num_calc_resrules		:= 6;

END IF;

dedn_calc_frr_name(7)		:= 'ACCRUED_BALANCE';
dedn_calc_frr_type(7)		:= 'I';
dedn_calc_frr_ele_id(7)		:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(7)		:= dedn_wh_iv_ids(6);
dedn_calc_frr_severity(7)	:= NULL;

dedn_calc_frr_name(8)		:= 'ARREARS_BALANCE';
dedn_calc_frr_type(8)		:= 'I';
dedn_calc_frr_ele_id(8)		:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(8)		:= dedn_wh_iv_ids(5);
dedn_calc_frr_severity(8)	:= NULL;

dedn_calc_frr_name(9)		:= 'CLEAR_ARREARS_FLAG';
dedn_calc_frr_type(9)		:= 'I';
dedn_calc_frr_ele_id(9)		:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(9)		:= dedn_wh_iv_ids(4);
dedn_calc_frr_severity(9)	:= NULL;

dedn_calc_frr_name(10)		:= 'PARTIAL_DEDNS_FLAG';
dedn_calc_frr_type(10)		:= 'I';
dedn_calc_frr_ele_id(10)	:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(10)		:= dedn_wh_iv_ids(7);
dedn_calc_frr_severity(10)	:= NULL;

dedn_calc_frr_name(11)		:= 'TOTAL_OWED_AMT';
dedn_calc_frr_type(11)		:= 'I';
dedn_calc_frr_ele_id(11)	:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(11)		:= dedn_wh_iv_ids(2);
dedn_calc_frr_severity(11)	:= NULL;

dedn_calc_frr_name(12)		:= 'TOWARDS_OWED_FLAG';
dedn_calc_frr_type(12)		:= 'I';
dedn_calc_frr_ele_id(12)	:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(12)		:= dedn_wh_iv_ids(3);
dedn_calc_frr_severity(12)	:= NULL;

dedn_calc_frr_name(13)		:= 'AFTERTAX_CALC_AMOUNT';
dedn_calc_frr_type(13)		:= 'I';
dedn_calc_frr_ele_id(13)	:= dedn_ele_ids(2);
dedn_calc_frr_iv_id(13)		:= dedn_wh_iv_ids(8);
dedn_calc_frr_severity(13)	:= NULL;

l_num_calc_resrules 		:= 13;

/*
WITHHOLDING formula return section
RETURNS:*  dedn_amt
	*, cancel_calc_amt
	*, not_taken
	*, to_arrears
	*, to_total_owed
	*, STOP_ENTRY
	*, stop_calc_entry
	*, set_clear
	*, mesg
*/

dedn_wh_frr_name(1)		:= 'DEDN_AMT';
dedn_wh_frr_type(1)		:= 'I';
dedn_wh_frr_ele_id(1)		:= dedn_ele_ids(1);
dedn_wh_frr_iv_id(1)		:= dedn_payval_id(1);
dedn_wh_frr_severity(1)		:= NULL;

dedn_wh_frr_name(2)		:= 'CANCEL_CALC_AMT';
dedn_wh_frr_type(2)		:= 'I';
dedn_wh_frr_ele_id(2)		:= dedn_ele_ids(4);
dedn_wh_frr_iv_id(2)		:= dedn_sf_iv_ids(6);
dedn_wh_frr_severity(2)		:= NULL;

dedn_wh_frr_name(3)		:= 'NOT_TAKEN';
dedn_wh_frr_type(3)		:= 'I';
dedn_wh_frr_ele_id(3)		:= dedn_ele_ids(4);
dedn_wh_frr_iv_id(3)		:= dedn_sf_iv_ids(5);
dedn_wh_frr_severity(3)		:= NULL;

/* WE MIGHT WANT TO CONDITIONALLY CREATE THESE RESULT RULES...
LOGIC IS BELOW...
*/
dedn_wh_frr_name(4)		:= NULL;  -- No longer need stop entry for WH ele.
dedn_wh_frr_type(4)		:= 'S';
dedn_wh_frr_ele_id(4)		:= dedn_ele_ids(2);
dedn_wh_frr_iv_id(4)		:= dedn_payval_id(2);
dedn_wh_frr_severity(4)		:= NULL;

IF p_ele_proc_type = 'R' THEN

   dedn_wh_frr_name(5)		:= 'STOP_CALC_ENTRY';
   dedn_wh_frr_type(5)		:= 'S';
   dedn_wh_frr_ele_id(5)	:= dedn_ele_ids(1);
   dedn_wh_frr_iv_id(5)		:= dedn_payval_id(1);
   dedn_wh_frr_severity(5)		:= NULL;

ELSE

   dedn_wh_frr_name(5)         := NULL;

END IF;

dedn_wh_frr_name(6)		:= 'MESG';
dedn_wh_frr_type(6)		:= 'M';
dedn_wh_frr_ele_id(6)		:= NULL;
dedn_wh_frr_iv_id(6)		:= NULL;
dedn_wh_frr_severity(6)		:= 'W';

dedn_wh_frr_name(7)             := 'ERROR_MESG';
dedn_wh_frr_type(7)             := 'M';
dedn_wh_frr_ele_id(7)           := NULL;
dedn_wh_frr_iv_id(7)            := NULL;
dedn_wh_frr_severity(7)         := 'F';

l_num_wh_resrules		:= 7;

-- Stop Rule checks:

IF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN

-- Note this indirect result feeds "Accrued" inpval on
-- "<ELE_NAME> Special Features" ele.

  dedn_wh_frr_name(8)		:= 'TO_TOTAL_OWED';
  dedn_wh_frr_type(8)		:= 'I';
  dedn_wh_frr_ele_id(8)	:= dedn_ele_ids(4);
  dedn_wh_frr_iv_id(8)	:= dedn_sf_iv_ids(1);
  dedn_wh_frr_severity(8)	:= NULL;

  l_num_wh_resrules 		:= 8;

ELSE

  dedn_wh_frr_name(8)	:= NULL;
  l_num_wh_resrules 		:= 8;

END IF; -- Stop Rule checks

IF p_arrearage = 'Y' THEN

--  create formula result rule for:
--  (*) to_arrears --> Indirect to <ELE_NAME>.ARREARS_CONTR

    hr_utility.set_location('hr_generate_pretax.ins_dedn_formula_processing',450);

  dedn_wh_frr_name(9)		:= 'TO_ARREARS';
  dedn_wh_frr_type(9)		:= 'I';
  dedn_wh_frr_ele_id(9)	:= dedn_ele_ids(4);
  dedn_wh_frr_iv_id(9) 	:= dedn_sf_iv_ids(2);
  dedn_wh_frr_severity(9)	:= NULL;

  dedn_wh_frr_name(10) 	:= 'SET_CLEAR';
  dedn_wh_frr_type(10) 	:= 'U';
  dedn_wh_frr_ele_id(10)	:= dedn_ele_ids(1);
  dedn_wh_frr_iv_id(10)	:= dedn_base_iv_ids(8);
  dedn_wh_frr_severity(10)	:= NULL;

  l_num_wh_resrules 		:= 10;

ELSE

  dedn_wh_frr_name(9)		:= NULL;
  dedn_wh_frr_name(10)		:= NULL;
  l_num_wh_resrules 		:= 10;

END IF;

IF p_ele_er_match = 'Y' THEN
   dedn_wh_frr_name(11)		:= 'DEDN_AMT';
   dedn_wh_frr_type(11)		:= 'I';
   dedn_wh_frr_ele_id(11)	:= dedn_ele_ids(5);
   dedn_wh_frr_iv_id(11)	:= dedn_er_iv_ids(1);
   dedn_wh_frr_severity(11)	:= NULL;
   l_num_wh_resrules 		:= 11;
ELSE
   dedn_wh_frr_name(11)		:= NULL;
   l_num_wh_resrules 		:= 11;
END IF;


-- Create formula result rules for WITHHOLDING element.
FOR n in 1..l_num_wh_resrules LOOP

 IF dedn_wh_frr_name(n) IS NOT NULL THEN

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',270);

    already_exists := hr_template_existence.result_rule_exists(
				p_spr_id	=> dedn_statproc_rule_id(2),
				p_frr_name	=> dedn_wh_frr_name(n),
				p_iv_id		=> dedn_wh_frr_iv_id(n),
				p_bg_id		=> p_bg_id,
				p_ele_id	=> dedn_wh_frr_ele_id(n),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

     hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',280);

      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	    p_business_group_id		=> p_bg_id,
  	    p_legislation_code		=> NULL,
  	    p_legislation_subgroup	=> g_template_leg_subgroup,
	    p_effective_start_date	=> g_eff_start_date,
	    p_effective_end_date       	=> g_eff_end_date,
	    p_status_processing_rule_id	=> dedn_statproc_rule_id(2),
	    p_input_value_id		=> dedn_wh_frr_iv_id(n),
	    p_result_name		=> dedn_wh_frr_name(n),
	    p_result_rule_type		=> dedn_wh_frr_type(n),
	    p_severity_level		=> dedn_wh_frr_severity(n),
	    p_element_type_id		=> dedn_wh_frr_ele_id(n));

    else

       hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',290);
       v_fres_rule_id := already_exists;

    end if;

   ELSE

      NULL; -- base resrule name is null, no need to create.

   END IF;

  END LOOP;



-- Create formula result rules for calc element.
FOR n in 1..l_num_calc_resrules LOOP

 IF dedn_calc_frr_name(n) IS NOT NULL THEN

    hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',270);

    already_exists := hr_template_existence.result_rule_exists(
				p_spr_id	=> dedn_statproc_rule_id(1),
				p_frr_name	=> dedn_calc_frr_name(n),
				p_iv_id		=> dedn_calc_frr_iv_id(n),
				p_bg_id		=> p_bg_id,
				p_ele_id	=> dedn_calc_frr_ele_id(n),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

     hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',280);

      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	    p_business_group_id		=> p_bg_id,
  	    p_legislation_code		=> NULL,
  	    p_legislation_subgroup	=> g_template_leg_subgroup,
	    p_effective_start_date	=> g_eff_start_date,
	    p_effective_end_date       	=> g_eff_end_date,
	    p_status_processing_rule_id	=> dedn_statproc_rule_id(1),
	    p_input_value_id		=> dedn_calc_frr_iv_id(n),
	    p_result_name		=> dedn_calc_frr_name(n),
	    p_result_rule_type		=> dedn_calc_frr_type(n),
	    p_severity_level		=> dedn_calc_frr_severity(n),
	    p_element_type_id		=> dedn_calc_frr_ele_id(n));

    else

       hr_utility.set_location('hr_upgrade_earnings.ins_uie_input_values ',290);
       v_fres_rule_id := already_exists;

    end if;

   ELSE

      NULL; -- Calc resrule name is null, no need to create.

   END IF;

  END LOOP;

END ins_dedn_formula_processing;


PROCEDURE create_pretax_class_feeds (	p_busgrp_id		in number,
					p_inpval_id		in number,
					p_eff_start_date 	in date) IS

-- This procedure creates feeds to all pretax classification balances
-- in STU and the current business group - except to Startup balances
-- Net and Payments.  The usage of this procedure is for cancelling
-- out the calculated pretax deduction amount...which does not feed
-- Net or Payments, but does feed all other pretax class bals.

l_bal_id	number(9);

already_exists	number;

CURSOR	get_pretax_bals IS
SELECT	pbc.balance_type_id
FROM	pay_balance_classifications pbc,
	pay_element_classifications pec,
	pay_balance_types pbt
WHERE  	nvl(pbc.business_group_id, p_busgrp_id) = p_busgrp_id
AND	nvl(pbc.legislation_code, 'US') = 'US'
AND	pbc.classification_id = pec.classification_id
AND	pec.classification_name = 'Pre-Tax Deductions'
AND	pec.business_group_id is null
AND	pec.legislation_code = 'US'
AND	pbc.balance_type_id = pbt.balance_type_id
AND	pbt.balance_name not in ('Net', 'Payments');

BEGIN

open get_pretax_bals;

loop

  fetch get_pretax_bals into l_bal_id;
  exit when get_pretax_bals%notfound;

  already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> l_bal_id,
				p_bg_id		=> p_busgrp_id,
				p_iv_id		=> p_inpval_id,
				p_eff_date	=> p_eff_start_date);

  IF already_exists = 0 THEN

    hr_balances.ins_balance_feed(
		p_option                      	=> 'INS_MANUAL_FEED',
               	p_input_value_id               	=> p_inpval_id,
               	p_element_type_id              	=> NULL,
               	p_primary_classification_id    	=> NULL,
               	p_sub_classification_id        	=> NULL,
	       	p_sub_classification_rule_id	=> NULL,
               	p_balance_type_id              	=> l_bal_id,
               	p_scale                       		=> '1',
               	p_session_date                 	=> p_eff_start_date,
               	p_business_group               	=> p_busgrp_id,
	       	p_legislation_code             	=> NULL,
             	p_mode                        	=> 'USER');

  END IF;

end loop;

close get_pretax_bals;

END create_pretax_class_feeds;


PROCEDURE create_pretax_cat_feeds (	p_busgrp_id		in number,
					p_src_iv_id		in number,
					p_inpval_id		in number,
					p_eff_start_date 	in date) IS

-- This procedure creates feeds to all pretax CATEGORY balances
-- in STU and the current business group - except to Startup balances
-- Net and Payments.  The usage of this procedure is for cancelling
-- out the calculated pretax deduction amount...which does not feed
-- Net or Payments, but does feed all other pretax cat bals.
-- This will be accomplished by copying all feeds that exist for the
-- Pay Value of the Base element.

l_bal_id	number(9);

already_exists	number;

CURSOR	get_pretax_catbals IS
SELECT	pbf.balance_type_id
FROM		pay_balance_feeds_f pbf,
		pay_balance_types pbt
WHERE  	pbf.input_value_id = p_src_iv_id
AND		nvl(pbf.business_group_id, p_busgrp_id) = p_busgrp_id
AND		nvl(pbf.legislation_code, 'US') = 'US'
AND		pbt.balance_type_id = pbf.balance_type_id
AND		pbt.balance_name not in ('Net', 'Payments');

BEGIN

open get_pretax_catbals;

loop

  fetch get_pretax_catbals into l_bal_id;
  exit when get_pretax_catbals%notfound;

  already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> l_bal_id,
				p_bg_id		=> p_busgrp_id,
				p_iv_id		=> p_inpval_id,
				p_eff_date	=> p_eff_start_date);

  IF already_exists = 0 THEN

    hr_balances.ins_balance_feed(
		p_option                      	=> 'INS_MANUAL_FEED',
               	p_input_value_id               	=> p_inpval_id,
               	p_element_type_id              	=> NULL,
               	p_primary_classification_id    	=> NULL,
               	p_sub_classification_id        	=> NULL,
	       	p_sub_classification_rule_id	=> NULL,
               	p_balance_type_id              	=> l_bal_id,
               	p_scale                       		=> '1',
               	p_session_date                 	=> p_eff_start_date,
               	p_business_group               	=> p_busgrp_id,
	       	p_legislation_code             	=> NULL,
             	p_mode                        	=> 'USER');

  END IF;

end loop;

close get_pretax_catbals;

END create_pretax_cat_feeds;


----------------------- ins_deduction_template Main ------------------------
--
-- Main Procedure
--

BEGIN

--
-- Set session date

hr_utility.set_location('hr_generate_pretax.ins_deduction_template',10);

pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
g_eff_start_date	:= nvl(p_ele_eff_start_date, sysdate);
g_eff_end_date		:= nvl(p_ele_eff_end_date, c_end_of_time);

-- Set "globals": v_bg_name

hr_utility.set_location('hr_generate_pretax.ins_deduction_template',20);
select	name
into	v_bg_name
from 	per_business_groups
where	business_group_id = p_bg_id;

--------------------- Create Balances Types and Defined Balances --------------

/*
dedn_assoc_bal_ids(1) := Primary Balance;
dedn_assoc_bal_ids(2) := Additional Balance;
dedn_assoc_bal_ids(3) := Replacement Balance;
dedn_assoc_bal_ids(4) := Not Taken Balance;
dedn_assoc_bal_ids(5) := Accrued Balance;
dedn_assoc_bal_ids(6) := Arrears Balance;
dedn_assoc_bal_ids(7) := Pretax-Able Balance;
dedn_assoc_bal_ids(8) := Eligible Comp Balance;

*/


--
-- Create associated balances for deductions.
--
dedn_assoc_bal_names(1)		:= p_ele_name;
dedn_assoc_bal_rep_names(1)     := p_ele_name;
dedn_assoc_bal_uom(1)		:= 'Money';

dedn_assoc_bal_names(2)		:= SUBSTR(p_ele_name, 1, 67)||' Additional';
dedn_assoc_bal_uom(2)		:= 'Money';
v_bal_rpt_name	    := SUBSTR(p_ele_name, 1, 17)||' Additional';
dedn_assoc_bal_rep_names(2)     := v_bal_rpt_name;

dedn_assoc_bal_names(3)		:= p_ele_name||' Replacement';
dedn_assoc_bal_uom(3)		:= 'Money';
v_bal_rpt_name	    := SUBSTR(p_ele_name, 1, 17)||' Replacement';
dedn_assoc_bal_rep_names(3)     := v_bal_rpt_name;

dedn_assoc_bal_names(4)		:= SUBSTR(p_ele_name, 1, 67)||' Not Taken';
dedn_assoc_bal_uom(4)		:= 'Money';
v_bal_rpt_name := SUBSTR(p_ele_name, 1, 17)||' Not Taken';
dedn_assoc_bal_rep_names(4)     := v_bal_rpt_name;

dedn_assoc_bal_names(5) := substr(p_ele_name, 1, 71)||' Accrued';
dedn_assoc_bal_uom(5)		:= 'Money';
v_bal_rpt_name := substr(p_ele_name, 1, 21)||' Accrued';
dedn_assoc_bal_rep_names(5)     := v_bal_rpt_name;

dedn_assoc_bal_names(6) := substr(p_ele_name, 1, 71)||' Arrears';
dedn_assoc_bal_uom(6)		:= 'Money';
v_bal_rpt_name := substr(p_ele_name, 1, 21)||' Arrears';
dedn_assoc_bal_rep_names(6)     := v_bal_rpt_name;

dedn_assoc_bal_names(7) := substr(p_ele_name, 1, 71)||' Able';
dedn_assoc_bal_uom(7)		:= 'Money';
v_bal_rpt_name := substr(p_ele_name, 1, 24)||' Able';
dedn_assoc_bal_rep_names(7)     := v_bal_rpt_name;

-- Begin new balance for Eligible Compensations
dedn_assoc_bal_names(8) := substr(p_ele_name, 1, 25)||' Eligible Comp';
dedn_assoc_bal_uom(8)		:= 'Money';
v_bal_rpt_name := substr(p_ele_name, 1, 16)||' Eligible Comp';
dedn_assoc_bal_rep_names(8)     := v_bal_rpt_name;


l_num_assoc_bals		:= 8;

-- Create associated balance types.
FOR i in 1..l_num_assoc_bals LOOP

    -- Check for existence before creating baltype.
    -- If already exists, set dedn_assoc_bal_id(i) appropriately for future reference.

    already_exists := hr_template_existence.bal_exists(
			p_bg_id		=> p_bg_id,
			p_bal_name	=> dedn_assoc_bal_names(i),
			p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

      hr_utility.set_location('hr_upgrade_earnings.upgrade_template',50);

-- ARE WE ABSOLUTELY COMFORTABLE WITH REPORTING NAME = BAL NAME?!
-- DESC PAY_BALANCE_TYPES TO SEE COL LENGTHS.

-- Check balance name is unique to balances within this BG.
      pay_balance_types_pkg.chk_balance_type(
			p_row_id			=> NULL,
  			p_business_group_id		=> p_bg_id,
  			p_legislation_code		=> NULL,
  			p_balance_name			=> dedn_assoc_bal_names(i),
  			p_reporting_name		=> dedn_assoc_bal_rep_names(i),
  			p_assignment_remuneration_flag	=> 'N');

      hr_utility.set_location('hr_upgrade_earnings.upgrade_template',60);

-- Also check balance name is unique to Startup data balances.
      pay_balance_types_pkg.chk_balance_type(
			p_row_id			=> NULL,
  			p_business_group_id		=> NULL,
  			p_legislation_code		=> 'US',
  			p_balance_name			=> dedn_assoc_bal_names(i),
  			p_reporting_name		=> dedn_assoc_bal_rep_names(i),
  			p_assignment_remuneration_flag 	=> 'N');

      hr_utility.set_location('hr_upgrade_earnings.upgrade_template',70);

      v_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> dedn_assoc_bal_names(i),
			p_uom 			=> dedn_assoc_bal_uom(i),
			p_reporting_name 	=> dedn_assoc_bal_rep_names(i),
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL);

    hr_utility.set_location('hr_upgrade_earnings.upgrade_template',80);

    dedn_assoc_bal_ids(i) := v_bal_type_id;

  else

    hr_utility.set_location('hr_upgrade_earnings.upgrade_template',90);

    dedn_assoc_bal_ids(i) := already_exists;

  end if;

--
-- Defined Balances (ie. balance type associated with a dimension)
--
  hr_utility.set_location('hr_upgrade_earnings.upgrade_template',100);

  do_defined_balances(	p_bal_name	=> dedn_assoc_bal_names(i),
			p_bg_name	=> v_bg_name);

  hr_utility.set_location('hr_upgrade_earnings.upgrade_template',110);

  if dedn_assoc_bal_rep_names(i) like '%Eligible%' then

     open get_reg_earn_feeds(p_bg_id);
     loop
	FETCH get_reg_earn_feeds INTO l_reg_earn_classification_id,
        l_reg_earn_business_group_id, l_reg_earn_legislation_code,
	l_reg_earn_balance_type_id, l_reg_earn_input_value_id,
	l_reg_earn_scale, l_reg_earn_element_type_id;
        EXIT WHEN get_reg_earn_feeds%NOTFOUND;

	hr_balances.ins_balance_feed(
	       p_option		=>	'INS_MANUAL_FEED',
               p_input_value_id		=> l_reg_earn_input_value_id,
               p_element_type_id	=> l_reg_earn_element_type_id,
               p_primary_classification_id	=> l_reg_earn_classification_id,
               p_sub_classification_id		=> NULL,
               p_sub_classification_rule_id	=> NULL,
               p_balance_type_id		=> dedn_assoc_bal_ids(i),
               p_scale		=> l_reg_earn_scale,
               p_session_date	=> g_eff_start_date,
               p_business_group		=> p_bg_id,
               p_legislation_code	=> NULL,
               p_mode		=> 'USER');

     end loop;
     close get_reg_earn_feeds;

  end if;

END LOOP;

--
----------------------- Create Element Type -----------------------------
--

--
-- Need to determine and get skip rule formula id and pass it
-- create_element.
--

hr_utility.set_location('hr_generate_pretax.upgrade_template',10);

IF UPPER(p_ele_start_rule) = 'CHAINED' THEN

  hr_utility.set_location('hr_generate_pretax.upgrade_template',15);

  SELECT 	FF.formula_id
  INTO		v_skip_formula_id
  FROM		ff_formulas_f 		FF
  WHERE		FF.formula_name		= 'CHAINED_SKIP_FORMULA'
  AND		FF.business_group_id 	IS NULL
  AND 		FF.legislation_code 	= g_template_leg_code
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date;

ELSIF UPPER(p_ele_start_rule) = 'ET' THEN

  hr_utility.set_location('hr_generate_pretax.upgrade_template',20);
  SELECT 	FF.formula_id
  INTO		v_skip_formula_id
  FROM		ff_formulas_f 		FF
  WHERE		FF.formula_name		= 'THRESHOLD_SKIP_FORMULA'
  AND		FF.business_group_id 	IS NULL
  AND		FF.legislation_code 	= g_template_leg_code
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date;

ELSE -- Just check skip rule and separate check flag.

  hr_utility.set_location('hr_generate_pretax.upgrade_template',25);

  SELECT 	FF.formula_id
  INTO		v_skip_formula_id
  FROM		ff_formulas_f 		FF
  WHERE		FF.formula_name 	= 'FREQ_RULE_SKIP_FORMULA'
  AND		FF.business_group_id 	IS NULL
  AND		FF.legislation_code	= g_template_leg_code
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date;

END IF;

--
-- Find what ele info category will be for SCL.
--

IF UPPER(p_ele_classification) = 'PRE-TAX DEDUCTIONS' THEN

  g_ele_info_cat := 'US_PRE-TAX DEDUCTIONS';

ELSE

  g_ele_info_cat := NULL;

END IF;
--

-- Need to find PRIMARY_CLASSIFICATION_ID of element type.
-- For future calls to various API.
--

hr_utility.set_location('hr_generate_pretax.ins_deduction_template',53);

 begin

select distinct(classification_id)
into   v_primary_class_id
from   pay_element_classifications
where  upper(classification_name) = upper(p_ele_classification)
and    business_group_id is null
and    legislation_code = 'US';

 exception when no_data_found then

  hr_utility.set_location('hr_upgrade_earnings.upgrade_template',999);
  hr_utility.set_location('*** Error: Element Classification NOT FOUND. ***',999);


end;

hr_utility.set_location('pyusuiet',130);

 begin

SELECT 	default_low_priority,
	default_high_priority
INTO	v_class_lo_priority,
	v_class_hi_priority
FROM 	pay_element_classifications
WHERE	classification_id	= v_primary_class_id
AND	business_group_id	is null
AND	legislation_code	= 'US';

 exception when no_data_found then

  hr_utility.set_location('hr_upgrade_earnings.upgrade_template',999);
  hr_utility.set_location('*** Error: Classification priorities NOT FOUND. ***',999);

end;

-- Find default priority for Involuntary Deductions classification
select default_high_priority
into   l_invol_dflt_prio
from   pay_element_classifications
where  UPPER(classification_name) = UPPER(g_invol_class_name)
and    business_group_id is null
and    legislation_code = 'US';

/*
dedn_ele_ids(1)	= Base
dedn_ele_ids(2)	= Withholding
dedn_ele_ids(3)	= Special Inputs
dedn_ele_ids(4)	= Special Features
dedn_ele_ids(5)	= Employer portion of Benefit dedn (ER)

Note, with this configuration we will lost ability in calculator to
find _BEN_EE_CONTR AND _BEN_ER_CONTR database items for benefit dedn...
ie. b/c the dbi are based on the element type on which Coverage is entered.
I think the best way to handle this is to create new database items
for the Calculator to use which can check to see which element type has
the calculator element type as element_information20 - ie. the base
element which has this calculator associated to it...and go from there...
Should be a minor modification to the existing dbi for ben ee and er contr.
*/

-- Element and payroll formula parameter settings:

  dedn_ele_names(1)	:= p_ele_name;
  dedn_ele_repnames(1)	:= p_ele_reporting_name;
  dedn_ele_class(1)	:= p_ele_classification;
  dedn_ele_cat(1)	:= p_ele_category;
  dedn_ele_proc_type(1)	:= p_ele_processing_type;
  dedn_ele_desc(1)	:= p_ele_description;
  dedn_ele_priority(1)	:= p_ele_priority;
  dedn_ele_start_rule(1) := p_ele_start_rule;
  dedn_indirect_only(1)	:= 'N';
  dedn_mix_category(1)	:= p_mix_flag;  -- Make sure to set ddf somewhere...
  dedn_skip_formula(1)	:= v_skip_formula_id;
  dedn_std_link(1)	:= p_ele_standard_link;

-- This pretax withholding element should be one more than
-- the priority on all generated
-- involuntary deductions so they will always process
-- in the correct order, ie. AFTER any wage attachments.

  l_wh_ele_priority	:= l_invol_dflt_prio;
-- This is the best we can do to ensure pretax dedns process after
-- involuntary dedns (wage attachments)...that is to make the
-- processing priority of the withholding element the highest (last
-- processed) priority available for involuntary deductions.

  dedn_ele_names(2)	:= p_ele_name||' Withholding';
  dedn_ele_repnames(2)	:= p_ele_reporting_name||' WH';
  dedn_ele_class(2)	:= p_ele_classification;
  dedn_ele_cat(2)	:= p_ele_category;
  dedn_ele_proc_type(2)	:= 'N';
  dedn_ele_desc(2)	:= p_ele_description;
  dedn_ele_priority(2)	:= l_wh_ele_priority;
  dedn_ele_start_rule(2) := p_ele_start_rule;
  dedn_indirect_only(2)	:= 'Y';  -- Does it have to be Y?
  dedn_mix_category(2)	:= p_mix_flag;  -- Make sure to set ddf somewhere...
  dedn_skip_formula(2)	:= v_skip_formula_id;
  dedn_std_link(2)	:= 'N';

  dedn_ele_names(3)	:= SUBSTR(p_ele_name, 1, 61)||' Special Inputs';
  dedn_ele_repnames(3)	:= SUBSTR(p_ele_reporting_name, 1, 27)||' SI';
  dedn_ele_class(3)	:= p_ele_classification;
  dedn_ele_cat(3)	:= p_ele_category;
  dedn_ele_proc_type(3)	:= 'N';
  dedn_ele_desc(3)	:= 'Generated adjustments element for '||p_ele_name;
  dedn_ele_priority(3)	:= v_class_lo_priority;
  dedn_ele_start_rule(3) := 'OE';
  dedn_indirect_only(3)	:= 'N';
  dedn_mix_category(3)	:= p_mix_flag; -- Make sure to set ddf somewhere...
  dedn_skip_formula(3)	:= NULL;
  dedn_std_link(3)	:= 'N';

  dedn_ele_names(4)	:= SUBSTR(p_ele_name, 1, 61)||' Special Features';
  dedn_ele_repnames(4)	:= SUBSTR(p_ele_reporting_name, 1, 27)||' SF';
  dedn_ele_class(4)	:= p_ele_classification;
  dedn_ele_cat(4)	:= p_ele_category;
  dedn_ele_proc_type(4)	:= 'N';
  dedn_ele_desc(4)	:= 'Generated results element for '||p_ele_name;
  dedn_ele_priority(4)	:= v_class_hi_priority;
  dedn_ele_start_rule(4) := 'OE';
  dedn_indirect_only(4)	:= 'Y';
  dedn_mix_category(4)	:= NULL;
  dedn_skip_formula(4)	:= NULL;
  dedn_std_link(4)	:= 'N';

  l_num_eles		:= 4;

IF p_ele_amount_rule = 'BT' or p_ele_er_match = 'Y' THEN

  hr_utility.set_location('hr_generate_pretax.ins_deduction_template',55);

  select default_priority
  into v_emp_liab_dflt_prio
  from pay_element_classifications
  where classification_name = 'Employer Liabilities'
  /* added check for legislation_code BUG 912994 */
  and legislation_code = g_template_leg_code;

  dedn_ele_names(5)	:= SUBSTR(p_ele_name, 1, 77)||' ER';
  dedn_ele_repnames(5)	:= SUBSTR(p_ele_name, 1, 27)||' ER';
  dedn_ele_class(5)	:= 'Employer Liabilities';
  dedn_ele_cat(5)	:= 'Benefits';
  dedn_ele_proc_type(5)	:= 'N';
  dedn_ele_desc(5)	:= 'Employer portion of benefit.';
  dedn_ele_priority(5)	:= v_emp_liab_dflt_prio;
  dedn_ele_start_rule(5) := NULL;
  dedn_indirect_only(5)	:= 'N';
  dedn_mix_category(5)	:= NULL;
  dedn_skip_formula(5)	:= NULL;
  dedn_std_link(5)	:= 'N';

  l_num_eles		:= 5;

ELSE

  dedn_ele_names(5)	:= null;
  l_num_eles		:= 5;

END IF; -- BENE ER Ele

-- Create all pretax configuration elements.
for x in 1..l_num_eles LOOP

 IF dedn_ele_names(x) IS NOT NULL THEN

  hr_utility.set_location('hr_generate_pretax.ins_deduction_template',51);

  v_ele_type_id :=  ins_dedn_ele_type (	dedn_ele_names(x),
					dedn_ele_repnames(x),
					dedn_ele_desc(x),
					dedn_ele_class(x),
					dedn_ele_cat(x),
					dedn_ele_start_rule(x),
					dedn_ele_proc_type(x),
					dedn_ele_priority(x),
					dedn_std_link(x),
					dedn_skip_formula(x),
					dedn_indirect_only(x),
					g_eff_start_date,
					g_eff_end_date,
					v_bg_name,
					p_bg_id);

  dedn_ele_ids(x) := v_ele_type_id;

-- Make pay value non enterable.

   v_pay_value_name := hr_input_values.get_pay_value_name(g_template_leg_code);

   hr_utility.set_location('hr_generate_pretax.ins_deduction_template',53);

-- hr_utility.trace('Updating '||v_pay_value_name||' for '||dedn_ele_names(x));

   UPDATE 	pay_input_values_f
   SET    	mandatory_flag 	= 'X'
   WHERE  	element_type_id = v_ele_type_id
   AND    	name 		= v_pay_value_name;

   SELECT input_value_id
   INTO   v_payval_id
   FROM   pay_input_values_f
   WHERE  element_type_id 	= v_ele_type_id
   AND    name 			= v_pay_value_name;

   hr_utility.set_location('hr_upgrade_earnings. upgrade_template',157);

  dedn_payval_id(x) := v_payval_id;

 ELSE

  NULL;

 END IF;

END LOOP;

hr_utility.set_location('hr_generate_pretax.ins_deduction_template',57);

IF p_ele_amount_rule = 'BT' or p_ele_er_match = 'Y'  THEN
--
-- Create "Primary" balance for ER Liab and "associate" appropriately.
-- Is there any way to table these optional objects that go with optional elements?
--

  hr_utility.set_location('hr_generate_pretax.ins_deduction_template',58);

  v_balance_name := dedn_ele_names(5);
  v_bal_rpt_name := dedn_ele_repnames(5);

-- Check for existence before creating...

  already_exists := hr_template_existence.bal_exists(
			p_bg_id		=> p_bg_id,
			p_bal_name	=> v_balance_name,
			p_eff_date	=> g_eff_start_date);

  if already_exists = 0 then

    v_er_charge_baltype_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_bal_rpt_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL);

  else

     v_er_charge_baltype_id := already_exists;

  end if;

  do_defined_balances(	p_bal_name 	=> v_balance_name,
			p_bg_name	=> v_bg_name);

-- Associate primary balance...need to look at emp liability ddf first!!!
-- added element_information_Category 12-JUL-00
  update pay_element_types_f
  set ELEMENT_INFORMATION_CATEGORY='US_EMPLOYER LIABILITIES' ,
      element_information10 = v_er_charge_baltype_id
  where element_type_id = dedn_ele_ids(5)
  and g_eff_start_date between effective_start_date and effective_end_date;

--
-- Primary balance feeds
--

  already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> v_er_charge_baltype_id,
				p_bg_id		=> p_bg_id,
				p_iv_id		=> dedn_payval_id(5),
				p_eff_date	=> g_eff_start_date );

  if ALREADY_EXISTS = 0 then

    hr_utility.set_location('hr_generate_pretax.ins_deduction_template',90);

    hr_balances.ins_balance_feed(
		p_option                               	=> 'INS_MANUAL_FEED',
               	p_input_value_id                	=> dedn_payval_id(5),
               	p_element_type_id               	=> NULL,
               	p_primary_classification_id     	=> NULL,
               	p_sub_classification_id         	=> NULL,
	       	p_sub_classification_rule_id    	=> NULL,
               	p_balance_type_id               	=> v_er_charge_baltype_id,
               	p_scale                                	=> '1',
               	p_session_date                  	=> g_eff_start_date,
               	p_business_group                	=> p_bg_id,
	       	p_legislation_code              	=> NULL,
               	p_mode                                 	=> 'USER');

  end if; -- feed exists.

END IF; -- Benefit

--
-------------------------- Insert Formula Processing records -------------
--

hr_utility.set_location('hr_generate_pretax.ins_deduction_template',68);

ins_dedn_formula_processing (	dedn_ele_names(1),
				v_primary_class_id,
				p_ele_classification,
				p_ele_category,
				p_ele_processing_type,
				p_ele_amount_rule,
				p_ele_proc_runtype,
				p_ele_start_rule,
				p_ele_stop_rule,
				p_ele_ee_bond,
				p_ele_paytab_name,
				p_ele_paytab_col,
				p_ele_paytab_row_type,
				p_ele_arrearage,
				p_ele_partial_dedn,
				v_er_charge_eletype_id,
				v_er_charge_payval_id,
				p_bg_id,
				p_mix_flag,
				g_eff_start_date,
				g_eff_end_date,
				v_bg_name);

hr_utility.set_location('hr_generate_pretax.ins_deduction_template',69);

--
------------------------ Insert Balance Feeds -------------------------
--

-- First, call the "category feeder" API which creates manual pay value feeds
-- to pre-existing balances depending on the element classn/category.
-- (Added by ALLEE - 5-MAY-1995)  Pass 'g_ele_eff_start_date' to
-- create_category_feeds in order for datetrack to work.
-- This call presumably feeds the Section 125 and 401k balances
-- when the deduction Classification/Category = PreTax/125 or Deferred Comp
-- as appropriate.


pay_us_ctgy_feeds_pkg.create_category_feeds(
			p_element_type_id =>  dedn_ele_ids(2),
			p_date		  =>  g_eff_start_date);

pay_us_ctgy_feeds_pkg.create_category_feeds(
			p_element_type_id =>  dedn_ele_ids(1),
			p_date		  =>  g_eff_start_date);


hr_utility.set_location('hr_generate_pretax.ins_deduction_template',70);

/* *** WITHHOLDING AND CALCULATOR FEEDS SECTION BEGIN *** */

dedn_base_feed_iv_id(1)		:= dedn_payval_id(1); -- Base Payval to
dedn_base_feed_bal_id(1)	:= dedn_assoc_bal_ids(1); -- Primary Bal

l_num_base_feeds	:= 1;

/* *** WITHHOLDING AND CALCULATOR FEEDS SECTION END *** */

dedn_si_feed_iv_id(1)	:= dedn_si_iv_ids(1); -- Repl amount
dedn_si_feed_bal_id(1)	:= dedn_assoc_bal_ids(3); -- Repl bal

dedn_si_feed_iv_id(2)	:= dedn_si_iv_ids(2); -- Addl amount
dedn_si_feed_bal_id(2)	:= dedn_assoc_bal_ids(2); -- Addl bal

l_num_si_feeds	     	:= 2;


dedn_sf_feed_iv_id(1)	:= dedn_sf_iv_ids(3); -- Repl amount
dedn_sf_feed_bal_id(1)	:= dedn_assoc_bal_ids(3); -- Repl bal

dedn_sf_feed_iv_id(2)	:= dedn_sf_iv_ids(4); -- Addl amount
dedn_sf_feed_bal_id(2)	:= dedn_assoc_bal_ids(2); -- Addl bal

dedn_sf_feed_iv_id(3)	:= dedn_sf_iv_ids(5); -- Not Taken
dedn_sf_feed_bal_id(3)	:= dedn_assoc_bal_ids(4); -- Not Taken bal

l_num_sf_feeds		:= 3;

IF p_ele_arrearage = 'Y' THEN

  dedn_sf_feed_iv_id(4)		:= dedn_sf_iv_ids(2); -- Arrears Contr
  dedn_sf_feed_bal_id(4)	:= dedn_assoc_bal_ids(6); -- Arrears bal

  l_num_sf_feeds		:= 4;

  dedn_si_feed_iv_id(3)		:= dedn_si_iv_ids(3);  -- Adjust arrears
  dedn_si_feed_bal_id(3)	:= dedn_assoc_bal_ids(6); -- Arrears bal

  l_num_si_feeds		:= 3;

--
-- Total Reached bal feeds (stop rule)
-- Needs to be checked within arrearage check because this is also
-- an optional feed...
--
  IF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN

    dedn_sf_feed_iv_id(5)	:= dedn_sf_iv_ids(1); -- Accrued iv to
    dedn_sf_feed_bal_id(5)	:= dedn_assoc_bal_ids(5); -- Accrued Bal

    l_num_sf_feeds		:= 5;

  END IF;

--
-- Total Reached bal feeds (stop rule)
--
ELSIF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN

  dedn_sf_feed_iv_id(4)		:= dedn_sf_iv_ids(1); -- Accrued iv to
  dedn_sf_feed_bal_id(4)	:= dedn_assoc_bal_ids(5); -- Accrued Bal

  l_num_sf_feeds		:= 4;

END IF;


/* Also need to create special features feeds from Ptx Amt and
   Cancel Ptx Amt ivs to all pretax class bals except net and
   payments...write a function.
   Also need to feed this input value to appropriate category balances
   - ie. do same as create_category_feeds procedure...we'll do this
   by a procedure that copies feeds from Base ele pay value...
*/

-- Feeds from Ptx Amt...
create_pretax_class_feeds (	p_busgrp_id	=> p_bg_id,
				p_inpval_id	=> dedn_sf_iv_ids(7),
				p_eff_start_date => g_eff_start_date);

create_pretax_cat_feeds (	p_busgrp_id	=> p_bg_id,
				p_src_iv_id	=> dedn_payval_id(1),
				p_inpval_id	=> dedn_sf_iv_ids(7),
				p_eff_start_date => g_eff_start_date);

-- Feeds from Cancel Ptx Amt...
create_pretax_class_feeds (	p_busgrp_id	=> p_bg_id,
				p_inpval_id	=> dedn_sf_iv_ids(6),
				p_eff_start_date => g_eff_start_date);

create_pretax_cat_feeds (	p_busgrp_id	=> p_bg_id,
				p_src_iv_id	=> dedn_payval_id(1),
				p_inpval_id	=> dedn_sf_iv_ids(6),
				p_eff_start_date => g_eff_start_date);

for y in 1..l_num_base_feeds LOOP

  already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> dedn_base_feed_bal_id(y),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> dedn_base_feed_iv_id(y),
				p_eff_date	=> g_eff_start_date );

  if ALREADY_EXISTS = 0 then

    hr_utility.set_location('hr_generate_pretax.ins_deduction_template',90);

    hr_balances.ins_balance_feed(
		p_option                               	=> 'INS_MANUAL_FEED',
               	p_input_value_id                	=> dedn_base_feed_iv_id(y),
		p_element_type_id               	=> NULL,
               	p_primary_classification_id     	=> NULL,
               	p_sub_classification_id         	=> NULL,
	       	p_sub_classification_rule_id    	=> NULL,
               	p_balance_type_id               	=> dedn_base_feed_bal_id(y),
               	p_scale                                	=> '1',
               	p_session_date                  	=> g_eff_start_date,
               	p_business_group                	=> p_bg_id,
	       	p_legislation_code              	=> NULL,
               	p_mode                                 	=> 'USER');

  end if; -- feed exists.

END LOOP;


  FOR sif in 1..l_num_si_feeds LOOP

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> dedn_si_feed_bal_id(sif),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> dedn_si_feed_iv_id(sif),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => dedn_si_feed_iv_id(sif),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => dedn_si_feed_bal_id(sif),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;


  FOR sf in 1..l_num_sf_feeds LOOP

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> dedn_sf_feed_bal_id(sf),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> dedn_sf_feed_iv_id(sf),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => dedn_sf_feed_iv_id(sf),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => dedn_sf_feed_bal_id(sf),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;



-- Associate balances and elements to base element type:
/*
dedn_assoc_bal_ids(1) := Primary Balance;
dedn_assoc_bal_ids(2) := Additional Balance;
dedn_assoc_bal_ids(3) := Replacement Balance;
dedn_assoc_bal_ids(4) := Not Taken Balance;
dedn_assoc_bal_ids(5) := Accrued Balance;
dedn_assoc_bal_ids(6) := Arrears Balance;
dedn_assoc_bal_ids(7) := Pretax-Able Balance;
dedn_assoc_bal_ids(8) := Eligible Comp Balance;
*/

UPDATE pay_element_types_f
SET    element_information10 = dedn_assoc_bal_ids(1), -- primary bal
       element_information11 = dedn_assoc_bal_ids(5), -- accrued bal
       element_information12 = dedn_assoc_bal_ids(6), -- arrears bal
       element_information13 = dedn_assoc_bal_ids(4), -- not taken bal
       element_information15 = dedn_assoc_bal_ids(7), -- able amount bal
       element_information16 = dedn_assoc_bal_ids(2), -- addl amount bal
       element_information17 = dedn_assoc_bal_ids(3), -- repl amount bal
       element_information18 = dedn_ele_ids(3), -- Special Inputs
       element_information19 = dedn_ele_ids(4), -- Special Features
       element_information20 = dedn_ele_ids(2)  -- Withholding ele
WHERE  element_type_id       = dedn_ele_ids(1)
AND    business_group_id + 0 = p_bg_id;


----------------------------- Conclude Main -----------------------------

RETURN dedn_ele_ids(1);

END pretax_deduction_template;

END hr_generate_pretax;

/
