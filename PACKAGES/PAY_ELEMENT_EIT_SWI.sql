--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EIT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EIT_SWI" AUTHID CURRENT_USER As
/* $Header: pyeeimwi.pkh 120.2 2005/12/16 16:46 ndorai noship $ */
  /*Global Variable */
  g_migration boolean:= TRUE;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_extra_info_api.create_element_extra_info
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
PROCEDURE create_element_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_element_type_id              in     number
  ,p_information_type             in     varchar2
  ,p_eei_attribute_category       in     varchar2  default null
  ,p_eei_attribute1               in     varchar2  default null
  ,p_eei_attribute2               in     varchar2  default null
  ,p_eei_attribute3               in     varchar2  default null
  ,p_eei_attribute4               in     varchar2  default null
  ,p_eei_attribute5               in     varchar2  default null
  ,p_eei_attribute6               in     varchar2  default null
  ,p_eei_attribute7               in     varchar2  default null
  ,p_eei_attribute8               in     varchar2  default null
  ,p_eei_attribute9               in     varchar2  default null
  ,p_eei_attribute10              in     varchar2  default null
  ,p_eei_attribute11              in     varchar2  default null
  ,p_eei_attribute12              in     varchar2  default null
  ,p_eei_attribute13              in     varchar2  default null
  ,p_eei_attribute14              in     varchar2  default null
  ,p_eei_attribute15              in     varchar2  default null
  ,p_eei_attribute16              in     varchar2  default null
  ,p_eei_attribute17              in     varchar2  default null
  ,p_eei_attribute18              in     varchar2  default null
  ,p_eei_attribute19              in     varchar2  default null
  ,p_eei_attribute20              in     varchar2  default null
  ,p_eei_information_category     in     varchar2  default null
  ,p_eei_information1             in     varchar2  default null
  ,p_eei_information2             in     varchar2  default null
  ,p_eei_information3             in     varchar2  default null
  ,p_eei_information4             in     varchar2  default null
  ,p_eei_information5             in     varchar2  default null
  ,p_eei_information6             in     varchar2  default null
  ,p_eei_information7             in     varchar2  default null
  ,p_eei_information8             in     varchar2  default null
  ,p_eei_information9             in     varchar2  default null
  ,p_eei_information10            in     varchar2  default null
  ,p_eei_information11            in     varchar2  default null
  ,p_eei_information12            in     varchar2  default null
  ,p_eei_information13            in     varchar2  default null
  ,p_eei_information14            in     varchar2  default null
  ,p_eei_information15            in     varchar2  default null
  ,p_eei_information16            in     varchar2  default null
  ,p_eei_information17            in     varchar2  default null
  ,p_eei_information18            in     varchar2  default null
  ,p_eei_information19            in     varchar2  default null
  ,p_eei_information20            in     varchar2  default null
  ,p_eei_information21            in     varchar2  default null
  ,p_eei_information22            in     varchar2  default null
  ,p_eei_information23            in     varchar2  default null
  ,p_eei_information24            in     varchar2  default null
  ,p_eei_information25            in     varchar2  default null
  ,p_eei_information26            in     varchar2  default null
  ,p_eei_information27            in     varchar2  default null
  ,p_eei_information28            in     varchar2  default null
  ,p_eei_information29            in     varchar2  default null
  ,p_eei_information30            in     varchar2  default null
  ,p_element_type_extra_info_id      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_extra_info_api.delete_element_extra_info
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
PROCEDURE delete_element_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_element_type_extra_info_id   in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_element_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: pay_element_extra_info_api.update_element_extra_info
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
PROCEDURE update_element_extra_info
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_element_type_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_eei_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_eei_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_eei_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_eei_information1             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information2             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information3             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information4             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information5             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information6             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information7             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information8             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information9             in     varchar2  default hr_api.g_varchar2
  ,p_eei_information10            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information11            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information12            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information13            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information14            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information15            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information16            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information17            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information18            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information19            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information20            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information21            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information22            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information23            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information24            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information25            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information26            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information27            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information28            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information29            in     varchar2  default hr_api.g_varchar2
  ,p_eei_information30            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  );
 end pay_element_eit_swi;

 

/
