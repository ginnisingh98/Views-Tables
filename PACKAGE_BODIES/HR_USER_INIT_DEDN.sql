--------------------------------------------------------
--  DDL for Package Body HR_USER_INIT_DEDN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_USER_INIT_DEDN" AS
/* $Header: pyusuidt.pkb 120.3.12010000.2 2008/11/17 13:35:31 sudedas ship $ */
-- PACKAGE BODY hr_user_init_dedn IS
/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : hr_user_init_dedn

    Filename	: pyusuidt.pkb

    Change List
    -----------
    Date        Name          	Vers    Bug No	Description
    ----        ----          	----	------	-----------
    29-OCT-93   H.Parichabutr  	1.0             First Created.
                                                Initial Procedures
    02-NOV-93	hparicha			Completed initial creation.
    04-NOV-93	hparicha	1.1		Added updates to SCL, inpval
						defaulting (where applicable),
						Adding locking and delete
						procedures.
    18-JAN-94	hparicha	40.19		p_ele_category is receiving
						LOOKUP_CODE!  Make appropriate
						comparison for Section 125 and
						Deferred Compensation.
						(Been lax on this change list
						- check the arcs log).
    21-FEB-94	hparicha	40.24	G571	Changed 'COVERAGE_TYPE' to
						'US_BENEFIT_COVERAGE'.
						(Been lax on this change list
						- check the arcs log).
    03-JUN-94	hparicha	40.1	G815	Added "MIX Category" param
						and DDF segment.
    16-JUN-94	hparicha	40.2	G934
    03-JUL-94	hparicha	40.3		Tidy up for 10G install.
    13-JUL-94	hparicha	40.4	G907	New implementation of Earnings
						and Deductions without use
						of update recurring fres rules.
						(aka BETA I freeze)
    22-AUG-94	hparicha	40.5	G1241	Add new defined balances req'd
						for view dedns screen.
						Creating "Not Taken" inpval
						on shadow whether or not
						partial flag is Yes or No - ie.
						we need to report dedns not
						taken in either case.  Same
						for "Arrears Contr", just for
						predictability and consistency.
						Create "Not Taken" balance
						type for Dedns Not Taken rpt.
						Feed "Not Taken" bal by
						Special Features "Not Taken"
						inpval.  Changed name of
						"Towards Bond Purchase" to
						"Toward...".
						Update element type DDF with
						associated balances.
    26-SEP-94	hparicha	40.6	G1201	Add "_GRE_YTD" defined bal w/
						Primary balance type - for
						summary reporting.
						Add deletion of "Not Taken" bal
						and handle name change of
						"...Towards Bond Purchase" to
						"...Toward Bond Purchase" in
						formula and deletion.
    05-OCT-94	rfine		40.7		Changed calls to DB_PAY_SETUP
						to PAY_DB_PAY_SETUP.
    18-OCT-94   spanwar         40.8            Removed "PER_PTD" and "PER_LR"
                                                balance dimension from
                                                dimension list since it is no
                                                longer supported.
				40.9		changed '-Able' to '_Able' for
						pretax dedn balance name.
    21-OCT-94	spanwar		40.10		Removed "PER_LR".
    24-NOV-94   rfine           40.11           Suppressed index on
						business_group_id
    05-DEC-94	hparicha	40.12	G1571	Added 'Payments' defbal for
						primary balance.
    21-DEC-94	hparicha	40.13	G1681	Clear/Adjust arrears fn'ality.
    02-MAR-95   spanwar                         Added call to category feeder
                                                in insert bal feeds section.
    05-MAY-95	allee			        Added global session date to
						the call to category feeder.
    14-JUN-95	hparicha	40.17	286491	Deletion of all balances via
						assoc bal ids held in
						ELEMENT_INFORMATIONxx columns.
						New params to "do_deletions".
    16-JUN-95	hparicha	40.18	271622	Deletion of freq rule info.
    29-JUN-95	hparicha	40.19	289319	Generate "Primary" balance
						and feeds for "ER Liab" when
						dedn is a benefit.  Remember
						to delete the bal and feeds!
						Defined balances are
						required for "_ASG_GRE_RUN/
						PTD/MONTH/QTD/YTD" - and
						also for PER and PER_GRE.
    30-JUN-95	hparicha	40.20		Added "Court Order" input
						value to garnishments.
						Also, set new param to
						create_element_type for
						p_third_party_pay_only = Y
						for garns.
    30-JUN-95	hparicha	40.21		Add benefit classification id
						to ele type update NO MATTER
						WHAT the calculation method is.
    03-AUG-95	hparicha	40.22		EE Bond Refund primary assoc
						balance created, defbals and
						feed also created.
						?Ben class may have
						?CONTRIBUTIONS_USED = 'N', in
						?which case the formula must
						?be altered NOT TO USE the
						?dbi "...BEN_EE_CONTR_VALUE"
						?and "...BEN_ER_CONTR_VALUE".
    17-OCT-95	hparicha	40.25	315814	Added call to bal type pkg
						to check for uniqueness of
						"Primary Associated Balance"
						name - ie. has same name as
						element type being generated.
    09-JAN-96	hparicha	40.26	333133	Added defined balances for "_GRE_RUN",
                                                _GRE_YTD, _GRE_ITD to do_defined_balances
                                                procedure.  This allows for GRE-level
                                                reporting of earnings and deductions.
    09-JAN-96   mswanson        40.27   333133  Add defined bal for arrears deductions with
                                                "_GRE_ITD" dimensions.
    12-JAN-96   mswanson        40.28           Restrict qry on dimension by legislation code.
    01-APR-96	hparicha	40.29	348658	Added element type id to Indirect formula
                                                result rules enabling Formula Results screen
                                                to display element name.
    15-Jul-1996	hparicha	40.30	373543  Changing creation of pretax
					        deductions such that they are
					        calculated before taxes, yet withheld
					        after taxes and wage attachments.
					        Now calls new package to create
					        pretax dedns.
    96/08/14	lwthomps	40.32	345102  Added the primary balance_id to post tax ER
                                                elements.
    16-Aug-1996 gpaytonm	40.33	        Removed call to hr_generate_pretax.pretax_ded
                                                uction_template which removes bug fix 373543
    12-Sep-1996	hparicha	40.34	373543  calls hr_generate_pretax again.
    05-Nov-1996	hparicha	40.35	413211  updated deletion procedure
				                to handle latest configuration -
				                esp. for pretax dedns...involved
				                addition of params to deletion
				                procedure.  Also added DDF
				                associations on voluntary
				                deductions for special inputs
				                and special features elements,
				                additional, replacement and
				                ee bond refund balances.
     07-Nov-1996 hparicha	40.36	413211  Deletion procedure
				                needs to cleanup OLD formulae
				                created during pretax upgrades.
     08 Nov 1996 hparicha	40.37           Dimension name for _PER_GRE_RUN
                      				reverted in generator code.

     11-Jul-1997 mmukherj        40.38  502307  changed do_defined_balances procedure to check
                                                whether record already exists in
                                                pay_defined_balances table or not for that
                                                business_group.Same changes has been made in
                                                pywatgen.pkb(involuntary deduction) and
                                                pygenptx.pkb(pretax deduction)
     18-Feb-1998 mmukherj        40.39  566328  do_deletions procedure is modified to
                                                include business_group_id in one a select
                                                (without cursor) statement, which was
                                                selecting more than one row for a given
                                                element_name.

     30-Apr-1998 pmadore	40.40           Added additonal input values, formula result
                                                rules, elements, and balances to support the
                                                Aftertax components of a pretax deduction in
                                                category of Deferred Comp 401k. The logic to
                                                create these objects depends upon the values
					        of two new parameters to the main package
                                                function:
                                                  p_ele_er_match AND p_ele_at_component
     18-Aug-1998 mmukherj       40.42   703234  Changed the procedure get_assoc_ele, set
                                                default value of l_val as 'N', so that if
                                                csr_sfx does not does not fetch any row
                                                l_val passes the value 'N', instead of '',
                                                which was creating problem in the form.
                                                Because aftertax_component_flag and
                                                employer_match_flag were not being set to
                                                any value.
     30 Dec 1998 mmukherj      110.4    787491  Entered business_group_id in all where
                                                condition of the select statements of
                                                do_deletions procedure.
     NOTE:
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

        For All Future Bugfixes: Please use business group_id in new DML statements ,
        whenever necessary, because we are allowing to create deduction with same name
        for two different business groups - mmukherj.

     01/08/1997  asasthan   110.5  773036    Added legislation code for US/Canada
                                            interoperability.

     07/29/1999  Rpotnuru   110.6            The variable  v_notaken_bal_type_id was
                                            used for Eligible comp and Over limit
                                            balances were also created using the same
                                            variable and because of this the system
                                            is creating wrong balance feeds. So two
                                            new variables for eleigible comp and
                                            Over limit balance were created and used
                                            accordingly. Added ASG_GRE_RUN dimension
                                            to Arrears balance.

     01/22/2002  ahanda     115.6           Added _ASG_PAYMENTS dimension
     25-Mar-2002 ekim       115.8  2276457  Added p_termination_rule to
                                            ins_deduction_template and update of
                                            pay_element_types_f for
                                            termination rule update
     24-Jul-2002 ekim       115.9           changed v_bg_name to
                                            per_business_groups.name%TYPE
     23-DEC-2002 tclewis    115.10          11.5.9. performance changes.
     27-DEC-2002 meshah     115.11          fixed gscc warnings.
     01-APR-2003 ahanda     115.12          Changed the defined balance creation for
                                            ASG_GRE_RUN to save run balance for Primary,
                                            Not Taken, Arrears and Accrued Bal.
     26-JUN-2003 ahanda     115.13          Changed call to create_balance_type procedure
                                            to pass the balance name as reporting name.
                                            Added code to populate 'After-Tax Deductions'
                                            category for balances
     07-JAN-2004 rsethupa   115.15 3349594  11.5.10 performance changes
     08-JAN-2004 rsethupa   115.16 3349594  Removed extra comment added in 115.15 version
     18-MAR-2004 kvsankar   115.17 3311781  Changed call to create_balance_type
                                            procedure to pass the balance_category value
                                            depending upon the classification of the
                                            element instead of passing 'After-Tax Deductions'
					    for deduction elements.
     20-MAY-2004 meshah     115.18          removed the logic not required for
                                            Non-Recurring elements. Like creation of
                                            additional and replacement defined balances.
     21-MAY-2004 meshah     115.19          fixed gscc error File.Sql.2 and File.Sql.17
     21-JUL-2004 schauhan   115.20 3613575  Added a table pay_element_types_f to a query
					    in procedure do_deletions to remove Merge Join Cartesian.
     22-JUL-2004 schauhan   115.21 3613575  Added rownum<2 condition to the query modified in previous
					    version.
     18-AUG-2004 sdhole     115.22 3651755  Removed balance category parameter for the
					    Eligible Comp balance.
     23-JAN-2007 alikhar    115.23 5763867  Added code to populate element_information_category
                            115.24          for Voluntary Deduction ER shadow element with
                                            amount type as Benefits Table.
     21-JAN-2008 sudedas    115.25 6270794  Added Defined Balance for ' Accrued' Balance
                                            with Dimension _ENTRY_ITD.
     17-NOV-2008 sudedas    115.26 7535681  Procedure do_deletions is modified
                                            to remove ' Refund' element/balance
                                            when "EE Series Bond" is checked.
*/

/*
---------------------------------------------------------------------
This package contains calls to core API used to insert records comprising an
entire deduction template.

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

-- Controlling procedure that calls all insert procedures according to
-- locking ladder.  May perform some simple logic.  More involved logic
-- is handled inside various insertion procedures as required,
-- especially ins_uie_formula_processing.
--
-- If any part of this package body fails, then rollback entire transaction.
-- Return to form and alert user of corrections required or to notify
-- Oracle HR staff in case of more serious error.

-- Please Note: PL/SQL v1 does not support explicit naming
-- of parameters in procedure/function calls.  Which only means
-- Forms 4 cannot call server-side PL/SQL using explicitly named parameters.

--
------------------------------- Insertions ------------------------------
--
-- Procedures to perform insertions of user-initiated earnings data:
-- Move inside ins_deduction_template.
--
------------------------- ins_deduction_template ------------------------
--
-- Move all other insert fns and procedures into here(?).
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
                ) RETURN NUMBER IS

-- global vars
-- Legislation Subgroup Code for all template elements.
g_template_leg_code		VARCHAR2(30) := 'US';
g_template_leg_subgroup		VARCHAR2(30);
g_arrears_contr_inpval_id	NUMBER(9);
g_adj_arrears_inpval_id		NUMBER(9);
g_to_tot_inpval_id		NUMBER(9);
g_topurch_inpval_id		NUMBER(9);
g_ele_info_cat			VARCHAR2(30);
--
g_inpval_disp_seq 		NUMBER := 0;	-- Display seq for input vals.
g_shadow_inpval_disp_seq 	NUMBER := 0; -- Display seq for shadow inpvals.
g_inputs_inpval_disp_seq 	NUMBER := 0; -- Display seq for shadow inpvals.
g_er_inpval_disp_seq		NUMBER := 0; -- Display seq for ER component inpvals.
g_eff_start_date  DATE;
g_eff_end_date  DATE;

-- local constants
 c_end_of_time  CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');

-- local vars
v_bg_name		per_business_groups.name%TYPE;
                        -- Get from bg short name passed in.
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
v_earn_bal_uom		VARCHAR2(30)	:= 'M';
v_balance_name		VARCHAR2(80);	-- Additional balances req'd by dedn.
--v_bal_rpt_name	VARCHAR2(30);
v_bal_dim		VARCHAR2(80);
v_inpval_id		NUMBER(9);
v_payval_id		NUMBER(9);	-- ID of payval for bal feed insert.
v_payval_name		VARCHAR2(80);	-- Name of payval.
v_shadow_info_payval_id	NUMBER(9);
v_inputs_info_payval_id	NUMBER(9);
--
v_payval_formula_id	NUMBER(9); -- ID of formula for payvalue validation.
v_totowed_bal_type_id	NUMBER(9);
v_eepurch_bal_type_id	NUMBER(9);
v_arrears_bal_type_id	NUMBER(9);
v_notaken_bal_type_id	NUMBER(9);
v_eligiblecomp_bal_type_id NUMBER (9);
v_overlimit_bal_type_id NUMBER(9);
v_able_bal_type_id	NUMBER(9);
v_sect125_bal_type_id	NUMBER(9);
v_401k_bal_type_id	NUMBER(9);
--
v_addl_amt_bal_type_id	NUMBER(9);	-- Pop'd by insertion of balance type.
v_addl_amt_bal_name 	VARCHAR2(80);
v_repl_amt_bal_type_id	NUMBER(9);	-- Pop'd by insertion of balance type.
v_repl_amt_bal_name 	VARCHAR2(80);
g_addl_inpval_id	NUMBER(9);	-- ID of Addl Amt inpval for bal feed.
g_repl_inpval_id	NUMBER(9);	-- ID of Replacement Amt inpval for bal feed.
gi_addl_inpval_id	NUMBER(9);	-- ID of Addl Amt inpval for bal feed.
gi_repl_inpval_id	NUMBER(9);	-- ID of Replace Amt inpval for bal feed.
--
g_notaken_inpval_id	NUMBER(9);	-- ID of Not Taken inpval for bal feed.
v_eerefund_eletype_id	NUMBER(9);
v_eerefund_payval_id	NUMBER(9);
v_topurch_eletype_id	NUMBER(9);
v_er_charge_eletype_id	NUMBER(9);
v_er_charge_baltype_id	NUMBER(9);
v_er_charge_payval_id	NUMBER(9); -- inpval id of ER charge PAY VALUE
v_eerefund_ele_name	VARCHAR2(80);
v_eerefund_baltype_id	NUMBER(9);
v_topurch_ele_name	VARCHAR2(80);
v_er_charge_ele_name	VARCHAR2(80);
v_skip_formula_id	NUMBER(9);

l_reg_earn_classification_id    number(9);
l_reg_earn_business_group_id    number(15);
l_reg_earn_legislation_code     varchar2(30);
l_reg_earn_balance_type_id      number(9);
l_reg_earn_input_value_id       number(9);
l_reg_earn_scale                number(5);
l_reg_earn_element_type_id      number(9);

-- Emp Balance form enhancement Bug 3311781
l_balance_category              varchar2(80);

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
				p_bg_name		in varchar2)
RETURN number IS
-- local vars
ret			NUMBER;
v_pay_value_name	VARCHAR2(80);
v_mult_entries_allowed	VARCHAR2(1);
v_third_ppm		VARCHAR2(30)	:= 'N';

BEGIN

--
-- Unless this function actually has to do anything, we can make call
-- to pay_db_pay_setup from ins_deduction_template.
--

hr_utility.set_location('hr_user_init_dedn.ins_dedn_ele_type',10);

IF p_ele_processing_type = 'N' THEN

  v_mult_entries_allowed := 'Y';

ELSE

  v_mult_entries_allowed := 'N';

END IF;

IF UPPER(p_ele_class) 		= 'INVOLUNTARY DEDUCTIONS' AND
   UPPER(p_ele_category)	= 'G' AND
   UPPER(p_ele_name)	 NOT LIKE '%SPECIAL INPUTS' AND
   UPPER(p_ele_name)	 NOT LIKE '%SPECIAL FEATURES' THEN

  v_third_ppm := 'Y';

END IF;

hr_utility.set_location('hr_user_init_dedn.ins_dedn_ele_type',30);
ret := pay_db_pay_setup.create_element(
			p_element_name 		=> p_ele_name,
		       	p_description 		=> p_ele_description,
                       	p_classification_name 	=> p_ele_class,
                       	p_post_termination_rule => 'Final Close',
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
--
v_pay_value_name := hr_input_values.get_pay_value_name(g_template_leg_code);
--
UPDATE pay_input_values_f
SET    mandatory_flag 	= 'X'
WHERE  element_type_id 	= ret
AND    name 		= v_pay_value_name;
--
RETURN ret;
--
END ins_dedn_ele_type;
--
------------------------- ins_formula -----------------------
--
FUNCTION ins_formula (	p_ff_ele_name		in varchar2,
			p_ff_suffix		in varchar2,
			p_ff_desc		in varchar2,
			p_ff_bg_id		in number,
			p_amt_rule		in varchar2 default NULL,
			p_row_type		in varchar2 default NULL,
                        p_ele_processing_type   in varchar2)
RETURN number IS
-- local vars
v_formula_id	number;		-- Return var
--
v_skeleton_formula_text		VARCHAR2(32000);
v_skeleton_formula_type_id	NUMBER(9);
v_ele_formula_text		VARCHAR2(32000);
v_ele_formula_name		VARCHAR2(80);
v_ele_formula_id		NUMBER(9);
v_ele_name			VARCHAR2(80);

BEGIN
  hr_utility.set_location('hr_user_init_dedn.ins_formula',10);

  if p_ele_processing_type = 'R' then

     SELECT FF.formula_text, FF.formula_type_id
       INTO v_skeleton_formula_text, v_skeleton_formula_type_id
     FROM ff_formulas_f	FF
     WHERE FF.formula_name = 'SYSTEM_DEDN_CALC_FORMULA'
       AND FF.business_group_id	IS NULL
       AND FF.legislation_code	= 'US'
       AND FF.formula_id >= 0  --Bug 3349594
       AND g_eff_start_date  between  FF.effective_start_date
                                  AND FF.effective_end_date;

  else

     SELECT FF.formula_text, FF.formula_type_id
       INTO v_skeleton_formula_text, v_skeleton_formula_type_id
     FROM ff_formulas_f FF
     WHERE FF.formula_name = 'SYSTEM_DEDN_CALC_NR_FORMULA'
       AND FF.business_group_id IS NULL
       AND FF.legislation_code  = 'US'
       AND FF.formula_id >= 0  --Bug 3349594
       AND g_eff_start_date  between  FF.effective_start_date
                                  AND FF.effective_end_date;

  end if; /* p_ele_processing_type  */

