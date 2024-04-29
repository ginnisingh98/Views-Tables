--------------------------------------------------------
--  DDL for Package PER_JP_PEM_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JP_PEM_RULES" AUTHID CURRENT_USER as
/* $Header: pejppemr.pkh 120.0 2005/05/31 10:55 appldev noship $ */
--
procedure chk_ddf(
	p_pem_information1	in varchar2,
	p_pem_information2	in varchar2);
--
end per_jp_pem_rules;

 

/
