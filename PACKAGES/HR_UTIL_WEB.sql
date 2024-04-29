--------------------------------------------------------
--  DDL for Package HR_UTIL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UTIL_WEB" AUTHID CURRENT_USER as
/* $Header: hrutlweb.pkh 120.1.12000000.1 2007/01/21 19:19:33 appldev ship $ */
--
-- We don't normally need to specify the host and agent since netscape
-- will work with relative paths.  The one place where it's needed is in
-- workflow when launching html from email attachments.  Then the host
-- and agent are not set up for you.  Use hr_offer_custom.g_owa2 in these
-- cases.
--
  g_owa                varchar2(2000)  := null;

  TYPE g_varchar2_tab_type IS TABLE OF varchar2(2000) INDEX BY BINARY_INTEGER;
  -- Use this when the routine raising the error has completely handled
  -- the situation.
  g_error_handled exception;
--
-- Default Varchar2 PL/SQL Table
--
--
-- ------------------------------------------------------------------------
-- |---------------------< prepare_parameter >-----------------------------|
-- ------------------------------------------------------------------------
--
-- Description:
--   This procedure takes in a parameter and makes it URL ready by changing
--   spaces to '+' and placing a '&' at the front of the parmameter name
--   when p_prefix is true (the parameter is not first in the list).
--
-- Pre Conditions:
--
-- In Arguments:
--    Name        Reqd  Type        Description
--    p_name      Yes   varchar2    Parameter name
--    p_value     Yes   varchar2    Parameter value
--    p_prefix    No    boolean     Set to false if the paramenter is the
--                                  first parm to be used in the URL.  If
--                                  p_prefix is true, an '&' will be placed
--                                  at the front of the parm.
--
-- Post Success:
--   Returns the parameter in a varchar2.
--
-- Post Failure:
--   This procedure should never fail.
--
-- Developer Implementation Notes:
--
-- Access Status:
--
-- -----------------------------------------------------------------------------
function prepare_parameter
           (p_name   in varchar2
           ,p_value  in varchar2
           ,p_prefix in boolean default true) return varchar2;


-- -------------------------------------------------------------------------
-- |---------------------------< proxyforURL >-----------------------------|
-- -------------------------------------------------------------------------
-- Returns the possibly null proxy string based on configuration stored
-- in profile options
--
function proxyforURL(p_url in varchar2) return varchar2 ;
end hr_util_web;

 

/
