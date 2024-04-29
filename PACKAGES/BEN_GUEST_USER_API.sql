--------------------------------------------------------
--  DDL for Package BEN_GUEST_USER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_GUEST_USER_API" AUTHID CURRENT_USER as
/* $Header: begstusr.pkh 120.0.12010000.2 2008/08/05 14:26:31 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< ben_guest_user_api >----------------------|
-- ---------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This procedure allows to login to oracle applications from web interface
-- without going through sign on web page.
-- Useful to customers who want to provide a link to access the applications
-- directly.
--
-- Prerequisites:
-- A Oracle applications user with user id as guest AND password as welcome
-- should be created if these parameters are not provided in the html
-- link. This defaulting allows customers to hide the userid and password
-- paramters.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--   rmode                          No   number   1 is JAVA_MODE, 2 is PLSQL_MODE
--   i_1                            No   varchar2 Applications Userid
--   i_2                            No   varchar2 Applications Password
--   home_url                       No   varchar2 Used to store in ICX_SESSIONS table.
--   i_direct                       No   varchar2 <Could not find any information>
--
procedure login(rmode       in     number  default 2,
               i_1         in     varchar2 ,
               i_2         in     varchar2 ,
               home_url    in     varchar2 default NULL,
               i_direct    IN     VARCHAR2 DEFAULT NULL);
end ben_guest_user_api;

/
