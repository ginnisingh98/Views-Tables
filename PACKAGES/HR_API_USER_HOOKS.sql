--------------------------------------------------------
--  DDL for Package HR_API_USER_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_API_USER_HOOKS" AUTHID CURRENT_USER as
/* $Header: hrusrhok.pkh 115.1 2002/12/05 18:00:18 apholt ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_package_body >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure creates one API user hook package body.
--
-- Prerequisites:
--   The hook package name provide must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hook_package                 Yes  varchar2 Name of a hook package.
--
-- Post success:
--   A hook package body is created in the database.
--
-- Post Failure:
--   This procedure does not create any package bodies. Applications errors
--   are written to the HR_API_HOOKS and HR_API_HOOK_CALLS tables. For most
--   application errors this procedure will end normally without a PL/SQL
--   exception being raised.
--
--   Unexpected Oracle errors and serious application errors will be raised
--   as a PL/SQL exception. When these errors are raised this procedure will
--   abort the processing.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_package_body
  (p_hook_package                  in     varchar2
  );
end hr_api_user_hooks;

 

/
