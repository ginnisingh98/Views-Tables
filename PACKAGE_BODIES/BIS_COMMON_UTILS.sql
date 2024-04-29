--------------------------------------------------------
--  DDL for Package Body BIS_COMMON_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_COMMON_UTILS" AS
  /* $Header: BISCUTLB.pls 115.0 2004/01/08 03:23:58 mdamle noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISCUTLS.pls
---
---  DESCRIPTION
---     Package Body File for common (Non-Product) specific utility functions
---
---  NOTES
---
---  HISTORY
---
---  25-Dec-2003 mdamle     Created
---===========================================================================

function replaceParameterValue(
 p_param_string	IN VARCHAR2
,p_key		IN VARCHAR2
,p_new_value	IN VARCHAR2) return VARCHAR2 is

l_key_posn	NUMBER;
l_equalTo_posn	NUMBER;
l_amp_posn	NUMBER;
l_new_string	VARCHAR2(2000) := NULL;
begin

	l_new_string := p_param_string;
	if (p_param_string is not null and p_key is not null) then
		l_key_posn := instr(p_param_string, p_key);
		if (l_key_posn > 0) then
			l_equalTo_posn := instr(p_param_string, '=', l_key_posn);
			l_amp_posn  := instr(p_param_string, '&', l_key_posn);
			l_new_string := substr(p_param_string, 1, l_equalTo_Posn) || p_new_value;
			if (l_amp_posn > 0) then
				l_new_string := l_new_string || substr(p_param_string, l_amp_posn);
			end if;
		else
			l_new_string := p_param_string || '&' || p_key || '=' || p_new_value;
		end if;
	end if;

	return l_new_string;

EXCEPTION
	when others then return null;
end replaceParameterValue;

function getParameterValue(
 p_param_string	IN VARCHAR2
,p_key		IN VARCHAR2) return VARCHAR2 is

l_key_posn	NUMBER;
l_equalTo_posn	NUMBER;
l_amp_posn	NUMBER;
l_value		VARCHAR2(2000) := NULL;
begin
	if (p_param_string is not null and p_key is not null) then
		l_key_posn := instr(p_param_string, p_key);

		if (l_key_posn > 0) then
			l_equalTo_posn := instr(p_param_string, '=', l_key_posn);
			l_amp_posn  := instr(p_param_string, '&', l_key_posn);

			if (l_amp_posn > 0) then
				l_value := substr(p_param_string, l_equalto_posn+1, l_amp_posn-1-l_equalto_posn);
			else
				l_value := substr(p_param_string, l_equalto_posn+1);
			end if;
		end if;
	end if;

	return l_value;

EXCEPTION
	when others then return null;
end getParameterValue;


end BIS_COMMON_UTILS;

/
