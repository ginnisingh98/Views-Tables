--------------------------------------------------------
--  DDL for Package PER_SOLUTIONS_SELECTED_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SOLUTIONS_SELECTED_API" AUTHID CURRENT_USER as
/* $Header: pesosapi.pkh 120.0 2005/05/31 21:24:05 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------< CREATE_SOLUTIONS_SELECTED >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process adds a new selected solution record.
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
--   p_solution_id                  yes  number   ID of the solution selected
--   p_solution_set_name            yes  varchar2 Solution set into which the
--                                                solution has been selected
--   p_user_id                      yes  number   User Id of solution selected
--
--
-- Post Success:
--   When the selected solution is valid, the API sets the following out
--   parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, this
--                                           will be set to the version number
--                                           of the Selected Solution created.
--                                           If p_validate is true this
--                                           parameter will be set to null.
--
--
-- Post Failure:
--   The API does not create a Selected Solution and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_solutions_selected
  (p_validate                      in     boolean   default false
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number            out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< UPDATE_SOLUTIONS_SELECTED >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process updates a solution type.
--
-- Prerequisites:
--   The Selected Solution record must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_id                  yes  number   ID of the solution selected
--   p_solution_set_name            yes  varchar2 Solution set into which the
--                                                solution has been selected
--   p_user_id                      yes  number   User Id of solution selected
--   p_object_version_number        yes  number   Object Version Number
--
--
--
-- Post Success:
--   The Selected Solution record is updated and the API sets the following out
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
--   The API does not update a Selected Solution and raises an error.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_solutions_selected
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in out nocopy number
  );

-- ----------------------------------------------------------------------------
-- |--------------------< DELETE_SOLUTIONS_SELECTED >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process deletes a selected solution.
--
-- Prerequisites:
--   The Selected Solution record must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes  Boolean  If true, the database remains
--                                                unchanged. If false the
--                                                assignment is updated in
--                                                the database.
--   p_solution_id                  yes  number   ID of the solution selected
--   p_solution_set_name            yes  varchar2 Solution set into which the
--                                                solution has been selected
--   p_user_id                      yes  number   User Id of solution selected
--   p_object_version_number        yes  number   Object Version Number
--
-- Post Success:
--   The Selected Solution is deleted.
--
-- Post Failure:
--   The API does not delete a Selected Solution and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_solutions_selected
  (p_validate                      in     boolean  default false
  ,p_solution_id                   in     number
  ,p_solution_set_name             in     varchar2
  ,p_user_id                       in     number
  ,p_object_version_number         in     number
  );
--
end per_solutions_selected_api;

 

/
