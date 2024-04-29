--------------------------------------------------------
--  DDL for Package PAY_IVT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IVT_RKD" AUTHID CURRENT_USER as
/* $Header: pyivtrhi.pkh 120.0 2005/05/29 06:05:39 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_input_value_id               in number
  ,p_language                     in varchar2
  ,p_name_o                       in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pay_ivt_rkd;

 

/
