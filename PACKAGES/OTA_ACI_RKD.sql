--------------------------------------------------------
--  DDL for Package OTA_ACI_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ACI_RKD" AUTHID CURRENT_USER as
/* $Header: otacirhi.pkh 120.0 2005/05/29 06:51:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_activity_version_id          in number
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
end ota_aci_rkd;

 

/
