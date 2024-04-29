--------------------------------------------------------
--  DDL for Package PAY_JP_EXTRA_BANK_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_EXTRA_BANK_RULES" AUTHID CURRENT_USER as
/* $Header: pyjpexbr.pkh 120.1 2005/07/22 01:02 keyazawa noship $ */
	--
	procedure chk_account_name
	(
		p_external_account_id in number
	);
	--
	procedure chk_account_name_update
	(
		p_external_account_id   in number,
		p_external_account_id_o in number
	);
	--
	procedure chk_swot_account_name
	(
    p_org_information_context in varchar2,
		p_org_information17       in varchar2
	);
	--
	procedure chk_swot_account_name_update
	(
    p_org_information_context in varchar2,
		p_org_information17       in varchar2,
		p_org_information17_o     in varchar2
	);
	--
end pay_jp_extra_bank_rules;

 

/
