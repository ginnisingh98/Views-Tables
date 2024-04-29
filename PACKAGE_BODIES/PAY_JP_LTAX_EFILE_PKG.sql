--------------------------------------------------------
--  DDL for Package Body PAY_JP_LTAX_EFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_LTAX_EFILE_PKG" as
/* $Header: pyjpltxe.pkb 120.3 2006/11/03 06:52:52 sgottipa noship $ */
--
-- Constants
--
c_package			constant varchar2(31) := 'pay_jp_ltax_efile_pkg.';
c_header_record_formatter	constant ff_formulas_f.formula_name%type := 'LTX_EFILE_WITHHOLD_AGENT_HEADER_PAYMENT';
c_data_record_init		constant ff_formulas_f.formula_name%type := 'LTX_EFILE_LTX_HEADER_PAYMENT';
c_data_record_detail		constant ff_formulas_f.formula_name%type := 'LTX_EFILE_LTX_FOOTER_PAYMENT';
c_data_record_formatter		constant ff_formulas_f.formula_name%type := 'LTX_EFILE_LTX_BODY_PAYMENT';
c_trailer_record_formatter	constant ff_formulas_f.formula_name%type := 'LTX_EFILE_WITHHOLD_AGENT_FOOTER_PAYMENT';
c_end_record_formatter		constant ff_formulas_f.formula_name%type := 'LTX_EFILE_END_PAYMENT';
--
-- Global Variables
--
type t_parameter is record(
	business_group_id		number,
	organization_id			number,
	effective_date			date,
	effective_date_from		date,
	effective_date_to		date);
g_parameter	t_parameter;
--
type t_formula is record(
	header_record_formatter		number,
	data_record_init		number,
	data_record_detail		number,
	data_record_formatter		number,
	trailer_record_formatter	number,
	end_record_formatter		number);
g_formula	t_formula;
--
type t_number_tbl is table of number index by binary_integer;
type t_varchar2_tbl is table of varchar2(255) index by binary_integer;
type t_date_tbl is table of date index by binary_integer;
type t_data is record(
	current_index			number,
	district_code_tbl		t_varchar2_tbl,
	district_name_kana_tbl		t_varchar2_tbl,
	swot_number_tbl			t_varchar2_tbl,
	assignment_id_tbl		t_number_tbl,
	date_earned_tbl			t_date_tbl,
	tax_tbl				t_number_tbl,
	lumpsum_tax_tbl			t_number_tbl,
	term_tax_tbl			t_number_tbl,
	term_income_tbl			t_number_tbl,
	term_district_tax_tbl		t_number_tbl,
	term_prefectural_tax_tbl	t_number_tbl);
g_data		t_data;
-- ----------------------------------------------------------------------------
-- |---------------------------------< init >---------------------------------|
-- ----------------------------------------------------------------------------
procedure init
is
--
  l_count     number := 0;
  l_rec_count number := 1;
--
	l_proc	varchar2(61) := c_package || 'init';
	--
	l_data_record_sort_order	hr_lookups.lookup_code%type := pay_jp_mag_utility_pkg.get_parameter('DATA_RECORD_SORT_ORDER');
	--
  l_district_code      VARCHAR2(255);
  l_district_name_kana VARCHAR2(255);
  l_swot_number        VARCHAR2(255);
  l_assignment_id      pay_action_information.assignment_id%TYPE;
  l_date_earned        pay_payroll_actions.date_earned%TYPE;
  l_ltax               NUMBER;
  l_ltax_lumpsum       NUMBER;
  l_sp_ltax            NUMBER;
  l_sp_ltax_income     NUMBER;
  l_sp_ltax_shi        NUMBER;
  l_sp_ltax_to         NUMBER;
  --
	cursor csr_org is
		--
		-- In header and trailer section, session_date is used as context DATE_EARNED.
		--
		select	hou.business_group_id,
			to_number(hoi.org_information1)	header_record_formatter,
			to_number(hoi.org_information2)	data_record_init,
			to_number(hoi.org_information3)	data_record_detail,
			to_number(hoi.org_information4)	data_record_formatter,
			to_number(hoi.org_information5)	trailer_record_formatter,
			to_number(hoi.org_information6)	end_record_formatter
		from	hr_organization_information	hoi,
			hr_all_organization_units	hou
		where	hou.organization_id = g_parameter.organization_id
		and	hoi.organization_id(+) = hou.organization_id
		and	hoi.org_information_context(+) = 'JP_LTAX_EFILE';
    --
  cursor csr_data(p_sort_order varchar2) is
		--
		-- In body section, context values used in payroll run are
		-- applied to "Payment" formula.
		--
