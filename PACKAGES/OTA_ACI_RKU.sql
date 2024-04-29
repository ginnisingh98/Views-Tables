--------------------------------------------------------
--  DDL for Package OTA_ACI_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACI_RKU" AUTHID CURRENT_USER as
/* $Header: otacirhi.pkh 120.0 2005/05/29 06:51:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_activity_version_id          in number
  ,p_activity_category            in varchar2
  ,p_object_version_number        in number
  ,p_event_id                     in number
  ,p_comments                     in varchar2
  ,p_aci_information_category     in varchar2
  ,p_aci_information1             in varchar2
  ,p_aci_information2             in varchar2
  ,p_aci_information3             in varchar2
  ,p_aci_information4             in varchar2
  ,p_aci_information5             in varchar2
  ,p_aci_information6             in varchar2
  ,p_aci_information7             in varchar2
  ,p_aci_information8             in varchar2
  ,p_aci_information9             in varchar2
  ,p_aci_information10            in varchar2
  ,p_aci_information11            in varchar2
  ,p_aci_information12            in varchar2
  ,p_aci_information13            in varchar2
  ,p_aci_information14            in varchar2
  ,p_aci_information15            in varchar2
  ,p_aci_information16            in varchar2
  ,p_aci_information17            in varchar2
  ,p_aci_information18            in varchar2
  ,p_aci_information19            in varchar2
  ,p_aci_information20            in varchar2
  ,p_start_date_active            in date
  ,p_end_date_active              in date
  ,p_primary_flag                 in varchar2
  ,p_category_usage_id            in number
  ,p_activity_category_o          in varchar2
  ,p_object_version_number_o      in number
  ,p_event_id_o                   in number
  ,p_comments_o                   in varchar2
  ,p_aci_information_category_o   in varchar2
  ,p_aci_information1_o           in varchar2
  ,p_aci_information2_o           in varchar2
  ,p_aci_information3_o           in varchar2
  ,p_aci_information4_o           in varchar2
  ,p_aci_information5_o           in varchar2
  ,p_aci_information6_o           in varchar2
  ,p_aci_information7_o           in varchar2
  ,p_aci_information8_o           in varchar2
  ,p_aci_information9_o           in varchar2
  ,p_aci_information10_o          in varchar2
  ,p_aci_information11_o          in varchar2
  ,p_aci_information12_o          in varchar2
  ,p_aci_information13_o          in varchar2
  ,p_aci_information14_o          in varchar2
  ,p_aci_information15_o          in varchar2
  ,p_aci_information16_o          in varchar2
  ,p_aci_information17_o          in varchar2
  ,p_aci_information18_o          in varchar2
  ,p_aci_information19_o          in varchar2
  ,p_aci_information20_o          in varchar2
  ,p_start_date_active_o          in date
  ,p_end_date_active_o            in date
  ,p_primary_flag_o               in varchar2
  );
--
end ota_aci_rku;

 

/
