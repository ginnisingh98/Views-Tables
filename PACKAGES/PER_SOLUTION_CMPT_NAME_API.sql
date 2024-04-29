--------------------------------------------------------
--  DDL for Package PER_SOLUTION_CMPT_NAME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_CMPT_NAME_API" AUTHID CURRENT_USER as
/* $Header: pescnapi.pkh 120.0 2005/05/31 20:46:04 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_SOLUTION_CMPT_NAME >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process adds a new solution type.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_id                  yes  number   Solution Id
--   p_component_name               yes  varchar2 Component Name
--   p_solution_type_name           yes  varchar2 Solution Type Name
--   p_name                         no   varchar2 Name of the component row
--   p_template_file                no   blob The template file as defined
--                                                in AZ_FILES
--
--
-- Post Success:
--   When the solution type is valid, the API sets the following out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, this
--                                           will be set to the version number
--                                           of the Solution Component Name
--                                           created. If p_validate is true this
--                                           parameter will be set to null.
--
--
-- Post Failure:
--   The API does not create a Solution Component Name and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_solution_cmpt_name
  (p_validate                      in     boolean   default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2  default null
  ,p_object_version_number            out nocopy number
  );
--
--
procedure create_solution_cmpt_name
  (p_validate                      in     boolean   default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2  default null
  ,p_template_file                 in     varchar2
  ,p_object_version_number            out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTION_CMPT_NAME >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process updates a solution component name.
--
-- Prerequisites:
--   The Solution Component Name record must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_id                  yes  number   Solution Id
--   p_component_name               yes  varchar2 Component Name
--   p_solution_type_name           yes  varchar2 Solution Type Name
--   p_name                         no   varchar2 Name of the component row
--   p_template_file                no   blob The template file as defined
--                                                in AZ_FILES
--   p_object_version_number        yes  number   Object Version Number
--
--
--
-- Post Success:
--   The Solution Component Name record is updated and the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false the
--                                           new version number is returned.
--                                           If p_validate is true then the
--                                           version number passed in is
--                                           returned.
--
-- Post Failure:
--   The API does not update a Solution Component Name and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_solution_cmpt_name
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_name                          in     varchar2   default hr_api.g_varchar2
  ,p_template_file                 in     varchar2
  ,p_object_version_number         in out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTION_CMPT_NAME >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process deletes a solution component name.
--
-- Prerequisites:
--   The Solution Component Name record identified by p_solution_cmpt_name_name
--   and p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_id                  yes  number   Solution Id
--   p_component_name               yes  varchar2 Component Name
--   p_solution_type_name           yes  varchar2 Solution Type Name
--   p_object_version_number        yes  number   Object Version Number
--
-- Post Success:
--   The Solution Component Name is deleted.
--
-- Post Failure:
--   The API does not delete a Solution Component Name and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_solution_cmpt_name
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_cmpt_name_api;

 

/