-- Replace element name placeholders with current element name:
  hr_utility.set_location('hr_user_init_dedn.ins_formula',15);
  v_ele_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');

  v_ele_formula_text := REPLACE(	v_skeleton_formula_text,
				 	'<ELE_NAME>',
					v_ele_name);
--
-- Make <ROW_TYPE> replacements if necessary.
--
  IF p_amt_rule = 'PT' THEN
    IF p_row_type NOT IN ('Salary Range', 'Age Range') THEN
      hr_utility.set_location('hr_user_init_dedn.ins_formula',17);
      v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE>',
					REPLACE(LTRIM(RTRIM(p_row_type)),' ','_'));

      hr_utility.set_location('hr_user_init_dedn.ins_formula',19);
      v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					'default for ' || REPLACE(LTRIM(RTRIM(p_row_type)),' ','_') || ' (text) is ''NOT ENTERED''');

      v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					',' || REPLACE(LTRIM(RTRIM(p_row_type)),' ','_') || ' (text)');

    ELSE

--
-- Do we need to handle when row type is Salary Range, ie. use ASS_SALARY dbi?
-- Do we also need to create Default For ASS_SALARY or PER_AGE as appropriate?
--
      hr_utility.set_location('hr_user_init_dedn.ins_formula',20);
      v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE>',
					'To_Char(PER_AGE)');

      hr_utility.set_location('hr_user_init_dedn.ins_formula',21);
      v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					' ');

      v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					' ');

    END IF;

--
--  "Zero" benefits
--
      hr_utility.set_location('hr_user_init_dedn.ins_formula',23);
     v_ele_formula_text := REPLACE(	v_ele_formula_text,
					v_ele_name || '_BEN_EE_CONTR_VALUE',
					'0');

     v_ele_formula_text := REPLACE(	v_ele_formula_text,
					v_ele_name || '_BEN_ER_CONTR_VALUE',
					'0');

     v_ele_formula_text := REPLACE(	v_ele_formula_text,
					'<DEFAULT_BEN_EE_LINE>',
					' ');

     v_ele_formula_text := REPLACE(	v_ele_formula_text,
					'<DEFAULT_BEN_ER_LINE>',
					' ');

  ELSIF p_amt_rule = 'BT' THEN

--
--  Using benefits, <ELE_NAME>_BEN_EE_CONTR_VALUE is already taken care of.
--
    hr_utility.set_location('hr_user_init_dedn.ins_formula',25);
    v_ele_formula_text := REPLACE(	v_ele_formula_text,
					'<DEFAULT_BEN_EE_LINE>',
					'default for ' || v_ele_name || '_BEN_EE_CONTR_VALUE is 0');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
					'<DEFAULT_BEN_ER_LINE>',
					'default for ' || v_ele_name || '_BEN_ER_CONTR_VALUE is 0');

-- Clear out <ROW_TYPE>
    v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE>',
					'''NOT ENTERED''');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					' ');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					' ');

  ELSE

--
-- Clear out everything!
-- Clear out <ROW_TYPE>
    hr_utility.set_location('hr_user_init_dedn.ins_formula',27);
    v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE>',
					'''NOT ENTERED''');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<DEFAULT_ROW_TYPE_LINE>',
					' ');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
				 	'<ROW_TYPE_INPUTS_ARE>',
					' ');

--
--  "Zero" benefits
--
    v_ele_formula_text := REPLACE(	v_ele_formula_text,
					v_ele_name || '_BEN_EE_CONTR_VALUE',
					'0');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
					v_ele_name || '_BEN_ER_CONTR_VALUE',
					'0');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
					'<DEFAULT_BEN_EE_LINE>',
					' ');

    v_ele_formula_text := REPLACE(	v_ele_formula_text,
					'<DEFAULT_BEN_ER_LINE>',
					' ');

  END IF;

  v_ele_formula_name := v_ele_name || UPPER(p_ff_suffix);
  v_ele_formula_name := SUBSTR(v_ele_formula_name, 1, 80);

--
-- Insert the new formula into current business goup:
-- Get new id

  hr_utility.set_location('hr_user_init_dedn.ins_formula',30);
  SELECT 	ff_formulas_s.nextval
  INTO		v_formula_id
  FROM 		sys.dual;

  hr_utility.set_location('hr_user_init_dedn.ins_formula',40);
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
 	v_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_ele_formula_name,
	p_ff_desc,
	v_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	g_eff_start_date);

RETURN v_formula_id;

END ins_formula;

--
------------------------- ins_dedn_formula_processing -----------------------
--
PROCEDURE ins_dedn_formula_processing (
			p_ele_id 		in number,
			p_ele_name 		in varchar2,
			p_shadow_ele_id 	in number,
			p_shadow_ele_name 	in varchar2,
			p_inputs_ele_id 	in number,
			p_inputs_ele_name 	in varchar2,
			p_primary_class_id	in number,
			p_ele_class_name	in varchar2,
			p_ele_cat		in varchar2,
			p_ele_proc_type		in varchar2,
               		p_amount_rule 		in varchar2,
			p_proc_runtype	 	in varchar2	default 'R',
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
			p_eerefund_eletype_id	in number	default NULL,
			p_bg_id 		in number,
			p_mix_category		in varchar2	default NULL,
			p_eff_start_date 	in date default NULL,
			p_eff_end_date 		in date default NULL,
			p_bg_name 		in varchar2) IS

-- local vars
v_fname			VARCHAR2(80);
v_ftype_id		NUMBER(9);
v_fdesc			VARCHAR2(240);
v_ftext			VARCHAR2(32000); -- "Safe" max length of varchar2
v_sticky_flag		VARCHAR2(1);
v_asst_status_type_id 	NUMBER(9);
v_stat_proc_rule_id	NUMBER(9);
v_fres_rule_id		NUMBER(9);
v_proc_rule		VARCHAR2(1) := 'P'; -- Provide "Process" proc rule.
v_calc_rule_formula_id 	NUMBER(9);
v_er_contr_inpval_id	NUMBER(9); -- inpval id of ER Contr to feed ER chrg
v_er_payval_id		NUMBER(9); -- paybal id of ER Contr (if not passed in)
v_bondrefund_inpval_id	NUMBER(9); -- inpval id;"Bond Refund" to feedDirPay.
v_eerefund_payval_id	NUMBER(9); -- inpval id of "EE Bond Refund" ele payval
v_to_owed_inpval_id	NUMBER(9); -- inpval id for Tot Reached stop rule
v_to_arrears_inpval_id	NUMBER(9); -- inpval id for To Arrears rule
v_notaken_inpval_id	NUMBER(9); -- inpval id for Not Taken (arrears = 'Y')
v_actdedn_inpval_id	NUMBER(9); -- inpval id for "Deduction Actually Taken" amount
v_passthru_inpval_id	NUMBER(9); -- inpval id for "Take OverLimit AT" amount

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
v_user_row_title	VARCHAR2(80);
--
-- In the case of earnings elements, the formulae are fully defined in advance
-- based on calculation rule only.  These pre-packaged formulae are seeded
-- as startup data - such that bg_id is NULL, in the appropriate legislation.
-- The formula_name will closely resemble the calc rule.
-- For deductions, formula is "pieced together" according to calc_rule
-- and other attributes. (Maybe, let's pre-defined them first.  Having them
-- pre-defined AND COMPILED makes things a bit easier.)

-- To copy a formula from seed data to the user's business group, we can
-- select the formula_text LONG field into a VARCHAR2; the LONG field
-- in the table can then accept the VARCHAR2 formula text as long as it
-- does not exceed 32767 bytes (varchar2 will be 32000 to be safe).

-- Make direct calls to CORE_API packaged procedures to:
-- 1) Insert status proc rule of 'PROCESS' for Asst status type 'ACTIVE_ASSIGN'
-- and appropriate formula according to calculation method
-- 2) Insert input values according to calculation method
--	- Also make call to ins_uie_input_vals for insertion of additional
--	input values based on class/category and others required of
--	ALL template earnings elements.
-- 3) Insert formula result rules as appropriate for formula and amount rule.
-- 4) Insert additional formula result rules according to other deduction
--    attributes.
--
BEGIN		-- Deduction Formula Processing
--
-- Check for % Earnings amount rule.
--
-- "% EARNINGS"
-- First, update SCL
--	  ( ) Category in segment 1;
--	  ( ) Partial EE Contributions in seg 2 (if not Involuntary Dedn)
--	  ( ) MIX Category in segment 9
--	  ( ) insert formula and save formula_id;
-- Insert status proc rule;
-- Insert input vals;
--	  (*) "Percentage"
--	  (*) "Earnings Balance" (lkp val to hr lkps for val bals)
--	  (*) "Earn Bal Dimension" (default to "ASS_RUN"; lkp val for dims)
--	  (*) "Additional Amount" (wait to insert this "Global" inpval)
--	  (*) "Replacement Amount" (wait to insert this "Global" inpval)
--	      (These are the ONLY "global" inpval for deductions.
-- Insert formula result rules;
--	  (*) dedn_amt 		--> Direct
--	  (*) stop_entry 	--> Stop
--	  ( ) clear_addl_amt	--> Update Recurring inpval "Additional Amount"
--	  ( ) clear_repl_amt	--> Update Rec inpval "Replacement Amount"
--
--  *** IF UPPER(p_ele_proc_type) = 'R' THEN
-- Resolve this issue over Rec/Nonrec versions of formulae
    -- ( ) Do we need to do this?  If a nonrecurring element has no formula
    --     result rule for STOP_ENTRY, then what difference does it make?
    --     Ie. why do we need separate formulae for Recurring and Nonrecurring
    --     if the only difference is stop entry?;
    --
    -- Recurring version of formula has final pay "Stop Entry". See issue above.
    --
    -- Find formula id of element's % Earnings formula;
    -- May be able to pass in element's formula name as created earlier,
    -- instead if [re]constructing it here.
-- Now create formula for element by selecting "skeleton" calculation formula
-- and performing string substitutions for element name in proper placeholders.
-- The formula is then inserted into the current business group.
-- Other placeholders will be substituted based on other attributes (ie.
-- balances and arrears).  When finished, the formula can be compiled.
--
IF UPPER(p_amount_rule) = 'PE' THEN
-- Set SCL:
--  IF UPPER(p_ele_class_name)	= 'INVOLUNTARY DEDUCTIONS' THEN
-- Populate segments 1,2,3 w/Category, PayTab, PayTab Row.
   hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',05);
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= p_ele_id
    AND		business_group_id + 0 		= p_bg_id;

 hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',05);
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= p_shadow_ele_id
    AND		business_group_id + 0 		= p_bg_id;


If p_ele_proc_type = 'R' then   /* Not required for NR Elements */

 hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',05);
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= p_inputs_ele_id
    AND		business_group_id + 0 		= p_bg_id;

End if;  /* Not required for NR Elements */

--
-- *1* Testing note: formula name should be '<ELE_NAME>_PERCENT_EARNINGS'
-- in this case.
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',15);
  v_calc_rule_formula_id := ins_formula  (
	p_ff_ele_name	=> p_ele_name,
	p_ff_suffix	=> '_PERCENT_EARNINGS',
	p_ff_desc	=> 'Percent Earnings calculation for deductions.',
	p_ff_bg_id	=> p_bg_id,
	p_amt_rule	=> NULL,
	p_row_type	=> NULL,
        p_ele_processing_type => p_ele_proc_type );

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',17);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> p_eff_start_date,
		p_effective_end_date 		=> p_eff_end_date,
		p_element_type_id 		=> p_ele_id,
		p_assignment_status_type_id 	=> v_asst_status_type_id,
		p_formula_id 			=> v_calc_rule_formula_id,
		p_processing_rule		=> v_proc_rule);
--
-- Remember: NULL asst_status_type_id means "Standard" processing rule!

-- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
-- Creating "Percentage" inpval
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',20);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
    v_inpval_name 	:= 'Percentage';
    v_inpval_uom 	:= 'Number';
    v_gen_dbi		:= 'Y';
    v_lkp_type 		:= NULL;
    v_dflt_value	:= NULL;
    v_inpval_id 	:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',25);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',27);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
  --
  -- (HERE) Done inserting "Percentage" input value.
  --
  -- Creating "Earnings Balance" inpval
  -- 08 Jun 1994: This is not used as of yet - Fast Formula requires the
  -- balance name to be "hard-coded" in order to retreive its' value; possibly
  -- next version of plsql/FF will allow us to hold the balance name on an
  -- input value.  Until then, the user may replace the REGULAR_EARNINGS
  -- balance used by default with any balance they choose.
  -- When this is implemented, create both a Balance Name inpval along with
  -- a Balance Dimension inpval.  Lookups can be created in order to validate
  -- these inpvals.
  --
--
-- Now insert appropriate formula_result_rules for this element
--

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',47);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'DEDN_AMT',
	p_result_rule_type		=> 'D',
	p_severity_level		=> NULL,
	p_element_type_id		=> NULL);

  IF p_ele_proc_type = 'R' THEN
    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',50);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'STOP_ENTRY',
	p_result_rule_type		=> 'S',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_ele_id);
  END IF;
--
-- Check for Payroll Table amount rule:
--
ELSIF UPPER(p_amount_rule) = 'PT' THEN
-- Update element type SCL as appropriate;
--	  ( ) Populate Category segment 1
--	  ( ) Populate Partial EE Contributions segment 2
--	  ( ) Populate payroll table/row segments
--		(segments 6,7 if Vol or Pre-Tax;
--		 segments 3,4 if Invol)
-- Insert input vals;
--	  (*) "Table Column" 		(default to p_ele_paytab_col)
--	  ( ) Also requires input value for "Table Row" if value in
--		p_ele_paytab_row is NOT a database item.  If it IS a dbi_name,
--		then we do not create inpval for it, the value is stored on
--		the SCL and formula picks it up from there.  This will amount
--		to an input value required when the user enters a value OTHER
--		then "Salary Range" or "Age Range" in the Row Type field.
-- Insert formula result rules;
--	  (*) dedn_amt --> Direct
--	  (*) stop_entry --> Stop
--
-- Find formula id of element's Payroll Table deduction formula;
-- May be able to pass in element's formula name as created earlier,
-- instead if [re]constructing it here.
-- Testing note: formula name should be '<ELE_NAME>_PAYROLL_TABLE'
-- in this case.
--
-- Find table id
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',53);
  SELECT 	user_table_id
  INTO		v_paytab_id
  FROM		pay_user_tables
  WHERE		UPPER(user_table_name) 		= UPPER(p_paytab_name)
  AND		NVL(business_group_id, p_bg_id)	= p_bg_id;
-- Find row code
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',55);
  SELECT	lookup_code
  INTO		v_row_code
  FROM		hr_lookups
  WHERE		UPPER(meaning) 	= UPPER(p_paytab_row_type)
  AND		lookup_type 	= 'US_TABLE_ROW_TYPES';
--
-- Set SCL:
-- Note: Changing "Payroll Table" and "Row Type" columns (ele_info6,7)
--       to hold the actual table name and lookup CODE.
--	 Previously stored the ID and Meaning (09 Feb 1994)
--
--  IF UPPER(p_ele_class_name)	= 'INVOLUNTARY DEDUCTIONS' THEN
-- Populate segments 1,2,3 w/Category, PayTab, PayTab Row.
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',57);
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= p_ele_id
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',57);
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code
    WHERE	element_type_id 		= p_shadow_ele_id
    AND		business_group_id + 0 		= p_bg_id;


If p_ele_proc_type = 'R' Then   /* Not required for NR Elements */

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',57);
    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3		= p_proc_runtype,
		element_information6		= p_paytab_name,
		element_information7		= v_row_code
    WHERE	element_type_id 		= p_inputs_ele_id
    AND		business_group_id + 0 		= p_bg_id;

End if;  /* Not required for NR Elements */

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',59);
  v_calc_rule_formula_id := ins_formula  (
	p_ff_ele_name	=> p_ele_name,
	p_ff_suffix	=> '_PAYROLL_TABLE',
	p_ff_desc	=> 'Payroll Table calculation for deductions.',
	p_ff_bg_id	=> p_bg_id,
	p_amt_rule	=> p_amount_rule,
	p_row_type	=> p_paytab_row_type,
        p_ele_processing_type => p_ele_proc_type );

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',60);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> p_eff_start_date,
		p_effective_end_date 		=> p_eff_end_date,
		p_element_type_id 		=> p_ele_id,
		p_assignment_status_type_id 	=> v_asst_status_type_id,
		p_formula_id 			=> v_calc_rule_formula_id,
		p_processing_rule		=> v_proc_rule);
--
-- Remember: NULL asst_status_type_id means "Standard" processing rule!

  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  --
  -- Creating "Table Column" inpval
  --
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',65);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Table Column';
  v_inpval_uom 		:= 'Character';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= NULL;
-- lkp could be created to validate user_Table_columns based on user_table.
  v_dflt_value		:= p_paytab_col;
-- Should be: v_dflt_value := p_paytab_col; but procedure checks for valid
-- values according to lookup - which is cool, since we'll have validated
-- this client side anyway.  ( ) Update procedure when appropriate.
--
  v_inpval_id 		:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',67);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',70);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Table Column" input value.
--
-- Place logic determining to create or not create additional input value here:
-- 1) If p_paytab_row_type = 'Age Range' or 'Salary Range' then DO NOT create
--	addl inpval;
-- 2) Compare p_paytab_row_type with database item names:
	-- If p_paytab_row_type = dbi.name then DO NOT create addl inpval;
	-- Else create addl inpval where name = PAY_USER_TABLES.USER_ROW_TITLE
--			(and user_table_name = p_paytab_name)
--

  IF p_paytab_row_type NOT IN ('Salary Range', 'Age Range') THEN
  -- Create inpval for row type.
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',75);
  --
  -- Creating "Row Type" inpval
  --
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',65);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= p_paytab_row_type;
  v_inpval_uom 		:= 'Character'; -- Get_Table_Value only accepts chars
  v_gen_dbi		:= 'Y';
  v_lkp_type		:= NULL;
-- lkp could be created to validate user_Table_columns based on user_table.
  v_dflt_value		:= NULL;

  v_inpval_id 		:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',67);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',70);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Row Type" input value.
--
    END IF; -- rowtype = dbi name check.
--
--  END IF; -- Row type = Age or Sal range.
--
--
-- Now insert appropriate formula_result_rules for this element
--

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',75);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'DEDN_AMT',
	p_result_rule_type		=> 'D',
	p_severity_level		=> NULL,
	p_element_type_id		=> NULL);

  IF p_ele_proc_type = 'R' THEN
    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',77);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'STOP_ENTRY',
	p_result_rule_type		=> 'S',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_ele_id);
  END IF;
--
-- Check for Benefits Table amount rule:
--
ELSIF UPPER(p_amount_rule) = 'BT' THEN


/*  Note:
Deductions template generator relies on input value creation
API to create proper "benefits" database items based on input
values created here.  If the API looks for a Benefits
classification, it won't find it - so we need the dbitem
creation mechanism to look for this scenario (ie. Coverage, EE,
and ER Contr input values).

(*) Another API is being provided by UK to create these dbi(create_contr_items)
*/
    -- Find formula id of element's Payroll Table deduction formula;
    -- May be able to pass in element's formula name as created earlier,
    -- instead if [re]constructing it here.
  -- Set SCL:
  --  IF UPPER(p_ele_class_name)	= 'INVOLUNTARY DEDUCTIONS' THEN
  -- Populate segments 1 w/Category
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',81);
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= p_ele_id
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',83);
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= p_shadow_ele_id
    AND		business_group_id + 0 		= p_bg_id;

If p_ele_proc_type = 'R' then   /* Not required for NR Elements  */

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',83);
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= p_inputs_ele_id
    AND		business_group_id + 0 		= p_bg_id;

End if;    /*   Not required for NR Elements   */

--
-- Testing note: formula name should be '<ELE_NAME>_BENEFITS_TABLE'
-- in this case.
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',85);
  v_calc_rule_formula_id := ins_formula  (
	p_ff_ele_name	=> p_ele_name,
	p_ff_suffix	=> '_BENEFITS_TABLE',
	p_ff_desc	=> 'Benefits Table calculation for deductions.',
	p_ff_bg_id	=> p_bg_id,
	p_amt_rule	=> p_amount_rule,
	p_row_type	=> NULL,
        p_ele_processing_type => p_ele_proc_type );

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',87);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> p_eff_start_date,
		p_effective_end_date 		=> p_eff_end_date,
		p_element_type_id 		=> p_ele_id,
		p_assignment_status_type_id 	=> v_asst_status_type_id,
		p_formula_id 			=> v_calc_rule_formula_id,
		p_processing_rule		=> v_proc_rule);
--
-- Remember: NULL asst_status_type_id means "Standard" processing rule!

  -- REQUIRED FOR EACH INPUT VALUE CREATED IN THIS MANNER, TO (HERE).
  --
  -- Creating "Coverage" inpval
  --
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',90);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Coverage';
  v_inpval_uom 		:= 'Character';
  v_gen_dbi		:= 'Y';
  v_lkp_type		:= 'US_BENEFIT_COVERAGE';
  v_dflt_value 		:= 'EMP ONLY';
  v_val_formula_id	:= NULL;  -- ??? By a formula to do some special sql?
  v_inpval_id 		:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'Y',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',95);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'Y',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',97);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Coverage" input value.
--
--
-- Creating "ER Contr" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',100);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'ER Contr';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'Y';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  v_val_formula_id	:= NULL;
  v_inpval_id 		:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',101);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',102);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "ER Contr" input value.
--
--
-- Creating "EE Contr" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',103);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'EE Contr';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'Y';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  v_val_formula_id	:= NULL;
  v_er_contr_inpval_id 	:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',105);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 	=> v_er_contr_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',107);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 	=> v_er_contr_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "EE Contr" input value.
--
--
-- Now insert appropriate formula_result_rules for this element
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',109);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'DEDN_AMT',
	p_result_rule_type		=> 'D',
	p_severity_level		=> NULL,
	p_element_type_id		=> NULL);

  IF p_ele_proc_type = 'R' THEN
    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',111);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'STOP_ENTRY',
	p_result_rule_type		=> 'S',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_ele_id);
  END IF;
--
-- In order to create indirect result feeding Employer Charge element for
-- this benefit, we must find the input_value_id for the pay_value of the
-- employer charge element.
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',70);
v_payval_name := hr_input_values.get_pay_value_name(g_template_leg_code);

hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',80);
-- We need inpval_id of pay value for this element:
SELECT 	IV.input_value_id
INTO	v_er_payval_id
FROM 	pay_input_values_f IV
WHERE	IV.element_type_id = p_er_charge_eletype_id
AND	IV.name = v_payval_name;
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',115);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id			=> v_er_payval_id,
	p_result_name			=> 'BENE_ER_CONTR',
	p_result_rule_type		=> 'I',
	p_severity_level			=> NULL,
	p_element_type_id		=> p_er_charge_eletype_id);
-- (*) ATTN: ins_form_res_rule API has been updated to accept a new param
-- for element type id.
-- I've taken a copy of benchmark package and called it pay_formula_results
-- since benchmark is unsupported by the UK.
--
ELSE
--
-- Default to Flat Amount processing of deduction.
-- (ie. IF UPPER(p_amount_rule) = 'FA' THEN...)
--
-- First, get formula_id for appropriate formula (created earlier this pkg);
-- Insert status proc rule;
-- Insert input vals ("Amount");
-- Insert formula result rules;
--	  (*) dedn_amt --> Direct
--	  (*) stop_entry --> Stop
--
-- Set DDF Segment values:
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',81);
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype,
		element_information9		= p_mix_category,
		benefit_classification_id	= p_ben_class_id
    WHERE	element_type_id 		= p_ele_id
    AND		business_group_id + 0 		= p_bg_id;

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',81);
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= p_shadow_ele_id
    AND		business_group_id + 0 		= p_bg_id;


If p_ele_proc_type = 'R' then /* Not required for NR Elements */

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',81);
    UPDATE 	pay_element_types_f
    SET		element_information_category	= g_ele_info_cat,
		element_information1 		= p_ele_cat,
		element_information2		= p_partial_dedn,
		element_information3 		= p_proc_runtype
    WHERE	element_type_id 		= p_inputs_ele_id
    AND		business_group_id + 0 		= p_bg_id;

End if;  /*  Not required for NR Elements  */

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',15);
  v_calc_rule_formula_id := ins_formula  (
	p_ff_ele_name	=> p_ele_name,
	p_ff_suffix	=> '_FLAT_AMOUNT',
	p_ff_desc	=> 'Flat Amount calculation for deductions.',
	p_ff_bg_id	=> p_bg_id,
	p_amt_rule	=> NULL,
	p_row_type	=> NULL,
        p_ele_processing_type => p_ele_proc_type );

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',119);
  v_stat_proc_rule_id :=
  pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> p_eff_start_date,
		p_effective_end_date 		=> p_eff_end_date,
		p_element_type_id 		=> p_ele_id,
		p_assignment_status_type_id 	=> v_asst_status_type_id,
		p_formula_id 			=> v_calc_rule_formula_id,
		p_processing_rule		=> v_proc_rule);
--
-- Flat "Amount" inpval.
--
hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',40);
g_inpval_disp_seq := g_inpval_disp_seq + 1;
v_inpval_name 	:= 'Amount';
v_inpval_uom 	:= 'Money';
v_gen_dbi	:= 'Y';
v_lkp_type	:= NULL;
v_dflt_value	:= NULL;

v_inpval_id 	:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => NULL,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

    hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',50);
    hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

    hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',60);
    hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
-- Done inserting "Amount" input value.
--
-- Now insert appropriate formula_result_rules for this element
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',121);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'DEDN_AMT',
	p_result_rule_type		=> 'D',
	p_severity_level		=> NULL,
	p_element_type_id		=> NULL);

  IF p_ele_proc_type = 'R' THEN
    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',123);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> NULL,
	p_result_name			=> 'STOP_ENTRY',
	p_result_rule_type		=> 'S',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_ele_id);
  END IF;

END IF; -- Amount rule checks

-- ER Component Checks
IF p_ele_er_match = 'Y' THEN

--  create input values for:
--  (*) "Deduction Actually Taken"
--  create formula result rule for:
--  (*) DEDN_AMT --> Deduction Actually Taken --> <ELE_NAME>_ER.
--

--
hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',983);
g_er_inpval_disp_seq 	:= g_er_inpval_disp_seq + 1;
v_inpval_name 		:= 'Deduction Actually Taken';
v_inpval_uom 		:= 'Money';
v_gen_dbi		:= 'N';
v_lkp_type		:= NULL;
v_dflt_value		:= NULL;

v_actdedn_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> v_er_charge_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                                p_uom_code              => NULL,
				p_mandatory_flag 	=> 'X',
				p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => v_val_formula_id,
                                p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_er_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                        p_effective_start_date	=> p_eff_start_date,
                                p_effective_end_date   	=> p_eff_end_date);

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',984);
hr_input_values.chk_input_value(
		        p_element_type_id 		=> v_er_charge_eletype_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_actdedn_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'X',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',985);
hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> v_er_charge_eletype_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_actdedn_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- Done inserting "Deduction Actually Taken" input value.

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',986);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> v_actdedn_inpval_id,
	p_result_name			=> 'DEDN_AMT',
	p_result_rule_type		=> 'I',
	p_severity_level		=> NULL,
	p_element_type_id		=> v_er_charge_eletype_id);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',987);


END IF; -- ER matching component

