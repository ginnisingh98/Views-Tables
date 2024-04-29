--------------------------------------------------------
--  DDL for Package PER_EQT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_EQT_RKD" AUTHID CURRENT_USER as
/* $Header: peeqtrhi.pkh 120.0 2005/05/31 08:13:14 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------------< after_delete >----------------------------------|
-- ----------------------------------------------------------------------------
--
-- This procedure is for the row handler user hook. The package body is generated.

-- Added Developer DF Columns

Procedure after_delete
  (p_qualification_type_id    in number
  ,p_object_version_number    in number
  ,p_name_o                   in varchar2
  ,p_category_o               in varchar2
  ,p_rank_o                   in number
  ,p_attribute_category_o     in varchar2
  ,p_attribute1_o             in varchar2
  ,p_attribute2_o             in varchar2
  ,p_attribute3_o             in varchar2
  ,p_attribute4_o             in varchar2
  ,p_attribute5_o             in varchar2
  ,p_attribute6_o             in varchar2
  ,p_attribute7_o             in varchar2
  ,p_attribute8_o             in varchar2
  ,p_attribute9_o             in varchar2
  ,p_attribute10_o            in varchar2
  ,p_attribute11_o            in varchar2
  ,p_attribute12_o            in varchar2
  ,p_attribute13_o            in varchar2
  ,p_attribute14_o            in varchar2
  ,p_attribute15_o            in varchar2
  ,p_attribute16_o            in varchar2
  ,p_attribute17_o            in varchar2
  ,p_attribute18_o            in varchar2
  ,p_attribute19_o            in varchar2
  ,p_attribute20_o            in varchar2
  ,p_object_version_number_o  in number
  ,p_information_category_o in varchar2
  ,p_information1_o	      in varchar2
  ,p_information2_o	      in varchar2
  ,p_information3_o	      in varchar2
  ,p_information4_o	      in varchar2
  ,p_information5_o	      in varchar2
  ,p_information6_o	      in varchar2
  ,p_information7_o	      in varchar2
  ,p_information8_o	      in varchar2
  ,p_information9_o	      in varchar2
  ,p_information10_o          in varchar2
  ,p_information11_o          in varchar2
  ,p_information12_o          in varchar2
  ,p_information13_o          in varchar2
  ,p_information14_o          in varchar2
  ,p_information15_o          in varchar2
  ,p_information16_o          in varchar2
  ,p_information17_o          in varchar2
  ,p_information18_o          in varchar2
  ,p_information19_o          in varchar2
  ,p_information20_o          in varchar2
  ,p_information21_o          in varchar2
  ,p_information22_o          in varchar2
  ,p_information23_o          in varchar2
  ,p_information24_o          in varchar2
  ,p_information25_o          in varchar2
  ,p_information26_o          in varchar2
  ,p_information27_o          in varchar2
  ,p_information28_o          in varchar2
  ,p_information29_o          in varchar2
  ,p_information30_o          in varchar2
  ,p_qual_framework_id_o      in number
  ,p_qualification_type_o     in varchar2
  ,p_credit_type_o            in varchar2
  ,p_credits_o                in number
  ,p_level_type_o             in varchar2
  ,p_level_number_o           in number
  ,p_field_o                  in varchar2
  ,p_sub_field_o              in varchar2
  ,p_provider_o               in varchar2
  ,p_qa_organization_o        in varchar2
   );
end per_eqt_rkd;

 

/
