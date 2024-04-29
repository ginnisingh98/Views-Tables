--------------------------------------------------------
--  DDL for Package HXC_TBB_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TBB_RKI" AUTHID CURRENT_USER as
/* $Header: hxctbbrhi.pkh 120.1 2005/07/14 17:23:33 arundell noship $ */

-- --------------------------------------------------------------------------
-- |-----------------------------< after_insert >---------------------------|
-- --------------------------------------------------------------------------

procedure after_insert
  (p_effective_date            in date
  ,p_time_building_block_id    in number
  ,p_type                      in varchar2
  ,p_measure                   in number
  ,p_unit_of_measure           in varchar2
  ,p_start_time                in date
  ,p_stop_time                 in date
  ,p_parent_building_block_id  in number
  ,p_parent_building_block_ovn in number
  ,p_scope                     in varchar2
  ,p_object_version_number     in number
  ,p_approval_status           in varchar2
  ,p_resource_id               in number
  ,p_resource_type             in varchar2
  ,p_approval_style_id         in number
  ,p_date_from                 in date
  ,p_date_to                   in date
  ,p_comment_text              in varchar2
  ,p_application_set_id        in number
  ,p_translation_display_key   in varchar2
  );

end hxc_tbb_rki;

 

/
