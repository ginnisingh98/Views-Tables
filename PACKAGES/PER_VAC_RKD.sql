--------------------------------------------------------
--  DDL for Package PER_VAC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VAC_RKD" AUTHID CURRENT_USER as
/* $Header: pevacrhi.pkh 120.0 2005/05/31 22:51:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_vacancy_id                   in number
  ,p_business_group_id_o          in number
  ,p_position_id_o                in number
  ,p_job_id_o                     in number
  ,p_grade_id_o                   in number
  ,p_organization_id_o            in number
  ,p_requisition_id_o             in number
  ,p_people_group_id_o            in number
  ,p_location_id_o                in number
  ,p_recruiter_id_o               in number
  ,p_date_from_o                  in date
  ,p_name_o                       in varchar2
  ,p_comments_o                   in varchar2
  ,p_date_to_o                    in date
  ,p_description_o                in varchar2
  ,p_number_of_openings_o         in number
  ,p_status_o                     in varchar2
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
  ,p_vacancy_category_o           in varchar2
  ,p_budget_measurement_type_o    in varchar2
  ,p_budget_measurement_value_o   in number
  ,p_manager_id_o                 in number
  ,p_security_method_o            in varchar2
  ,p_primary_posting_id_o         in number
  ,p_assessment_id_o              in number
  ,p_object_version_number_o      in number
  );
--
end per_vac_rkd;

 

/
