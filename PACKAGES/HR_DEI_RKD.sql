--------------------------------------------------------
--  DDL for Package HR_DEI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DEI_RKD" AUTHID CURRENT_USER as
/* $Header: hrdeirhi.pkh 120.1.12010000.2 2010/04/07 11:45:05 tkghosh ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_document_extra_info_id       in number
  ,p_person_id_o                  in number
  ,p_document_type_id_o           in number
  ,p_document_number_o            in varchar2
  ,p_date_from_o                  in date
  ,p_date_to_o                    in date
  ,p_issued_by_o                  in varchar2
  ,p_issued_at_o                  in varchar2
  ,p_issued_date_o                in date
  ,p_issuing_authority_o          in varchar2
  ,p_verified_by_o                in number
  ,p_verified_date_o              in date
  ,p_related_object_name_o        in varchar2
  ,p_related_object_id_col_o      in varchar2
  ,p_related_object_id_o          in number
  ,p_dei_attribute_category_o     in varchar2
  ,p_dei_attribute1_o             in varchar2
  ,p_dei_attribute2_o             in varchar2
  ,p_dei_attribute3_o             in varchar2
  ,p_dei_attribute4_o             in varchar2
  ,p_dei_attribute5_o             in varchar2
  ,p_dei_attribute6_o             in varchar2
  ,p_dei_attribute7_o             in varchar2
  ,p_dei_attribute8_o             in varchar2
  ,p_dei_attribute9_o             in varchar2
  ,p_dei_attribute10_o            in varchar2
  ,p_dei_attribute11_o            in varchar2
  ,p_dei_attribute12_o            in varchar2
  ,p_dei_attribute13_o            in varchar2
  ,p_dei_attribute14_o            in varchar2
  ,p_dei_attribute15_o            in varchar2
  ,p_dei_attribute16_o            in varchar2
  ,p_dei_attribute17_o            in varchar2
  ,p_dei_attribute18_o            in varchar2
  ,p_dei_attribute19_o            in varchar2
  ,p_dei_attribute20_o            in varchar2
  ,p_dei_attribute21_o            in varchar2
  ,p_dei_attribute22_o            in varchar2
  ,p_dei_attribute23_o            in varchar2
  ,p_dei_attribute24_o            in varchar2
  ,p_dei_attribute25_o            in varchar2
  ,p_dei_attribute26_o            in varchar2
  ,p_dei_attribute27_o            in varchar2
  ,p_dei_attribute28_o            in varchar2
  ,p_dei_attribute29_o            in varchar2
  ,p_dei_attribute30_o            in varchar2
  ,p_dei_information_category_o   in varchar2
  ,p_dei_information1_o           in varchar2
  ,p_dei_information2_o           in varchar2
  ,p_dei_information3_o           in varchar2
  ,p_dei_information4_o           in varchar2
  ,p_dei_information5_o           in varchar2
  ,p_dei_information6_o           in varchar2
  ,p_dei_information7_o           in varchar2
  ,p_dei_information8_o           in varchar2
  ,p_dei_information9_o           in varchar2
  ,p_dei_information10_o          in varchar2
  ,p_dei_information11_o          in varchar2
  ,p_dei_information12_o          in varchar2
  ,p_dei_information13_o          in varchar2
  ,p_dei_information14_o          in varchar2
  ,p_dei_information15_o          in varchar2
  ,p_dei_information16_o          in varchar2
  ,p_dei_information17_o          in varchar2
  ,p_dei_information18_o          in varchar2
  ,p_dei_information19_o          in varchar2
  ,p_dei_information20_o          in varchar2
  ,p_dei_information21_o          in varchar2
  ,p_dei_information22_o          in varchar2
  ,p_dei_information23_o          in varchar2
  ,p_dei_information24_o          in varchar2
  ,p_dei_information25_o          in varchar2
  ,p_dei_information26_o          in varchar2
  ,p_dei_information27_o          in varchar2
  ,p_dei_information28_o          in varchar2
  ,p_dei_information29_o          in varchar2
  ,p_dei_information30_o          in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_object_version_number_o      in number
  );
--
end hr_dei_rkd;

/
