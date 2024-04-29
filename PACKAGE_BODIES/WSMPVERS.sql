--------------------------------------------------------
--  DDL for Package Body WSMPVERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPVERS" AS
/* $Header: WSMVERSB.pls 120.1 2005/06/29 03:37:05 mprathap noship $ */

function get_osfm_release_version RETURN VARCHAR2
IS
	/*******************************************************************/
	/*
	-- Initial Version of this file contains base release version 110500
	-- With each DISCRETE_MFG FAMILY PACK the version will correspond to
	-- that of the PKM Release such as 11.5.8.
	-- For example a return value of varchar2
	-- 	'110500' - Base Release - 11i
	--	'110506' - 11.5.6 - DiscMfgFamilyPack F
	--	'110507' - 11.5.7 - DiscMfgFamilyPack G
	--	'110508' - 11.5.8 - DiscMfgFamilyPack H
	--	'110509' - 11.5.9 - DiscMfgFamilyPack I
	--	etc...
	-- This file should be part of ONLY FAMILY PACKS and should not be
	-- part of any one-off patches or ARU, except pre-approved by OSFM
	-- Development Team.
	--
	-- How to use this Code Level Global in your code ?
	-- * Get the value of this global which denotes at which code level the customer is in.
	-- * Compare the version of this global to the version in which you release your code, to
	-- functionally control execution of your code.
	--
	--    Example:
	--      If your code is released in Pack H, then you would check
	-- if  WSMPVERS.get_osfm_release_version >= '110508' then
	--                <Your functionality>
	-- end if;
	--
	*/
	/*******************************************************************/

	--osfm_current_code_version Varchar2(10) := '110510'; -- DiscMfgFamily Pack J or 11.5.10
	osfm_current_code_version Varchar2(10) := '120000'; --Release 12

Begin
	Return osfm_current_code_version;
End get_osfm_release_version;

END WSMPVERS;

/
