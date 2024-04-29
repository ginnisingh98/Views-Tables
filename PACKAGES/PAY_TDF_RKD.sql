--------------------------------------------------------
--  DDL for Package PAY_TDF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_TDF_RKD" AUTHID CURRENT_USER as
/* $Header: pytdfrhi.pkh 120.1 2005/06/14 14:08 tvankayl noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_time_definition_id           in number
  ,p_short_name_o                 in varchar2
  ,p_definition_name_o            in varchar2
  ,p_period_type_o                in varchar2
  ,p_period_unit_o                in varchar2
  ,p_day_adjustment_o             in varchar2
  ,p_dynamic_code_o               in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_definition_type_o            in varchar2
  ,p_number_of_years_o            in number
  ,p_start_date_o                 in date
  ,p_period_time_definition_id_o  in number
  ,p_creator_id_o                 in number
  ,p_creator_type_o               in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_tdf_rkd;

 

/
