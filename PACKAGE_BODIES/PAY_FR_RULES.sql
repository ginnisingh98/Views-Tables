--------------------------------------------------------
--  DDL for Package Body PAY_FR_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_RULES" as
/*   $Header: pyfrrule.pkb 115.11 2004/01/12 07:44:46 aparkes noship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_fr_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   01-FEB-2001  asnell      115.0  Created.
   09-MAY-2001  jrhodes     115.1  added missing join to assignment_id
   03-AUG-2001  jrhodes     115.2  Corrected join to element link
   10-OCT-2002  srjadhav    115.4  Added procedure get_dynamic_org_meth
   17-OCT-2002  srjadhav    115.5  Changed message numbers
   25-NOV-2002  asnell      115.6  added nocopy to parms
   10-APR-2003  aparkes     115.7  2898674 added get_multi_tax_unit_pay_flag
   11-NOV-2003  aparkes     115.8  Added retro context override hook
   08-JAN-2004  aparkes     115.9  Added get_source_text2_context (for bug
                                   3360253), get_source_number_context and
                                   raise_null_context_input following bug
                                   3305989.
   12-JAN-2004  aparkes     115.10 Use hr_utility.raise_error in above proc
                            115.11 Corrected trace in get_source_number_context
*/
--
--
-- private globals used for caching in get_dynamic_org_meth
  TYPE g_org_meth_map_rec IS RECORD (
    estab_id           pay_assignment_actions.tax_unit_id%TYPE,
    gen_org_paymeth_id pay_org_payment_methods_f.ORG_PAYMENT_METHOD_ID%TYPE,
    new_org_paymeth_id pay_org_payment_methods_f.ORG_PAYMENT_METHOD_ID%TYPE,
    err_name           fnd_new_messages.MESSAGE_NAME%TYPE,
    opm_name_token     varchar2(80),
    org_name_token     varchar2(60),
    org_type_token     varchar2(20));
  TYPE g_org_meth_map_typ IS TABLE OF g_org_meth_map_rec
    Index by BINARY_INTEGER;
  g_org_meth_map_tbl     g_org_meth_map_typ;
  g_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
  g_estab_id             pay_assignment_actions.tax_unit_id%TYPE;
