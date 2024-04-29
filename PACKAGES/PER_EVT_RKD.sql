--------------------------------------------------------
--  DDL for Package PER_EVT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVT_RKD" AUTHID CURRENT_USER as
/* $Header: peevtrhi.pkh 120.0 2005/05/31 08:38:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_event_id                     in number
  ,p_business_group_id_o          in number
  ,p_location_id_o                in number
  ,p_internal_contact_person_id_o in number
  ,p_organization_run_by_id_o     in number
  ,p_assignment_id_o              in number
  ,p_date_start_o                 in date
  ,p_type_o                       in varchar2
  ,p_comments_o                   in varchar2
  ,p_contact_telephone_number_o   in varchar2
  ,p_date_end_o                   in date
  ,p_emp_or_apl_o                 in varchar2
  ,p_event_or_interview_o         in varchar2
  ,p_external_contact_o           in varchar2
  ,p_time_end_o                   in varchar2
  ,p_time_start_o                 in varchar2
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
  ,p_party_id_o                   in number
  ,p_object_version_number_o      in number
  );
--
end per_evt_rkd;

 

/
