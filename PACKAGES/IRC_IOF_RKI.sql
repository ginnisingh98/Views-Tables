--------------------------------------------------------
--  DDL for Package IRC_IOF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IOF_RKI" AUTHID CURRENT_USER as
/* $Header: iriofrhi.pkh 120.1 2005/09/29 09:32 mmillmor noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_offer_id                     in number
  ,p_offer_version                in number
  ,p_latest_offer                 in varchar2
  ,p_offer_status                 in varchar2
  ,p_discretionary_job_title      in varchar2
  ,p_offer_extended_method        in varchar2
  ,p_respondent_id                in number
  ,p_expiry_date                  in date
  ,p_proposed_start_date          in date
  ,p_offer_letter_tracking_code   in varchar2
  ,p_offer_postal_service         in varchar2
  ,p_offer_shipping_date          in date
  ,p_vacancy_id                   in number
  ,p_applicant_assignment_id      in number
  ,p_offer_assignment_id          in number
  ,p_address_id                   in number
  ,p_template_id                  in number
  ,p_offer_letter_file_type       in varchar2
  ,p_offer_letter_file_name       in varchar2
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
  ,p_attribute21                  in varchar2
  ,p_attribute22                  in varchar2
  ,p_attribute23                  in varchar2
  ,p_attribute24                  in varchar2
  ,p_attribute25                  in varchar2
  ,p_attribute26                  in varchar2
  ,p_attribute27                  in varchar2
  ,p_attribute28                  in varchar2
  ,p_attribute29                  in varchar2
  ,p_attribute30                  in varchar2
  ,p_object_version_number        in number
  );
end irc_iof_rki;

 

/
