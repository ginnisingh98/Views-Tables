--------------------------------------------------------
--  DDL for Package PER_SOLUTION_TYPE_CMPT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_TYPE_CMPT_API" AUTHID CURRENT_USER as
/* $Header: pestcapi.pkh 120.0 2005/05/31 21:57:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_SOLUTION_TYPE_CMPT >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process adds a new solution type component.
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
--   p_effective_date               yes  date     Effective date
--   p_component_name               yes  varchar2 Name of the component
--   p_solution_type_name           yes  varchar2 Name of the solution type
--   p_api_name                     yes  varchar2 Name of the API to load this
--                                                component
--   p_parent_component_name        no   varchar2 Parent of component hierarchy
--   p_updateable                   yes  varchar2 Flag to determine whether a
--                                                user can update this solution
--                                                type component.
--   p_extensible                   yes  varchar2 Flag to determine whether a
--                                                user can extend this solution
--                                                type component.
--   p_legislation_code             yes  varchar2 Legislation Code
--
--
-- Post Success:
--   When the solution type component is valid, the API sets the following
--   out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, this
--                                           will be set to the version number
--                                           of the Solution Type Component
--                                           created. If p_validate is true this
--                                           parameter will be set to null.
--
--
-- Post Failure:
--   The API does not create a Solution Type Component and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_solution_type_cmpt
  (p_validate                      in     boolean   default false
  ,p_effective_date                in     date
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_api_name                      in     varchar2  default null
  ,p_parent_component_name         in     varchar2  default null
  ,p_updateable                    in     varchar2  default null
  ,p_extensible                    in     varchar2  default null
  ,p_object_version_number            out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTION_TYPE_CMPT >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process updates a solution type component.
--
-- Prerequisites:
--   The Solution Type Component record identified by p_solution_type_name and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_effective_date               yes  date     Effective date
--   p_component_name               yes  varchar2 Name of the component
--   p_solution_type_name           yes  varchar2 Name of the solution type
--   p_legislation_code             yes  varchar2 Legislation Code
--   p_api_name                     no   varchar2 Name of the API to load this
--                                                component
--   p_parent_component_name        no   varchar2 Parent of component hierarchy
--   p_updateable                   no   varchar2 Flag to determine whether a
--                                                user can update this solution
--                                                type component.
--   p_updateable                   no   varchar2 Flag to determine whether a
--                                                user can extend this solution
--                                                type component.
--   p_object_version_number        yes  number   Object Version Number
--
--
--
-- Post Success:
--   The Solution Type Component record is updated and the API sets the
--   following out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false the
--                                           new version number is returned.
--                                           If p_validate is true then the
--                                           version number passed in is
--                                           returned.
--
-- Post Failure:
--   The API does not update a Solution Type Component and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_solution_type_cmpt
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_api_name                      in     varchar2  default hr_api.g_varchar2
  ,p_parent_component_name         in     varchar2  default hr_api.g_varchar2
  ,p_updateable                    in     varchar2  default hr_api.g_varchar2
  ,p_extensible                    in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTION_TYPE_CMPT >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process deletes a solution type component.
--
-- Prerequisites:
--   The Solution Type Component record identified by p_solution_type_name and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_component_name               yes  varchar2 Name of the component
--   p_solution_type_name           yes  number   Solution Type Component Name
--   p_legislation_code             yes  varchar2 Legislation Code
--   p_object_version_number        yes  number   Object Version Number
--
-- Post Success:
--   The Solution Type Component is deleted.
--
-- Post Failure:
--   The API does not delete a Solution Type Component and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_solution_type_cmpt
  (p_validate                      in     boolean  default false
  ,p_component_name                in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_legislation_code              in     varchar2
  ,p_object_version_number         in     number
  );
--
end per_solution_type_cmpt_api;

 

/
