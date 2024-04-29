--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EIT_MIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EIT_MIG" AUTHID CURRENT_USER as
/* $Header: pyeeimpi.pkh 120.0 2005/12/16 15:04:38 ndorai noship $ */
/*
 * This package contains element extra information APIs.
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_element_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
/*
 * This API creates extra information for a given element.
*/
--
procedure create_element_extra_info
  (p_validate                     in     boolean  default false
  ,p_element_type_id              in     number
  ,p_information_type             in     varchar2
  ,p_eei_attribute_category       in     varchar2 default null
  ,p_eei_attribute1               in     varchar2 default null
  ,p_eei_attribute2               in     varchar2 default null
  ,p_eei_attribute3               in     varchar2 default null
  ,p_eei_attribute4               in     varchar2 default null
  ,p_eei_attribute5               in     varchar2 default null
  ,p_eei_attribute6               in     varchar2 default null
  ,p_eei_attribute7               in     varchar2 default null
  ,p_eei_attribute8               in     varchar2 default null
  ,p_eei_attribute9               in     varchar2 default null
  ,p_eei_attribute10              in     varchar2 default null
  ,p_eei_attribute11              in     varchar2 default null
  ,p_eei_attribute12              in     varchar2 default null
  ,p_eei_attribute13              in     varchar2 default null
  ,p_eei_attribute14              in     varchar2 default null
  ,p_eei_attribute15              in     varchar2 default null
  ,p_eei_attribute16              in     varchar2 default null
  ,p_eei_attribute17              in     varchar2 default null
  ,p_eei_attribute18              in     varchar2 default null
  ,p_eei_attribute19              in     varchar2 default null
  ,p_eei_attribute20              in     varchar2 default null
  ,p_eei_information_category     in     varchar2 default null
  ,p_eei_information1             in     varchar2 default null
  ,p_eei_information2             in     varchar2 default null
  ,p_eei_information3             in     varchar2 default null
  ,p_eei_information4             in     varchar2 default null
  ,p_eei_information5             in     varchar2 default null
  ,p_eei_information6             in     varchar2 default null
  ,p_eei_information7             in     varchar2 default null
  ,p_eei_information8             in     varchar2 default null
  ,p_eei_information9             in     varchar2 default null
  ,p_eei_information10            in     varchar2 default null
  ,p_eei_information11            in     varchar2 default null
  ,p_eei_information12            in     varchar2 default null
  ,p_eei_information13            in     varchar2 default null
  ,p_eei_information14            in     varchar2 default null
  ,p_eei_information15            in     varchar2 default null
  ,p_eei_information16            in     varchar2 default null
  ,p_eei_information17            in     varchar2 default null
  ,p_eei_information18            in     varchar2 default null
  ,p_eei_information19            in     varchar2 default null
  ,p_eei_information20            in     varchar2 default null
  ,p_eei_information21            in     varchar2 default null
  ,p_eei_information22            in     varchar2 default null
  ,p_eei_information23            in     varchar2 default null
  ,p_eei_information24            in     varchar2 default null
  ,p_eei_information25            in     varchar2 default null
  ,p_eei_information26            in     varchar2 default null
  ,p_eei_information27            in     varchar2 default null
  ,p_eei_information28            in     varchar2 default null
  ,p_eei_information29            in     varchar2 default null
  ,p_eei_information30            in     varchar2 default null
  ,p_element_type_extra_info_id      out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_element_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
--
/*
 * This API updates extra information for a given element.
*/
--
--
procedure update_element_extra_info
  (p_validate                     in     boolean  default false
  ,p_element_type_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_eei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_eei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_eei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_element_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
/*
 * This API deletes extra information for a given element.
*/
--
--
procedure delete_element_extra_info
  (p_validate                      in     boolean  default false
  ,p_element_type_extra_info_id    in     number
  ,p_object_version_number         in     number
  );
--
end pay_element_eit_mig;

 

/
