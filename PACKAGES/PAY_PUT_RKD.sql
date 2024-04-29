--------------------------------------------------------
--  DDL for Package PAY_PUT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUT_RKD" AUTHID CURRENT_USER as
/* $Header: pyputrhi.pkh 120.0 2005/05/29 08:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_user_table_id                in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_range_or_match_o             in varchar2
  ,p_user_key_units_o             in varchar2
  ,p_user_table_name_o            in varchar2
  ,p_user_row_title_o             in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_put_rkd;

 

/
