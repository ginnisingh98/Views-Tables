--------------------------------------------------------
--  DDL for Package Body HR_US_GARN_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_GARN_GEN" as
/*$Header: pywatgen.pkb 120.1.12000000.1 2007/01/18 03:19:40 appldev noship $*/

/*
+======================================================================+
|                Copyright (c) 1993 Oracle Corporation                 |
|                   Redwood Shores, California, USA                    |
|                        All rights reserved.                          |
+======================================================================+

    Name        : Wage Attachment Generator
    Filename    : pywatgen.pkb
    Change List
    -----------
    Date        Name            Vers    Bug No  Description
    ----        ----            ----    ------  -----------
    13-NOV-95   hparicha        40.0    Created.
    19-DEC-95   jthuring        40.3    Fixed RCS header
    09-JAN-96	hparicha    40.4	333133 Added defined balances
					required for summary reporting.
    20-FEB-96	hparicha    40.5    	338498  Garn fees must be reported
					separately from
					garn deduction...add associated bal
					and ele, along with appropriate bal
					feeds and formula results.
    11-MAR-96	hparicha		Don't forget to associate the fee bal
					with fee ele as the
					primary balance; and to make
					classification feeds for
					the input values fed with Fee results
					- ie. feed all balances to be fed by
					involuntary deductions.
    28-MAR-96  hparicha	    40.6	353325: Adding params to allow user
					entered reporting name and description
					of wage attachment elements.
					353321: Freq rules can now be entered
					for invol dedns.
15th April 1996	Hparicha	40.7	350540 : Not Taken and Adj Not Taken
					input values added
					to Special Features.  Results from
					base and verif ffs, feeds to
					associated balance Not Taken.
16th April 1996	Hparicha		344518 : Arrears Bal Amount and
					Support Other Family ivs
					added to base and calc.  Results from
					base to calc for supp other fam
					(reusing arrears bal amount from base
					to calc).
 					Also, modify result rules from calc
					and verif to feed Pay Values of base
					and fee elements for costing purposes.
					Also, adding feeds to Accrued assoc bal
					for proper total owed processing.
14th July 1996	hparicha	40.8	373235 - friendlier iv names.
					374743 - spousal support and
					alimony are treated same as
					child support - ie. they are
					all "support" orders.
					Adding checks for existence before
					creation of elements, etc...this
					makes wage attachments upgradeable.
					Also making iv name changes as per bug
					text.
					365745 - New high level category bal
					for tax levies must be fed when
					category is tax levy.
					378699 - New high level adjusted
					support bal must be fed from verifier
					result via SF input val.
25th July 1996	hparicha	40.9	Various changes during SWAMP QA.
				40.10	Removed various out-dated inputs.
				40.11	Changed withheld fee result so that it
					hits an input value on Fee element so
					a run result is created...so the Fee
					shows up on SOE et al.
30th July 1996	hparicha	40.12	Added new result rule to Order Indirect
					subpriority of Calculator elements.
31st July 1996	hparicha	40.13	Removed underscores from iv names
					(again).
7th Aug 1996	hparicha	40.14	388710. Added formula resrule
					to pass Date In Arrears input
					value from base to calculator ele.
14th Aug 1996	hparicha	40.15	New variable for l_upgrade_mode.
					This var defaults to No.  It is
					only used when running the package
					in upgrade mode.  Upgrade mode is
					inferred when base element already
					exists.  When upgrade mode is Yes, the
					new API for adding an input value
					over the lifetime of an element type
					will be called.  This new api will
					then create all link_input_value,
					element_entry_value, and
					run_result_value records as needed.
17th Sep 1996	hparicha	40.16	374391. Adding input values for
					monthly cap processing on support
					orders.
20th Sep 1996	hparicha	40.17	Upgrade mode now set based on
					UPPER of element name comparison.
3rd Oct 1996	hparicha	40.18	398791. Added param to existence
					functions (pytmplex.pkb) for an
					effective date to be used in
					existence comparisons.
5th Nov 1996	hparicha	40.19	413211. Updated deletion procedure
					with respect to latest configuration.
7th Nov 1996	hparicha	40.20	413211 - again...deletion procedure needs to
				        cleanup OLD formulae creating during upgrades.

10th July 1997  mmukherj   40.21     502307   Updated do_defined_balances
                                              procedure.Included business_group_id
                                              in where condition while checking
                                              pay_defined_balnce has already exist
                                              for that balance_name for that busines_
                                              group_id or not
21st July 1997  mmukherj   40.22              Put Version No in the comment above (
				              10th July 1997) and added  comment to
				              do_defined_balance procedure.
				              Changed the select statement of the
				              same proceduerto avoid using index on
				              business_group_id.

7th Nov 1997    rpanchap   40.23     459552   Updated the function create_garnishment
                                              to Populate the text table, garn_base_iv_names,
                                              based on 2 categories (Support and
                                              the rest of the categories grouped as one)

9th Jan 1998    mmukherj   40.24     566328   delete_dedn procedure is modified to include
				              business_group_id in one a select(without cursor)
				              statement, which was selecting more than one row
			                      for a given element_name.

14th Jul 1998	 ssarma	   40.25     625442   Fee indirect result from calculator
					      formula now feeds the fee element
					      instead of the verifier element
					      incase of non-support invlountary
					      deductions.

03rd Nov 1998   ssarma	   40.26     658479   Added run result Calc_Subprio to all associated
				              elements so that subpriority can be processed.
              				      Changed the processing priority of all Garnishment
	                    		      elements so that CS/AY/SS and TL process at the
		                              highest priority based on date served. followed by
			                      BO,CD/G,EL and ER.

01 Dec 1998	ssarma	   40.27     658479   Changed priority for Tax levy
	              			      calculation element to be equal to that of support
		              		      calculator elements. Added formula result rules
			              	      of Garn_fee in calculator. Added Diff_dedn_amt
              				      and Diff_fee_amt formula result rules to verifier
	              			      element. Added delete stmt to delete formula
		              		      result rules from pay_formula_result_rules_f
			              	      so that no unnecessary result rules are hanging !

04 Dec 1998 ssarma	   40.28     774717   Added back dedn at time of writ
					      to the tax levy element.

11 Dec 1998 ssarma    40.29     771631   Changed the processing priority of the tax
                                         calculator element to be equal with the support
                                         verifier element.

08-FEB-1999 ssarma    40.36              Max Per Period input value added in the base element
                                         and corresponging input values/FRR to indirect elmt.

05-MAR-1999 ahanda    40.37              Added dimension for assignment Inception to Date.
                                         Also changed the priority for Special Inputs for
                                         garnishment and edu. loan to process before
                                         base element.

23-SEP-1999 ssarma    40.39              Made change from = to like for old formula
                                         select statement.
21-APR-2000 fusman    40.43              New PTD Fee Balance,Month Fee Balance and
                                         Accrued Fee Balance are created.
                                         For Garnishment: Acc_Fee=>Garn.Cal=>
                                         Spl.Fee. PTD,Month=>Calculator
                                         For Child.Supp
                                         Acc_Fee=>Chi.Sup.Cal=>Prio=>Verif=>
                                         Spl.Features PTD,Month=>Chi.Sup.Cal
                                         =>Prio=>Verif.
21-APR-2000 fusman    40.44              Changed the suffixes from database_item
                                         _suffixes to dimension names as names
                                         have index which will speed up
                                         the process when creating the balances.
24-APR-2000 fusman    40.45              Corrected the Dimension name
                                         Assignment-Level Current Run.
24-APR-2000 fusman    40.46              Removed the balances PTD and Month since
                                         only Accrued balance is used in two
                                         dimensions
03-MAY-2000 fusman    115.17             Changed the dates to fnd.canonical format.
24-Oct-2000 fusman    115.18             New dimensions PTD,ITD and Month has been
                                         included.
27-Dec-2000 fusman    115.19  1348004    Changed the priority of EL same as G,CD.
                              1498260    Added date check in the select stmt
                                         of input_value_id
03-Jan-2001 fusman    115.20             Added Compile_flag 'N' for Old formulas.
22-JAN-2002 ahanda    115.21             Added creation of _ASG_PAYMENTS defined
                                         balance ID.
19-Jul-2002 ekim      115.23             Added balance feed to 'Child Supp Total
                                         Amount' for bug 2374248.
21-Aug-2002 ekim      115.24             Chaged the formula result rule of the
                                         Calculator element.  The result of
                                         to_addl, and to_repl should feed Special
                                         Features element not Special Inputs
                                         element.
22-Aug-2002 ekim      115.25  2527761    Commented update of element_information12
                                         and element_information13 to keep bug
                                         980683 fix and remove setting not_taken
                                         to 0 in the calculator formula
                                         pyusgarnfedlycal.hdt for other wage attach
                                         and verifier formula pyusgarnchsupver
                                         for support.

                                         Added following balances for Special
                                         Features element with IV of Not Taken
                                         will feed to this balance.
                                           Support Not Taken Amount
                                           Other Garn Not Taken Amount
12-sep-2002 ekim      115.27              Removed elisa from trace message.
08-Oct-2002 ekim      115.28 2603525   Changed UOM to pass lookup code
                                       instead of meaning. (ex.M not Money)
                                       Changed to use p_uom_code to call
                                       pay_db_pay_setup.create_input_value
                                       and create_balance_type instead
                                       of p_uom.
10-Oct-2002 ekim      115.29           Removed default value from delete_dedn
                                       for GSCC warning.
07-Jan-2003 ekim      115.30           Made performance change for the query
                                       which gets l_count_already.
                                       Bug 2721714.
01-APR-2003 ahanda    115.31           Fixed the issue with the select stmt
                                       changed for bug 2721714.
01-APR-2003 ahanda    115.32           Changed the defined balance creation call
                                       to store _ASG_GRE_RUN as run balance.
26-JUN-2003 ahanda    115.33           Changed call to create_balance_type procedure
                                       to pass the balance name
                                       Added code to populate 'After-Tax Deductions'
                                       category for balances
18-MAR-2004 kvsankar  115.34  3311781  Changed call to create_balance_type procedure
                                       to pass the balance category as
                                       'Involuntary Deductions' instead of
                                       'After-Tax Deductions'.
09-JUN-2004 kvsankar  115.35  3622290   Changed the delete_dedn procedure to
                                        delete the elements based on the new
                                        architecture for Involuntary deductions
                                        element. The procedure does delete
                                        elements created using the old
                                        architecture.
17-JUN-2004 kvsankar  115.36  3682501   Added code for deleting the template
                                        created while creating an Involuntary
                                        Deduction element in the new
                                        architecture. Also modified the
                                        delete_dedn procedure to take into
                                        account 'Arrears' and 'Not Taken'
                                        balances for deletion.
18-AUG-2004 sdhole    115.37 3651755    Removed the balance category for the
                                        following balances Additional, Replacement
                                        Accrued Fees, Vol Dedns.
30-JAN-2006 kvsankar  115.38 4680388    Modified the delete_dedn procedure
                                        to use delete_user_structure for
                                        deleting elements created using
                                        template engine
***************************************************************************/

FUNCTION create_garnishment (
	p_garn_name		IN VARCHAR2,
	p_garn_reporting_name	IN VARCHAR2,
	p_garn_description	IN VARCHAR2,
	p_category		IN VARCHAR2,
	p_bg_id			IN NUMBER,
	p_ele_eff_start_date	IN DATE) RETURN NUMBER IS

  c_end_of_time  CONSTANT DATE := fnd_date.canonical_to_date('4712/12/31 00:00:00');

  TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE num_table IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;

  garn_ele_names	 text_table;
  garn_ele_repnames	 text_table;
  garn_ele_proc_type	 text_table;
  garn_ele_desc		 text_table;
  garn_ele_priority	 num_table;
  garn_indirect_only	 text_table;
  garn_mix_category	 text_table;
  garn_pay_formula	 text_table;
  garn_ele_ids		 num_table;
  garn_statproc_rule_id	 num_table;
  garn_third_party_pay   text_table;
  garn_payval_id	 num_table;

  garn_base_frr_name	 text_table;
  garn_base_frr_type	 text_table;
  garn_base_frr_ele_id	 num_table;
  garn_base_frr_iv_id	 num_table;
  garn_base_frr_severity text_table;

  garn_calc_frr_name	 text_table;
  garn_calc_frr_type	 text_table;
  garn_calc_frr_ele_id	 num_table;
  garn_calc_frr_iv_id	 num_table;
  garn_calc_frr_severity text_table;

  garn_verif_frr_name	  text_table;
  garn_verif_frr_type	  text_table;
  garn_verif_frr_ele_id	  num_table;
  garn_verif_frr_iv_id	  num_table;
  garn_verif_frr_severity text_table;

  garn_si_frr_name	 text_table;
  garn_si_frr_type	 text_table;
  garn_si_frr_ele_id	 num_table;
  garn_si_frr_iv_id	 num_table;
  garn_si_frr_severity	 text_table;

  garn_sf_frr_name	 text_table;
  garn_sf_frr_type	 text_table;
  garn_sf_frr_ele_id	 num_table;
  garn_sf_frr_iv_id	 num_table;
  garn_sf_frr_severity	 text_table;

  garn_vp_frr_name	 text_table;
  garn_vp_frr_type	 text_table;
  garn_vp_frr_ele_id	 num_table;
  garn_vp_frr_iv_id	 num_table;
  garn_vp_frr_severity	 text_table;

  garn_base_feed_iv_id		num_table;
  garn_base_feed_bal_id		num_table;

  garn_calc_feed_iv_id		num_table;
  garn_calc_feed_bal_id		num_table;

  garn_verif_feed_iv_id		num_table;
  garn_verif_feed_bal_id	num_table;

  garn_si_feed_iv_id		num_table;
  garn_si_feed_bal_id		num_table;

  garn_sf_feed_iv_id		num_table;
  garn_sf_feed_bal_id		num_table;

  garn_fee_feed_iv_id		num_table;
  garn_fee_feed_bal_id		num_table;

  garn_vp_feed_iv_id		num_table;
  garn_vp_feed_bal_id		num_table;

  l_num_base_resrules	number;
  l_num_calc_resrules	number;
  l_num_verif_resrules	number;
  l_num_si_resrules	number;
  l_num_sf_resrules	number;
  l_num_vp_resrules     number;

  l_num_base_feeds	number;
  l_num_calc_feeds	number;
  l_num_verif_feeds	number;
  l_num_si_feeds	number;
  l_num_sf_feeds	number;
  l_num_fee_feeds	number;
  l_num_vp_feeds	number;

  garn_assoc_bal_names	text_table;
  garn_assoc_bal_ids	num_table;

  garn_base_iv_names	text_table;
  garn_base_iv_seq	num_table;
  garn_base_iv_mand	text_table;
  garn_base_iv_uom	text_table;
  garn_base_iv_dbi	text_table;
  garn_base_iv_lkp	text_table;
  garn_base_iv_dflt	text_table;
  garn_base_iv_ids	num_table;

  garn_calc_iv_names	text_table;
  garn_calc_iv_seq	num_table;
  garn_calc_iv_mand	text_table;
  garn_calc_iv_uom	text_table;
  garn_calc_iv_dbi	text_table;
  garn_calc_iv_lkp	text_table;
  garn_calc_iv_dflt	text_table;
  garn_calc_iv_ids	num_table;

  garn_calc_payval_id	number(9);

  garn_verif_iv_names	text_table;
  garn_verif_iv_seq	num_table;
  garn_verif_iv_mand	text_table;
  garn_verif_iv_uom	text_table;
  garn_verif_iv_dbi	text_table;
  garn_verif_iv_lkp	text_table;
  garn_verif_iv_dflt	text_table;
  garn_verif_iv_ids	num_table;

  garn_si_iv_names	text_table;
  garn_si_iv_seq	num_table;
  garn_si_iv_mand	text_table;
  garn_si_iv_uom	text_table;
  garn_si_iv_dbi	text_table;
  garn_si_iv_lkp	text_table;
  garn_si_iv_dflt	text_table;
  garn_si_iv_ids	num_table;

  garn_sf_iv_names	text_table;
  garn_sf_iv_seq	num_table;
  garn_sf_iv_mand	text_table;
  garn_sf_iv_uom	text_table;
  garn_sf_iv_dbi	text_table;
  garn_sf_iv_lkp	text_table;
  garn_sf_iv_dflt	text_table;
  garn_sf_iv_ids	num_table;

  garn_fee_iv_names	text_table;
  garn_fee_iv_seq	num_table;
  garn_fee_iv_mand	text_table;
  garn_fee_iv_uom	text_table;
  garn_fee_iv_dbi	text_table;
  garn_fee_iv_lkp	text_table;
  garn_fee_iv_dflt	text_table;
  garn_fee_iv_ids	num_table;

  garn_vp_iv_names	text_table;
  garn_vp_iv_seq	num_table;
  garn_vp_iv_mand	text_table;
  garn_vp_iv_uom	text_table;
  garn_vp_iv_dbi	text_table;
  garn_vp_iv_lkp	text_table;
  garn_vp_iv_dflt	text_table;
  garn_vp_iv_ids	num_table;

  l_num_eles		number;
  l_num_assoc_bals	number;

  l_num_base_ivs  number;
  l_num_calc_ivs	number;
  l_num_verif_ivs	number;
  l_num_si_ivs		number;
  l_num_sf_ivs		number;
  l_num_fee_ivs		number;
  l_num_vp_ivs          number;

  lfee			number;
  nfee			number;
  i			number;
  k			number;
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

  already_exists	number;

  -- Other various local vars

  l_base_ele_id			NUMBER(9);
  v_bg_name			VARCHAR2(80);
  v_bal_type_id			NUMBER(9);
  v_ele_type_id			NUMBER(9);
  v_inpval_id			NUMBER(9);
  v_pay_value_name		VARCHAR2(80);
  v_payval_id			NUMBER(9);
  v_calc_formula_id		NUMBER(9);
  v_stat_proc_rule_id		NUMBER(9);
  v_spr_formula_id		NUMBER(9);
  v_fres_rule_id			NUMBER(9);
  v_frr_ele_id			NUMBER(9);
  v_frr_iv_id			NUMBER(9);

  v_ff_text			VARCHAR2(32000);
  v_balstp_ff_name		VARCHAR2(80);

  g_childsupp_count_balance_id	  NUMBER(9);
  g_total_dedns_balance_id        NUMBER(9);
  g_total_amount_balance_id       NUMBER(9);
  g_total_fees_balance_id	  NUMBER(9);
  g_supp_not_taken_bal_id         NUMBER(9);
  g_other_not_taken_bal_id        NUMBER(9);

  g_voldedns_balance_id		NUMBER(9);

  g_net_balance_id		number(9);
  g_payments_balance_id	number(9);

/* 365745, 378699 */
  g_wh_support_balance_id	number(9);
  g_wh_fee_balance_id	number(9);
  g_tax_levies_balance_id	number(9);
  g_wh_supp_over_flow_balance_id number(9);

  g_ele_classification 		VARCHAR2(30)	:= 'INVOLUNTARY DEDUCTIONS';
  g_ele_info_cat 		VARCHAR2(30)	:= 'US_INVOLUNTARY DEDUCTIONS';
  g_ele_standard_link		VARCHAR2(1)	:= 'N';
  g_ele_priority		NUMBER(9);
  g_ele_class_id		NUMBER(9);
  g_skip_formula_id		NUMBER(9);
  g_partial_dedn		VARCHAR2(30)	:= 'Y';
  g_ele_runtype			VARCHAR2(30)	:= 'REG';
                                -- was 'ALL', but now freq rules are allowed...
  g_mix_category		VARCHAR2(30)	:= 'D';

  g_asst_status_type_id		NUMBER(9)	:= NULL;
  g_proc_rule			VARCHAR2(1)	:= 'P';

  g_eff_start_date		DATE;
  g_eff_end_date		DATE		:= c_end_of_time;

  l_involbal_id			number(9);
  l_invol_scale			number(5);

  l_upgrade_mode	varchar2(1) := 'N';

cursor get_invol_bals is
select	bt.balance_type_id,
	bc.scale
from	pay_balance_types	bt,
	pay_balance_classifications bc,
	pay_element_classifications ec
where	bt.balance_type_id = bc.balance_type_id
and	bc.classification_id = ec.classification_id
and       nvl(bc.business_group_id, p_bg_id) + 0  = p_bg_id
and	ec.classification_name = 'Involuntary Deductions'
and	ec.legislation_code = 'US'
order by bt.balance_name;

--
---------------------------- ins_garn_ele_type -------------------------------
--
FUNCTION ins_garn_ele_type (	p_ele_name 		in varchar2,
				p_ele_reporting_name 	in varchar2,
				p_ele_description 	in varchar2,
				p_ele_class 		in varchar2,
				p_ele_category 		in varchar2,
				p_ele_processing_type 	in varchar2,
				p_ele_priority 		in number,
				p_ele_standard_link 	in varchar2,
				p_skip_formula_id	in number default NULL,
				p_ind_only_flag		in varchar2,
				p_third_party_pay	in varchar2,
				p_ele_eff_start_date	in date,
				p_ele_eff_end_date	in date,
				p_bg_name		in varchar2,
				p_bg_id			in number)
RETURN number IS
-- local vars
ret			NUMBER;
v_mult_entries_allowed	VARCHAR2(1);
l_ele_priority          NUMBER;

g_third_ppm		VARCHAR2(30)	:= 'N';

already_exists		number;

BEGIN

--

IF p_ele_processing_type = 'N' THEN

  v_mult_entries_allowed := 'Y';

ELSE

  v_mult_entries_allowed := 'N';

END IF;

already_exists := hr_template_existence.ele_exists(
				p_ele_name	=> p_ele_name,
				p_bg_id		=> p_bg_id,
				p_eff_date	=> p_ele_eff_start_date);

if already_exists = 0 then

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
			p_third_party_pay_only	=> p_third_party_pay);

else

   if upper(p_ele_name) = upper(garn_ele_names(1)) then

-- Base element already exists, this MUST be called via upgrade mechanism.
-- Set upgrade mode flag for addition of input values, link input values, entry values,
-- and run result values.

     l_upgrade_mode := 'Y';
     hr_utility.trace('UPGRADE MODE = YES');

   end if;

  ret := already_exists;

  /* Updating the processing priority of the elements */

     update pay_element_types_f
     set processing_priority = p_ele_priority
     where element_type_id = ret
     and business_group_id + 0 = p_bg_id;

end if;

RETURN ret;
--
END ins_garn_ele_type;
--

