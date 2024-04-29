--------------------------------------------------------
--  DDL for Package Body OTA_TFH_API_BUSINESS_RULES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TFH_API_BUSINESS_RULES2" as
/* $Header: ottfh03t.pkb 115.0 99/07/16 00:55:17 porting ship $ */
--
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tfh_api_business_rules2.';
--
-- Global api dml status
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_finance_lines >--------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_finance_lines (p_rec in ota_tfh_api_shd.g_rec_type) is
--
l_proc  varchar2(72) := g_package||'update_finance_lines';
--
l_transfer_status_changed   boolean
    := ota_general.value_changed( ota_tfh_api_shd.g_old_rec.transfer_status
                                , p_rec.transfer_status );
--
begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
-- If the Header transfer status is changed then update all the lines
-- with the same old transfer status
--
if l_transfer_status_changed then
   ota_tfl_api_business_rules2.change_line_for_header
        (p_rec.finance_header_id
        ,p_rec.transfer_status
        ,ota_tfh_api_shd.g_old_rec.transfer_status);
end if;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end update_finance_lines;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< invoice_full_amount >------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
-- Return the full amount of of invoice
--
Function invoice_full_amount (
	p_finance_header_id in varchar2
 	,p_currency_code in varchar2 )
return varchar2 is
--
cursor csr_tot is
	select nvl(sum(tfl.money_amount),0)
	from ota_finance_lines tfl
	where finance_header_id = p_finance_header_id
	and cancelled_flag = 'N';
--
l_tot 	number;
l_amount varchar2(30);
--
begin
--
open csr_tot;
fetch csr_tot into l_tot;
close csr_tot;
if p_currency_code is not null then
  l_amount := hr_chkfmt.changeformat(
			l_tot,
                         'M',
                         p_currency_code);
else
  l_amount := to_char(l_tot);
end if;
--
return l_amount;
--
end invoice_full_amount;
--
end ota_tfh_api_business_rules2;

/
