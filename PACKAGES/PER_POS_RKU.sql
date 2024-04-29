--------------------------------------------------------
--  DDL for Package PER_POS_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_POS_RKU" AUTHID CURRENT_USER as
/* $Header: peposrhi.pkh 120.0 2005/05/31 14:54:04 appldev noship $ */
--
-- ---------------------------------------------------------------------------+
-- |----------------------------< after_update >------------------------------|
-- ---------------------------------------------------------------------------+
--
procedure after_update
  (p_position_id                  in number
  ,p_successor_position_id        in number
  ,p_relief_position_id           in number
  ,p_location_id                  in number
  ,p_position_definition_id       in number
  ,p_date_effective               in date
  ,p_comments                     in varchar2
  ,p_date_end                     in date
  ,p_frequency                    in varchar2
  ,p_name                         in varchar2
  ,p_probation_period             in number
  ,p_probation_period_units       in varchar2
  ,p_replacement_required_flag    in varchar2
  ,p_time_normal_finish           in varchar2
  ,p_time_normal_start            in varchar2
  ,p_status                       in varchar2
  ,p_working_hours                in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_attribute_category           in varchar2
  ,p_attribute1                   in varchar2
  ,p_attribute2                   in varchar2
  ,p_attribute3                   in varchar2
  ,p_attribute4                   in varchar2
  ,p_attribute5                   in varchar2
  ,p_attribute6                   in varchar2
  ,p_attribute7                   in varchar2
  ,p_attribute8                   in varchar2
  ,p_attribute9                   in varchar2
  ,p_attribute10                  in varchar2
  ,p_attribute11                  in varchar2
  ,p_attribute12                  in varchar2
  ,p_attribute13                  in varchar2
  ,p_attribute14                  in varchar2
  ,p_attribute15                  in varchar2
  ,p_attribute16                  in varchar2
  ,p_attribute17                  in varchar2
  ,p_attribute18                  in varchar2
  ,p_attribute19                  in varchar2
  ,p_attribute20                  in varchar2
  ,p_object_version_number        in number
  ,p_business_group_id_o          in number
  ,p_job_id_o                     in number
  ,p_organization_id_o            in number
  ,p_successor_position_id_o      in number
  ,p_relief_position_id_o         in number
  ,p_location_id_o                in number
  ,p_position_definition_id_o     in number
  ,p_date_effective_o             in date
  ,p_comments_o                   in varchar2
  ,p_date_end_o                   in date
  ,p_frequency_o                  in varchar2
  ,p_name_o                       in varchar2
  ,p_probation_period_o           in number
  ,p_probation_period_units_o     in varchar2
  ,p_replacement_required_flag_o  in varchar2
  ,p_time_normal_finish_o         in varchar2
  ,p_time_normal_start_o          in varchar2
  ,p_status_o                     in varchar2
  ,p_working_hours_o              in number
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
  ,p_object_version_number_o      in number
  );
end per_pos_rku;

 

/