PROCEDURE do_defined_balances (	p_bal_id  	 IN NUMBER,
                                p_bal_name       IN VARCHAR2,
                                p_bg_name        IN VARCHAR2,
				p_no_payments	 IN BOOLEAN default FALSE,
                                p_save_run_value IN VARCHAR2 default 'N') IS

-- local vars

TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  suffixes	text_table;
  x_dimension_name text_table;
  dim_id	number(9);
  dim_name	varchar2(80);
  num_suffixes  number;

  already_exists number;
  v_business_group_id number;

BEGIN

suffixes(1)         := '_ASG_RUN';
x_dimension_name(1) := 'Assignment-Level Current Run';

suffixes(2)         := '_ASG_PTD';
x_dimension_name(2) := 'Assignment Period to Date';

suffixes(3)         := '_ASG_MONTH';
x_dimension_name(3) := 'Assignment Month';

suffixes(4)         := '_ASG_QTD';
x_dimension_name(4) := 'Assignment Quarter to Date';

suffixes(5)         := '_ASG_YTD';
x_dimension_name(5) := 'Assignment Year to Date';

suffixes(6)         := '_ASG_GRE_RUN';
x_dimension_name(6) := 'Assignment within Government Reporting Entity Run';

suffixes(7)         := '_ASG_GRE_PTD';
x_dimension_name(7) := 'Assignment within Government Reporting Entity Period to Date';

suffixes(8)         := '_ASG_GRE_MONTH';
x_dimension_name(8) := 'Assignment within Government Reporting Entity Month';

suffixes(9)         := '_ASG_GRE_QTD';
x_dimension_name(9) := 'Assignment within Government Reporting Entity Quarter to Date';

suffixes(10)         := '_ASG_GRE_YTD';
x_dimension_name(10) := 'Assignment within Government Reporting Entity Year to Date';

suffixes(11)         := '_PER_RUN';
x_dimension_name(11) := 'Person Run';

suffixes(12)         := '_PER_MONTH';
x_dimension_name(12) := 'Person Month';

suffixes(13)         := '_PER_QTD';
x_dimension_name(13) := 'Person Quarter to Date';

suffixes(14)         := '_PER_YTD';
x_dimension_name(14) := 'Person Year to Date';

suffixes(15)         := '_PER_GRE_RUN';
x_dimension_name(15) := 'Person within Government Reporting Entity Run';

suffixes(16)         := '_PER_GRE_MONTH';
x_dimension_name(16) := 'Person within Government Reporting Entity Month';

suffixes(17)         := '_PER_GRE_QTD';
x_dimension_name(17) := 'Person within Government Reporting Entity Quarter to Date';

suffixes(18)         := '_PER_GRE_YTD';
x_dimension_name(18) := 'Person within Government Reporting Entity Year to Date';

suffixes(19)         := '_PAYMENTS';
x_dimension_name(19) := 'Payments';

suffixes(20)         := '_ASG_GRE_LTD';
x_dimension_name(20) := 'Assignment within Government Reporting Entity Lifetime to Date';

suffixes(21)         := '_ASG_LTD';
x_dimension_name(21) := 'Assignment Lifetime to Date';

suffixes(22)         := '_PER_GRE_LTD';
x_dimension_name(22) := 'Person within Government Reporting Entity Lifetime to Date';

suffixes(23)         := '_PER_LTD';
x_dimension_name(23) := 'Person Lifetime to Date';

/* WWBug 133133 start */
/* Add defbals required for company level, summary reporting. */
suffixes(24)         := '_GRE_RUN';
x_dimension_name(24) := 'Government Reporting Entity Run';

suffixes(25)         := '_GRE_YTD';
x_dimension_name(25) := 'Government Reporting Entity Year to Date';

suffixes(26)         := '_GRE_ITD';
x_dimension_name(26) := 'Government Reporting Entity Inception To Date';


/* WWBug 350540 start */
/* Need defbals on arrears bal for ASG_GRE_ITD and GRE_ITD. */
suffixes(27)         := '_ASG_GRE_ITD';
x_dimension_name(27) := 'Assignment within Government Reporting Entity Inception To Date';

/* Changed GRE_ITD to ASG_ITD as GRE_ITD is already there in
   suffixes(26) and ASG_ITD is missing. Bug 820068 */

suffixes(28)         := '_ASG_ITD';
x_dimension_name(28) := 'Assignment Inception To Date';

suffixes(29)         := '_ENTRY_ITD';
x_dimension_name(29) := 'US Element Entry Inception to Date';

suffixes(30)         := '_ENTRY_MONTH';
x_dimension_name(30) := 'US Element Entry Month';

suffixes(31)         := '_ENTRY_PTD';
x_dimension_name(31) := 'US Element Entry Period to Date';

suffixes(32)         := '_ASG_PAYMENTS';
x_dimension_name(32) := 'Assignment Payments';

num_suffixes := 32;

/* WWBug 133133, 350540 finish */

    hr_utility.trace('In do_defined_balances');
    for i in 1..num_suffixes loop

      select dimension_name, balance_dimension_id
      into dim_name, dim_id
      from pay_balance_dimensions
      where dimension_name = x_dimension_name(i)
      and legislation_code = g_template_leg_code;
      -- and business_group_id IS NULL;

/* added line to include business_group_id in the where clause of the select
statement below. So that it checkes the existence of data for a the given
business_group_id Bug No: 502307.
*/
      hr_utility.trace('Defined Balance for '||p_bal_name||suffixes(i));
      SELECT  count(0)
        INTO  already_exists
        FROM  pay_defined_balances db
       WHERE  db.balance_type_id       = p_bal_id
         AND  db.balance_dimension_id  = dim_id
         AND  db.business_group_id + 0 = p_bg_id;

     if (already_exists = 0) then

        IF p_no_payments = TRUE and suffixes(i) = '_PAYMENTS' THEN
           NULL;
        ELSE
          IF p_save_run_value = 'Y' THEN
             IF suffixes(i) = '_ASG_GRE_RUN' THEN
                pay_db_pay_setup.create_defined_balance(
		      p_balance_name        => p_bal_name,
		      p_balance_dimension   => dim_name,
		      p_business_group_name => p_bg_name,
		      p_legislation_code    => NULL,
                      p_save_run_bal        => p_save_run_value);
             ELSE
                pay_db_pay_setup.create_defined_balance(
                      p_balance_name        => p_bal_name,
                      p_balance_dimension   => dim_name,
                      p_business_group_name => p_bg_name,
                      p_legislation_code    => NULL);
             END IF;

          ELSE
             pay_db_pay_setup.create_defined_balance(
                 p_balance_name        => p_bal_name,
                 p_balance_dimension   => dim_name,
                 p_business_group_name => p_bg_name,
                 p_legislation_code    => NULL);

          END IF;
      END IF;

     end if;

    end loop;
    hr_utility.trace('Out of do_defined_balances');
END do_defined_balances;
--
------------------------- ins_formula -----------------------
--
FUNCTION ins_formula (	p_ff_ele_name		in varchar2,
			p_ff_bg_id		in number)
RETURN varchar2 IS
-- local vars
v_formula_id	number;
--
v_skeleton_formula_text		VARCHAR2(32000);
v_skeleton_formula_type_id	NUMBER(9);
v_ele_formula_text		VARCHAR2(32000);
v_ele_formula_name		VARCHAR2(80); -- Return variable
v_ele_formula_id			NUMBER(9);
v_ele_name			VARCHAR2(80);

v_ff_desc			varchar2(80);

v_orig_ele_formula_id		NUMBER(9);
v_orig_ele_formula_name	VARCHAR2(80);
v_orig_ele_formula_text		varchar2(32000);
v_new_ele_formula_id		NUMBER(9);
v_new_ele_formula_name	VARCHAR2(80);
v_new_ele_formula_text		VARCHAR2(32000);

already_exists			number;
l_count_already			number;

BEGIN

-- Enhance this function to preserve original formula text...

  SELECT 	FF.formula_text,
		FF.formula_type_id
  INTO		v_skeleton_formula_text,
		v_skeleton_formula_type_id
  FROM		ff_formulas_f	FF
  WHERE		FF.formula_name		= 'BALANCE_SETUP_FORMULA'
  AND		FF.business_group_id 	IS NULL
  AND		FF.legislation_code	= 'US'
  AND		g_eff_start_date 	>= FF.effective_start_date
  AND		g_eff_start_date	<= FF.effective_end_date;

-- Replace element name placeholders with current element name:

  v_ele_name := REPLACE(LTRIM(RTRIM(UPPER(p_ff_ele_name))),' ','_');

  v_new_ele_formula_text := REPLACE(	v_skeleton_formula_text,
				 	'<ELE_NAME>',
					v_ele_name);


  v_new_ele_formula_name := UPPER(v_ele_name || '_BALANCE_SETUP_FORMULA');
  v_new_ele_formula_name := SUBSTR(v_new_ele_formula_name, 1, 80);

  v_ff_desc := 'Formula used to access element specific balances.';

-- Call function to check existence of formula to get id.
-- Get original formula id, name, and text for this element currently,
-- ie. before putting in new ff text.

hr_utility.set_location('hr_us_garn_gen.ins_formula',20);

already_exists := hr_template_existence.ele_ff_exists(
				p_ele_name	=> p_ff_ele_name,
				p_bg_id		=> p_ff_bg_id,
				p_ff_name	=> v_orig_ele_formula_name,
				p_ff_text	=> v_orig_ele_formula_text,
				p_eff_date	=> g_eff_start_date);

if already_exists = 0 then

-- Insert the new formula text into current business group since
-- there is no formula for this element currently.
--
-- Get new id for formula

  SELECT 	ff_formulas_s.nextval
  INTO		v_new_ele_formula_id
  FROM	 	sys.dual;

--
-- Insert the new formula into current business group:
--
  hr_utility.set_location('hr_us_garn_gen.ins_formula',40);
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
 	v_new_ele_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_ff_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_new_ele_formula_name,
	v_ff_desc,
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

    hr_utility.set_location('hr_us_garn_gen.ins_formula',50);

    v_new_ele_formula_id := already_exists;
    v_new_ele_formula_name := v_orig_ele_formula_name;

-- Update existing formula with new ff name and text.

--  dbms_output.put_line('existing FF '||v_new_ele_formula_id||' being updated');
--  dbms_output.put_line(v_new_ele_formula_name);

   hr_utility.set_location('hr_us_garn_gen.ins_formula',70);

    UPDATE	ff_formulas_f
    SET		formula_text	= v_new_ele_formula_text
    WHERE	formula_id	= v_new_ele_formula_id
    AND		business_group_id+0 = p_ff_bg_id
    AND		g_eff_start_date BETWEEN effective_start_date
                                     AND effective_end_date;

--
-- Insert the original formula into current business group to preserve customer mods.
--
hr_utility.trace('FF '||v_orig_ele_formula_name||' already exists for ele '||p_ff_ele_name);

select count(0)
into l_count_already
from ff_formulas_f fff, ff_formula_types ffft
where (upper(formula_name) like upper('OLD%_'||v_orig_ele_formula_name) or
         upper(formula_name) like upper(v_orig_ele_formula_name) or
         upper(formula_name) like upper('%'||v_orig_ele_formula_name)||'_EXP' or
        upper(formula_name) like upper('%'||v_orig_ele_formula_name)||'_OLD%' )
and   business_group_id+0 = p_ff_bg_id
and fff.legislation_code = 'US'
and ffft.formula_type_name = 'Oracle Payroll'
and ffft.formula_type_id = fff.formula_type_id;

hr_utility.set_location('hr_us_garn_gen.ins_formula',35);

hr_utility.trace('Preserving text for formula '||v_orig_ele_formula_name ||
                 ' for BG ' || p_ff_bg_id);

  v_orig_ele_formula_name := 'OLD'||l_count_already||'_'||v_orig_ele_formula_name;
  v_orig_ele_formula_name := substr(v_orig_ele_formula_name,1,80);

hr_utility.trace('Text saved in formula named '||v_orig_ele_formula_name);

  hr_utility.set_location('hr_us_garn_gen.ins_formula',30);

  SELECT 	ff_formulas_s.nextval
  INTO		v_orig_ele_formula_id
  FROM	 	sys.dual;

  hr_utility.set_location('hr_us_garn_gen.ins_formula',40);

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
				CREATION_DATE,
                                COMPILE_FLAG)
values (
 	v_orig_ele_formula_id,
 	g_eff_start_date,
	g_eff_end_date,
	p_ff_bg_id,
	NULL,
	v_skeleton_formula_type_id,
	v_orig_ele_formula_name,
	v_ff_desc,
	v_orig_ele_formula_text,
	'N',
	NULL,
	NULL,
	NULL,
	-1,
	g_eff_start_date,
        'N');

end if;

RETURN v_new_ele_formula_name;

END ins_formula;

--
-- Create Garnishment MAIN
--

BEGIN
        -- hr_utility.trace_on(null,'ORACLE');
 begin

  select	name
  into		v_bg_name
  from 		per_business_groups
  where		business_group_id + 0 = p_bg_id;
 exception WHEN NO_DATA_FOUND THEN
    v_bg_name := NULL;
    hr_utility.set_location('Could not find ''BG NAME'' ', 999);
 end;

  g_eff_start_date	:= nvl(p_ele_eff_start_date, sysdate);

 begin
  select classification_id,
	 default_priority
  into   g_ele_class_id,
	 g_ele_priority
  from   pay_element_classifications
  where  UPPER(classification_name) = g_ele_classification
  and legislation_code = 'US';
 exception WHEN NO_DATA_FOUND THEN
   hr_utility.set_location('Could not find ''CLASSIFICATION'' ', 999);
 end;

  -- Need skip rule formula
 begin
  SELECT	FF.formula_id
  INTO		g_skip_formula_id
  FROM		ff_formulas_f FF
  WHERE	FF.formula_name 	= 'WAT_SKIP'
  AND		FF.business_group_id 	IS NULL
  AND    legislation_code =  'US'
  AND 		p_ele_eff_start_date    >= FF.effective_start_date
  AND 		p_ele_eff_start_date	<= FF.effective_end_date;
 exception WHEN NO_DATA_FOUND THEN
   hr_utility.set_location('Could not find ''SKIP RULE'' ', 999);
 end;
  -- Get voluntary deductions high level balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO	g_voldedns_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Voluntary Deductions'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_voldedns_balance_id := NULL;

    hr_utility.set_location('Could not find ''Voluntary Deductions'' balance', 999);

   end;

-- 374743 : Spousal support and alimony are treated same as child support.
  IF p_category NOT IN ('CS', 'SS', 'AY') THEN

  -- Get wage attach "total dedns" balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO 	g_total_dedns_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Garn Total Dedns'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_total_dedns_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Dedns'' balance', 999);

   end;

  -- Get garnishment "total fees" balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO 	g_total_fees_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Garn Total Fees'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_total_fees_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Fees'' balance', 999);

   end;

 -- Get Other Garn Not Taken Amount  balance for future ref.

  begin

   SELECT      balance_type_id
    INTO        g_other_not_taken_bal_id
    FROM        pay_balance_types
    WHERE       balance_name = 'Other Garn Not Taken Amount'
    AND         business_group_id IS NULL
    AND         legislation_code = 'US';

   hr_utility.trace('g_other_not_taken_bal_id = '||to_char(g_other_not_taken_bal_id));

   exception WHEN NO_DATA_FOUND THEN

    g_other_not_taken_bal_id := NULL;

    hr_utility.set_location('Could not find ''Other Wage Attach Not Taken Amount'' balance'
, 999);

   end;


/* 365745 fixes begin */
   if p_category = 'TL' then

-- Get wage attach "tax levies" balance for future ref.

     begin

     SELECT 	balance_type_id
     INTO	g_tax_levies_balance_id
     FROM	pay_balance_types
     WHERE 	balance_name = 'Tax Levies'
     AND	business_group_id IS NULL
     AND	legislation_code = 'US';

     exception WHEN NO_DATA_FOUND THEN

      g_tax_levies_balance_id := NULL;

      hr_utility.set_location('Could not find ''Tax Levies'' balance', 999);

     end;

   end if;
/* 365745 fixes end */

  ELSE

  -- Get child support "count" balance for future ref.
  -- Child Support, Spousal Support and Alimony are all
  -- treated as "support" (374743).

   begin

    SELECT 	balance_type_id
    INTO	g_childsupp_count_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Child Supp Count'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_childsupp_count_balance_id := NULL;

    hr_utility.set_location('Could not find ''Count'' balance', 999);

   end;

  -- Get child support "total dedns" balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO	g_total_dedns_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Child Supp Total Dedns'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_total_dedns_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Dedns'' balance', 999);

   end;

  -- Get child support "total amount" balance for future ref.

  begin

   SELECT      balance_type_id
    INTO        g_total_amount_balance_id
    FROM        pay_balance_types
    WHERE       balance_name = 'Child Supp Total Amount'
    AND         business_group_id IS NULL
    AND         legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_total_amount_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Amount'' balance', 999);

   end;

  -- Get support not taken amount  balance for future ref.

  begin

   SELECT      balance_type_id
    INTO        g_supp_not_taken_bal_id
    FROM        pay_balance_types
    WHERE       balance_name = 'Support Not Taken Amount'
    AND         business_group_id IS NULL
    AND         legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_supp_not_taken_bal_id := NULL;

    hr_utility.set_location('Could not find ''Support Not Taken Amount'' balance', 999);

   end;


  -- Get child support "total fees" balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO	g_total_fees_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Child Supp Total Fees'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_total_fees_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Fees'' balance', 999);

   end;

/* 378699 fixes begin */
  -- Get wage attach "total adjusted support" balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO 	g_wh_support_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Total Withheld Support'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_wh_support_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Withheld Support'' balance', 999);

   end;

  -- Get wage attach "total adjusted support" balance for future ref.

   begin

    SELECT 	balance_type_id
    INTO 	g_wh_fee_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Total Withheld Fee'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_wh_fee_balance_id := NULL;

    hr_utility.set_location('Could not find ''Total Withheld Fee'' balance', 999);

   end;
/* 378699 fixes end */

  END IF;

begin

    SELECT 	balance_type_id
    INTO 	g_net_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Net'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

    SELECT 	balance_type_id
    INTO 	g_payments_balance_id
    FROM	pay_balance_types
    WHERE 	balance_name = 'Payments'
    AND		business_group_id IS NULL
    AND		legislation_code = 'US';

   exception WHEN NO_DATA_FOUND THEN

    g_net_balance_id := NULL;
    g_payments_balance_id := null;

    hr_utility.set_location('MAJOR ERROR: Net or Payments STU balance not found', 999);

   end;

  -- Setup all configuration param settings based on category:


  -- Element and payroll formula parameter settings:
  garn_ele_names(1)	:= p_garn_name;
  garn_ele_repnames(1)	:= p_garn_reporting_name;
  garn_ele_proc_type(1)	:= 'R';
  garn_ele_desc(1)	:= p_garn_description;

  IF p_category IN ('CS','AY','SS','TL') THEN
  garn_ele_priority(1)	:= g_ele_priority;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(1)  := g_ele_priority + 7;
  ELSIF p_category IN ('CD','G') THEN
  garn_ele_priority(1)  := g_ele_priority + 11;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(1)  := g_ele_priority + 11; /*bug:1348004*/
  ELSE
  garn_ele_priority(1)  := g_ele_priority + 22;
  END IF;
  garn_indirect_only(1)	:= 'N';
  garn_mix_category(1)	:= 'D';
  garn_pay_formula(1) 	:= ins_formula(	p_ff_ele_name 	=> garn_ele_names(1),
					p_ff_bg_id	=> p_bg_id);
  garn_third_party_pay(1) := 'Y';

  garn_ele_names(2)	:= p_garn_name||' Calculator';
  garn_ele_repnames(2)	:= p_garn_reporting_name||' Calc';
  garn_ele_proc_type(2)	:= 'N';
  garn_ele_desc(2)	:= 'Generated calculation element for '||p_garn_name;
  IF p_category IN ('CS', 'SS', 'AY') THEN
  garn_ele_priority(2)	:= g_ele_priority + 1;
  ELSIF p_category = 'TL' THEN
  garn_ele_priority(2)  := g_ele_priority + 3;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(2)  := g_ele_priority + 8;
  ELSIF p_category IN  ('CD','G') THEN
  garn_ele_priority(2)  := g_ele_priority + 13;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(2)  := g_ele_priority + 13;
  ELSE
  garn_ele_priority(2)  := g_ele_priority + 23;
  END IF;
  garn_indirect_only(2)	:= 'Y';
  garn_mix_category(2)	:= NULL;
  garn_third_party_pay(2) := 'N';

  -- 374743 : Treat spousal support and alimony same as child support.
  IF p_category IN ('CS', 'SS', 'AY') THEN

    garn_pay_formula(2)	:= 'CHILD_SUPP_CALCULATION_FORMULA';

  ELSIF p_category = 'TL' THEN

    garn_pay_formula(2)	:= 'FED_LEVY_CALCULATION_FORMULA';

  ELSE

    garn_pay_formula(2)	:= 'GARN_CALCULATION_FORMULA';

  END IF;

  garn_ele_names(3)	:= p_garn_name||' Verifier';
  garn_ele_repnames(3)	:= p_garn_reporting_name||' Verify';
  garn_ele_proc_type(3)	:= 'N';
  garn_ele_desc(3)	:= 'Generated verification element for '||p_garn_name;
  IF p_category IN ('CS', 'SS', 'AY') THEN
  garn_ele_priority(3)	:= g_ele_priority + 3;
  ELSIF p_category = 'TL' THEN
  garn_ele_priority(3)  := g_ele_priority + 5;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(3)  := g_ele_priority + 10;
  ELSIF p_category IN ('CD','G') THEN
  garn_ele_priority(3)  := g_ele_priority + 15;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(3)  := g_ele_priority + 15;
  ELSE
  garn_ele_priority(3)  := g_ele_priority + 25;
  END IF;
  garn_indirect_only(3)	:= 'Y';
  garn_mix_category(3)	:= NULL;
  garn_third_party_pay(3) := 'N';

  -- 374743 : Treat spousal support and alimony same as child support.
  IF p_category IN ('CS', 'SS', 'AY') THEN

    garn_pay_formula(3)	:= 'CHILD_SUPP_VERIFICATION_FORMULA';

  ELSE

    garn_pay_formula(3)	:= NULL;

  END IF;

  garn_ele_names(4)	:= p_garn_name||' Special Inputs';
  garn_ele_repnames(4)	:= p_garn_reporting_name||' SI';
  garn_ele_proc_type(4)	:= 'N';
  garn_ele_desc(4)	:= 'Generated adjustments element for '||p_garn_name;
  IF p_category IN ('AY','CS','SS','TL') THEN
  garn_ele_priority(4)	:= g_ele_priority - 1;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(4)  := g_ele_priority + 6;
  ELSIF p_category IN ('CD','G') THEN
  garn_ele_priority(4)  := g_ele_priority + 9;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(4)  := g_ele_priority + 9;
  ELSE
  garn_ele_priority(4)  := g_ele_priority + 21;
  END IF;
  garn_indirect_only(4)	:= 'N';
  garn_mix_category(4)	:= NULL;
  garn_pay_formula(4)	:= NULL;
  garn_third_party_pay(4) := 'N';

  garn_ele_names(5)	:= p_garn_name||' Special Features';
  garn_ele_repnames(5)	:= p_garn_reporting_name||' SF';
  garn_ele_proc_type(5)	:= 'N';
  garn_ele_desc(5)	:= 'Generated results element for '||p_garn_name;
  IF p_category IN ('AY','CS','SS','TL') THEN
  garn_ele_priority(5)	:= g_ele_priority;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(5)  := g_ele_priority + 7;
  ELSIF p_category IN ('CD','G') THEN
  garn_ele_priority(5)  := g_ele_priority + 11;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(5)  := g_ele_priority + 11;
  ELSE
  garn_ele_priority(5)  := g_ele_priority + 22;
  END IF;
  garn_indirect_only(5)	:= 'Y';
  garn_mix_category(5)	:= NULL;
  garn_pay_formula(5)	:= NULL;
  garn_third_party_pay(5) := 'N';

  garn_ele_names(6)	:= p_garn_name||' Fees';
  garn_ele_repnames(6)	:= p_garn_reporting_name||' Fees';
  garn_ele_proc_type(6)	:= 'N';
  garn_ele_desc(6)	:= 'Generated Fee results element for '||p_garn_name;
  IF p_category IN ('CS', 'SS', 'AY') THEN
  garn_ele_priority(6)	:= g_ele_priority + 2;
  ELSIF p_category = 'TL' THEN
  garn_ele_priority(6)  := g_ele_priority + 4;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(6)  := g_ele_priority + 9;
  ELSIF p_category IN ('CD','G') THEN
  garn_ele_priority(6)  := g_ele_priority + 14;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(6)  := g_ele_priority + 14;
  ELSE
  garn_ele_priority(6)  := g_ele_priority + 24;
  END IF;
  garn_indirect_only(6)	:= 'Y';
  garn_mix_category(6)	:= NULL;
  garn_pay_formula(6)	:= NULL;
  garn_third_party_pay(6) := 'N';

  garn_ele_names(7)     := p_garn_name||' Priority';
  garn_ele_repnames(7)  := p_garn_reporting_name||' VP';
  garn_ele_proc_type(7) := 'N';
  garn_ele_desc(7)      := 'Generated verifier priority element for '||p_garn_name;
  IF p_category IN ('CS', 'SS', 'AY') THEN
  garn_ele_priority(7)  := g_ele_priority + 1;
  ELSIF p_category = 'TL' THEN
  garn_ele_priority(7)  := g_ele_priority + 3;
  ELSIF p_category = 'BO' THEN
  garn_ele_priority(7)  := g_ele_priority + 8;
  ELSIF p_category IN  ('CD','G') THEN
  garn_ele_priority(7)  := g_ele_priority + 13;
  ELSIF p_category = 'EL' THEN
  garn_ele_priority(7)  := g_ele_priority + 13;
  ELSE
  garn_ele_priority(7)  := g_ele_priority + 23;
  END IF;
  garn_indirect_only(7) := 'Y';
  garn_mix_category(7)  := NULL;
  garn_third_party_pay(7) := 'N';
  IF p_category IN ('CS', 'SS', 'AY') THEN
    garn_pay_formula(7)	:= 'WAGE_ATTACH_PRIORITY_FORMULA';
  ELSE
    garn_pay_formula(7)	:= NULL;
  END IF;

  l_num_eles		:= 7;

 -- Garn input value param settings:

