--------------------------------------------------------
--  DDL for Package Body PAY_JP_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_PAYSLIP_ARCHIVE" AS
/* $Header: pyjpparc.pkb 120.5.12010000.3 2010/03/02 02:47:21 keyazawa ship $ */
--
-- Constants
--
c_package			CONSTANT VARCHAR2(31) := 'pay_jp_payslip_archive.';
-----------------------------------------------------------------------------
-- Set Defined Balance Ids
-----------------------------------------------------------------------------
/*
Corrected balance dimension as _ASG_YTD instead of _ASG_YTD_RUN to fix Bug 5401179
*/
c_ytd_allowance_def_bal_id	CONSTANT NUMBER := hr_jp_id_pkg.defined_balance_id(
							'B_YEA_ERN',
							'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01',
							NULL, 'JP');
c_ytd_sal_taxable_def_bal_id	CONSTANT NUMBER := hr_jp_id_pkg.defined_balance_id(
							'B_YEA_TXBL_ERN_MONEY',
							'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01',
							NULL, 'JP');
c_ytd_mat_taxable_def_bal_id	CONSTANT NUMBER := hr_jp_id_pkg.defined_balance_id(
							'B_YEA_TXBL_ERN_KIND',
							'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01',
							NULL, 'JP');
c_ytd_si_prem_def_bal_id	CONSTANT NUMBER := hr_jp_id_pkg.defined_balance_id(
							'B_YEA_SAL_DCT_SI_PREM',
							'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01',
							NULL, 'JP');
c_ytd_itax_def_bal_id		CONSTANT NUMBER := hr_jp_id_pkg.defined_balance_id(
							'B_YEA_WITHHOLD_ITX',
							'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01',
							NULL, 'JP');
c_ytd_yea_itax_def_bal_id	CONSTANT NUMBER := hr_jp_id_pkg.defined_balance_id(
							'B_YEA_TAX_PAY',
							'_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01',
							NULL, 'JP');
--c_net_pay_bal_id		CONSTANT NUMBER := hr_jp_id_pkg.balance_type_id('B_NET_PAY', null, 'JP');
c_net_pay_bal_id		CONSTANT NUMBER := hr_jp_id_pkg.balance_type_id('B_PAYSLIP_NET_PAY', null, 'JP');
--
-- Global Variables (Concurrent Program parameters)
--
g_arch_payroll_action_id	NUMBER;
g_bg_id				NUMBER;
g_effective_date		date;
--
g_payroll_id			NUMBER;
g_consolidation_set_id		number;
g_payment_date			DATE;
g_payslip_label			pay_action_information.action_information1%type;
-- +--------------------------------------------------------------------------+
-- |-----------------------------< init_globals >-----------------------------|
-- +--------------------------------------------------------------------------+
--
-- 2786851. created
-- Call this in the following procedures.
--   PAY_REPORT_FORMAT_MAPPINGS_F.RANGE_CODE
--   PAY_REPORT_FORMAT_MAPPINGS_F.ASSIGNMENT_ACTION_CODE
--   PAY_REPORT_FORMAT_MAPPINGS_F.INITIALIZATION_CODE
--
procedure init_globals(p_arch_payroll_action_id in number)
is
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'init_globals';
	l_legislative_parameters	pay_payroll_actions.legislative_parameters%type;
	l_start_pos			number;
	l_end_pos			number;
begin
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	-- This global variables deriving routine is only kicked
	-- when global variables are not set.
	-- Once populated, the following code is skipped.
	--
	if g_arch_payroll_action_id is null then
		select	business_group_id,
			effective_date,
			legislative_parameters
		into	g_bg_id,
			g_effective_date,
			l_legislative_parameters
		from	pay_payroll_actions
		where	payroll_action_id = p_arch_payroll_action_id;
		--
		-- Better to change how to derive PAYSLIP_LABEL from legislative parameters.
		-- 1. Replace all "spaces" set in PAYSLIP_LABEL legislative parameter to "underscores" when issueing concurrent programs.
		--    e.g. <Payslip Label>        : Monthly Pay
		--         <Payslip Label Hidden> : PAYSLIP_LABEL=MONTHLY_PAY
		-- 2. All "underscores" are replaced back to "spaces"
		--    e.g. g_payslip_label := replace(pay_core_utils.get_parameter('PAYSLIP_LABEL', l_legislative_parameters), '_', ' ');
		-- Future enhancement.
		--
		g_arch_payroll_action_id	:= p_arch_payroll_action_id;
		g_payroll_id			:= to_number(pay_core_utils.get_parameter('PAYROLL', l_legislative_parameters));
		g_consolidation_set_id		:= to_number(pay_core_utils.get_parameter('CONSOLIDATION', l_legislative_parameters));
		g_payment_date			:= fnd_date.canonical_to_date(pay_core_utils.get_parameter('PAYMENT_DATE', l_legislative_parameters));
		--
		l_start_pos := instr(l_legislative_parameters, 'PAYSLIP_LABEL');
		if l_start_pos > 0 then
			l_start_pos	:= l_start_pos + length('PAYSLIP_LABEL') + 1;
			l_end_pos	:= instr(l_legislative_parameters, 'PAYMENT_DATE') - 2;
			g_payslip_label	:= substr(l_legislative_parameters, l_start_pos, l_end_pos - l_start_pos + 1);
		end if;
		--
		hr_utility.trace('g_arch_payroll_action_id : ' || g_arch_payroll_action_id);
		hr_utility.trace('g_bg_id                  : ' || g_bg_id);
		hr_utility.trace('g_effective_date         : ' || g_effective_date);
		hr_utility.trace('g_payroll_id             : ' || g_payroll_id);
		hr_utility.trace('g_consolidation_set_id   : ' || g_consolidation_set_id);
		hr_utility.trace('g_payment_date           : ' || g_payment_date);
		hr_utility.trace('g_payslip_label          : ' || g_payslip_label);
	end if;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
