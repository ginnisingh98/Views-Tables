--------------------------------------------------------
--  DDL for Package PAY_IVT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IVT_RKI" AUTHID CURRENT_USER as
/* $Header: pyivtrhi.pkh 120.0 2005/05/29 06:05:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_input_value_id               in number
  ,p_name                         in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  );
end pay_ivt_rki;

 

/
