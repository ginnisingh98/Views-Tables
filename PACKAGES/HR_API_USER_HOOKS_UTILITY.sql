--------------------------------------------------------
--  DDL for Package HR_API_USER_HOOKS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_USER_HOOKS_UTILITY" AUTHID CURRENT_USER as
/* $Header: hrusrutl.pkh 115.2 2002/12/05 18:05:06 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< write_hook_parameter_list >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure builds a list of parameters value available at each API
--   user hook. The output is written to the HR_API_USER_HOOK_REPORTS table.
--
-- Prerequisites:
--   There are no rows in the HR_API_USER_HOOK_REPORTS which match the
--   current database session SESSION_ID.
--
-- In Parameters:
--   None
--
-- Post success:
--   Details of the parameter list are written to HR_API_USER_HOOK_REPORTS.
--
-- Post Failure:
--   An error is raised and no rows are written to HR_API_USER_HOOK_REPORTS.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure write_hook_parameter_list;
--
-- ----------------------------------------------------------------------------
-- |------------------------< write_all_errors_report >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure builds an error list report for all API modules where
--   user hooks are available. The output is written to the
--   HR_API_USER_HOOK_REPORTS table.
--
-- Prerequisites:
--   There are no rows in the HR_API_USER_HOOK_REPORTS which match the
--   current database session SESSION_ID.
--
-- In Parameters:
--   None
--
-- Post success:
--   Details of any errors are written to HR_API_USER_HOOK_REPORTS.
--
-- Post Failure:
--   An error is raised and no details are written to HR_API_USER_HOOK_REPORTS.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure write_all_errors_report;
--
-- ----------------------------------------------------------------------------
-- |------------------------< write_one_errors_report >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure builds an error list report for one API module. The output
--   is written to the HR_API_USER_HOOK_REPORTS table.
--
-- Prerequisites:
--   The API module must be defined in the HR_API_MODULES table.
--   The API module is not an alternative interface.
--
--   There are no rows in the HR_API_USER_HOOK_REPORTS which match the
--   current database session SESSION_ID.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_module_id                Yes  Number   ID of API module
--
-- Post success:
--   Details of any errors are written to HR_API_USER_HOOK_REPORTS.
--
--   If no API module exists with the p_api_module_id ID, or the API
--   module is an alternative interface then no details are written
--   to HR_API_USER_HOOK_REPORTS and no error is raised.
--
-- Post Failure:
--   An Oracle error error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure write_one_errors_report
  (p_api_module_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< clear_hook_report >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure deleted all the rows from HR_API_USER_HOOK_REPORTS
--   which match this database session SESSION_ID. Rows for database sessions
--   which no longer exist are also deleted.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   None
--
-- Post success:
--   Rows in HR_API_USER_HOOK_REPORTS which match this database session
--   SESSION_ID are removed. This procedure does issue a commit.
--
-- Post Failure:
--   An error is raised and no HR_API_USER_HOOK_REPORTS are deleted.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure clear_hook_report;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hooks_all_modules >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will create the hook package body source code for all
--   the API modules which have been defined in the HR_API_MODULES table.
--   Alternative Interface API modules are not processed as they do not
--   contain user hooks.
--   This procedure can be called in a number of scenarios.
--     1) During install of core product code.
--     2) During install of legislation specific code.
--     3) After a customer has defined extra hook logic.
--
-- Prerequisites:
--   In all scenarios this procedure should be executed after the
--   corresponding package headers, package bodies have been installed in
--   the database. The package code should have a status of 'VALID'.
--   The corresponding seed data for the HR_API_MODULES, HR_API_HOOKS and
--   HR_API_HOOK_CALLS tables should have been installed.
--
--   This procedure should only be called from sql scripts as it issues
--   many commit statements.
--
-- In Parameters:
--   None
--
-- Post success:
--   Hook package body source code will be created directly in the database.
--   Details of any application errors will be written to the HR_API_HOOKS
--   and HR_API_HOOK_CALLS tables.
--
-- Post Failure:
--   An error is raised and the remainder of the hook package bodies will
--   not be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_hooks_all_modules;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hooks_one_module >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will create the hook package body source code for one
--   API module.
--
-- Prerequisites:
--   The API module must be defined in the HR_API_MODULES table and must
--   not be an alternative interface module.
--
--   This procedure should be executed after the corresponding hook and call
--   package headers, package bodies have been installed in the database.
--   The package code should have a status of 'VALID'. The corresponding seed
--   data for the HR_API_MODULES, HR_API_HOOKS and HR_API_HOOK_CALLS tables
--   should have been installed.
--
--   This procedure should only be called from sql scripts as it issues
--   commit statements.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_module_id                Yes  Number   ID of API module
--
-- Post success:
--   Hook package body source code will be created directly in the database.
--   Details of any application errors will be written to the HR_API_HOOKS
--   and HR_API_HOOK_CALLS tables.
--
--   If no API module exists with the p_api_module_id ID then no package body
--   source code is created and no error is raised.
--
-- Post Failure:
--   An error is raised and the remainder of the hook package bodies will
--   not be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_hooks_one_module
  (p_api_module_id                 in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_hooks_add_report >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will create the hook package body source code for one
--   API module and will then add details of the generation to the hook
--   report table.
--
--   This procedure provides is a cover to calling create_hooks_one_module
--   and write_one_errors_report separately. It has been designed to be
--   executed from *rsd.sql and *asd.sql scripts.
--
-- Prerequisites:
--   The API module must be defined in the HR_API_MODULES table and must
--   not be an alternative interface module.
--
--   This procedure should be executed after the corresponding hook and call
--   package headers, package bodies have been installed in the database.
--   The package code should have a status of 'VALID'. The corresponding seed
--   data for the HR_API_MODULES, HR_API_HOOKS and HR_API_HOOK_CALLS tables
--   should have been installed.
--
--   This procedure should only be called from sql scripts as it issues
--   commit statements.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_api_module_id                Yes  Number   ID of API module
--
-- Post success:
--   Hook package body source code will be created directly in the database.
--   Details of any application errors will be written to the HR_API_HOOKS
--   and HR_API_HOOK_CALLS tables.
--
--   Details of the source code generation will be written to the
--   HR_API_USER_HOOK_REPORTS table.
--
--   If no API module exists with the p_api_module_id ID then no package body
--   source code is created and no error is raised.
--
-- Post Failure:
--   An error is raised and the remainder of the hook package bodies will
--   not be created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_hooks_add_report
  (p_api_module_id                 in     number
  );
--
end hr_api_user_hooks_utility;

 

/