IF p_ele_ee_bond = 'Y' THEN
-- create input values for:
--  (*) "Purchase Price"
--  (*) "Towards Purchase" (Feeds "Towards Bond Purchase" balance, get id)
--  03 Dec 1993: No longer create "Towards Purchase" input value; instead
--  we have a new element type "Bond Purchase", fed by new indirect result
--  from formula,
--  which in turn feeds "Towards Bond Purchase" balance.
--  Remember to delete appropriately from do_deletions procedure.
--  Create formula result rule for:
--  (*) to_purch_bal --> Update Recurring to <ELE_NAME>.TOWARDS_PURCHASE inpval
--  (*) bond_refund  --> Indirect to <ELE_NAME>_REFUND.AMOUNT (directpymt)
--
-- Creating "Purchase Price" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',125);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Purchase Price';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N'; -- Can be 'N', not needed by any other formulae
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  v_inpval_id 		:=	pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'Y',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',127);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',129);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Purchase Price" input value.
--
--
-- Creating "Toward Purchase" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',125);
  g_shadow_inpval_disp_seq 	:= g_shadow_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Toward Purchase';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N'; -- Can be 'N', not needed by any other formulae
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  g_topurch_inpval_id	:=	pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_shadow_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
			        p_display_sequence 	=> g_shadow_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',127);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_shadow_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> g_topurch_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',129);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_shadow_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> g_topurch_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Toward Purchase" input value.
--
-- Formula results
-- Find id for <ELE_NAME>_REFUND pay value. Non-Payroll Payment,
-- ie. direct pay(?); Used on Final Pay.
/* Now it's passed in since we had to create it for non-payroll element.
PLEASE NOTE: The situation was a bit reversed in another account where
NON_PAYMENTS_FLAG = 'N' for class = 'Non-Payroll Payments'; but non-pay-flag
was 'Y' for 'Employer Liab' class!  So i hope it stays one way or the other.
*/

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',140);
  SELECT	inp.input_value_id
  INTO 		v_eerefund_payval_id
  FROM 	pay_input_values_f inp,
		hr_lookups hl
  WHERE    	inp.element_type_id	= p_eerefund_eletype_id
  AND   	inp.name 		= hl.meaning
  AND   	hl.lookup_code 		= 'PAY VALUE'
  AND   	hl.lookup_type 		= 'NAME_TRANSLATIONS';

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',150);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> v_eerefund_payval_id,
	p_result_name			=> 'BOND_REFUND',
	p_result_rule_type		=> 'I',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_eerefund_eletype_id);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',150);
  v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> g_topurch_inpval_id,
	p_result_name			=> 'TO_PURCH_BAL',
	p_result_rule_type		=> 'I',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_shadow_ele_id);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',160);

END IF; -- EE Bond
--
-- Start Rule checks.
--
IF p_ele_start_rule = 'ET' THEN
-- create input values for:
--  (*) "Threshold Balance"
--  (*) "Threshold Bal Dim"
--  (*) "Threshold Amount"
--
-- Creating "Threshold Balance" and "Threshold Dimension" inpval
--
-- Creating "Threshold Amount" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',230);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Threshold Amount';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  v_inpval_id 		:=	pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',240);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',250);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Threshold Amount" input value.
--
ELSIF p_ele_start_rule = 'CHAINED' THEN
--  create input values for:
--  (*) "Chained To"
--
-- Creating "Chained To" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',260);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Chained To';
  v_inpval_uom 		:= 'Character';
  v_gen_dbi		:= 'N';
--  v_lkp_type		:= 'US_VALID_ELE_TYPES'; User can define.
  v_dflt_value 		:= NULL;
  v_inpval_id 		:=	pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',270);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',280);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Chained To" input value.
--
END IF; -- Start Rule checks

--
-- Stop Rule checks:

IF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN

--  create input values for:
--  (*) "Total Owed"
--  (*) "Accrued" (Feeds "Accrued" balance)
--  (*) "Towards Owed" (y/n val)
--  create formula result rule for:
--  (*) to_total_owed --> Upd Recurring to <ELE_NAME>.ACCRUED.
--
-- Creating "Total Owed" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',290);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Total Owed';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  v_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',300);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',310);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Total Owed" input value.
--
--
-- Creating "Accrued" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',320);
  g_shadow_inpval_disp_seq 	:= g_shadow_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Accrued';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  g_to_tot_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_shadow_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
	                      	p_formula_id            => NULL,
        	              	p_hot_default_flag      => 'N',
			p_display_sequence 	=> g_shadow_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',330);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_shadow_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> g_to_tot_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',340);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_shadow_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> g_to_tot_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Accrued" input value.
--
--
-- Creating "Towards Owed" inpval
--
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',350);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Towards Owed';
  v_inpval_uom 		:= 'Character';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= 'YES_NO';
  v_dflt_value 		:= 'Y';
  v_inpval_id :=pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',360);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',370);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Towards Owed" input value.
--
--  IF p_ele_proc_type = 'R' THEN
      hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',380);
--
-- Note this indirect result feeds "Accrued" inpval on
-- "<ELE_NAME> Special Features" ele.
--
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> g_to_tot_inpval_id,
	p_result_name			=> 'TO_TOTAL_OWED',
	p_result_rule_type		=> 'I',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_shadow_ele_id);

--  END IF;

END IF; -- Stop Rule checks



-- Arrearage checks.

IF p_arrearage = 'Y' THEN

--  create input values for:
--  ( ) "Clear Arrears" (on base ele)
--  (*) "Arrears Contr" (on Special Features ele Feeds "Arrears" balance)
--  (*) "Not Taken" (on Special Features ele)
--  create formula result rule for:
--  (*) to_arrears --> Indirect to <ELE_NAME>.ARREARS_CONTR
--  (*) not_taken --> Indirect to <ELE_NAME>.NOT_TAKEN

-- Creating "Clear Arrears" inpval

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',381);
  g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Clear Arrears';
  v_inpval_uom 		:= 'Character';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= 'YES_NO';
  v_dflt_value 		:= 'N';
  v_inpval_id :=pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',382);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',383);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);

-- Done inserting "Clear Arrears" input value.
    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',450);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> v_inpval_id,
	p_result_name			=> 'SET_CLEAR',
	p_result_rule_type		=> 'U',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_ele_id);

END IF;

-- Creating "Arrears Contr" inpval

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',390);
  g_shadow_inpval_disp_seq 	:= g_shadow_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Arrears Contr';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  g_arrears_contr_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_shadow_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
			        p_display_sequence 	=> g_shadow_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',400);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_shadow_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 	        => g_arrears_contr_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',410);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_shadow_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 	        => g_arrears_contr_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- (HERE) Done inserting "Arrears Contr" input value.
--
-- Can create FRR for arrears since form (PAYSUDDE) validates that
-- Arrearage = 'N' for Nonrecurring deductions - but just in case something
-- slips thru, we'll check proc_type again.
--
  IF p_ele_proc_type = 'R' THEN
    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',450);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> g_arrears_contr_inpval_id,
	p_result_name			=> 'TO_ARREARS',
	p_result_rule_type		=> 'I',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_shadow_ele_id);

  END IF;

-- IF p_partial_dedn = 'Y' THEN
-- Actually, we want Not Taken inpval whether partial = Y or N, ie. if it's
-- No and dedn cannot be taken, then we need to see that on Dedns Not Taken
-- report.
-- Creating "Not Taken" inpval

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',420);
  g_shadow_inpval_disp_seq 	:= g_shadow_inpval_disp_seq + 1;
  v_inpval_name 	:= 'Not Taken';
  v_inpval_uom 		:= 'Money';
  v_gen_dbi		:= 'N';
  v_lkp_type		:= NULL;
  v_dflt_value 		:= NULL;
  g_notaken_inpval_id 	:= pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_shadow_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_val_formula_id,
                            	p_hot_default_flag      => 'N',
			        p_display_sequence 	=> g_shadow_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start_date,
                            	p_effective_end_date   	=> p_eff_end_date);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',430);
  hr_input_values.chk_input_value(
			p_element_type_id 		=> p_shadow_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> g_notaken_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
			p_default_value 		=> v_dflt_value,
			p_lookup_type 			=> v_lkp_type,
			p_formula_id 			=> v_val_formula_id,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',440);
  hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_shadow_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> g_notaken_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);

-- (HERE) Done inserting "Not Taken" input value.

--  IF p_ele_proc_type = 'R' THEN
-- Recurring/Nonrecurring has nothing to do with Partial Dedns, if an amount
-- is not taken - then it is NOT TAKEN !

    hr_utility.set_location('hr_user_init_dedn.ins_dedn_formula_processing',460);
    v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start_date,
	p_effective_end_date         	=> p_eff_end_date,
	p_status_processing_rule_id	=> v_stat_proc_rule_id,
	p_input_value_id		=> g_notaken_inpval_id,
	p_result_name			=> 'NOT_TAKEN',
	p_result_rule_type		=> 'I',
	p_severity_level		=> NULL,
	p_element_type_id		=> p_shadow_ele_id);

-- END IF; -- Not Taken

/* Involuntary Deductions do not have After Tax Component

-- Begin Insert Aftertax Passthrough Input Value
--  create input values for:
--  (*) "'Take OverLimit AT'" - -- should calculated deductions over the pretax limit be
--						taken as aftertax deductions?
--

--
hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',993);
g_inpval_disp_seq 	:= g_inpval_disp_seq + 1;
v_inpval_name 		:= 'Take OverLimit AT';
v_inpval_uom 		:= 'Character';
v_gen_dbi		:= 'N';
v_lkp_type		:= 'YES_NO';
v_dflt_value		:= 'N';

v_passthru_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                                p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                                p_default_value         => v_dflt_value,
                                p_min_value             => NULL,
                                p_max_value             => NULL,
                                p_warning_or_error      => NULL,
                                p_lookup_type           => v_lkp_type,
                                p_formula_id            => v_val_formula_id,
                                p_hot_default_flag      => 'N',
				p_display_sequence 	=> g_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                        p_effective_start_date	=> p_eff_start_date,
                                p_effective_end_date   	=> p_eff_end_date);

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',994);
hr_input_values.chk_input_value(
		        p_element_type_id 		=> p_ele_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start_date,
                        p_val_end_date 			=> p_eff_end_date,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> v_passthru_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> p_ele_proc_type,
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',995);
hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start_date,
			p_val_end_date 			=> p_eff_end_date,
			p_element_type_id 		=> p_ele_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> v_passthru_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
--
-- Done inserting Insert Aftertax Passthrough Input Value

*/


END ins_dedn_formula_processing;

---------------------------- ins_dedn_input_vals ------------------------------
PROCEDURE ins_dedn_input_vals (
		p_ele_type_id		in number,
		p_ele_name	 	in varchar2,
		p_shadow_ele_type_id	in number,
		p_shadow_ele_name	in varchar2,
		p_inputs_ele_type_id	in number,
		p_inputs_ele_name	in varchar2,
		p_eff_start		in date,
		p_eff_end		in date,
		p_primary_class_id	in number,
		p_ele_class		in varchar2,
		p_ele_cat		in varchar2,
		p_ele_proc_type		in varchar2,
		p_bg_id			in number,
		p_bg_name		in varchar2,
		p_amt_rule		in varchar2) IS
--
-- local vars
--
v_inpval_id		NUMBER(9);
v_inpval_name		VARCHAR2(30);
v_inpval_uom		VARCHAR2(80);
v_gen_dbi		VARCHAR2(1);
v_dflt_value		VARCHAR2(60);
v_lkp_type		VARCHAR2(30);
v_formula_id		NUMBER(9);
v_status_proc_id	NUMBER(9);
v_resrule_id		NUMBER(9);
--
-- More input values may be necessary, so make direct calls to CORE_API
-- packaged procedures to:
-- 1) Insert input values according to Class and Category
--    (Done in ins_dedn_formula_processing)
-- 2) Insert input values required for ALL user-initiated earnings elements
--    (ie. batch entry fields, override fields)

-- Add input values (in order) "Replacement Amount", "Additional Amount"
-- Only create Replacement Amount if calc rule <> Flat Amount.
--
BEGIN


If p_ele_proc_type = 'R'  then  /* Not required for NR Elements */

   --
   -- Create inpvals for "Special Inputs"
   --
   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',40);
   g_inputs_inpval_disp_seq	:= 1;
   v_inpval_name 		:= 'Replace Amt';
   v_inpval_uom 		:= 'Money';
   v_gen_dbi		:= 'N';
   v_lkp_type		:= NULL;
   v_dflt_value		:= NULL;

   gi_repl_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_inputs_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_formula_id,
                            	p_hot_default_flag      => 'N',
			        p_display_sequence 	=> g_inputs_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start,
                            	p_effective_end_date   	=> p_eff_end);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',50);
   hr_input_values.chk_input_value(
		        p_element_type_id 		=> p_inputs_ele_type_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start,
                        p_val_end_date 			=> p_eff_end,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> gi_repl_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',60);
   hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start,
			p_val_end_date 			=> p_eff_end,
		        p_element_type_id 		=> p_inputs_ele_type_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> gi_repl_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
   --
   -- Done inserting "Replacement Amt" input value.
   --
   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',70);
   g_inputs_inpval_disp_seq 	:= g_inputs_inpval_disp_seq + 1;
   v_inpval_name 		:= 'Addl Amt';
   v_inpval_uom 		:= 'Money';
   v_gen_dbi		:= 'N';
   v_lkp_type		:= NULL;
   v_dflt_value		:= NULL;

   gi_addl_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_inputs_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_formula_id,
                            	p_hot_default_flag      => 'N',
			        p_display_sequence 	=> g_inputs_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start,
                            	p_effective_end_date   	=> p_eff_end);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',75);
   hr_input_values.chk_input_value(
		        p_element_type_id 		=> p_inputs_ele_type_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start,
                        p_val_end_date 			=> p_eff_end,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> gi_addl_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',80);
   hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start,
			p_val_end_date 			=> p_eff_end,
		        p_element_type_id 		=> p_inputs_ele_type_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> gi_addl_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);


   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',81);
g_inputs_inpval_disp_seq	:= g_inputs_inpval_disp_seq + 1;
v_inpval_name 		:= 'Adjust Arrears';
v_inpval_uom 		:= 'Money';
v_gen_dbi		:= 'N';
v_lkp_type		:= NULL;
v_dflt_value		:= NULL;

g_adj_arrears_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_inputs_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_formula_id,
                            	p_hot_default_flag      => 'N',
			        p_display_sequence 	=> g_inputs_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start,
                            	p_effective_end_date   	=> p_eff_end);

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',50);
hr_input_values.chk_input_value(
		        p_element_type_id 		=> p_inputs_ele_type_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start,
                        p_val_end_date 			=> p_eff_end,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 	        => g_adj_arrears_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',60);
hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start,
			p_val_end_date 			=> p_eff_end,
		        p_element_type_id 		=> p_inputs_ele_type_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 	        => g_adj_arrears_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);

End if;   /*  Not required for NR Elements  */
--
-- Done inserting "Adjust Arrears" input value.
--
-- Create inpvals for "Special Features"
--

