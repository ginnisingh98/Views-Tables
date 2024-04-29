--------------------------------------------------------
--  DDL for Package BEN_ELP_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELP_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: beeliapi.pkh 120.0 2005/05/28 02:18:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_elp_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates extra information for a given elp
--
-- Prerequisites:
--   elp must exits
--   elp Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is created
--   p_eligy_prfl_id                  Yes  number   elp for which the extra
--                                                info applies
--   p_information_type             Yes  varchar2 Information type the extra
--                                                info applies to
--   p_eli_attribute_category           varchar2 Determines context of the
--                                                elp_attribute descriptive
--                                                flexfield in parameters
--   p_eli_attribute1                   varchar2 Descriptive flexfield
--   p_eli_attribute2                   varchar2 Descriptive flexfield
--   p_eli_attribute3                   varchar2 Descriptive flexfield
--   p_eli_attribute4                   varchar2 Descriptive flexfield
--   p_eli_attribute5                   varchar2 Descriptive flexfield
--   p_eli_attribute6                   varchar2 Descriptive flexfield
--   p_eli_attribute7                   varchar2 Descriptive flexfield
--   p_eli_attribute8                   varchar2 Descriptive flexfield
--   p_eli_attribute9                   varchar2 Descriptive flexfield
--   p_eli_attribute10                  varchar2 Descriptive flexfield
--   p_eli_attribute11                  varchar2 Descriptive flexfield
--   p_eli_attribute12                  varchar2 Descriptive flexfield
--   p_eli_attribute13                  varchar2 Descriptive flexfield
--   p_eli_attribute14                  varchar2 Descriptive flexfield
--   p_eli_attribute15                  varchar2 Descriptive flexfield
--   p_eli_attribute16                  varchar2 Descriptive flexfield
--   p_eli_attribute17                  varchar2 Descriptive flexfield
--   p_eli_attribute18                  varchar2 Descriptive flexfield
--   p_eli_attribute19                  varchar2 Descriptive flexfield
--   p_eli_attribute20                  varchar2 Descriptive flexfield
--   p_eli_information_category         varchar2 Determines context of the
--                                                elp_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_eli_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_eli_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The elp extra info is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_elp_extra_info_id       number   If p_validate is false, uniquely
--                                           identifies the elp extra info
--                                           created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           elp extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the elp extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_elp_extra_info
  (p_validate                     in     boolean  default false
  ,p_eligy_prfl_id                       in     number
  ,p_information_type             in     varchar2
  ,p_eli_attribute_category       in     varchar2 default null
  ,p_eli_attribute1               in     varchar2 default null
  ,p_eli_attribute2               in     varchar2 default null
  ,p_eli_attribute3               in     varchar2 default null
  ,p_eli_attribute4               in     varchar2 default null
  ,p_eli_attribute5               in     varchar2 default null
  ,p_eli_attribute6               in     varchar2 default null
  ,p_eli_attribute7               in     varchar2 default null
  ,p_eli_attribute8               in     varchar2 default null
  ,p_eli_attribute9               in     varchar2 default null
  ,p_eli_attribute10              in     varchar2 default null
  ,p_eli_attribute11              in     varchar2 default null
  ,p_eli_attribute12              in     varchar2 default null
  ,p_eli_attribute13              in     varchar2 default null
  ,p_eli_attribute14              in     varchar2 default null
  ,p_eli_attribute15              in     varchar2 default null
  ,p_eli_attribute16              in     varchar2 default null
  ,p_eli_attribute17              in     varchar2 default null
  ,p_eli_attribute18              in     varchar2 default null
  ,p_eli_attribute19              in     varchar2 default null
  ,p_eli_attribute20              in     varchar2 default null
  ,p_eli_information_category     in     varchar2 default null
  ,p_eli_information1             in     varchar2 default null
  ,p_eli_information2             in     varchar2 default null
  ,p_eli_information3             in     varchar2 default null
  ,p_eli_information4             in     varchar2 default null
  ,p_eli_information5             in     varchar2 default null
  ,p_eli_information6             in     varchar2 default null
  ,p_eli_information7             in     varchar2 default null
  ,p_eli_information8             in     varchar2 default null
  ,p_eli_information9             in     varchar2 default null
  ,p_eli_information10            in     varchar2 default null
  ,p_eli_information11            in     varchar2 default null
  ,p_eli_information12            in     varchar2 default null
  ,p_eli_information13            in     varchar2 default null
  ,p_eli_information14            in     varchar2 default null
  ,p_eli_information15            in     varchar2 default null
  ,p_eli_information16            in     varchar2 default null
  ,p_eli_information17            in     varchar2 default null
  ,p_eli_information18            in     varchar2 default null
  ,p_eli_information19            in     varchar2 default null
  ,p_eli_information20            in     varchar2 default null
  ,p_eli_information21            in     varchar2 default null
  ,p_eli_information22            in     varchar2 default null
  ,p_eli_information23            in     varchar2 default null
  ,p_eli_information24            in     varchar2 default null
  ,p_eli_information25            in     varchar2 default null
  ,p_eli_information26            in     varchar2 default null
  ,p_eli_information27            in     varchar2 default null
  ,p_eli_information28            in     varchar2 default null
  ,p_eli_information29            in     varchar2 default null
  ,p_eli_information30            in     varchar2 default null
  ,p_elp_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_elp_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates extra information for a given elp as identified by the
--   in parameter p_elp_extra_info_id and the in out parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The elp extra info as identified by the in parameter
--   p_elp_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is updated
--   p_elp_extra_info_id       yes  number   Primary key of the elp
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                elp extra info to be
--                                                updated
--   p_eli_attribute_category           varchar2 Determines context of the
--                                                elp_attribute descriptive
--                                                flexfield in parameters
--   p_eli_attribute1                   varchar2 Descriptive flexfield
--   p_eli_attribute2                   varchar2 Descriptive flexfield
--   p_eli_attribute3                   varchar2 Descriptive flexfield
--   p_eli_attribute4                   varchar2 Descriptive flexfield
--   p_eli_attribute5                   varchar2 Descriptive flexfield
--   p_eli_attribute6                   varchar2 Descriptive flexfield
--   p_eli_attribute7                   varchar2 Descriptive flexfield
--   p_eli_attribute8                   varchar2 Descriptive flexfield
--   p_eli_attribute9                   varchar2 Descriptive flexfield
--   p_eli_attribute10                  varchar2 Descriptive flexfield
--   p_eli_attribute11                  varchar2 Descriptive flexfield
--   p_eli_attribute12                  varchar2 Descriptive flexfield
--   p_eli_attribute13                  varchar2 Descriptive flexfield
--   p_eli_attribute14                  varchar2 Descriptive flexfield
--   p_eli_attribute15                  varchar2 Descriptive flexfield
--   p_eli_attribute16                  varchar2 Descriptive flexfield
--   p_eli_attribute17                  varchar2 Descriptive flexfield
--   p_eli_attribute18                  varchar2 Descriptive flexfield
--   p_eli_attribute19                  varchar2 Descriptive flexfield
--   p_eli_attribute20                  varchar2 Descriptive flexfield
--   p_eli_information_category         varchar2 Determines context of the
--                                                elp_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_eli_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_eli_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_eli_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The elp extra info is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           elp extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not update the elp extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_elp_extra_info
  (p_validate                     in     boolean  default false
  ,p_elp_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_eli_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_eli_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_eli_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_eli_information1             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information2             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information3             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information4             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information5             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information6             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information7             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information8             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information9             in     varchar2 default hr_api.g_varchar2
  ,p_eli_information10            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information11            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information12            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information13            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information14            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information15            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information16            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information17            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information18            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information19            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information20            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information21            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information22            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information23            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information24            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information25            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information26            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information27            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information28            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information29            in     varchar2 default hr_api.g_varchar2
  ,p_eli_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_elp_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes extra information for a given elp as identified by the
--   in parameter p_elp_extra_info_id and the in parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The elp extra info as identified by the in parameter
--   p_elp_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is deleted
--   p_elp_extra_info_id       yes  number   Primary key of the elp
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                elp extra info to be
--                                                deleted
--
-- Post Success:
--   The elp extra info is deleted
--
-- Post Failure:
--   The API does not delete the elp extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_elp_extra_info
  (p_validate                      	in     boolean  default false
  ,p_elp_extra_info_id        	in     number
  ,p_object_version_number         	in     number
  );
--
end ben_elp_extra_info_api;

 

/
