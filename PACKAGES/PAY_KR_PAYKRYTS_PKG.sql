--------------------------------------------------------
--  DDL for Package PAY_KR_PAYKRYTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_PAYKRYTS_PKG" AUTHID CURRENT_USER as
/* $Header: paykryts.pkh 115.1 2003/06/02 09:30:52 nnaresh noship $ */
------------------------------------------------------------------------
procedure data(
	p_tax_unit_id			in number,
	p_target_year			in number,
	p_count				out nocopy number,
	p_earnings			out nocopy number,
	p_non_taxable_count		out nocopy number,
	p_non_taxable			out nocopy number,
	p_med_exp_tax_exem_count	out nocopy number,
	p_med_exp_tax_exem		out nocopy number,
	p_donation_tax_exem_count	out nocopy number,
	p_donation_tax_exem		out nocopy number,
	p_annual_itax			out nocopy number,
	p_prev_itax			out nocopy number,
	p_cur_itax			out nocopy number,
	p_itax_adj_pay			out nocopy number,
	p_itax_adj_refund		out nocopy number,
	p_itax_adj			out nocopy number);
------------------------------------------------------------------------
end pay_kr_paykryts_pkg;

 

/
