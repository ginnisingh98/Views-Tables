--------------------------------------------------------
--  DDL for Package Body PAY_JP_EXTRA_BANK_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_EXTRA_BANK_RULES" as
/* $Header: pyjpexbr.pkb 120.1 2005/07/22 01:02 keyazawa noship $ */
	--
	procedure chk_kana_format
	(
		p_input in varchar2
	) is
		--
		l_input  varchar2(255);
		l_output varchar2(255);
		l_rgeflg varchar2(1);
		--
	begin
		--
		if p_input is not null then
			--
			l_input := p_input;
			--
			hr_chkfmt.checkformat
			(
				value   => l_input,
				format  => 'KANA',
				output  => l_output,
				minimum => NULL,
				maximum => NULL,
				nullok  => 'N',
				rgeflg  => l_rgeflg,
				curcode => NULL
			);
			--
		end if;
		--
	end chk_kana_format;
	--
	-----------------------------------------------------------
	-- check account name for personal/org payment method table
	-----------------------------------------------------------
	procedure chk_account_name
	(
		p_external_account_id in number
	) is
		--
		l_in_account_name  varchar2(150);
		l_out_account_name varchar2(150);
		l_rgeflg           varchar2(1);
		--
	begin
		--
		if p_external_account_id is not null then
			--
			select
				segment9 /* account name */
			into
				l_in_account_name
			from
				pay_external_accounts
			where
				external_account_id = p_external_account_id;
			--
			chk_kana_format(l_in_account_name);
			--
		end if;
		--
	end chk_account_name;
	--
	procedure chk_account_name_update
	(
		p_external_account_id   in number,
		p_external_account_id_o in number
	) is
	begin
		--
		if nvl(p_external_account_id, hr_api.g_number) <> nvl(p_external_account_id_o, hr_api.g_number) then
			--
			chk_account_name(p_external_account_id);
			--
		end if;
		--
	end chk_account_name_update;
	--
	-------------------------------------------------------
	-- check account name for swot organization information
	-------------------------------------------------------
	procedure chk_swot_account_name
	(
    p_org_information_context in varchar2,
		p_org_information17       in varchar2
	) is
		--
		l_in_value  varchar2(150);
		l_out_value varchar2(150);
		l_rgeflg    varchar2(1);
		--
	begin
		--
    if p_org_information_context = 'JP_TAX_SWOT_INFO' then
    --
  	  chk_kana_format(p_org_information17);
    --
    end if;
		--
	end chk_swot_account_name;
	--
	procedure chk_swot_account_name_update
	(
    p_org_information_context in varchar2,
		p_org_information17       in varchar2,
		p_org_information17_o     in varchar2
	) is
	begin
		--
		if nvl(p_org_information17, hr_api.g_varchar2) <> nvl(p_org_information17_o, hr_api.g_varchar2) then
			--
			chk_swot_account_name(p_org_information_context, p_org_information17);
			--
		end if;
		--
	end chk_swot_account_name_update;
	--
end pay_jp_extra_bank_rules;

/