-- Query has been modified to fix Bug 5371071
    select v.assignment_action_id,
           v.ltax_district_code,
           v.assignment_id,
           v.date_earned,
           v.ltax,
           v.ltax_lumpsum,
           v.sp_ltax,
           v.sp_ltax_income,
           v.sp_ltax_shi,
           v.sp_ltax_to
    from    (select pptn.action_information1   assignment_action_id,
                    paan.assignment_id         assignment_id,
                    ppan.date_earned           date_earned,
                    pptn.action_information3   ltax_district_code,
                    pptn.action_information5   ltax,
                    pptn.action_information6   ltax_lumpsum,
                    decode(pptn.action_information3,
                           nvl(pptn.action_information15,pptn.action_information3), pptn.action_information7, 0) sp_ltax,
                    decode(pptn.action_information3,
                           nvl(pptn.action_information15,pptn.action_information3), pptn.action_information8, 0) sp_ltax_income,
                    decode(pptn.action_information3,
                           nvl(pptn.action_information15,pptn.action_information3), pptn.action_information9, 0)  sp_ltax_shi,
                    decode(pptn.action_information3,
                           nvl(pptn.action_information15,pptn.action_information3), pptn.action_information10, 0) sp_ltax_to
             from   pay_payroll_actions     ppan,
                    pay_assignment_actions  paan,
                    pay_action_information  pptn
             where  ppan.business_group_id = g_parameter.business_group_id
             and    ppan.action_type in ('R', 'Q', 'B')
             and    ppan.effective_date
                      between g_parameter.effective_date_from and g_parameter.effective_date_to
             and    paan.payroll_action_id = ppan.payroll_action_id
             and    paan.action_status = 'C'
             and    pptn.action_information_category = 'JP_PRE_TAX_2'
             and    pptn.action_context_type = 'AAP'
             and    pptn.action_information1 = paan.assignment_action_id
             and    pptn.assignment_id = paan.assignment_id
             and    pptn.action_information3 is not null

             union

             select pptl.action_information1    assignment_action_id,
                    paal.assignment_id          assignment_id,
                    ppal.date_earned            date_earned,
                    pptl.action_information15   ltax_district_code,
                    pptl.action_information5    ltax,
                    decode(pptl.action_information15,
                           nvl(pptl.action_information3,pptl.action_information15), pptl.action_information6, 0) ltax_lumpsum,
                    pptl.action_information7    sp_ltax,
                    pptl.action_information8    sp_ltax_income,
                    pptl.action_information9    sp_ltax_shi,
                    pptl.action_information10   sp_ltax_to
             from   pay_payroll_actions     ppal,
                    pay_assignment_actions  paal,
                    pay_action_information  pptl
             where  ppal.business_group_id = g_parameter.business_group_id
             and     ppal.action_type in ('R', 'Q', 'B')
             and     ppal.effective_date
                       between g_parameter.effective_date_from and g_parameter.effective_date_to
             and     paal.payroll_action_id = ppal.payroll_action_id
             and     paal.action_status = 'C'
             and     pptl.action_information_category = 'JP_PRE_TAX_2'
             and     pptl.action_context_type = 'AAP'
             and     pptl.action_information1 = paal.assignment_action_id
             and     pptl.assignment_id = paal.assignment_id
             and     pptl.action_information15 is not null) v,
          per_all_assignments_f           asg,
          per_all_people_f                per
    where asg.assignment_id = v.assignment_id
    and   v.date_earned
            between asg.effective_start_date and asg.effective_end_date
    and   per.person_id = asg.person_id
    and   v.date_earned
            between per.effective_start_date and per.effective_end_date
    order by
            v.ltax_district_code,
            decode(p_sort_order,
              'ASSIGNMENT_NUMBER', asg.assignment_number,
              'EMPLOYEE_NUMBER', per.employee_number,
              nvl(per.order_name, per.full_name));
	--
	-- Function to derive JP legislative "Payment" formula
	--
	function formula_id(p_formula_name in varchar2) return number
	is
		l_formula_id	number;
	begin
		select	min(f.formula_id)
		into	l_formula_id
		from	ff_formula_types	t,
			ff_formulas_f		f
		where	f.formula_name = p_formula_name
		and	f.legislation_code = 'JP'
		and	f.business_group_id is null
		and	t.formula_type_id = f.formula_type_id
		and	t.formula_type_name = 'Payment';
		--
		return l_formula_id;
	end formula_id;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- Execute initialization code only if this is the first run
	--
	if g_parameter.effective_date is null then
		--
		-- Derive concurrent program parameter values from pay_mag_tape
		--
		select	effective_date
		into	g_parameter.effective_date
		from	fnd_sessions
		where	session_id = userenv('sessionid');
		g_parameter.effective_date_from	:= fnd_date.canonical_to_date(pay_jp_mag_utility_pkg.get_parameter('EFFECTIVE_DATE_FROM'));
		g_parameter.effective_date_to	:= fnd_date.canonical_to_date(pay_jp_mag_utility_pkg.get_parameter('EFFECTIVE_DATE_TO'));
		g_parameter.organization_id	:= fnd_number.canonical_to_number(pay_jp_mag_utility_pkg.get_parameter('ORGANIZATION_ID'));
		--
		hr_utility.trace('Session Date        : ' || fnd_date.date_to_canonical(g_parameter.effective_date));
		hr_utility.trace('EFFECTIVE_DATE_FROM : ' || fnd_date.date_to_canonical(g_parameter.effective_date_from));
		hr_utility.trace('EFFECTIVE_DATE_TO   : ' || fnd_date.date_to_canonical(g_parameter.effective_date_to));
		hr_utility.trace('ORGANIZATION_ID     : ' || to_char(g_parameter.organization_id));
		hr_utility.trace('CHARACTER_SET       : ' || pay_jp_mag_utility_pkg.get_parameter('CHARACTER_SET'));
		hr_utility.set_location(l_proc, 20);
		--
		-- Derive 6 formulas to be executed by PYUMAG
		--
		open csr_org;
		fetch csr_org into
			g_parameter.business_group_id,
			g_formula.header_record_formatter,
			g_formula.data_record_init,
			g_formula.data_record_detail,
			g_formula.data_record_formatter,
			g_formula.trailer_record_formatter,
			g_formula.end_record_formatter;
		close csr_org;
		if g_formula.header_record_formatter is null then
			g_formula.header_record_formatter	:= formula_id(c_header_record_formatter);
		end if;
		if g_formula.data_record_init is null then
			g_formula.data_record_init		:= formula_id(c_data_record_init);
		end if;
		if g_formula.data_record_detail is null then
			g_formula.data_record_detail		:= formula_id(c_data_record_detail);
		end if;
		if g_formula.data_record_formatter is null then
			g_formula.data_record_formatter		:= formula_id(c_data_record_formatter);
		end if;
		if g_formula.trailer_record_formatter is null then
			g_formula.trailer_record_formatter	:= formula_id(c_trailer_record_formatter);
		end if;
		if g_formula.end_record_formatter is null then
			g_formula.end_record_formatter		:= formula_id(c_end_record_formatter);
		end if;
		--
		hr_utility.trace('BUSINESS_GROUP_ID        : ' || to_char(g_parameter.business_group_id));
		hr_utility.trace('HEADER_RECORD_FORMATTER  : ' || to_char(g_formula.header_record_formatter));
		hr_utility.trace('DATA_RECORD_INIT         : ' || to_char(g_formula.data_record_init));
		hr_utility.trace('DATA_RECORD_DETAIL       : ' || to_char(g_formula.data_record_detail));
		hr_utility.trace('DATA_RECORD_FORMATTER    : ' || to_char(g_formula.data_record_formatter));
		hr_utility.trace('TRAILER_RECORD_FORMATTER : ' || to_char(g_formula.trailer_record_formatter));
		hr_utility.trace('END_RECORD_FORMATTER     : ' || to_char(g_formula.end_record_formatter));
		hr_utility.set_location(l_proc, 30);
		--
		-- Derive "Data Record" information with BULK COLLECT
		--
		g_data.current_index := 0;
		--
		hr_utility.trace('DATA_RECORD_SORT_ORDER   : ' || l_data_record_sort_order);
