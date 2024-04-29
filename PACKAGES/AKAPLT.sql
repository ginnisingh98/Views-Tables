--------------------------------------------------------
--  DDL for Package AKAPLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AKAPLT" AUTHID CURRENT_USER AS
/* $Header: akaplts.pls 115.2 99/07/17 15:17:40 porting s $ */

	TYPE applet_created_table is table of BOOLEAN index by binary_integer;
	g_applet_created	applet_created_table;
	g_current_instance	number	:= -99;

	procedure setAppletCreated( p_created	in boolean,
								p_instance	in number);

	function getInstanceCount	return number;
	function getFirstInstance	return number;
	function getNextInstance	return number;

END AKAPLT;

 

/
