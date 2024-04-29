--------------------------------------------------------
--  DDL for Package PAY_TAX_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TAX_BK1" AUTHID CURRENT_USER as
/* $Header: pytaxapi.pkh 120.1 2005/10/02 02:34:32 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< submit_fed_w4_b >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure submit_fed_w4_b
  (
   p_source_name	    	    in  varchar2
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_filing_status_code             in  varchar2
  ,p_withholding_allowances         in  number
  ,p_fit_additional_tax             in  number
  ,p_fit_exempt                     in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< submit_fed_w4_a >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure submit_fed_w4_a
  (
   p_source_name	    	    in  varchar2
  ,p_person_id                      in  number
  ,p_business_group_id              in  number
  ,p_filing_status_code             in  varchar2
  ,p_withholding_allowances         in  number
  ,p_fit_additional_tax             in  number
  ,p_fit_exempt                     in  varchar2
  ,p_stat_trans_audit_id            in  number
  );
--
end pay_tax_bk1;

 

/