--
-- Broken the cursor fetch statement as PL/SQL Code to fix Bug 5371071
--
  for l_rec in csr_data(l_data_record_sort_order)
  loop

    select count(1)
    into   l_count
    from   pay_action_information pai
    where  pai.action_information_category = 'JP_PRE_TAX_1'
    and    pai.action_context_type = 'AAP'
    and    pai.action_information1 = l_rec.assignment_action_id
    and    pai.action_information21 = g_parameter.organization_id
    and    not exists(
             select NULL
             from   pay_action_interlocks   pain,
                    pay_assignment_actions  paan2,
                    pay_payroll_actions     ppan2
             where  pain.locked_action_id = pai.action_information1
             and    paan2.assignment_action_id = pain.locking_action_id
             and    ppan2.payroll_action_id = paan2.payroll_action_id
             and    ppan2.action_type = 'V');

    if (l_count > 0) then
    --
      if ((l_district_code = l_rec.ltax_district_code) and
              l_assignment_id = l_rec.assignment_id) then

        if (l_date_earned is null or l_date_earned < l_rec.date_earned) then
          l_date_earned := l_rec.date_earned;
        end if;

        l_ltax           := l_ltax + l_rec.ltax;
        l_ltax_lumpsum   := l_ltax_lumpsum + l_rec.ltax_lumpsum;
        l_sp_ltax        := l_sp_ltax + l_rec.sp_ltax;
        l_sp_ltax_income := l_sp_ltax_income + l_rec.sp_ltax_income;
        l_sp_ltax_shi    := l_sp_ltax_shi + l_rec.sp_ltax_shi;
        l_sp_ltax_to     := l_sp_ltax_to + l_rec.sp_ltax_to;

      else

        if (l_district_code is null and l_assignment_id is null) then

          l_district_code := l_rec.ltax_district_code;
          l_assignment_id := l_rec.assignment_id;

        elsif ((l_district_code <> l_rec.ltax_district_code) or
               (l_assignment_id <> l_rec.assignment_id)) then

          if (l_ltax <> 0 or l_ltax_lumpsum <> 0 or l_sp_ltax <> 0) then

            g_data.district_code_tbl(l_rec_count) := l_district_code;
            g_data.district_name_kana_tbl(l_rec_count) := l_district_name_kana;
            g_data.swot_number_tbl(l_rec_count) := l_swot_number;
            g_data.assignment_id_tbl(l_rec_count) := l_assignment_id;
            g_data.date_earned_tbl(l_rec_count) := l_date_earned;
            g_data.tax_tbl(l_rec_count) := l_ltax;
            g_data.lumpsum_tax_tbl(l_rec_count) := l_ltax_lumpsum;
            g_data.term_tax_tbl(l_rec_count) := l_sp_ltax;
            g_data.term_income_tbl(l_rec_count) := l_sp_ltax_income;
            g_data.term_district_tax_tbl(l_rec_count) := l_sp_ltax_shi;
            g_data.term_prefectural_tax_tbl(l_rec_count) := l_sp_ltax_to;

            l_rec_count := l_rec_count + 1;

          end if;

        end if;

        if (l_district_name_kana is null or
            l_district_code <> l_rec.ltax_district_code) then

          select adr.district_name_kana,
                 psn.swot_number
          into   l_district_name_kana,
                 l_swot_number
          from   per_jp_address_lookups          adr,
                 pay_jp_swot_numbers             psn
          where  adr.district_code = substrb(l_rec.ltax_district_code, 1, 5)
          and    psn.organization_id(+) = g_parameter.organization_id
          and    psn.district_code(+) = adr.district_code || substrb(l_rec.ltax_district_code,6);

        end if;

        l_district_code  := l_rec.ltax_district_code;
        l_assignment_id  := l_rec.assignment_id;
        l_date_earned    := l_rec.date_earned;
        l_ltax           := l_rec.ltax;
        l_ltax_lumpsum   := l_rec.ltax_lumpsum;
        l_sp_ltax        := l_rec.sp_ltax;
        l_sp_ltax_income := l_rec.sp_ltax_income;
        l_sp_ltax_shi    := l_rec.sp_ltax_shi;
        l_sp_ltax_to     := l_rec.sp_ltax_to;

      end if;

    end if;

  end loop;

  if (l_ltax <> 0 or l_ltax_lumpsum <> 0 or l_sp_ltax <> 0) then
    g_data.district_code_tbl(l_rec_count) := l_district_code;
    g_data.district_name_kana_tbl(l_rec_count) := l_district_name_kana;
    g_data.swot_number_tbl(l_rec_count) := l_swot_number;
    g_data.assignment_id_tbl(l_rec_count) := l_assignment_id;
    g_data.date_earned_tbl(l_rec_count) := l_date_earned;
    g_data.tax_tbl(l_rec_count) := l_ltax;
    g_data.lumpsum_tax_tbl(l_rec_count) := l_ltax_lumpsum;
    g_data.term_tax_tbl(l_rec_count) := l_sp_ltax;
    g_data.term_income_tbl(l_rec_count) := l_sp_ltax_income;
    g_data.term_district_tax_tbl(l_rec_count) := l_sp_ltax_shi;
    g_data.term_prefectural_tax_tbl(l_rec_count) := l_sp_ltax_to;

  end if;
		--
		hr_utility.trace('Num of Data Records : ' || to_char(g_data.district_code_tbl.count));
	end if;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 40);