end init_globals;
-- +--------------------------------------------------------------------------+
-- |-----------------------< setup_payment_information >----------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure is to archive payment information which includes payment date
-- and payslip label. These data are defined at archiver process.
--
PROCEDURE setup_payment_information(p_arch_assignment_action_id IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'setup_payment_information';
	c_action_information_category	constant pay_action_information.action_information_category%type := 'EMPLOYEE PAYMENT INFORMATION';
	l_pay_date_disp			pay_action_information.action_information1%type;
	l_payslip_name			pay_action_information.action_information1%type;
	l_act_info_rec			pay_emp_action_arch.act_info_rec;
	--
	CURSOR csr_element_set_name(cp_arch_assignment_action_id NUMBER) IS
	SELECT	pes.element_set_name
	FROM	pay_element_sets	pes,
		pay_payroll_actions	rppa,	-- run pact
		pay_assignment_actions	rpaa,	-- run assact
		pay_action_interlocks	rpai	-- run interlock by archive assact
	WHERE	rpai.locking_action_id = cp_arch_assignment_action_id
	AND	rpaa.assignment_action_id = rpai.locked_action_id
	AND	rppa.payroll_action_id = rpaa.payroll_action_id
	-- Element Set is available only when "Run"
-- waste of resource to check action_type.
--	AND	rppa.action_type = 'R'
	AND	pes.element_set_id = rppa.element_set_id
	ORDER BY rpaa.action_sequence desc;
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	-- Better to store this with canonical format and apply the following conversion
	-- in framework, but there're many limitations for current online payslip.
	-- Future enhancement required.
	--
	l_pay_date_disp := to_char(g_payment_date, fnd_profile.value_wnps('ICX_DATE_FORMAT_MASK'));
	l_payslip_name := g_payslip_label;
	--
	-- When PAYSLIP_LABEL is not set when running concurrent program,
	-- concatenate the element_set_name of runs locked by current archive assact
	-- order by action_sequence desc.
	--
	IF l_payslip_name IS NULL THEN
		FOR l_element_set_name_rec IN csr_element_set_name(p_arch_assignment_action_id) LOOP
			if l_payslip_name is null then
				l_payslip_name := l_element_set_name_rec.element_set_name;
			else
				l_payslip_name := l_element_set_name_rec.element_set_name || ' ' || l_payslip_name;
			end if;
		END LOOP;
	END IF;
	--
	-- l_payslip_name can be null when
	--   1) PAYSLIP_LABEL legislative parameter is null
	--   2) element_set is not set
	--
	l_payslip_name := trim(l_pay_date_disp || ' ' || l_payslip_name);
	--
	hr_utility.trace('pay_date_disp : ' || l_pay_date_disp);
	hr_utility.trace('payslip_name  : "' || l_payslip_name || '"');
	--
	-- Stack information into global variable
	--
	l_act_info_rec.action_info_category	:= c_action_information_category;
	l_act_info_rec.act_info1		:= l_pay_date_disp;
	l_act_info_rec.act_info2		:= l_payslip_name;
	-- Note the index starts from "0".
	pay_emp_action_arch.lrr_act_tab(pay_emp_action_arch.lrr_act_tab.count) := l_act_info_rec;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END setup_payment_information;