-- end of private globals used for caching in get_dynamic_org_meth


   procedure raise_null_context_input(p_ee_id number,p_cxt_name varchar2)
   is
      l_element_name  pay_element_types_f.element_name%type;
      l_assignment_id pay_element_entries_f.assignment_id%type;
      l_input_name    pay_legislation_contexts.input_value_name%type;

      cursor csr_get_element_info is
      select et.element_name, entry.assignment_id
      from pay_element_entries entry,
        pay_element_links el,
        pay_element_types_f_tl   et
      where entry.element_entry_id = p_ee_id
    	and et.element_type_id = el.element_type_id
     	and el.element_link_id = entry.element_link_id
        and et.language = userenv('lang');

      cursor csr_get_input_name is
      select plc.input_value_name
      from   ff_contexts              ffc,
             pay_legislation_contexts plc
      where  ffc.context_name     = p_cxt_name
      and    ffc.context_id       = plc.context_id
      and    plc.legislation_code = 'FR';
   begin
      open csr_get_element_info;
      fetch csr_get_element_info into l_element_name, l_assignment_id;
      close csr_get_element_info;
      open csr_get_input_name;
      fetch csr_get_input_name into l_input_name;
      close csr_get_input_name;
      hr_utility.trace('error PAY_75084_NULL_CONTEXT_INPUT raised. Direct Ele:'
                       ||l_element_name||' Input:'||l_input_name);
      hr_utility.set_message(801,'PAY_75084_NULL_CONTEXT_INPUT');
      hr_utility.set_message_token('INPUT_NAME',l_input_name);
      hr_utility.set_message_token('ELEMENT',l_element_name);
      hr_utility.raise_error;
   end raise_null_context_input;

   procedure get_source_text_context(p_asg_act_id number,
                                     p_ee_id number,
                                     p_source_text in out nocopy varchar2)
   is
   -- the statutory deductions element holds an input to record the
   -- process_type. The statutory deductions formula fires PLSQL to
   -- record that process type as a plsql global (it remains constant for
   -- any run).
   -- set that global as the default source_text context
   -- if its null fetch the process_type from the statutory deduction
   -- element entry

   cursor csr_process_type_entry_value is
          select SCREEN_ENTRY_VALUE from
                                    pay_assignment_actions aa,
                                    pay_payroll_actions pa,
                                    pay_element_entries_f ee,
                                    pay_element_entry_values_f eev,
                                    pay_input_values_f iv,
                                    pay_element_types_f et,
                                    pay_element_links_f el
                  where aa.assignment_action_id = p_asg_act_id
                    and pa.payroll_action_id    = aa.payroll_action_id
                    and aa.assignment_id        = ee.assignment_id
                    and iv.input_value_id       = eev.input_value_id
                    and el.element_link_id      = ee.element_link_id
                    and ee.element_entry_id     = eev.element_entry_id
                    and et.element_name         = 'FR_STATUTORY_DEDUCTIONS'
                    and iv.name                 = 'Process_Type'
                    and el.element_type_id     = et.element_type_id
                    and pa.date_earned between
                           et.effective_start_date and et.effective_end_date
                    and pa.date_earned between
                           iv.effective_start_date and iv.effective_end_date
                    and pa.date_earned between
                           el.effective_start_date and el.effective_end_date
                    and pa.date_earned between
                           ee.effective_start_date and ee.effective_end_date
                    and pa.date_earned between
                           eev.effective_start_date and eev.effective_end_date;

   begin
   hr_utility.set_location('PAY_FR_RULES.get_source_text_context',1);

   if pay_fr_general.g_process_type is not null
      then p_source_text := pay_fr_general.g_process_type;
           hr_utility.set_location('PAY_FR_RULES.get_source_text_context',2);

      else
           hr_utility.set_location('PAY_FR_RULES.get_source_text_context',3);
           open csr_process_type_entry_value;
           fetch csr_process_type_entry_value into p_source_text;
           close csr_process_type_entry_value;

      end if;
   hr_utility.set_location('PAY_FR_RULES.get_source_text_context='||
                               p_source_text,4);

   end get_source_text_context;

   procedure get_source_text2_context(p_asg_act_id number,
                                      p_ee_id number,
                                      p_source_text2 in out nocopy varchar2) is
   begin
      -- contribution_code should never be null so error if this
      -- defaulting procedure if invoked
      hr_utility.set_location('Entered get_source_text2_context. p_asg_act_id('
                              ||to_char(p_asg_act_id)||') p_ee_id('
                              ||to_char(p_ee_id)||')',5);
      raise_null_context_input(p_ee_id,'SOURCE_TEXT2');
      hr_utility.set_location('Leaving get_source_text2_context.',10);
   end get_source_text2_context;

   procedure get_source_context(p_asg_act_id number,
                                p_ee_id number,
                                p_source_id in out nocopy varchar2) is
   begin
      -- contribution_usage_id should never be null so error if this
      -- defaulting procedure is invoked

      hr_utility.set_location('Entered get_source_context. p_asg_act_id('||
                              to_char(p_asg_act_id)||') p_ee_id('||
                              to_char(p_ee_id)||')',5);
      p_source_id := '-99';
      raise_null_context_input(p_ee_id,'SOURCE_ID');
      hr_utility.set_location('Leaving get_source_context.',10);

   end get_source_context;

   procedure get_source_number_context(p_asg_act_id number,
                                       p_ee_id number,
                                       p_source_number in out nocopy varchar2)
   is
   begin
      -- Rate should never be null so error if this
      -- defaulting procedure if invoked
      hr_utility.set_location('Entered get_source_number_context. p_asg_act_id('
                              ||to_char(p_asg_act_id)||') p_ee_id('
                              ||to_char(p_ee_id)||')',5);
      raise_null_context_input(p_ee_id,'SOURCE_NUMBER');
      hr_utility.set_location('Leaving get_source_number_context.',10);
   end get_source_number_context;