-- Based on Category (Currently classifying it as Support Vs rest of them)
-- The following 5 iv_names are common to all categories :

  garn_base_iv_names(1)	      := 'Amount';
  garn_base_iv_seq(1)		:= 1;
  garn_base_iv_uom(1)		:= 'M';
  garn_base_iv_mand(1)		:= 'N';
  garn_base_iv_dbi(1)		:= 'N';
  garn_base_iv_lkp(1)		:= NULL;
  garn_base_iv_dflt(1)		:= NULL;

  garn_base_iv_names(2)	:= 'Percentage';
  garn_base_iv_seq(2)	:= 2;
  garn_base_iv_uom(2)	:= 'N';
  garn_base_iv_mand(2)	:= 'N';
  garn_base_iv_dbi(2)	:= 'N';
  garn_base_iv_lkp(2)	:= NULL;
  garn_base_iv_dflt(2)	:= NULL;

  garn_base_iv_names(3)		:= 'Jurisdiction';
  garn_base_iv_seq(3)		:= 3;
  garn_base_iv_uom(3)		:= 'C';
  garn_base_iv_mand(3)		:= 'N';
  garn_base_iv_dbi(3)		:= 'N';
  garn_base_iv_lkp(3)		:= NULL;
  garn_base_iv_dflt(3)		:= NULL;

  garn_base_iv_names(4)		:= 'Attachment Number';
  garn_base_iv_seq(4)		:= 4;
  garn_base_iv_uom(4)		:= 'C';
  garn_base_iv_mand(4)		:= 'N';
  garn_base_iv_dbi(4)		:= 'N';
  garn_base_iv_lkp(4)		:= NULL;
  garn_base_iv_dflt(4)		:= NULL;

  garn_base_iv_names(5)		:= 'Total Owed';
  garn_base_iv_seq(5)		:= 5;
  garn_base_iv_uom(5)		:= 'M';
  garn_base_iv_mand(5)		:= 'N';
  garn_base_iv_dbi(5)		:= 'N';
  garn_base_iv_lkp(5)		:= NULL;
  garn_base_iv_dflt(5)		:= NULL;

  garn_base_iv_names(6)		:= 'Date Served';
  garn_base_iv_seq(6)		:= 6;
  garn_base_iv_uom(6)		:= 'D';
  garn_base_iv_mand(6)		:= 'N';
  garn_base_iv_dbi(6)		:= 'N';
  garn_base_iv_lkp(6)		:= NULL;
  garn_base_iv_dflt(6)		:= NULL;

  garn_base_iv_names(7)		:= 'Max Per Period';
  garn_base_iv_seq(7)		:= 7;
  garn_base_iv_uom(7)		:= 'M';
  garn_base_iv_mand(7)		:= 'N';
  garn_base_iv_dbi(7)		:= 'N';
  garn_base_iv_lkp(7)		:= NULL;
  garn_base_iv_dflt(7)		:= NULL;

  garn_base_iv_names(8)		:= 'Monthly Cap';
  garn_base_iv_seq(8)		:= 8;
  garn_base_iv_uom(8)		:= 'M';
  garn_base_iv_mand(8)		:= 'N';
  garn_base_iv_dbi(8)		:= 'N';
  garn_base_iv_lkp(8)		:= NULL;
  garn_base_iv_dflt(8)		:= NULL;

  IF p_category  IN ('CS', 'SS', 'AY') THEN   -- All Support Categories

    garn_base_iv_names(9)	:= 'Arrears Dedn Amount';
    garn_base_iv_seq(9)		:= 9;
    garn_base_iv_uom(9)		:= 'M';
    garn_base_iv_mand(9)	:= 'N';
    garn_base_iv_dbi(9)		:= 'N';
    garn_base_iv_lkp(9)		:= NULL;
    garn_base_iv_dflt(9)	:= NULL;

    garn_base_iv_names(10)	:= 'Date In Arrears';
    garn_base_iv_seq(10)	:= 10;
    garn_base_iv_uom(10)	:= 'D';
    garn_base_iv_mand(10)	:= 'N';
    garn_base_iv_dbi(10)	:= 'N';
    garn_base_iv_lkp(10)	:= NULL;
    garn_base_iv_dflt(10)	:= NULL;

    garn_base_iv_names(11)	:= 'Num Dependents';
    garn_base_iv_seq(11)	:= 11;
    garn_base_iv_uom(11)	:= 'I';
    garn_base_iv_mand(11)	:= 'N';
    garn_base_iv_dbi(11)	:= 'N';
    garn_base_iv_lkp(11)	:= NULL;
    garn_base_iv_dflt(11)	:= NULL;

    garn_base_iv_names(12)	:= 'Arrears Bal Amount';
    garn_base_iv_seq(12)	:= 12;
    garn_base_iv_uom(12)	:= 'M';
    garn_base_iv_mand(12)	:= 'N';
    garn_base_iv_dbi(12)	:= 'N';
    garn_base_iv_lkp(12)	:= NULL;
    garn_base_iv_dflt(12)	:= NULL;

    garn_base_iv_names(13)	:= 'Support Other Family';
    garn_base_iv_seq(13)	:= 13;
    garn_base_iv_uom(13)	:= 'C';
    garn_base_iv_mand(13)	:= 'N';
    garn_base_iv_dbi(13)	:= 'N';
    garn_base_iv_lkp(13)	:= 'YES_NO';
    garn_base_iv_dflt(13)	:= NULL;

    garn_base_iv_names(14)	:= 'Allowances';
    garn_base_iv_seq(14)	:= 14;
    garn_base_iv_uom(14)	:= 'I';
    garn_base_iv_mand(14)	:= 'N';
    garn_base_iv_dbi(14)	:= 'N';
    garn_base_iv_lkp(14)	:= NULL;
    garn_base_iv_dflt(14)	:= NULL;

    garn_base_iv_names(15)		:= 'Dedns at Time of Writ';
    garn_base_iv_seq(15)		:= 15;
    garn_base_iv_uom(15)		:= 'M';
    garn_base_iv_mand(15)		:= 'N';
    garn_base_iv_dbi(15)		:= 'N';
    garn_base_iv_lkp(15)		:= NULL;
    garn_base_iv_dflt(15)		:= NULL;


  	 garn_base_iv_names(16)		:= 'Clear Arrears';
    garn_base_iv_seq(16)		:= 16;
    garn_base_iv_uom(16)		:= 'C';
    garn_base_iv_mand(16)		:= 'N';
    garn_base_iv_dbi(16)		:= 'N';
    garn_base_iv_lkp(16)		:= 'YES_NO';
    garn_base_iv_dflt(16)		:= 'N';

      l_num_base_ivs            := 16;

  Else

    garn_base_iv_names(9)	:= 'Dedns at Time of Writ';
    garn_base_iv_seq(9)		:= 9;
    garn_base_iv_uom(9)		:= 'M';
    garn_base_iv_mand(9)	:= 'N';
    garn_base_iv_dbi(9)		:= 'N';
    garn_base_iv_lkp(9)		:= NULL;
    garn_base_iv_dflt(9)	:= NULL;

    garn_base_iv_names(10)	:= 'Filing Status';
    garn_base_iv_seq(10)	:= 10;
    garn_base_iv_uom(10)	:= 'C';
    garn_base_iv_mand(10)	:= 'N';
    garn_base_iv_dbi(10)	:= 'N';
    garn_base_iv_lkp(10)	:= 'US_FEDLEVY_FILING_STATUS';
    garn_base_iv_dflt(10)	:= NULL;

    garn_base_iv_names(11)	:= 'Allowances';
    garn_base_iv_seq(11)	:= 11;
    garn_base_iv_uom(11)	:= 'I';
    garn_base_iv_mand(11)	:= 'N';
    garn_base_iv_dbi(11)	:= 'N';
    garn_base_iv_lkp(11)	:= NULL;
    garn_base_iv_dflt(11)	:= NULL;

    garn_base_iv_names(12)	:= 'Num Dependents';
    garn_base_iv_seq(12)	:= 12;
    garn_base_iv_uom(12)	:= 'I';
    garn_base_iv_mand(12)	:= 'N';
    garn_base_iv_dbi(12)	:= 'N';
    garn_base_iv_lkp(12)	:= NULL;
    garn_base_iv_dflt(12)	:= NULL;

    garn_base_iv_names(13)		:= 'Clear Arrears';
    garn_base_iv_seq(13)		:= 13;
    garn_base_iv_uom(13)		:= 'C';
    garn_base_iv_mand(13)		:= 'N';
    garn_base_iv_dbi(13)		:= 'N';
    garn_base_iv_lkp(13)		:= 'YES_NO';
    garn_base_iv_dflt(13)		:= 'N';

    l_num_base_ivs         := 13;

   if p_category  IN ('BO') THEN

    garn_base_iv_names(14)      := 'Exempt Amount';
    garn_base_iv_seq(14)        := 14;
    garn_base_iv_uom(14)        := 'N';
    garn_base_iv_mand(14)       := 'N';
    garn_base_iv_dbi(14)        := 'N';
    garn_base_iv_lkp(14)        := NULL;
    garn_base_iv_dflt(14)       := NULL;

    l_num_base_ivs            := 14;

   end if;

