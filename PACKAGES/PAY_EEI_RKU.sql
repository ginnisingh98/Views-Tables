--------------------------------------------------------
--  DDL for Package PAY_EEI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EEI_RKU" AUTHID CURRENT_USER as
/* $Header: pyeeirhi.pkh 120.2 2005/08/20 09:39:31 rtahilia noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_element_type_extra_info_id   in number
  ,p_element_type_id              in number
  ,p_information_type             in varchar2
  ,p_request_id                   in number
  ,p_program_application_id       in number
  ,p_program_id                   in number
  ,p_program_update_date          in date
  ,p_eei_attribute_category       in varchar2
  ,p_eei_attribute1               in varchar2
  ,p_eei_attribute2               in varchar2
  ,p_eei_attribute3               in varchar2
  ,p_eei_attribute4               in varchar2
  ,p_eei_attribute5               in varchar2
  ,p_eei_attribute6               in varchar2
  ,p_eei_attribute7               in varchar2
  ,p_eei_attribute8               in varchar2
  ,p_eei_attribute9               in varchar2
  ,p_eei_attribute10              in varchar2
  ,p_eei_attribute11              in varchar2
  ,p_eei_attribute12              in varchar2
  ,p_eei_attribute13              in varchar2
  ,p_eei_attribute14              in varchar2
  ,p_eei_attribute15              in varchar2
  ,p_eei_attribute16              in varchar2
  ,p_eei_attribute17              in varchar2
  ,p_eei_attribute18              in varchar2
  ,p_eei_attribute19              in varchar2
  ,p_eei_attribute20              in varchar2
  ,p_eei_information_category     in varchar2
  ,p_eei_information1             in varchar2
  ,p_eei_information2             in varchar2
  ,p_eei_information3             in varchar2
  ,p_eei_information4             in varchar2
  ,p_eei_information5             in varchar2
  ,p_eei_information6             in varchar2
  ,p_eei_information7             in varchar2
  ,p_eei_information8             in varchar2
  ,p_eei_information9             in varchar2
  ,p_eei_information10            in varchar2
  ,p_eei_information11            in varchar2
  ,p_eei_information12            in varchar2
  ,p_eei_information13            in varchar2
  ,p_eei_information14            in varchar2
  ,p_eei_information15            in varchar2
  ,p_eei_information16            in varchar2
  ,p_eei_information17            in varchar2
  ,p_eei_information18            in varchar2
  ,p_eei_information19            in varchar2
  ,p_eei_information20            in varchar2
  ,p_eei_information21            in varchar2
  ,p_eei_information22            in varchar2
  ,p_eei_information23            in varchar2
  ,p_eei_information24            in varchar2
  ,p_eei_information25            in varchar2
  ,p_eei_information26            in varchar2
  ,p_eei_information27            in varchar2
  ,p_eei_information28            in varchar2
  ,p_eei_information29            in varchar2
  ,p_eei_information30            in varchar2
  ,p_object_version_number        in number
  ,p_element_type_id_o            in number
  ,p_information_type_o           in varchar2
  ,p_request_id_o                 in number
  ,p_program_application_id_o     in number
  ,p_program_id_o                 in number
  ,p_program_update_date_o        in date
  ,p_eei_attribute_category_o     in varchar2
  ,p_eei_attribute1_o             in varchar2
  ,p_eei_attribute2_o             in varchar2
  ,p_eei_attribute3_o             in varchar2
  ,p_eei_attribute4_o             in varchar2
  ,p_eei_attribute5_o             in varchar2
  ,p_eei_attribute6_o             in varchar2
  ,p_eei_attribute7_o             in varchar2
  ,p_eei_attribute8_o             in varchar2
  ,p_eei_attribute9_o             in varchar2
  ,p_eei_attribute10_o            in varchar2
  ,p_eei_attribute11_o            in varchar2
  ,p_eei_attribute12_o            in varchar2
  ,p_eei_attribute13_o            in varchar2
  ,p_eei_attribute14_o            in varchar2
  ,p_eei_attribute15_o            in varchar2
  ,p_eei_attribute16_o            in varchar2
  ,p_eei_attribute17_o            in varchar2
  ,p_eei_attribute18_o            in varchar2
  ,p_eei_attribute19_o            in varchar2
  ,p_eei_attribute20_o            in varchar2
  ,p_eei_information_category_o   in varchar2
  ,p_eei_information1_o           in varchar2
  ,p_eei_information2_o           in varchar2
  ,p_eei_information3_o           in varchar2
  ,p_eei_information4_o           in varchar2
  ,p_eei_information5_o           in varchar2
  ,p_eei_information6_o           in varchar2
  ,p_eei_information7_o           in varchar2
  ,p_eei_information8_o           in varchar2
  ,p_eei_information9_o           in varchar2
  ,p_eei_information10_o          in varchar2
  ,p_eei_information11_o          in varchar2
  ,p_eei_information12_o          in varchar2
  ,p_eei_information13_o          in varchar2
  ,p_eei_information14_o          in varchar2
  ,p_eei_information15_o          in varchar2
  ,p_eei_information16_o          in varchar2
  ,p_eei_information17_o          in varchar2
  ,p_eei_information18_o          in varchar2
  ,p_eei_information19_o          in varchar2
  ,p_eei_information20_o          in varchar2
  ,p_eei_information21_o          in varchar2
  ,p_eei_information22_o          in varchar2
  ,p_eei_information23_o          in varchar2
  ,p_eei_information24_o          in varchar2
  ,p_eei_information25_o          in varchar2
  ,p_eei_information26_o          in varchar2
  ,p_eei_information27_o          in varchar2
  ,p_eei_information28_o          in varchar2
  ,p_eei_information29_o          in varchar2
  ,p_eei_information30_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end pay_eei_rku;

 

/