PROCEDURE get_dynamic_org_meth
	(p_assignment_action_id in number
		,p_effective_date       in date
		,p_org_meth             in number   -- org meth with no bank account
		,p_org_method_id        out nocopy number) -- replacement org meth
IS
l_gen_org_method_id_chr varchar2(60);
	l_map_tbl_ind           BINARY_INTEGER;
	l_dummy_opm_id    pay_org_payment_methods_f.ORG_PAYMENT_METHOD_ID%TYPE;
	l_company_id      hr_all_organization_units.ORGANIZATION_ID%TYPE;
	--
	cursor csr_get_estab is
	select tax_unit_id
	from pay_assignment_actions
	where assignment_action_id = p_assignment_action_id;
	--
	cursor csr_get_company is
	select fnd_number.canonical_to_number(hoi.ORG_INFORMATION1)
	from   hr_organization_information   hoi
	where  hoi.organization_id         = g_estab_id
	AND    hoi.org_information_context = 'FR_ESTAB_INFO';
	--
	cursor csr_check_opm_effective(p_opm_id in number, p_date in date) is
	select ORG_PAYMENT_METHOD_ID
	from   pay_org_payment_methods_f
	where  ORG_PAYMENT_METHOD_ID = p_opm_id
	and    p_date between effective_start_date and effective_end_date;
	--
	PROCEDURE cache_tokens(p_opm_id in number, p_org_id in number) is
			cursor csr_get_opm_name is
			select substrb(ORG_PAYMENT_METHOD_NAME,1,80)
			from   pay_org_payment_methods_f_tl
			where  ORG_PAYMENT_METHOD_ID = p_opm_id
			and    language = userenv('LANG');
			--
			cursor csr_get_org_info is
			select substrb(NAME,1,60), substrb(hrl.meaning,1,20)
			from   hr_all_organization_units_tl  org,
			       hr_organization_information   ori,
			       hr_lookups                    hrl
			where  org.ORGANIZATION_ID = p_org_id
			and    org.language = userenv('LANG')
			and    org.ORGANIZATION_ID = ori.ORGANIZATION_ID
			and    ori.org_information_context = 'CLASS'
			and    ori.ORG_INFORMATION1 = hrl.lookup_code
			and    hrl.lookup_type = 'ORG_CLASS';
	BEGIN
			open csr_get_opm_name;
			fetch csr_get_opm_name into g_org_meth_map_tbl(l_map_tbl_ind).opm_name_token;
			close csr_get_opm_name;
			open csr_get_org_info;
			fetch csr_get_org_info into 	g_org_meth_map_tbl(l_map_tbl_ind).org_name_token,
							g_org_meth_map_tbl(l_map_tbl_ind).org_type_token;
			close csr_get_org_info;
	END cache_tokens;
	--
