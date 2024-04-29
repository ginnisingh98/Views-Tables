--------------------------------------------------------
--  DDL for Package PAY_PUT_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PUT_RKU" AUTHID CURRENT_USER as
/* $Header: pyputrhi.pkh 120.0 2005/05/29 08:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_user_table_id                in number
  ,p_user_table_name              in varchar2
  ,p_user_row_title               in varchar2
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_range_or_match_o             in varchar2
  ,p_user_key_units_o             in varchar2
  ,p_user_table_name_o            in varchar2
  ,p_user_row_title_o             in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_put_rku;

 

/
