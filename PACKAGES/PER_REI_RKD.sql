--------------------------------------------------------
--  DDL for Package PER_REI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REI_RKD" AUTHID CURRENT_USER as
/* $Header: pereirhi.pkh 120.0 2005/05/31 17:34:06 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_contact_extra_info_id        in number
  ,p_effective_start_date         in date
  ,p_effective_end_date           in date
  ,p_effective_start_date_o       in date
  ,p_effective_end_date_o         in date
  ,p_contact_relationship_id_o    in number
  ,p_information_type_o           in varchar2
  ,p_cei_information_category_o   in varchar2
  ,p_cei_information1_o           in varchar2
  ,p_cei_information2_o           in varchar2
  ,p_cei_information3_o           in varchar2
  ,p_cei_information4_o           in varchar2
  ,p_cei_information5_o           in varchar2
  ,p_cei_information6_o           in varchar2
  ,p_cei_information7_o           in varchar2
  ,p_cei_information8_o           in varchar2
  ,p_cei_information9_o           in varchar2
  ,p_cei_information10_o          in varchar2
  ,p_cei_information11_o          in varchar2
  ,p_cei_information12_o          in varchar2
  ,p_cei_information13_o          in varchar2
  ,p_cei_information14_o          in varchar2
  ,p_cei_information15_o          in varchar2
  ,p_cei_information16_o          in varchar2
  ,p_cei_information17_o          in varchar2
  ,p_cei_information18_o          in varchar2
  ,p_cei_information19_o          in varchar2
  ,p_cei_information20_o          in varchar2
  ,p_cei_information21_o          in varchar2
  ,p_cei_information22_o          in varchar2
  ,p_cei_information23_o          in varchar2
  ,p_cei_information24_o          in varchar2
  ,p_cei_information25_o          in varchar2
  ,p_cei_information26_o          in varchar2
  ,p_cei_information27_o          in varchar2
  ,p_cei_information28_o          in varchar2
  ,p_cei_information29_o          in varchar2
  ,p_cei_information30_o          in varchar2
  ,p_cei_attribute_category_o     in varchar2
  ,p_cei_attribute1_o             in varchar2
  ,p_cei_attribute2_o             in varchar2
  ,p_cei_attribute3_o             in varchar2
  ,p_cei_attribute4_o             in varchar2
  ,p_cei_attribute5_o             in varchar2
  ,p_cei_attribute6_o             in varchar2
  ,p_cei_attribute7_o             in varchar2
  ,p_cei_attribute8_o             in varchar2
  ,p_cei_attribute9_o             in varchar2
  ,p_cei_attribute10_o            in varchar2
  ,p_cei_attribute11_o            in varchar2
  ,p_cei_attribute12_o            in varchar2
  ,p_cei_attribute13_o            in varchar2
  ,p_cei_attribute14_o            in varchar2
  ,p_cei_attribute15_o            in varchar2
  ,p_cei_attribute16_o            in varchar2
  ,p_cei_attribute17_o            in varchar2
  ,p_cei_attribute18_o            in varchar2
  ,p_cei_attribute19_o            in varchar2
  ,p_cei_attribute20_o            in varchar2
  ,p_object_version_number_o      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  );
--
end per_rei_rkd;

 

/
