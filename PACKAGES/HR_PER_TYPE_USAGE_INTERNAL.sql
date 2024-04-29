--------------------------------------------------------
--  DDL for Package HR_PER_TYPE_USAGE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PER_TYPE_USAGE_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peptubsi.pkh 120.0.12010000.2 2008/09/12 11:07:56 ghshanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_person_type_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_validate                     Yes  boolean   If true, the database remains
--                                                 unchanged, otherwise the row
--                                                 is created on the database.
--   p_person_id                    Yes  number    Person's Id
--   p_person_type_id               Yes  number    Person Type for person
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
--   p_attribute21                  No   varchar2  Descriptive Flexfield
--   p_attribute22                  No   varchar2  Descriptive Flexfield
--   p_attribute23                  No   varchar2  Descriptive Flexfield
--   p_attribute24                  No   varchar2  Descriptive Flexfield
--   p_attribute25                  No   varchar2  Descriptive Flexfield
--   p_attribute26                  No   varchar2  Descriptive Flexfield
--   p_attribute27                  No   varchar2  Descriptive Flexfield
--   p_attribute28                  No   varchar2  Descriptive Flexfield
--   p_attribute29                  No   varchar2  Descriptive Flexfield
--   p_attribute30                  No   varchar2  Descriptive Flexfield
--   p_effective_date               Yes  date      Session Date.
--
-- Post Success:
--   When the person type usage has been successfully inserted, the following
--   OUT parms are set.
--
-- Out Parameters:
--   Name                     Reqd Type      Description
--   p_person_type_usage_id   Yes  number    If p_validate is set to false, then
--                                           this uniquely identifies the new
--                                           record, else it contains null.
--   p_effective_start_date   Yes  date      If p_validate is set to false, then
--                                           this will be set to the effective
--                                           start date of the record, else it
--                                           will be set to null.
--   p_effective_end_date     Yes  date      If p_validate is set to false, then
--                                           this will be set to the effective
--                                           end date of the record, else it
--                                           will be set to null.
--   p_object_version_number  Yes  number    If p_validate is set to false, then
--                                           this will be set to the version
--                                           number of the record, else it
--                                           will be set to null.
--
-- Post Failure:
--   The API does not create the person type usage and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure create_person_type_usage
(
   p_validate                       in boolean    default false
  ,p_person_id                      in  number
  ,p_person_type_id                 in  number
  ,p_effective_date                 in  date
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
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_person_type_usage_id           out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_person_type_usage >------------------------|
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
--   p_validate                     Yes  boolean  If true, the database remains
--                                                unchanged, otherwise the row
--                                                is created on the database.
--   p_person_type_usage_id         Yes  number   ID of person usage type to
--                                                be deleted.
--   p_effective_date               Yes  date     Date on which record is to
--                                                be deleted.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode of delete.
--                                                Currently only DELETE and
--                                                ZAP are supported.
--
-- Post Success:
--   When the person type usage has been successfully deleted, the following
--   OUT parms are set. All of the below parameters will be set to NULL if the
--   datetrack delete mode is set to ZAP.
--
--   Name                     Reqd Type     Description
--   p_effective_start_date   Yes  date     If p_validate is set to false, then
--                                          this will be set to the effective
--                                          start date of the record, else it
--                                          will be set to null.
--   p_effective_end_date     Yes  date     If p_validate is set to false, then
--                                          this will be set to the effective
--                                          end date of the record, else it
--                                          will be set to null.
--   p_object_version_number  Yes  number   If p_validate is set to false, then
--                                          this will be set to the version
--                                          number of the record, else it
--                                          will be set to null.
--  Post Failure:
--   The API does not delete the person type usage and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure delete_person_type_usage
  (
   p_validate                       in boolean        default false
  ,p_person_type_usage_id           in number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_person_type_usage >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_validate                     Yes  boolean   If true, the database remains
--                                                 unchanged, otherwise the row
--                                                 is updated on the database.
--   p_effective_date               Yes  date      Session Date.
--   p_datetrack_mode               Yes  varchar2  Datetrack update mode
--   p_person_type_usage_id         Yes  number    Person Type Usage Identifier
--   p_object_version_number        Yes  number    Object version number for
--                                                 Person type usage
--   p_person_type_id               No   number    Person type identifier
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
--   p_attribute21                  No   varchar2  Descriptive Flexfield
--   p_attribute22                  No   varchar2  Descriptive Flexfield
--   p_attribute23                  No   varchar2  Descriptive Flexfield
--   p_attribute24                  No   varchar2  Descriptive Flexfield
--   p_attribute25                  No   varchar2  Descriptive Flexfield
--   p_attribute26                  No   varchar2  Descriptive Flexfield
--   p_attribute27                  No   varchar2  Descriptive Flexfield
--   p_attribute28                  No   varchar2  Descriptive Flexfield
--   p_attribute29                  No   varchar2  Descriptive Flexfield
--   p_attribute30                  No   varchar2  Descriptive Flexfield
--
-- Post Success:
--   When the person type usage has been successfully updated, the following
--   OUT parms are set.
--
-- Out Parameters:
--   Name                     Reqd Type      Description
--   p_object_version_number  Yes  number    If p_validate is set to false, then
--                                           this will be set to the version
--                                           number of the record, else it
--                                           will be set to null.
--   p_effective_start_date   Yes  date      If p_validate is set to false, then
--                                           this will be set to the effective
--                                           start date of the record, else it
--                                           will be set to null.
--   p_effective_end_date     Yes  date      If p_validate is set to false, then
--                                           this will be set to the effective
--                                           end date of the record, else it
--                                           will be set to null.
--
-- Post Failure:
--   The API does not update the person type usage and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure update_person_type_usage
(
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_person_type_usage_id           in     number
  ,p_object_version_number          in out nocopy number
  ,p_person_type_id                 in     number    default hr_api.g_number
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           out nocopy    date
  ,p_effective_end_date             out nocopy    date
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------< maintain_person_type_usage >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_effective_date               Yes  date      Session Date.
--   p_person_id                    Yes  number    Person identifier
--   p_person_type_id               Yes  number    Person type identifier
--   p_datetrack_update_mode        No   varchar2  Datetrack update mode
--   p_datetrack_delete_mode        No   varchar2  Datetrack delete mode
--
-- Post Success:
--   When the person type usage has been successfully maintained, the following
--   OUT parms are set.
--
-- Post Failure:
--   The API does not update the person type usage and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure maintain_person_type_usage
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_person_type_id                 in     number
  ,p_datetrack_update_mode          in     varchar2 default hr_api.g_update
  ,p_datetrack_delete_mode          in     varchar2 default null
 );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< cancel_person_type_usage >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_effective_date               Yes  date      Session Date.
--   p_person_id                    Yes  number    Person identifier
--   p_system_person_type           Yes  varchar2  System person type
--
-- Post Success:
--   When the person type usage has been successfully cancelled, the following
--   OUT parms are set.
--
-- Post Failure:
--   The API does not cancel the person type usage and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure cancel_person_type_usage
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_system_person_type             in     varchar2
 );
--

-- ----------------------------------------------------------------------------
-- |-----------------------< cancel_emp_apl_ptu >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_effective_date               Yes  date      Session Date.
--   p_person_id                    Yes  number    Person identifier
--   p_system_person_type           Yes  varchar2  System person type
--
-- Post Success:
--   When the person type usage has been successfully cancelled, the following
--   OUT parms are set.
--
-- Post Failure:
--   The API does not cancel the person type usage and raises an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure cancel_emp_apl_ptu
(
   p_effective_date                 in     date
  ,p_person_id                      in     number
  ,p_system_person_type             in     varchar2
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< change_hire_date_ptu >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_date_start                   Yes  date      new hire date
--   p_old_date_start               Yes  date      old hire date
--   p_person_id                    Yes  number    Person identifier
--   p_system_person_type           Yes  varchar2  System person type
--
-- Post Success:
--   When the hire date has been changed and the PTU record updated accordingly
--   the following OUT parms are set.
--
-- Post Failure:
--   The API does not move the start date of the PTU record and raise an error.
--
-- Access Status:
--   Internal.
--
-- {End Of Comments}
--
procedure change_hire_date_ptu
(
   p_date_start          in      date
  ,p_old_date_start 	in	date
  ,p_person_id		in	number
  ,p_system_person_type	in	varchar2
 );
--
end hr_per_type_usage_internal;

/
