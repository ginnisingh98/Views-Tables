--------------------------------------------------------
--  DDL for Package HR_DEPLOYMENT_FACTOR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DEPLOYMENT_FACTOR_SWI" AUTHID CURRENT_USER as
/* $Header: pedpfswi.pkh 120.0 2005/05/31 07:45:59 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_person_dpmt_factor >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API is used to create a deployment factor for a person
--
-- Prerequisites:
--  The person must exist in the database
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the assignment and
--                                                element entries are
--                                                updated.
--   p_effective_date               Yes  date     The effective date of entry
--                                                of this deployment factor
--   p_person_id                    Yes  number   ID of the person
--   p_object_version_number        Yes  number   Version number of the
--                                                deployment factor record
--   p_work_any_country             Yes  varchar2 Yes/No field to describe if
--                                                work is required to be done
--                                                in any country.
--   p_work_any_location            Yes  varchar2 Yes/No field to describe if
--                                                work is required to be done
--                                                in any location.
--   p_relocate_domestically        Yes  varchar2 Yes/No field to describe
--                                                willingness to relocate
--                                                domestically
--   p_relocate_internationally     Yes  varchar2 Yes/No field to describe
--                                                willingness to relocate
--                                                internationally
--   p_travel_required              Yes  varchar2 Yes/No field to indicate if
--                                                travel is required
--   p_country1                     No   varchar2 A country where work will be
--                                                required
--   p_country2                     No   varchar2 A country where work will be
--                                                required
--   p_country3                     No   varchar2 A country where work will be
--                                                required
--   p_work_duration                No   varchar2 Required work duration
--   p_work_schedule                No   varchar2 Required work schedule
--   p_work_hours                   No   varchar2 Rerquired work hours
--   p_fte_capacity                 No   varchar2 Full time capacity
--   p_visit_internationally        No   varchar2 Yes/No field to describe
--                                                willingness to visit
--                                                internationally
--   p_only_current_location        No   varchar2 Yes/No field to describe
--                                                if only the current location
--                                                is acceptable
--   p_no_country1                  No   varchar2 A country which is not
--                                                acceptable
--   p_no_country2                  No   varchar2 A country which is not
--                                                acceptable
--   p_no_country3                  No   varchar2 A country which is not
--                                                acceptable
--   p_comments                     No   varchar2 comments
--   p_earliest_available_date      No   date     Earliest date for transfer
--   p_available_for_transfer       No   varchar2 Yes/No field to indicate if
--                                                the person is availabe for
--                                                transfer
--   p_relocation_preference        No   varchar2 The persons relocation
--                                                preference
--   p_attribute_category           No   varchar2 Flexfield Column
--   p_attribute1                   No   varchar2 Flexfield Column
--   p_attribute2                   No   varchar2 Flexfield Column
--   p_attribute3                   No   varchar2 Flexfield Column
--   p_attribute4                   No   varchar2 Flexfield Column
--   p_attribute5                   No   varchar2 Flexfield Column
--   p_attribute6                   No   varchar2 Flexfield Column
--   p_attribute7                   No   varchar2 Flexfield Column
--   p_attribute8                   No   varchar2 Flexfield Column
--   p_attribute9                   No   varchar2 Flexfield Column
--   p_attribute10                  No   varchar2 Flexfield Column
--   p_attribute11                  No   varchar2 Flexfield Column
--   p_attribute12                  No   varchar2 Flexfield Column
--   p_attribute13                  No   varchar2 Flexfield Column
--   p_attribute14                  No   varchar2 Flexfield Column
--   p_attribute15                  No   varchar2 Flexfield Column
--   p_attribute16                  No   varchar2 Flexfield Column
--   p_attribute17                  No   varchar2 Flexfield Column
--   p_attribute18                  No   varchar2 Flexfield Column
--   p_attribute19                  No   varchar2 Flexfield Column
--   p_attribute20                  No   varchar2 Flexfield Column
--   p_deployment_factor_id         No   number
--   p_object_version_number        No   number
--
--
-- Post Success:
--   The following out parameters are set
--
--   Name                           Type     Description
--   p_deployment_factor_id         number   Unique ID for the new deployment
--                                           factor
--   p_object_version_number        number   version number for the new
--                                           deployment factor
--
-- Post Failure:
--  The API does not create a record and an error is raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_person_dpmt_factor
  (p_validate                     in     number default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_work_any_country             in     varchar2
  ,p_work_any_location            in     varchar2
  ,p_relocate_domestically        in     varchar2
  ,p_relocate_internationally     in     varchar2
  ,p_travel_required              in     varchar2
  ,p_country1                     in     varchar2 default null
  ,p_country2                     in     varchar2 default null
  ,p_country3                     in     varchar2 default null
  ,p_work_duration                in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_work_hours                   in     varchar2 default null
  ,p_fte_capacity                 in     varchar2 default null
  ,p_visit_internationally        in     varchar2 default null
  ,p_only_current_location        in     varchar2 default null
  ,p_no_country1                  in     varchar2 default null
  ,p_no_country2                  in     varchar2 default null
  ,p_no_country3                  in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_earliest_available_date      in     date     default null
  ,p_available_for_transfer       in     varchar2 default null
  ,p_relocation_preference        in     varchar2 default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_deployment_factor_id            out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_person_dpmt_factor >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API is used to update a deployment factor for a person
--
-- Prerequisites:
--  The person must exist in the database.
--  The deployment factor must exist in the database
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the assignment and
--                                                element entries are
--                                                updated.
--   p_effective_date               Yes  date     The effective date of entry
--                                                of this deployment factor
--   p_deployment_factor_id         Yes  number   ID of the deployment factor
--   p_object_version_number        Yes  number   Version number of the
--                                                deployment factor record
--   p_work_any_country             Yes  varchar2 Yes/No field to describe if
--                                                work is required to be done
--                                                in any country.
--   p_work_any_location            Yes  varchar2 Yes/No field to describe if
--                                                work is required to be done
--                                                in any location.
--   p_relocate_domestically        Yes  varchar2 Yes/No field to describe
--                                                willingness to relocate
--                                                domestically
--   p_relocate_internationally     Yes  varchar2 Yes/No field to describe
--                                                willingness to relocate
--                                                internationally
--   p_travel_required              Yes  varchar2 Yes/No field to indicate if
--                                                travel is required
--   p_country1                     No   varchar2 A country where work will be
--                                                required
--   p_country2                     No   varchar2 A country where work will be
--                                                required
--   p_country3                     No   varchar2 A country where work will be
--                                                required
--   p_work_duration                No   varchar2 Required work duration
--   p_work_schedule                No   varchar2 Required work schedule
--   p_work_hours                   No   varchar2 Rerquired work hours
--   p_fte_capacity                 No   varchar2 Full time capacity
--   p_visit_internationally        No   varchar2 Yes/No field to describe
--                                                willingness to visit
--                                                internationally
--   p_only_current_location        No   varchar2 Yes/No field to describe
--                                                if only the current location
--                                                is acceptable
--   p_no_country1                  No   varchar2 A country which is not
--                                                acceptable
--   p_no_country2                  No   varchar2 A country which is not
--                                                acceptable
--   p_no_country3                  No   varchar2 A country which is not
--                                                acceptable
--   p_comments                     No   varchar2 comments
--   p_earliest_available_date      No   date     Earliest date for transfer
--   p_available_for_transfer       No   varchar2 Yes/No field to indicate if
--                                                the person is availabe for
--                                                transfer
--   p_relocation_preference        No   varchar2 The persons relocation
--                                                preference
--   p_attribute_category           No   varchar2 Flexfield Column
--   p_attribute1                   No   varchar2 Flexfield Column
--   p_attribute2                   No   varchar2 Flexfield Column
--   p_attribute3                   No   varchar2 Flexfield Column
--   p_attribute4                   No   varchar2 Flexfield Column
--   p_attribute5                   No   varchar2 Flexfield Column
--   p_attribute6                   No   varchar2 Flexfield Column
--   p_attribute7                   No   varchar2 Flexfield Column
--   p_attribute8                   No   varchar2 Flexfield Column
--   p_attribute9                   No   varchar2 Flexfield Column
--   p_attribute10                  No   varchar2 Flexfield Column
--   p_attribute11                  No   varchar2 Flexfield Column
--   p_attribute12                  No   varchar2 Flexfield Column
--   p_attribute13                  No   varchar2 Flexfield Column
--   p_attribute14                  No   varchar2 Flexfield Column
--   p_attribute15                  No   varchar2 Flexfield Column
--   p_attribute16                  No   varchar2 Flexfield Column
--   p_attribute17                  No   varchar2 Flexfield Column
--   p_attribute18                  No   varchar2 Flexfield Column
--   p_attribute19                  No   varchar2 Flexfield Column
--   p_attribute20                  No   varchar2 Flexfield Column
--   p_deployment_factor_id         No   number
--   p_object_version_number        No   number
--
--
-- Post Success:
--   The following out parameters are set
--
--   Name                           Type     Description
--   p_object_version_number        number   version number for the new
--                                           deployment factor
--
-- Post Failure:
--  The API does not update the record and an error is raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_person_dpmt_factor
  (p_validate                     in     number default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_deployment_factor_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_work_any_country             in     varchar2 default hr_api.g_varchar2
  ,p_work_any_location            in     varchar2 default hr_api.g_varchar2
  ,p_relocate_domestically        in     varchar2 default hr_api.g_varchar2
  ,p_relocate_internationally     in     varchar2 default hr_api.g_varchar2
  ,p_travel_required              in     varchar2 default hr_api.g_varchar2
  ,p_country1                     in     varchar2 default hr_api.g_varchar2
  ,p_country2                     in     varchar2 default hr_api.g_varchar2
  ,p_country3                     in     varchar2 default hr_api.g_varchar2
  ,p_work_duration                in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_work_hours                   in     varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in     varchar2 default hr_api.g_varchar2
  ,p_visit_internationally        in     varchar2 default hr_api.g_varchar2
  ,p_only_current_location        in     varchar2 default hr_api.g_varchar2
  ,p_no_country1                  in     varchar2 default hr_api.g_varchar2
  ,p_no_country2                  in     varchar2 default hr_api.g_varchar2
  ,p_no_country3                  in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_earliest_available_date      in     date     default hr_api.g_date
  ,p_available_for_transfer       in     varchar2 default hr_api.g_varchar2
  ,p_relocation_preference        in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  );
--
--
end hr_deployment_factor_swi;

 

/