BEGIN
	l_gen_org_method_id_chr := fnd_number.number_to_canonical(p_org_meth);
	--
	if g_assignment_action_id is null or
				g_assignment_action_id <> p_assignment_action_id
	then
			open csr_get_estab;
			fetch csr_get_estab into g_estab_id;
			close csr_get_estab;
			g_assignment_action_id := p_assignment_action_id;
	end if;
	--
	l_map_tbl_ind := DBMS_UTILITY.get_hash_value(g_estab_id||p_org_meth,1,1048576); -- (2^20)
	if not g_org_meth_map_tbl.exists(l_map_tbl_ind)
	or g_org_meth_map_tbl(l_map_tbl_ind).estab_id           <> g_estab_id
	or g_org_meth_map_tbl(l_map_tbl_ind).gen_org_paymeth_id <> p_org_meth
	then
			-- cache index not used, or user key doesn't match, so prime cache
			g_org_meth_map_tbl(l_map_tbl_ind).estab_id           := g_estab_id;
			g_org_meth_map_tbl(l_map_tbl_ind).gen_org_paymeth_id := p_org_meth;
			g_org_meth_map_tbl(l_map_tbl_ind).new_org_paymeth_id := null;
			g_org_meth_map_tbl(l_map_tbl_ind).err_name           := null;
			-- get replacement org paymeth from estab
			BEGIN
					SELECT fnd_number.canonical_to_number(hoi.ORG_INFORMATION1)
					INTO   p_org_method_id
					FROM   hr_organization_information hoi,
					       hr_all_organization_units   org
					WHERE  hoi.organization_id         = g_estab_id
					AND    hoi.ORG_INFORMATION2        = l_gen_org_method_id_chr
					AND    hoi.org_information_context = 'FR_DYN_PAYMETH_MAPPING_INFO'
					AND    hoi.organization_id         = org.organization_id
					AND    p_effective_date between org.date_from
					AND    nvl(org.date_to, hr_general.end_of_time);
					--
					open csr_check_opm_effective(p_org_method_id,p_effective_date);
					fetch csr_check_opm_effective into l_dummy_opm_id;
					if csr_check_opm_effective%NOTFOUND then
							g_org_meth_map_tbl(l_map_tbl_ind).err_name := 'PAY_75035_OPM_NOT_EFFECTIVE';
							cache_tokens(p_org_method_id, g_estab_id);
					else
							g_org_meth_map_tbl(l_map_tbl_ind).new_org_paymeth_id := p_org_method_id;
					end if;
					close csr_check_opm_effective;
			EXCEPTION
					WHEN TOO_MANY_ROWS then
							g_org_meth_map_tbl(l_map_tbl_ind).err_name := 'PAY_75036_TOO_MANY_GEN_OPMS';
							cache_tokens(p_org_meth, g_estab_id);
					WHEN NO_DATA_FOUND then
							-- get replacement org paymeth from company
							BEGIN
									Open csr_get_company;
									Fetch csr_get_company into l_company_id;
									Close csr_get_company;

									SELECT fnd_number.canonical_to_number(hoi.ORG_INFORMATION1)
									INTO   p_org_method_id
									FROM   hr_organization_information hoi,
									       hr_all_organization_units   org
									WHERE  hoi.organization_id         = l_company_id
									AND    hoi.ORG_INFORMATION2        = l_gen_org_method_id_chr
									AND    hoi.org_information_context = 'FR_DYN_PAYMETH_MAPPING_INFO'
									AND    hoi.organization_id         = org.organization_id
									AND    p_effective_date between org.date_from
									AND    nvl(org.date_to, hr_general.end_of_time);
									--
									open csr_check_opm_effective(p_org_method_id, p_effective_date);
									fetch csr_check_opm_effective into l_dummy_opm_id;
									if csr_check_opm_effective%NOTFOUND then
											g_org_meth_map_tbl(l_map_tbl_ind).err_name := 'PAY_75035_OPM_NOT_EFFECTIVE';
											cache_tokens(p_org_method_id, l_company_id);
									else
											g_org_meth_map_tbl(l_map_tbl_ind).new_org_paymeth_id := p_org_method_id;
									end if;
									close csr_check_opm_effective;
							EXCEPTION
									WHEN TOO_MANY_ROWS then
											g_org_meth_map_tbl(l_map_tbl_ind).err_name := 'PAY_75036_TOO_MANY_GEN_OPMS';
											cache_tokens(p_org_meth, l_company_id);
									WHEN NO_DATA_FOUND then
											g_org_meth_map_tbl(l_map_tbl_ind).err_name := 'PAY_75034_NO_SPEC_OPM';
											cache_tokens(p_org_meth, g_estab_id);
							END;  -- Company Block
			END;  -- Estab block
	END IF;  -- Cache matching
	-- determine appropriate result from cache.


	IF g_org_meth_map_tbl(l_map_tbl_ind).new_org_paymeth_id IS NOT NULL
	THEN
			p_org_method_id :=
																	g_org_meth_map_tbl(l_map_tbl_ind).new_org_paymeth_id;
	ELSIF g_org_meth_map_tbl(l_map_tbl_ind).err_name = 'PAY_75034_NO_SPEC_OPM'
	THEN
			hr_utility.set_message(801, 'PAY_75034_NO_SPEC_OPM');
			hr_utility.set_message_token('OPM_NAME',g_org_meth_map_tbl(l_map_tbl_ind).opm_name_token);
			hr_utility.set_message_token('ESTAB_NAME',g_org_meth_map_tbl(l_map_tbl_ind).org_name_token);
			hr_utility.raise_error;
	ELSIF g_org_meth_map_tbl(l_map_tbl_ind).err_name = 'PAY_75035_OPM_NOT_EFFECTIVE'
	THEN
			hr_utility.set_message(801,'PAY_75035_OPM_NOT_EFFECTIVE');
			hr_utility.set_message_token('OPM_NAME', g_org_meth_map_tbl(l_map_tbl_ind).opm_name_token);
			hr_utility.set_message_token('ORG_CLASS', g_org_meth_map_tbl(l_map_tbl_ind).org_type_token);
			hr_utility.set_message_token('ORG_NAME', g_org_meth_map_tbl(l_map_tbl_ind).org_name_token);
			hr_utility.raise_error;
	ELSIF g_org_meth_map_tbl(l_map_tbl_ind).err_name = 'PAY_75036_TOO_MANY_GEN_OPMS'
	THEN
			hr_utility.set_message(801, 'PAY_75036_TOO_MANY_GEN_OPMS');
			hr_utility.set_message_token('OPM_NAME',	g_org_meth_map_tbl(l_map_tbl_ind).opm_name_token);
			hr_utility.set_message_token('ORG_CLASS',	g_org_meth_map_tbl(l_map_tbl_ind).org_type_token);
			hr_utility.set_message_token('ORG_NAME',	g_org_meth_map_tbl(l_map_tbl_ind).org_name_token);
			hr_utility.raise_error;
	END IF;
