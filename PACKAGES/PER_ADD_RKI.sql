--------------------------------------------------------
--  DDL for Package PER_ADD_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ADD_RKI" AUTHID CURRENT_USER as
/* $Header: peaddrhi.pkh 120.0.12010000.1 2008/07/28 04:03:04 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_address_id                   in  number
  ,p_business_group_id            in  number
  ,p_person_id                    in  number
  ,p_date_from                    in  date
  ,p_primary_flag                 in  varchar2
  ,p_style                        in  varchar2
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
  ,p_validate_county              in  boolean
  ,p_party_id                     in  number
  );
end per_add_rki;

/
