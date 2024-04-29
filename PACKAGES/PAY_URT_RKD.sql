--------------------------------------------------------
--  DDL for Package PAY_URT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_URT_RKD" AUTHID CURRENT_USER as
/* $Header: pyurtrhi.pkh 120.0 2005/05/29 09:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_user_row_id                  in number
  ,p_language                     in varchar2
  ,p_source_lang_o                in varchar2
  ,p_row_low_range_or_name_o      in varchar2
  );
--
end pay_urt_rkd;

 

/
