--------------------------------------------------------
--  DDL for Package PER_BBT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BBT_RKD" AUTHID CURRENT_USER as
/* $Header: pebbtrhi.pkh 120.0 2005/05/31 06:03:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_balance_type_id              in number
  ,p_input_value_id_o             in number
  ,p_business_group_id_o          in number
  ,p_displayed_name_o             in varchar2
  ,p_internal_name_o              in varchar2
  ,p_uom_o                        in varchar2
  ,p_currency_o                   in varchar2
  ,p_category_o                   in varchar2
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_object_version_number_o      in number
  );
--
end per_bbt_rkd;

 

/
