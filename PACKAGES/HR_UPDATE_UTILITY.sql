--------------------------------------------------------
--  DDL for Package HR_UPDATE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UPDATE_UTILITY" AUTHID CURRENT_USER AS
/* $Header: hruptutil.pkh 115.5 2004/04/05 02:57:51 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |----------------------------< submitRequest >-----------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure submits a concurrent request from within a patch.  The
--   request will be processed when the concurrent managers restart after
--   completion of the apps-wide downtime window.
--
--   The package function identified by the p_validate_function parameter is
--   called to determine whether there is any data to be updated.  If no data
--   is present for update then the called function should return FALSE and the
--   concurrent request is not submitted.  If data is present for update then
--   the function should return TRUE and the concurrent request will be
--   submitted.
--
-- Prerequisites
--
-- Parameters:
--   Name                           Reqd Type     Description
--   p_app_shortname                  Y  Varchar2 The shortname of the app that
--                                                owns the request being
--                                                submitted.
--   p_update_name                    Y  Varchar2 The name of the update to be
--                                                processed.
--   p_validate_proc                  Y  Varchar2 The name of a procedure called
--                                                to determine whether the
--                                                update being submitted is
--                                                required.
--   p_business_group_Id              N  Number   Business group ID
--   p_legislation_code               N  Varchar2 Legislation code for BG
--                                                specified
--   p_argument1..10                  N  Varchar2 Optional parameters to pass
--                                                to conc request.
--
procedure submitRequest
   (p_app_shortname      in     varchar2
   ,p_update_name        in     varchar2
   ,p_validate_proc      in     varchar2
   ,p_business_group_id  in     number   default null
   ,p_legislation_code   in     varchar2 default null
   ,p_argument1          in     varchar2 default chr(0)
   ,p_argument2          in     varchar2 default chr(0)
   ,p_argument3          in     varchar2 default chr(0)
   ,p_argument4          in     varchar2 default chr(0)
   ,p_argument5          in     varchar2 default chr(0)
   ,p_argument6          in     varchar2 default chr(0)
   ,p_argument7          in     varchar2 default chr(0)
   ,p_argument8          in     varchar2 default chr(0)
   ,p_argument9          in     varchar2 default chr(0)
   ,p_argument10         in     varchar2 default chr(0)
   ,p_request_id            out nocopy number);


-- ----------------------------------------------------------------------------
-- |--------------------------< isUpdateComplete >----------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This function can be called from a function(Form, web-page or conc
--   request) to determine whether the update it is dependent upon has
--   completed successfully.  If the named upgrade has completed then TRUE
--   is returned otherwise FALSE is returned.
--
--   This function utilises the PAY_UPGRADE_DEFINITIONS and PAY_UPGRADE_STATUS
--
--
-- Prerequisites
--
-- Parameters:
--   Name                           Reqd Type     Description
--   p_app_shortname                  Y  Varchar2 The shortname of the app
--   p_function_name                  Y  Varchar2 The name of the function.
--   p_business_group_id              Y  Number   The ID if the sessions BG.
--   p_update_name                    Y  Varchar2 The name of the update which
--                                                this function is dependent
--                                                upon.
--
function isUpdateComplete
   (p_app_shortname      varchar2
   ,p_function_name      varchar2
   ,p_business_group_id  number
   ,p_update_name        varchar2) return varchar2;

-- ----------------------------------------------------------------------------
-- |---------------------------< setUpdateComplete >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure can be called from the end of an update job
--   to set the status of the Job to "Complete" in the PAY_UPGRADE_STATUS
--   table.  This should be the final step of the upgrade process.
--
-- Prerequisites
--
-- Parameters:
--   Name                           Reqd Type     Description
--   p_update_name                    Y  Varchar2 The name of the update.
--   p_business_group_id              N  Number   Business group id.
--   p_legislation_code               N  Number   Legislation code.
--
procedure setUpdateComplete
   (p_update_name        varchar2,
    p_business_group_id  number default null,
    p_legislation_code   varchar2 default null) ;

-- ----------------------------------------------------------------------------
-- |---------------------------< setUpdateProcessing >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure can be called from the start of an update job
--   to set the status of the Job to "Processing" in the PAY_UPGRADE_STATUS
--   table.  This should be the first step of the upgrade process.
--
-- Prerequisites
--
-- Parameters:
--   Name                           Reqd Type     Description
--   p_update_name                    Y  Varchar2 The name of the update.
--   p_business_group_id              N  Number   Business group id.
--   p_legislation_code               N  Number   Legislation code.
--
procedure setUpdateProcessing
   (p_update_name        varchar2,
    p_business_group_id  number default null,
    p_legislation_code   varchar2 default null) ;


end hr_update_utility;

 

/
