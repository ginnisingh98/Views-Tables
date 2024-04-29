--------------------------------------------------------
--  DDL for Package PAY_TXR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TXR_RKD" AUTHID CURRENT_USER as
/* $Header: pytxrrhi.pkh 120.0 2005/05/29 09:09 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_jurisdiction_code            in varchar2
  ,p_tax_type                     in varchar2
  ,p_tax_category                 in varchar2
  ,p_classification_id            in number
  ,p_taxability_rules_date_id     in number
  ,p_legislation_code_o           in varchar2
  ,p_status_o                     in varchar2
  ,p_secondary_classification_id  in number
  );
--
end pay_txr_rkd;

 

/