end init;
-- ----------------------------------------------------------------------------
-- |-----------------------------< run_formula >------------------------------|
-- ----------------------------------------------------------------------------
procedure run_formula
is
	l_proc		varchar2(61) := c_package || 'run_formula';
	--
	l_formula_id	number;
begin
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	-- Execute initialization code
	--
	init;
	--
	-- Dequeue the formula to be executed from the formula queue.
	-- If not exists, setup the formula into the formula queue
	-- and dequeue the first formula from the formula queue.
	--
	l_formula_id := pay_jp_mag_utility_pkg.dequeue_formula;
	if l_formula_id is null then
		g_data.current_index := g_data.current_index + 1;
		--
		if g_data.district_code_tbl.exists(g_data.current_index) then
			if g_data.current_index = 1 then
				pay_jp_mag_utility_pkg.enqueue_formula(g_formula.header_record_formatter);
				pay_jp_mag_utility_pkg.enqueue_formula(g_formula.data_record_init);
			else
				if g_data.district_code_tbl(g_data.current_index) <> g_data.district_code_tbl(g_data.current_index - 1) then
					pay_jp_mag_utility_pkg.enqueue_formula(g_formula.data_record_init);
				end if;
			end if;
			--
			pay_jp_mag_utility_pkg.enqueue_formula(g_formula.data_record_detail);
			--
			if g_data.current_index = g_data.district_code_tbl.count then
				pay_jp_mag_utility_pkg.enqueue_formula(g_formula.data_record_formatter);
				pay_jp_mag_utility_pkg.enqueue_formula(g_formula.trailer_record_formatter);
				pay_jp_mag_utility_pkg.enqueue_formula(g_formula.end_record_formatter);
			else
				if g_data.district_code_tbl(g_data.current_index) <> g_data.district_code_tbl(g_data.current_index + 1) then
					pay_jp_mag_utility_pkg.enqueue_formula(g_formula.data_record_formatter);
				end if;
			end if;
			--
			-- Dequeue the latest formula
			--
			l_formula_id := pay_jp_mag_utility_pkg.dequeue_formula;
		--
		-- The following NO_DATA_FOUND will finishes process successfully
		-- in the following conditions.
		--   1) TRANSFER_END_OF_FILE is not passed to PYUMAG in the last formula.
		--   2) No target assignments are derived.
		--
		else
			raise NO_DATA_FOUND;
		end if;
	end if;
	--
	hr_utility.set_location(l_proc, 20);
	--
	-- Setup contexts and parameters depending on the formula
	-- which is going to be executed by PYUMAG.
	-- Note that all parameter values are inherited to the subsequent formulas,
	-- but contexts available depends on each formula.
	--
	pay_jp_mag_utility_pkg.set_parameter('NEW_FORMULA_ID', l_formula_id, null);
	pay_jp_mag_utility_pkg.clear_contexts;
	--
	-- HEADER_RECORD_FORMATTER
	--
	if l_formula_id = g_formula.header_record_formatter then
		hr_utility.trace('HEADER_RECORD_FORMATTER');
		--
		pay_jp_mag_utility_pkg.set_context('BUSINESS_GROUP_ID',		g_parameter.business_group_id);
		pay_jp_mag_utility_pkg.set_context('DATE_EARNED',		g_parameter.effective_date);
		pay_jp_mag_utility_pkg.set_context('ORGANIZATION_ID',		g_parameter.organization_id);
	--
	-- DATA_RECORD_INIT
	--
	elsif l_formula_id = g_formula.data_record_init then
		hr_utility.trace('DATA_RECORD_INIT');
		--
		pay_jp_mag_utility_pkg.set_context('BUSINESS_GROUP_ID',		g_parameter.business_group_id);
		pay_jp_mag_utility_pkg.set_context('DATE_EARNED',		g_parameter.effective_date);
		pay_jp_mag_utility_pkg.set_context('ORGANIZATION_ID',		g_parameter.organization_id);
		--
		pay_jp_mag_utility_pkg.set_parameter('DISTRICT_CODE', 		g_data.district_code_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('DISTRICT_NAME_KANA', 	g_data.district_name_kana_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('SWOT_NUMBER', 		g_data.swot_number_tbl(g_data.current_index));
	--
	-- DATA_RECORD_DETAIL
	--
	elsif l_formula_id = g_formula.data_record_detail then
		hr_utility.trace('DATA_RECORD_DETAIL');
		--
		pay_jp_mag_utility_pkg.set_context('BUSINESS_GROUP_ID',		g_parameter.business_group_id);
		pay_jp_mag_utility_pkg.set_context('ORGANIZATION_ID',		g_parameter.organization_id);
		pay_jp_mag_utility_pkg.set_context('ASSIGNMENT_ID',		g_data.assignment_id_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_context('DATE_EARNED',		g_data.date_earned_tbl(g_data.current_index));
		--
		pay_jp_mag_utility_pkg.set_parameter('TAX', 			g_data.tax_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('LUMPSUM_TAX', 		g_data.lumpsum_tax_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('TERM_TAX', 		g_data.term_tax_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('TERM_INCOME', 		g_data.term_income_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('TERM_DISTRICT_TAX', 	g_data.term_district_tax_tbl(g_data.current_index));
		pay_jp_mag_utility_pkg.set_parameter('TERM_PREFECTURAL_TAX', 	g_data.term_prefectural_tax_tbl(g_data.current_index));
	--
	-- DATA_RECORD_FORMATTER
	--
	elsif l_formula_id = g_formula.data_record_formatter then
		hr_utility.trace('DATA_RECORD_FORMATTER');
		--
		pay_jp_mag_utility_pkg.set_context('BUSINESS_GROUP_ID',		g_parameter.business_group_id);
		pay_jp_mag_utility_pkg.set_context('DATE_EARNED',		g_parameter.effective_date);
		pay_jp_mag_utility_pkg.set_context('ORGANIZATION_ID',		g_parameter.organization_id);
	--
	-- TRAILER_RECORD_FORMATTER
	--
	elsif l_formula_id = g_formula.trailer_record_formatter then
		hr_utility.trace('TRAILER_RECORD_FORMATTER');
		--
		pay_jp_mag_utility_pkg.set_context('BUSINESS_GROUP_ID',		g_parameter.business_group_id);
		pay_jp_mag_utility_pkg.set_context('DATE_EARNED',		g_parameter.effective_date);
		pay_jp_mag_utility_pkg.set_context('ORGANIZATION_ID',		g_parameter.organization_id);
	--
	-- END_RECORD_FORMATTER
	--
	elsif l_formula_id = g_formula.end_record_formatter then
		hr_utility.trace('END_RECORD_FORMATTER');
		--
		pay_jp_mag_utility_pkg.set_context('BUSINESS_GROUP_ID',		g_parameter.business_group_id);
		pay_jp_mag_utility_pkg.set_context('DATE_EARNED',		g_parameter.effective_date);
	else
		hr_utility.trace('Unknown formula : ' || to_char(l_formula_id));
	end if;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 30);
end run_formula;
--
end pay_jp_ltax_efile_pkg;

/
