--------------------------------------------------------
--  DDL for Package PQH_ACCOMMODATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ACCOMMODATIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqaccapi.pkh 120.1 2005/10/02 02:25:22 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<update_accommodation_b>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_accommodation_b
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_accommodation_id             in     number
  ,p_object_version_number        in     number
  ,p_accommodation_name           in     varchar2
  ,p_business_group_id            in     number
  ,p_location_id                  in     number
  ,p_accommodation_desc           in     varchar2
  ,p_accommodation_type           in     varchar2
  ,p_style                        in     varchar2
  ,p_address_line_1               in     varchar2
  ,p_address_line_2               in     varchar2
  ,p_address_line_3               in     varchar2
  ,p_town_or_city                 in     varchar2
  ,p_country                      in     varchar2
  ,p_postal_code                  in     varchar2
  ,p_region_1                     in     varchar2
  ,p_region_2                     in     varchar2
  ,p_region_3                     in     varchar2
  ,p_telephone_number_1           in     varchar2
  ,p_telephone_number_2           in     varchar2
  ,p_telephone_number_3           in     varchar2
  ,p_floor_number                 in     varchar2
  ,p_floor_area                   in     number
  ,p_floor_area_measure_unit      in     varchar2
  ,p_main_rooms                   in     number
  ,p_family_size                  in     number
  ,p_suitability_disabled         in     varchar2
  ,p_rental_value                 in     number
  ,p_rental_value_currency        in     varchar2
  ,p_owner                        in     varchar2
  ,p_comments                     in     varchar2
  ,p_information_category         in     varchar2
  ,p_information1                 in     varchar2
  ,p_information2                 in     varchar2
  ,p_information3                 in     varchar2
  ,p_information4                 in     varchar2
  ,p_information5                 in     varchar2
  ,p_information6                 in     varchar2
  ,p_information7                 in     varchar2
  ,p_information8                 in     varchar2
  ,p_information9                 in     varchar2
  ,p_information10                in     varchar2
  ,p_information11                in     varchar2
  ,p_information12                in     varchar2
  ,p_information13                in     varchar2
  ,p_information14                in     varchar2
  ,p_information15                in     varchar2
  ,p_information16                in     varchar2
  ,p_information17                in     varchar2
  ,p_information18                in     varchar2
  ,p_information19                in     varchar2
  ,p_information20                in     varchar2
  ,p_information21                in     varchar2
  ,p_information22                in     varchar2
  ,p_information23                in     varchar2
  ,p_information24                in     varchar2
  ,p_information25                in     varchar2
  ,p_information26                in     varchar2
  ,p_information27                in     varchar2
  ,p_information28                in     varchar2
  ,p_information29                in     varchar2
  ,p_information30                in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------<update_accommodation_a>-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_accommodation_a
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_accommodation_id             in     number
  ,p_object_version_number        in     number
  ,p_accommodation_name           in     varchar2
  ,p_business_group_id            in     number
  ,p_location_id                  in     number
  ,p_accommodation_desc           in     varchar2
  ,p_accommodation_type           in     varchar2
  ,p_style                        in     varchar2
  ,p_address_line_1               in     varchar2
  ,p_address_line_2               in     varchar2
  ,p_address_line_3               in     varchar2
  ,p_town_or_city                 in     varchar2
  ,p_country                      in     varchar2
  ,p_postal_code                  in     varchar2
  ,p_region_1                     in     varchar2
  ,p_region_2                     in     varchar2
  ,p_region_3                     in     varchar2
  ,p_telephone_number_1           in     varchar2
  ,p_telephone_number_2           in     varchar2
  ,p_telephone_number_3           in     varchar2
  ,p_floor_number                 in     varchar2
  ,p_floor_area                   in     number
  ,p_floor_area_measure_unit      in     varchar2
  ,p_main_rooms                   in     number
  ,p_family_size                  in     number
  ,p_suitability_disabled         in     varchar2
  ,p_rental_value                 in     number
  ,p_rental_value_currency        in     varchar2
  ,p_owner                        in     varchar2
  ,p_comments                     in     varchar2
  ,p_information_category         in     varchar2
  ,p_information1                 in     varchar2
  ,p_information2                 in     varchar2
  ,p_information3                 in     varchar2
  ,p_information4                 in     varchar2
  ,p_information5                 in     varchar2
  ,p_information6                 in     varchar2
  ,p_information7                 in     varchar2
  ,p_information8                 in     varchar2
  ,p_information9                 in     varchar2
  ,p_information10                in     varchar2
  ,p_information11                in     varchar2
  ,p_information12                in     varchar2
  ,p_information13                in     varchar2
  ,p_information14                in     varchar2
  ,p_information15                in     varchar2
  ,p_information16                in     varchar2
  ,p_information17                in     varchar2
  ,p_information18                in     varchar2
  ,p_information19                in     varchar2
  ,p_information20                in     varchar2
  ,p_information21                in     varchar2
  ,p_information22                in     varchar2
  ,p_information23                in     varchar2
  ,p_information24                in     varchar2
  ,p_information25                in     varchar2
  ,p_information26                in     varchar2
  ,p_information27                in     varchar2
  ,p_information28                in     varchar2
  ,p_information29                in     varchar2
  ,p_information30                in     varchar2
  ,p_attribute_category           in     varchar2
  ,p_attribute1                   in     varchar2
  ,p_attribute2                   in     varchar2
  ,p_attribute3                   in     varchar2
  ,p_attribute4                   in     varchar2
  ,p_attribute5                   in     varchar2
  ,p_attribute6                   in     varchar2
  ,p_attribute7                   in     varchar2
  ,p_attribute8                   in     varchar2
  ,p_attribute9                   in     varchar2
  ,p_attribute10                  in     varchar2
  ,p_attribute11                  in     varchar2
  ,p_attribute12                  in     varchar2
  ,p_attribute13                  in     varchar2
  ,p_attribute14                  in     varchar2
  ,p_attribute15                  in     varchar2
  ,p_attribute16                  in     varchar2
  ,p_attribute17                  in     varchar2
  ,p_attribute18                  in     varchar2
  ,p_attribute19                  in     varchar2
  ,p_attribute20                  in     varchar2
  ,p_attribute21                  in     varchar2
  ,p_attribute22                  in     varchar2
  ,p_attribute23                  in     varchar2
  ,p_attribute24                  in     varchar2
  ,p_attribute25                  in     varchar2
  ,p_attribute26                  in     varchar2
  ,p_attribute27                  in     varchar2
  ,p_attribute28                  in     varchar2
  ,p_attribute29                  in     varchar2
  ,p_attribute30                  in     varchar2
  ,p_effective_start_date         in     date
  ,p_effective_end_date           in     date
  );
--
end pqh_accommodations_bk2;

 

/
