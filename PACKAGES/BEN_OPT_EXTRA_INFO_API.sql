--------------------------------------------------------
--  DDL for Package BEN_OPT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_OPT_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: beopiapi.pkh 120.0 2005/05/28 09:52:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_opt_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates extra information for a given opt
--
-- Prerequisites:
--   OPT must exits
--   OPT Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is created
--   p_opt_id                  Yes  number   opt for which the extra
--                                                info applies
--   p_information_type             Yes  varchar2 Information type the extra
--                                                info applies to
--   p_opi_attribute_category           varchar2 Determines context of the
--                                                opt_attribute descriptive
--                                                flexfield in parameters
--   p_opi_attribute1                   varchar2 Descriptive flexfield
--   p_opi_attribute2                   varchar2 Descriptive flexfield
--   p_opi_attribute3                   varchar2 Descriptive flexfield
--   p_opi_attribute4                   varchar2 Descriptive flexfield
--   p_opi_attribute5                   varchar2 Descriptive flexfield
--   p_opi_attribute6                   varchar2 Descriptive flexfield
--   p_opi_attribute7                   varchar2 Descriptive flexfield
--   p_opi_attribute8                   varchar2 Descriptive flexfield
--   p_opi_attribute9                   varchar2 Descriptive flexfield
--   p_opi_attribute10                  varchar2 Descriptive flexfield
--   p_opi_attribute11                  varchar2 Descriptive flexfield
--   p_opi_attribute12                  varchar2 Descriptive flexfield
--   p_opi_attribute13                  varchar2 Descriptive flexfield
--   p_opi_attribute14                  varchar2 Descriptive flexfield
--   p_opi_attribute15                  varchar2 Descriptive flexfield
--   p_opi_attribute16                  varchar2 Descriptive flexfield
--   p_opi_attribute17                  varchar2 Descriptive flexfield
--   p_opi_attribute18                  varchar2 Descriptive flexfield
--   p_opi_attribute19                  varchar2 Descriptive flexfield
--   p_opi_attribute20                  varchar2 Descriptive flexfield
--   p_opi_information_category         varchar2 Determines context of the
--                                                opt_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_opi_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_opi_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The OPT extra info is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_opt_extra_info_id       number   If p_validate is false, uniquely
--                                           identifies the opt extra info
--                                           created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           OPT extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the OPT extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_opt_extra_info
  (p_validate                     in     boolean  default false
  ,p_opt_id                       in     number
  ,p_information_type             in     varchar2
  ,p_opi_attribute_category       in     varchar2 default null
  ,p_opi_attribute1               in     varchar2 default null
  ,p_opi_attribute2               in     varchar2 default null
  ,p_opi_attribute3               in     varchar2 default null
  ,p_opi_attribute4               in     varchar2 default null
  ,p_opi_attribute5               in     varchar2 default null
  ,p_opi_attribute6               in     varchar2 default null
  ,p_opi_attribute7               in     varchar2 default null
  ,p_opi_attribute8               in     varchar2 default null
  ,p_opi_attribute9               in     varchar2 default null
  ,p_opi_attribute10              in     varchar2 default null
  ,p_opi_attribute11              in     varchar2 default null
  ,p_opi_attribute12              in     varchar2 default null
  ,p_opi_attribute13              in     varchar2 default null
  ,p_opi_attribute14              in     varchar2 default null
  ,p_opi_attribute15              in     varchar2 default null
  ,p_opi_attribute16              in     varchar2 default null
  ,p_opi_attribute17              in     varchar2 default null
  ,p_opi_attribute18              in     varchar2 default null
  ,p_opi_attribute19              in     varchar2 default null
  ,p_opi_attribute20              in     varchar2 default null
  ,p_opi_information_category     in     varchar2 default null
  ,p_opi_information1             in     varchar2 default null
  ,p_opi_information2             in     varchar2 default null
  ,p_opi_information3             in     varchar2 default null
  ,p_opi_information4             in     varchar2 default null
  ,p_opi_information5             in     varchar2 default null
  ,p_opi_information6             in     varchar2 default null
  ,p_opi_information7             in     varchar2 default null
  ,p_opi_information8             in     varchar2 default null
  ,p_opi_information9             in     varchar2 default null
  ,p_opi_information10            in     varchar2 default null
  ,p_opi_information11            in     varchar2 default null
  ,p_opi_information12            in     varchar2 default null
  ,p_opi_information13            in     varchar2 default null
  ,p_opi_information14            in     varchar2 default null
  ,p_opi_information15            in     varchar2 default null
  ,p_opi_information16            in     varchar2 default null
  ,p_opi_information17            in     varchar2 default null
  ,p_opi_information18            in     varchar2 default null
  ,p_opi_information19            in     varchar2 default null
  ,p_opi_information20            in     varchar2 default null
  ,p_opi_information21            in     varchar2 default null
  ,p_opi_information22            in     varchar2 default null
  ,p_opi_information23            in     varchar2 default null
  ,p_opi_information24            in     varchar2 default null
  ,p_opi_information25            in     varchar2 default null
  ,p_opi_information26            in     varchar2 default null
  ,p_opi_information27            in     varchar2 default null
  ,p_opi_information28            in     varchar2 default null
  ,p_opi_information29            in     varchar2 default null
  ,p_opi_information30            in     varchar2 default null
  ,p_opt_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_opt_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates extra information for a given opt as identified by the
--   in parameter p_opt_extra_info_id and the in out parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The OPT extra info as identified by the in parameter
--   p_opt_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is updated
--   p_opt_extra_info_id       yes  number   Primary key of the LER
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                OPT extra info to be
--                                                updated
--   p_opi_attribute_category           varchar2 Determines context of the
--                                                opt_attribute descriptive
--                                                flexfield in parameters
--   p_opi_attribute1                   varchar2 Descriptive flexfield
--   p_opi_attribute2                   varchar2 Descriptive flexfield
--   p_opi_attribute3                   varchar2 Descriptive flexfield
--   p_opi_attribute4                   varchar2 Descriptive flexfield
--   p_opi_attribute5                   varchar2 Descriptive flexfield
--   p_opi_attribute6                   varchar2 Descriptive flexfield
--   p_opi_attribute7                   varchar2 Descriptive flexfield
--   p_opi_attribute8                   varchar2 Descriptive flexfield
--   p_opi_attribute9                   varchar2 Descriptive flexfield
--   p_opi_attribute10                  varchar2 Descriptive flexfield
--   p_opi_attribute11                  varchar2 Descriptive flexfield
--   p_opi_attribute12                  varchar2 Descriptive flexfield
--   p_opi_attribute13                  varchar2 Descriptive flexfield
--   p_opi_attribute14                  varchar2 Descriptive flexfield
--   p_opi_attribute15                  varchar2 Descriptive flexfield
--   p_opi_attribute16                  varchar2 Descriptive flexfield
--   p_opi_attribute17                  varchar2 Descriptive flexfield
--   p_opi_attribute18                  varchar2 Descriptive flexfield
--   p_opi_attribute19                  varchar2 Descriptive flexfield
--   p_opi_attribute20                  varchar2 Descriptive flexfield
--   p_opi_information_category         varchar2 Determines context of the
--                                                opt_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_opi_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_opi_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_opi_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The OPT extra info is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           OPT extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not update the OPT extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_opt_extra_info
  (p_validate                     in     boolean  default false
  ,p_opt_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_opi_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_opi_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_opi_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_opi_information1             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information2             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information3             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information4             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information5             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information6             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information7             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information8             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information9             in     varchar2 default hr_api.g_varchar2
  ,p_opi_information10            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information11            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information12            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information13            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information14            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information15            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information16            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information17            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information18            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information19            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information20            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information21            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information22            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information23            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information24            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information25            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information26            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information27            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information28            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information29            in     varchar2 default hr_api.g_varchar2
  ,p_opi_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_opt_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes extra information for a given opt as identified by the
--   in parameter p_opt_extra_info_id and the in parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The OPT extra info as identified by the in parameter
--   p_opt_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is deleted
--   p_opt_extra_info_id       yes  number   Primary key of the LER
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                OPT extra info to be
--                                                deleted
--
-- Post Success:
--   The OPT extra info is deleted
--
-- Post Failure:
--   The API does not delete the OPT extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_opt_extra_info
  (p_validate                      	in     boolean  default false
  ,p_opt_extra_info_id        	in     number
  ,p_object_version_number         	in     number
  );
--
end ben_opt_extra_info_api;

 

/
