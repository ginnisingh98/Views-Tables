--------------------------------------------------------
--  DDL for Package HR_API_MODULE_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_MODULE_INTERNAL" AUTHID CURRENT_USER as
/* $Header: peamdbsi.pkh 115.0 99/07/17 18:29:46 porting ship $ */
--
--
-- ----------------------------------------------------------------
-- |---------------------< create_api_module >-------------------------|
-- ----------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates an entry on the table that lists the HRMS API Modules. The
--   table contains details of the business processes and row handlers.
--
--   There are two types of module that can currently be created; a Row Handler
--   (Module Type = 'RH') or a Business Process (Module Type = 'BP'). If the
--   module is a R.H. then the Module Name should contain the name of the
--   database table. If the module is a B.P. then the Module Name will contain
--   the name of the business process procedure. These two rules are NOT
--   enforced by the code, it is down to the caller to provide the correct
--   values.
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
--   The module package must be set if the module type is BP. If the module type
--   is RH then the module package must be RH.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                module is created in
--                                                the database.
--   p_api_module_type               Y   varchar2 The type of the module, either
--                                                'BP' for Business Process or
--                                                'RH' for Row Handler.
--   p_module_name                   Y   varchar2 Name of Module.
--   p_data_within_business_group    N   varchar2 Flag that indicates whether or
--                                                not there is data within the
--                                                business group. Set to Y or N.
--   p_legislation_code              N   varchar2 Legislation Code.
--   p_module_package                N   varchar2 Package name. Must be set if
--                                                Module Type is BP. Must be
--                                                NULL if Module type is RH.
--
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_api_module_id                number   Unique ID for the module
--                                           created by the API
--
-- Post Failure:
--   The API does not create the module and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_api_module
  (p_validate                      in     boolean  default false,
   p_effective_date                in     date,
   p_api_module_type               IN      varchar2,
   p_module_name                   IN      varchar2,
   p_data_within_business_group    IN      varchar2   default 'Y',
   p_legislation_code              IN      varchar2   default null,
   p_module_package                IN      varchar2   default null,
   p_api_module_id                 OUT     number);

-- ----------------------------------------------------------------
-- |---------------------< delete_api_module >-------------------------|
-- ----------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a row on the HR_API_MODULES table.
--
--   A module cannot be deleted if it is reference by a row in the HR_API_HOOKS.
--   Only HR core development can delete a row where LEGISLATION_CODE is null.
--   Only the legislation group which created the row where legislation code is
--   not null can delete the row.
--   These two checks are not enforced by code.
--
-- Prerequisites:
--   An existing API module.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                       N  boolean  If true, the database remains
--                                                unchanged. If false, the
--                                                module is deleted.
--
--   p_api_module_id                  Y  number   Unique ID for the module to be
--                                                deleted.
--
-- Post Success:
--   The API does not set any out parameters
--
-- Post Failure:
--   The API does not delete the module and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_api_module
  (p_validate                      in      boolean  default false,
   p_api_module_id                 in      number);
--
-- ----------------------------------------------------------------
-- |---------------------< update_api_module >--------------------|
-- ----------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This business process allows HR core Development team to update
--   existing API module information.
--
-- Prerequisites:
--   An existing API module.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                      N   boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--
--   p_api_module_id                 Y   number   Unique ID for the module
--                                                created by the API
--
--   p_module_name                   N   varchar2 Name of Module.
--
--   p_module_package                N   varchar2 Package name. Must be set if
--                                                Module Type is BP. Must be
--                                                NULL if Module type is RH.
--
-- Post Success:
--   The API sets no out parameters.
--
-- Post Failure:
--   The API does not update the module and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_api_module
  (p_validate                      in      boolean  default false,
   p_api_module_id                 in      number,
   p_module_name                   IN      varchar2 default hr_api.g_varchar2,
   p_module_package                IN      varchar2 default hr_api.g_varchar2,
   p_data_within_business_group    IN      varchar2 default hr_api.g_varchar2,
   p_effective_date                IN      date
  );

end hr_api_module_internal;

 

/
