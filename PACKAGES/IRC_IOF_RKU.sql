--------------------------------------------------------
--  DDL for Package IRC_IOF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IOF_RKU" AUTHID CURRENT_USER as
/* $Header: iriofrhi.pkh 120.1 2005/09/29 09:32 mmillmor noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
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
  ,p_offer_version_o              in number
  ,p_latest_offer_o               in varchar2
  ,p_offer_status_o               in varchar2
  ,p_discretionary_job_title_o    in varchar2
  ,p_offer_extended_method_o      in varchar2
  ,p_respondent_id_o              in number
  ,p_expiry_date_o                in date
  ,p_proposed_start_date_o        in date
  ,p_offer_letter_tracking_code_o in varchar2
  ,p_offer_postal_service_o       in varchar2
  ,p_offer_shipping_date_o        in date
  ,p_vacancy_id_o                 in number
  ,p_applicant_assignment_id_o    in number
  ,p_offer_assignment_id_o        in number
  ,p_address_id_o                 in number
  ,p_template_id_o                in number
  ,p_offer_letter_file_type_o     in varchar2
  ,p_offer_letter_file_name_o     in varchar2
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
  ,p_object_version_number_o      in number
  );
--
end irc_iof_rku;

 

/
