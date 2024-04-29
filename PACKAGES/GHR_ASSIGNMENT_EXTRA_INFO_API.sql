--------------------------------------------------------
--  DDL for Package GHR_ASSIGNMENT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_ASSIGNMENT_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: ghaeiapi.pkh 120.0.12010000.3 2009/05/26 11:49:15 utokachi noship $ */
--
-- Package Variables
--
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_assignment_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_assignment_extra_info
  (p_validate                      	in     boolean  default false
  ,p_assignment_id                  	in     number
  ,p_information_type              	in     varchar2
  ,p_effective_date                	in     date
  ,p_aei_attribute_category        in     varchar2 default null
  ,p_aei_attribute1                in     varchar2 default null
  ,p_aei_attribute2                in     varchar2 default null
  ,p_aei_attribute3                in     varchar2 default null
  ,p_aei_attribute4                in     varchar2 default null
  ,p_aei_attribute5                in     varchar2 default null
  ,p_aei_attribute6                in     varchar2 default null
  ,p_aei_attribute7                in     varchar2 default null
  ,p_aei_attribute8                in     varchar2 default null
  ,p_aei_attribute9                in     varchar2 default null
  ,p_aei_attribute10               in     varchar2 default null
  ,p_aei_attribute11               in     varchar2 default null
  ,p_aei_attribute12               in     varchar2 default null
  ,p_aei_attribute13               in     varchar2 default null
  ,p_aei_attribute14               in     varchar2 default null
  ,p_aei_attribute15               in     varchar2 default null
  ,p_aei_attribute16               in     varchar2 default null
  ,p_aei_attribute17               in     varchar2 default null
  ,p_aei_attribute18               in     varchar2 default null
  ,p_aei_attribute19               in     varchar2 default null
  ,p_aei_attribute20               in     varchar2 default null
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  ,p_aei_information23             in     varchar2 default null
  ,p_aei_information24             in     varchar2 default null
  ,p_aei_information25             in     varchar2 default null
  ,p_aei_information26             in     varchar2 default null
  ,p_aei_information27             in     varchar2 default null
  ,p_aei_information28             in     varchar2 default null
  ,p_aei_information29             in     varchar2 default null
  ,p_aei_information30             in     varchar2 default null
  ,p_assignment_extra_info_id         out NOCOPY number
  ,p_object_version_number          out NOCOPY number
  ) ;

 -- ----------------------------------------------------------------------------
-- |---------------------< update_assignment_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_assignment_extra_info
  (p_validate                       in     boolean  default false
  ,p_assignment_extra_info_id         in     number
  ,p_object_version_number          in out NOCOPY number
  ,p_effective_date                 in     date
  ,p_aei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_aei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_aei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information30             in     varchar2 default hr_api.g_varchar2
  );
end ghr_assignment_extra_info_api;

/
