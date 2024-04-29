--------------------------------------------------------
--  DDL for Package OTA_RUD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RUD_RKD" AUTHID CURRENT_USER as
/* $Header: otrudrhi.pkh 120.0 2005/05/29 07:32:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_resource_usage_id            in number
  ,p_supplied_resource_id_o       in number
  ,p_activity_version_id_o        in number
  ,p_object_version_number_o      in number
  ,p_required_flag_o              in varchar2
  ,p_start_date_o                 in date
  ,p_comments_o                   in varchar2
  ,p_end_date_o                   in date
  ,p_quantity_o                   in number
  ,p_resource_type_o              in varchar2
  ,p_role_to_play_o               in varchar2
  ,p_usage_reason_o               in varchar2
  ,p_rud_information_category_o   in varchar2
  ,p_rud_information1_o           in varchar2
  ,p_rud_information2_o           in varchar2
  ,p_rud_information3_o           in varchar2
  ,p_rud_information4_o           in varchar2
  ,p_rud_information5_o           in varchar2
  ,p_rud_information6_o           in varchar2
  ,p_rud_information7_o           in varchar2
  ,p_rud_information8_o           in varchar2
  ,p_rud_information9_o           in varchar2
  ,p_rud_information10_o          in varchar2
  ,p_rud_information11_o          in varchar2
  ,p_rud_information12_o          in varchar2
  ,p_rud_information13_o          in varchar2
  ,p_rud_information14_o          in varchar2
  ,p_rud_information15_o          in varchar2
  ,p_rud_information16_o          in varchar2
  ,p_rud_information17_o          in varchar2
  ,p_rud_information18_o          in varchar2
  ,p_rud_information19_o          in varchar2
  ,p_rud_information20_o          in varchar2
  ,p_offering_id_o                in number
  );
--
end ota_rud_rkd;

 

/
