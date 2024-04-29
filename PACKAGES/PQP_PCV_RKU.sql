--------------------------------------------------------
--  DDL for Package PQP_PCV_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_RKU" AUTHID CURRENT_USER as
/* $Header: pqpcvrhi.pkh 120.0 2005/05/29 01:55:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_configuration_value_id       in number
  ,p_business_group_id            in number
  ,p_legislation_code             in varchar2
  ,p_pcv_attribute_category       in varchar2
  ,p_pcv_attribute1               in varchar2
  ,p_pcv_attribute2               in varchar2
  ,p_pcv_attribute3               in varchar2
  ,p_pcv_attribute4               in varchar2
  ,p_pcv_attribute5               in varchar2
  ,p_pcv_attribute6               in varchar2
  ,p_pcv_attribute7               in varchar2
  ,p_pcv_attribute8               in varchar2
  ,p_pcv_attribute9               in varchar2
  ,p_pcv_attribute10              in varchar2
  ,p_pcv_attribute11              in varchar2
  ,p_pcv_attribute12              in varchar2
  ,p_pcv_attribute13              in varchar2
  ,p_pcv_attribute14              in varchar2
  ,p_pcv_attribute15              in varchar2
  ,p_pcv_attribute16              in varchar2
  ,p_pcv_attribute17              in varchar2
  ,p_pcv_attribute18              in varchar2
  ,p_pcv_attribute19              in varchar2
  ,p_pcv_attribute20              in varchar2
  ,p_pcv_information_category     in varchar2
  ,p_pcv_information1             in varchar2
  ,p_pcv_information2             in varchar2
  ,p_pcv_information3             in varchar2
  ,p_pcv_information4             in varchar2
  ,p_pcv_information5             in varchar2
  ,p_pcv_information6             in varchar2
  ,p_pcv_information7             in varchar2
  ,p_pcv_information8             in varchar2
  ,p_pcv_information9             in varchar2
  ,p_pcv_information10            in varchar2
  ,p_pcv_information11            in varchar2
  ,p_pcv_information12            in varchar2
  ,p_pcv_information13            in varchar2
  ,p_pcv_information14            in varchar2
  ,p_pcv_information15            in varchar2
  ,p_pcv_information16            in varchar2
  ,p_pcv_information17            in varchar2
  ,p_pcv_information18            in varchar2
  ,p_pcv_information19            in varchar2
  ,p_pcv_information20            in varchar2
  ,p_object_version_number        in number
  ,p_configuration_name           in varchar2
  ,p_business_group_id_o          in number
  ,p_legislation_code_o           in varchar2
  ,p_pcv_attribute_category_o     in varchar2
  ,p_pcv_attribute1_o             in varchar2
  ,p_pcv_attribute2_o             in varchar2
  ,p_pcv_attribute3_o             in varchar2
  ,p_pcv_attribute4_o             in varchar2
  ,p_pcv_attribute5_o             in varchar2
  ,p_pcv_attribute6_o             in varchar2
  ,p_pcv_attribute7_o             in varchar2
  ,p_pcv_attribute8_o             in varchar2
  ,p_pcv_attribute9_o             in varchar2
  ,p_pcv_attribute10_o            in varchar2
  ,p_pcv_attribute11_o            in varchar2
  ,p_pcv_attribute12_o            in varchar2
  ,p_pcv_attribute13_o            in varchar2
  ,p_pcv_attribute14_o            in varchar2
  ,p_pcv_attribute15_o            in varchar2
  ,p_pcv_attribute16_o            in varchar2
  ,p_pcv_attribute17_o            in varchar2
  ,p_pcv_attribute18_o            in varchar2
  ,p_pcv_attribute19_o            in varchar2
  ,p_pcv_attribute20_o            in varchar2
  ,p_pcv_information_category_o   in varchar2
  ,p_pcv_information1_o           in varchar2
  ,p_pcv_information2_o           in varchar2
  ,p_pcv_information3_o           in varchar2
  ,p_pcv_information4_o           in varchar2
  ,p_pcv_information5_o           in varchar2
  ,p_pcv_information6_o           in varchar2
  ,p_pcv_information7_o           in varchar2
  ,p_pcv_information8_o           in varchar2
  ,p_pcv_information9_o           in varchar2
  ,p_pcv_information10_o          in varchar2
  ,p_pcv_information11_o          in varchar2
  ,p_pcv_information12_o          in varchar2
  ,p_pcv_information13_o          in varchar2
  ,p_pcv_information14_o          in varchar2
  ,p_pcv_information15_o          in varchar2
  ,p_pcv_information16_o          in varchar2
  ,p_pcv_information17_o          in varchar2
  ,p_pcv_information18_o          in varchar2
  ,p_pcv_information19_o          in varchar2
  ,p_pcv_information20_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_configuration_name_o         in varchar2
  );
--
end pqp_pcv_rku;

 

/
