--------------------------------------------------------
--  DDL for Package Body PER_PERSON_ADDRESS_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERSON_ADDRESS_EVENT" as
/* $Header: peaddbev.pkb 120.0.12010000.1 2008/08/28 10:46:28 srgnanas noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_PERSON_ADDRESS_EVENT.';
--
-- --------------------------------------------------------------------------------------------------
-- |--------------------------< RAISE_CREATE_BUSINESS_EVENT >----------------------------------------|
-- --------------------------------------------------------------------------------------------------

procedure RAISE_CREATE_BUSINESS_EVENT
  (
	p_effective_date               date,
	p_pradd_ovlapval_override      boolean,
	p_validate_county              boolean,
	p_person_id                    number,
	p_primary_flag                 varchar2,
	p_style                        varchar2,
	p_date_from                    date,
	p_date_to                      date,
	p_address_type                 varchar2,
	p_comments                     long,
	p_address_line1                varchar2,
	p_address_line2                varchar2,
	p_address_line3                varchar2,
	p_town_or_city                 varchar2,
	p_region_1                     varchar2,
	p_region_2                     varchar2,
	p_region_3                     varchar2,
	p_postal_code                  varchar2,
	p_country                      varchar2,
	p_telephone_number_1           varchar2,
	p_telephone_number_2           varchar2,
	p_telephone_number_3           varchar2,
	p_addr_attribute_category      varchar2,
	p_addr_attribute1              varchar2,
	p_addr_attribute2              varchar2,
	p_addr_attribute3              varchar2,
	p_addr_attribute4              varchar2,
	p_addr_attribute5              varchar2,
	p_addr_attribute6              varchar2,
	p_addr_attribute7              varchar2,
	p_addr_attribute8              varchar2,
	p_addr_attribute9              varchar2,
	p_addr_attribute10             varchar2,
	p_addr_attribute11             varchar2,
	p_addr_attribute12             varchar2,
	p_addr_attribute13             varchar2,
	p_addr_attribute14             varchar2,
	p_addr_attribute15             varchar2,
	p_addr_attribute16             varchar2,
	p_addr_attribute17             varchar2,
	p_addr_attribute18             varchar2,
	p_addr_attribute19             varchar2,
	p_addr_attribute20             varchar2,
	p_add_information13            varchar2,
	p_add_information14            varchar2,
	p_add_information15            varchar2,
	p_add_information16            varchar2,
	p_add_information17            varchar2,
	p_add_information18            varchar2,
	p_add_information19            varchar2,
	p_add_information20            varchar2,
	p_address_id                   number,
	p_object_version_number        number,
	p_party_id                     number
  )
is
begin
  HR_PERSON_ADDRESS_BE1.create_person_address_a(
  	p_effective_date => p_effective_date
	,p_pradd_ovlapval_override => p_pradd_ovlapval_override
  	,p_validate_county  =>	p_validate_county
  	,p_person_id => p_person_id
  	,p_primary_flag => p_primary_flag
  	,p_style => p_style
  	,p_date_from => p_date_from
  	,p_date_to => p_date_to
  	,p_address_type => p_address_type
  	,p_comments => p_comments
  	,p_address_line1 => p_address_line1
  	,p_address_line2 => p_address_line2
  	,p_address_line3 => p_address_line3
  	,p_town_or_city => p_town_or_city
  	,p_region_1 => p_region_1
  	,p_region_2 => p_region_2
  	,p_region_3 => p_region_3
  	,p_postal_code => p_postal_code
  	,p_country => p_country
  	,p_telephone_number_1 => p_telephone_number_1
  	,p_telephone_number_2 => p_telephone_number_2
  	,p_telephone_number_3 => p_telephone_number_3
  	,p_addr_attribute_category => p_addr_attribute_category
  	,p_addr_attribute1 => p_addr_attribute1
  	,p_addr_attribute2 => p_addr_attribute2
  	,p_addr_attribute3 => p_addr_attribute3
  	,p_addr_attribute4 => p_addr_attribute4
  	,p_addr_attribute5 => p_addr_attribute5
  	,p_addr_attribute6 => p_addr_attribute6
  	,p_addr_attribute7 => p_addr_attribute7
  	,p_addr_attribute8 => p_addr_attribute8
  	,p_addr_attribute9 => p_addr_attribute9
  	,p_addr_attribute10 => p_addr_attribute10
  	,p_addr_attribute11 => p_addr_attribute11
  	,p_addr_attribute12 => p_addr_attribute12
  	,p_addr_attribute13 => p_addr_attribute13
  	,p_addr_attribute14 => p_addr_attribute14
  	,p_addr_attribute15 => p_addr_attribute15
  	,p_addr_attribute16 => p_addr_attribute16
  	,p_addr_attribute17 => p_addr_attribute17
  	,p_addr_attribute18 => p_addr_attribute18
  	,p_addr_attribute19 => p_addr_attribute19
  	,p_addr_attribute20 => p_addr_attribute20
  	,p_add_information13 => p_add_information13
  	,p_add_information14 => p_add_information14
  	,p_add_information15 => p_add_information15
  	,p_add_information16 => p_add_information16
  	,p_add_information17 => p_add_information17
  	,p_add_information18 => p_add_information18
  	,p_add_information19 => p_add_information19
  	,p_add_information20 => p_add_information20
  	,p_address_id => p_address_id
	,p_object_version_number => p_object_version_number
  	,p_party_id => p_party_id
);
end RAISE_CREATE_BUSINESS_EVENT;

-- --------------------------------------------------------------------------------------------------
-- |--------------------------< RAISE_UPDATE_BUSINESS_EVENT >---------------------------------------|
-- --------------------------------------------------------------------------------------------------

procedure RAISE_UPDATE_BUSINESS_EVENT
  (p_effective_date               date,
	p_validate_county              boolean,
	p_address_id                   number,
	p_object_version_number        number,
	p_date_from                    date,
	p_date_to                      date,
	p_address_type                 varchar2,
	p_comments                     long,
	p_address_line1                varchar2,
	p_address_line2                varchar2,
	p_address_line3                varchar2,
	p_town_or_city                 varchar2,
	p_region_1                     varchar2,
	p_region_2                     varchar2,
	p_region_3                     varchar2,
	p_postal_code                  varchar2,
	p_country                      varchar2,
	p_telephone_number_1           varchar2,
	p_telephone_number_2           varchar2,
	p_telephone_number_3           varchar2,
	p_addr_attribute_category      varchar2,
	p_addr_attribute1              varchar2,
	p_addr_attribute2              varchar2,
	p_addr_attribute3              varchar2,
	p_addr_attribute4              varchar2,
	p_addr_attribute5              varchar2,
	p_addr_attribute6              varchar2,
	p_addr_attribute7              varchar2,
	p_addr_attribute8              varchar2,
	p_addr_attribute9              varchar2,
	p_addr_attribute10             varchar2,
	p_addr_attribute11             varchar2,
	p_addr_attribute12             varchar2,
	p_addr_attribute13             varchar2,
	p_addr_attribute14             varchar2,
	p_addr_attribute15             varchar2,
	p_addr_attribute16             varchar2,
	p_addr_attribute17             varchar2,
	p_addr_attribute18             varchar2,
	p_addr_attribute19             varchar2,
	p_addr_attribute20             varchar2,
	p_add_information13            varchar2,
	p_add_information14            varchar2,
	p_add_information15            varchar2,
	p_add_information16            varchar2,
	p_add_information17            varchar2,
	p_add_information18            varchar2,
	p_add_information19            varchar2,
	p_add_information20            varchar2
  )
is
begin
 HR_PERSON_ADDRESS_BE2.update_person_address_a(
	 p_effective_date => p_effective_date
	,p_validate_county  => p_validate_county
	,p_object_version_number => p_object_version_number
	,p_address_id => p_address_id
	,p_date_from => p_date_from
  	,p_date_to => p_date_to
	,p_address_type => p_address_type
  	,p_comments => p_comments
  	,p_address_line1 => p_address_line1
  	,p_address_line2 => p_address_line2
  	,p_address_line3 => p_address_line3
  	,p_town_or_city => p_town_or_city
  	,p_region_1 => p_region_1
  	,p_region_2 => p_region_2
  	,p_region_3 => p_region_3
  	,p_postal_code => p_postal_code
  	,p_country => p_country
  	,p_telephone_number_1 => p_telephone_number_1
  	,p_telephone_number_2 => p_telephone_number_2
  	,p_telephone_number_3 => p_telephone_number_3
  	,p_addr_attribute_category => p_addr_attribute_category
  	,p_addr_attribute1 => p_addr_attribute1
  	,p_addr_attribute2 => p_addr_attribute2
  	,p_addr_attribute3 => p_addr_attribute3
  	,p_addr_attribute4 => p_addr_attribute4
  	,p_addr_attribute5 => p_addr_attribute5
  	,p_addr_attribute6 => p_addr_attribute6
  	,p_addr_attribute7 => p_addr_attribute7
  	,p_addr_attribute8 => p_addr_attribute8
  	,p_addr_attribute9 => p_addr_attribute9
  	,p_addr_attribute10 => p_addr_attribute10
  	,p_addr_attribute11 => p_addr_attribute11
  	,p_addr_attribute12 => p_addr_attribute12
  	,p_addr_attribute13 => p_addr_attribute13
  	,p_addr_attribute14 => p_addr_attribute14
  	,p_addr_attribute15 => p_addr_attribute15
  	,p_addr_attribute16 => p_addr_attribute16
  	,p_addr_attribute17 => p_addr_attribute17
  	,p_addr_attribute18 => p_addr_attribute18
  	,p_addr_attribute19 => p_addr_attribute19
  	,p_addr_attribute20 => p_addr_attribute20
  	,p_add_information13 => p_add_information13
  	,p_add_information14 => p_add_information14
  	,p_add_information15 => p_add_information15
  	,p_add_information16 => p_add_information16
  	,p_add_information17 => p_add_information17
  	,p_add_information18 => p_add_information18
  	,p_add_information19 => p_add_information19
  	,p_add_information20 => p_add_information20
);
end RAISE_UPDATE_BUSINESS_EVENT;

end PER_PERSON_ADDRESS_EVENT;

/