If p_ele_proc_type = 'R'  then  /* Not required for NR Elements */

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',40);
   g_shadow_inpval_disp_seq 	:= g_shadow_inpval_disp_seq + 1;
   v_inpval_name 		:= 'Replacement Amt';
   v_inpval_uom 		:= 'Money';
   v_gen_dbi		:= 'N';
   v_lkp_type		:= NULL;
   v_dflt_value		:= NULL;

   g_repl_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_shadow_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_formula_id,
                            	p_hot_default_flag      => 'N',
			p_display_sequence 	=> g_shadow_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start,
                            	p_effective_end_date   	=> p_eff_end);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',50);
   hr_input_values.chk_input_value(
		p_element_type_id 		=> p_shadow_ele_type_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start,
                        p_val_end_date 			=> p_eff_end,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> g_repl_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',60);
   hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start,
			p_val_end_date 			=> p_eff_end,
		p_element_type_id 		=> p_shadow_ele_type_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> g_repl_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
   --
   -- Done inserting "Replacement Amt" input value.
   --
   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',70);
   g_shadow_inpval_disp_seq 	:= g_shadow_inpval_disp_seq + 1;
   v_inpval_name 		:= 'Additional Amt';
   v_inpval_uom 		:= 'Money';
   v_gen_dbi		:= 'N';
   v_lkp_type		:= NULL;
   v_dflt_value		:= NULL;

   g_addl_inpval_id := pay_db_pay_setup.create_input_value (
				p_element_name 		=> p_shadow_ele_name,
				p_name 			=> v_inpval_name,
				p_uom 			=> v_inpval_uom,
                            	p_uom_code              => NULL,
				p_mandatory_flag 	=> 'N',
				p_generate_db_item_flag => v_gen_dbi,
                            	p_default_value         => v_dflt_value,
                            	p_min_value             => NULL,
                            	p_max_value             => NULL,
                            	p_warning_or_error      => NULL,
                            	p_lookup_type           => v_lkp_type,
                            	p_formula_id            => v_formula_id,
                            	p_hot_default_flag      => 'N',
			p_display_sequence 	=> g_shadow_inpval_disp_seq,
				p_business_group_name 	=> p_bg_name,
	                      	p_effective_start_date	=> p_eff_start,
                            	p_effective_end_date   	=> p_eff_end);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',75);
   hr_input_values.chk_input_value(
		p_element_type_id 		=> p_shadow_ele_type_id,
			p_legislation_code 		=> g_template_leg_code,
                        p_val_start_date 		=> p_eff_start,
                        p_val_end_date 			=> p_eff_end,
			p_insert_update_flag		=> 'UPDATE',
			p_input_value_id 		=> g_addl_inpval_id,
			p_rowid 			=> NULL,
			p_recurring_flag 		=> 'N',
			p_mandatory_flag 		=> 'N',
			p_hot_default_flag 		=> 'N',
			p_standard_link_flag 		=> 'N',
			p_classification_type 		=> 'N',
			p_name 				=> v_inpval_name,
			p_uom 				=> v_inpval_uom,
			p_min_value 			=> NULL,
			p_max_value 			=> NULL,
      			p_default_value 		=> NULL,
			p_lookup_type 			=> v_dflt_value,
			p_formula_id 			=> NULL,
			p_generate_db_items_flag 	=> v_gen_dbi,
			p_warning_or_error 		=> NULL);

   hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',80);
   hr_input_values.ins_3p_input_values(
			p_val_start_date 		=> p_eff_start,
			p_val_end_date 			=> p_eff_end,
		p_element_type_id 		=> p_shadow_ele_type_id,
			p_primary_classification_id 	=> p_primary_class_id,
			p_input_value_id 		=> g_addl_inpval_id,
			p_default_value 		=> v_dflt_value,
			p_max_value 			=> NULL,
			p_min_value 			=> NULL,
			p_warning_or_error_flag 	=> NULL,
			p_input_value_name 		=> v_inpval_name,
			p_db_items_flag 		=> v_gen_dbi,
			p_costable_type			=> NULL,
			p_hot_default_flag 		=> 'N',
			p_business_group_id 		=> p_bg_id,
			p_legislation_code 		=> NULL,
			p_startup_mode 			=> NULL);
   --
   -- Done inserting "Addl Amt" input value.

end if;  /* Not required for NR Elements */


-- Generic input values for [all] deductions.
--
-- *** Also need to create FORMULA RESULT RULES to "zero" out these values.
--
-- Find "Standard" status processing rule id for this element.
-- We know this must be the only one right now:
--
--

hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',85);
SELECT	status_processing_rule_id
INTO	v_status_proc_id
FROM	pay_status_processing_rules_f
WHERE	assignment_status_type_id IS NULL
AND	element_type_id	= p_ele_type_id;

--
-- Additional and Replacement amount input values only need UPDREE FRR if
-- they are recurring!  Otherwise payroll run bombs w/ ASSERTION ERROR
-- when trying to "update recurring" on a nonrecurring element (i think
-- that's the prob).
--
IF p_ele_proc_type = 'R' THEN
  hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',90);
  v_resrule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start,
	p_effective_end_date         	=> p_eff_end,
	p_status_processing_rule_id	=> v_status_proc_id,
	p_input_value_id			=> g_repl_inpval_id,
	p_result_name			=> 'CLEAR_REPL_AMT',
	p_result_rule_type		=> 'I',
	p_severity_level			=> NULL,
	p_element_type_id		=> p_shadow_ele_type_id);

  hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',95);
  v_resrule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start,
	p_effective_end_date         	=> p_eff_end,
	p_status_processing_rule_id	=> v_status_proc_id,
	p_input_value_id			=> g_addl_inpval_id,
	p_result_name			=> 'CLEAR_ADDL_AMT',
	p_result_rule_type		=> 'I',
	p_severity_level			=> NULL,
	p_element_type_id		=> p_shadow_ele_type_id);

END IF;

  hr_utility.set_location('hr_user_init_dedn.ins_uie_inp_values',100);
  v_resrule_id := pay_formula_results.ins_form_res_rule (
  	p_business_group_id		=> p_bg_id,
	p_legislation_code		=> NULL,
  	p_legislation_subgroup		=> g_template_leg_subgroup,
	p_effective_start_date		=> p_eff_start,
	p_effective_end_date         	=> p_eff_end,
	p_status_processing_rule_id	=> v_status_proc_id,
	p_input_value_id			=> NULL,
	p_result_name			=> 'MESG',
	p_result_rule_type		=> 'M',
	p_severity_level			=> 'W',
	p_element_type_id		=> NULL);

END ins_dedn_input_vals;

PROCEDURE do_defined_balances (	p_bal_name	IN VARCHAR2,
				p_bg_name	IN VARCHAR2,
				p_no_payments	IN BOOLEAN default FALSE) IS

-- local vars

TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  suffixes	text_table;
  dim_id	number(9);
  dim_name	varchar2(80);
  num_suffixes number;

  already_exists number;
  v_business_group_id number;

BEGIN

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

/* *** WWBug 133133 start *** */
/*
     Add suffixes to create defined bals for GRE_YTD, GRE_RUN, GRE_ITD.
     Number of defined balance suffixes increases to 22
*/
suffixes(19) := '_GRE_RUN';
suffixes(20) := '_GRE_YTD';
suffixes(21) := '_GRE_ITD';

suffixes(22) := '_PAYMENTS';
suffixes(23) := '_ASG_PAYMENTS';

num_suffixes := 23;

  select business_group_id
  into   v_business_group_id
  from   per_business_groups
  where  upper(name) = upper(p_bg_name);

/* *** WWBug 133133 finish *** */

    for i in 1..num_suffixes loop

      select dimension_name, balance_dimension_id
      into dim_name, dim_id
      from pay_balance_dimensions
      where database_item_suffix = suffixes(i)
      and legislation_code = g_template_leg_code
      and business_group_id is null;

/* the following select statement has been commented. Earlier it was not
   checking whether record already exists in pay_defined_balance or not. Now
   it is checking it and for a particular business_group_id.
*/

      SELECT  count(0)
      INTO  already_exists
      FROM  pay_defined_balances db,
            pay_balance_types bt
      WHERE  db.balance_type_id = bt.balance_type_id
      AND  bt.balance_name = p_bal_name
      AND  db.balance_dimension_id = dim_id
      AND  bt.business_group_id = v_business_group_id;


      if (already_exists = 0) then


      IF p_no_payments = TRUE and
         (suffixes(i) = '_PAYMENTS' or suffixes(i) = '_ASG_PAYMENTS') THEN

        NULL;

      ELSIF suffixes(i) = '_ASG_GRE_RUN' THEN

        pay_db_pay_setup.create_defined_balance(
                p_balance_name          => p_bal_name,
                p_balance_dimension     => dim_name,
                p_business_group_name   => p_bg_name,
                p_legislation_code      => NULL,
                p_save_run_bal          => 'Y');

      ELSE

        pay_db_pay_setup.create_defined_balance(
                p_balance_name          => p_bal_name,
                p_balance_dimension     => dim_name,
                p_business_group_name   => p_bg_name,
                p_legislation_code      => NULL);

      END IF;

    end if;

    end loop;

END do_defined_balances;

----------------------- ins_deduction_template Main ------------------------
--
-- Main Procedure

BEGIN

--
-- Set session date
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',10);
pay_db_pay_setup.set_session_date(nvl(p_ele_eff_start_date, sysdate));
g_eff_start_date	:= nvl(p_ele_eff_start_date, sysdate);
g_eff_end_date		:= nvl(p_ele_eff_end_date, c_end_of_time);


-- Set "globals": v_bg_name
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',20);
select	name
into	v_bg_name
from 	per_business_groups
where	business_group_id = p_bg_id;

--------------------- Create Balances Types and Defined Balances --------------
--
-- Create associated balances for deductions.
--
-- "Primary" Balance:
--
/* Call pay_balance_types_pkg.chk_balance_type twice in order to check that
   the "Primary Balance" is ok to generate:
 procedure chk_balance_type
 (
  p_row_id                       varchar2,
  p_business_group_id            number,
  p_legislation_code             varchar2,
  p_balance_name                 varchar2,
  p_reporting_name               varchar2,
  p_assignment_remuneration_flag varchar2
 ) is
*/

hr_utility.set_location('pyusuidt',217);
-- Check element name, ie. primary balance name, is unique to
-- balances within this BG.
pay_balance_types_pkg.chk_balance_type(
			p_row_id		=> NULL,
  			p_business_group_id	=> p_bg_id,
  			p_legislation_code	=> NULL,
  			p_balance_name          => p_ele_name,
  			p_reporting_name        => p_ele_name,
  			p_assignment_remuneration_flag => 'N');

hr_utility.set_location('pyusuidt',317);
-- Check element name, ie. primary balance name, is unique to
-- balances provided as startup data.
pay_balance_types_pkg.chk_balance_type(
			p_row_id		=> NULL,
  			p_business_group_id	=> NULL,
  			p_legislation_code	=> 'US',
  			p_balance_name          => p_ele_name,
  			p_reporting_name        => p_ele_name,
  			p_assignment_remuneration_flag => 'N');

hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',25);

-- Emp Balance for enhancement Bug 3311781
if upper(p_ele_classification) = 'VOLUNTARY DEDUCTIONS' then
   l_balance_category := 'Voluntary Deductions';
else
   l_balance_category := 'After-Tax Deductions';
end if;

v_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> p_ele_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> p_ele_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

do_defined_balances(	p_bal_name 	=> p_ele_name,
			p_bg_name	=> v_bg_name);

--
-- Other balances based on certain attributes:
--

If p_ele_processing_type = 'R' then /* Not required for NR Elements */

   v_addl_amt_bal_name := SUBSTR(p_ele_name, 1, 67)||' Additional';
   --v_bal_rpt_name	    := SUBSTR(p_ele_name, 1, 17)||' Additional';
   hr_utility.set_location('pyusuidt',119);
   v_addl_amt_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_addl_amt_bal_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_addl_amt_bal_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

   hr_utility.set_location('pyusuidt',127);
   pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_addl_amt_bal_name,
                        p_balance_dimension 	=> 'Assignment within Government Reporting Entity Inception to Date',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

   v_repl_amt_bal_name := SUBSTR(p_ele_name, 1, 67)||' Replacement';
   --v_bal_rpt_name    := SUBSTR(p_ele_name, 1, 17)||' Replacement';
   hr_utility.set_location('pyusuidt',119);
   v_repl_amt_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_repl_amt_bal_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_repl_amt_bal_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

   hr_utility.set_location('pyusuidt',129);
   pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_repl_amt_bal_name,
                        p_balance_dimension 	=> 'Assignment within Government Reporting Entity Inception to Date',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

End if; /* Not required for NR Elements */

v_balance_name := SUBSTR(p_ele_name, 1, 67)||' Not Taken';
--v_bal_rpt_name := SUBSTR(p_ele_name, 1, 17)||' Not Taken';
hr_utility.set_location('pyusuidt',130);
v_notaken_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

hr_utility.set_location('pyusuidt',131);
pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
  			p_balance_dimension 	=> 'Person Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension 	=> 'Person within Government Reporting Entity Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

hr_utility.set_location('pyusuidt',131);
pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension 	=> 'Assignment-Level Current Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

  pay_db_pay_setup.create_defined_balance (
         p_balance_name         => v_balance_name,
         p_balance_dimension    => 'Assignment within Government Reporting Entity Run',
         p_business_group_name 	=> v_bg_name,
         p_legislation_code     => NULL,
         p_save_run_bal         => 'Y');


If p_ele_processing_type = 'R' then /* Not required for NR Elements */

  v_balance_name := substr(p_ele_name, 1, 55)||' Toward Bond Purchase';
  --v_bal_rpt_name := substr(p_ele_name, 1, 13)||' To Bond Purch';
  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',39);
  v_eepurch_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',41);
  pay_db_pay_setup.create_defined_balance (
    p_balance_name 		=> v_balance_name,
    p_balance_dimension	        => 'Assignment Inception to Date',
    p_business_group_name 	=> v_bg_name,
    p_legislation_code 		=> NULL);

  pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension 	=> 'Assignment within Government Reporting Entity Inception to Date',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',43);
  v_balance_name := substr(p_ele_name, 1, 71)||' Accrued';
  --v_bal_rpt_name := substr(p_ele_name, 1, 21)||' Accrued';
  v_totowed_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',45);
  pay_db_pay_setup.create_defined_balance (
      p_balance_name        => v_balance_name,
      p_balance_dimension   => 'Assignment Inception to Date',
      p_business_group_name => v_bg_name,
      p_legislation_code    => NULL);

  pay_db_pay_setup.create_defined_balance (
      p_balance_name      => v_balance_name,
      p_balance_dimension => 'Assignment within Government Reporting Entity Inception to Date',
      p_business_group_name  => v_bg_name,
      p_legislation_code     => NULL);

  pay_db_pay_setup.create_defined_balance(
      p_balance_name         => v_balance_name,
      p_balance_dimension    => 'Assignment within Government Reporting Entity Run',
      p_business_group_name  => v_bg_name,
      p_legislation_code     => NULL,
      p_save_run_bal         => 'Y');
  --
  --  Adding _ENTRY_ITD Balance Dimension For Bug# 6270794
  --
  pay_db_pay_setup.create_defined_balance (
      p_balance_name        =>  v_balance_name,
      p_balance_dimension   => 'US Element Entry Inception to Date',
      p_business_group_name =>  v_bg_name,
      p_legislation_code    =>  NULL);

  v_balance_name := substr(p_ele_name, 1, 71)||' Arrears';
  --v_bal_rpt_name := substr(p_ele_name, 1, 21)||' Arrears';
  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',47);
  v_arrears_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',49);
  pay_db_pay_setup.create_defined_balance (
    p_balance_name 	=> v_balance_name,
    p_balance_dimension	=> 'Assignment Inception to Date',
    p_business_group_name => v_bg_name,
    p_legislation_code 	  => NULL);

  pay_db_pay_setup.create_defined_balance (
   p_balance_name 	=> v_balance_name,
   p_balance_dimension 	=> 'Assignment within Government Reporting Entity Inception to Date',
   p_business_group_name => v_bg_name,
   p_legislation_code 	=> NULL);

-- WWbug333133 - create _GRE_ITD dimension for arrears

  pay_db_pay_setup.create_defined_balance (
    p_balance_name 		=> v_balance_name,
    p_balance_dimension	        => 'Government Reporting Entity Inception to Date',
    p_business_group_name 	=> v_bg_name,
    p_legislation_code 		=> NULL);

--
  pay_db_pay_setup.create_defined_balance(
         p_balance_name         => v_balance_name,
         p_balance_dimension    => 'Assignment within Government Reporting Entity Run',
         p_business_group_name  => v_bg_name,
         p_legislation_code     => NULL,
         p_save_run_bal         => 'Y');


end if; /* Not required for NR Elements */

