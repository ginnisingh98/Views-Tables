--------------------------------------------------------
--  DDL for Package PER_RAA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RAA_RKD" AUTHID CURRENT_USER as
/* $Header: peraarhi.pkh 120.0 2005/05/31 16:29:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_recruitment_activity_id      in number
  ,p_business_group_id_o          in number
  ,p_authorising_person_id_o      in number
  ,p_run_by_organization_id_o     in number
  ,p_internal_contact_person_id_o in number
  ,p_parent_recruitment_activit_o in number
  ,p_currency_code_o              in varchar2
  ,p_date_start_o                 in date
  ,p_name_o                       in varchar2
  ,p_actual_cost_o                in varchar2
  ,p_comments_o                   in varchar2
  ,p_contact_telephone_number_o   in varchar2
  ,p_date_closing_o               in date
  ,p_date_end_o                   in date
  ,p_external_contact_o           in varchar2
  ,p_planned_cost_o               in varchar2
  ,p_recruiting_site_id_o         in number
  ,p_recruiting_site_response_o   in varchar2
  ,p_last_posted_date_o           in varchar2
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
  ,p_posting_content_id_o         in number
  ,p_status_o                     in varchar2
  ,p_object_version_number_o      in number
  );
--
end per_raa_rkd;

 

/
