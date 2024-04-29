--------------------------------------------------------
--  DDL for Package OTA_OCL_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_OCL_RKI" AUTHID CURRENT_USER as
/* $Header: otoclrhi.pkh 120.1 2007/02/07 09:18:56 niarora noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
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
  );
end ota_ocl_rki;

/
