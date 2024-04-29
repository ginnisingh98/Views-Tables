--------------------------------------------------------
--  DDL for Package BEN_PGM_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PGM_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: bepgiapi.pkh 120.0 2005/05/28 10:45:47 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_pgm_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates extra information for a given pgm
--
-- Prerequisites:
--   pgm must exits
--   pgm Information Type must already exist
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is created
--   p_pgm_id                  Yes  number   pgm for which the extra
--                                                info applies
--   p_information_type             Yes  varchar2 Information type the extra
--                                                info applies to
--   p_pgi_attribute_category           varchar2 Determines context of the
--                                                pgm_attribute descriptive
--                                                flexfield in parameters
--   p_pgi_attribute1                   varchar2 Descriptive flexfield
--   p_pgi_attribute2                   varchar2 Descriptive flexfield
--   p_pgi_attribute3                   varchar2 Descriptive flexfield
--   p_pgi_attribute4                   varchar2 Descriptive flexfield
--   p_pgi_attribute5                   varchar2 Descriptive flexfield
--   p_pgi_attribute6                   varchar2 Descriptive flexfield
--   p_pgi_attribute7                   varchar2 Descriptive flexfield
--   p_pgi_attribute8                   varchar2 Descriptive flexfield
--   p_pgi_attribute9                   varchar2 Descriptive flexfield
--   p_pgi_attribute10                  varchar2 Descriptive flexfield
--   p_pgi_attribute11                  varchar2 Descriptive flexfield
--   p_pgi_attribute12                  varchar2 Descriptive flexfield
--   p_pgi_attribute13                  varchar2 Descriptive flexfield
--   p_pgi_attribute14                  varchar2 Descriptive flexfield
--   p_pgi_attribute15                  varchar2 Descriptive flexfield
--   p_pgi_attribute16                  varchar2 Descriptive flexfield
--   p_pgi_attribute17                  varchar2 Descriptive flexfield
--   p_pgi_attribute18                  varchar2 Descriptive flexfield
--   p_pgi_attribute19                  varchar2 Descriptive flexfield
--   p_pgi_attribute20                  varchar2 Descriptive flexfield
--   p_pgi_information_category         varchar2 Determines context of the
--                                                pgm_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_pgi_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_pgi_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The pgm extra info is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_pgm_extra_info_id       number   If p_validate is false, uniquely
--                                           identifies the pgm extra info
--                                           created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           pgm extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the pgm extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_pgm_extra_info
  (p_validate                     in     boolean  default false
  ,p_pgm_id                       in     number
  ,p_information_type             in     varchar2
  ,p_pgi_attribute_category       in     varchar2 default null
  ,p_pgi_attribute1               in     varchar2 default null
  ,p_pgi_attribute2               in     varchar2 default null
  ,p_pgi_attribute3               in     varchar2 default null
  ,p_pgi_attribute4               in     varchar2 default null
  ,p_pgi_attribute5               in     varchar2 default null
  ,p_pgi_attribute6               in     varchar2 default null
  ,p_pgi_attribute7               in     varchar2 default null
  ,p_pgi_attribute8               in     varchar2 default null
  ,p_pgi_attribute9               in     varchar2 default null
  ,p_pgi_attribute10              in     varchar2 default null
  ,p_pgi_attribute11              in     varchar2 default null
  ,p_pgi_attribute12              in     varchar2 default null
  ,p_pgi_attribute13              in     varchar2 default null
  ,p_pgi_attribute14              in     varchar2 default null
  ,p_pgi_attribute15              in     varchar2 default null
  ,p_pgi_attribute16              in     varchar2 default null
  ,p_pgi_attribute17              in     varchar2 default null
  ,p_pgi_attribute18              in     varchar2 default null
  ,p_pgi_attribute19              in     varchar2 default null
  ,p_pgi_attribute20              in     varchar2 default null
  ,p_pgi_information_category     in     varchar2 default null
  ,p_pgi_information1             in     varchar2 default null
  ,p_pgi_information2             in     varchar2 default null
  ,p_pgi_information3             in     varchar2 default null
  ,p_pgi_information4             in     varchar2 default null
  ,p_pgi_information5             in     varchar2 default null
  ,p_pgi_information6             in     varchar2 default null
  ,p_pgi_information7             in     varchar2 default null
  ,p_pgi_information8             in     varchar2 default null
  ,p_pgi_information9             in     varchar2 default null
  ,p_pgi_information10            in     varchar2 default null
  ,p_pgi_information11            in     varchar2 default null
  ,p_pgi_information12            in     varchar2 default null
  ,p_pgi_information13            in     varchar2 default null
  ,p_pgi_information14            in     varchar2 default null
  ,p_pgi_information15            in     varchar2 default null
  ,p_pgi_information16            in     varchar2 default null
  ,p_pgi_information17            in     varchar2 default null
  ,p_pgi_information18            in     varchar2 default null
  ,p_pgi_information19            in     varchar2 default null
  ,p_pgi_information20            in     varchar2 default null
  ,p_pgi_information21            in     varchar2 default null
  ,p_pgi_information22            in     varchar2 default null
  ,p_pgi_information23            in     varchar2 default null
  ,p_pgi_information24            in     varchar2 default null
  ,p_pgi_information25            in     varchar2 default null
  ,p_pgi_information26            in     varchar2 default null
  ,p_pgi_information27            in     varchar2 default null
  ,p_pgi_information28            in     varchar2 default null
  ,p_pgi_information29            in     varchar2 default null
  ,p_pgi_information30            in     varchar2 default null
  ,p_pgm_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_pgm_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates extra information for a given pgm as identified by the
--   in parameter p_pgm_extra_info_id and the in out parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The pgm extra info as identified by the in parameter
--   p_pgm_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is updated
--   p_pgm_extra_info_id       yes  number   Primary key of the pgm
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                pgm extra info to be
--                                                updated
--   p_pgi_attribute_category           varchar2 Determines context of the
--                                                pgm_attribute descriptive
--                                                flexfield in parameters
--   p_pgi_attribute1                   varchar2 Descriptive flexfield
--   p_pgi_attribute2                   varchar2 Descriptive flexfield
--   p_pgi_attribute3                   varchar2 Descriptive flexfield
--   p_pgi_attribute4                   varchar2 Descriptive flexfield
--   p_pgi_attribute5                   varchar2 Descriptive flexfield
--   p_pgi_attribute6                   varchar2 Descriptive flexfield
--   p_pgi_attribute7                   varchar2 Descriptive flexfield
--   p_pgi_attribute8                   varchar2 Descriptive flexfield
--   p_pgi_attribute9                   varchar2 Descriptive flexfield
--   p_pgi_attribute10                  varchar2 Descriptive flexfield
--   p_pgi_attribute11                  varchar2 Descriptive flexfield
--   p_pgi_attribute12                  varchar2 Descriptive flexfield
--   p_pgi_attribute13                  varchar2 Descriptive flexfield
--   p_pgi_attribute14                  varchar2 Descriptive flexfield
--   p_pgi_attribute15                  varchar2 Descriptive flexfield
--   p_pgi_attribute16                  varchar2 Descriptive flexfield
--   p_pgi_attribute17                  varchar2 Descriptive flexfield
--   p_pgi_attribute18                  varchar2 Descriptive flexfield
--   p_pgi_attribute19                  varchar2 Descriptive flexfield
--   p_pgi_attribute20                  varchar2 Descriptive flexfield
--   p_pgi_information_category         varchar2 Determines context of the
--                                                pgm_attribute developer
--                                                descriptive flexfield in
--                                                parameters
--   p_pgi_information1                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information2                 varchar2 Descriptive flexfield
--                                                flexfield
--   p_pgi_information3                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information4                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information5                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information6                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information7                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information8                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information9                 varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information10                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information11                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information12                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information13                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information14                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information15                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information16                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information17                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information18                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information19                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information20                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information21                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information22                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information23                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information24                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information25                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information26                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information27                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information28                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information29                varchar2 Developer descriptive
--                                                flexfield
--   p_pgi_information30                varchar2 default null
--                                                flexfield
--
-- Post Success:
--   The pgm extra info is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           pgm extra info.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not update the pgm extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_pgm_extra_info
  (p_validate                     in     boolean  default false
  ,p_pgm_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_pgi_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information1             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information2             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information3             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information4             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information5             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information6             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information7             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information8             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information9             in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information10            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information11            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information12            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information13            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information14            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information15            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information16            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information17            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information18            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information19            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information20            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information21            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information22            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information23            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information24            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information25            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information26            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information27            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information28            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information29            in     varchar2 default hr_api.g_varchar2
  ,p_pgi_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_pgm_extra_info >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes extra information for a given pgm as identified by the
--   in parameter p_pgm_extra_info_id and the in parameter
--   p_object_version_number.
--
-- Prerequisites:
--   The pgm extra info as identified by the in parameter
--   p_pgm_extra_info_id and the in out parameter p_object_version_number must
--   already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the extra info is deleted
--   p_pgm_extra_info_id       yes  number   Primary key of the pgm
--                                                extra info
--   p_object_version_number        yes  number   Current version of the
--                                                pgm extra info to be
--                                                deleted
--
-- Post Success:
--   The pgm extra info is deleted
--
-- Post Failure:
--   The API does not delete the pgm extra info and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_pgm_extra_info
  (p_validate                      	in     boolean  default false
  ,p_pgm_extra_info_id        	in     number
  ,p_object_version_number         	in     number
  );
--
end ben_pgm_extra_info_api;

 

/
