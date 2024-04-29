--------------------------------------------------------
--  DDL for Package BEN_PL_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PL_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: bepliapi.pkh 120.0.12010000.1 2008/07/29 12:50:37 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pl_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates extra information for a given pl
--
-- Prerequisites:
--   pl must exits
--   pl Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is created
--   p_pl_id                  Yes  number   pl for which the extra
--                                                info applies
--   p_information_type             Yes  varchar2 Information type the extra
--                                                info applies to
--   p_pli_attribute_category           varchar2 Determines context of the
--                                                pl_attribute descriptive
--                                                flexfield in parameters
--   p_pli_attribute1                   varchar2 Descriptive flexfield
--   p_pli_attribute2                   varchar2 Descriptive flexfield
--   p_pli_attribute3                   varchar2 Descriptive flexfield
--   p_pli_attribute4                   varchar2 Descriptive flexfield
--   p_pli_attribute5                   varchar2 Descriptive flexfield
--   p_pli_attribute6                   varchar2 Descriptive flexfield
--   p_pli_attribute7                   varchar2 Descriptive flexfield
--   p_pli_attribute8                   varchar2 Descriptive flexfield
--   p_pli_attribute9                   varchar2 Descriptive flexfield
--   p_pli_attribute10                  varchar2 Descriptive flexfield
--   p_pli_attribute11                  varchar2 Descriptive flexfield
--   p_pli_attribute12                  varchar2 Descriptive flexfield
--   p_pli_attribute13                  varchar2 Descriptive flexfield
--   p_pli_attribute14                  varchar2 Descriptive flexfield
--   p_pli_attribute15                  varchar2 Descriptive flexfield
--   p_pli_attribute16                  varchar2 Descriptive flexfield
--   p_pli_attribute17                  varchar2 Descriptive flexfield
--   p_pli_attribute18                  varchar2 Descriptive flexfield
--   p_pli_attribute19                  varchar2 Descriptive flexfield
--   p_pli_attribute20                  varchar2 Descriptive flexfield
--   p_pli_information_category         varchar2 Determines context of the
--                                                pl_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_pli_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_pli_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The pl extra info is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_pl_extra_info_id       number   If p_validate is false, uniquely
--                                           identifies the pl extra info
--                                           created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           pl extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the pl extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pl_extra_info
  (p_validate                     in     boolean  default false
  ,p_pl_id                       in     number
  ,p_information_type             in     varchar2
  ,p_pli_attribute_category       in     varchar2 default null
  ,p_pli_attribute1               in     varchar2 default null
  ,p_pli_attribute2               in     varchar2 default null
  ,p_pli_attribute3               in     varchar2 default null
  ,p_pli_attribute4               in     varchar2 default null
  ,p_pli_attribute5               in     varchar2 default null
  ,p_pli_attribute6               in     varchar2 default null
  ,p_pli_attribute7               in     varchar2 default null
  ,p_pli_attribute8               in     varchar2 default null
  ,p_pli_attribute9               in     varchar2 default null
  ,p_pli_attribute10              in     varchar2 default null
  ,p_pli_attribute11              in     varchar2 default null
  ,p_pli_attribute12              in     varchar2 default null
  ,p_pli_attribute13              in     varchar2 default null
  ,p_pli_attribute14              in     varchar2 default null
  ,p_pli_attribute15              in     varchar2 default null
  ,p_pli_attribute16              in     varchar2 default null
  ,p_pli_attribute17              in     varchar2 default null
  ,p_pli_attribute18              in     varchar2 default null
  ,p_pli_attribute19              in     varchar2 default null
  ,p_pli_attribute20              in     varchar2 default null
  ,p_pli_information_category     in     varchar2 default null
  ,p_pli_information1             in     varchar2 default null
  ,p_pli_information2             in     varchar2 default null
  ,p_pli_information3             in     varchar2 default null
  ,p_pli_information4             in     varchar2 default null
  ,p_pli_information5             in     varchar2 default null
  ,p_pli_information6             in     varchar2 default null
  ,p_pli_information7             in     varchar2 default null
  ,p_pli_information8             in     varchar2 default null
  ,p_pli_information9             in     varchar2 default null
  ,p_pli_information10            in     varchar2 default null
  ,p_pli_information11            in     varchar2 default null
  ,p_pli_information12            in     varchar2 default null
  ,p_pli_information13            in     varchar2 default null
  ,p_pli_information14            in     varchar2 default null
  ,p_pli_information15            in     varchar2 default null
  ,p_pli_information16            in     varchar2 default null
  ,p_pli_information17            in     varchar2 default null
  ,p_pli_information18            in     varchar2 default null
  ,p_pli_information19            in     varchar2 default null
  ,p_pli_information20            in     varchar2 default null
  ,p_pli_information21            in     varchar2 default null
  ,p_pli_information22            in     varchar2 default null
  ,p_pli_information23            in     varchar2 default null
  ,p_pli_information24            in     varchar2 default null
  ,p_pli_information25            in     varchar2 default null
  ,p_pli_information26            in     varchar2 default null
  ,p_pli_information27            in     varchar2 default null
  ,p_pli_information28            in     varchar2 default null
  ,p_pli_information29            in     varchar2 default null
  ,p_pli_information30            in     varchar2 default null
  ,p_pl_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pl_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates extra information for a given pl as identified by the
--   in parameter p_pl_extra_info_id and the in out parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The pl extra info as identified by the in parameter
--   p_pl_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is updated
--   p_pl_extra_info_id       yes  number   Primary key of the pl
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                pl extra info to be
--                                                updated
--   p_pli_attribute_category           varchar2 Determines context of the
--                                                pl_attribute descriptive
--                                                flexfield in parameters
--   p_pli_attribute1                   varchar2 Descriptive flexfield
--   p_pli_attribute2                   varchar2 Descriptive flexfield
--   p_pli_attribute3                   varchar2 Descriptive flexfield
--   p_pli_attribute4                   varchar2 Descriptive flexfield
--   p_pli_attribute5                   varchar2 Descriptive flexfield
--   p_pli_attribute6                   varchar2 Descriptive flexfield
--   p_pli_attribute7                   varchar2 Descriptive flexfield
--   p_pli_attribute8                   varchar2 Descriptive flexfield
--   p_pli_attribute9                   varchar2 Descriptive flexfield
--   p_pli_attribute10                  varchar2 Descriptive flexfield
--   p_pli_attribute11                  varchar2 Descriptive flexfield
--   p_pli_attribute12                  varchar2 Descriptive flexfield
--   p_pli_attribute13                  varchar2 Descriptive flexfield
--   p_pli_attribute14                  varchar2 Descriptive flexfield
--   p_pli_attribute15                  varchar2 Descriptive flexfield
--   p_pli_attribute16                  varchar2 Descriptive flexfield
--   p_pli_attribute17                  varchar2 Descriptive flexfield
--   p_pli_attribute18                  varchar2 Descriptive flexfield
--   p_pli_attribute19                  varchar2 Descriptive flexfield
--   p_pli_attribute20                  varchar2 Descriptive flexfield
--   p_pli_information_category         varchar2 Determines context of the
--                                                pl_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_pli_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_pli_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_pli_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The pl extra info is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           pl extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not update the pl extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_pl_extra_info
  (p_validate                     in     boolean  default false
  ,p_pl_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_pli_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_pli_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_pli_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_pli_information1             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information2             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information3             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information4             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information5             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information6             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information7             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information8             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information9             in     varchar2 default hr_api.g_varchar2
  ,p_pli_information10            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information11            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information12            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information13            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information14            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information15            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information16            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information17            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information18            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information19            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information20            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information21            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information22            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information23            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information24            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information25            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information26            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information27            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information28            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information29            in     varchar2 default hr_api.g_varchar2
  ,p_pli_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pl_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes extra information for a given pl as identified by the
--   in parameter p_pl_extra_info_id and the in parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The pl extra info as identified by the in parameter
--   p_pl_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is deleted
--   p_pl_extra_info_id       yes  number   Primary key of the pl
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                pl extra info to be
--                                                deleted
--
-- Post Success:
--   The pl extra info is deleted
--
-- Post Failure:
--   The API does not delete the pl extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_pl_extra_info
  (p_validate                      	in     boolean  default false
  ,p_pl_extra_info_id        	in     number
  ,p_object_version_number         	in     number
  );
--
end ben_pl_extra_info_api;

/
