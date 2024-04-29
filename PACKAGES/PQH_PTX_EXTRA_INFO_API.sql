--------------------------------------------------------
--  DDL for Package PQH_PTX_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PTX_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pqpteapi.pkh 120.0 2005/05/29 02:20:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ptx_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_information_type             Yes  varchar2
--   p_position_transaction_id      Yes  number
--   p_position_extra_info_id       No   number
--   p_information_category         No   varchar2
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_attribute_category           No   varchar2  Descriptive Flexfield
--   p_attribute1                   No   varchar2  Descriptive Flexfield
--   p_attribute2                   No   varchar2  Descriptive Flexfield
--   p_attribute3                   No   varchar2  Descriptive Flexfield
--   p_attribute4                   No   varchar2  Descriptive Flexfield
--   p_attribute5                   No   varchar2  Descriptive Flexfield
--   p_attribute6                   No   varchar2  Descriptive Flexfield
--   p_attribute7                   No   varchar2  Descriptive Flexfield
--   p_attribute8                   No   varchar2  Descriptive Flexfield
--   p_attribute9                   No   varchar2  Descriptive Flexfield
--   p_attribute10                  No   varchar2  Descriptive Flexfield
--   p_attribute11                  No   varchar2  Descriptive Flexfield
--   p_attribute12                  No   varchar2  Descriptive Flexfield
--   p_attribute13                  No   varchar2  Descriptive Flexfield
--   p_attribute14                  No   varchar2  Descriptive Flexfield
--   p_attribute15                  No   varchar2  Descriptive Flexfield
--   p_attribute16                  No   varchar2  Descriptive Flexfield
--   p_attribute17                  No   varchar2  Descriptive Flexfield
--   p_attribute18                  No   varchar2  Descriptive Flexfield
--   p_attribute19                  No   varchar2  Descriptive Flexfield
--   p_attribute20                  No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
-- Out Parameters:
--   Name                                Type     Description
--   p_ptx_extra_info_id            Yes  number    PK of record
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_ptx_extra_info
(
   p_validate                       in boolean    default false
  ,p_ptx_extra_info_id              out nocopy number
  ,p_information_type               in  varchar2  default null
  ,p_position_transaction_id        in  number    default null
  ,p_position_extra_info_id         in  number    default null
  ,p_information_category           in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
-- ----------------------------------------------------------------------------
-- |------------------------< update_ptx_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_ptx_extra_info_id            Yes  number    PK of record
--   p_information_type             Yes  varchar2
--   p_position_transaction_id      Yes  number
--   p_position_extra_info_id       No   number
--   p_information_category         No   varchar2
--   p_information1                 No   varchar2
--   p_information2                 No   varchar2
--   p_information3                 No   varchar2
--   p_information4                 No   varchar2
--   p_information5                 No   varchar2
--   p_information6                 No   varchar2
--   p_information7                 No   varchar2
--   p_information8                 No   varchar2
--   p_information9                 No   varchar2
--   p_information10                No   varchar2
--   p_information11                No   varchar2
--   p_information12                No   varchar2
--   p_information13                No   varchar2
--   p_information14                No   varchar2
--   p_information15                No   varchar2
--   p_information16                No   varchar2
--   p_information17                No   varchar2
--   p_information18                No   varchar2
--   p_information19                No   varchar2
--   p_information20                No   varchar2
--   p_information21                No   varchar2
--   p_information22                No   varchar2
--   p_information23                No   varchar2
--   p_information24                No   varchar2
--   p_information25                No   varchar2
--   p_information26                No   varchar2
--   p_information27                No   varchar2
--   p_information28                No   varchar2
--   p_information29                No   varchar2
--   p_information30                No   varchar2
--   p_attribute_category           No   varchar2  Descriptive Flexfield
--   p_attribute1                   No   varchar2  Descriptive Flexfield
--   p_attribute2                   No   varchar2  Descriptive Flexfield
--   p_attribute3                   No   varchar2  Descriptive Flexfield
--   p_attribute4                   No   varchar2  Descriptive Flexfield
--   p_attribute5                   No   varchar2  Descriptive Flexfield
--   p_attribute6                   No   varchar2  Descriptive Flexfield
--   p_attribute7                   No   varchar2  Descriptive Flexfield
--   p_attribute8                   No   varchar2  Descriptive Flexfield
--   p_attribute9                   No   varchar2  Descriptive Flexfield
--   p_attribute10                  No   varchar2  Descriptive Flexfield
--   p_attribute11                  No   varchar2  Descriptive Flexfield
--   p_attribute12                  No   varchar2  Descriptive Flexfield
--   p_attribute13                  No   varchar2  Descriptive Flexfield
--   p_attribute14                  No   varchar2  Descriptive Flexfield
--   p_attribute15                  No   varchar2  Descriptive Flexfield
--   p_attribute16                  No   varchar2  Descriptive Flexfield
--   p_attribute17                  No   varchar2  Descriptive Flexfield
--   p_attribute18                  No   varchar2  Descriptive Flexfield
--   p_attribute19                  No   varchar2  Descriptive Flexfield
--   p_attribute20                  No   varchar2  Descriptive Flexfield
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_ptx_extra_info
  (
   p_validate                       in boolean    default false
  ,p_ptx_extra_info_id              in  number
  ,p_information_type               in  varchar2  default hr_api.g_varchar2
  ,p_position_transaction_id        in  number    default hr_api.g_number
  ,p_position_extra_info_id         in  number    default hr_api.g_number
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ptx_extra_info >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--   p_ptx_extra_info_id            Yes  number    PK of record
--
-- Post Success:
--
--   Name                           Type     Description
--   p_object_version_number        Yes  number    OVN of record
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_ptx_extra_info
  (
   p_validate                       in boolean        default false
  ,p_ptx_extra_info_id              in  number
  ,p_object_version_number          in out nocopy number
  );
--
--
end pqh_ptx_extra_info_api;

 

/
