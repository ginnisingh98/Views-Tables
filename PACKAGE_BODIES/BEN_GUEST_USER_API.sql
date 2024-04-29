--------------------------------------------------------
--  DDL for Package Body BEN_GUEST_USER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_GUEST_USER_API" as
/* $Header: begstusr.pkb 120.1.12010000.2 2008/08/05 14:26:20 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_guest_user_api.';

procedure login(rmode      in     number  default 2,
               i_1         in     varchar2 ,
               i_2         in     varchar2 ,
               home_url    in     varchar2 default NULL,
               i_direct    in     VARCHAR2 DEFAULT NULL) is
begin
  --
  hr_utility.set_location('Entering ' || g_package, 10);
  --
  null; -- Blanked out call to Oraclemypage.home
  --
  hr_utility.set_location('Leaving ' || g_package, 90);
  --
exception
   when others then
        --
        -- 5555 Need to look at the code which calls oraclemypage.Home
        -- to see whether it sets the values.
        -- Need to uncommet following lines after checking whether it is required.
        -- icx_sec.g_validateSession_flag := true;

        hr_utility.set_location('Error ' || SQLERRM, 10);
        raise;

end Login;

end ben_guest_user_api;

/