-- +--------------------------------------------------------------------------+
-- |-----------------------< setup_element_information >----------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure is to archive statutory element information.
-- These archived data is displayed on Earnings and Deductions regions.
--
PROCEDURE setup_element_information(p_arch_assignment_action_id IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'setup_element_information';
	c_action_information_category	constant pay_action_information.action_information_category%type := 'JP ELEMENT INFORMATION';
--	l_exists			VARCHAR2(1);
--	l_payment_type			hr_lookups.lookup_code%type;
	l_act_info_rec			pay_emp_action_arch.act_info_rec;
	--
	-- Seems to be better to store "MEANING" information
	-- for the input_values with LOOKUP_TYPE.
	--
        /* Removed the Hint in the below cursor as per Bug# 4674234. */

	CURSOR csr_element_info(cp_arch_assignment_action_id NUMBER) IS
	SELECT /*+ ORDERED */
		rpaa.assignment_id,
		prr.element_type_id,
		NVL(pettl.reporting_name, pettl.element_name) reporting_name,
		prrv.input_value_id,
		prrv.result_value,
		decode(pbf.scale, 1, 'E', -1, 'D', 'O') payment_type
	FROM	pay_action_interlocks		pai,	-- run interlock by archive assact
		pay_assignment_actions		rpaa,	-- run assact
		pay_payroll_actions		rppa,   -- run pact
		pay_run_results			prr,
		pay_run_result_values		prrv,
		pay_balance_feeds_f		pbf,
		pay_element_types_f_tl		pettl
	WHERE	pai.locking_action_id = cp_arch_assignment_action_id
	AND	rpaa.assignment_action_id = pai.locked_action_id
	AND	rppa.payroll_action_id = rpaa.payroll_action_id
	AND	rppa.action_type in ('R', 'Q', 'B')
	AND	prr.assignment_action_id = rpaa.assignment_action_id
	AND	prr.status IN ('P', 'PA')
	AND	prrv.run_result_id = prr.run_result_id
	AND	prrv.result_value IS NOT NULL
	and	pbf.balance_type_id = c_net_pay_bal_id
	and	pbf.input_value_id = prrv.input_value_id
	and	rppa.effective_date
		between pbf.effective_start_date and pbf.effective_end_date
	AND	pettl.element_type_id = prr.element_type_id
	AND	pettl.language = userenv('LANG');
/*
	--
	CURSOR csr_yea_sub_class(
		cp_element_type_id	NUMBER,
		cp_run_effective_date	date) IS
	SELECT	'Y'
	FROM	pay_element_classifications	pec,
		pay_sub_classification_rules_f	sub
	WHERE	pec.classification_name = c_yea_deduction_cl
	and	sub.element_type_id = cp_element_type_id
	AND	pec.classification_id = sub.classification_id
	and	cp_run_effective_date
		between sub.effective_start_date and sub.effective_end_date;
*/
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	FOR l_element_info_rec IN csr_element_info(p_arch_assignment_action_id) LOOP
/*
		--
		-- Earnings
		--
		IF l_element_info_rec.classification_name IN (
			c_sal_allowance_cl,
			c_sal_mat_allowance_cl,
			c_bon_allowance_cl,
			c_bon_mat_allowance_cl,
			c_sp_bon_allowance_cl,
			c_sp_bon_mat_allowance_cl,
			c_term_allowance_cl,
			c_term_mat_allowance_cl) THEN
			l_payment_type := 'E';
		--
		-- Deductions
		--
		ELSIF l_element_info_rec.classification_name IN (
			c_sal_si_prem_res_cl,
			c_sal_si_prem_nr_cl,
			c_sal_deduction_cl,
			c_bon_si_prem_res_cl,
			c_bon_si_prem_nr_cl,
			c_bon_deduction_cl,
			c_sp_bon_si_prem_res_cl,
			c_sp_bon_si_prem_nr_cl,
			c_sp_bon_deduction_cl,
			c_term_deduction_cl) THEN
			l_payment_type := 'D';
		--
		-- YEA case. We can not detect whether the element is deduction or not
		-- from YEA primary classification, so derive the secondary classification
		-- which allows us to distinguish whether it is deduction or not.
		--
		ELSIF l_element_info_rec.classification_name = c_yea_cl THEN
			--
			-- Check Yea Deduction
			--
			OPEN csr_yea_sub_class(l_element_info_rec.element_type_id, l_element_info_rec.run_effective_date);
			FETCH csr_yea_sub_class INTO l_exists;
			--
			-- Deductions
			--
			IF csr_yea_sub_class%FOUND THEN
				l_payment_type := 'D';
			--
			-- Other
			--
			ELSE
				l_payment_type := 'O';
			END IF;
			CLOSE csr_yea_sub_class;
		--
		-- Other
		--
		ELSE
			l_payment_type := 'O';
		END IF;
*/
		--
		hr_utility.trace('action_information_category : ' || c_action_information_category);
		hr_utility.trace('element_type_id             : ' || to_char(l_element_info_rec.element_type_id));
		hr_utility.trace('input_value_id              : ' || to_char(l_element_info_rec.input_value_id));
		hr_utility.trace('reporting_name              : ' || l_element_info_rec.reporting_name);
		hr_utility.trace('payment_type                : ' || l_element_info_rec.payment_type);
		hr_utility.trace('result_value                : ' || l_element_info_rec.result_value);
		--
		-- Stack information into global variable
		--
		l_act_info_rec.assignment_id		:= l_element_info_rec.assignment_id;
		l_act_info_rec.action_info_category	:= c_action_information_category;
		l_act_info_rec.act_info1		:= fnd_number.number_to_canonical(l_element_info_rec.element_type_id);
		l_act_info_rec.act_info2		:= fnd_number.number_to_canonical(l_element_info_rec.input_value_id);
		l_act_info_rec.act_info3		:= l_element_info_rec.reporting_name;
		l_act_info_rec.act_info4		:= l_element_info_rec.payment_type;
		l_act_info_rec.act_info5		:= 'M';
		l_act_info_rec.act_info6		:= l_element_info_rec.result_value;
		-- Note the index starts from "0".
		pay_emp_action_arch.lrr_act_tab(pay_emp_action_arch.lrr_act_tab.count) := l_act_info_rec;
	END LOOP;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END setup_element_information;
-- +--------------------------------------------------------------------------+
-- |----------------------< setup_net_pay_distribution >----------------------|
-- +--------------------------------------------------------------------------+
PROCEDURE setup_net_pay_distribution(p_arch_assignment_action_id IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'setup_net_pay_distribution';
	c_action_information_category	constant pay_action_information.action_information_category%type := 'EMPLOYEE NET PAY DISTRIBUTION';
	l_act_info_rec			pay_emp_action_arch.act_info_rec;
	--
	cursor csr_assact(cp_arch_assignment_action_id number) is
		select	/*+ ORDERED */
			ppaa.assignment_action_id	prepay_assignment_action_id,
			pppa.effective_date		prepay_effective_date,
			ppaa.assignment_id		prepay_assignment_id
		from	pay_action_interlocks	ppai,	-- prepay interlocks by arch assact
			pay_assignment_actions	ppaa,	-- prepay assact
			pay_payroll_actions	pppa	-- prepay pact
		where	ppai.locking_action_id = cp_arch_assignment_action_id
		and	ppaa.assignment_action_id = ppai.locked_action_id
		and	pppa.payroll_action_id = ppaa.payroll_action_id
		and	pppa.action_type in ('P', 'U');
	--
	-- A master prepayments assignment action can have multiple child assignment actions,
	-- but child can not have child assignment actions.
	-- Both master and child assignment actions can have PAY_PRE_PAYMENTS record.
	-- PAY_PRE_PAYMENTS indicates source "Run" assignment_action_id.
	--
	cursor csr_payment(
		cp_prepay_assignment_action_id	number,
		cp_prepay_effective_date	date) is
		select	/*+ ORDERED USE_NL(PPP OPM OPMTL PPT PEA PPM BNK BCH) */
			pea.segment1	bank_code,
			bnk.bank_name,
			bch.branch_name,
			pea.segment4	branch_code,
			hr_general.decode_lookup('PAY_METHOD_PAYMENT_TYPE',
				decode(ppt.category, 'CA', 'CASH', 'MT', 'DEPOSIT', NULL))	payment_type_meaning,
			hr_general.decode_lookup('JP_BANK_ACCOUNT_TYPE', pea.segment7)	account_type_meaning,
			pea.segment7	account_type,
			pea.segment8	account_number,
			pea.segment9	account_name,
			pea.segment10	description1,
			ppp.value,
--			ppp.pre_payment_id,
			opm.org_payment_method_id,
			opmtl.org_payment_method_name,
			opm.currency_code,
			ppm.personal_payment_method_id
		from	(
				select	paa.assignment_action_id
				from	pay_assignment_actions	paa
				connect by prior paa.assignment_action_id = paa.source_action_id
				start with paa.assignment_action_id = cp_prepay_assignment_action_id
			)				v,
			pay_pre_payments		ppp,
			pay_org_payment_methods_f	opm,
			pay_org_payment_methods_f_tl	opmtl,
			pay_payment_types		ppt,
			pay_external_accounts		pea,
			pay_personal_payment_methods_f	ppm,
			pay_jp_banks			bnk,
			pay_jp_bank_branches		bch
		where	ppp.assignment_action_id = v.assignment_action_id
		and	opm.org_payment_method_id = ppp.org_payment_method_id
		and	cp_prepay_effective_date
			between opm.effective_start_date and opm.effective_end_date
		-- Exclude 3rd party pay
		and	opm.defined_balance_id is not null
		and	opmtl.org_payment_method_id = opm.org_payment_method_id
		and	opmtl.language = userenv('LANG')
		and	ppt.payment_type_id = opm.payment_type_id
		-- Exclude 3rd party payment
		and	ppm.personal_payment_method_id(+) = ppp.personal_payment_method_id
		and	cp_prepay_effective_date
			between ppm.effective_start_date(+) and ppm.effective_end_date(+)
		and	pea.external_account_id(+) = ppm.external_account_id
		and	bnk.bank_code(+) = pea.segment1
		and	bch.bank_code(+) = pea.segment1
		and	bch.branch_code(+) = pea.segment4;
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	for l_assact_rec in csr_assact(p_arch_assignment_action_id) loop
		for l_rec in csr_payment(l_assact_rec.prepay_assignment_action_id, l_assact_rec.prepay_effective_date) loop
			--
			-- Stack information into global variable
			--
			l_act_info_rec.assignment_id		:= l_assact_rec.prepay_assignment_id;
			l_act_info_rec.action_info_category	:= c_action_information_category;
			l_act_info_rec.act_info1		:= fnd_number.number_to_canonical(l_rec.org_payment_method_id);
			l_act_info_rec.act_info2		:= fnd_number.number_to_canonical(l_rec.personal_payment_method_id);
--			l_act_info_rec.act_info4		:= null;
			l_act_info_rec.act_info5		:= l_rec.bank_code;
			l_act_info_rec.act_info6		:= l_rec.bank_name;
			l_act_info_rec.act_info7		:= l_rec.branch_name;
			l_act_info_rec.act_info8		:= l_rec.branch_code;
			l_act_info_rec.act_info9		:= l_rec.payment_type_meaning;
			l_act_info_rec.act_info10		:= l_rec.account_type_meaning;
			l_act_info_rec.act_info11		:= l_rec.account_type;
			l_act_info_rec.act_info12		:= l_rec.account_number;
			l_act_info_rec.act_info13		:= l_rec.account_name;
			l_act_info_rec.act_info14		:= l_rec.description1;
--			l_act_info_rec.act_info15		:= fnd_number.number_to_canonical(l_rec.pre_payment_id);
			l_act_info_rec.act_info16		:= fnd_number.number_to_canonical(l_rec.value);
--			l_act_info_rec.act_info17		:= fnd_number.number_to_canonical(l_assact_rec.prepay_assignment_action_id);
			l_act_info_rec.act_info18		:= l_rec.org_payment_method_name;
			-- Note the index starts from "0".
			pay_emp_action_arch.lrr_act_tab(pay_emp_action_arch.lrr_act_tab.count) := l_act_info_rec;
		end loop;
	end loop;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END setup_net_pay_distribution;
-- +--------------------------------------------------------------------------+
-- |---------------------------< setup_ytd_amount >---------------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure is to archive YTD amount for JP statutory information.
-- These archived data is displayed on Year To Date region.
-- If an archiving process includes multiple run processes, balance value
-- is gotten only for the latest run process.
--
PROCEDURE setup_ytd_amount(
	p_run_assignment_action_id	IN NUMBER,
	p_run_effective_date		IN DATE,
	p_run_assignment_id		IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'setup_ytd_amount';
	c_action_information_category	constant pay_action_information.action_information_category%type := 'JP YTD AMOUNT';
	l_allowance_ytd			NUMBER;
	l_taxable_ytd			NUMBER;
	l_si_prem_ytd			NUMBER;
	l_itax_ytd			NUMBER;
	l_act_info_rec			pay_emp_action_arch.act_info_rec;
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	l_allowance_ytd	:= pay_balance_pkg.get_value(c_ytd_allowance_def_bal_id, p_run_assignment_action_id);
	l_taxable_ytd	:= pay_balance_pkg.get_value(c_ytd_sal_taxable_def_bal_id, p_run_assignment_action_id)
			+  pay_balance_pkg.get_value(c_ytd_mat_taxable_def_bal_id, p_run_assignment_action_id);
	l_si_prem_ytd	:= pay_balance_pkg.get_value(c_ytd_si_prem_def_bal_id, p_run_assignment_action_id);
	l_itax_ytd	:= pay_balance_pkg.get_value(c_ytd_itax_def_bal_id, p_run_assignment_action_id)
			+  pay_balance_pkg.get_value(c_ytd_yea_itax_def_bal_id, p_run_assignment_action_id);
	--
	hr_utility.trace('action_information_category : ' || c_action_information_category);
	hr_utility.trace('allowance_ytd               : ' || to_char(l_allowance_ytd));
	hr_utility.trace('taxable_ytd                 : ' || to_char(l_taxable_ytd));
	hr_utility.trace('si_prem_ytd                 : ' || to_char(l_si_prem_ytd));
	hr_utility.trace('itax_ytd                    : ' || to_char(l_itax_ytd));
	hr_utility.trace('run_effective_date          : ' || to_char(p_run_effective_date));
	--
	-- Stack information into global variable
	--
	l_act_info_rec.assignment_id		:= p_run_assignment_id;
	l_act_info_rec.action_info_category	:= c_action_information_category;
	l_act_info_rec.act_info1		:= fnd_number.number_to_canonical(l_allowance_ytd);
	l_act_info_rec.act_info2		:= fnd_number.number_to_canonical(l_taxable_ytd);
	l_act_info_rec.act_info3		:= fnd_number.number_to_canonical(l_si_prem_ytd);
	l_act_info_rec.act_info4		:= fnd_number.number_to_canonical(l_itax_ytd);
	l_act_info_rec.act_info5		:= fnd_date.date_to_canonical(p_run_effective_date); -- Not used
	-- Note the index starts from "0".
	pay_emp_action_arch.lrr_act_tab(pay_emp_action_arch.lrr_act_tab.count) := l_act_info_rec;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END setup_ytd_amount;
-- +--------------------------------------------------------------------------+
-- |--------------------------< setup_eit_element >---------------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure is to archive element which is defined at Organization EIT.
-- This procedure archives from PAY_RUN_RESULT_VALUES while core procedure
-- pay_emp_action_arch.get_employee_other_info archives from PAY_ELEMENT_ENTRY_VALUES_F.
-- These archived data is displayed on Further Information region.
-- Note: The condition to get archive data is the same as global package,
--       pay_emp_action_arch.get_employee_other_info.
--
PROCEDURE setup_eit_element(
	p_arch_assignment_action_id 	IN NUMBER,
	p_organization_id		IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61) := c_package || 'setup_eit_element';
	c_org_information_type		constant hr_org_information_types.org_information_type%type := 'Organization:Payslip Info';
	c_bg_information_type		constant hr_org_information_types.org_information_type%type := 'Business Group:Payslip Info';
	c_action_information_category	constant pay_action_information.action_information_category%type := 'JP ELEMENT INFORMATION';
	c_payment_type			constant hr_lookups.lookup_code%type := 'F';
	l_exists			VARCHAR2(1);
	l_organization_id		number;
	l_org_information_context	hr_organization_information.org_information_context%type;
	l_act_info_rec			pay_emp_action_arch.act_info_rec;
	l_result_value			varchar2(255);
	--
	CURSOR csr_organization_info(
		cp_organization_id	NUMBER,
		cp_org_info_context	VARCHAR2) IS
	SELECT	'Y'
	FROM	hr_organization_information
	WHERE	organization_id = cp_organization_id
	AND	org_information_context = cp_org_info_context;
	--
	CURSOR csr_eit_element(
		cp_arch_assignment_action_id	NUMBER,
		cp_organization_id		NUMBER,
		cp_org_information_context	VARCHAR2) IS
	SELECT	/*+ ORDERED */
		rpaa.assignment_id,
		hoi.org_information2	element_type_id,
		hoi.org_information3	input_value_id,
		nvl(hoi.org_information7, nvl(pettl.reporting_name, pettl.element_name))	reporting_name,
		piv.uom,
		prrv.result_value,
		piv.lookup_type,
		piv.value_set_id
	FROM	pay_action_interlocks		rpai,	-- run interlock by archive assact
		pay_assignment_actions		rpaa,	-- run assact
		pay_payroll_actions		rppa,	-- run pact
		pay_run_results			prr,
		hr_organization_information	hoi,
		pay_element_types_f		pet,
		pay_element_types_f_tl		pettl,
		pay_input_values_f		piv,
		pay_run_result_values		prrv
	WHERE	rpai.locking_action_id = cp_arch_assignment_action_id
	AND	rpaa.assignment_action_id = rpai.locked_action_id
	AND	rppa.payroll_action_id = rpaa.payroll_action_id
	AND	rppa.action_type in ('R', 'Q', 'B')
	AND	prr.assignment_action_id = rpaa.assignment_action_id
	AND	prr.status IN ('P', 'PA')
	AND	hoi.organization_id = cp_organization_id
	AND	hoi.org_information_context = cp_org_information_context
	AND	hoi.org_information1 = 'ELEMENT'
	AND	fnd_number.canonical_to_number(hoi.org_information2) = prr.element_type_id
	and	pet.element_type_id = prr.element_type_id
	and	rppa.effective_date
		between pet.effective_start_date and pet.effective_end_date
	AND	pettl.element_type_id = pet.element_type_id
	AND	pettl.language = userenv('LANG')
	AND	piv.input_value_id = fnd_number.canonical_to_number(hoi.org_information3)
	AND	rppa.effective_date
		between  piv.effective_start_date and piv.effective_end_date
	AND	prrv.input_value_id = piv.input_value_id
	AND	prrv.run_result_id = prr.run_result_id;
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	-- Check whether "ELEMENT" org_information_type is set at HR organization level.
	-- If exists, "ELEMENT" org_information_type at only HR organization level is used,
	-- and "ELEMENT" org_information_type at BG level is ignored.
	--
	OPEN csr_organization_info(p_organization_id, c_org_information_type);
	FETCH csr_organization_info INTO l_exists;
	IF csr_organization_info%NOTFOUND THEN
		l_organization_id := g_bg_id;
		l_org_information_context := c_bg_information_type;
	ELSE
		l_organization_id := p_organization_id;
		l_org_information_context := c_org_information_type;
	END IF;
	CLOSE csr_organization_info;
	--
	FOR l_eit_element_rec IN csr_eit_element(p_arch_assignment_action_id, l_organization_id, l_org_information_context) LOOP
		hr_utility.trace('action_information_category : ' || c_action_information_category);
		hr_utility.trace('element_type_id             : ' || l_eit_element_rec.element_type_id);
		hr_utility.trace('input_value_id              : ' || l_eit_element_rec.input_value_id);
		hr_utility.trace('reporting_name              : ' || l_eit_element_rec.reporting_name);
		hr_utility.trace('payment_type                : ' || c_payment_type);
		hr_utility.trace('uom                         : ' || l_eit_element_rec.uom);
		hr_utility.trace('result_value                : ' || l_eit_element_rec.result_value);
		--
		-- If input value is either "LookupType" or "ValueSet",
		-- decode the value to meaning.
		--
		if l_eit_element_rec.result_value is not null then
			if l_eit_element_rec.lookup_type is not null then
				l_result_value := hr_general.decode_lookup(l_eit_element_rec.lookup_type, l_eit_element_rec.result_value);
				if l_result_value is not null then
					l_eit_element_rec.result_value := l_result_value;
				end if;
			elsif l_eit_element_rec.value_set_id is not null then
				l_result_value := pay_input_values_pkg.decode_vset_value(l_eit_element_rec.value_set_id, l_eit_element_rec.result_value);
				if l_result_value is not null then
					l_eit_element_rec.result_value := l_result_value;
				end if;
			end if;
		end if;
		--
		-- Stack information into global variable
		--
		l_act_info_rec.assignment_id		:= l_eit_element_rec.assignment_id;
		l_act_info_rec.action_info_category	:= c_action_information_category;
		l_act_info_rec.act_info1		:= fnd_number.number_to_canonical(l_eit_element_rec.element_type_id);
		l_act_info_rec.act_info2		:= fnd_number.number_to_canonical(l_eit_element_rec.input_value_id);
		l_act_info_rec.act_info3		:= l_eit_element_rec.reporting_name;
		l_act_info_rec.act_info4		:= c_payment_type;
		l_act_info_rec.act_info5		:= l_eit_element_rec.uom;
		l_act_info_rec.act_info6		:= l_eit_element_rec.result_value;
		-- Note the index starts from "0".
		pay_emp_action_arch.lrr_act_tab(pay_emp_action_arch.lrr_act_tab.count) := l_act_info_rec;
	END LOOP;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END setup_eit_element;
/*
-- +--------------------------------------------------------------------------+
-- |--------------------------< setup_eit_balance >---------------------------|
-- +--------------------------------------------------------------------------+
--
-- Need to remove this procedure when bug.2810320 is fixed
-- This procedure to archive balance which is defined at Organization EIT.
-- These archived data is displayed on Balances region.
-- If an archiving process includes multiple run processes, balance value
-- is gotten only for the latest run process.
--
PROCEDURE setup_eit_balance(
	p_arch_assignment_action_id	IN NUMBER,
	p_arch_assignment_id		in number,
	p_run_assignment_action_id	IN NUMBER,
	p_organization_id		IN NUMBER)
IS
	c_proc	CONSTANT VARCHAR2(61) := c_package || 'setup_eit_balance';
	--
	CURSOR csr_emp_other_info_bal(cp_arch_assignment_action_id NUMBER) IS
	SELECT	pai.action_information_id,
		pai.object_version_number
	FROM	pay_action_information pai
	WHERE	pai.action_context_id = cp_arch_assignment_action_id
	AND	pai.action_context_type = 'AAP'
	AND	pai.action_information_category = 'EMPLOYEE OTHER INFORMATION'
	AND	pai.action_information2 = 'BALANCE';
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	-- Delete balances which has archived in get_personal_information procedure
	-- because balances archived are based on prepay assact, not run assact,
	-- which means only balances with "_PAYMENTS" dimensions are archived.
	--
	FOR l_emp_other_info_bal_rec IN csr_emp_other_info_bal(p_arch_assignment_action_id) LOOP
		pay_action_information_api.delete_action_information(
			p_action_information_id	=> l_emp_other_info_bal_rec.action_information_id,
			p_object_version_number	=> l_emp_other_info_bal_rec.object_version_number);
	END LOOP;
	--
	pay_emp_action_arch.initialization_process;
	pay_emp_action_arch.get_employee_other_info(
		p_run_action_id		=> p_run_assignment_action_id,
		p_assignment_id		=> null,	-- used to derive element entry values
		p_organization_id	=> p_organization_id,
		p_business_group_id	=> g_bg_id,
		p_curr_pymt_eff_date	=> NULL,	-- used to derive element entry values
		p_tax_unit_id		=> NULL);	-- not used by JP legislation
	pay_emp_action_arch.insert_rows_thro_api_process(
		p_action_context_id	=> p_arch_assignment_action_id,
		p_action_context_type	=> 'AAP',
		p_assignment_id		=> p_arch_assignment_id,
		p_tax_unit_id		=> NULL,
		p_curr_pymt_eff_date	=> g_payment_date,
		p_tab_rec_data		=> pay_emp_action_arch.lrr_act_tab);
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END setup_eit_balance;
*/
-- +--------------------------------------------------------------------------+
-- |-----------------------------< range_cursor >-----------------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure returns the SQL statement to select all the employee that may
-- be eligible for online payslip.
-- The archiver uses this cursor to split the people into chunks for parallel
-- processing.
--
PROCEDURE range_cursor(
	p_payroll_action_id	IN NUMBER,
	p_sqlstr		OUT NOCOPY VARCHAR2)
IS
	c_proc	CONSTANT VARCHAR2(61):= c_package || 'range_cursor';
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	init_globals(p_payroll_action_id);
	pay_emp_action_arch.arch_pay_action_level_data(
		p_payroll_action_id => p_payroll_action_id,
		p_payroll_id        => g_payroll_id,
		p_effective_date    => g_payment_date);
	--
	p_sqlstr :=
'SELECT DISTINCT per.person_id
FROM	per_all_people_f	per,
	pay_payroll_actions	ppa
WHERE	ppa.payroll_action_id = :payroll_action_id
AND	ppa.business_group_id + 0 = per.business_group_id
ORDER BY per.person_id';
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END range_cursor;
-- +--------------------------------------------------------------------------+
-- |---------------------------< action_creation >----------------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure creates locking data for run and prepayment assignment actions
-- by archiving assignment action.
-- The successfully completed prepayments are selected and locked by archiving
-- action. All the successfully completed runs under the prepayments are also
-- selected and locked by archiving action.
-- The archive will not pickup already archived prepayments.
-- Note: JP online payslip is given for each archiving action. It's different from
--      the core specification.
--
PROCEDURE action_creation(
	p_payroll_action_id	IN NUMBER,
	p_start_person_id	IN NUMBER,
	p_end_person_id		IN NUMBER,
	p_chunk			IN NUMBER)
IS
	c_proc				CONSTANT VARCHAR2(61):= c_package || 'action_creation';
	l_arch_assignment_action_id	NUMBER;
	l_prepay_assignment_id		NUMBER;
	l_prepay_assignment_action_id	NUMBER;
	--
	CURSOR csr_asg(
		cp_payroll_action_id	NUMBER,
		cp_start_person_id	NUMBER,
		cp_end_person_id	NUMBER,
		cp_payroll_id		NUMBER,
		cp_consolidation_set_id	NUMBER) IS
	SELECT	/*+ ORDERED */
		ppaa.assignment_id		prepay_assignment_id,
		ppaa.assignment_action_id	prepay_assignment_action_id,
		rpaa.assignment_action_id	run_assignment_action_id
	FROM	pay_payroll_actions	xppa,	-- archive pact
		pay_payroll_actions	pppa,	-- prepay pact
		pay_assignment_actions	ppaa,	-- prepay assact
		per_all_assignments_f	paaf,
		pay_action_interlocks	rpai,	-- run interlock by archive assact
		pay_assignment_actions	rpaa,	-- run assact
		pay_payroll_actions	rppa	-- run pact
	WHERE	xppa.payroll_action_id = cp_payroll_action_id
	AND	pppa.payroll_id = cp_payroll_id
	AND	pppa.consolidation_set_id = cp_consolidation_set_id
	AND	pppa.action_type IN ('P', 'U')
	AND	pppa.effective_date
		BETWEEN xppa.start_date AND xppa.effective_date
	AND	ppaa.payroll_action_id = pppa.payroll_action_id
	-- Only lock master prepayment assignment action
	AND	ppaa.source_action_id is null
	AND	ppaa.action_status = 'C'
	AND	paaf.assignment_id = ppaa.assignment_id
	AND	xppa.effective_date
		BETWEEN paaf.effective_start_date AND paaf.effective_end_date
	AND	paaf.person_id
		BETWEEN cp_start_person_id AND cp_end_person_id
	-- The following payroll_id validation will removed in near future.
	AND	paaf.payroll_id + 0 = pppa.payroll_id
	AND	rpai.locking_action_id = ppaa.assignment_action_id
	AND	rpaa.assignment_action_id = rpai.locked_action_id
--	AND	rpaa.action_status = 'C'
	AND	rppa.payroll_action_id = rpaa.payroll_action_id
	AND	rppa.action_type IN ('R', 'Q', 'B')
	AND	NOT EXISTS(
			SELECT	/*+ ORDERED */
				NULL
			FROM	pay_action_interlocks	xpai2,
				pay_assignment_actions	xpaa2,
				pay_payroll_actions	xppa2
			WHERE	xpai2.locked_action_id = ppaa.assignment_action_id
			AND	xpaa2.assignment_action_id = xpai2.locking_action_id
			AND	xppa2.payroll_action_id = xpaa2.payroll_action_id
			AND	xppa2.action_type = 'X'
			AND	xppa2.report_type = 'JPPS')
	AND	NOT EXISTS(
			SELECT	/*+ ORDERED */
				null
			FROM	pay_action_interlocks	vpai,
				pay_assignment_actions	vpaa,
				pay_payroll_actions	vppa
			WHERE	vpai.locked_action_id = rpaa.assignment_action_id
			AND	vpaa.assignment_action_id = vpai.locking_action_id
			AND	vppa.payroll_action_id = vpaa.payroll_action_id
			AND	vppa.action_type = 'V')
	ORDER BY ppaa.assignment_id, ppaa.assignment_action_id
	FOR UPDATE OF paaf.assignment_id;
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	init_globals(p_payroll_action_id);
	--
	FOR l_asg_rec IN csr_asg(
		p_payroll_action_id,
		p_start_person_id,
		p_end_person_id,
		g_payroll_id,
		g_consolidation_set_id) LOOP
		--
		-- Even if multiple prepayment processes match the condition of archiving, only single assignment
		-- action for archiving process should be created.
		--
		IF (l_prepay_assignment_id is null) or (l_prepay_assignment_id <> l_asg_rec.prepay_assignment_id) THEN
			SELECT	pay_assignment_actions_s.NEXTVAL
			INTO	l_arch_assignment_action_id
			FROM	dual;
			--
			-- create an archive assignment action for the master assignment action
			--
			hr_utility.trace('inserting into PAY_ASSIGNMENT_ACTIONS');
			hr_utility.trace('arch_assignmen_action_id : ' || to_char(l_arch_assignment_action_id));
			hr_utility.trace('arch_assignment_id       : ' || to_char(l_asg_rec.prepay_assignment_id));
			--
			hr_nonrun_asact.insact(l_arch_assignment_action_id, l_asg_rec.prepay_assignment_id, p_payroll_action_id, p_chunk, NULL);
		END IF;
		--
		-- If a prepayment process locks multiple run processes, multiple prepayment ids are derived by csr_asg.
		-- But only single prepayment id is required as below.
		--
		IF (l_prepay_assignment_action_id is null) or (l_prepay_assignment_action_id <> l_asg_rec.prepay_assignment_action_id) THEN
			--
			-- create an archive to payroll master assignment action interlock and create an archive to
			-- prepayment assignment action interlock
			--
			hr_utility.trace('inserting into PAY_ACTION_INTERLOCKS (PREPAY)');
			hr_utility.trace('locking_action_id : ' || to_char(l_arch_assignment_action_id));
			hr_utility.trace('locked_action_id  : ' || to_char(l_asg_rec.prepay_assignment_action_id));
			--
			hr_nonrun_asact.insint(l_arch_assignment_action_id, l_asg_rec.prepay_assignment_action_id);
		END IF;
		--
		hr_utility.trace('inserting into PAY_ACTION_INTERLOCKS (RUN)');
		hr_utility.trace('locking_action_id : ' || to_char(l_arch_assignment_action_id));
		hr_utility.trace('locked_action_id  : ' || to_char(l_asg_rec.run_assignment_action_id));
		--
		hr_nonrun_asact.insint(l_arch_assignment_action_id, l_asg_rec.run_assignment_action_id);
		--
		l_prepay_assignment_id		:= l_asg_rec.prepay_assignment_id;
		l_prepay_assignment_action_id	:= l_asg_rec.prepay_assignment_action_id;
	END LOOP;
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END action_creation;
-- +--------------------------------------------------------------------------+
-- |------------------------------< arch_init >-------------------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure is to archive global context at payroll run level.
--
PROCEDURE archinit(p_payroll_action_id IN NUMBER)
IS
	c_proc	CONSTANT VARCHAR2(61):= c_package || 'archinit';
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	init_globals(p_payroll_action_id);
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END archinit;
-- +--------------------------------------------------------------------------+
-- |-----------------------------< archive_code >-----------------------------|
-- +--------------------------------------------------------------------------+
--
-- This procedure is to archive data at assignment action level.
--
PROCEDURE archive_code(
	p_assignment_action_id	IN NUMBER,
	p_effective_date	IN DATE)
IS
	c_proc				CONSTANT VARCHAR2(61):= c_package || 'archive_code';
	l_arch_assignment_id 		NUMBER;
	l_run_assignment_action_id 	NUMBER;
	l_run_assignment_id		number;
	l_run_effective_date		DATE;
	l_time_period_id		NUMBER;
	l_organization_id		NUMBER;
BEGIN
	hr_utility.set_location('Entering ' || c_proc, 10);
	--
	-- Here derives the latest RUN assignment action information
	-- locked by current archive assignment action.
	--
	select	/*+ ORDERED */
		xpaa.assignment_id,
		rpaa.assignment_action_id,
		rpaa.assignment_id,
		rppa.effective_date,
		rppa.time_period_id,
		asg.organization_id
	into	l_arch_assignment_id,
		l_run_assignment_action_id,
		l_run_assignment_id,
		l_run_effective_date,
		l_time_period_id,
		l_organization_id
	from	pay_assignment_actions	xpaa,	-- archive assact
		pay_action_interlocks	rpai,	-- run interlock by archive
		pay_assignment_actions	rpaa,	-- run assact
		pay_payroll_actions	rppa,	-- run pact
		per_all_assignments_f	asg
	where	xpaa.assignment_action_id = p_assignment_action_id
	and	rpai.locking_action_id = xpaa.assignment_action_id
	and	rpaa.assignment_action_id = rpai.locked_action_id
	and	rppa.payroll_action_id = rpaa.payroll_action_id
	and	rppa.action_type in ('R', 'Q', 'B')
	and	asg.assignment_id = rpaa.assignment_id
	and	rppa.effective_date
		between asg.effective_start_date and asg.effective_end_date
	and	not exists(
			select	/*+ ORDERED */
				null
			from	pay_action_interlocks	rpai2,	-- run interlock by archive
				pay_assignment_actions	rpaa2,	-- run assact
				pay_payroll_actions	rppa2	-- run pact
			where	rpai2.locking_action_id = xpaa.assignment_action_id
			and	rpaa2.assignment_action_id = rpai2.locked_action_id
			and	rpaa2.action_sequence > rpaa.action_sequence
			and	rppa2.payroll_action_id = rpaa2.payroll_action_id
			and	rppa2.action_type in ('R', 'Q', 'B'));
	--
	hr_utility.trace('run_assignment_action_id : ' || to_char(l_run_assignment_action_id));
	hr_utility.trace('run_assignment_id        : ' || to_char(l_run_assignment_id));
	hr_utility.trace('run_effective_date       : ' || to_char(l_run_effective_date));
	hr_utility.trace('time_period_id           : ' || to_char(l_time_period_id));
	hr_utility.trace('organization_id          : ' || to_char(l_organization_id));
	--
	-- call generic procedure to retrieve and archive all data for
	-- EMPLOYEE DETAILS, ADDRESS DETAILS and EMPLOYEE OTHER INFORMATION(only balances).
	-- Note EMPLOYEE NET PAY DISTRIBUTION needs to be populated without using US proc
	-- because JP locks multiple prepayment assignment actions by 1 archive assignment action.
	-- This is not supported by US procedure now.
	--
	pay_emp_action_arch.get_personal_information(
		p_payroll_action_id	=> g_arch_payroll_action_id,			-- archive pact (not used)
		p_assactid		=> p_assignment_action_id,			-- pay_action_information.action_context_id
		p_assignment_id 	=> l_arch_assignment_id,			-- Used to archive assignment info
		p_curr_pymt_ass_act_id	=> null,					-- N/A (used for net pay)
		p_curr_eff_date 	=> l_run_effective_date,			-- Used to archive assignment info
		p_date_earned		=> l_run_effective_date,			-- Used to employee info (only required for US previously)
		p_curr_pymt_eff_date	=> l_run_effective_date,			-- pay_action_information.effective_date
		p_tax_unit_id		=> null,					-- N/A (Not used by JP)
		p_time_period_id	=> l_time_period_id,				-- run Time Period Id
		p_ppp_source_action_id	=> null,					-- netpay distribution (for Separate Payment)
		p_ytd_balcall_aaid	=> l_run_assignment_action_id);			-- Used to archive balance. PAYMENTS dimension is not supported in JP.
	--
	-- Clear pay_emp_action_arch.lrr_act_tab global variable
	--
	pay_emp_action_arch.initialization_process;
	--
	-- Archive EMPLOYEE PAYMENT INFORMATION(Payslip Assignment Action Information) into global variable
	--
	setup_payment_information(p_arch_assignment_action_id => p_assignment_action_id);
	--
	-- Archive JP ELEMENT INFORMATION(Earnings/Deductions) into global variable
	--
	setup_element_information(p_arch_assignment_action_id => p_assignment_action_id);
	--
	-- Archive EMPLOYEE NET PAY DISTRIBUTION into global variable
	--
	setup_net_pay_distribution(p_arch_assignment_action_id => p_assignment_action_id);
	--
	-- Archive JP YTD AMOUNT into global variable
	--
	setup_ytd_amount(
		p_run_assignment_action_id	=> l_run_assignment_action_id,
		p_run_effective_date		=> l_run_effective_date,
		p_run_assignment_id		=> l_run_assignment_id);
	--
	-- Archive JP ELEMENT INFORMATION(Run Result) into global variable
	--
	setup_eit_element(
		p_arch_assignment_action_id	=> p_assignment_action_id,
		p_organization_id		=> l_organization_id);
	--
	-- Upload global variable lrr_act_tab into PAY_ACTION_INFORMATION
	--
	pay_emp_action_arch.insert_rows_thro_api_process(
		p_action_context_id	=> p_assignment_action_id,
		p_action_context_type	=> 'AAP',
		p_assignment_id		=> l_arch_assignment_id,
		p_tax_unit_id		=> null,
		p_curr_pymt_eff_date	=> l_run_effective_date,
		p_tab_rec_data		=> pay_emp_action_arch.lrr_act_tab);
	--
	hr_utility.set_location('Leaving ' || c_proc, 20);
END archive_code;
--
PROCEDURE deinitialization_code (p_payroll_action_id IN NUMBER)
IS
	l_dummy		varchar2(1);
	cursor csr_pa_exists is
		select	'Y'
		from	dual
		where	exists(
				select	null
				from	pay_action_information
				where	action_context_id = p_payroll_action_id
				and	action_context_type = 'PA');
BEGIN
	--
	-- "initialization_code" is kicked for each child thread, so arch_pay_action_level_data
	-- should not be called in child threads, but called by parent thread, which means in
	-- either "range_code" or "deinitialization_code".
	-- But "range_code" is not called when retrying, so need to implement payroll level
	-- archiving in deinitialization_code here.
	--
	open csr_pa_exists;
	fetch csr_pa_exists into l_dummy;
	if csr_pa_exists%notfound then
		--
		-- When retrying payroll action whose assignment actions are all "completed",
		-- initialization_code is not called. So init_globals needs to be called here also
		-- to guarantee that all globals are set.
		--
		init_globals(p_payroll_action_id);
		pay_emp_action_arch.arch_pay_action_level_data(
			p_payroll_action_id => p_payroll_action_id,
			p_payroll_id        => g_payroll_id,
			p_effective_date    => g_payment_date);
	end if;
END deinitialization_code;
--
END pay_jp_payslip_archive;

/
