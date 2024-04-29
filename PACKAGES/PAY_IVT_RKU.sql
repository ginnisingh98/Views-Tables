--------------------------------------------------------
--  DDL for Package PAY_IVT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IVT_RKU" AUTHID CURRENT_USER as
/* $Header: pyivtrhi.pkh 120.0 2005/05/29 06:05:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_input_value_id               in number
  ,p_name                         in varchar2
  ,p_language                     in varchar2
  ,p_source_lang                  in varchar2
  ,p_name_o                       in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pay_ivt_rku;

 

/
