--------------------------------------------------------
--  DDL for Package OTA_OCL_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OCL_RKD" AUTHID CURRENT_USER as
/* $Header: otoclrhi.pkh 120.1 2007/02/07 09:18:56 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_competence_language_id       in number
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
end ota_ocl_rkd;

/