END get_dynamic_org_meth;

procedure get_multi_tax_unit_pay_flag(p_bus_grp in number,
                                      p_mtup_flag in out nocopy varchar2)
is
begin
  null;
end get_multi_tax_unit_pay_flag;
--
procedure retro_context_override(p_element_entry_id  in number,
                                 p_context_name      in varchar2,
                                 p_context_value     in varchar2,
                                 p_replacement_value out nocopy varchar2)
is
  cursor csr_matching_entry is
  select epd1.source_element_type_id,
    max(decode(piv.name,'Contribution_Code',eev1.screen_entry_value)) cc1,
    max(decode(piv.name,'Contribution_Code',eev2.screen_entry_value)) cc2,
    max(decode(piv.name,'Process_Type',eev1.screen_entry_value)) pt1,
    max(decode(piv.name,'Process_Type',eev2.screen_entry_value)) pt2,
    max(decode(piv.name,'Contribution_Usage_ID',eev1.screen_entry_value)) cui1,
    max(decode(piv.name,'Contribution_Usage_ID',eev2.screen_entry_value)) cui2,
    max(decode(piv.name,'Rate Type',eev1.screen_entry_value)) rt1,
    max(decode(piv.name,'Rate Type',eev2.screen_entry_value)) rt2
  from  pay_element_entries_f       pee1,
        pay_element_entries_f       pee2,
        pay_entry_process_details   epd1,
        pay_entry_process_details   epd2,
        pay_element_entry_values_f  eev1,
        pay_element_entry_values_f  eev2,
        pay_input_values_f          piv
  where pee1.element_entry_id       = p_element_entry_id
  and   pee2.element_link_id        = pee1.element_link_id
  and   pee2.assignment_id          = pee1.assignment_id
  and   pee2.effective_start_date   = pee1.effective_start_date
  and   pee2.effective_end_date     = pee1.effective_end_date
  and   pee2.creator_id             = pee1.creator_id
  and   pee2.creator_type          in ('EE','RR')
  and   pee2.element_entry_id      <> pee1.element_entry_id
  and   epd1.element_entry_id       = pee1.element_entry_id
  and   epd2.element_entry_id       = pee2.element_entry_id
  and   epd2.retro_component_id     = epd1.retro_component_id
  and   epd2.process_path           = epd1.process_path
  and   epd2.source_asg_action_id   = epd1.source_asg_action_id
  and   epd2.source_element_type_id = epd1.source_element_type_id
  and  (epd1.tax_unit_id is null or
        epd2.tax_unit_id            = epd1.tax_unit_id)
  and   epd2.source_entry_id        = epd1.source_entry_id
  and   eev1.element_entry_id       = pee1.element_entry_id
  and   eev2.element_entry_id       = pee2.element_entry_id
  and   eev1.input_value_id         = eev2.input_value_id
  and   piv.input_value_id          = eev2.input_value_id
  and   piv.name                   in ('Contribution_Code','Process_Type',
                                       'Contribution_Usage_ID','Rate Type')
  group by epd1.source_element_type_id
  having max(decode(piv.name,'Contribution_Code',eev1.screen_entry_value))
       = max(decode(piv.name,'Contribution_Code',eev2.screen_entry_value))
     and max(decode(piv.name,'Process_Type',eev1.screen_entry_value))
       = max(decode(piv.name,'Process_Type',eev2.screen_entry_value))
     and max(decode(piv.name,'Contribution_Usage_ID',eev1.screen_entry_value))
       = max(decode(piv.name,'Contribution_Usage_ID',eev2.screen_entry_value))
     and nvl(max(decode(piv.name,'Rate Type',eev1.screen_entry_value)),' ')
       = nvl(max(decode(piv.name,'Rate Type',eev2.screen_entry_value)),' ');
  --
  cursor csr_retro_code_by_id(p_cu_id in number) is
  select retro_contribution_code,contribution_type
  from   pay_fr_contribution_usages
  where  contribution_usage_id = p_cu_id
  and    retro_contribution_code <> contribution_code;
  --
  rec_matching_entry  csr_matching_entry%ROWTYPE;
  l_retro_code        pay_fr_contribution_usages.retro_contribution_code%TYPE;
  l_contribution_type pay_fr_contribution_usages.contribution_type%TYPE;
