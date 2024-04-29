--------------------------------------------------------
--  DDL for Package HR_CALENDAR_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CALENDAR_ENTRY_API" AUTHID CURRENT_USER as
/* $Header: peentapi.pkh 120.0 2005/05/31 08:08:15 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_calendar_entry >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a calendar entry.
--
--
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the calendar entry is created.
--   p_effective_date               Yes  date     Application effective date.
--   p_name                         Yes  varchar2 The name of the calendar entry.
--   p_type                         Yes  varchar2 The type of the calendar entry.
--   p_start_date                   Yes  date     The start date (time component will be truncated)
--                                                of the calendar entry.
--   p_start_hour                        varchar2 The lookup_code of the hour that the entry starts.
--   p_start_min                         varchar2 The lookup_code of the minute (to nearest 5 minute)
--                                                that the entry starts
--   p_end_date                     Yes  date     The end date (time component will be truncated)
--                                                of the calendar entry.
--   p_end_hour                          varchar2 The lookup_code of the hour that the entry ends.
--   p_end_min                           varchar2 The lookup_code of the minute (to nearest 5 minute)
--                                                that the entry ends.
--   p_business_group_id                 number   The id of the business group.
--   p_description                       varchar2 Description of the calendar entry.
--   p_hierarchy_id                      number   ID of the generic hierarchy (per_gen_hierarchy)
--                                                that will be used when creating entry values
--                                                for the entry (as opposed to stand-alone entry values).
--   p_value_set_id                      number   ID of the value set that will be used when creating
--                                                stand-alone (non-hierarchy) entry values.
--   p_organization_structure_id         number   ID of the Organization Structure (hierarchy) that will be
--                                                used when creating entry values.
--   p_org_structure_version_id          number   ID of the specific Organization Structure Version
--                                                for the Organization Structure.
--   p_legislation_code                  varchar2 Seed data legislative owner code - Internal Development Use only.
--   p_identifier_key                    varchar2 Seed data loader developer key - Internal Development Use only.
--
-- Post Success:
--   The calendar entry record is created and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_calendar_entry_id            number   If p_validate is false, uniquely
--                                           identifies the  calendar entry created.
--                                           If p_validate is true, set to
--                                           null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           calendar entry.
--                                           If p_validate is true, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the calendar entry record and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

procedure create_calendar_entry
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_name                          in     varchar2
  ,p_type                          in     varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2 default null
  ,p_start_min                     in     varchar2 default null
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2 default null
  ,p_end_min                       in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_hierarchy_id                  in     number   default null
  ,p_value_set_id                  in     number   default null
  ,p_organization_structure_id     in     number   default null
  ,p_org_structure_version_id      in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_identifier_key                in     varchar2 default null
  ,p_calendar_entry_id                out nocopy number
  ,p_object_version_number            out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_calendar_entry >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates a calendar entry as identified by p_calendar_entry_id.
--
-- Prerequisites:
--   The calendar entry record identified by p_calendar_entry_id and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the calendar entry  is updated.
--   p_effective_date               Yes  date     Application effective date.
--   p_calendar_entry_id            Yes  number   Surrogate id of the calendar entry
--   p_object_version_number        Yes  number   Version number of the calendar entry record.
--   p_name                              varchar2 The type of the calendar entry.
--   p_type                              varchar2 The type of calendar entry.
--   p_start_date                        date     The start date (inc. time component)
--                                                of the calendar entry.
--   p_start_hour                        varchar2 The lookup_code of the hour that the entry starts.
--   p_start_min                         varchar2 The lookup_code of the minute (to nearest 5 minute)
--                                                that the entry starts
--   p_end_date                          date     The end date (inc. time component)
--                                                of the calendar entry.
--   p_end_hour                          varchar2 The lookup_code of the hour that the entry ends.
--   p_end_min                           varchar2 The lookup_code of the minute (to nearest 5 minute)
--                                                that the entry ends.
--   p_description                       varchar2 Description of the calendar entry.
--   p_hierarchy_id                      number   ID of the generic hierarchy (per_gen_hierarchy)
--                                                that will be used when creating entry values
--                                                for the entry (as opposed to stand-alone entry values).
--   p_value_set_id                      number   ID of the value set that will be used when creating
--                                                stand-alone (non-hierarchy) entry values
--   p_organization_structure_id         number   ID of the Organization Structure (hierarchy) that will be
--                                                used when creating entry values.
--   p_org_structure_version_id          number   ID of the specific Organization Structure Version
--                                                for the Organization Structure.
-- Post Success:
--   The calendar entry record is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of this
--                                           calendar entry.
--                                           If p_validate is true, set to
--                                           null same value passed in.
--
-- Post Failure:
--   The API does not update the calendar entry and raises an error.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
--
procedure update_calendar_entry
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_type                          in     varchar2 default hr_api.g_varchar2
  ,p_start_date                    in     date
  ,p_start_hour                    in     varchar2 default hr_api.g_varchar2
  ,p_start_min                     in     varchar2 default hr_api.g_varchar2
  ,p_end_date                      in     date
  ,p_end_hour                      in     varchar2 default hr_api.g_varchar2
  ,p_end_min                       in     varchar2 default hr_api.g_varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_hierarchy_id                  in     number   default hr_api.g_number
  ,p_value_set_id                  in     number   default hr_api.g_number
  ,p_organization_structure_id     in     number   default hr_api.g_number
  ,p_org_structure_version_id      in     number   default hr_api.g_number
  ,p_business_group_id             in     number   default null
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a calendar entry record as identified by the in parameter
--   p_calendar_entry_id and p_object_version_number after first deleting any
--   existing per_cal_entry_values records for the calendar entry.
--
-- Prerequisites:
--   The calendar entry as identified by the in parameter p_calendar_entry_id and the
--   in parameter p_object_version_number must already exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the calendar entry is deleted.
--   p_calendar_entry_id            Yes  number   Primary key of the calendar entry.
--   p_object_version_number        Yes  number   Current version of the
--                                                calendar entry
--
-- Post Success:
--   The calendar entry is deleted.
--
-- Post Failure:
--   The API does not delete the calendar entry and raises an error.
--
-- Access Status:
--   Public
--
-- {End Of Comments}
--
procedure delete_calendar_entry
  (p_validate                      in     boolean  default false
  ,p_calendar_entry_id             in     number
  ,p_object_version_number         in     number
  );
--
--
end  HR_CALENDAR_ENTRY_API;

 

/
