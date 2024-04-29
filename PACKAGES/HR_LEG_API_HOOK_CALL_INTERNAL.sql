--------------------------------------------------------
--  DDL for Package HR_LEG_API_HOOK_CALL_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LEG_API_HOOK_CALL_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peahlbsi.pkh 115.1 2002/12/03 13:50:49 apholt ship $ */
--
--
-- ---------------------------------------------------------------------------
-- |---------------------< create_leg_api_hook_call >-------------------------|
-- ---------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process allows legislation groups to create hook call
--   information in the HR_API_HOOK_CALLS table. The hook call information
--   specifies which extra logic, package procedures or formula should be
--   called from the API hook points.
--
--   Each row should be a child of a parent API Hook which already exists on the
--   HR_API_HOOKS table. The p_api_hook_id acts as a foreign key to this table.
--
--   The legislation code value should always be set and indicates that the extra
--   logic should only be called for a hook call when data corresponds to the
--   legislation.
--
--   When more than one row exists for the same API_HOOK_ID, the SEQUENCE value
--   affects the order of the hook calls. Low numbers will be processed first.
--   Legislation specific calls must have a sequence between 1000 <= Sequence
--   <= 1999. Either 'before all' or 'after all' legislation specific calls.
--
--   All other parameters are described in detail below:
--
-- Prerequisites:
--   An API Hook must have been created so that the Hook Call can be attached to it.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--
--   p_effective_date                Y   date     Effective date.
--
--   p_api_hook_id                   Y   number   The id of the parent API Hook
--
--   p_api_hook_call_type            Y   varchar2 The type of the hook call. Can
--                                                only be set to 'PP' for the first
--                                                version.
--
--   p_legislation_code              Y   varchar2 Legislation Code for group.
--
--   p_sequence                      N   number   When more than one row exists for
--                                                the same API_HOOK_ID, Sequence
--                                                will affect the order of the hook
--                                                calls (low numbers processed first).
--
--   p_enabled_flag                  Y   varchar2 Takes a YES/NO value.
--
--   p_call_package                  Y   varchar2 Name of the database package that
--                                                the hook package should call.
--
--   p_call_procedure                Y   varchar2 Name of the procedure within the
--                                                CALL_PACKAGE that the hook package
--                                                should call. It should not be
--                                                possible to call the same package
--                                                procedure at the same hook more
--                                                then once.
--
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_api_hook_call_id             number   Unique ID for the hook call.
--
--   p_object_version_number        number   Version number of the new
--                                           hook call
-- Post Failure:
--   The API does not create the hook call and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_leg_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_id                  in     number,
   p_api_hook_call_type           in     varchar2,
   p_sequence                     in     number,
   p_enabled_flag                 in     varchar2  default 'Y',
   p_legislation_code             in     varchar2  default null,
   p_call_package                 in     varchar2  default null,
   p_call_procedure               in     varchar2  default null,
   p_api_hook_call_id             out nocopy    number,
   p_object_version_number        out nocopy    number
);
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_leg_api_hook_call >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API enables a Legislation Group to delete a row on the
--   HR_API_HOOK_CALLS table.
--
--   Only the legislation group which created the row where legislation
--   code is not not null can delete the row.
--
-- Prerequisites:
--   A valid api hook call id
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                       N  boolean  If true, the database remains
--                                                unchanged. If false, the hook is
--                                                deleted.
--
--   p_api_hook_call_id               Y  number   Unique ID for the hook call to be
--                                                deleted.
--
--   p_object_version_number          Y  number   Object Version Number of the
--                                                row to be deleted.
--
-- Post Success:
--   The API does not set any out parameters
--
-- Post Failure:
--   The API does not delete the hook call and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_leg_api_hook_call
  (p_validate                           in     boolean  default false,
   p_api_hook_call_id                   in     number,
   p_object_version_number              in     number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_leg_api_hook_call >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API enables a Legislation Group to update a row on the
--   HR_API_HOOK_CALLS table.
--
--   Only the legislation group which created the row where legislation
--   code is not null can update the row.
--
-- Prerequisites:
--   The row to be updated must exist on the table.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--
--   p_effective_date                Y   date     Effective date.
--
--   p_api_hook_call_id              Y   number   Unique ID for the hook call.
	--
--   p_sequence                      N   number   When more than one row exists for
--                                                the same API_HOOK_ID, Sequence
--                                                will affect the order of the hook
--                                                calls (low numbers processed first).
--
--   p_enabled_flag                  N   varchar2 Takes a YES/NO value.
--
--   p_call_package                  N   varchar2 Name of the database package that
--                                                the hook package should call.
--
--   p_call_procedure                N   varchar2 Name of the procedure within the
--                                                CALL_PACKAGE that the hook package
--                                                should call. It should not be
--                                                possible to call the same package
--                                                procedure at the same hook more
--                                                then once.
--
--
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   Version number of the updated hook call.
--
-- Post Failure:
--   The API does not update the hook call and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_leg_api_hook_call
  (p_validate                     in     boolean  default false,
   p_effective_date               in     date,
   p_api_hook_call_id             in     number,
   p_sequence                     in     number    default hr_api.g_number,
   p_enabled_flag                 in     varchar2  default hr_api.g_varchar2,
   p_call_package                 in     varchar2  default hr_api.g_varchar2,
   p_call_procedure               in     varchar2  default hr_api.g_varchar2,
   p_object_version_number        in out nocopy    number
  );
end hr_leg_api_hook_call_internal;

 

/