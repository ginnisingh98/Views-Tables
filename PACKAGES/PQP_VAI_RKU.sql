--------------------------------------------------------
--  DDL for Package PQP_VAI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VAI_RKU" AUTHID CURRENT_USER as
/* $Header: pqvairhi.pkh 120.0.12010000.2 2008/08/08 07:19:40 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_veh_alloc_extra_info_id      in number
  ,p_vehicle_allocation_id        in number
  ,p_information_type             in varchar2
  ,p_vaei_attribute_category      in varchar2
  ,p_vaei_attribute1              in varchar2
  ,p_vaei_attribute2              in varchar2
  ,p_vaei_attribute3              in varchar2
  ,p_vaei_attribute4              in varchar2
  ,p_vaei_attribute5              in varchar2
  ,p_vaei_attribute6              in varchar2
  ,p_vaei_attribute7              in varchar2
  ,p_vaei_attribute8              in varchar2
  ,p_vaei_attribute9              in varchar2
  ,p_vaei_attribute10             in varchar2
  ,p_vaei_attribute11             in varchar2
  ,p_vaei_attribute12             in varchar2
  ,p_vaei_attribute13             in varchar2
  ,p_vaei_attribute14             in varchar2
  ,p_vaei_attribute15             in varchar2
  ,p_vaei_attribute16             in varchar2
  ,p_vaei_attribute17             in varchar2
  ,p_vaei_attribute18             in varchar2
  ,p_vaei_attribute19             in varchar2
  ,p_vaei_attribute20             in varchar2
  ,p_vaei_information_category    in varchar2
  ,p_vaei_information1            in varchar2
  ,p_vaei_information2            in varchar2
  ,p_vaei_information3            in varchar2
  ,p_vaei_information4            in varchar2
  ,p_vaei_information5            in varchar2
  ,p_vaei_information6            in varchar2
  ,p_vaei_information7            in varchar2
  ,p_vaei_information8            in varchar2
  ,p_vaei_information9            in varchar2
  ,p_vaei_information10           in varchar2
  ,p_vaei_information11           in varchar2
  ,p_vaei_information12           in varchar2
  ,p_vaei_information13           in varchar2
  ,p_vaei_information14           in varchar2
  ,p_vaei_information15           in varchar2
  ,p_vaei_information16           in varchar2
  ,p_vaei_information17           in varchar2
  ,p_vaei_information18           in varchar2
  ,p_vaei_information19           in varchar2
  ,p_vaei_information20           in varchar2
  ,p_vaei_information21           in varchar2
  ,p_vaei_information22           in varchar2
  ,p_vaei_information23           in varchar2
  ,p_vaei_information24           in varchar2
  ,p_vaei_information25           in varchar2
  ,p_vaei_information26           in varchar2
  ,p_vaei_information27           in varchar2
  ,p_vaei_information28           in varchar2
  ,p_vaei_information29           in varchar2
  ,p_vaei_information30           in varchar2
  ,p_object_version_number        in number
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_vehicle_allocation_id_o      in number
  ,p_information_type_o           in varchar2
  ,p_vaei_attribute_category_o    in varchar2
  ,p_vaei_attribute1_o            in varchar2
  ,p_vaei_attribute2_o            in varchar2
  ,p_vaei_attribute3_o            in varchar2
  ,p_vaei_attribute4_o            in varchar2
  ,p_vaei_attribute5_o            in varchar2
  ,p_vaei_attribute6_o            in varchar2
  ,p_vaei_attribute7_o            in varchar2
  ,p_vaei_attribute8_o            in varchar2
  ,p_vaei_attribute9_o            in varchar2
  ,p_vaei_attribute10_o           in varchar2
  ,p_vaei_attribute11_o           in varchar2
  ,p_vaei_attribute12_o           in varchar2
  ,p_vaei_attribute13_o           in varchar2
  ,p_vaei_attribute14_o           in varchar2
  ,p_vaei_attribute15_o           in varchar2
  ,p_vaei_attribute16_o           in varchar2
  ,p_vaei_attribute17_o           in varchar2
  ,p_vaei_attribute18_o           in varchar2
  ,p_vaei_attribute19_o           in varchar2
  ,p_vaei_attribute20_o           in varchar2
  ,p_vaei_information_category_o  in varchar2
  ,p_vaei_information1_o          in varchar2
  ,p_vaei_information2_o          in varchar2
  ,p_vaei_information3_o          in varchar2
  ,p_vaei_information4_o          in varchar2
  ,p_vaei_information5_o          in varchar2
  ,p_vaei_information6_o          in varchar2
  ,p_vaei_information7_o          in varchar2
  ,p_vaei_information8_o          in varchar2
  ,p_vaei_information9_o          in varchar2
  ,p_vaei_information10_o         in varchar2
  ,p_vaei_information11_o         in varchar2
  ,p_vaei_information12_o         in varchar2
  ,p_vaei_information13_o         in varchar2
  ,p_vaei_information14_o         in varchar2
  ,p_vaei_information15_o         in varchar2
  ,p_vaei_information16_o         in varchar2
  ,p_vaei_information17_o         in varchar2
  ,p_vaei_information18_o         in varchar2
  ,p_vaei_information19_o         in varchar2
  ,p_vaei_information20_o         in varchar2
  ,p_vaei_information21_o         in varchar2
  ,p_vaei_information22_o         in varchar2
  ,p_vaei_information23_o         in varchar2
  ,p_vaei_information24_o         in varchar2
  ,p_vaei_information25_o         in varchar2
  ,p_vaei_information26_o         in varchar2
  ,p_vaei_information27_o         in varchar2
  ,p_vaei_information28_o         in varchar2
  ,p_vaei_information29_o         in varchar2
  ,p_vaei_information30_o         in varchar2
  ,p_object_version_number_o      in number
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  );
--
end pqp_vai_rku;

/