-- Begin Create Eligible Comp Balance
 v_balance_name := SUBSTR(p_ele_name, 1, 66)||' Eligible Comp';
 --v_bal_rpt_name := SUBSTR(p_ele_name, 1, 16)||' Eligible Comp';
 hr_utility.set_location('pyusuidt',240);
 v_eligiblecomp_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

  if v_balance_name like '%Eligible%' then

     open get_reg_earn_feeds(p_bg_id);
     loop
        FETCH get_reg_earn_feeds INTO l_reg_earn_classification_id,
        l_reg_earn_business_group_id, l_reg_earn_legislation_code,
        l_reg_earn_balance_type_id, l_reg_earn_input_value_id,
        l_reg_earn_scale, l_reg_earn_element_type_id;
        EXIT WHEN get_reg_earn_feeds%NOTFOUND;

        hr_balances.ins_balance_feed(
               p_option                         => 'INS_MANUAL_FEED',
               p_input_value_id                 => l_reg_earn_input_value_id,
               p_element_type_id                => l_reg_earn_element_type_id,
               p_primary_classification_id      => l_reg_earn_classification_id,
               p_sub_classification_id          => NULL,
               p_sub_classification_rule_id     => NULL,
               p_balance_type_id                => v_eligiblecomp_bal_type_id ,
               p_scale                          => l_reg_earn_scale,
               p_session_date                   => g_eff_start_date,
               p_business_group                 => p_bg_id,
               p_legislation_code               => NULL,
               p_mode                           => 'USER');

     end loop;
     close get_reg_earn_feeds;

  end if;

 hr_utility.set_location('pyusuidt',241);
 pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
  			p_balance_dimension 	=> 'Person Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

 pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension 	=> 'Person within Government Reporting Entity Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

 hr_utility.set_location('pyusuidt',243);
 pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension 	=> 'Assignment-Level Current Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

  pay_db_pay_setup.create_defined_balance (
         p_balance_name         => v_balance_name,
         p_balance_dimension    => 'Assignment within Government Reporting Entity Run',
         p_business_group_name  => v_bg_name,
         p_legislation_code     => NULL);


  pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension     => 'Assignment within Government Reporting Entity Year to Date',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

-- End Eligible Comp Balance

/* Vol. Deductions are after-tax components. They will never have Overlimit

-- Begin Aftertax Component Balance

--IF p_ele_at_component = 'Y' THEN
 v_balance_name := SUBSTR(p_ele_name, 1, 67)||' Overlimit';
 --v_bal_rpt_name := SUBSTR(p_ele_name, 1, 17)||' Overlimit';
 hr_utility.set_location('pyusuidt',245);
 --v_notaken_bal_type_id := pay_db_pay_setup.create_balance_type(
 v_overlimit_bal_type_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

 hr_utility.set_location('pyusuidt',246);
 pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
  			p_balance_dimension 	=> 'Person Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);


 hr_utility.set_location('pyusuidt',247);
 pay_db_pay_setup.create_defined_balance (
			p_balance_name 		=> v_balance_name,
                        p_balance_dimension 	=> 'Assignment-Level Current Run',
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL);

  pay_db_pay_setup.create_defined_balance (
         p_balance_name         => v_balance_name,
         p_balance_dimension    => 'Assignment within Government Reporting Entity Run',
         p_business_group_name  => v_bg_name,
         p_legislation_code     => NULL);


*/
--
----------------------- Create Element Type -----------------------------
--
-- Determine deduction skip rule; or we may use the "single" formulae method.
-- 27Sep93: At this moment, a single skip rule will handle all deduction
-- templates.
--
-- Need to determine and get skip rule formula id and pass it
-- create_element.
--
hr_utility.set_location('hr_user_init_dedn.ins_dedn_ele_type',10);
--
IF UPPER(p_ele_start_rule) = 'CHAINED' THEN
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_ele_type',15);
  SELECT 	FF.formula_id
  INTO		v_skip_formula_id
  FROM		ff_formulas_f FF
  WHERE		FF.formula_name 	= 'CHAINED_SKIP_FORMULA'
  AND		FF.business_group_id 	IS NULL
  -- added legislation_code asasthan
  AND           FF.legislation_code  = 'US'
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date
  AND           FF.formula_id           >= 0;  --Bug 3349594
--
ELSIF UPPER(p_ele_start_rule) = 'ET' THEN
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_ele_type',20);
  SELECT 	FF.formula_id
  INTO		v_skip_formula_id
  FROM		ff_formulas_f FF
  WHERE		FF.formula_name 	= 'THRESHOLD_SKIP_FORMULA'
  AND		FF.business_group_id 	IS NULL
  -- added legislation code asasthan
  AND           FF.legislation_code    = 'US'
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date
  AND           FF.formula_id           >= 0;    --Bug 3349594
-- AND FF.business_group_id IS NULL
--
ELSE -- Just check skip rule and separate check flag.
  hr_utility.set_location('hr_user_init_dedn.ins_dedn_ele_type',25);
  SELECT 	FF.formula_id
  INTO		v_skip_formula_id
  FROM		ff_formulas_f FF
  WHERE		FF.formula_name 	= 'FREQ_RULE_SKIP_FORMULA'
  AND		FF.legislation_code	= 'US'
  AND		FF.business_group_id 	IS NULL
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date
  AND           FF.formula_id           >= 0;   --Bug 3349594
--
END IF;
--
-- Find what ele info category will be for SCL.
--
IF UPPER(p_ele_classification) = 'VOLUNTARY DEDUCTIONS' THEN
  g_ele_info_cat := 'US_VOLUNTARY DEDUCTIONS';
END IF;
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',51);
v_ele_type_id :=  ins_dedn_ele_type (	p_ele_name,
					p_ele_reporting_name,
					p_ele_description,
					p_ele_classification,
					p_ele_category,
					p_ele_start_rule,
					p_ele_processing_type,
					p_ele_priority,
					p_ele_standard_link,
					v_skip_formula_id,
					'N',
					g_eff_start_date,
					g_eff_end_date,
					v_bg_name);
--
-- Need to find PRIMARY_CLASSIFICATION_ID of element type.
-- For future calls to various API.
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',53);

select distinct(classification_id)
into   v_primary_class_id
from   pay_element_types_f
where  element_type_id = v_ele_type_id;
--
-- Need to update termination rule.(bug 2276457)
--
UPDATE pay_element_types_f
   SET post_termination_rule = p_termination_rule
 WHERE element_type_id = v_ele_type_id;
--
hr_utility.set_location('pyusuiet',130);
SELECT 	 default_low_priority,
	 default_high_priority
INTO	 v_class_lo_priority,
	 v_class_hi_priority
FROM 	 pay_element_classifications
WHERE	 classification_id = v_primary_class_id
AND	 nvl(business_group_id, p_bg_id) = p_bg_id;


If p_ele_processing_type = 'R' then /* Not required for NR Elements */
   --
   --
   -- Create "special inputs" element
   --
   hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',51);
   v_inputs_ele_name := SUBSTR(p_ele_name, 1, 61)||' Special Inputs';
   v_ele_repname := SUBSTR(p_ele_name, 1, 27)||' SI';
   v_inputs_ele_type_id :=  ins_dedn_ele_type (
			   v_inputs_ele_name,
			   v_ele_repname,
			   p_ele_description,
			   p_ele_classification,
			   p_ele_category,
			   'OE',
			   'N',
			   v_class_lo_priority,
			   'N',
			   NULL,
			   'N',
			   g_eff_start_date,
			   g_eff_end_date,
			   v_bg_name);

   --
   -- Need to update termination rule.(bug 2276457)
   --
   UPDATE pay_element_types_f
      SET post_termination_rule = p_termination_rule
    WHERE element_type_id = v_inputs_ele_type_id;

End if;  /* Not required for NR Elements */

--
--
-- Create "shadow" element
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',51);
v_shadow_ele_name := SUBSTR(p_ele_name, 1, 61)||' Special Features';
v_ele_repname := SUBSTR(p_ele_name, 1, 27)||' SF';
v_shadow_ele_type_id :=  ins_dedn_ele_type (
			v_shadow_ele_name,
			v_ele_repname,
			p_ele_description,
			p_ele_classification,
			p_ele_category,
			'OE',
			'N',
			v_class_hi_priority,
			'N',
			NULL,
			'Y',
			g_eff_start_date,
			g_eff_end_date,
			v_bg_name);

--
-- Need to update termination rule.(bug 2276457)
--
UPDATE pay_element_types_f
   SET post_termination_rule = p_termination_rule
 WHERE element_type_id = v_shadow_ele_type_id;

