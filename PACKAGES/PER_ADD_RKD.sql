--------------------------------------------------------
--  DDL for Package PER_ADD_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_RKD" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_address_id                   in  number
  ,p_business_group_id_o          in  number
  ,p_date_from_o                  in  date
  ,p_address_line1_o              in  varchar2
  ,p_address_line2_o              in  varchar2
  ,p_address_line3_o              in  varchar2
  ,p_address_type_o               in  varchar2
  ,p_comments_o                   in  long
  ,p_country_o                    in  varchar2
  ,p_date_to_o                    in  date
  ,p_postal_code_o                in  varchar2
  ,p_region_1_o                   in  varchar2
  ,p_region_2_o                   in  varchar2
  ,p_region_3_o                   in  varchar2
  ,p_telephone_number_1_o         in  varchar2
  ,p_telephone_number_2_o         in  varchar2
  ,p_telephone_number_3_o         in  varchar2
  ,p_town_or_city_o               in  varchar2
  ,p_request_id_o                 in  number
  ,p_program_application_id_o     in  number
  ,p_program_id_o                 in  number
  ,p_program_update_date_o        in  date
  ,p_addr_attribute_category_o    in  varchar2
  ,p_addr_attribute1_o            in  varchar2
  ,p_addr_attribute2_o            in  varchar2
  ,p_addr_attribute3_o            in  varchar2
  ,p_addr_attribute4_o            in  varchar2
  ,p_addr_attribute5_o            in  varchar2
  ,p_addr_attribute6_o            in  varchar2
  ,p_addr_attribute7_o            in  varchar2
  ,p_addr_attribute8_o            in  varchar2
  ,p_addr_attribute9_o            in  varchar2
  ,p_addr_attribute10_o           in  varchar2
  ,p_addr_attribute11_o           in  varchar2
  ,p_addr_attribute12_o           in  varchar2
  ,p_addr_attribute13_o           in  varchar2
  ,p_addr_attribute14_o           in  varchar2
  ,p_addr_attribute15_o           in  varchar2
  ,p_addr_attribute16_o           in  varchar2
  ,p_addr_attribute17_o           in  varchar2
  ,p_addr_attribute18_o           in  varchar2
  ,p_addr_attribute19_o           in  varchar2
  ,p_addr_attribute20_o           in  varchar2
  ,p_add_information13_o          in  varchar2
  ,p_add_information14_o          in  varchar2
  ,p_add_information15_o          in  varchar2
  ,p_add_information16_o          in  varchar2
  ,p_add_information17_o          in  varchar2
  ,p_add_information18_o          in  varchar2
  ,p_add_information19_o          in  varchar2
  ,p_add_information20_o          in  varchar2
  ,p_object_version_number_o      in  number
  );
--
end per_add_rkd;

/
