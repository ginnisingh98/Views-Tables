--------------------------------------------------------
--  DDL for Package PER_CTC_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTC_RKD" AUTHID CURRENT_USER as
/* $Header: pectcrhi.pkh 120.0 2005/05/31 07:20:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (
  p_effective_date               in date,
  p_datetrack_mode               in varchar2,
  p_validation_start_date        in date,
  p_validation_end_date          in date,
  p_contract_id                  in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_object_version_number        in number,
  p_effective_start_date_o       in date,
  p_effective_end_date_o         in date,
  p_business_group_id_o          in number,
  p_person_id_o                  in number,
  p_reference_o                  in varchar2,
  p_type_o                       in varchar2,
  p_status_o                     in varchar2,
  p_status_reason_o              in varchar2,
  p_doc_status_o                 in varchar2,
  p_doc_status_change_date_o     in date,
  p_description_o                in varchar2,
  p_duration_o                   in number,
  p_duration_units_o             in varchar2,
  p_contractual_job_title_o      in varchar2,
  p_parties_o                    in varchar2,
  p_start_reason_o               in varchar2,
  p_end_reason_o                 in varchar2,
  p_number_of_extensions_o       in number,
  p_extension_reason_o           in varchar2,
  p_extension_period_o           in number,
  p_extension_period_units_o     in varchar2,
  p_ctr_information_category_o   in varchar2,
  p_ctr_information1_o           in varchar2,
  p_ctr_information2_o           in varchar2,
  p_ctr_information3_o           in varchar2,
  p_ctr_information4_o           in varchar2,
  p_ctr_information5_o           in varchar2,
  p_ctr_information6_o           in varchar2,
  p_ctr_information7_o           in varchar2,
  p_ctr_information8_o           in varchar2,
  p_ctr_information9_o           in varchar2,
  p_ctr_information10_o          in varchar2,
  p_ctr_information11_o          in varchar2,
  p_ctr_information12_o          in varchar2,
  p_ctr_information13_o          in varchar2,
  p_ctr_information14_o          in varchar2,
  p_ctr_information15_o          in varchar2,
  p_ctr_information16_o          in varchar2,
  p_ctr_information17_o          in varchar2,
  p_ctr_information18_o          in varchar2,
  p_ctr_information19_o          in varchar2,
  p_ctr_information20_o          in varchar2,
  p_attribute_category_o         in varchar2,
  p_attribute1_o                 in varchar2,
  p_attribute2_o                 in varchar2,
  p_attribute3_o                 in varchar2,
  p_attribute4_o                 in varchar2,
  p_attribute5_o                 in varchar2,
  p_attribute6_o                 in varchar2,
  p_attribute7_o                 in varchar2,
  p_attribute8_o                 in varchar2,
  p_attribute9_o                 in varchar2,
  p_attribute10_o                in varchar2,
  p_attribute11_o                in varchar2,
  p_attribute12_o                in varchar2,
  p_attribute13_o                in varchar2,
  p_attribute14_o                in varchar2,
  p_attribute15_o                in varchar2,
  p_attribute16_o                in varchar2,
  p_attribute17_o                in varchar2,
  p_attribute18_o                in varchar2,
  p_attribute19_o                in varchar2,
  p_attribute20_o                in varchar2,
  p_object_version_number_o      in number
  );
--
end per_ctc_rkd;

 

/