-- Note : l_num_base_ivs to be later used to determine the No.  or input values to be created
-- for the specific element.

  End if;


  garn_calc_iv_names(1)		:= 'Amount';
  garn_calc_iv_seq(1)		:= 1;
  garn_calc_iv_uom(1)		:= 'M';
  garn_calc_iv_mand(1)		:= 'N';
  garn_calc_iv_dbi(1)		:= 'N';
  garn_calc_iv_lkp(1)		:= NULL;
  garn_calc_iv_dflt(1)		:= NULL;

  garn_calc_iv_names(2)		:= 'Jurisdiction';
  garn_calc_iv_seq(2)		:= 2;
  garn_calc_iv_uom(2)		:= 'C';
  garn_calc_iv_mand(2)		:= 'N';
  garn_calc_iv_dbi(2)		:= 'N';
  garn_calc_iv_lkp(2)		:= NULL;
  garn_calc_iv_dflt(2)		:= NULL;

  garn_calc_iv_names(3)		:= 'Total Owed';
  garn_calc_iv_seq(3)		:= 3;
  garn_calc_iv_uom(3)		:= 'M';
  garn_calc_iv_mand(3)		:= 'N';
  garn_calc_iv_dbi(3)		:= 'N';
  garn_calc_iv_lkp(3)		:= NULL;
  garn_calc_iv_dflt(3)		:= NULL;

  garn_calc_iv_names(4)		:= 'Date Served';
  garn_calc_iv_seq(4)		:= 4;
  garn_calc_iv_uom(4)		:= 'D';
  garn_calc_iv_mand(4)		:= 'N';
  garn_calc_iv_dbi(4)		:= 'N';
  garn_calc_iv_lkp(4)		:= NULL;
  garn_calc_iv_dflt(4)		:= NULL;

  garn_calc_iv_names(5)		:= 'Arrears Dedn Amount';
  garn_calc_iv_seq(5)		:= 5;
  garn_calc_iv_uom(5)		:= 'M';
  garn_calc_iv_mand(5)		:= 'N';
  garn_calc_iv_dbi(5)		:= 'N';
  garn_calc_iv_lkp(5)		:= NULL;
  garn_calc_iv_dflt(5)		:= NULL;

  garn_calc_iv_names(6)		:= 'Date In Arrears';
  garn_calc_iv_seq(6)		:= 6;
  garn_calc_iv_uom(6)		:= 'D';
  garn_calc_iv_mand(6)		:= 'N';
  garn_calc_iv_dbi(6)		:= 'N';
  garn_calc_iv_lkp(6)		:= NULL;
  garn_calc_iv_dflt(6)		:= NULL;

  garn_calc_iv_names(7)		:= 'Num Dependents';
  garn_calc_iv_seq(7)		:= 7;
  garn_calc_iv_uom(7)		:= 'I';
  garn_calc_iv_mand(7)		:= 'N';
  garn_calc_iv_dbi(7)		:= 'N';
  garn_calc_iv_lkp(7)		:= NULL;
  garn_calc_iv_dflt(7)		:= NULL;

  garn_calc_iv_names(8)		:= 'Filing Status';
  garn_calc_iv_seq(8)		:= 8;
  garn_calc_iv_uom(8)		:= 'C';
  garn_calc_iv_mand(8)		:= 'N';
  garn_calc_iv_dbi(8)		:= 'N';
  garn_calc_iv_lkp(8)		:= 'US_FEDLEVY_FILING_STATUS';
  garn_calc_iv_dflt(8)		:= NULL;

  garn_calc_iv_names(9)		:= 'Allowances';
  garn_calc_iv_seq(9)		:= 9;
  garn_calc_iv_uom(9)		:= 'I';
  garn_calc_iv_mand(9)		:= 'N';
  garn_calc_iv_dbi(9)		:= 'N';
  garn_calc_iv_lkp(9)		:= NULL;
  garn_calc_iv_dflt(9)		:= NULL;

  garn_calc_iv_names(10)	:= 'Dedns at Time of Writ';
  garn_calc_iv_seq(10)		:= 10;
  garn_calc_iv_uom(10)		:= 'M';
  garn_calc_iv_mand(10)		:= 'N';
  garn_calc_iv_dbi(10)		:= 'N';
  garn_calc_iv_lkp(10)		:= NULL;
  garn_calc_iv_dflt(10)		:= NULL;

  garn_calc_iv_names(11)	:= 'Additional Amount Balance';
  garn_calc_iv_seq(11)		:= 11;
  garn_calc_iv_uom(11)		:= 'M';
  garn_calc_iv_mand(11)		:= 'N';
  garn_calc_iv_dbi(11)		:= 'N';
  garn_calc_iv_lkp(11)		:= NULL;
  garn_calc_iv_dflt(11)		:= NULL;

  garn_calc_iv_names(12)	:= 'Replacement Amount Balance';
  garn_calc_iv_seq(12)		:= 12;
  garn_calc_iv_uom(12)		:= 'M';
  garn_calc_iv_mand(12)		:= 'N';
  garn_calc_iv_dbi(12)		:= 'N';
  garn_calc_iv_lkp(12)		:= NULL;
  garn_calc_iv_dflt(12)		:= NULL;

  garn_calc_iv_names(13)	:= 'Arrears Amount Balance';
  garn_calc_iv_seq(13)		:= 13;
  garn_calc_iv_uom(13)		:= 'M';
  garn_calc_iv_mand(13)		:= 'N';
  garn_calc_iv_dbi(13)		:= 'N';
  garn_calc_iv_lkp(13)		:= NULL;
  garn_calc_iv_dflt(13)		:= NULL;

  garn_calc_iv_names(14)	:= 'Primary Amount Balance';
  garn_calc_iv_seq(14)		:= 14;
  garn_calc_iv_uom(14)		:= 'M';
  garn_calc_iv_mand(14)		:= 'N';
  garn_calc_iv_dbi(14)		:= 'N';
  garn_calc_iv_lkp(14)		:= NULL;
  garn_calc_iv_dflt(14)		:= NULL;

  garn_calc_iv_names(15)	:= 'Percentage';
  garn_calc_iv_seq(15)		:= 15;
  garn_calc_iv_uom(15)		:= 'N';
  garn_calc_iv_mand(15)		:= 'N';
  garn_calc_iv_dbi(15)		:= 'N';
  garn_calc_iv_lkp(15)		:= NULL;
  garn_calc_iv_dflt(15)		:= NULL;

  garn_calc_iv_names(16)	:= 'Support Other Family';
  garn_calc_iv_seq(16)		:= 16;
  garn_calc_iv_uom(16)		:= 'C';
  garn_calc_iv_mand(16)		:= 'N';
  garn_calc_iv_dbi(16)		:= 'N';
  garn_calc_iv_lkp(16)		:= 'YES_NO';
  garn_calc_iv_dflt(16)		:= NULL;

  garn_calc_iv_names(17)	:= 'Monthly Cap Amount';
  garn_calc_iv_seq(17)		:= 17;
  garn_calc_iv_uom(17)		:= 'M';
  garn_calc_iv_mand(17)		:= 'N';
  garn_calc_iv_dbi(17)		:= 'N';
  garn_calc_iv_lkp(17)		:= NULL;
  garn_calc_iv_dflt(17)		:= NULL;

  garn_calc_iv_names(18)	:= 'Month To Date Balance';
  garn_calc_iv_seq(18)		:= 18;
  garn_calc_iv_uom(18)		:= 'M';
  garn_calc_iv_mand(18)		:= 'N';
  garn_calc_iv_dbi(18)		:= 'N';
  garn_calc_iv_lkp(18)		:= NULL;
  garn_calc_iv_dflt(18)		:= NULL;

  garn_calc_iv_names(19)   := 'Exempt Amt BO';
  garn_calc_iv_seq(19)     := 19;
  garn_calc_iv_uom(19)     := 'M';
  garn_calc_iv_mand(19)    := 'N';
  garn_calc_iv_dbi(19)     := 'N';
  garn_calc_iv_lkp(19)     := NULL;
  garn_calc_iv_dflt(19)    := NULL;

  garn_calc_iv_names(20)	:= 'Period Cap Amount';
  garn_calc_iv_seq(20)		:= 20;
  garn_calc_iv_uom(20)		:= 'M';
  garn_calc_iv_mand(20)		:= 'N';
  garn_calc_iv_dbi(20)		:= 'N';
  garn_calc_iv_lkp(20)		:= NULL;
  garn_calc_iv_dflt(20)		:= NULL;

  garn_calc_iv_names(21)	:= 'Period To Date Balance';
  garn_calc_iv_seq(21)		:= 21;
  garn_calc_iv_uom(21)		:= 'M';
  garn_calc_iv_mand(21)		:= 'N';
  garn_calc_iv_dbi(21)		:= 'N';
  garn_calc_iv_lkp(21)		:= NULL;
  garn_calc_iv_dflt(21)		:= NULL;


  garn_calc_iv_names(22)        := 'Accrued Fees';
  garn_calc_iv_seq(22)          := 22;
  garn_calc_iv_uom(22)          := 'M';
  garn_calc_iv_mand(22)         := 'N';
  garn_calc_iv_dbi(22)          := 'N';
  garn_calc_iv_lkp(22)          := NULL;
  garn_calc_iv_dflt(22)         := NULL;

  garn_calc_iv_names(23)        := 'PTD Fee Balance';
  garn_calc_iv_seq(23)          := 23;
  garn_calc_iv_uom(23)          := 'M';
  garn_calc_iv_mand(23)         := 'N';
  garn_calc_iv_dbi(23)          := 'N';
  garn_calc_iv_lkp(23)          := NULL;
  garn_calc_iv_dflt(23)         := NULL;

  garn_calc_iv_names(24)        := 'Month Fee Balance';
  garn_calc_iv_seq(24)          := 24;
  garn_calc_iv_uom(24)          := 'M';
  garn_calc_iv_mand(24)         := 'N';
  garn_calc_iv_dbi(24)          := 'N';
  garn_calc_iv_lkp(24)          := NULL;
  garn_calc_iv_dflt(24)         := NULL;

  garn_calc_iv_names(25)        := 'Accrued Fee Correction';
  garn_calc_iv_seq(25)          := 25;
  garn_calc_iv_uom(25)          := 'M';
  garn_calc_iv_mand(25)         := 'N';
  garn_calc_iv_dbi(25)          := 'N';
  garn_calc_iv_lkp(25)          := NULL;
  garn_calc_iv_dflt(25)         := NULL;


  l_num_calc_ivs		:= 25;

  garn_verif_iv_names(1)	:= 'Deduction Amount';
  garn_verif_iv_seq(1)		:= 1;
  garn_verif_iv_uom(1)		:= 'M';
  garn_verif_iv_mand(1)		:= 'N';
  garn_verif_iv_dbi(1)		:= 'N';
  garn_verif_iv_lkp(1)		:= NULL;
  garn_verif_iv_dflt(1)		:= NULL;

  garn_verif_iv_names(2)	:= 'Arrears Amount';
  garn_verif_iv_seq(2)		:= 2;
  garn_verif_iv_uom(2)		:= 'M';
  garn_verif_iv_mand(2)		:= 'N';
  garn_verif_iv_dbi(2)		:= 'N';
  garn_verif_iv_lkp(2)		:= NULL;
  garn_verif_iv_dflt(2)		:= NULL;

  garn_verif_iv_names(3)	:= 'Fee Amount';
  garn_verif_iv_seq(3)		:= 3;
  garn_verif_iv_uom(3)		:= 'M';
  garn_verif_iv_mand(3)		:= 'N';
  garn_verif_iv_dbi(3)		:= 'N';
  garn_verif_iv_lkp(3)		:= NULL;
  garn_verif_iv_dflt(3)		:= NULL;

  garn_verif_iv_names(4)	:= 'DI Subject';
  garn_verif_iv_seq(4)		:= 4;
  garn_verif_iv_uom(4)		:= 'M';
  garn_verif_iv_mand(4)		:= 'N';
  garn_verif_iv_dbi(4)		:= 'N';
  garn_verif_iv_lkp(4)		:= NULL;
  garn_verif_iv_dflt(4)		:= NULL;

  garn_verif_iv_names(5)	:= 'Jurisdiction';
  garn_verif_iv_seq(5)		:= 5;
  garn_verif_iv_uom(5)		:= 'C';
  garn_verif_iv_mand(5)		:= 'N';
  garn_verif_iv_dbi(5)		:= 'N';
  garn_verif_iv_lkp(5)		:= NULL;
  garn_verif_iv_dflt(5)		:= NULL;

  garn_verif_iv_names(6)	:= 'Primary Amount Balance';
  garn_verif_iv_seq(6)		:= 6;
  garn_verif_iv_uom(6)		:= 'M';
  garn_verif_iv_mand(6)		:= 'N';
  garn_verif_iv_dbi(6)		:= 'N';
  garn_verif_iv_lkp(6)		:= NULL;
  garn_verif_iv_dflt(6)		:= NULL;

  garn_verif_iv_names(7)	:= 'Total Owed';
  garn_verif_iv_seq(7)		:= 7;
  garn_verif_iv_uom(7)		:= 'M';
  garn_verif_iv_mand(7)		:= 'N';
  garn_verif_iv_dbi(7)		:= 'N';
  garn_verif_iv_lkp(7)		:= NULL;
  garn_verif_iv_dflt(7)		:= NULL;

  garn_verif_iv_names(8)	:= 'Date Served';
  garn_verif_iv_seq(8)		:= 8;
  garn_verif_iv_uom(8)		:= 'D';
  garn_verif_iv_mand(8)		:= 'N';
  garn_verif_iv_dbi(8)		:= 'N';
  garn_verif_iv_lkp(8)		:= NULL;
  garn_verif_iv_dflt(8)		:= NULL;

  garn_verif_iv_names(9)	:= 'DI Subject 45';
  garn_verif_iv_seq(9)		:= 9;
  garn_verif_iv_uom(9)		:= 'M';
  garn_verif_iv_mand(9)		:= 'N';
  garn_verif_iv_dbi(9)		:= 'N';
  garn_verif_iv_lkp(9)		:= NULL;
  garn_verif_iv_dflt(9)		:= NULL;

  garn_verif_iv_names(10)	:= 'DI Subject 50';
  garn_verif_iv_seq(10)		:= 10;
  garn_verif_iv_uom(10)		:= 'M';
  garn_verif_iv_mand(10)	:= 'N';
  garn_verif_iv_dbi(10)		:= 'N';
  garn_verif_iv_lkp(10)		:= NULL;
  garn_verif_iv_dflt(10)	:= NULL;

  garn_verif_iv_names(11)	:= 'Support Other Family';
  garn_verif_iv_seq(11)		:= 11;
  garn_verif_iv_uom(11)		:= 'C';
  garn_verif_iv_mand(11)	:= 'N';
  garn_verif_iv_dbi(11)		:= 'N';
  garn_verif_iv_lkp(11)		:= 'YES_NO';
  garn_verif_iv_dflt(11)	:= NULL;

  garn_verif_iv_names(12)       := 'Accrued Fees';
  garn_verif_iv_seq(12)         := 12;
  garn_verif_iv_uom(12)         := 'M';
  garn_verif_iv_mand(12)        := 'N';
  garn_verif_iv_dbi(12)         := 'N';
  garn_verif_iv_lkp(12)         := NULL;
  garn_verif_iv_dflt(12)        := NULL;

  garn_verif_iv_names(13)       := 'PTD Fee Balance';
  garn_verif_iv_seq(13)         := 13;
  garn_verif_iv_uom(13)         := 'M';
  garn_verif_iv_mand(13)        := 'N';
  garn_verif_iv_dbi(13)         := 'N';
  garn_verif_iv_lkp(13)         := NULL;
  garn_verif_iv_dflt(13)        := NULL;

  garn_verif_iv_names(14)       := 'Month Fee Balance';
  garn_verif_iv_seq(14)         := 14;
  garn_verif_iv_uom(14)         := 'M';
  garn_verif_iv_mand(14)        := 'N';
  garn_verif_iv_dbi(14)         := 'N';
  garn_verif_iv_lkp(14)         := NULL;
  garn_verif_iv_dflt(14)        := NULL;

  l_num_verif_ivs		:= 14;


  garn_si_iv_names(1)	:= 'Replace Amt';
  garn_si_iv_seq(1)	:= 1;
  garn_si_iv_uom(1)	:= 'M';
  garn_si_iv_mand(1)	:= 'N';
  garn_si_iv_dbi(1)	:= 'N';
  garn_si_iv_lkp(1)	:= NULL;
  garn_si_iv_dflt(1)	:= NULL;

  garn_si_iv_names(2)	:= 'Addl Amt';
  garn_si_iv_seq(2)	:= 2;
  garn_si_iv_uom(2)	:= 'M';
  garn_si_iv_mand(2)	:= 'N';
  garn_si_iv_dbi(2)	:= 'N';
  garn_si_iv_lkp(2)	:= NULL;
  garn_si_iv_dflt(2)	:= NULL;

  garn_si_iv_names(3)	:= 'Adjust Arrears';
  garn_si_iv_seq(3)	:= 3;
  garn_si_iv_uom(3)	:= 'M';
  garn_si_iv_mand(3)	:= 'N';
  garn_si_iv_dbi(3)	:= 'N';
  garn_si_iv_lkp(3)	:= NULL;
  garn_si_iv_dflt(3)	:= NULL;

  l_num_si_ivs		:= 3;

  garn_sf_iv_names(1)	:= 'Not Taken';
  garn_sf_iv_seq(1)	:= 1;
  garn_sf_iv_uom(1)	:= 'M';
  garn_sf_iv_mand(1)	:= 'N';
  garn_sf_iv_dbi(1)	:= 'N';
  garn_sf_iv_lkp(1)	:= NULL;
  garn_sf_iv_dflt(1)	:= NULL;

  garn_sf_iv_names(2)	:= 'Arrears Contr';
  garn_sf_iv_seq(2)	:= 2;
  garn_sf_iv_uom(2)	:= 'M';
  garn_sf_iv_mand(2)	:= 'N';
  garn_sf_iv_dbi(2)	:= 'N';
  garn_sf_iv_lkp(2)	:= NULL;
  garn_sf_iv_dflt(2)	:= NULL;

  garn_sf_iv_names(3)	:= 'Calculated Fee Amount';
  garn_sf_iv_seq(3)	:= 3;
  garn_sf_iv_uom(3)	:= 'M';
  garn_sf_iv_mand(3)	:= 'N';
  garn_sf_iv_dbi(3)	:= 'N';
  garn_sf_iv_lkp(3)	:= NULL;
  garn_sf_iv_dflt(3)	:= NULL;

-- Feeds child supp total dedns balance...378699
  garn_sf_iv_names(4)	:= 'Calculated Amount';
  garn_sf_iv_seq(4)	:= 4;
  garn_sf_iv_uom(4)	:= 'M';
  garn_sf_iv_mand(4)	:= 'N';
  garn_sf_iv_dbi(4)	:= 'N';
  garn_sf_iv_lkp(4)	:= NULL;
  garn_sf_iv_dflt(4)	:= NULL;

  garn_sf_iv_names(5)	:= 'Replacement Amt';
  garn_sf_iv_seq(5)	:= 5;
  garn_sf_iv_uom(5)	:= 'M';
  garn_sf_iv_mand(5)	:= 'N';
  garn_sf_iv_dbi(5)	:= 'N';
  garn_sf_iv_lkp(5)	:= NULL;
  garn_sf_iv_dflt(5)	:= NULL;

  garn_sf_iv_names(6)	:= 'Additional Amt';
  garn_sf_iv_seq(6)	:= 6;
  garn_sf_iv_uom(6)	:= 'M';
  garn_sf_iv_mand(6)	:= 'N';
  garn_sf_iv_dbi(6)	:= 'N';
  garn_sf_iv_lkp(6)	:= NULL;
  garn_sf_iv_dflt(6)	:= NULL;

  garn_sf_iv_names(7)	:= 'Counter';
  garn_sf_iv_seq(7)	:= 7;
  garn_sf_iv_uom(7)	:= 'N';
  garn_sf_iv_mand(7)	:= 'N';
  garn_sf_iv_dbi(7)	:= 'N';
  garn_sf_iv_lkp(7)	:= NULL;
  garn_sf_iv_dflt(7)	:= NULL;

  garn_sf_iv_names(8)	:= 'Voldedns at Writ';
  garn_sf_iv_seq(8)	:= 8;
  garn_sf_iv_uom(8)	:= 'M';
  garn_sf_iv_mand(8)	:= 'N';
  garn_sf_iv_dbi(8)	:= 'N';
  garn_sf_iv_lkp(8)	:= NULL;
  garn_sf_iv_dflt(8)	:= NULL;

  garn_sf_iv_names(9)	:= 'To Total Owed';
  garn_sf_iv_seq(9)	:= 9;
  garn_sf_iv_uom(9)	:= 'M';
  garn_sf_iv_mand(9)	:= 'N';
  garn_sf_iv_dbi(9)	:= 'N';
  garn_sf_iv_lkp(9)	:= NULL;
  garn_sf_iv_dflt(9)	:= NULL;

  garn_sf_iv_names(10)  := 'Accrued Fees';
  garn_sf_iv_seq(10)    := 10;
  garn_sf_iv_uom(10)    := 'M';
  garn_sf_iv_mand(10)   := 'N';
  garn_sf_iv_dbi(10)    := 'N';
  garn_sf_iv_lkp(10)    := NULL;
  garn_sf_iv_dflt(10)   := NULL;

  l_num_sf_ivs		:= 10;

/* 338498 : 20th Feb 1996  - begin */

  garn_fee_iv_names(1)	:= 'Withheld Fee Amount';
  garn_fee_iv_seq(1)	:= 1;
  garn_fee_iv_uom(1)	:= 'M';
  garn_fee_iv_mand(1)	:= 'N';
  garn_fee_iv_dbi(1)	:= 'N';
  garn_fee_iv_lkp(1)	:= NULL;
  garn_fee_iv_dflt(1)	:= NULL;

  l_num_fee_ivs		:= 1;

  garn_vp_iv_names(1)  := 'Amount';
  garn_vp_iv_seq(1)    := 1;
  garn_vp_iv_uom(1)    := 'M';
  garn_vp_iv_mand(1)   := 'N';
  garn_vp_iv_dbi(1)    := 'N';
  garn_vp_iv_lkp(1)    := NULL;
  garn_vp_iv_dflt(1)   := NULL;

  garn_vp_iv_names(2)  := 'Calc Priority';
  garn_vp_iv_seq(2)    := 2;
  garn_vp_iv_uom(2)    := 'N';
  garn_vp_iv_mand(2)   := 'N';
  garn_vp_iv_dbi(2)    := 'N';
  garn_vp_iv_lkp(2)    := NULL;
  garn_vp_iv_dflt(2)   := NULL;

  garn_vp_iv_names(3)  := 'DI Subject';
  garn_vp_iv_seq(3)    := 3;
  garn_vp_iv_uom(3)    := 'M';
  garn_vp_iv_mand(3)   := 'N';
  garn_vp_iv_dbi(3)    := 'N';
  garn_vp_iv_lkp(3)    := NULL;
  garn_vp_iv_dflt(3)   := NULL;

  garn_vp_iv_names(4)  := 'Jurisdiction';
  garn_vp_iv_seq(4)    := 4;
  garn_vp_iv_uom(4)    := 'C';
  garn_vp_iv_mand(4)   := 'N';
  garn_vp_iv_dbi(4)    := 'N';
  garn_vp_iv_lkp(4)    := NULL;
  garn_vp_iv_dflt(4)   := NULL;

  garn_vp_iv_names(5)	:= 'Arrears Amount';
  garn_vp_iv_seq(5)	:= 5;
  garn_vp_iv_uom(5)	:= 'M';
  garn_vp_iv_mand(5)	:= 'N';
  garn_vp_iv_dbi(5)	:= 'N';
  garn_vp_iv_lkp(5)	:= NULL;
  garn_vp_iv_dflt(5)	:= NULL;

  garn_vp_iv_names(6)	:= 'Fee Amount';
  garn_vp_iv_seq(6)	:= 6;
  garn_vp_iv_uom(6)	:= 'M';
  garn_vp_iv_mand(6)	:= 'N';
  garn_vp_iv_dbi(6)	:= 'N';
  garn_vp_iv_lkp(6)	:= NULL;
  garn_vp_iv_dflt(6)	:= NULL;

  garn_vp_iv_names(7)	:= 'Primary Amount Balance';
  garn_vp_iv_seq(7)	:= 7;
  garn_vp_iv_uom(7)	:= 'M';
  garn_vp_iv_mand(7)	:= 'N';
  garn_vp_iv_dbi(7)	:= 'N';
  garn_vp_iv_lkp(7)	:= NULL;
  garn_vp_iv_dflt(7)	:= NULL;

  garn_vp_iv_names(8)	:= 'Total Owed';
  garn_vp_iv_seq(8)	:= 8;
  garn_vp_iv_uom(8)	:= 'M';
  garn_vp_iv_mand(8)	:= 'N';
  garn_vp_iv_dbi(8)	:= 'N';
  garn_vp_iv_lkp(8)	:= NULL;
  garn_vp_iv_dflt(8)	:= NULL;

  garn_vp_iv_names(9)	:= 'Date Served';
  garn_vp_iv_seq(9)	:= 9;
  garn_vp_iv_uom(9)	:= 'D';
  garn_vp_iv_mand(9)	:= 'N';
  garn_vp_iv_dbi(9)	:= 'N';
  garn_vp_iv_lkp(9)	:= NULL;
  garn_vp_iv_dflt(9)	:= NULL;

  garn_vp_iv_names(10)	:= 'DI Subject 45';
  garn_vp_iv_seq(10)	:= 10;
  garn_vp_iv_uom(10)	:= 'M';
  garn_vp_iv_mand(10)	:= 'N';
  garn_vp_iv_dbi(10)	:= 'N';
  garn_vp_iv_lkp(10)	:= NULL;
  garn_vp_iv_dflt(10)	:= NULL;

  garn_vp_iv_names(11)	:= 'DI Subject 50';
  garn_vp_iv_seq(11)	:= 11;
  garn_vp_iv_uom(11)	:= 'M';
  garn_vp_iv_mand(11)	:= 'N';
  garn_vp_iv_dbi(11)	:= 'N';
  garn_vp_iv_lkp(11)	:= NULL;
  garn_vp_iv_dflt(11)	:= NULL;

  garn_vp_iv_names(12)	:= 'Support Other Family';
  garn_vp_iv_seq(12)	:= 12;
  garn_vp_iv_uom(12)	:= 'C';
  garn_vp_iv_mand(12)	:= 'N';
  garn_vp_iv_dbi(12)	:= 'N';
  garn_vp_iv_lkp(12)	:= 'YES_NO';
  garn_vp_iv_dflt(12)	:= NULL;

 garn_vp_iv_names(13)  := 'Accrued Fees';
 garn_vp_iv_seq(13)    := 13;
 garn_vp_iv_uom(13)    := 'M';
 garn_vp_iv_mand(13)   := 'N';
 garn_vp_iv_dbi(13)    := 'N';
 garn_vp_iv_lkp(13)    := NULL;
 garn_vp_iv_dflt(13)   := NULL;

 garn_vp_iv_names(14)  := 'PTD Fee Balance';
 garn_vp_iv_seq(14)    := 14;
 garn_vp_iv_uom(14)    := 'M';
 garn_vp_iv_mand(14)   := 'N';
 garn_vp_iv_dbi(14)    := 'N';
 garn_vp_iv_lkp(14)    := NULL;
 garn_vp_iv_dflt(14)   := NULL;

 garn_vp_iv_names(15)  := 'Month Fee Balance';
 garn_vp_iv_seq(15)    := 15;
 garn_vp_iv_uom(15)    := 'M';
 garn_vp_iv_mand(15)   := 'N';
 garn_vp_iv_dbi(15)    := 'N';
 garn_vp_iv_lkp(15)    := NULL;
 garn_vp_iv_dflt(15)   := NULL;

  l_num_vp_ivs         := 15;

/* 338498 : 20th Feb 1996  - end */

  garn_assoc_bal_names(1)	:= p_garn_name;
  garn_assoc_bal_names(2)	:= p_garn_name||' Additional';
  garn_assoc_bal_names(3)	:= p_garn_name||' Replacement';
  garn_assoc_bal_names(4)	:= p_garn_name||' Accrued';
  garn_assoc_bal_names(5)	:= p_garn_name||' Arrears';
  garn_assoc_bal_names(6)	:= p_garn_name||' Not Taken';
  garn_assoc_bal_names(7)	:= p_garn_name||' Fees';
  garn_assoc_bal_names(8)	:= p_garn_name||' Vol Dedns';
  garn_assoc_bal_names(9)       := p_garn_name||' Accrued Fees';


  l_num_assoc_bals		:= 9;

--
-- Create Associated Balance Types and Defined Balances
-- NOTE : Done in this order because of locking ladder.
--
FOR i in 1..l_num_assoc_bals LOOP

  -- Check for existence before creating baltype.
  -- If already exists, set dedn_assoc_bal_id(i) appropriately for
  -- future reference.

  already_exists := hr_template_existence.bal_exists(
			p_bg_id		=> p_bg_id,
			p_bal_name	=> garn_assoc_bal_names(i),
			p_eff_date	=> g_eff_start_date);

  if already_exists = 0 then

    -- Check element name, ie. primary balance name, is unique to
    -- balances within this BG.
    pay_balance_types_pkg.chk_balance_type(
			p_row_id		=> NULL,
  			p_business_group_id	=> p_bg_id,
  			p_legislation_code	=> NULL,
  			p_balance_name          => garn_assoc_bal_names(i),
  			p_reporting_name        => garn_assoc_bal_names(i),
  			p_assignment_remuneration_flag => 'N');

    -- Check element name, ie. primary balance name, is unique to
    -- balances provided as startup data.
    pay_balance_types_pkg.chk_balance_type(
			p_row_id		=> NULL,
  			p_business_group_id	=> NULL,
  			p_legislation_code	=> 'US',
  			p_balance_name          => garn_assoc_bal_names(i),
  			p_reporting_name        => garn_assoc_bal_names(i),
  			p_assignment_remuneration_flag => 'N');

    -- For Bug 3651755 added if condition

         if garn_assoc_bal_names(i) in (p_garn_name||' Additional',
                                        p_garn_name||' Replacement',
                                        p_garn_name||' Vol Dedns',
                                        p_garn_name||' Accrued Fees') then

  	    v_bal_type_id := pay_db_pay_setup.create_balance_type(
	         p_balance_name          => garn_assoc_bal_names(i),
	         p_uom                   => null,
	         p_uom_code              => 'M',
	         p_reporting_name        => garn_assoc_bal_names(i),
	         p_business_group_name   => v_bg_name,
        	 p_legislation_code      => NULL,
	         p_legislation_subgroup  => NULL,
	         p_bc_leg_code           => 'US',
	         p_effective_date        => g_eff_start_date);

          else

  	    v_bal_type_id := pay_db_pay_setup.create_balance_type(
	         p_balance_name          => garn_assoc_bal_names(i),
	         p_uom                   => null,
	         p_uom_code              => 'M',
	         p_reporting_name        => garn_assoc_bal_names(i),
	         p_business_group_name   => v_bg_name,
        	 p_legislation_code      => NULL,
	         p_legislation_subgroup  => NULL,
	         p_balance_category      => 'Involuntary Deductions', -- Bug 3311781
	         p_bc_leg_code           => 'US',
	         p_effective_date        => g_eff_start_date);
          end if;

    garn_assoc_bal_ids(i) := v_bal_type_id;

  else

    garn_assoc_bal_ids(i) := already_exists;

  end if;

  hr_utility.trace('Before do_defined_balances');
  if garn_assoc_bal_names(i) in (p_garn_name||' Additional',
                                 p_garn_name||' Replacement',
                                 p_garn_name||' Vol Dedns',
                                 p_garn_name||' Accrued Fees') then

      do_defined_balances(p_bal_id         => garn_assoc_bal_ids(i),
                          p_bal_name       => garn_assoc_bal_names(i),
                          p_bg_name        => v_bg_name,
                          p_save_run_value => 'N');
  else

      do_defined_balances(p_bal_id         => garn_assoc_bal_ids(i),
                          p_bal_name       => garn_assoc_bal_names(i),
                          p_bg_name        => v_bg_name,
                          p_save_run_value => 'Y');

  end if;

  hr_utility.trace('After do_defined_balances');

