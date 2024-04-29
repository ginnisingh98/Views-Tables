--------------------------------------------------------
--  DDL for Package HR_API_HOOK_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_HOOK_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peahkbsi.pkh 115.1 2002/12/03 16:28:52 apholt ship $ */
--
--
-- -------------------------------------------------------------------
-- |---------------------< create_api_hook >-------------------------|
-- -------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The HR_API_HOOKS table lists the points which are available in each API
--   module. It contains data sourced from the HR core Development team. If
--   legislation group/ partners and legislation vertical market groups
--   implement additional APIs which have user hooks they will also own rows
--   in the table. Each row is created using this procedure.
--
--   Each row should be a child of a parent API module which already exists on
--   the HR_API_MODULES table. The p_api_module_id acts as a foreign key to
--   this table.
--
--   The hook package and hook procedure parms are both mandatory. An API
--   developer should not create two different hook points which call the same
--   hook package. The combination of hook package and hook procedure should be
--   unique in HR_API_HOOKS.
--
--   The Legislation Code value should only be set if the API module contains at
--   least one user hook and will be maintained by a legislation group or a
--   legislation vertical market. Only the legislation group which created the
--   row where the Legislation Code is not null can update or delete the row.
--   A null value in Legislation Code indicates that the API module contains at
--   least one user hook, was implemented and is maintained by HR core
--   development. Only HR core development can maintain rows where Legislation
--   Code is Null. Again, these two rules are not enforced by code.
--
--   The Legislation Package defines the name of the database package to be
--   called to derive the legislation code. The legislation function is
--   contained within this package. The function must return the legislation
--   code and any parms it needs must be available in the hook package. This
--   function will only be called when legislation specific logic exists and
--   p_business_group_id is not a parm to the hook package procedure.
--   Legislation package and function must be both null or both not null. If
--   either of these two columns are populated then the other must also be
--   populated. Or both must contain blank values.
--
-- Prerequisites:
--   An API Module must have been created so that the Hook can be attached to
--   it.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                hook is created in
--                                                the database.
--   p_effective_date                Y   date     Effective date of the row.
--
--   p_api_module_id                 Y   number   The id of the parent API
--                                                module
--
--   p_api_hook_type                 Y   varchar2 The type of the hook. Should
--                                                be AI, AU or AD if the parent
--                                                module is a Row Handler.
--                                                Should be BP or AP if the
--                                                parent module is an API
--
--   p_hook_package                  Y   varchar2 Hook package name
--
--   p_hook_procedure                Y   varchar2 Hook Procedure name.
--
--   p_legislation_code              N   varchar2 Legislation Code.
--
--   p_legislation_package           N   varchar2 Holds the name of the database
--                                                package containing a function
--                                                to derive the legislation
--                                                code, when the legislation
--                                                specific logic exists and
--                                                p_business_group_id is not a
--                                                known parameter to the hook
--                                                package.
--
--   p_legislation_function          N   varchar2 Name of the function within
--                                                the legislation package to
--                                                call when the legislation
--                                                code needs to be known.
--
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_api_hook_id                  number   Unique ID for the hook
--                                           created by the API
--
-- Post Failure:
--   The API does not create the hook and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_api_hook
  (p_validate                     in     boolean  default false,
   p_effective_date               in date,
   p_api_module_id                in number,
   p_api_hook_type                in varchar2,
   p_hook_package                 in varchar2,
   p_hook_procedure               in varchar2,
   p_legislation_code             in varchar2         default null,
   p_legislation_package          in varchar2         default null,
   p_legislation_function         in varchar2         default null,
   p_api_hook_id                  OUT NOCOPY     number);
--
-- ----------------------------------------------------------------
-- |---------------------< delete_api_hook >-------------------------|
-- ----------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a row on the HR_API_HOOKS table.
--
--   A hook cannot be deleted if it is reference by a row in the
--   HR_API_HOOK_CALLS. Only HR core development can delete a row where
--   LEGISLATION_CODE is null. Only the legislation group which created the
--   row where legislation code is not not null can delete the row.
--   These two checks are not enforced by code.
--
-- Prerequisites:
--   An existing API hook.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                       N  boolean  If true, the database remains
--                                                unchanged. If false, the hook
--                                                is deleted.
--
--   p_api_hook_id                    Y  number   Unique ID for the hook to be
--                                                deleted.
--
-- Post Success:
--   The API does not set any out parameters
--
-- Post Failure:
--   The API does not delete the hook and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_api_hook
  (p_validate                      in      boolean  default false,
   p_api_hook_id                   in      number);
--
-- ----------------------------------------------------------------
-- |---------------------< update_api_hook >-------------------------|
-- ----------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process allows HR core Development team to update
--   existing API hook information.
--
-- Prerequisites:
--   An API Hook must have been created before it can be updated.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                hook is updated in the
--                                                database.
--   p_effective_date                Y   date     Effective date of the row.
--
--   p_api_hook_id                   Y   number   Unique ID for the hook
--                                                to be updated by the API
--
--   p_api_hook_type                 N   varchar2 The type of the hook. Should
--                                                be AI, AU or AD if the parent
--                                                module is a Row Handler.
--                                                Should be BP or AP if the
--                                                parent module is an API
--
--   p_hook_package                  N   varchar2 Hook package name
--
--   p_hook_procedure                N   varchar2 Hook Procedure name.
--
--   p_legislation_package           N   varchar2 Holds the name of the database
--                                                package containing a function
--                                                to derive the legislation
--                                                code, when the legislation
--                                                specific logic exists and
--                                                p_business_group_id is not a
--                                                known parameter to the hook
--                                                package.
--
--   p_legislation_function          N   varchar2 Name of the function within
--                                                the legislation package to
--                                                call when the legislation
--                                                code needs to be known.
--
-- Post Success:
--   The API sets no out parameters.
--
-- Post Failure:
--   The API does not update the hook and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_api_hook
  (p_validate                     in     boolean      default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_type                in     varchar2     default hr_api.g_varchar2,
   p_hook_package                 in     varchar2     default hr_api.g_varchar2,
   p_hook_procedure               in     varchar2     default hr_api.g_varchar2,
   p_legislation_package          in     varchar2     default hr_api.g_varchar2,
   p_legislation_function         in     varchar2     default hr_api.g_varchar2
  );
--
end hr_api_hook_internal;

 

/
