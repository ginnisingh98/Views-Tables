--------------------------------------------------------
--  DDL for Package Body WF_EVENTS_APPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_EVENTS_APPS_PKG" as
/* $Header: WFEVTAPB.pls 120.1 2005/07/02 08:18:28 appldev noship $ */

-- This is called by the SSA Framework (wfehtmb.pls) only before calling any
-- table handlers

procedure setMode
is
 uname varchar2(320);
begin
 if WF_EVENTS_PKG.g_Mode is null then
	wfa_sec.GetSession(uname);
 end if;

 if uname = WF_EVENTS_PKG.g_SeedUser then
	WF_EVENTS_PKG.g_Mode := 'FORCE';
 else
	WF_EVENTS_PKG.g_Mode := 'CUSTOM';
 end if;

end setMode;

----------------------------------------------------------------------------
-- This is called by the OA Framework code before calling the table handlers

procedure FWKsetMode
is
 uname varchar2(320);
begin
 if WF_EVENTS_PKG.g_Mode is null then
	uname  := wfa_sec.GetFWKUserName;
 end if;

 if uname = WF_EVENTS_PKG.g_SeedUser then
	WF_EVENTS_PKG.g_Mode := 'FORCE';
 else
	WF_EVENTS_PKG.g_Mode := 'CUSTOM';
 end if;
end FWKsetMode;

end WF_EVENTS_APPS_PKG;

/
