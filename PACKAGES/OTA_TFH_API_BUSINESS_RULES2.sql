--------------------------------------------------------
--  DDL for Package OTA_TFH_API_BUSINESS_RULES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TFH_API_BUSINESS_RULES2" AUTHID CURRENT_USER as
/* $Header: ottfh03t.pkh 115.0 99/07/16 00:55:20 porting ship $ */
/*
-- ----------------------------------------------------------------------------
-- |-------------------------< check_tfl_memo_flag >--------------------------|
-- ----------------------------------------------------------------------------
--
-- NO MORE PUBLIC
-- Description:
-- If Header's memo flag is set to 'Y', all finance lines must have their
-- memo flag set to 'Y'
--
Procedure check_tfl_memo_flag (
	 p_finance_header_id in number
	,p_memo_flag         in varchar2
  );
--
*/
-- ----------------------------------------------------------------------------
-- |----------------------------< update_finance_lines>------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
-- Called after post_update.
-- This procedure call various procedures updating finance lines
-- according to the changes made on the header.
--
procedure update_finance_lines (p_rec	in  ota_tfh_api_shd.g_rec_type );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< invoice_full_amount >------------------|
-- ----------------------------------------------------------------------------
--
Function invoice_full_amount (
		p_finance_header_id in varchar2
		,p_currency_code in varchar2)
return varchar2;
pragma restrict_references (invoice_full_amount, WNPS,WNDS);
--
end ota_tfh_api_business_rules2;

 

/
