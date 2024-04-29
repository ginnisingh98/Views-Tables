--------------------------------------------------------
--  DDL for Package PER_SOLUTION_SET_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTION_SET_API" AUTHID CURRENT_USER as
/* $Header: peslsapi.pkh 120.0 2005/05/31 21:12:33 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_SOLUTION_SET >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process adds a new solution set.
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
--   p_solution_set_name            yes  varchar2 Name of the solution set
--   p_user_id                      yes  number   ID of the owner of the
--                                                solution set
--   p_description                  no   varchar2 Description of the solution
--                                                set
--   p_status                       no   varchar2 Whether a solution set has
--                                                been completed or implemented
--   p_solution_set_impl_id         no   number   Refers to config_hdr_id column
--                                                in az_files table which is a
--                                                sequence number cz_config_hdrs_s.
--
--
-- Post Success:
--   When the solution type is valid, the API sets the following out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, this
--                                           will be set to the version number
--                                           of the Solution Set created. If
--                                           p_validate is true this parameter
--                                           will be set to null.
--
--
-- Post Failure:
--   The API does not create a Solution Set and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_solution_set
  (p_validate                      in     boolean   default false
  ,p_effective_date                in     date
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_description                   in     varchar2  default null
  ,p_status                        in     varchar2  default null
  ,p_solution_set_impl_id          in     number    default hr_api.g_number
  ,p_object_version_number            out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |------------------------< UPDATE_SOLUTION_SET >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process updates a solution type.
--
-- Prerequisites:
--   The Solution Set record identified by p_solution_type_name and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_effective_date               yes  date     Effective date
--   p_solution_set_name            yes  varchar2 Name of the solution set
--   p_user_id                      yes  number   ID of the owner of the
--                                                solution set
--   p_description                  no   varchar2 Description of the solution
--                                                set
--   p_status                       no   varchar2 Whether a solution set has
--                                                been completed or implemented
--   p_object_version_number        yes  number   Object Version Number
--   p_solution_set_impl_id         no   number   Refers to config_hdr_id column
--                                                in az_files table which is a
--                                                sequence number cz_config_hdrs_s.
--
--
--
-- Post Success:
--   The Solution Set record is updated and the API sets the following out
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
--   The API does not update a Solution Set and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_solution_set
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_solution_set_impl_id          in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |------------------------< DELETE_SOLUTION_SET >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process deletes a solution set.
--
-- Prerequisites:
--   The Solution Set record identified by p_solution_type_name and
--   p_object_version_number must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_set_name            yes  varchar2 Name of the solution set
--   p_user_id                      yes  number   ID of the owner of the
--                                                solution set
--   p_object_version_number        yes  number   Object Version Number
--
-- Post Success:
--   The Solution Set is deleted.
--
-- Post Failure:
--   The API does not delete a Solution Set and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_solution_set
  (p_validate                      in     boolean  default false
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in     number
  );
--
end per_solution_set_api;

 

/
