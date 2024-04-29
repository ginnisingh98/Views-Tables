--------------------------------------------------------
--  DDL for Package PAY_BDT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BDT_RKI" AUTHID CURRENT_USER as
/* $Header: pybdtrhi.pkh 120.1 2005/11/24 05:36 arashid noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_balance_dimension_id         in number
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_dimension_name               in varchar2
  ,p_database_item_suffix         in varchar2
  ,p_description                  in varchar2
  );
end pay_bdt_rki;

 

/
