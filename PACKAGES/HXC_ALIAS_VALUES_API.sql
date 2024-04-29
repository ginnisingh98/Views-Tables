--------------------------------------------------------
--  DDL for Package HXC_ALIAS_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_VALUES_API" AUTHID CURRENT_USER as
/* $Header: hxchavapi.pkh 120.0 2005/05/29 05:34:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_alias_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API creates an alias value.
--
-- Prerequisites:
--    An alias definition must exist, for which alias values will be created.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    p_validate                    No   boolean  IF TRUE then the database
--                                                remains unchanged.IF FALSE
--                                                then a new alias value is
--                                                created. The default is FALSE.
--    p_alias_value_name            Yes  varchar2 The name for the alias value.
--    p_date_from		    Yes  date	  The beginning date from which
--						  this alias value is valid.
--    p_date_to                     No   date     The end date for this alias
--						  value.
--    p_alias_definition_id         Yes  number   The foreign key to the alias
--                                                definitions table.  The alias
--						  value belongs to this alias
--						  definition.
--    p_enabled_flag                Yes  varchar2 This flag indicates whether
--                                                or not the alias value
--						  will be visible on the list
--						  of values on the timecard
--						  field. 'Y' means it is
--						  visible; 'N' means it is not.
--    p_attribute_category          No   varchar2 The flexfield context, for
--                                                the attribute columns.
--    p_attribute1..n               No   varchar2 Values for alias fields.
--
--
-- Post Success:
--   After the alias value has been created successfully, the following OUT
--   parameters are set:
--
--   Name                           Type     Description
--    p_alias_value_id              number   Primary Key for entity
--    p_object_version_number       number   Object Version Number of the new
--                                           alias value record.
--
-- Post Failure:
--   The alias value is not created and an application error is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_alias_value
  (p_validate                      in     boolean  default false
  ,p_alias_value_id                   out nocopy number
  ,p_alias_value_name		   in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_alias_definition_id	   in     number
  ,p_enabled_flag		   in     varchar2
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
  ,p_object_version_number            out nocopy number
  ,p_language_code                 in     varchar2  default hr_api.userenv_lang
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_alias_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API updates an existing alias value.
--
-- Prerequisites:
--    None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    p_validate                    No   boolean  IF TRUE then the database
--                                                remains unchanged.IF FALSE
--                                                then the alias value is
--                                                updated. The default is FALSE.
--    p_alias_value_id              Yes  number   Primary Key for entity
--    p_alias_value_name            Yes  varchar2 The name for the alias value.
--    p_date_from                   Yes  date     The beginning date from which
--                                                this alias value is valid.
--    p_date_to                     No   date     The end date for this alias
--                                                value.
--    p_alias_definition_id         Yes  number   The foreign key to the alias
--                                                definitions table.  The alias
--                                                value belongs to this alias
--                                                definition.
--    p_enabled_flag                Yes  varchar2 This flag indicates whether
--                                                or not the alias value
--                                                will be visible on the list
--                                                of values on the timecard
--                                                field. 'Y' means it is
--                                                visible; 'N' means it is not.
--    p_attribute_category          No   varchar2 The flexfield context, for
--                                                the attribute columns.
--    p_attribute1..n               No   varchar2 Values for alias fields.
--    p_object_version_number       No   number   Object Version Number of the
--                                                existing record.
--
--
-- Post Success:
--   After the alias value has been updated successfully, the following OUT
--   parameters are set:
--
--   Name                           Type     Description
--    p_object_version_number       number   Object Version Number of the
--					     updated alias value record.
--
-- Post Failure:
--   The alias value is not updated and an application error is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_alias_value
  (p_validate                      in     boolean  default false
  ,p_alias_value_id                in     number
  ,p_alias_value_name              in     varchar2
  ,p_date_from                     in     date
  ,p_date_to                       in     date     default null
  ,p_alias_definition_id           in     number
  ,p_enabled_flag                  in     varchar2
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
  ,p_object_version_number         in out nocopy number
  ,p_language_code                 in     varchar2  default hr_api.userenv_lang
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alias_value >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API deletes an existing alias value.
--
-- Prerequisites:
--    None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    p_validate                    No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias value.
--                                                is deleted. Default is FALSE.
--    p_alias_value_id              Yes  number   Primary Key for entity
--    p_object_version_number       Yes  number   Object Version Number
--
-- Post Success:
--
--   If the alias value has been deleted successfully the process
--   completes with success, with no OUT parameters being set.
--
-- Post Failure:
--
--   The alias value will not be deleted and an application error is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_alias_value
  (p_validate                      in     boolean  default false
  ,p_alias_value_id                in     number
  ,p_object_version_number         in     number
  );
--
end hxc_alias_values_api;

 

/
