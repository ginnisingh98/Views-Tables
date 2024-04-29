--------------------------------------------------------
--  DDL for Package Body AKAPLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AKAPLT" AS
/* $Header: akapltb.pls 115.2 99/07/17 15:17:34 porting s $ */

	procedure setAppletCreated (	p_created	in boolean,
									p_instance	in number) is
	begin
		g_applet_created(p_instance) := p_created;
	end setAppletCreated;

	function getInstanceCount	return number is
	begin
		return g_applet_created.COUNT;
	end getInstanceCount;

	function getFirstInstance	return number is
		instance_count	number;
		instance		number;
	begin
		instance_count := g_applet_created.COUNT;
		if (instance_count >= 1) then
			for i in g_applet_created.FIRST .. g_applet_created.LAST loop
				if g_applet_created(i) then
					g_current_instance := i;
					return i;
				end if;
			end loop;
		end if;
		return -99;
	end getFirstInstance;

	function getNextInstance	return number is
	begin
		if (g_current_instance = -99) then
			return g_current_instance;
		end if;

		for i in (g_current_instance+1) .. g_applet_created.LAST loop
			if g_applet_created(i) then
				g_current_instance := i;
				return i;
			end if;
		end loop;

		return -99;

	end getNextInstance;

END AKAPLT;

/
