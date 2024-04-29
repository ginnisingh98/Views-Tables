--------------------------------------------------------
--  DDL for Package HXC_MAPPING_COMPONENT_BK_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MAPPING_COMPONENT_BK_2" AUTHID CURRENT_USER as
/* $Header: hxcmpcapi.pkh 120.0 2005/05/29 05:47:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_mapping_component_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_mapping_component_b
  (p_mapping_component_id          in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  ,p_field_name                     in     varchar2
  ,p_bld_blk_info_type_id           in     number
  ,p_segment                        in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_mapping_component_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_mapping_component_a
  (p_mapping_component_id          in     number
  ,p_object_version_number          in     number
  ,p_name                           in     varchar2
  ,p_field_name                     in     varchar2
  ,p_bld_blk_info_type_id           in     number
  ,p_segment                        in     varchar2
  );
--
end hxc_mapping_component_bk_2;

 

/
