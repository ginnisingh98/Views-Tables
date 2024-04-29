--------------------------------------------------------
--  DDL for Package PER_ADD_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_RKU" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_address_id                   in  number
  ,p_business_group_id            in  number
  ,p_person_id                    in  number
  ,p_date_from                    in  date
  ,p_address_line1                in  varchar2
  ,p_address_line2                in  varchar2
  ,p_address_line3                in  varchar2
  ,p_address_type                 in  varchar2
  ,p_comments                     in  long
  ,p_country                      in  varchar2
  ,p_date_to                      in  date
  ,p_postal_code                  in  varchar2
  ,p_region_1                     in  varchar2
  ,p_region_2                     in  varchar2
  ,p_region_3                     in  varchar2
  ,p_telephone_number_1           in  varchar2
  ,p_telephone_number_2           in  varchar2
  ,p_telephone_number_3           in  varchar2
  ,p_town_or_city                 in  varchar2
  ,p_request_id                   in  number
  ,p_program_application_id       in  number
  ,p_program_id                   in  number
  ,p_program_update_date          in  date
  ,p_addr_attribute_category      in  varchar2
  ,p_addr_attribute1              in  varchar2
  ,p_addr_attribute2              in  varchar2
  ,p_addr_attribute3              in  varchar2
  ,p_addr_attribute4              in  varchar2
  ,p_addr_attribute5              in  varchar2
  ,p_addr_attribute6              in  varchar2
  ,p_addr_attribute7              in  varchar2
  ,p_addr_attribute8              in  varchar2
  ,p_addr_attribute9              in  varchar2
  ,p_addr_attribute10             in  varchar2
  ,p_addr_attribute11             in  varchar2
  ,p_addr_attribute12             in  varchar2
  ,p_addr_attribute13             in  varchar2
  ,p_addr_attribute14             in  varchar2
  ,p_addr_attribute15             in  varchar2
  ,p_addr_attribute16             in  varchar2
  ,p_addr_attribute17             in  varchar2
  ,p_addr_attribute18             in  varchar2
  ,p_addr_attribute19             in  varchar2
  ,p_addr_attribute20             in  varchar2
  ,p_add_information13            in  varchar2
  ,p_add_information14            in  varchar2
  ,p_add_information15            in  varchar2
  ,p_add_information16            in  varchar2
  ,p_add_information17            in  varchar2
  ,p_add_information18            in  varchar2
  ,p_add_information19            in  varchar2
  ,p_add_information20            in  varchar2
  ,p_object_version_number        in  number
  ,p_effective_date               in  date
  ,p_prflagval_override           in  boolean
  ,p_validate_county              in  boolean
  ,p_business_group_id_o          in  number
  ,p_person_id_o                  in  number
  ,p_date_from_o                  in  date
  ,p_primary_flag_o               in  varchar2
  ,p_style_o                      in  varchar2
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
  ,p_party_id_o                   in  number
  );
end per_add_rku;

/
