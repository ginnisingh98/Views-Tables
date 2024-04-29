--------------------------------------------------------
--  DDL for Package OTA_OCL_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OCL_RKU" AUTHID CURRENT_USER as
/* $Header: otoclrhi.pkh 120.1 2007/02/07 09:18:56 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_competence_language_id       in number
  ,p_competence_id                in number
  ,p_language_code                  in varchar2
  ,p_min_proficiency_level_id     in number
  ,p_business_group_id            in number
  ,p_object_version_number        in number
  ,p_ocl_information_category     in varchar2
  ,p_ocl_information1             in varchar2
  ,p_ocl_information2             in varchar2
  ,p_ocl_information3             in varchar2
  ,p_ocl_information4             in varchar2
  ,p_ocl_information5             in varchar2
  ,p_ocl_information6             in varchar2
  ,p_ocl_information7             in varchar2
  ,p_ocl_information8             in varchar2
  ,p_ocl_information9             in varchar2
  ,p_ocl_information10            in varchar2
  ,p_ocl_information11            in varchar2
  ,p_ocl_information12            in varchar2
  ,p_ocl_information13            in varchar2
  ,p_ocl_information14            in varchar2
  ,p_ocl_information15            in varchar2
  ,p_ocl_information16            in varchar2
  ,p_ocl_information17            in varchar2
  ,p_ocl_information18            in varchar2
  ,p_ocl_information19            in varchar2
  ,p_ocl_information20            in varchar2
  ,p_competence_id_o              in number
  ,p_language_code_o                in varchar2
  ,p_min_proficiency_level_id_o   in number
  ,p_business_group_id_o          in number
  ,p_object_version_number_o      in number
  ,p_ocl_information_category_o   in varchar2
  ,p_ocl_information1_o           in varchar2
  ,p_ocl_information2_o           in varchar2
  ,p_ocl_information3_o           in varchar2
  ,p_ocl_information4_o           in varchar2
  ,p_ocl_information5_o           in varchar2
  ,p_ocl_information6_o           in varchar2
  ,p_ocl_information7_o           in varchar2
  ,p_ocl_information8_o           in varchar2
  ,p_ocl_information9_o           in varchar2
  ,p_ocl_information10_o          in varchar2
  ,p_ocl_information11_o          in varchar2
  ,p_ocl_information12_o          in varchar2
  ,p_ocl_information13_o          in varchar2
  ,p_ocl_information14_o          in varchar2
  ,p_ocl_information15_o          in varchar2
  ,p_ocl_information16_o          in varchar2
  ,p_ocl_information17_o          in varchar2
  ,p_ocl_information18_o          in varchar2
  ,p_ocl_information19_o          in varchar2
  ,p_ocl_information20_o          in varchar2
  );
--
end ota_ocl_rku;

/
