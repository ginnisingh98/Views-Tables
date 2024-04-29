--------------------------------------------------------
--  DDL for Package HXC_TIME_ENTRY_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_ENTRY_RULE_API" AUTHID CURRENT_USER as
/* $Header: hxcterapi.pkh 120.0 2005/05/29 05:59:23 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_entry_rule>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API creates a Time Entry Rule with a given name, approval rule
-- usage covering a particular date ranege. If no Date To is specified
-- the rule is assumed to be valid until the end of time.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new time_entry_rule
--                                                is created. Default is FALSE.
--   p_time_entry_rule_id        No   number   Primary Key for entity
--   p_object_version_number        No   number   Object Version Number
--   p_name                         Yes  varchar2 Name for the time entry rule
--   p_business_group_id                 number   The ID of the business
--                                                group which is linked to
--                                                the time entry rule.
--   p_legislation_code                  varchar2 The legislation code linked
--                                                to the time entry rule.
--   p_rule_usage                   Yes  varchar2 Rule Usage Code - must be a valid
--                                                value from HR_LOOKUPS for the type
--                                                'APPROVAL_RULE_USAGE'
--   p_start_date                    Yes  date     Start date of the rule
--   p_mapping_id                   No   number   Field Mapping Id
--   p_formula_id                   No   number   Fast Formula ID
--   p_description                  No   varchar2 User description of the rule
--   p_end_date                      No   date     End Date of the rule
--   p_effective_date               No   date     Effective Date - today's date.
--   p_attribute_category           No   varchar2 Attribute Category for
--                                                attribute columns.
--   p_attribute1..n                No   varchar2 Values for Time Entry Rules
--
-- Post Success:
--
-- when the time_entry_rule has been created successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_time_entry_rule_id        Number   Primary Key for the new rule
--   p_object_version_number        Number   Object version number for the
--                                           new rule
--
-- Post Failure:
--
-- The time entry rule will not be inserted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_time_entry_rule
  (p_validate                      in  boolean   default false
  ,p_time_entry_rule_id            in  out nocopy number
  ,p_object_version_number         in  out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_rule_usage                    in     varchar2
  ,p_start_date                    in     date
  ,p_mapping_id                    in     number   default null
  ,p_formula_id                    in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_end_date                      in     date     default null
  ,p_effective_date                in     date     default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  );
    --
-- ----------------------------------------------------------------------------
-- |------------------------<update_time_entry_rule>-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API updates an existing Time Entry Rule with a given name, approval
-- rule usage covering a particular date range.
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the time_entry_rule
--                                                is updated. Default is FALSE.
--   p_time_entry_rule_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--   p_name                         Yes  varchar2 Name for the time entry rule
--   p_business_group_id                 number   The ID of the business
--                                                group which is linked to
--                                                the time entry rule.
--   p_legislation_code                  varchar2 The legislation code linked
--                                                to the time entry rule.
--   p_rule_usage                   Yes  varchar2 Rule Usage Code - must be a valid
--                                                value from HR_LOOKUPS for the type
--                                                'APPROVAL_RULE_USAGE'
--   p_start_date                    Yes  date     Start date of the rule
--   p_mapping_id                   No   number   Field Mapping ID
--   p_formula_id                   No   number   Fast Formula ID
--   p_description                  No   varchar2 User description of the rule
--   p_end_date                      No   date     End Date of the rule
--   p_effective_date               No   date     Effective Date - today's date.
--   p_attribute_category           No   varchar2 Attribute Category for
--                                                attribute columns.
--   p_attribute1..n                No   varchar2 Values for Time Entry Rules
--
--
-- Post Success:
--
-- when the time_entry_rule has been updated successfully the following
-- out parameters are set.
--
--   Name                           Type     Description
--
--   p_object_version_number        Number   Object version number for the
--                                           updated rule
--
-- Post Failure:
--
-- The time entry rule will not be updated and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_time_entry_rule
  (p_validate                      in      boolean   default false
  ,p_time_entry_rule_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_rule_usage                    in     varchar2
  ,p_start_date                    in     date
  ,p_mapping_id                    in     number   default hr_api.g_number
  ,p_formula_id                    in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_effective_date		   in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_entry_rule >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--
-- This API deletes an existing Time Entry Rule
--
-- Prerequisites:
--
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   p_validate                     No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the time_entry_rule
--                                                is deleted. Default is FALSE.
--   p_time_entry_rule_id        Yes  number   Primary Key for entity
--   p_object_version_number        Yes  number   Object Version Number
--
-- Post Success:
--
-- when the time_entry_rule has been deleted successfully the process
-- completes with success.
--
-- Post Failure:
--
-- The time entry rule will not be deleted and an application error raised
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_time_entry_rule
  (p_validate                       in  boolean  default false
  ,p_time_entry_rule_id          in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_time_entry_rule_api;

 

/