END LOOP;

--
-- Create Element Types
--
  FOR i in 1..l_num_eles LOOP
    v_ele_type_id :=  ins_garn_ele_type (
			p_ele_name 		=> garn_ele_names(i),
			p_ele_reporting_name 	=> garn_ele_repnames(i),
			p_ele_description 	=> garn_ele_desc(i),
			p_ele_class 		=> g_ele_classification,
			p_ele_category 		=> p_category,
			p_ele_processing_type 	=> garn_ele_proc_type(i),
			p_ele_priority 		=> garn_ele_priority(i),
			p_ele_standard_link 	=> g_ele_standard_link,
			p_skip_formula_id	=> g_skip_formula_id,
			p_ind_only_flag		=> garn_indirect_only(i),
			p_third_party_pay	=> garn_third_party_pay(i),
			p_ele_eff_start_date	=> g_eff_start_date,
			p_ele_eff_end_date	=> g_eff_end_date,
			p_bg_name		=> v_bg_name,
			p_bg_id			=> p_bg_id);

    garn_ele_ids(i) := v_ele_type_id;

    v_pay_value_name := hr_input_values.get_pay_value_name(g_template_leg_code);

   begin
    UPDATE pay_input_values_f
    SET    mandatory_flag 	= 'X'
    WHERE  element_type_id 	= v_ele_type_id
    AND    name 		= v_pay_value_name;
    if sql%notfound then
             hr_utility.trace('Error here...');
    end if;
   end;

   begin
    SELECT input_value_id
    INTO   v_payval_id
    FROM   pay_input_values_f
    WHERE  element_type_id 	= v_ele_type_id
    AND    name 		= v_pay_value_name
    AND   g_eff_end_date between effective_start_date
                 and effective_end_date; /*1498260*/

   exception
     when no_data_found then
       hr_utility.trace('Error here...'||to_char(v_ele_type_id));
   end;

    garn_payval_id(i) := v_payval_id;

-- Update Element Type DDF as appropriate.

    UPDATE 	pay_element_types_f
    SET		element_information_category 	= g_ele_info_cat,
		element_information1 		= p_category,
		element_information2		= g_partial_dedn,
		element_information3		= g_ele_runtype,
		element_information9		= garn_mix_category(i)
    WHERE	element_type_id 		= v_ele_type_id
    AND		business_group_id + 0 		= p_bg_id;

--
-- Create status processing rule.
--
IF garn_pay_formula(i) IS NOT NULL THEN

   begin

    SELECT formula_id
    INTO   v_calc_formula_id
    FROM   ff_formulas_f
    WHERE  formula_name = garn_pay_formula(i)
    AND	   g_eff_start_date between effective_start_date
		        	and effective_end_date
    AND	   nvl(business_group_id, p_bg_id) + 0 = p_bg_id
    AND	   nvl(legislation_code, g_template_leg_code) = g_template_leg_code
    AND    rownum < 2;

   exception WHEN NO_DATA_FOUND THEN

    v_calc_formula_id := NULL;

    hr_utility.set_location('Error : DID NOT FIND CALC FORMULA', 9);

   end;

hr_utility.set_location('ele '||v_ele_type_id||'ff '||v_calc_formula_id||'bg '||p_bg_id, 9);

-- Looks to require a change here since Alimony and Spousal support verifiers
-- will already have a stat proc rule but not with the new verif formula now put
-- on spousal and alimony...change the spr_exists fn to not use ff id...return ff of
-- existing spr...then compare with v_calc_formula_id, if not the same - then update
-- existing spr, if same, do nothing...if no spr exists, proceed as normal and create spr...

   already_exists := hr_template_existence.spr_exists (
				p_ele_id	=> v_ele_type_id,
				p_ff_id		=> v_spr_formula_id,
				p_bg_id		=> p_bg_id,
				p_val_date	=> g_eff_start_date);

   if already_exists = 0 then

    v_stat_proc_rule_id :=
    pay_formula_results.ins_stat_proc_rule (
		p_business_group_id 		=> p_bg_id,
		p_legislation_code		=> NULL,
		p_legislation_subgroup 		=> g_template_leg_subgroup,
		p_effective_start_date 		=> g_eff_start_date,
		p_effective_end_date 		=> g_eff_end_date,
		p_element_type_id 		=> v_ele_type_id,
		p_assignment_status_type_id 	=> g_asst_status_type_id,
		p_formula_id 			=> v_calc_formula_id,
		p_processing_rule		=> g_proc_rule);

    garn_statproc_rule_id(i) := v_stat_proc_rule_id;

   else

     garn_statproc_rule_id(i) := already_exists;

     IF v_calc_formula_id = v_spr_formula_id THEN

       NULL; -- spr already has this formula attached.

     ELSE

       -- Make sure to update the "standard" processing rule, ie. which
       -- is the one that was checked for in spr_exists.
       UPDATE pay_status_processing_rules_f
       SET formula_id = v_calc_formula_id
       WHERE status_processing_rule_id = already_exists
       AND g_eff_start_date between effective_start_date
                                              and effective_end_date;

     END IF;

   end if;

  END IF;

  END LOOP;

--
-- Now create all base element input values.
--
  hr_utility.trace('Base ivs = '||to_char(l_num_base_ivs));
  FOR k in 1..l_num_base_ivs LOOP
      hr_utility.trace('Base iv # = '||to_char(k));
    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(1),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_base_iv_names(k),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

/*
40.15 : Call new API to add input value over life of element if
         upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(1),
			p_name 	            => garn_base_iv_names(k),
			p_uom_code 			=> garn_base_iv_uom(k),
			p_mandatory_flag 	=> garn_base_iv_mand(k),
			p_generate_db_item_flag => garn_base_iv_dbi(k),
            p_default_value         => garn_base_iv_dflt(k),
            p_min_value             => NULL,
	        p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_base_iv_lkp(k),
	        p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_base_iv_seq(k),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_base_iv_ids(k) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(1),
		p_legislation_code 		=> g_template_leg_code,
    	p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag	=> 'UPDATE',
		p_input_value_id 		=> garn_base_iv_ids(k),
		p_rowid 			    => NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_base_iv_mand(k),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 	=> 'N',
		p_classification_type 	=> 'N',
		p_name 			        => garn_base_iv_names(k),
		p_uom                   => garn_base_iv_uom(k),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> garn_base_iv_dflt(k),
		p_lookup_type 			=> garn_base_iv_lkp(k),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag  => garn_base_iv_dbi(k),
		p_warning_or_error 		=> NULL);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(1),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_base_iv_ids(k),
		p_default_value 			=> garn_base_iv_dflt(k),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 		=> NULL,
		p_input_value_name 		=> garn_base_iv_names(k),
		p_db_items_flag 		=> garn_base_iv_dbi(k),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 		=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(1),
			p_name 	     		=> garn_base_iv_names(k),
			p_uom_code 			=> garn_base_iv_uom(k),
			p_mandatory_flag 	=> garn_base_iv_mand(k),
			p_generate_db_item_flag => garn_base_iv_dbi(k),
            p_default_value         => garn_base_iv_dflt(k),
            p_min_value             => NULL,
	        p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_base_iv_lkp(k),
	        p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
		    p_display_sequence 	=> garn_base_iv_seq(k),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_base_iv_ids(k) := v_inpval_id;

        -- Existing elements being upgraded. Call modified iv procedures
        -- that do not validate for existing entries or run results.

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(1),
		p_legislation_code 		=> g_template_leg_code,
    	            p_val_start_date 		=> g_eff_start_date,
            	p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_base_iv_ids(k),
		p_rowid 			=> NULL,
		p_recurring_flag 			=> 'N',
		p_mandatory_flag 		=> garn_base_iv_mand(k),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 			=> garn_base_iv_names(k),
		p_uom 				=> garn_base_iv_uom(k),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 			=> garn_base_iv_dflt(k),
		p_lookup_type 			=> garn_base_iv_lkp(k),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_base_iv_dbi(k),
		p_warning_or_error 		=> NULL);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(1),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_base_iv_ids(k),
		p_default_value 			=> garn_base_iv_dflt(k),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 		=> NULL,
		p_input_value_name 		=> garn_base_iv_names(k),
		p_db_items_flag 		=> garn_base_iv_dbi(k),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 		=> NULL);

        -- Need to add link input value, element entry values, and
        -- run result values for new input value on existing element.

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(1),
			p_input_value_id  	=> garn_base_iv_ids(k),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_base_iv_dflt(k),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      garn_base_iv_ids(k) := already_exists;

    end if;

  END LOOP;

--
-- Now create all calc element input values.
--
  hr_utility.trace('Calc ivs = '||to_char(l_num_calc_ivs));
  FOR c in 1..l_num_calc_ivs LOOP
      hr_utility.trace('Calc iv # = '||to_char(c));
    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(2),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_calc_iv_names(c),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

/* 40.15 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
		p_element_name 		=> garn_ele_names(2),
		p_name   			=> garn_calc_iv_names(c),
		p_uom_code 			=> garn_calc_iv_uom(c),
		p_mandatory_flag 	=> garn_calc_iv_mand(c),
		p_generate_db_item_flag => garn_calc_iv_dbi(c),
        p_default_value         => garn_calc_iv_dflt(c),
        p_min_value             => NULL,
        p_max_value             => NULL,
        p_warning_or_error      => NULL,
        p_lookup_type           => garn_calc_iv_lkp(c),
        p_formula_id            => NULL,
        p_hot_default_flag      => 'N',
		p_display_sequence 	    => garn_calc_iv_seq(c),
		p_business_group_name 	=> v_bg_name,
        p_effective_start_date	=> g_eff_start_date,
        p_effective_end_date   	=> g_eff_end_date);

        garn_calc_iv_ids(c) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(2),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_calc_iv_ids(c),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_calc_iv_mand(c),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_calc_iv_names(c),
		p_uom 				=> garn_calc_iv_uom(c),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> garn_calc_iv_dflt(c),
		p_lookup_type 			=> garn_calc_iv_lkp(c),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_calc_iv_dbi(c),
		p_warning_or_error 		=> NULL);

        hr_input_values.ins_3p_input_values(
 		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(2),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_calc_iv_ids(c),
		p_default_value 		=> garn_calc_iv_dflt(c),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_calc_iv_names(c),
		p_db_items_flag 		=> garn_calc_iv_dbi(c),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
		p_element_name 		=> garn_ele_names(2),
		p_name 	     		=> garn_calc_iv_names(c),
		p_uom_code 			=> garn_calc_iv_uom(c),
		p_mandatory_flag 	=> garn_calc_iv_mand(c),
		p_generate_db_item_flag => garn_calc_iv_dbi(c),
        p_default_value         => garn_calc_iv_dflt(c),
        p_min_value             => NULL,
        p_max_value             => NULL,
        p_warning_or_error      => NULL,
        p_lookup_type           => garn_calc_iv_lkp(c),
        p_formula_id            => NULL,
        p_hot_default_flag      => 'N',
		p_display_sequence 	=> garn_calc_iv_seq(c),
		p_business_group_name 	=> v_bg_name,
        p_effective_start_date	=> g_eff_start_date,
        p_effective_end_date   	=> g_eff_end_date);

        garn_calc_iv_ids(c) := v_inpval_id;

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(2),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_calc_iv_ids(c),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_calc_iv_mand(c),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_calc_iv_names(c),
		p_uom 				=> garn_calc_iv_uom(c),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> garn_calc_iv_dflt(c),
		p_lookup_type 			=> garn_calc_iv_lkp(c),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_calc_iv_dbi(c),
		p_warning_or_error 		=> NULL);

        pay_template_ivs.ins_3p_input_values(
 		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(2),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_calc_iv_ids(c),
		p_default_value 		=> garn_calc_iv_dflt(c),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_calc_iv_names(c),
		p_db_items_flag 		=> garn_calc_iv_dbi(c),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 		=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(2),
			p_input_value_id  	=> garn_calc_iv_ids(c),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_calc_iv_dflt(c),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

   else

      garn_calc_iv_ids(c) := already_exists;

    end if;

  END LOOP;

--
-- Now create all verification element input values.
--
  hr_utility.trace('Verif ivs = '||to_char(l_num_verif_ivs));
  FOR v in 1..l_num_verif_ivs LOOP
      hr_utility.trace('Verif iv # = '||to_char(v));

    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(3),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_verif_iv_names(v),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

/* 40.15 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(3),
			p_name 	     		=> garn_verif_iv_names(v),
			p_uom_code 			=> garn_verif_iv_uom(v),
			p_mandatory_flag 	=> garn_verif_iv_mand(v),
			p_generate_db_item_flag => garn_verif_iv_dbi(v),
            p_default_value         => garn_verif_iv_dflt(v),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_verif_iv_lkp(v),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_verif_iv_seq(v),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_verif_iv_ids(v) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(3),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_verif_iv_ids(v),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_verif_iv_mand(v),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_verif_iv_names(v),
		p_uom 				=> garn_verif_iv_uom(v),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_verif_iv_dflt(v),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_verif_iv_dbi(v),
		p_warning_or_error 		=> NULL);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(3),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_verif_iv_ids(v),
		p_default_value 		=> garn_verif_iv_dflt(v),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_verif_iv_names(v),
		p_db_items_flag 		=> garn_verif_iv_dbi(v),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(3),
			p_name 	    		=> garn_verif_iv_names(v),
			p_uom_code 			=> garn_verif_iv_uom(v),
			p_mandatory_flag 	=> garn_verif_iv_mand(v),
			p_generate_db_item_flag => garn_verif_iv_dbi(v),
            p_default_value         => garn_verif_iv_dflt(v),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_verif_iv_lkp(v),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_verif_iv_seq(v),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_verif_iv_ids(v) := v_inpval_id;

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(3),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_verif_iv_ids(v),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_verif_iv_mand(v),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_verif_iv_names(v),
		p_uom 				=> garn_verif_iv_uom(v),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_verif_iv_dflt(v),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_verif_iv_dbi(v),
		p_warning_or_error 		=> NULL);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(3),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_verif_iv_ids(v),
		p_default_value 		=> garn_verif_iv_dflt(v),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_verif_iv_names(v),
		p_db_items_flag 		=> garn_verif_iv_dbi(v),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(3),
			p_input_value_id  	=> garn_verif_iv_ids(v),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_verif_iv_dflt(v),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      garn_verif_iv_ids(v) := already_exists;

    end if;

  END LOOP;

--
-- Now create all special inputs element input values.
--
  hr_utility.trace('SIV ivs = '||to_char(l_num_si_ivs));
  FOR siv in 1..l_num_si_ivs LOOP
      hr_utility.trace('SIV iv # = '||to_char(siv));
    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(4),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_si_iv_names(siv),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

/* 40.15 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(4),
			p_name 	    		=> garn_si_iv_names(siv),
			p_uom_code 			=> garn_si_iv_uom(siv),
			p_mandatory_flag 	=> garn_si_iv_mand(siv),
			p_generate_db_item_flag => garn_si_iv_dbi(siv),
            p_default_value         => garn_si_iv_dflt(siv),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_si_iv_lkp(siv),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_si_iv_seq(siv),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_si_iv_ids(siv) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(4),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_si_iv_ids(siv),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_si_iv_mand(siv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_si_iv_names(siv),
		p_uom 				=> garn_si_iv_uom(siv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_si_iv_dflt(siv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_si_iv_dbi(siv),
		p_warning_or_error 		=> NULL);

      hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(4),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_si_iv_ids(siv),
		p_default_value 		=> garn_si_iv_dflt(siv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_si_iv_names(siv),
		p_db_items_flag 		=> garn_si_iv_dbi(siv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(4),
			p_name 	     		=> garn_si_iv_names(siv),
			p_uom_code 			=> garn_si_iv_uom(siv),
			p_mandatory_flag 	=> garn_si_iv_mand(siv),
			p_generate_db_item_flag => garn_si_iv_dbi(siv),
            p_default_value         => garn_si_iv_dflt(siv),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_si_iv_lkp(siv),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_si_iv_seq(siv),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_si_iv_ids(siv) := v_inpval_id;

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(4),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_si_iv_ids(siv),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_si_iv_mand(siv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_si_iv_names(siv),
		p_uom 				=> garn_si_iv_uom(siv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_si_iv_dflt(siv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_si_iv_dbi(siv),
		p_warning_or_error 		=> NULL);

      pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(4),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_si_iv_ids(siv),
		p_default_value 		=> garn_si_iv_dflt(siv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_si_iv_names(siv),
		p_db_items_flag 		=> garn_si_iv_dbi(siv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(4),
			p_input_value_id  	=> garn_si_iv_ids(siv),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_si_iv_dflt(siv),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      garn_si_iv_ids(siv) := already_exists;

    end if;

  END LOOP;


--
-- Now create all special features element input values.
--
  hr_utility.trace('SFV ivs = '||to_char(l_num_sf_ivs));
  FOR sfv in 1..l_num_sf_ivs LOOP
      hr_utility.trace('SFV iv # = '||to_char(sfv));

    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(5),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_sf_iv_names(sfv),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

/* 40.15 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(5),
			p_name 	    		=> garn_sf_iv_names(sfv),
			p_uom_code 			=> garn_sf_iv_uom(sfv),
			p_mandatory_flag 	=> garn_sf_iv_mand(sfv),
			p_generate_db_item_flag => garn_sf_iv_dbi(sfv),
            p_default_value         => garn_sf_iv_dflt(sfv),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_sf_iv_lkp(sfv),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_sf_iv_seq(sfv),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_sf_iv_ids(sfv) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(5),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_sf_iv_ids(sfv),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_sf_iv_mand(sfv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_sf_iv_names(sfv),
		p_uom 				=> garn_sf_iv_uom(sfv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_sf_iv_dflt(sfv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_sf_iv_dbi(sfv),
		p_warning_or_error 		=> NULL);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(5),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_sf_iv_ids(sfv),
		p_default_value 		=> garn_sf_iv_dflt(sfv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_sf_iv_names(sfv),
		p_db_items_flag 		=> garn_sf_iv_dbi(sfv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(5),
			p_name 	     		=> garn_sf_iv_names(sfv),
			p_uom_code 			=> garn_sf_iv_uom(sfv),
			p_mandatory_flag 	=> garn_sf_iv_mand(sfv),
			p_generate_db_item_flag => garn_sf_iv_dbi(sfv),
            p_default_value         => garn_sf_iv_dflt(sfv),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_sf_iv_lkp(sfv),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_sf_iv_seq(sfv),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_sf_iv_ids(sfv) := v_inpval_id;

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(5),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_sf_iv_ids(sfv),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_sf_iv_mand(sfv),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_sf_iv_names(sfv),
		p_uom 				=> garn_sf_iv_uom(sfv),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_sf_iv_dflt(sfv),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_sf_iv_dbi(sfv),
		p_warning_or_error 		=> NULL);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(5),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_sf_iv_ids(sfv),
		p_default_value 		=> garn_sf_iv_dflt(sfv),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_sf_iv_names(sfv),
		p_db_items_flag 		=> garn_sf_iv_dbi(sfv),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(5),
			p_input_value_id  	=> garn_sf_iv_ids(sfv),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_sf_iv_dflt(sfv),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      garn_sf_iv_ids(sfv) := already_exists;

    end if;

  END LOOP;

--
-- Now create all fee element input values.
--
  hr_utility.trace('Fee ivs = '||to_char(l_num_fee_ivs));
  FOR lfee in 1..l_num_fee_ivs LOOP
      hr_utility.trace('Fees iv # = '||to_char(lfee));
    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(6),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_fee_iv_names(lfee),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

/* 40.15 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(6),
			p_name 	    		=> garn_fee_iv_names(lfee),
			p_uom_code 			=> garn_fee_iv_uom(lfee),
			p_mandatory_flag 	=> garn_fee_iv_mand(lfee),
			p_generate_db_item_flag => garn_fee_iv_dbi(lfee),
            p_default_value         => garn_fee_iv_dflt(lfee),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_fee_iv_lkp(lfee),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_fee_iv_seq(lfee),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_fee_iv_ids(lfee) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(6),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_fee_iv_ids(lfee),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_fee_iv_mand(lfee),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_fee_iv_names(lfee),
		p_uom 				=> garn_fee_iv_uom(lfee),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_fee_iv_dflt(lfee),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_fee_iv_dbi(lfee),
		p_warning_or_error 		=> NULL);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(6),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_fee_iv_ids(lfee),
		p_default_value 		=> garn_fee_iv_dflt(lfee),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_fee_iv_names(lfee),
		p_db_items_flag 		=> garn_fee_iv_dbi(lfee),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(6),
			p_name 			=> garn_fee_iv_names(lfee),
			p_uom_code 			=> garn_fee_iv_uom(lfee),
			p_mandatory_flag 	=> garn_fee_iv_mand(lfee),
			p_generate_db_item_flag => garn_fee_iv_dbi(lfee),
            p_default_value         => garn_fee_iv_dflt(lfee),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_fee_iv_lkp(lfee),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_fee_iv_seq(lfee),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_fee_iv_ids(lfee) := v_inpval_id;

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(6),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_fee_iv_ids(lfee),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_fee_iv_mand(lfee),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_fee_iv_names(lfee),
		p_uom 				=> garn_fee_iv_uom(lfee),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_fee_iv_dflt(lfee),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_fee_iv_dbi(lfee),
		p_warning_or_error 		=> NULL);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(6),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_fee_iv_ids(lfee),
		p_default_value 		=> garn_fee_iv_dflt(lfee),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_fee_iv_names(lfee),
		p_db_items_flag 		=> garn_fee_iv_dbi(lfee),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(6),
			p_input_value_id  	=> garn_fee_iv_ids(lfee),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_fee_iv_dflt(lfee),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      garn_fee_iv_ids(lfee) := already_exists;

    end if;

  END LOOP;

-- Now create all verifier priority element input values.
--
  hr_utility.trace('VP ivs = '||to_char(l_num_vp_ivs));
  FOR lvp  in 1..l_num_vp_ivs LOOP
      hr_utility.trace('VP iv # = '||to_char(lvp));
    already_exists := hr_template_existence.iv_name_exists(
				p_ele_id	=> garn_ele_ids(7),
				p_bg_id		=> p_bg_id,
				p_iv_name	=> garn_vp_iv_names(lvp),
				p_eff_date	=> g_eff_start_date);
    if already_exists = 0 then

/* 40.15 : Call new API to add input value over life of element if
          upgrade mode = Yes
*/

      IF l_upgrade_mode = 'N' THEN

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(7),
			p_name 			=> garn_vp_iv_names(lvp),
			p_uom_code 			=> garn_vp_iv_uom(lvp),
			p_mandatory_flag 	=> garn_vp_iv_mand(lvp),
			p_generate_db_item_flag => garn_vp_iv_dbi(lvp),
            p_default_value         => garn_vp_iv_dflt(lvp),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_vp_iv_lkp(lvp),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_vp_iv_seq(lvp),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_vp_iv_ids(lvp) := v_inpval_id;

        hr_input_values.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(7),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_vp_iv_ids(lvp),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_vp_iv_mand(lvp),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_vp_iv_names(lvp),
		p_uom 				=> garn_vp_iv_uom(lvp),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_vp_iv_dflt(lvp),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_vp_iv_dbi(lvp),
		p_warning_or_error 		=> NULL);

        hr_input_values.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(7),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_vp_iv_ids(lvp),
		p_default_value 		=> garn_vp_iv_dflt(lvp),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_vp_iv_names(lvp),
		p_db_items_flag 		=> garn_vp_iv_dbi(lvp),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

      ELSE

        v_inpval_id := pay_db_pay_setup.create_input_value (
			p_element_name 		=> garn_ele_names(7),
			p_name 			=> garn_vp_iv_names(lvp),
			p_uom_code 			=> garn_vp_iv_uom(lvp),
			p_mandatory_flag 	=> garn_vp_iv_mand(lvp),
			p_generate_db_item_flag => garn_vp_iv_dbi(lvp),
            p_default_value         => garn_vp_iv_dflt(lvp),
            p_min_value             => NULL,
            p_max_value             => NULL,
            p_warning_or_error      => NULL,
            p_lookup_type           => garn_vp_iv_lkp(lvp),
            p_formula_id            => NULL,
            p_hot_default_flag      => 'N',
			p_display_sequence 	=> garn_vp_iv_seq(lvp),
			p_business_group_name 	=> v_bg_name,
	        p_effective_start_date	=> g_eff_start_date,
            p_effective_end_date   	=> g_eff_end_date);

        garn_vp_iv_ids(lvp) := v_inpval_id;

        pay_template_ivs.chk_input_value(
		p_element_type_id 		=> garn_ele_ids(7),
		p_legislation_code 		=> g_template_leg_code,
        p_val_start_date 		=> g_eff_start_date,
        p_val_end_date 			=> g_eff_end_date,
		p_insert_update_flag		=> 'UPDATE',
		p_input_value_id 		=> garn_vp_iv_ids(lvp),
		p_rowid 			=> NULL,
		p_recurring_flag 		=> 'N',
		p_mandatory_flag 		=> garn_vp_iv_mand(lvp),
		p_hot_default_flag 		=> 'N',
		p_standard_link_flag 		=> 'N',
		p_classification_type 		=> 'N',
		p_name 				=> garn_vp_iv_names(lvp),
		p_uom 				=> garn_vp_iv_uom(lvp),
		p_min_value 			=> NULL,
		p_max_value 			=> NULL,
		p_default_value 		=> NULL,
		p_lookup_type 			=> garn_vp_iv_dflt(lvp),
		p_formula_id 			=> NULL,
		p_generate_db_items_flag 	=> garn_vp_iv_dbi(lvp),
		p_warning_or_error 		=> NULL);

        pay_template_ivs.ins_3p_input_values(
		p_val_start_date 		=> g_eff_start_date,
		p_val_end_date 			=> g_eff_end_date,
		p_element_type_id 		=> garn_ele_ids(7),
		p_primary_classification_id 	=> g_ele_class_id,
		p_input_value_id 		=> garn_vp_iv_ids(lvp),
		p_default_value 		=> garn_vp_iv_dflt(lvp),
		p_max_value 			=> NULL,
		p_min_value 			=> NULL,
		p_warning_or_error_flag 	=> NULL,
		p_input_value_name 		=> garn_vp_iv_names(lvp),
		p_db_items_flag 		=> garn_vp_iv_dbi(lvp),
		p_costable_type			=> NULL,
		p_hot_default_flag 		=> 'N',
		p_business_group_id 		=> p_bg_id,
		p_legislation_code 		=> NULL,
		p_startup_mode 			=> NULL);

        pay_template_ivs.new_input_value (
			p_element_type_id 	=> garn_ele_ids(7),
			p_input_value_id  	=> garn_vp_iv_ids(lvp),
			p_costed_flag	  	=> 'N',
			p_default_value	  	=> garn_vp_iv_dflt(lvp),
			p_max_value	  	=> NULL,
			p_min_value	  	=> NULL,
			p_warning_or_error	=> NULL);

      END IF;

    else

      garn_vp_iv_ids(lvp) := already_exists;

    end if;

  END LOOP;
