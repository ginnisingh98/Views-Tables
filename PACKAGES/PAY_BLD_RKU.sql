--------------------------------------------------------
--  DDL for Package PAY_BLD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BLD_RKU" AUTHID CURRENT_USER as
/* $Header: pybldrhi.pkh 120.0 2005/05/29 03:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_balance_dimension_id         in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_route_id                     in number
  ,p_database_item_suffix         in varchar2
  ,p_dimension_name               in varchar2
  ,p_dimension_type               in varchar2
  ,p_description                  in varchar2
  ,p_feed_checking_code           in varchar2
  ,p_legislation_subgroup         in varchar2
  ,p_payments_flag                in varchar2
  ,p_expiry_checking_code         in varchar2
  ,p_expiry_checking_level        in varchar2
  ,p_feed_checking_type           in varchar2
  ,p_dimension_level              in varchar2
  ,p_period_type                  in varchar2
  ,p_asg_action_balance_dim_id    in number
  ,p_database_item_function       in varchar2
  ,p_save_run_balance_enabled     in varchar2
  ,p_start_date_code              in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_route_id_o                   in number
  ,p_database_item_suffix_o       in varchar2
  ,p_dimension_name_o             in varchar2
  ,p_dimension_type_o             in varchar2
  ,p_description_o                in varchar2
  ,p_feed_checking_code_o         in varchar2
  ,p_legislation_subgroup_o       in varchar2
  ,p_payments_flag_o              in varchar2
  ,p_expiry_checking_code_o       in varchar2
  ,p_expiry_checking_level_o      in varchar2
  ,p_feed_checking_type_o         in varchar2
  ,p_dimension_level_o            in varchar2
  ,p_period_type_o                in varchar2
  ,p_asg_action_balance_dim_id_o  in number
  ,p_database_item_function_o     in varchar2
  ,p_save_run_balance_enabled_o   in varchar2
  ,p_start_date_code_o            in varchar2
  );
--
end pay_bld_rku;

 

/
