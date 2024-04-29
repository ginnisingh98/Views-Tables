--------------------------------------------------------
--  DDL for Package HXC_TIME_CATEGORY_COMP_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_CATEGORY_COMP_BK_2" AUTHID CURRENT_USER as
/* $Header: hxctccapi.pkh 120.0 2005/05/29 05:55:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_time_category_comp_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_category_comp_b
  (p_time_category_comp_id          in     number
  ,p_object_version_number          in     number
  ,p_time_category_id             number
  ,p_ref_time_category_id         number
  ,p_component_type_id            number
  ,p_flex_value_set_id            number
  ,p_value_id                     Varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_time_category_comp_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_category_comp_a
  (p_time_category_comp_id          in     number
  ,p_object_version_number          in     number
  ,p_time_category_id             number
  ,p_ref_time_category_id         number
  ,p_component_type_id            number
  ,p_flex_value_set_id            number
  ,p_value_id                     Varchar2
  ,p_is_null                        in varchar2
  ,p_equal_to                       in varchar2
  ,p_type                           in varchar2
  );
--
end hxc_time_category_comp_bk_2;

 

/