--
-- Now insert appropriate formula_result_rules for this element, now that
-- all elements and input values are created.
--

  -- Formula result rule param settings:
  garn_base_frr_name(1)		:= 'AMT';
  garn_base_frr_type(1)		:= 'I';
  garn_base_frr_ele_id(1)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(1)	:= garn_calc_iv_ids(1);
  garn_base_frr_severity(1)	:= NULL;

  garn_base_frr_name(2)		:= 'OWED';
  garn_base_frr_type(2)		:= 'I';
  garn_base_frr_ele_id(2)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(2)	:= garn_calc_iv_ids(3);
  garn_base_frr_severity(2)	:= NULL;

  garn_base_frr_name(3)		:= 'SERVED';
  garn_base_frr_type(3)		:= 'I';
  garn_base_frr_ele_id(3)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(3)	:= garn_calc_iv_ids(4);
  garn_base_frr_severity(3)	:= NULL;

  garn_base_frr_name(4)		:= 'ARREARS_OVERRIDE';
  garn_base_frr_type(4)		:= 'I';
  garn_base_frr_ele_id(4)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(4)	:= garn_calc_iv_ids(5);
  garn_base_frr_severity(4)	:= NULL;

  garn_base_frr_name(5)		:= 'NUM_DEPS';
  garn_base_frr_type(5)		:= 'I';
  garn_base_frr_ele_id(5)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(5)	:= garn_calc_iv_ids(7);
  garn_base_frr_severity(5)	:= NULL;

  garn_base_frr_name(6)		:= 'FIL_STAT';
  garn_base_frr_type(6)		:= 'I';
  garn_base_frr_ele_id(6)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(6)	:= garn_calc_iv_ids(8);
  garn_base_frr_severity(6)	:= NULL;

  garn_base_frr_name(7)		:= 'ALLOWS';
  garn_base_frr_type(7)		:= 'I';
  garn_base_frr_ele_id(7)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(7)	:= garn_calc_iv_ids(9);
  garn_base_frr_severity(7)	:= NULL;

  garn_base_frr_name(8)		:= 'DEDN_OVERRIDE';
  garn_base_frr_type(8)		:= 'I';
  garn_base_frr_ele_id(8)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(8)	:= garn_calc_iv_ids(10);
  garn_base_frr_severity(8)	:= NULL;

  garn_base_frr_name(9)		:= 'ADDITIONAL_AMOUNT_BALANCE';
  garn_base_frr_type(9)		:= 'I';
  garn_base_frr_ele_id(9)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(9)	:= garn_calc_iv_ids(11);
  garn_base_frr_severity(9)	:= NULL;

  garn_base_frr_name(10)	:= 'REPLACEMENT_AMOUNT_BALANCE';
  garn_base_frr_type(10)	:= 'I';
  garn_base_frr_ele_id(10)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(10)	:= garn_calc_iv_ids(12);
  garn_base_frr_severity(10)	:= NULL;

  garn_base_frr_name(11)	:= 'ARREARS_AMOUNT_BALANCE';
  garn_base_frr_type(11)	:= 'I';
  garn_base_frr_ele_id(11)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(11)	:= garn_calc_iv_ids(13);
  garn_base_frr_severity(11)	:= NULL;

  garn_base_frr_name(12)	:= 'PRIMARY_AMOUNT_BALANCE';
  garn_base_frr_type(12)	:= 'I';
  garn_base_frr_ele_id(12)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(12)	:= garn_calc_iv_ids(14);
  garn_base_frr_severity(12)	:= NULL;

  garn_base_frr_name(13)	:= 'JURIS_CODE';
  garn_base_frr_type(13)	:= 'I';
  garn_base_frr_ele_id(13)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(13)	:= garn_calc_iv_ids(2);
  garn_base_frr_severity(13)	:= NULL;

  garn_base_frr_name(14)	:= 'PCT';
  garn_base_frr_type(14)	:= 'I';
  garn_base_frr_ele_id(14)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(14)	:= garn_calc_iv_ids(15);
  garn_base_frr_severity(14)	:= NULL;

  garn_base_frr_name(15)	:= 'VOLDEDNS_AT_WRIT';
  garn_base_frr_type(15)	:= 'I';
  garn_base_frr_ele_id(15)	:= garn_ele_ids(5);
  garn_base_frr_iv_id(15)	:= garn_SF_IV_IDS(8);
  garn_base_frr_severity(15)	:= NULL;

  garn_base_frr_name(16)	:= 'SUPP_OTHER_FAM';
  garn_base_frr_type(16)	:= 'I';
  garn_base_frr_ele_id(16)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(16)	:= garn_calc_iv_ids(16);
  garn_base_frr_severity(16)	:= NULL;

  garn_base_frr_name(17)	:= 'CALC_SUBPRIO';
  garn_base_frr_type(17)	:= 'O';
  garn_base_frr_ele_id(17)	:= garn_ele_ids(2);
  garn_base_frr_iv_id(17)	:= NULL;
  garn_base_frr_severity(17)	:= NULL;

  garn_base_frr_name(18)       	:= 'ARREARS_DATE';
  garn_base_frr_type(18)        := 'I';
  garn_base_frr_ele_id(18)     	:= garn_ele_ids(2);
  garn_base_frr_iv_id(18)       := garn_calc_iv_ids(6);
  garn_base_frr_severity(18)   	:= NULL;

  garn_base_frr_name(19)       := 'MONTH_CAP_AMT';
  garn_base_frr_type(19)       := 'I';
  garn_base_frr_ele_id(19)     := garn_ele_ids(2);
  garn_base_frr_iv_id(19)      := garn_calc_iv_ids(17);
  garn_base_frr_severity(19)   := NULL;

  garn_base_frr_name(20)       := 'MTD_BAL';
  garn_base_frr_type(20)       := 'I';
  garn_base_frr_ele_id(20)     := garn_ele_ids(2);
  garn_base_frr_iv_id(20)      := garn_calc_iv_ids(18);
  garn_base_frr_severity(20)   := NULL;

  garn_base_frr_name(21)       := 'EXEMPT_AMT';
  garn_base_frr_type(21)       := 'I';
  garn_base_frr_ele_id(21)     := garn_ele_ids(2);
  garn_base_frr_iv_id(21)      := garn_calc_iv_ids(19);
  garn_base_frr_severity(21)   := NULL;

  garn_base_frr_name(22)       := 'PTD_CAP_AMT';
  garn_base_frr_type(22)       := 'I';
  garn_base_frr_ele_id(22)     := garn_ele_ids(2);
  garn_base_frr_iv_id(22)      := garn_calc_iv_ids(20);
  garn_base_frr_severity(22)   := NULL;

  garn_base_frr_name(23)       := 'PTD_BAL';
  garn_base_frr_type(23)       := 'I';
  garn_base_frr_ele_id(23)     := garn_ele_ids(2);
  garn_base_frr_iv_id(23)      := garn_calc_iv_ids(21);
  garn_base_frr_severity(23)   := NULL;

  garn_base_frr_name(24)       := 'CA_ACCRUED_FEES';
  garn_base_frr_type(24)       := 'I';
  garn_base_frr_ele_id(24)     := garn_ele_ids(2);
  garn_base_frr_iv_id(24)      := garn_calc_iv_ids(22);
  garn_base_frr_severity(24)   := NULL;

  garn_base_frr_name(25)       := 'CA_PTD_FEE_BAL';
  garn_base_frr_type(25)       := 'I';
  garn_base_frr_ele_id(25)     := garn_ele_ids(2);
  garn_base_frr_iv_id(25)      := garn_calc_iv_ids(23);
  garn_base_frr_severity(25)   := NULL;

  garn_base_frr_name(26)       := 'CA_MONTH_FEE_BAL';
  garn_base_frr_type(26)       := 'I';
  garn_base_frr_ele_id(26)     := garn_ele_ids(2);
  garn_base_frr_iv_id(26)      := garn_calc_iv_ids(24);
  garn_base_frr_severity(26)   := NULL;

  garn_base_frr_name(27)       := 'TO_ACCRUED_FEES';
  garn_base_frr_type(27)       := 'I';
  garn_base_frr_ele_id(27)     := garn_ele_ids(2);
  garn_base_frr_iv_id(27)      := garn_calc_iv_ids(25);
  garn_base_frr_severity(27)   := NULL;

  l_num_base_resrules           := 27;

  garn_calc_frr_name(1)		:= 'TO_COUNT';
  garn_calc_frr_type(1)		:= 'I';
  garn_calc_frr_iv_id(1)	:= garn_SF_IV_IDS(7);
  garn_calc_frr_ele_id(1)	:= garn_ele_ids(5);
  garn_calc_frr_severity(1)	:= NULL;

  garn_calc_frr_name(2)		:= 'MESG';
  garn_calc_frr_type(2)		:= 'M';
  garn_calc_frr_iv_id(2)	:= NULL;
  garn_calc_frr_ele_id(2)	:= NULL;
  garn_calc_frr_severity(2)	:= 'W';

  garn_calc_frr_name(3)		:= 'VERIFY_DEDN_AMT';
  garn_calc_frr_type(3)		:= 'I';
  garn_calc_frr_iv_id(3)	:= garn_vp_iv_ids(1);
  garn_calc_frr_ele_id(3)	:= garn_ele_ids(7);
  garn_calc_frr_severity(3)	:= NULL;

  garn_calc_frr_name(4)		:= 'VERIFY_ARREARS_AMT';
  garn_calc_frr_type(4)		:= 'I';
  garn_calc_frr_iv_id(4)	:= garn_vp_iv_ids(5);
  garn_calc_frr_ele_id(4)	:= garn_ele_ids(7);
  garn_calc_frr_severity(4)	:= NULL;

  garn_calc_frr_name(5)		:= 'VERIFY_FEE_AMT';
  garn_calc_frr_type(5)		:= 'I';
  garn_calc_frr_iv_id(5)	:= garn_vp_iv_ids(6);
  garn_calc_frr_ele_id(5)	:= garn_ele_ids(7);
  garn_calc_frr_severity(5)	:= NULL;

  garn_calc_frr_name(6)		:= 'DI_SUBJ';
  garn_calc_frr_type(6)		:= 'I';
  garn_calc_frr_iv_id(6)	:= garn_vp_iv_ids(3);
  garn_calc_frr_ele_id(6)	:= garn_ele_ids(7);
  garn_calc_frr_severity(6)	:= NULL;

-- 378699 : If support order, this result now goes to special features iv
-- feeding total dedns bal...otherwise, goes to payval of base ele.
IF p_category in ('CS', 'SS', 'AY') THEN

  garn_calc_frr_name(7)		:= 'CALCD_DEDN_AMT';
  garn_calc_frr_type(7)		:= 'I';
  garn_calc_frr_iv_id(7)	:= garn_sf_iv_ids(4);
  garn_calc_frr_ele_id(7)	:= garn_ele_ids(5);
  garn_calc_frr_severity(7)	:= NULL;

ELSE

  garn_calc_frr_name(7)		:= 'CALCD_DEDN_AMT';
  garn_calc_frr_type(7)		:= 'I';
  garn_calc_frr_iv_id(7)	:= garn_payval_id(1);
  garn_calc_frr_ele_id(7)	:= garn_ele_ids(1);
  garn_calc_frr_severity(7)	:= NULL;

END IF;

  garn_calc_frr_name(8)		:= 'VERIFY_JD_CODE';
  garn_calc_frr_type(8)		:= 'I';
  garn_calc_frr_iv_id(8)	:= garn_vp_iv_ids(4);
  garn_calc_frr_ele_id(8)	:= garn_ele_ids(7);
  garn_calc_frr_severity(8)	:= NULL;

-- 378699 : Result now goes to special features iv feeding total fees bal.
  garn_calc_frr_name(9)		:= 'CALCD_FEE';
  garn_calc_frr_type(9)		:= 'I';
  garn_calc_frr_iv_id(9)	:= garn_sf_iv_ids(3);
  garn_calc_frr_ele_id(9)	:= garn_ele_ids(5);
  garn_calc_frr_severity(9)	:= NULL;

  garn_calc_frr_name(10)	:= 'TO_TOTAL_OWED';
  garn_calc_frr_type(10)	:= 'I';
  garn_calc_frr_iv_id(10)	:= garn_SF_IV_IDS(9);
  garn_calc_frr_ele_id(10)	:= garn_ele_ids(5);
  garn_calc_frr_severity(10)	:= NULL;

  garn_calc_frr_name(11)	:= 'STOP_ENTRY';
  garn_calc_frr_type(11)	:= 'S';
  garn_calc_frr_iv_id(11)	:= garn_payval_id(1);
  garn_calc_frr_ele_id(11)	:= garn_ele_ids(1);
  garn_calc_frr_severity(11)	:= NULL;

  garn_calc_frr_name(12)	:= 'CALCD_ARREARS';
  garn_calc_frr_type(12)	:= 'I';
  garn_calc_frr_iv_id(12)	:= garn_sf_iv_ids(2);
  garn_calc_frr_ele_id(12)	:= garn_ele_ids(5);
  garn_calc_frr_severity(12)	:= NULL;

  garn_calc_frr_name(13)	:= 'NOT_TAKEN';
  garn_calc_frr_type(13)	:= 'I';
  garn_calc_frr_iv_id(13)	:= garn_sf_iv_ids(1);
  garn_calc_frr_ele_id(13)	:= garn_ele_ids(5);
  garn_calc_frr_severity(13)	:= NULL;

  garn_calc_frr_name(14)	:= 'PRIM_BAL';
  garn_calc_frr_type(14)	:= 'I';
  garn_calc_frr_iv_id(14)	:= garn_vp_iv_ids(7);
  garn_calc_frr_ele_id(14)	:= garn_ele_ids(7);
  garn_calc_frr_severity(14)	:= NULL;

  garn_calc_frr_name(15)	:= 'TOTAL_OWED_AMT';
  garn_calc_frr_type(15)	:= 'I';
  garn_calc_frr_ele_id(15)	:= garn_ele_ids(7);
  garn_calc_frr_iv_id(15)	:= garn_vp_iv_ids(8);
  garn_calc_frr_severity(15)	:= NULL;

  garn_calc_frr_name(16)	:= 'VERIF_DATE_SERVED';
  garn_calc_frr_type(16)	:= 'I';
  garn_calc_frr_ele_id(16)	:= garn_ele_ids(7);
  garn_calc_frr_iv_id(16)	:= garn_vp_iv_ids(9);
  garn_calc_frr_severity(16)	:= NULL;


  /* Fatal Error Message */
  garn_calc_frr_name(17)	:= 'FATAL_MESG';
  garn_calc_frr_type(17)	:= 'M';
  garn_calc_frr_iv_id(17)	:= NULL;
  garn_calc_frr_ele_id(17)	:= NULL;
  garn_calc_frr_severity(17)	:= 'F';


  /* Added 05 Mar 1999 for Bug 413086 */
  garn_calc_frr_name(18)	:= 'TO_REPL';
  garn_calc_frr_type(18)	:= 'I';
  garn_calc_frr_iv_id(18)	:= garn_sf_iv_ids(5);
  garn_calc_frr_ele_id(18)	:= garn_ele_ids(5);
  garn_calc_frr_severity(18)	:= NULL;


  garn_calc_frr_name(19)	:= 'TO_ADDL';
  garn_calc_frr_type(19)	:= 'I';
  garn_calc_frr_iv_id(19)	:= garn_sf_iv_ids(6);
  garn_calc_frr_ele_id(19)	:= garn_ele_ids(5);
  garn_calc_frr_severity(19)	:= NULL;

-- 625442 : Calculated fee for non-support garnishments to feed the fee element.
IF p_category not in ('CS','SS','AY') THEN
  garn_calc_frr_name(20)	:= 'GARN_FEE';
  garn_calc_frr_type(20)	:= 'I';
  garn_calc_frr_iv_id(20)	:= garn_fee_iv_ids(1);
  garn_calc_frr_ele_id(20)	:= garn_ele_ids(6);
  garn_calc_frr_severity(20)	:= NULL;

  garn_calc_frr_name(21)        := 'SF_ACCRUED_FEES';
  garn_calc_frr_type(21)        := 'I';
  garn_calc_frr_iv_id(21)       := garn_SF_IV_IDS(10);
  garn_calc_frr_ele_id(21)      := garn_ele_ids(5);
  garn_calc_frr_severity(21)    := NULL;

  l_num_calc_resrules           := 21;
