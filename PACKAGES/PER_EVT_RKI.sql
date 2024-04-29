--------------------------------------------------------
--  DDL for Package PER_EVT_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EVT_RKI" AUTHID CURRENT_USER as
/* $Header: peevtrhi.pkh 120.0 2005/05/31 08:38:01 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_event_id                     in number
  ,p_business_group_id            in number
  ,p_location_id                  in number
  ,p_internal_contact_person_id   in number
  ,p_organization_run_by_id       in number
  ,p_assignment_id                in number
  ,p_date_start                   in date
  ,p_type                         in varchar2
  ,p_comments                     in varchar2
  ,p_contact_telephone_number     in varchar2
  ,p_date_end                     in date
  ,p_emp_or_apl                   in varchar2
  ,p_event_or_interview           in varchar2
  ,p_external_contact             in varchar2
  ,p_time_end                     in varchar2
  ,p_time_start                   in varchar2
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
  ,p_party_id                     in number
  ,p_object_version_number        in number
  );
end per_evt_rki;

 

/
