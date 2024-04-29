--------------------------------------------------------
--  DDL for Package PER_SOLUTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_API" AUTHID CURRENT_USER as
/* $Header: pesolapi.pkh 120.0 2005/05/31 21:19:52 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_SOLUTION >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process adds a new solution.
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
--   p_solution_name                yes  varchar2 Name of solution
--   p_description                  no   varchar2 Used on the summary page
--   p_link_to_full_description     no   varchar2 The name of the page where the
--                                                full description of the
--                                                solution is held
--   p_solution_type_name           yes  varchar2 FK to PER_SOLUTION_TYPES
--   p_vertical                     no   varchar2 Chosen from a lookup of type
--                                                PER_SOLUTION_VERTICALS
--   p_legislation_code             no   varchar2 Legislation Code
--   p_user_id                      no   varchar2 Used for user-defined
--                                                solutions only
--
--
--
-- Post Success:
--   When the solution is valid, the API sets the following out parameters.
--
--   Name                           Type     Description
--   p_solution_id                  number   If p_validate is false, this
--                                           uniquely identifies the Solution
--                                           created. If p_validate is true,
--                                           this parameter will be null.
--   p_object_version_number        number   If p_validate is false, this
--                                           will be set to the version number
--                                           of the Solution created. If
--                                           p_validate is true this parameter
--                                           will be set to null.
--
--
-- Post Failure:
--   The API does not create a Solution and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_solution
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_name                 in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_description                   in     varchar2   default null
  ,p_link_to_full_description      in     varchar2   default null
  ,p_vertical                      in     varchar2   default null
  ,p_legislation_code              in     varchar2   default null
  ,p_user_id                       in     varchar2   default null
  ,p_solution_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_SOLUTION >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process updates a solution.
--
-- Prerequisites:
--   The Solution record identified by p_solution_id and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_effective_date               yes  date     Effective date
--   p_solution_id                  yes  number   ID of solution
--   p_object_version_number        yes  number   Object Version Number
--   p_solution_name                yes  varchar2 Name of solution
--   p_description                  no   varchar2 Used on the summary page
--   p_link_to_full_description     no   varchar2 The name of the page where the
--                                                full description of the
--                                                solution is held
--   p_solution_type_name           yes  varchar2 FK to PER_SOLUTION_TYPES
--   p_vertical                     no   varchar2 Chosen from a lookup of type
--                                                PER_SOLUTION_VERTICALS
--   p_legislation_code             no   varchar2 Legislation Code
--   p_user_id                      no   varchar2 Used for user-defined
--                                                solutions only
--
--
--
-- Post Success:
--   The Solution record is updated and the API sets the following out
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
--   The API does not update a Solution and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_solution
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_id                   in     number
  ,p_solution_name                 in     varchar2
  ,p_solution_type_name            in     varchar2
  ,p_description                   in     varchar2   default hr_api.g_varchar2
  ,p_link_to_full_description      in     varchar2   default hr_api.g_varchar2
  ,p_vertical                      in     varchar2   default hr_api.g_varchar2
  ,p_legislation_code              in     varchar2   default hr_api.g_varchar2
  ,p_user_id                       in     varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_SOLUTION >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process deletes a solution.
--
-- Prerequisites:
--   The Solution record identified by p_solution_id and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_id                  yes  number   ID of solution
--   p_object_version_number        yes  number   Object Version Number
--
-- Post Success:
--   The Solution is deleted.
--
-- Post Failure:
--   The API does not delete a Solution and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_solution
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_object_version_number         in     number
  );
--
end per_solution_api;

 

/