ELSE
  garn_calc_frr_name(20)        := 'DI_SUBJ_NC45';
  garn_calc_frr_type(20)        := 'I';
  garn_calc_frr_ele_id(20)      := garn_ele_ids(7);
  garn_calc_frr_iv_id(20)       := garn_vp_iv_ids(10);
  garn_calc_frr_severity(20)    := NULL;

  garn_calc_frr_name(21)	:= 'CALC_SUBPRIO';
  garn_calc_frr_type(21)	:= 'I';
  garn_calc_frr_ele_id(21)	:= garn_ele_ids(7);
  garn_calc_frr_iv_id(21)	:= garn_vp_iv_ids(2);
  garn_calc_frr_severity(21)	:= NULL;

  garn_calc_frr_name(22)        := 'DI_SUBJ_NC50';
  garn_calc_frr_type(22)        := 'I';
  garn_calc_frr_ele_id(22)      := garn_ele_ids(7);
  garn_calc_frr_iv_id(22)       := garn_vp_iv_ids(11);
  garn_calc_frr_severity(22)    := NULL;

  garn_calc_frr_name(23)        := 'SUPP_OTHER_FAMILY';
  garn_calc_frr_type(23)        := 'I';
  garn_calc_frr_ele_id(23)      := garn_ele_ids(7);
  garn_calc_frr_iv_id(23)       := garn_vp_iv_ids(12);
  garn_calc_frr_severity(23)    := NULL;

  garn_calc_frr_name(24)        := 'PR_ACCRUED_FEES';
  garn_calc_frr_type(24)        := 'I';
  garn_calc_frr_iv_id(24)       := garn_vp_iv_ids(13);
  garn_calc_frr_ele_id(24)      := garn_ele_ids(7);
  garn_calc_frr_severity(24)    := NULL;

  garn_calc_frr_name(25)        := 'PR_PTD_FEE_BAL';
  garn_calc_frr_type(25)        := 'I';
  garn_calc_frr_iv_id(25)       := garn_vp_iv_ids(14);
  garn_calc_frr_ele_id(25)      := garn_ele_ids(7);
  garn_calc_frr_severity(25)    := NULL;

  garn_calc_frr_name(26)        := 'PR_MONTH_FEE_BAL';
  garn_calc_frr_type(26)        := 'I';
  garn_calc_frr_iv_id(26)       := garn_vp_iv_ids(15);
  garn_calc_frr_ele_id(26)      := garn_ele_ids(7);
  garn_calc_frr_severity(26)    := NULL;

  garn_calc_frr_name(27)        := 'SF_ACCRUED_FEES';
  garn_calc_frr_type(27)        := 'I';
  garn_calc_frr_iv_id(27)       := garn_SF_iv_ids(10);
  garn_calc_frr_ele_id(27)      := garn_ele_ids(5);
  garn_calc_frr_severity(27)    := NULL;

  l_num_calc_resrules            := 27;

END IF;

 hr_utility.trace('After inserting Calculated fee for non supported elements');
  garn_verif_frr_name(1)	:= 'WH_DEDN_AMT';
  garn_verif_frr_type(1)	:= 'I';
  garn_verif_frr_iv_id(1)	:= garn_payval_id(1);
  garn_verif_frr_ele_id(1)	:= garn_ele_ids(1);
  garn_verif_frr_severity(1)	:= NULL;

  garn_verif_frr_name(2)	:= 'ARREARS_AMT';
  garn_verif_frr_type(2)	:= 'I';
  garn_verif_frr_iv_id(2)	:= garn_sf_iv_ids(2);
  garn_verif_frr_ele_id(2)	:= garn_ele_ids(5);
  garn_verif_frr_severity(2)	:= NULL;

  garn_verif_frr_name(3)	:= 'WH_FEE_AMT';
  garn_verif_frr_type(3)	:= 'I';
  garn_verif_frr_iv_id(3)	:= garn_fee_iv_ids(1);
  garn_verif_frr_ele_id(3)	:= garn_ele_ids(6);
  garn_verif_frr_severity(3)	:= NULL;

  garn_verif_frr_name(4)	:= 'NOT_TAKEN';
  garn_verif_frr_type(4)	:= 'I';
  garn_verif_frr_iv_id(4)	:= garn_sf_iv_ids(1);
  garn_verif_frr_ele_id(4)	:= garn_ele_ids(5);
  garn_verif_frr_severity(4)	:= NULL;

  garn_verif_frr_name(5)	:= 'TO_TOTAL_OWED';
  garn_verif_frr_type(5)	:= 'I';
  garn_verif_frr_iv_id(5)	:= garn_SF_IV_IDS(9);
  garn_verif_frr_ele_id(5)	:= garn_ele_ids(5);
  garn_verif_frr_severity(5)	:= NULL;

  garn_verif_frr_name(6)	:= 'STOP_ENTRY';
  garn_verif_frr_type(6)	:= 'S';
  garn_verif_frr_iv_id(6)	:= garn_payval_id(1);
  garn_verif_frr_ele_id(6)	:= garn_ele_ids(1);
  garn_verif_frr_severity(6)	:= NULL;

  garn_verif_frr_name(7)	:= 'CALC_SUBPRIO';
  garn_verif_frr_type(7)	:= 'O';
  garn_verif_frr_ele_id(7)	:= garn_ele_ids(6);
  garn_verif_frr_iv_id(7)	:= NULL;
  garn_verif_frr_severity(7)	:= NULL;

  garn_verif_frr_name(8)	:= 'DIFF_DEDN_AMT';
  garn_verif_frr_type(8)	:= 'I';
  garn_verif_frr_iv_id(8)	:= garn_sf_iv_ids(4);
  garn_verif_frr_ele_id(8)	:= garn_ele_ids(5);
  garn_verif_frr_severity(8)    := NULL;

  garn_verif_frr_name(9)        := 'DIFF_FEE_AMT';
  garn_verif_frr_type(9)        := 'I';
  garn_verif_frr_iv_id(9)       := garn_sf_iv_ids(3);
  garn_verif_frr_ele_id(9)      := garn_ele_ids(5);
  garn_verif_frr_severity(9)    := NULL;

  garn_verif_frr_name(10)       := 'MESG';
  garn_verif_frr_type(10)       := 'M';
  garn_verif_frr_iv_id(10)      := NULL;
  garn_verif_frr_ele_id(10)     := NULL;
  garn_verif_frr_severity(10)   := 'W';

  garn_verif_frr_name(11)       := 'FATAL_MESG';
  garn_verif_frr_type(11)       := 'M';
  garn_verif_frr_iv_id(11)      := NULL;
  garn_verif_frr_ele_id(11)     := NULL;
  garn_verif_frr_severity(11)   := 'F';

  garn_verif_frr_name(12)       := 'TO_COUNT';
  garn_verif_frr_type(12)       := 'I';
  garn_verif_frr_iv_id(12)      := garn_SF_IV_IDS(7);
  garn_verif_frr_ele_id(12)     := garn_ele_ids(5);
  garn_verif_frr_severity(12)   := NULL;

  garn_verif_frr_name(13)       := 'SF_ACCRUED_FEES';
  garn_verif_frr_type(13)       := 'I';
  garn_verif_frr_iv_id(13)      := garn_SF_IV_IDS(10);
  garn_verif_frr_ele_id(13)     := garn_ele_ids(5);
  garn_verif_frr_severity(13)   := NULL;

  l_num_verif_resrules		:= 13;

  garn_vp_frr_name(1)       := 'VF_CALC_SUBPRIO';
  garn_vp_frr_type(1)       := 'O';
  garn_vp_frr_iv_id(1)      := NULL;
  garn_vp_frr_ele_id(1)     := garn_ele_ids(3);
  garn_vp_frr_severity(1)   := NULL;

  garn_vp_frr_name(2)       := 'VF_JD_CODE';
  garn_vp_frr_type(2)       := 'I';
  garn_vp_frr_iv_id(2)      := garn_verif_iv_ids(5);
  garn_vp_frr_ele_id(2)     := garn_ele_ids(3);
  garn_vp_frr_severity(2)   := NULL;

  garn_vp_frr_name(3)       := 'VF_DEDN_AMT';
  garn_vp_frr_type(3)	    := 'I';
  garn_vp_frr_iv_id(3)	    := garn_verif_iv_ids(1);
  garn_vp_frr_ele_id(3)	    := garn_ele_ids(3);
  garn_vp_frr_severity(3)   := NULL;

  garn_vp_frr_name(4)       := 'VF_ARREARS_AMT';
  garn_vp_frr_type(4)	    := 'I';
  garn_vp_frr_iv_id(4)	    := garn_verif_iv_ids(2);
  garn_vp_frr_ele_id(4)	    := garn_ele_ids(3);
  garn_vp_frr_severity(4)   := NULL;

  garn_vp_frr_name(5)	    := 'VF_FEE_AMT';
  garn_vp_frr_type(5)       := 'I';
  garn_vp_frr_iv_id(5)	    := garn_verif_iv_ids(3);
  garn_vp_frr_ele_id(5)	    := garn_ele_ids(3);
  garn_vp_frr_severity(5)   := NULL;

  garn_vp_frr_name(6)       := 'VF_DI_SUBJ';
  garn_vp_frr_type(6)	    := 'I';
  garn_vp_frr_iv_id(6)	    := garn_verif_iv_ids(4);
  garn_vp_frr_ele_id(6)	    := garn_ele_ids(3);
  garn_vp_frr_severity(6)   := NULL;

  garn_vp_frr_name(7)       := 'VF_DI_SUBJ_NC45';
  garn_vp_frr_type(7)       := 'I';
  garn_vp_frr_iv_id(7)      := garn_verif_iv_ids(9);
  garn_vp_frr_ele_id(7)     := garn_ele_ids(3);
  garn_vp_frr_severity(7)   := NULL;

  garn_vp_frr_name(8)	    := 'VF_PRIM_BAL';
  garn_vp_frr_type(8)	    := 'I';
  garn_vp_frr_iv_id(8)	    := garn_verif_iv_ids(6);
  garn_vp_frr_ele_id(8)	    := garn_ele_ids(3);
  garn_vp_frr_severity(8)   := NULL;

  garn_vp_frr_name(9)	    := 'VF_TOTAL_OWED_AMT';
  garn_vp_frr_type(9)	    := 'I';
  garn_vp_frr_iv_id(9)	    := garn_verif_iv_ids(7);
  garn_vp_frr_ele_id(9)	    := garn_ele_ids(3);
  garn_vp_frr_severity(9)   := NULL;

  garn_vp_frr_name(10)	    := 'VF_DATE_SERVED';
  garn_vp_frr_type(10)	    := 'I';
  garn_vp_frr_iv_id(10)	    := garn_verif_iv_ids(8);
  garn_vp_frr_ele_id(10)    := garn_ele_ids(3);
  garn_vp_frr_severity(10)  := NULL;

  garn_vp_frr_name(11)      := 'VF_DI_SUBJ_NC50';
  garn_vp_frr_type(11)      := 'I';
  garn_vp_frr_iv_id(11)     := garn_verif_iv_ids(10);
  garn_vp_frr_ele_id(11)    := garn_ele_ids(3);
  garn_vp_frr_severity(11)  := NULL;

  garn_vp_frr_name(12)      := 'VF_SUPP_OTHER_FAMILY';
  garn_vp_frr_type(12)      := 'I';
  garn_vp_frr_iv_id(12)     := garn_verif_iv_ids(11);
  garn_vp_frr_ele_id(12)    := garn_ele_ids(3);
  garn_vp_frr_severity(12)  := NULL;

  garn_vp_frr_name(13)      := 'VF_ACCRUED_FEES';
  garn_vp_frr_type(13)      := 'I';
  garn_vp_frr_iv_id(13)     := garn_verif_iv_ids(12);
  garn_vp_frr_ele_id(13)    := garn_ele_ids(3);
  garn_vp_frr_severity(13)  := NULL;

  garn_vp_frr_name(14)      := 'VF_PTD_FEE_BAL';
  garn_vp_frr_type(14)      := 'I';
  garn_vp_frr_iv_id(14)     := garn_verif_iv_ids(13);
  garn_vp_frr_ele_id(14)    := garn_ele_ids(3);
  garn_vp_frr_severity(14)  := NULL;

  garn_vp_frr_name(15)      := 'VF_MONTH_FEE_BAL';
  garn_vp_frr_type(15)     := 'I';
  garn_vp_frr_iv_id(15)     := garn_verif_iv_ids(14);
  garn_vp_frr_ele_id(15)    := garn_ele_ids(3);
  garn_vp_frr_severity(15)  := NULL;

  l_num_vp_resrules         := 15;


  -- Formula Result Rules for BASE ELEMENT
  -- ie. garn_statproc_rule_id(1)
hr_utility.set_location('Here', 1);
  delete from pay_formula_result_rules_f
  where STATUS_PROCESSING_RULE_ID = garn_statproc_rule_id(1);

hr_utility.set_location('Here', 2);
  FOR n in 1..l_num_base_resrules LOOP


    already_exists := hr_template_existence.result_rule_exists(
				p_spr_id	=> garn_statproc_rule_id(1),
				p_frr_name	=> garn_base_frr_name(n),
				p_iv_id		=> garn_base_frr_iv_id(n),
				p_bg_id		=> p_bg_id,
				p_ele_id	=> garn_base_frr_ele_id(n),
				p_eff_date	=> g_eff_start_date);

hr_utility.set_location('Here', 3);
    if already_exists = 0 then

hr_utility.set_location('Here', 4);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	    p_business_group_id		=> p_bg_id,
  	    p_legislation_code		=> NULL,
  	    p_legislation_subgroup	=> g_template_leg_subgroup,
	    p_effective_start_date	=> g_eff_start_date,
	    p_effective_end_date       	=> g_eff_end_date,
	    p_status_processing_rule_id	=> garn_statproc_rule_id(1),
	    p_input_value_id		=> garn_base_frr_iv_id(n),
	    p_result_name		=> garn_base_frr_name(n),
	    p_result_rule_type		=> garn_base_frr_type(n),
	    p_severity_level		=> garn_base_frr_severity(n),
	    p_element_type_id		=> garn_base_frr_ele_id(n));
hr_utility.set_location('Here', 5);

    else

hr_utility.set_location('Here', 6);
      v_fres_rule_id := already_exists;

    end if;

  END LOOP;

  -- Formula Result Rules for CALCULATION ELEMENT
  -- ie. garn_statproc_rule_id(2)
hr_utility.set_location('Here', 7);
  delete from pay_formula_result_rules_f
  where STATUS_PROCESSING_RULE_ID = garn_statproc_rule_id(2);

hr_utility.set_location('Here', 8);
  FOR o in 1..l_num_calc_resrules LOOP

hr_utility.set_location('Here', 9);
    already_exists := hr_template_existence.result_rule_exists(
				p_spr_id	=> garn_statproc_rule_id(2),
				p_frr_name	=> garn_calc_frr_name(o),
				p_iv_id		=> garn_calc_frr_iv_id(o),
				p_bg_id		=> p_bg_id,
				p_ele_id	=> garn_calc_frr_ele_id(o),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

hr_utility.set_location('Here', 10);

      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	    p_business_group_id		=> p_bg_id,
  	    p_legislation_code		=> NULL,
  	    p_legislation_subgroup	=> g_template_leg_subgroup,
	    p_effective_start_date	=> g_eff_start_date,
	    p_effective_end_date       	=> g_eff_end_date,
	    p_status_processing_rule_id	=> garn_statproc_rule_id(2),
	    p_input_value_id		=> garn_calc_frr_iv_id(o),
	    p_result_name		=> garn_calc_frr_name(o),
	    p_result_rule_type		=> garn_calc_frr_type(o),
	    p_severity_level		=> garn_calc_frr_severity(o),
	    p_element_type_id		=> garn_calc_frr_ele_id(o));

hr_utility.set_location('Here', 11);
    else

      v_fres_rule_id := already_exists;

hr_utility.set_location('Here', 12);
    end if;

  END LOOP;
hr_utility.set_location('Here', 13);

  -- Formula Result Rules for VERIFIER PRIORITY ELEMENT
  -- ie. garn_statproc_rule_id(7)
IF p_category in ('CS', 'SS', 'AY') THEN
hr_utility.set_location('Here', 14);
  delete from pay_formula_result_rules_f
  where STATUS_PROCESSING_RULE_ID = garn_statproc_rule_id(7);
hr_utility.set_location('Here', 15);

  FOR o in 1..l_num_vp_resrules LOOP

hr_utility.set_location('Here', 16);
    already_exists := hr_template_existence.result_rule_exists(
				p_spr_id	=> garn_statproc_rule_id(7),
				p_frr_name	=> garn_vp_frr_name(o),
				p_iv_id		=> garn_vp_frr_iv_id(o),
				p_bg_id		=> p_bg_id,
				p_ele_id	=> garn_vp_frr_ele_id(o),
				p_eff_date	=> g_eff_start_date);

    if already_exists = 0 then

hr_utility.set_location('Here', 17);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	    p_business_group_id		=> p_bg_id,
  	    p_legislation_code		=> NULL,
  	    p_legislation_subgroup	=> g_template_leg_subgroup,
	    p_effective_start_date	=> g_eff_start_date,
	    p_effective_end_date       	=> g_eff_end_date,
	    p_status_processing_rule_id	=> garn_statproc_rule_id(7),
	    p_input_value_id		=> garn_vp_frr_iv_id(o),
	    p_result_name		=> garn_vp_frr_name(o),
	    p_result_rule_type		=> garn_vp_frr_type(o),
	    p_severity_level		=> garn_vp_frr_severity(o),
	    p_element_type_id		=> garn_vp_frr_ele_id(o));

hr_utility.set_location('Here', 18);
    else

      v_fres_rule_id := already_exists;
hr_utility.set_location('Here', 19);

    end if;

  END LOOP;
    end if;

hr_utility.set_location('Here', 20);
  -- Formula Result Rules for VERIFIER ELEMENT
  -- ie. garn_statproc_rule_id(3) , only required for support orders...
IF p_category in ('CS', 'SS', 'AY') THEN
hr_utility.set_location('Here', 21);
  delete from pay_formula_result_rules_f
  where STATUS_PROCESSING_RULE_ID = garn_statproc_rule_id(3);

  FOR p in 1..l_num_verif_resrules LOOP

hr_utility.set_location('Here', 22);
    already_exists := hr_template_existence.result_rule_exists(
				p_spr_id	=> garn_statproc_rule_id(3),
				p_frr_name	=> garn_verif_frr_name(p),
				p_iv_id		=> garn_verif_frr_iv_id(p),
				p_bg_id		=> p_bg_id,
				p_ele_id	=> garn_verif_frr_ele_id(p),
				p_eff_date	=> g_eff_start_date);

hr_utility.set_location('Here', 23);
    if already_exists = 0 then

hr_utility.set_location('Here', 24);
      v_fres_rule_id := pay_formula_results.ins_form_res_rule (
  	    p_business_group_id		=> p_bg_id,
  	    p_legislation_code		=> NULL,
  	    p_legislation_subgroup	=> g_template_leg_subgroup,
	    p_effective_start_date	=> g_eff_start_date,
	    p_effective_end_date       	=> g_eff_end_date,
	    p_status_processing_rule_id	=> garn_statproc_rule_id(3),
	    p_input_value_id		=> garn_verif_frr_iv_id(p),
	    p_result_name		=> garn_verif_frr_name(p),
	    p_result_rule_type		=> garn_verif_frr_type(p),
	    p_severity_level		=> garn_verif_frr_severity(p),
	    p_element_type_id		=> garn_verif_frr_ele_id(p));

    else

      v_fres_rule_id := already_exists;
hr_utility.set_location('Here', 25);

    end if;

  END LOOP;

END IF;

--
-- Now insert appropriate balance feeds.
--

  garn_si_feed_iv_id(1)		:= garn_si_iv_ids(1);
  garn_si_feed_bal_id(1)	:= garn_assoc_bal_ids(3);

  garn_si_feed_iv_id(2)		:= garn_si_iv_ids(2);
  garn_si_feed_bal_id(2)	:= garn_assoc_bal_ids(2);

  garn_si_feed_iv_id(3)		:= garn_si_iv_ids(3);
  garn_si_feed_bal_id(3)	:= garn_assoc_bal_ids(5);

  l_num_si_feeds		:= 3;


  garn_sf_feed_iv_id(1)		:= garn_sf_iv_ids(2);
  garn_sf_feed_bal_id(1)	:= garn_assoc_bal_ids(5);

  garn_sf_feed_iv_id(2)		:= garn_SF_IV_IDS(5);
  garn_sf_feed_bal_id(2)	:= garn_assoc_bal_ids(3);

  garn_sf_feed_iv_id(3)		:= garn_SF_IV_IDS(6);
  garn_sf_feed_bal_id(3)	:= garn_assoc_bal_ids(2);

  garn_sf_feed_iv_id(4)		:= garn_SF_IV_IDS(8);
  garn_sf_feed_bal_id(4)	:= garn_assoc_bal_ids(8);

  garn_sf_feed_iv_id(5)		:= garn_sf_iv_ids(1);
  garn_sf_feed_bal_id(5)	:= garn_assoc_bal_ids(6);

  garn_sf_feed_iv_id(6)		:= garn_SF_IV_IDS(9);
  garn_sf_feed_bal_id(6)	:= garn_assoc_bal_ids(4);

-- 378699 begin
  garn_sf_feed_iv_id(7)		:= garn_sf_iv_ids(3);
  garn_sf_feed_bal_id(7)	:= g_total_fees_balance_id;

  garn_sf_feed_iv_id(8)		:= garn_sf_iv_ids(4);
  garn_sf_feed_bal_id(8)	:= g_total_dedns_balance_id;

-- 378699 end

  garn_sf_feed_iv_id(9)         := garn_SF_IV_IDS(10);
  garn_sf_feed_bal_id(9)        := garn_assoc_bal_ids(9);

  -- 374743 : Treat spousal support and alimony same as child support.
  IF p_category IN ('CS', 'SS', 'AY') THEN

    garn_sf_feed_iv_id(10)	:= garn_SF_IV_IDS(7);
    garn_sf_feed_bal_id(10)	:= g_childsupp_count_balance_id;

/* pre-tax arrearage balance for Support */

    garn_sf_feed_iv_id(11)      := garn_sf_iv_ids(1);
    garn_sf_feed_bal_id(11)     := g_supp_not_taken_bal_id;

    l_num_sf_feeds		:= 11;

  ELSE

/* pre-tax arrearage balance for Other Wage Attachment*/

    garn_sf_feed_iv_id(10)      := garn_sf_iv_ids(1);
    garn_sf_feed_bal_id(10)     := g_other_not_taken_bal_id;


    l_num_sf_feeds		:= 10;

  END IF;

  garn_base_feed_iv_id(1)	:= garn_payval_id(1);
  garn_base_feed_bal_id(1)	:= garn_assoc_bal_ids(1);

  l_num_base_feeds := 1;

