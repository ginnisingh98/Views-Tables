--------------------------------------------------------
--  DDL for Package HR_ORU_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORU_RKD" AUTHID CURRENT_USER as
/* $Header: hrorurhi.pkh 120.1 2005/07/15 06:03:15 bshukla noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_organization_id              in number
  ,p_business_group_id_o          in number
  ,p_cost_allocation_keyflex_id_o in number
  ,p_location_id_o                in number
  ,p_soft_coding_keyflex_id_o     in number
  ,p_date_from_o                  in date
  ,p_name_o                       in varchar2
  ,p_comments_o                   in varchar2
  ,p_date_to_o                    in date
  ,p_internal_external_flag_o     in varchar2
  ,p_internal_address_line_o      in varchar2
  ,p_type_o                       in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_attribute_category_o         in varchar2
  ,p_attribute1_o                 in varchar2
  ,p_attribute2_o                 in varchar2
  ,p_attribute3_o                 in varchar2
  ,p_attribute4_o                 in varchar2
  ,p_attribute5_o                 in varchar2
  ,p_attribute6_o                 in varchar2
  ,p_attribute7_o                 in varchar2
  ,p_attribute8_o                 in varchar2
  ,p_attribute9_o                 in varchar2
  ,p_attribute10_o                in varchar2
  ,p_attribute11_o                in varchar2
  ,p_attribute12_o                in varchar2
  ,p_attribute13_o                in varchar2
  ,p_attribute14_o                in varchar2
  ,p_attribute15_o                in varchar2
  ,p_attribute16_o                in varchar2
  ,p_attribute17_o                in varchar2
  ,p_attribute18_o                in varchar2
  ,p_attribute19_o                in varchar2
  ,p_attribute20_o                in varchar2
  --Enhancement 4040086
  ,p_attribute21_o                in varchar2
  ,p_attribute22_o                in varchar2
  ,p_attribute23_o                in varchar2
  ,p_attribute24_o                in varchar2
  ,p_attribute25_o                in varchar2
  ,p_attribute26_o                in varchar2
  ,p_attribute27_o                in varchar2
  ,p_attribute28_o                in varchar2
  ,p_attribute29_o                in varchar2
  ,p_attribute30_o                in varchar2
  --End Enhancement 4040086
  ,p_object_version_number_o      in number
  );
--
end hr_oru_rkd;

 

/
