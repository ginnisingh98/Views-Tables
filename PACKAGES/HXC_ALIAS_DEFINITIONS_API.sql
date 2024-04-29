--------------------------------------------------------
--  DDL for Package HXC_ALIAS_DEFINITIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_ALIAS_DEFINITIONS_API" AUTHID CURRENT_USER as
/* $Header: hxchadapi.pkh 120.0 2005/05/29 05:32:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_alias_definition >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    p_validate                    No   Boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then a new alias definition is
--                                                created. The default is FALSE.
--    p_alias_definition_name       Yes  varchar2 Name for the alias
--    p_timecard_field              Yes  varchar2 The field on the timecard
--                                                for which this alias will
--                                                be used.
--    p_description                 No   varchar2 User description of the alias
--
--   p_prompt 			    No   varchar2 Prompt for the alternate Name
--						  defined.
--  p_alias_type_id		    Yes	 Number   ID of the alternate Name Type.
--
-- Post Success:
--
-- The following OUT parameters are set after the alias definition
-- has been created successfully:
--
--   Name                           Type     Description
--    p_alias_definition_id         number   Primary Key for entity
--    p_object_version_number       number   Object Version Number
--
-- Post Failure:
--
-- The alias definition will not be created and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_alias_definition
  (p_validate                      in     boolean  default false
  ,p_alias_definition_id	      out nocopy number
  ,p_alias_definition_name	   in     varchar2
  ,p_alias_context_code            in     varchar2 default null
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_prompt                        in     varchar2 default null
  ,p_timecard_field		   in     varchar2
  ,p_object_version_number            out nocopy number
  ,p_language_code                 in     varchar2  default hr_api.userenv_lang
  ,p_alias_type_id                 in     number
--  ,p_effective_date                in     date
--  ,p_non_mandatory_arg             in     number   default null
--  ,p_some_warning                     out boolean
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_alias_definition >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API updates an existing alias definition.
--
-- Prerequisites:
--    None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    p_validate		    No   Boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias definition is
--                                                updated. The default is FALSE.
--    p_alias_definition_id         Yes  number   Primary Key for entity
--    p_alias_definition_name       Yes  varchar2 Name for the alias
--    p_timecard_field       	    Yes  varchar2 The field on the timecard
--						  for which this alias will
--						  be used.
--    p_description                 No   varchar2 User description of the alias
--   p_prompt                       No   varchar2 Prompt for the alternate Name
--                                                defined.
--  p_alias_type_id                 Yes  Number   ID of the alternate Name Type.
--
--    p_object_version_number       No   number   Object Version Number of the
--						  existing record.
--
-- Post Success:
--
-- The following OUT parameters are set, after the alias definition has
-- been updated successfully:
--
--   Name                           Type     Description
--    p_object_version_number       number   Object Version Number of the
--					     updated record.
--
-- Post Failure:
--
-- The alias definition will not be updated and an application error will be
-- raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_alias_definition
  (p_validate                      in     boolean  default false
  ,p_alias_definition_id           in     number
  ,p_alias_definition_name         in     varchar2
  ,p_alias_context_code            in     varchar2 default null
  ,p_business_group_id	           in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_prompt                        in     varchar2 default null
  ,p_timecard_field                in     varchar2
  ,p_object_version_number         in out nocopy number
  ,p_language_code                 in     varchar2  default hr_api.userenv_lang
  ,p_alias_type_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_alias_definition >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API deletes an existing alias definition.
--
-- Prerequisites:
--    None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--    p_validate                    No   boolean  If TRUE then the database
--                                                remains unchanged. If FALSE
--                                                then the alias definition.
--                                                is deleted. Default is FALSE.
--    p_alias_definition_id         Yes  number   Primary Key for entity
--    p_object_version_number       Yes  number   Object Version Number
--
-- Post Success:
--
--   If the alias definition has been deleted successfully the process
--   completes with success, with no OUT parameters being set.
--
-- Post Failure:
--
--   The alias definition will not be deleted and an application error is
--   raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_alias_definition
  (p_validate                      in     boolean  default false
  ,p_alias_definition_id           in     number
  ,p_object_version_number         in     number
  );
--
end hxc_alias_definitions_api;

 

/
