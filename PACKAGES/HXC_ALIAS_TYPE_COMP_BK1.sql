--------------------------------------------------------
--  DDL for Package HXC_ALIAS_TYPE_COMP_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_TYPE_COMP_BK1" AUTHID CURRENT_USER as
/* $Header: hxcatcapi.pkh 120.0 2005/05/29 05:26:46 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_alias_type_comp_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_type_comp_b
  (p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_alias_type_comp_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_alias_type_comp_a
  (p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in     number
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< update_alias_type_comp_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_type_comp_b
  (p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_alias_type_comp_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_alias_type_comp_a
  (p_component_name                in     varchar2
  ,p_component_type                in     varchar2
  ,p_mapping_component_id          in     number
  ,p_alias_type_id                 in     number
  ,p_alias_type_component_id       in     number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_alias_type_comp_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_type_comp_b
  (p_alias_type_component_id       in    number
  ,p_object_version_number         in     number
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_alias_type_comp_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_alias_type_comp_a
  (p_alias_type_component_id       in    number
  ,p_object_version_number         in     number
  );
end hxc_alias_type_comp_bk1;

 

/
