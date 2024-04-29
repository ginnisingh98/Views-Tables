--------------------------------------------------------
--  DDL for Package OTA_RUD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_RUD_RKI" AUTHID CURRENT_USER as
/* $Header: otrudrhi.pkh 120.0 2005/05/29 07:32:29 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_resource_usage_id            in number
  ,p_supplied_resource_id         in number
  ,p_activity_version_id          in number
  ,p_object_version_number        in number
  ,p_required_flag                in varchar2
  ,p_start_date                   in date
  ,p_comments                     in varchar2
  ,p_end_date                     in date
  ,p_quantity                     in number
  ,p_resource_type                in varchar2
  ,p_role_to_play                 in varchar2
  ,p_usage_reason                 in varchar2
  ,p_rud_information_category     in varchar2
  ,p_rud_information1             in varchar2
  ,p_rud_information2             in varchar2
  ,p_rud_information3             in varchar2
  ,p_rud_information4             in varchar2
  ,p_rud_information5             in varchar2
  ,p_rud_information6             in varchar2
  ,p_rud_information7             in varchar2
  ,p_rud_information8             in varchar2
  ,p_rud_information9             in varchar2
  ,p_rud_information10            in varchar2
  ,p_rud_information11            in varchar2
  ,p_rud_information12            in varchar2
  ,p_rud_information13            in varchar2
  ,p_rud_information14            in varchar2
  ,p_rud_information15            in varchar2
  ,p_rud_information16            in varchar2
  ,p_rud_information17            in varchar2
  ,p_rud_information18            in varchar2
  ,p_rud_information19            in varchar2
  ,p_rud_information20            in varchar2
  ,p_offering_id                  in number
  );
end ota_rud_rki;

 

/
