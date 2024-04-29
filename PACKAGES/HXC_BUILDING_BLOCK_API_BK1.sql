--------------------------------------------------------
--  DDL for Package HXC_BUILDING_BLOCK_API_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_BUILDING_BLOCK_API_BK1" AUTHID CURRENT_USER as
/* $Header: hxctbbapi.pkh 120.1 2005/07/14 17:18:24 arundell noship $ */

-- --------------------------------------------------------------------------
-- |---------------------------< create_building_block_b >------------------|
-- --------------------------------------------------------------------------

procedure create_building_block_b
  (p_effective_date            in date
  ,p_type                      in varchar2
  ,p_measure                   in number
  ,p_unit_of_measure           in varchar2
  ,p_start_time                in date
  ,p_stop_time                 in date
  ,p_parent_building_block_id  in number
  ,p_parent_building_block_ovn in number
  ,p_scope                     in varchar2
  ,p_approval_style_id         in number
  ,p_approval_status           in varchar2
  ,p_resource_id               in number
  ,p_resource_type             in varchar2
  ,p_comment_text              in varchar2
  ,p_application_set_id        in number
  ,p_translation_display_key   in varchar2
  );

-- --------------------------------------------------------------------------
-- |---------------------------< create_building_block_a >------------------|
-- --------------------------------------------------------------------------

procedure create_building_block_a
  (p_effective_date            in date
  ,p_type                      in varchar2
  ,p_measure                   in number
  ,p_unit_of_measure           in varchar2
  ,p_start_time                in date
  ,p_stop_time                 in date
  ,p_parent_building_block_id  in number
  ,p_parent_building_block_ovn in number
  ,p_scope                     in varchar2
  ,p_approval_style_id         in number
  ,p_approval_status           in varchar2
  ,p_resource_id               in number
  ,p_resource_type             in varchar2
  ,p_comment_text              in varchar2
  ,p_time_building_block_id    in number
  ,p_object_version_number     in number
  ,p_application_set_id        in number
  ,p_translation_display_key   in varchar2
  );

end hxc_building_block_api_bk1;

 

/