begin
  if p_context_name <> 'SOURCE_TEXT2'
  or nvl(p_context_value,' ') = ' '
  then
    -- Not the Contribution_code context or context is null/space
    -- so return value unchanged
    p_replacement_value := p_context_value;
  else
    open csr_matching_entry;
    fetch csr_matching_entry into rec_matching_entry;
    if csr_matching_entry%NOTFOUND then
      -- No matching entry so return value unchanged.
      p_replacement_value := p_context_value;
      close csr_matching_entry;
    else
      close csr_matching_entry;
      -- Matching entry, only the rate must have changed so replace value
      open csr_retro_code_by_id(
               fnd_number.canonical_to_number(rec_matching_entry.cui1));
      fetch csr_retro_code_by_id into l_retro_code,l_contribution_type;
      if csr_retro_code_by_id%NOTFOUND then
        -- retro_contribution_code not different or contribution_code
        -- not held on pay_fr_contribution_usages
        -- so return value unchanged
        p_replacement_value := p_context_value;
      else
        IF l_contribution_type = 'URSSAF' THEN
          p_replacement_value := substr(rec_matching_entry.cc1,1,3) ||
                                 substr(l_retro_code,4,4);
        ELSIF l_contribution_type = 'ASSEDIC' THEN
          p_replacement_value := substr(rec_matching_entry.cc1,1,2) ||
                                 substr(l_retro_code,3,5);
        ELSIF l_contribution_type = 'AGIRC' THEN
          p_replacement_value := substr(rec_matching_entry.cc1,1,5) ||
                                 substr(l_retro_code,6,2);
        ELSE  /* Must be ARRCO */
          p_replacement_value := substr(rec_matching_entry.cc1,1,5) ||
                                 substr(l_retro_code,6,2);
        END IF;
      end if; -- csr_retro_code_by_id%NOTFOUND
      close csr_retro_code_by_id;
    end if; -- No matching entry
  end if; -- Not the Contribution_code context
end retro_context_override;
end pay_fr_rules;

/
