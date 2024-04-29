--------------------------------------------------------
--  DDL for Package PER_CTC_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CTC_RKI" AUTHID CURRENT_USER as
/* $Header: pectcrhi.pkh 120.0 2005/05/31 07:20:26 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (
  p_contract_id                  in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_business_group_id            in number,
  p_object_version_number        in number,
  p_person_id                    in number,
  p_reference                    in varchar2,
  p_type                         in varchar2,
  p_status                       in varchar2,
  p_status_reason                in varchar2,
  p_doc_status                   in varchar2,
  p_doc_status_change_date       in date,
  p_description                  in varchar2,
  p_duration                     in number,
  p_duration_units               in varchar2,
  p_contractual_job_title        in varchar2,
  p_parties                      in varchar2,
  p_start_reason                 in varchar2,
  p_end_reason                   in varchar2,
  p_number_of_extensions         in number,
  p_extension_reason             in varchar2,
  p_extension_period             in number,
  p_extension_period_units       in varchar2,
  p_ctr_information_category     in varchar2,
  p_ctr_information1             in varchar2,
  p_ctr_information2             in varchar2,
  p_ctr_information3             in varchar2,
  p_ctr_information4             in varchar2,
  p_ctr_information5             in varchar2,
  p_ctr_information6             in varchar2,
  p_ctr_information7             in varchar2,
  p_ctr_information8             in varchar2,
  p_ctr_information9             in varchar2,
  p_ctr_information10            in varchar2,
  p_ctr_information11            in varchar2,
  p_ctr_information12            in varchar2,
  p_ctr_information13            in varchar2,
  p_ctr_information14            in varchar2,
  p_ctr_information15            in varchar2,
  p_ctr_information16            in varchar2,
  p_ctr_information17            in varchar2,
  p_ctr_information18            in varchar2,
  p_ctr_information19            in varchar2,
  p_ctr_information20            in varchar2,
  p_attribute_category           in varchar2,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_attribute11                  in varchar2,
  p_attribute12                  in varchar2,
  p_attribute13                  in varchar2,
  p_attribute14                  in varchar2,
  p_attribute15                  in varchar2,
  p_attribute16                  in varchar2,
  p_attribute17                  in varchar2,
  p_attribute18                  in varchar2,
  p_attribute19                  in varchar2,
  p_attribute20                  in varchar2,
  p_effective_date               in date,
  p_validation_start_date        in date,
  p_validation_end_date          in date
  );
end per_ctc_rki;

 

/
