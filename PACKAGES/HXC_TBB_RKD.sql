--------------------------------------------------------
--  DDL for Package HXC_TBB_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TBB_RKD" AUTHID CURRENT_USER as
/* $Header: hxctbbrhi.pkh 120.1 2005/07/14 17:23:33 arundell noship $ */

-- --------------------------------------------------------------------------
-- |----------------------------< after_delete >----------------------------|
-- --------------------------------------------------------------------------

procedure after_delete
  (p_time_building_block_id       in number
  ,p_type_o                       in varchar2
  ,p_measure_o                    in number
  ,p_unit_of_measure_o            in varchar2
  ,p_start_time_o                 in date
  ,p_stop_time_o                  in date
  ,p_parent_building_block_id_o   in number
  ,p_parent_building_block_ovn_o  in number
  ,p_scope_o                      in varchar2
  ,p_object_version_number_o      in number
  ,p_approval_status_o            in varchar2
  ,p_resource_id_o                in number
  ,p_resource_type_o              in varchar2
  ,p_approval_style_id_o          in number
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_comment_text_o               in varchar2
  ,p_application_set_id_o         in number
  ,p_translation_display_key_o    in varchar2
  );

end hxc_tbb_rkd;

 

/
