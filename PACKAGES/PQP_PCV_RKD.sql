--------------------------------------------------------
--  DDL for Package PQP_PCV_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PCV_RKD" AUTHID CURRENT_USER as
/* $Header: pqpcvrhi.pkh 120.0 2005/05/29 01:55:28 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_configuration_value_id       in number
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
end pqp_pcv_rkd;

 

/