/* 378699 : payval is now fed by verifier, feed "total withheld support"
   balance for proration of support in order of receipt.
*/
IF p_category in ('CS', 'SS', 'AY') THEN

  garn_base_feed_iv_id(2)	:= garn_payval_id(1);
  garn_base_feed_bal_id(2)	:= g_wh_support_balance_id;

  /* 2374248 : Created new balance to get desired Amount which is
     input value of Amount rather than using calculated dedn amount */

  garn_base_feed_iv_id(3)       := garn_base_iv_ids(1);
  garn_base_feed_bal_id(3)      := g_total_amount_balance_id;

  l_num_base_feeds := 3;

ELSE

/* 365745 : Feed tax levies high level category balance when wage attachment
   is a tax levy...
*/

  IF p_category = 'TL' THEN

    garn_base_feed_iv_id(2)	:= garn_payval_id(1);
    garn_base_feed_bal_id(2)	:= g_tax_levies_balance_id;

    l_num_base_feeds := 2;


  ELSE

    garn_base_feed_iv_id(2)	:= garn_payval_id(1);
    garn_base_feed_bal_id(2)	:= g_total_dedns_balance_id;

    l_num_base_feeds := 2;

  END IF;

END IF;

/* 365745 : Feed tax levies high level category balance when wage attachment
   is a tax levy...
*/

  IF p_category = 'TL' THEN

    garn_base_feed_iv_id(3)	:= garn_payval_id(1);
    garn_base_feed_bal_id(3)	:= g_tax_levies_balance_id;

    l_num_base_feeds := 3;

  END IF;


  garn_calc_feed_iv_id(1)		:= garn_payval_id(2);
  garn_calc_feed_bal_id(1)	:= garn_assoc_bal_ids(1);

  garn_calc_feed_iv_id(2)		:= garn_payval_id(2);
  garn_calc_feed_bal_id(2)	:= g_total_dedns_balance_id;

  l_num_calc_feeds		:= 2;



  garn_fee_feed_iv_id(1)		:= garn_fee_iv_ids(1);
  garn_fee_feed_bal_id(1)	:= garn_assoc_bal_ids(7);

IF p_category in ('CS', 'SS', 'AY') THEN

  garn_fee_feed_iv_id(2)		:= garn_fee_iv_ids(1);
  garn_fee_feed_bal_id(2)	:= g_wh_fee_balance_id;

  l_num_fee_feeds		:= 2;

ELSE

  l_num_fee_feeds		:= 1;

END IF;


  hr_utility.trace('Base Feeds : '||to_char(l_num_base_feeds));

  FOR i in 1..l_num_base_feeds LOOP

   IF garn_base_feed_iv_id(i) IS NOT NULL THEN

   hr_utility.trace('Bal Id : '||to_char(garn_base_feed_bal_id(i)));
   hr_utility.trace('BG Id  : '||to_char(p_bg_id));
   hr_utility.trace('IV Id  : '||to_char(garn_base_feed_iv_id(i)));
   hr_utility.trace('Date   : '||g_eff_start_date);

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> garn_base_feed_bal_id(i),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_base_feed_iv_id(i),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_base_feed_iv_id(i),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => garn_base_feed_bal_id(i),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

   END IF;

  END LOOP;

   hr_utility.trace('SI Feeds : '||to_char(l_num_si_feeds));

  FOR sif in 1..l_num_si_feeds LOOP

   hr_utility.trace('Bal Id : '||to_char(garn_si_feed_bal_id(sif)));
   hr_utility.trace('BG Id  : '||to_char(p_bg_id));
   hr_utility.trace('IV Id  : '||to_char(garn_si_feed_iv_id(sif)));
   hr_utility.trace('Date   : '||g_eff_start_date);

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> garn_si_feed_bal_id(sif),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_si_feed_iv_id(sif),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_si_feed_iv_id(sif),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => garn_si_feed_bal_id(sif),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;

  hr_utility.trace('SF Feeds : '||to_char(l_num_sf_feeds));

  FOR sf in 1..l_num_sf_feeds LOOP

   hr_utility.trace('l_num_sf_feeds = '||to_char(sf));
   hr_utility.trace('g_other_not_taken_bal_id = '||to_char(g_other_not_taken_bal_id));
   hr_utility.trace('Bal Id : '||to_char(garn_sf_feed_bal_id(sf)));
   hr_utility.trace('BG Id  : '||to_char(p_bg_id));
   hr_utility.trace('IV Id  : '||to_char(garn_sf_feed_iv_id(sf)));
   hr_utility.trace('Date   : '||g_eff_start_date);

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> garn_sf_feed_bal_id(sf),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_sf_feed_iv_id(sf),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_sf_feed_iv_id(sf),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => garn_sf_feed_bal_id(sf),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;

/*
   hr_utility.trace('Calc Feeds : '||to_char(l_num_calc_feeds));

  FOR scf in 1..l_num_calc_feeds LOOP

   hr_utility.trace('Bal Id : '||to_char(garn_calc_feed_bal_id(scf)));
   hr_utility.trace('BG Id  : '||to_char(p_bg_id));
   hr_utility.trace('IV Id  : '||to_char(garn_calc_feed_iv_id(scf)));
   hr_utility.trace('Date   : '||g_eff_start_date);

    already_exists := hr_template_existence.bal_feed_exists(
				p_bal_id       	=> garn_calc_feed_bal_id(scf),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_calc_feed_iv_id(scf),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_calc_feed_iv_id(scf),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => garn_calc_feed_bal_id(scf),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;

   hr_utility.trace('Verif Feeds : '||to_char(l_num_verif_feeds));

  FOR i in 1..l_num_verif_feeds LOOP

   hr_utility.trace('Bal Id : '||to_char(garn_verif_feed_bal_id(sif)));
   hr_utility.trace('BG Id  : '||to_char(p_bg_id));
   hr_utility.trace('IV Id  : '||to_char(garn_verif_feed_iv_id(sif)));
   hr_utility.trace('Date   : '||g_eff_start_date);

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> garn_verif_feed_bal_id(i),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_verif_feed_iv_id(i),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_verif_feed_iv_id(i),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => garn_verif_feed_bal_id(i),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;
*/
   hr_utility.trace('Fee Feeds : '||to_char(l_num_fee_feeds));

 FOR nfee in 1..l_num_fee_feeds LOOP

   hr_utility.trace('Bal Id : '||to_char(garn_fee_feed_bal_id(nfee)));
   hr_utility.trace('BG Id  : '||to_char(p_bg_id));
   hr_utility.trace('IV Id  : '||to_char(garn_fee_feed_iv_id(nfee)));
   hr_utility.trace('Date   : '||g_eff_start_date);

    already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> garn_fee_feed_bal_id(nfee),
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_fee_feed_iv_id(nfee),
				p_eff_date	=> g_eff_start_date);

    if ALREADY_EXISTS = 0 then

      hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_fee_feed_iv_id(nfee),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => garn_fee_feed_bal_id(nfee),
               	p_scale                         => '1',
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

    end if;

  END LOOP;


-- Insert feeds for fee amount input val to balances fed by invol dedns (ie. not automatically
-- created b/c these are not the Fee element Pay Value!).

OPEN get_invol_bals;
    hr_utility.trace('Insert feeds for fee amount input val to balances fed by invol dedns');
    LOOP

       FETCH get_invol_bals INTO	l_involbal_id, l_invol_scale;
       EXIT WHEN get_invol_bals%NOTFOUND;

       hr_utility.trace('Bal Id : '||to_char(l_involbal_id));
       hr_utility.trace('BG Id  : '||to_char(p_bg_id));
       hr_utility.trace('IV Id  : '||to_char(garn_fee_iv_ids(1)));
       hr_utility.trace('Date   : '||g_eff_start_date);

       already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> l_involbal_id,
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_fee_iv_ids(1),
				p_eff_date	=> g_eff_start_date);

       if ALREADY_EXISTS = 0 then

         hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_fee_iv_ids(1),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => l_involbal_id,
               	p_scale                         => l_invol_scale,
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

       end if;

-- Also need to do this for pay value of base element, just in case...
       hr_utility.trace('Also need to do this for pay value of base element');

       hr_utility.trace('Bal Id : '||to_char(l_involbal_id));
       hr_utility.trace('BG Id  : '||to_char(p_bg_id));
       hr_utility.trace('IV Id  : '||to_char(garn_payval_id(1)));
       hr_utility.trace('Date   : '||g_eff_start_date);

       already_exists := hr_template_existence.bal_feed_exists (
				p_bal_id       	=> l_involbal_id,
				p_bg_id		=> p_bg_id,
				p_iv_id		=> garn_payval_id(1),
				p_eff_date	=> g_eff_start_date);

       if ALREADY_EXISTS = 0 then

         hr_balances.ins_balance_feed(
		p_option                        => 'INS_MANUAL_FEED',
               	p_input_value_id                => garn_payval_id(1),
               	p_element_type_id               => NULL,
               	p_primary_classification_id     => NULL,
               	p_sub_classification_id         => NULL,
	       	p_sub_classification_rule_id    => NULL,
               	p_balance_type_id               => l_involbal_id,
               	p_scale                         => l_invol_scale,
               	p_session_date                  => g_eff_start_date,
               	p_business_group                => p_bg_id,
	       	p_legislation_code              => NULL,
               	p_mode                          => 'USER');

       end if;

    END LOOP;
 CLOSE get_invol_bals;

--
-- Now make sure all DDF segs for assoc bals and assoc eles are set for
-- child support.
--
  UPDATE	pay_element_types_f
  SET		element_information5	= garn_ele_ids(2),
		element_information8	= garn_assoc_bal_ids(8),
		element_information10	= garn_assoc_bal_ids(1),
		element_information11	= garn_assoc_bal_ids(4),
                /* Not setting Arrears and Not Taken Balance for bug 980683
                   NotTaken and Arrears are set to 0 in the verifier formula
                   for bug 980683.  However, these balances are needed for
                   bug 2527761.  So, to make both work, the arrears and not taken
                   balance will be created but not set in the Further Element
                   Information Flexfield.

		element_information12	= garn_assoc_bal_ids(5),
		element_information13	= garn_assoc_bal_ids(6),
                */
		element_information16	= garn_assoc_bal_ids(2),
		element_information17	= garn_assoc_bal_ids(3),
		element_information15	= garn_assoc_bal_ids(7) ,
		element_information18	= garn_ele_ids(4),
		element_information19	= garn_ele_ids(5),
		element_information20	= garn_ele_ids(3)
  WHERE	element_type_id	= garn_ele_ids(1);

hr_utility.trace('Before final update Line:4513  garn_assoc_bal_id  '|| to_char(garn_assoc_bal_ids(7)));
  UPDATE	pay_element_types_f
  SET		element_information10	= garn_assoc_bal_ids(7),
              element_information11   = garn_assoc_bal_ids(9)
  WHERE	element_type_id	= garn_ele_ids(6);

  l_base_ele_id := garn_ele_ids(1);

  RETURN l_base_ele_id;
END create_garnishment;

--
------------------------- Deletion procedures -----------------------------
--
-- The following procedure is used to delete all payroll objects related to
-- deduction configurations (esp. involuntary deductions).
-- The element type DDF seggies are utilized as follows:
-- ELEMENT_INFORMATION10 = Associated Primary Balance
-- ELEMENT_INFORMATION11 = Associated Accrued Balance
-- ELEMENT_INFORMATION12 = Associated Arrears Balance
-- ELEMENT_INFORMATION13 = Associated Not Taken Balance
-- ELEMENT_INFORMATION14 = Associated To Bond Purchase Balance
-- ELEMENT_INFORMATION15 = Associated Fee Balance
-- ELEMENT_INFORMATION16 = Associated Additional Amount Balance
-- ELEMENT_INFORMATION17 = Associated Replacement Amount Balance
-- ELEMENT_INFORMATION18 = Associated Special Inputs Element
-- ELEMENT_INFORMATION19 = Associated Special Features Element
-- ELEMENT_INFORMATION20 = Associated Verification Element
-- ELEMENT_INFORMATION5  = Associated Calculation Element
-- NOTE: Further Element Type DDF is full, so associated Fee Element
--       must be found by explicit match on element name.
--
-- Configuration deletion follows this algorithm:
-- 0. Delete frequency rules for wage attachment.
-- 1. Delete all associated balances.
-- 2. For all associated element types of configured wage attachment...
-- 3. Delete all formula result rules.
-- 4. Delete all status processing rules.
-- 5. Delete all formulae...including OLD formulae preserved during upgrades.
-- 6. Delete all input values.
-- 7. Delete element types.
--

PROCEDURE delete_dedn (p_business_group_id	in number,
			p_ele_type_id		in number,
			p_ele_name		in varchar2,
			p_ele_priority		in number,
			p_ele_info_10		in varchar2,
			p_ele_info_11		in varchar2,
			p_ele_info_12		in varchar2,
			p_ele_info_13		in varchar2,
			p_ele_info_14		in varchar2,
			p_ele_info_15		in varchar2,
			p_ele_info_16		in varchar2,
			p_ele_info_17		in varchar2,
			p_ele_info_18		in varchar2,
			p_ele_info_19		in varchar2,
			p_ele_info_20		in varchar2,
			p_ele_info_5		in varchar2,
			p_ele_info_8		in varchar2,
			p_del_sess_date		in date,
			p_del_val_start_date	in date,
			p_del_val_end_date	in date) IS
-- local constants
c_end_of_time  CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');

  TYPE text_table IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  TYPE num_table IS TABLE OF NUMBER(9) INDEX BY BINARY_INTEGER;

  assoc_eles		num_table;
  assoc_bals		num_table;

  i 			number;
  j			number;
  l_num_assoc_bals	number;
  l_num_assoc_eles	number;

-- local vars
v_del_mode		VARCHAR2(80) 	:= 'ZAP'; -- Completely remove template.
v_startup_mode		VARCHAR2(80) 	:= 'USER';
v_del_sess_date 	DATE 		:= NULL;
v_del_val_start 	DATE 		:= NULL;
v_del_val_end		DATE 		:= NULL;
v_bal_type_id		NUMBER(9);
v_eletype_id		NUMBER(9);
v_assoc_eletype_id	NUMBER(9);
v_assoc_ele_priority	NUMBER(9);
v_ff_id			NUMBER(9);
v_ff_count		NUMBER(3);
v_fname_suffix		VARCHAR2(20);
v_eletype_count 	NUMBER(3);
v_baltype_count		NUMBER(3);
v_assoc_bal_type_id	NUMBER(9);
v_assoc_bal_name	VARCHAR2(80);
v_freqrule_id		NUMBER(9);
v_spr_id		NUMBER(9);

v_voldedn_baltype_id	NUMBER(9);
v_template_id           number(9);

l_fee_primary_bal	varchar2(150);
l_fee_primbal_id	number(9);

l_fee_ele_id		number(9);
l_pri_ele_id            number(9);
l_fee_accrued_bal_id    number(9);


CURSOR 	get_formulae(l_ele_id in number) IS
SELECT	distinct ff.formula_id
FROM	pay_status_processing_rules_f spr, ff_formulas_f ff
WHERE	spr.element_type_id = l_ele_id
AND	ff.formula_id = spr.formula_id
AND	ff.business_group_id + 0 = p_business_group_id
AND	ff.legislation_code IS NULL;

CURSOR 	get_old_formulae(l_ele_name in varchar2) IS
SELECT	distinct ff.formula_id
FROM	ff_formulas_f ff
WHERE	ff.formula_name like upper('OLD%'||p_ele_name||'_BALANCE_SETUP_FORMULA%')
AND	ff.business_group_id + 0 = p_business_group_id;

CURSOR 	get_spr(l_ele_id in number) IS
SELECT	distinct status_processing_rule_id
FROM	pay_status_processing_rules_f
WHERE	element_type_id = l_ele_id;

CURSOR	get_freqrule IS
SELECT 	ele_payroll_freq_rule_id
FROM   	pay_ele_payroll_freq_rules
WHERE  	element_type_id = p_ele_type_id;

-- Bug 3682501
-- Cursor to obtain the template id needed to be deleted from the shadow tables
-- for the current element getting deleted
CURSOR  get_template_id IS
SELECT  template_id
  FROM  pay_shadow_element_types
 WHERE  element_name = p_ele_name;

-- Garnishmment Rewrite
-- Changing the select statement to a cursor because in the
-- new architecture we dont have Priority element.
-- Cursor will return NULL for elements created using New architecture
-- Elements created prior to Garnishment Rewrite will return the
-- element_type_id which is then used to delete the Priority element created.
CURSOR c_get_priority IS
SELECT element_type_id
  FROM  pay_element_types_f
 WHERE element_name = p_ele_name||' Priority'
   AND p_del_sess_date between effective_start_date
		             and effective_end_date
   AND business_group_id + 0 = p_business_group_id;

-- Bug 3682501
-- Cursor added to get the balance type ids of 'Arrears' and 'Not Taken' balance
-- as the Further Element Information descriptive flexfield are not set for
-- the mentioned balances. Refer to Bug 2527761 for more information.
CURSOR c_get_bal_type(l_bal_name varchar2) IS
SELECT balance_type_id
  FROM  pay_balance_types
 WHERE balance_name = p_ele_name || l_bal_name
   AND business_group_id + 0 = p_business_group_id;

BEGIN

/** Bug 566328: The select statement below is modified to put business group id
     in the where clause. Because now it is allowing to enter deduction with
	  same name in different business groups( ref. Bug 502307), selection only by
	  element name will fetch more than one row and raise error.  **/

select element_type_id
, element_information11
into    l_fee_ele_id
, l_fee_accrued_bal_id
from  pay_element_types_f
where element_name = p_ele_name||' Fees'
and p_del_sess_date between effective_start_date
		             and effective_end_date
and business_group_id + 0 = p_business_group_id ;

-- Garnishment Rewrite
-- Element id for priority element
l_pri_ele_id := NULL;
Open c_get_priority;
Fetch c_get_priority into l_pri_ele_id;
Close c_get_priority;

assoc_eles(1)	:= fnd_number.canonical_to_number(p_ele_info_18);	-- Special Inputs ele
assoc_eles(2)	:= fnd_number.canonical_to_number(p_ele_info_19);	-- Special Features ele
assoc_eles(3)	:= l_fee_ele_id;		-- Fee ele
assoc_eles(4)	:= fnd_number.canonical_to_number(p_ele_info_20);	-- Verifier ele
assoc_eles(5)	:= fnd_number.canonical_to_number(p_ele_info_5);	-- Calculator ele
assoc_eles(6)	:= p_ele_type_id;		-- Base ele
assoc_eles(7)   := l_pri_ele_id;                -- Priority ele

l_num_assoc_eles := 7;

assoc_bals(1)	:= fnd_number.canonical_to_number(p_ele_info_10);	-- Primary bal
assoc_bals(2)	:= fnd_number.canonical_to_number(p_ele_info_11);	-- Accrued bal
assoc_bals(3)	:= fnd_number.canonical_to_number(p_ele_info_12);	-- Arrears bal
assoc_bals(4)	:= fnd_number.canonical_to_number(p_ele_info_13);	-- Not Taken bal
assoc_bals(5)	:= fnd_number.canonical_to_number(p_ele_info_14);	-- To Bond bal
assoc_bals(6)	:= fnd_number.canonical_to_number(p_ele_info_15);	-- Fee bal
assoc_bals(7)	:= fnd_number.canonical_to_number(p_ele_info_16);	-- Additional Amt bal
assoc_bals(8)	:= fnd_number.canonical_to_number(p_ele_info_17);	-- Replacement Amt bal
assoc_bals(9)	:= fnd_number.canonical_to_number(p_ele_info_8);	-- Vol Dedns bal

assoc_bals(10)	:= l_fee_accrued_bal_id;	-- Fee Accrued bal

-- Bug 3682501
-- Populating the balance_type_id for Arrears balance
v_bal_type_id := null;
open c_get_bal_type(' Arrears');
fetch c_get_bal_type into v_bal_type_id;
if v_bal_type_id is not null then
   assoc_bals(3) := fnd_number.canonical_to_number(v_bal_type_id);
end if;
close c_get_bal_type;

-- Bug 3682501
-- Populating the balance_type_id for Not Taken balance
v_bal_type_id := null;
open c_get_bal_type(' Not Taken');
fetch c_get_bal_type into v_bal_type_id;
if v_bal_type_id is not null then
   assoc_bals(4) := fnd_number.canonical_to_number(v_bal_type_id);
end if;
close c_get_bal_type;

l_num_assoc_bals := 10;

-- Populate vars.
v_del_val_end		:= nvl(p_del_val_end_date, c_end_of_time);
v_del_val_start 	:= nvl(p_del_val_start_date, sysdate);
v_del_sess_date 	:= nvl(p_del_sess_date, sysdate);
--
-- Do not allow direct deletion of any associated element, these will be
-- deleted by deleting the "base" ele.
--
IF p_ele_name like '% Special Features' THEN
  hr_utility.set_location('hr_us_garn_gen.delete_dedn',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Do not allow deletion of Special Inputs ele, delete by deleting base ele:
--
IF p_ele_name like '% Special Inputs' THEN
  hr_utility.set_location('hr_us_garn_gen.delete_dedn',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Do not allow deletion of Calculator element, delete by deleting base ele:
--
IF p_ele_name like '% Calculator' THEN
  hr_utility.set_location('hr_us_garn_gen.delete_dedn',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Do not allow deletion of Verifier element, delete by deleting base ele:
--
IF p_ele_name like '% Verifier' THEN
  hr_utility.set_location('hr_us_garn_gen.delete_dedn',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Do not allow deletion of Fees element, delete by deleting base ele:
--
IF p_ele_name like '% Fees' THEN
  hr_utility.set_location('hr_us_garn_gen.delete_dedn',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;

IF p_ele_name like '% Priority' THEN
  hr_utility.set_location('hr_us_garn_gen.delete_dedn',40);
  hr_utility.set_message(801,'PAY_xxxx_CANNOT_DEL_ELE');
  hr_utility.raise_error;
END IF;
--
-- Delete base ele frequency rule info:
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

-- Bug 3682501
-- Code added for deleting the template
open get_template_id;
fetch get_template_id into v_template_id;
close get_template_id;

-- Check if the element to be deleted was created using CORE template. If yes
-- delete the template created while creating the element.
if v_template_id is not null then
   hr_utility.set_location('hr_us_garn_gen.delete_dedn', 45);
   -- Bug 4680388
   -- Modified the code to use delete_user_structure
   pay_element_template_api.delete_user_structure(
                              p_drop_formula_packages => TRUE
                             ,p_template_id => v_template_id);
end if;


END delete_dedn;

END hr_us_garn_gen;

/
