--------------------------------------------------------
--  DDL for Package HR_PERSON_ADDRESS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_ADDRESS_SWI" AUTHID CURRENT_USER As
/* $Header: hraddswi.pkh 120.0 2005/05/30 22:34:07 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_address >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_address_api.create_person_address
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE create_person_address
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_pradd_ovlapval_override      in     number    default null
  ,p_validate_county              in     number    default null
  ,p_person_id                    in     number    default null
  ,p_primary_flag                 in     varchar2
  ,p_style                        in     varchar2
  ,p_date_from                    in     date
  ,p_date_to                      in     date      default null
  ,p_address_type                 in     varchar2  default null
  ,p_comments                     in     long      default null
  ,p_address_line1                in     varchar2  default null
  ,p_address_line2                in     varchar2  default null
  ,p_address_line3                in     varchar2  default null
  ,p_town_or_city                 in     varchar2  default null
  ,p_region_1                     in     varchar2  default null
  ,p_region_2                     in     varchar2  default null
  ,p_region_3                     in     varchar2  default null
  ,p_postal_code                  in     varchar2  default null
  ,p_country                      in     varchar2  default null
  ,p_telephone_number_1           in     varchar2  default null
  ,p_telephone_number_2           in     varchar2  default null
  ,p_telephone_number_3           in     varchar2  default null
  ,p_addr_attribute_category      in     varchar2  default null
  ,p_addr_attribute1              in     varchar2  default null
  ,p_addr_attribute2              in     varchar2  default null
  ,p_addr_attribute3              in     varchar2  default null
  ,p_addr_attribute4              in     varchar2  default null
  ,p_addr_attribute5              in     varchar2  default null
  ,p_addr_attribute6              in     varchar2  default null
  ,p_addr_attribute7              in     varchar2  default null
  ,p_addr_attribute8              in     varchar2  default null
  ,p_addr_attribute9              in     varchar2  default null
  ,p_addr_attribute10             in     varchar2  default null
  ,p_addr_attribute11             in     varchar2  default null
  ,p_addr_attribute12             in     varchar2  default null
  ,p_addr_attribute13             in     varchar2  default null
  ,p_addr_attribute14             in     varchar2  default null
  ,p_addr_attribute15             in     varchar2  default null
  ,p_addr_attribute16             in     varchar2  default null
  ,p_addr_attribute17             in     varchar2  default null
  ,p_addr_attribute18             in     varchar2  default null
  ,p_addr_attribute19             in     varchar2  default null
  ,p_addr_attribute20             in     varchar2  default null
  ,p_add_information13            in     varchar2  default null
  ,p_add_information14            in     varchar2  default null
  ,p_add_information15            in     varchar2  default null
  ,p_add_information16            in     varchar2  default null
  ,p_add_information17            in     varchar2  default null
  ,p_add_information18            in     varchar2  default null
  ,p_add_information19            in     varchar2  default null
  ,p_add_information20            in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_address_id                   in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_address >------------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_person_address_api.update_person_address
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_person_address
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_validate_county              in     number    default hr_api.g_true_num
  ,p_address_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_address_type                 in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_address_line1                in     varchar2  default hr_api.g_varchar2
  ,p_address_line2                in     varchar2  default hr_api.g_varchar2
  ,p_address_line3                in     varchar2  default hr_api.g_varchar2
  ,p_town_or_city                 in     varchar2  default hr_api.g_varchar2
  ,p_region_1                     in     varchar2  default hr_api.g_varchar2
  ,p_region_2                     in     varchar2  default hr_api.g_varchar2
  ,p_region_3                     in     varchar2  default hr_api.g_varchar2
  ,p_postal_code                  in     varchar2  default hr_api.g_varchar2
  ,p_country                      in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_1           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_2           in     varchar2  default hr_api.g_varchar2
  ,p_telephone_number_3           in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute_category      in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute1              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute2              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute3              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute4              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute5              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute6              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute7              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute8              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute9              in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute10             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute11             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute12             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute13             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute14             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute15             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute16             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute17             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute18             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute19             in     varchar2  default hr_api.g_varchar2
  ,p_addr_attribute20             in     varchar2  default hr_api.g_varchar2
  ,p_add_information13            in     varchar2  default hr_api.g_varchar2
  ,p_add_information14            in     varchar2  default hr_api.g_varchar2
  ,p_add_information15            in     varchar2  default hr_api.g_varchar2
  ,p_add_information16            in     varchar2  default hr_api.g_varchar2
  ,p_add_information17            in     varchar2  default hr_api.g_varchar2
  ,p_add_information18            in     varchar2  default hr_api.g_varchar2
  ,p_add_information19            in     varchar2  default hr_api.g_varchar2
  ,p_add_information20            in     varchar2  default hr_api.g_varchar2
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_style                        in     varchar2
  ,p_return_status                   out nocopy varchar2
  );
end hr_person_address_swi;

 

/