--
-- Need to create employer charge element for Benefits Table deductions or
-- deductions where there is an employer match component (e.g. 401k, 403b)
--
IF p_ele_amount_rule = 'BT' or p_ele_er_match = 'Y' THEN
  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',55);
  v_er_charge_ele_name		:= SUBSTR(p_ele_name, 1, 77)||' ER';
  v_ele_repname 		:= SUBSTR(p_ele_name, 1, 27)||' ER';
  v_er_charge_eletype_id 	:= ins_dedn_ele_type (
					v_er_charge_ele_name,
					v_ele_repname,
					'Employer portion of benefit.',
					'Employer Liabilities',
					'Benefits',
					NULL,
					'N',
					'6500',
					'N',
					NULL,
					'N',
					g_eff_start_date,
					g_eff_end_date,
					v_bg_name);
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',57);
--
-- Create Pay Value for this element.
--
-- NO, "Employer Liabilities" has non-payments flag = 'N'!
-- So a payvalue is created by pay_db_pay_setup.create_element
-- Need to do this for Non-Payments where non_payments_flag = 'Y',
-- (done for Earnings, but was snagging on "dbi name already used"
-- which i think is a bug.

--
-- Create "Primary" balance for this ER Liab and "associate" appropriately.
--
  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',58);
  v_balance_name := v_er_charge_ele_name;
  --v_bal_rpt_name := v_ele_repname;
  v_er_charge_baltype_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

do_defined_balances(	p_bal_name 	=> v_balance_name,
			p_bg_name	=> v_bg_name);

--
-- Primary balance feeds
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',70);
v_payval_name := hr_input_values.get_pay_value_name(g_template_leg_code);

-- We need inpval_id of pay value for this element:
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',80);
SELECT 	IV.input_value_id
INTO	v_payval_id
FROM 	pay_input_values_f IV
WHERE	IV.element_type_id = v_er_charge_eletype_id
AND	IV.name = v_payval_name;
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',90);
hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => v_payval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_er_charge_baltype_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');



---Inserted by lwthomps for bug 345102.  Associate Primary balance with
---Employer Liabiliity type benefits.

  UPDATE pay_element_types_f
  SET	 ELEMENT_INFORMATION10 = v_er_charge_baltype_id
  WHERE  element_type_id = v_er_charge_eletype_id;

-- Bug Fix 5763867
    UPDATE  pay_element_types_f
        SET element_information_category  = 'US_EMPLOYER LIABILITIES',
            element_information1          = 'B'
      WHERE element_type_id               = v_er_charge_eletype_id
        AND business_group_id + 0         = p_bg_id;

--
END IF; -- Benefit
--
IF p_ele_ee_bond = 'Y' THEN
  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',63);
  v_eerefund_ele_name 	:= SUBSTR(p_ele_name, 1, 72)||' Refund';
  v_ele_repname		:= SUBSTR(p_ele_name, 1, 22)||' Refund';
  v_eerefund_eletype_id	:= ins_dedn_ele_type (
					v_eerefund_ele_name,
					v_ele_repname,
					'EE Bond Refund element.',
					'Non-Payroll Payments',
					'Expense Reimbursement',
					NULL,
					'N',
					p_ele_priority + 1,
					'N',
					NULL,
					'N',
					g_eff_start_date,
					g_eff_end_date,
					v_bg_name);
--
-- Create Bond Refund Primary associated balance...and feeds...
--
--
-- Create "Primary" balance for this EE Bond Refund and
-- "associate" appropriately.
--
  hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',58);
  v_balance_name := v_eerefund_ele_name;
  --v_bal_rpt_name := v_ele_repname;
  v_eerefund_baltype_id := pay_db_pay_setup.create_balance_type(
			p_balance_name 		=> v_balance_name,
			p_uom 			=> 'Money',
			p_reporting_name 	=> v_balance_name,
			p_business_group_name 	=> v_bg_name,
			p_legislation_code 	=> NULL,
			p_legislation_subgroup 	=> NULL,
                        p_balance_category      => l_balance_category, -- Bug 3311781
                        p_bc_leg_code           => 'US',
                        p_effective_date        => g_eff_start_date);

-- Update ele type DDF for primary associated balance.

  UPDATE pay_element_types_f
  SET	 ELEMENT_INFORMATION10 = v_eerefund_baltype_id
  WHERE  element_type_id = v_eerefund_eletype_id;

do_defined_balances(	p_bal_name 	=> v_balance_name,
			p_bg_name	=> v_bg_name,
			p_no_payments	=> TRUE);

--
-- Primary balance feeds
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',70);
v_payval_name := hr_input_values.get_pay_value_name(g_template_leg_code);

-- We need inpval_id of pay value for this element:
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',80);
SELECT 	IV.input_value_id
INTO	v_payval_id
FROM 	pay_input_values_f IV
WHERE	IV.element_type_id = v_eerefund_eletype_id
AND	IV.name = v_payval_name;
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',90);
hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => v_payval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_eerefund_baltype_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

-- Done creating Bond Refund element
--
END IF; -- EE Bond
--
-------------------------- Insert Formula Processing records -------------
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',68);
ins_dedn_formula_processing (	v_ele_type_id,
				p_ele_name,
				v_shadow_ele_type_id,
				v_shadow_ele_name,
				v_inputs_ele_type_id,
				v_inputs_ele_name,
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
				v_eerefund_eletype_id,
				p_bg_id,
				p_mix_flag,
				g_eff_start_date,
				g_eff_end_date,
				v_bg_name);
--
-------------------------Insert Input Values --------------------------
--
-- Make insertion of all basic earnings input vals (ie. req'd for all
-- earnings elements, not based on calc rule; instead on Class).
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',69);
ins_dedn_input_vals (	v_ele_type_id,
			p_ele_name,
			v_shadow_ele_type_id,
			v_shadow_ele_name,
			v_inputs_ele_type_id,
			v_inputs_ele_name,
			g_eff_start_date,
			g_eff_end_date,
			v_primary_class_id,
			p_ele_classification,
			p_ele_category,
			p_ele_processing_type,
			p_bg_id,
			v_bg_name,
			p_ele_amount_rule);
--
------------------------ Insert Balance Feeds -------------------------
--
-- First, call the "category feeder" API which creates manual pay value feeds
-- to pre-existing balances depending on the element classn/category.
-- (Added by ALLEE - 5-MAY-1995)  Pass 'g_ele_eff_start_date' to
-- create_category_feeds in order for datetrack to work.
pay_us_ctgy_feeds_pkg.create_category_feeds(
			p_element_type_id =>  v_ele_type_id,
			p_date		  =>  g_eff_start_date);
--
-- These are manual feeds for "primary" balance for earnings element.
-- For manual feeds, only baltype id, inpval id, and scale are req'd.
--
-- NOTE: For primary balances, the feeds should not be altered - only one
-- value should ever feed the primary balance (ie. the element's payvalue).
-- In order to query the balance on Define Balances, the LEG Subgroup should
-- be NULL instead of 'TEMPLATE'.
--
-- We also need to feed the Section 125 and 401k balances
-- when the deduction Classification/Category = PreTax/125 or Deferred
-- as appropriate.
--
-- And we need to update element type DDF with associated balances (G1241).
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',70);
v_payval_name := hr_input_values.get_pay_value_name(g_template_leg_code);

-- We need inpval_id of pay value for this element:
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',80);
SELECT 	IV.input_value_id
INTO	v_payval_id
FROM 	pay_input_values_f IV
WHERE	IV.element_type_id = v_ele_type_id
AND	IV.name = v_payval_name;
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
--
hr_utility.set_location('hr_user_init_dedn.ins_deduction_template',90);
hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => v_payval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
-- Addl/Repl Amount balance feeds from Special Features ele:
--

if p_ele_processing_type = 'R' then  /* Not required for NR Elements  */

  hr_utility.set_location('pyusuiet',147);
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_addl_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_addl_amt_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
--
hr_utility.set_location('pyusuiet',146);
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
  hr_utility.set_location('pyusuiet',147);
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_repl_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_repl_amt_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
-- Addl/Repl Amount balance feeds from Special Inputs ele:
--
  hr_utility.set_location('pyusuiet',147);
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => gi_addl_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_addl_amt_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
--
hr_utility.set_location('pyusuiet',146);
--
-- Now, insert feed.
-- Note, there is a packaged function "chk_ins_balance_feed" in pybalnce.pkb.
-- Since this is definitely a new balance feed for a new element and balance,
-- there is no chance for duplicating an existing feed.
  hr_utility.set_location('pyusuiet',147);
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => gi_repl_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_repl_amt_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

End if;  /* Not required for NR Elements */

--
-- Arrearage bal feeds
IF p_ele_arrearage = 'Y' THEN
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_arrears_contr_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_arrears_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_adj_arrears_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_arrears_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

END IF; -- Arrearage balfeeds
--
-- Not Taken bal feed
--
hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_notaken_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_notaken_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
-- EE Bond bal feeds
IF p_ele_ee_bond = 'Y' THEN
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_topurch_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_eepurch_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
END IF;	-- EE Bond bal feeds
--
-- Total Reached bal feeds (stop rule)
IF UPPER(p_ele_stop_rule) = 'TOTAL REACHED' THEN
  hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => g_to_tot_inpval_id,
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => v_totowed_bal_type_id,
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');
--
END IF; -- Stop rule bal feeds.
--
--
-- Other associated balances:
--

if p_ele_processing_type = 'R' then  /* Not required for NR Elements */
   UPDATE pay_element_types_f
   SET    element_information10 = v_bal_type_id,
          element_information11 = v_totowed_bal_type_id,
          element_information12 = v_arrears_bal_type_id,
          element_information13 = v_notaken_bal_type_id,
          element_information14 = v_eepurch_bal_type_id,
          element_information16 = v_addl_amt_bal_type_id,
          element_information17 = v_repl_amt_bal_type_id,
          element_information18 = v_inputs_ele_type_id,
          element_information19 = v_shadow_ele_type_id
   WHERE  element_type_id = v_ele_type_id
   AND    business_group_id + 0 = p_bg_id;

else /* Not required for NR Elements */

   UPDATE pay_element_types_f
   SET    element_information10 = v_bal_type_id,
          element_information13 = v_notaken_bal_type_id,
          element_information19 = v_shadow_ele_type_id
   WHERE  element_type_id = v_ele_type_id
   AND    business_group_id + 0 = p_bg_id;

end if;  /*  Not required for NR Elements  */
--
----------------------------- Conclude Main -----------------------------
--
RETURN v_ele_type_id;

END ins_deduction_template;
--
-------------------------------- Locking procedures ----------------------
--
PROCEDURE lock_template_rows (
		p_ele_type_id 		in number,
		p_ele_eff_start_date	in date 	default NULL,
		p_ele_eff_end_date	in date		default NULL,
		p_ele_name		in varchar2,
		p_ele_reporting_name 	in varchar2,
		p_ele_description 	in varchar2 	default NULL,
		p_ele_classification 	in varchar2,
		p_ele_category 		in varchar2	default NULL,
		p_ele_processing_type 	in varchar2,
		p_ele_priority 		in number	default NULL,
		p_ele_standard_link 	in varchar2 	default 'N') IS

CURSOR chk_for_lock IS
	SELECT	*
 	FROM 	pay_all_deduction_types_v
	WHERE  	element_type_id = p_ele_type_id;
--	FOR UPDATE OF element_type_id NOWAIT;

recinfo chk_for_lock%ROWTYPE;

BEGIN
  hr_utility.set_location('hr_user_init_dedn.lock_template_rows',10);
  OPEN chk_for_lock;
  FETCH chk_for_lock INTO recinfo;
  CLOSE chk_for_lock;

-- Note: Not checking eff dates.

  hr_utility.set_location('hr_user_init_dedn.lock_template_rows',20);
  IF ( ( (recinfo.element_type_id = p_ele_type_id)
       OR (recinfo.element_type_id IS NULL AND p_ele_type_id IS NULL))
--     AND ( (recinfo.effective_start_date = fnd_date.canonical_to_date(p_ele_eff_start_date))
--       OR (recinfo.effective_start_date IS NULL
--		AND p_ele_eff_start_date IS NULL))
--     AND ( (recinfo.effective_end_date = fnd_date.canonical_to_date(p_ele_eff_end_date))
--       OR (recinfo.effective_end_date IS NULL
--		AND p_ele_eff_end_date IS NULL))
     AND ( (recinfo.element_name = p_ele_name)
       OR (recinfo.element_name IS NULL AND p_ele_name IS NULL))
     AND ( (recinfo.reporting_name = p_ele_reporting_name)
       OR (recinfo.reporting_name IS NULL AND p_ele_reporting_name IS NULL))
     AND ( (recinfo.description = p_ele_description)
       OR (recinfo.description IS NULL AND p_ele_description IS NULL))
     AND ( (recinfo.classification_name = p_ele_classification)
       OR (recinfo.classification_name IS NULL
		AND p_ele_classification IS NULL))
     AND ( (recinfo.category = p_ele_category)
       OR (recinfo.category IS NULL AND p_ele_category IS NULL))
     AND ( (recinfo.processing_type = p_ele_processing_type)
       OR (recinfo.processing_type IS NULL AND p_ele_processing_type IS NULL))
     AND ( (recinfo.processing_priority = p_ele_priority)
       OR (recinfo.processing_priority IS NULL AND p_ele_priority IS NULL))
     AND ( (recinfo.standard_link_flag = p_ele_standard_link)
      OR (recinfo.standard_link_flag IS NULL AND p_ele_standard_link IS NULL)))
THEN
  hr_utility.set_location('hr_user_init_dedn.lock_template_rows',30);
  RETURN;
ELSE
  hr_utility.set_location('hr_user_init_dedn.lock_template_rows',40);
  hr_utility.set_message(801,'PAY_xxxx_COULD_NOT_OBTAIN_LOCK');
  hr_utility.raise_error;

  --  FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED_BY_ANOTHER_USER');
  --  APP_EXCEPTION.RAISE_EXCEPTION;

END IF;

END lock_template_rows;
--
--
------------------------- Deletion procedures -----------------------------
--
--       element_information10 = primary bal
--       element_information11 = accrued bal
--       element_information12 = arrears bal
--       element_information13 = not taken bal
--       element_information15 = able amount bal
--       element_information16 = addl amount bal
--       element_information17 = repl amount bal
--       element_information18 = Special Inputs
--       element_information19 = Special Features
--       element_information20 = Withholding ele
--
-- Configuration deletion follows this algorithm:
-- 0. Delete frequency rules for wage attachment.
-- 1. Delete all associated balances.
-- 2. For all associated element types of configured wage attachment...
-- 3. Delete all formula result rules.
-- 4. Delete all status processing rules.
-- 5. Delete all formulae.
-- 6. Delete all input values.
-- 7. Delete element types.
/* Bug 787491: All select statements are using business_group_id in where
condition */
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
			p_del_val_end_date	in date) IS
-- local constants
c_end_of_time  CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');

-- local vars

  TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE num_table IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;

  assoc_eles		num_table;
  assoc_bals		num_table;

  i 			number;
  j			number;
  l_num_assoc_bals	number;
  l_num_assoc_eles	number;

v_del_mode	VARCHAR2(80) 	:= 'ZAP'; -- Completely remove template.
v_startup_mode	VARCHAR2(80) 	:= 'USER';
v_del_sess_date DATE 		:= NULL;
v_del_val_start DATE 		:= NULL;
v_del_val_end	DATE 		:= NULL;
v_bal_type_id	NUMBER(9);
v_eletype_id	NUMBER(9);
v_shadow_eletype_id		NUMBER(9);
v_shadow_ele_priority		NUMBER(9);
v_inputs_eletype_id		NUMBER(9);
v_inputs_ele_priority		NUMBER(9);
v_ff_id		NUMBER(9);
v_ff_count	NUMBER(3);
v_fname_suffix	VARCHAR2(20);
v_eletype_count NUMBER(3);
v_baltype_count	NUMBER(3);
v_addl_bal_type_id	NUMBER(9);
v_addl_bal_name	VARCHAR2(80);
v_repl_bal_type_id	NUMBER(9);
v_repl_bal_name	VARCHAR2(80);
v_freqrule_id	NUMBER(9);
v_not_taken_baltype_id number;
v_class_name	VARCHAR2(80);

v_employer_match_flag   varchar2(2000);
v_after_tax_flag   varchar2(2000);
v_after_tax_id     number;
v_after_tax_si_id     number;
v_after_tax_sf_id     number;
v_employer_match_id number;
v_at_er_id number;

v_elig_bal_id number;
v_overlimit_bal_id number;
v_at_er_bal_id number;
v_at_bal_id number;
v_at_accr_id number;
v_at_addl_id number;
v_at_arr_id number;
v_at_elig_id number;
v_at_not_taken_id number;
v_at_overlimit_id number;
v_at_repl_id number;
v_at_to_bond_id number;

v_spr_id	number(9);
v_assoc_ele_priority	number(9);
v_refund_bal_id         pay_balance_types.balance_type_id%TYPE;
v_refund_ele_id         pay_element_types_f.element_type_id%TYPE;

CURSOR	get_freqrule IS
SELECT 	ele_payroll_freq_rule_id
FROM   	pay_ele_payroll_freq_rules
WHERE  	element_type_id = p_ele_type_id
AND	business_group_id = p_business_group_id;

CURSOR 	get_formulae(l_ele_id in number) IS
SELECT	distinct ff.formula_id
FROM	pay_status_processing_rules_f spr, ff_formulas_f ff
WHERE	spr.element_type_id = l_ele_id
AND	ff.formula_id = spr.formula_id
AND	ff.business_group_id = p_business_group_id;

CURSOR get_old_formulae(l_ele_name in varchar2) IS
SELECT	distinct ff.formula_id
FROM	ff_formulas_f ff
WHERE	ff.formula_name like upper('OLD%'||p_ele_name||'_FLAT%')
OR	ff.formula_name like upper('OLD%'||p_ele_name||'_PERCENT%')
OR	ff.formula_name like upper('OLD%'||p_ele_name||'_BENEFIT%')
OR	ff.formula_name like upper('OLD%'||p_ele_name||'_PAYROLL%')
OR	ff.formula_name like upper('OLD%'||p_ele_name||'_WITHHOLDING')
AND	ff.business_group_id = p_business_group_id;

CURSOR 	get_spr(l_ele_id in number) IS
SELECT	distinct status_processing_rule_id
FROM	pay_status_processing_rules_f
WHERE	element_type_id = l_ele_id
AND	business_group_id = p_business_group_id;

--
BEGIN
-- Populate vars.
v_del_val_end	 	:= nvl(p_del_val_end_date, c_end_of_time);
v_del_val_start 	:= nvl(p_del_val_start_date, sysdate);
v_del_sess_date 	:= nvl(p_del_sess_date, sysdate);
pay_db_pay_setup.set_session_date(nvl(p_del_val_start_date, sysdate));

assoc_eles(1)	:= fnd_number.canonical_to_number(p_ele_info_18);	-- Special Inputs ele
assoc_eles(2)	:= fnd_number.canonical_to_number(p_ele_info_19);	-- Special Features ele
assoc_eles(3)	:= fnd_number.canonical_to_number(p_ele_info_20);	-- Withholding ele
assoc_eles(4)	:= p_ele_type_id;		-- Base ele

l_num_assoc_eles := 4;

--Begin
select employer_match_flag, aftertax_component_flag, classification_name
into v_employer_match_flag, v_after_tax_flag, v_class_name
from pay_all_deduction_types_v
where element_type_id = p_ele_type_id
and    v_del_sess_date >= effective_start_date
and    v_del_sess_date <= effective_end_date
and business_group_id + 0 = p_business_group_id ;

--Exception when no_data_found then
 --	v_employer_match_flag := 'N';
  --      v_after_tax_flag := 'N';
--	v_class_name := 'Voluntary Deductions';
--End;

Begin
select balance_type_id
into v_not_taken_baltype_id
from pay_balance_types
where balance_name like p_ele_name||' Not Taken'
and business_group_id + 0 = p_business_group_id ;

exception when NO_DATA_FOUND then null;
End;

assoc_bals(1)	:= fnd_number.canonical_to_number(p_ele_info_10);	-- Primary bal
assoc_bals(2)	:= fnd_number.canonical_to_number(p_ele_info_11);	-- Accrued bal
assoc_bals(3)	:= fnd_number.canonical_to_number(p_ele_info_12);	-- Arrears bal
assoc_bals(4)	:= v_not_taken_baltype_id;	-- Not Taken bal
assoc_bals(5)	:= fnd_number.canonical_to_number(p_ele_info_14);	-- Bond Purch bal
assoc_bals(6)	:= fnd_number.canonical_to_number(p_ele_info_15);	-- Able bal
assoc_bals(7)	:= fnd_number.canonical_to_number(p_ele_info_16);	-- Additional Amt bal
assoc_bals(8)	:= fnd_number.canonical_to_number(p_ele_info_17);	-- Replacement Amt bal

Begin
select balance_type_id
into v_elig_bal_id
from pay_balance_types
where balance_name like p_ele_name||' Eligible Comp'
and business_group_id + 0 = p_business_group_id ;

exception when NO_DATA_FOUND then null;
End;

assoc_bals(9)   := v_elig_bal_id;
l_num_assoc_bals := 9;

if v_employer_match_flag = 'Y' then
   l_num_assoc_eles := l_num_assoc_eles + 1;

   select element_type_id
   into v_employer_match_id
   from pay_element_types_f
   where element_name like p_ele_name||' ER'
   and    v_del_sess_date >= effective_start_date
   and    v_del_sess_date <= effective_end_date
   and business_group_id + 0 = p_business_group_id ;

   assoc_eles(l_num_assoc_eles) := v_employer_match_id;
end if;

if v_after_tax_flag = 'Y' then
   l_num_assoc_eles := l_num_assoc_eles + 1;

   select element_type_id
   into v_after_tax_id
   from pay_element_types_f
   where element_name like p_ele_name||' AT'
   AND    v_del_sess_date >= effective_start_date
   AND    v_del_sess_date <= effective_end_date
   and business_group_id + 0 = p_business_group_id;

   assoc_eles(l_num_assoc_eles) := v_after_tax_id;

   l_num_assoc_eles := l_num_assoc_eles + 1;

   select element_type_id
   into v_after_tax_si_id
   from pay_element_types_f
   where element_name like p_ele_name||' AT Special Inputs'
   AND    v_del_sess_date >= effective_start_date
   AND    v_del_sess_date <= effective_end_date
   and business_group_id + 0 = p_business_group_id;

   assoc_eles(l_num_assoc_eles) := v_after_tax_si_id;

   l_num_assoc_eles := l_num_assoc_eles + 1;

   select element_type_id
   into v_after_tax_sf_id
   from pay_element_types_f
   where element_name like p_ele_name||' AT Special Features'
   AND    v_del_sess_date >= effective_start_date
   AND    v_del_sess_date <= effective_end_date
   and business_group_id + 0 = p_business_group_id;

   assoc_eles(l_num_assoc_eles) := v_after_tax_sf_id;

-- Bug 3613575 -- Added table pay_elements_types_f to remove Merge Join Cartesian
   select primary_baltype_id, accrued_baltype_id, arrears_baltype_id,
	  not_taken_baltype_id, tobondpurch_baltype_id,
          additional_baltype_id, replacement_baltype_id
   into v_at_bal_id, v_at_accr_id, v_at_arr_id, v_at_not_taken_id,
        v_at_to_bond_id, v_at_addl_id, v_at_repl_id
   from pay_all_deduction_types_v padt,
	pay_element_types_f pet
   WHERE pet.element_type_id = padt.element_type_id
   AND padt.element_name like p_ele_name||' AT'
   AND    v_del_sess_date >= padt.effective_start_date
   AND    v_del_sess_date <= padt.effective_end_date
   AND padt.business_group_id + 0 = p_business_group_id
   AND rownum<2;

   select balance_type_id
   into v_at_not_taken_id
   from pay_balance_types
   where balance_name like p_ele_name||' AT Not Taken'
   and business_group_id + 0 = p_business_group_id ;

   select balance_type_id
   into v_at_elig_id
   from pay_balance_types
   where balance_name like p_ele_name||' AT Eligible Comp'
   and business_group_id + 0 = p_business_group_id ;

   select balance_type_id
   into v_at_overlimit_id
   from pay_balance_types
   where balance_name like p_ele_name||' AT Overlimit'
   and business_group_id + 0 = p_business_group_id ;

   assoc_bals(10) := v_at_bal_id;
   assoc_bals(11) := v_at_accr_id;
   assoc_bals(12) := v_at_addl_id;
   assoc_bals(13) := v_at_arr_id;
   assoc_bals(14) := v_at_elig_id;
   assoc_bals(15) := v_at_not_taken_id;
   assoc_bals(16) := v_at_overlimit_id;
   assoc_bals(17) := v_at_repl_id;
   assoc_bals(18) := v_at_to_bond_id;

   l_num_assoc_bals := 18;
end if;

if v_employer_match_flag = 'Y' and v_after_tax_flag = 'Y' then

   l_num_assoc_eles := l_num_assoc_eles + 1;

   select element_type_id
   into v_at_er_id
   from pay_element_types_f
   where element_name like p_ele_name||' AT ER'
   AND    v_del_sess_date >= effective_start_date
   AND    v_del_sess_date <= effective_end_date
   and business_group_id + 0 = p_business_group_id ;

   assoc_eles(l_num_assoc_eles) := v_at_er_id;

   select balance_type_id
   into v_at_er_bal_id
   from pay_balance_types
   where balance_name like p_ele_name||' AT ER'
   and business_group_id + 0 = p_business_group_id ;

   assoc_bals(19) := v_at_er_bal_id;
   l_num_assoc_bals := 19;

end if;

if v_class_name = 'Voluntary Deductions' then

   l_num_assoc_bals := l_num_assoc_bals + 1;

   begin
   select balance_type_id
   into v_overlimit_bal_id
   from pay_balance_types
   where balance_name like p_ele_name||' Overlimit'
   and business_group_id + 0 = p_business_group_id ;

   exception when NO_DATA_FOUND then null;
   end;

   assoc_bals(l_num_assoc_bals) := v_overlimit_bal_id;

   -- Following Added for Bug# 7535681
   IF p_ele_ee_bond = 'Y' THEN
      BEGIN
        SELECT balance_type_id
          INTO v_refund_bal_id
          FROM pay_balance_types
         WHERE balance_name like p_ele_name||' Refund'
           AND business_group_id + 0 = p_business_group_id ;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      l_num_assoc_bals := l_num_assoc_bals + 1;
      assoc_bals(l_num_assoc_bals) := v_refund_bal_id;

      BEGIN
      SELECT element_type_id
       INTO  v_refund_ele_id
       FROM pay_element_types_f
      WHERE element_name like p_ele_name||' Refund'
        AND v_del_sess_date >= effective_start_date
        AND v_del_sess_date <= effective_end_date
        AND business_group_id + 0 = p_business_group_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      l_num_assoc_eles := l_num_assoc_eles + 1;
      assoc_eles(l_num_assoc_eles) := v_refund_ele_id;
   END IF; -- p_ele_ee_bond = 'Y'

end if;

--
-- Do not allow deletion of Special Features element.
--
IF p_ele_name like '% Special Features' THEN
  hr_utility.set_location('hr_user_init_dedn.do_deletion',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Do not allow deletion of Special Inputs element.
--
IF p_ele_name like '% Special Inputs' THEN
  hr_utility.set_location('hr_user_init_dedn.do_deletion',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Do not allow deletion of Withholding element.
--
IF p_ele_name like '% Withholding' THEN
  hr_utility.set_location('hr_user_init_dedn.do_deletion',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--

--
-- Delete frequency rule info:
--
-- Deletion of any Deduction Frequency Rules should be handled
-- by cascade delete according to db constraint.
-- 14 June 1995: Bug# 271622 notes that ele freq rules are NOT deleted
-- when a deduction is deleted.  Constraint not working...
--

OPEN get_freqrule;
LOOP
  FETCH get_freqrule INTO v_freqrule_id;
  EXIT WHEN get_freqrule%NOTFOUND;
  hr_utility.set_location('pyusuidt',153);

  begin

    DELETE FROM pay_freq_rule_periods
    WHERE ele_payroll_freq_rule_id = v_freqrule_id;

  exception when NO_DATA_FOUND then
    null; -- No freq rule periods exist.
  end;

  begin

    DELETE FROM pay_ele_payroll_freq_rules
    WHERE ele_payroll_freq_rule_id = v_freqrule_id;

  exception when NO_DATA_FOUND then
    null; -- No freq rule exists.
  end;

END LOOP;
CLOSE get_freqrule;

--
-- Loop to delete formula result rules, status proc rules, and formulae.
--
-- Note: deletion of formula result rules is handled by
--       del_status_processing_rules.
--

FOR i in 1..l_num_assoc_eles LOOP

  IF assoc_eles(i) IS NOT NULL THEN

-- Get formula_ids to delete from various tables:
-- FF_FORMULAS_F
-- FF_FDI_USAGES_F
-- FF_COMPILED_INFO_F
--
    OPEN get_formulae(assoc_eles(i));
    LOOP

      FETCH get_formulae INTO v_ff_id;
      EXIT WHEN get_formulae%NOTFOUND;

      begin

        DELETE FROM	ff_formulas_f
        WHERE		formula_id = v_ff_id;

      exception when NO_DATA_FOUND then
        null;
      end;

      begin

        DELETE FROM	ff_fdi_usages_f
        WHERE		formula_id = v_ff_id;

      exception when NO_DATA_FOUND then
        null;
      end;

      begin

        DELETE FROM	ff_compiled_info_f
        WHERE		formula_id = v_ff_id;

      exception when NO_DATA_FOUND then
        null;
      end;

    END LOOP;
    CLOSE get_formulae;

    OPEN get_spr(assoc_eles(i));
    LOOP

      FETCH get_spr INTO v_spr_id;
      EXIT WHEN get_spr%NOTFOUND;

      hr_utility.set_location('hr_us_garn_gen.delete_dedn', 10);
      hr_elements.del_status_processing_rules(
			p_element_type_id       => assoc_eles(i),
		        p_delete_mode	        => v_del_mode,
		        p_val_session_date      => v_del_sess_date,
			p_val_start_date  	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end,
			p_startup_mode		=> v_startup_mode);

    END LOOP;
    CLOSE get_spr;

  END IF;

END LOOP;
--
-- Delete all OLD formulae created during upgrades.
--
OPEN get_old_formulae(p_ele_name);
LOOP
  FETCH get_old_formulae
  INTO  v_ff_id;
  EXIT WHEN get_old_formulae%NOTFOUND;

  begin

    DELETE FROM	ff_formulas_f
    WHERE formula_id = v_ff_id;

  exception when NO_DATA_FOUND then
    null;
  end;

  begin

    DELETE FROM	ff_fdi_usages_f
    WHERE formula_id = v_ff_id;

  exception when NO_DATA_FOUND then
    null;
  end;

  begin

    DELETE FROM	ff_compiled_info_f
    WHERE formula_id = v_ff_id;

  exception when NO_DATA_FOUND then
    null;
  end;

END LOOP;
CLOSE get_old_formulae;

--
-- Delete all associated balances.
--
-- Balance type ids of associated balances for this element are passed in
-- via the p_ele_info_xx params.
-- Note, all balance feeds for each balance type are deleted
-- by del_balance_type_cascade.
--
FOR i in 1..l_num_assoc_bals LOOP

  IF assoc_bals(i) IS NOT NULL THEN

    hr_utility.set_location('hr_us_garn_gen.delete_dedn', 50);
    hr_balances.del_balance_type_cascade (
	p_balance_type_id       => assoc_bals(i),
	p_legislation_code      => g_template_leg_code,
	p_mode                  => v_del_mode);

    hr_utility.set_location('hr_us_garn_gen.delete_dedn', 60);
    DELETE FROM pay_balance_types
    WHERE balance_type_id = assoc_bals(i);

  END IF;

END LOOP;

--
-- Now delete associated eles:
--
-- Note: Input value deletion is handled by del_3p_element_type
--

FOR j in 1..l_num_assoc_eles LOOP

  IF assoc_eles(j) IS NOT NULL THEN

    select processing_priority
    into   v_assoc_ele_priority
    from   pay_element_types_f
    where  element_type_id = assoc_eles(j)
    and    v_del_sess_date between effective_start_date
                               and effective_end_date;

    hr_utility.set_location('hr_us_garn_gen.delete_dedn', 20);
    hr_elements.chk_del_element_type (
			p_mode             	=> v_del_mode,
			p_element_type_id  	=> assoc_eles(j),
			p_processing_priority	=> v_assoc_ele_priority,
			p_session_date	   	=> v_del_sess_date,
			p_val_start_date       	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end);

    hr_utility.set_location('hr_us_garn_gen.delete_dedn', 30);
    hr_elements.del_3p_element_type (
			p_element_type_id       => assoc_eles(j),
		        p_delete_mode	        => v_del_mode,
		        p_val_session_date      => v_del_sess_date,
			p_val_start_date  	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end,
			p_startup_mode		=> v_startup_mode);
    --
    -- Delete element type record:
    -- Remember, we're 'ZAP'ing, no need to worry about date-effective delete.
    --
    hr_utility.set_location('hr_us_garn_gen.delete_dedn', 35);
    delete from PAY_ELEMENT_TYPES_F
    where 	element_type_id = assoc_eles(j);

  END IF;

END LOOP;

-- ********
-- END LOOP TO DELETE ELES
-- ********

--
-- Special deletion handling for deductions:
-- 1. A benefit deduction will have an employer liability element
--    and balance.
-- 2. A bond deduction will have a bond refund element and balance.
--

--
-- Check for benefit deduction and delete ER element and balance if present.
--

  begin

    SELECT DISTINCT balance_type_id
    INTO   v_bal_type_id
    FROM   pay_balance_types
    WHERE  balance_name = p_ele_name || ' ER'  --Bug 3349594
    and business_group_id + 0 = p_business_group_id ;

    hr_balances.del_balance_type_cascade (
	p_balance_type_id       => v_bal_type_id,
	p_legislation_code      => g_template_leg_code,
	p_mode                  => v_del_mode);

    hr_utility.set_location('pyusuiet',165);
    delete from PAY_BALANCE_TYPES
    where  balance_type_id = v_bal_type_id;

  exception when NO_DATA_FOUND then
    null;
  end;

  begin

/** Bug 566328: The select statement below is modified to put business group id
     in the where clause. Because now it is allowing to enter deduction with
	  same name in different business groups( ref. Bug 502307), selection only by
	  element name will fetch more than one row and raise error.  **/

    SELECT DISTINCT element_type_id
    INTO   v_eletype_id
    FROM   pay_element_types_f
    WHERE  element_name = p_ele_name || ' ER'  --Bug 3349594
    AND    v_del_sess_date >= effective_start_date
    AND	   v_del_sess_date <= effective_end_date
    and business_group_id + 0 = p_business_group_id ;

    hr_utility.set_location('hr_user_init_dedn.do_deletions', 20);
    hr_elements.chk_del_element_type (
			p_mode             	=> v_del_mode,
			p_element_type_id  	=> v_eletype_id,
			p_processing_priority	=> NULL,
			p_session_date	   	=> v_del_sess_date,
			p_val_start_date       	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end);

    hr_utility.set_location('hr_user_init_dedn.do_deletions', 30);
    hr_elements.del_3p_element_type (
			p_element_type_id       => v_eletype_id,
		        p_delete_mode	        => v_del_mode,
		        p_val_session_date      => v_del_sess_date,
			p_val_start_date  	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end,
			p_startup_mode		=> v_startup_mode);
--
-- Delete element type record:
-- Remember, we're 'ZAP'ing, so no need to worry about date-effective delete.
--
    hr_utility.set_location('hr_user_init_dedn.do_deletions', 35);
    delete from PAY_ELEMENT_TYPES_F
    where  element_type_id = v_eletype_id;

  exception when NO_DATA_FOUND then
    null;
  end;

--
-- Check for EE bond and delete refund element if present.
--

begin

    SELECT DISTINCT balance_type_id
    INTO   v_bal_type_id
    FROM   pay_balance_types
    WHERE  balance_name = p_ele_name || ' REFUND'  --Bug 3349594
   and business_group_id + 0 = p_business_group_id ;

    hr_balances.del_balance_type_cascade (
	p_balance_type_id       => v_bal_type_id,
	p_legislation_code      => g_template_leg_code,
	p_mode                  => v_del_mode);

    hr_utility.set_location('pyusuiet',165);
    delete from PAY_BALANCE_TYPES
    where  balance_type_id = v_bal_type_id;

  exception when NO_DATA_FOUND then
    null;
  end;

  begin

/** Bug 566328: The select statement below is modified to put business group id
     in the where clause. Because now it is allowing to enter deduction with
	  same name in different business groups( ref. Bug 502307), selection only by
	  element name will fetch more than one row and raise error.  **/

    hr_utility.set_location('hr_user_init_dedn.do_deletions', 17);
    SELECT DISTINCT element_type_id
    INTO   v_eletype_id
    FROM   pay_element_types_f
    WHERE  element_name = p_ele_name || ' REFUND'   --Bug 3349594
    AND    v_del_sess_date >= effective_start_date
    AND	   v_del_sess_date <= effective_end_date
    and business_group_id + 0 = p_business_group_id ;

    hr_utility.set_location('hr_user_init_dedn.do_deletions', 20);
    hr_elements.chk_del_element_type (
			p_mode             	=> v_del_mode,
			p_element_type_id  	=> v_eletype_id,
			p_processing_priority	=> NULL,
			p_session_date	   	=> v_del_sess_date,
			p_val_start_date       	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end);

    hr_utility.set_location('hr_user_init_dedn.do_deletions', 30);
    hr_elements.del_3p_element_type (
			p_element_type_id       => v_eletype_id,
		        p_delete_mode	        => v_del_mode,
		        p_val_session_date      => v_del_sess_date,
			p_val_start_date  	=> v_del_val_start,
			p_val_end_date     	=> v_del_val_end,
			p_startup_mode		=> v_startup_mode);

    hr_utility.set_location('hr_user_init_dedn.do_deletions', 35);
    delete from PAY_ELEMENT_TYPES_F
    where  element_type_id = v_eletype_id;

  exception when NO_DATA_FOUND then
    null;
  end;


END do_deletions; -- Del recs according to lockladder.


FUNCTION get_assoc_ele(p_ele_type_id 	in NUMBER
				,p_suffix		in VARCHAR2
				,p_eff_start_date	in DATE
				,p_bg_id		in NUMBER) RETURN varchar2 IS

  CURSOR csr_sfx IS
  SELECT decode(x.element_name,null,'N','Y')
  FROM pay_element_types x, pay_element_types b
  WHERE b.element_type_id = p_ele_type_id
  AND   b.business_group_id + 0 = p_bg_id
  AND   p_eff_start_date between b.effective_start_date
  		AND   b.effective_end_date
  AND   x.business_group_id + 0 = p_bg_id
  AND   x.effective_start_date between b.effective_start_date
		  AND   b.effective_end_date
  AND   b.element_name||' '||p_suffix = x.element_name(+);

/* Bug 703234: l_val is defaulted to 'N' , so that if csr_sfx does not
does not fetch any row l_val passes the value 'N', instead of '', which was
creating problem in the form. Because aftertax_component_flag and
employer_match_flag were not being set to any value */

  l_val	varchar2(1) := 'N';
BEGIN
	OPEN csr_sfx;
	FETCH csr_sfx INTO l_val;
	CLOSE csr_sfx;
	RETURN l_val;
END get_assoc_ele;
END hr_user_init_dedn;

/
