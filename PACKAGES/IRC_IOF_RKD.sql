--------------------------------------------------------
--  DDL for Package IRC_IOF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_IOF_RKD" AUTHID CURRENT_USER as
/* $Header: iriofrhi.pkh 120.1 2005/09/29 09:32 mmillmor noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_offer_id                     in number
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
end irc_iof_rkd;

 

/
