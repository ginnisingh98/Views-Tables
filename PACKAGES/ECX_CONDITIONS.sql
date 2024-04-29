--------------------------------------------------------
--  DDL for Package ECX_CONDITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_CONDITIONS" AUTHID CURRENT_USER as
-- $Header: ECXCONDS.pls 120.4 2005/10/30 23:24:48 susaha ship $
/** Check for following conditions =,!=,>,<,>=,<=,null,not null
condition type will be passed as condition and the condition variable on which the condition needs to be evaluated
**/
function check_type_condition
	(
	type            in      varchar2,
	variable        in      varchar2,
	vartype		in	pls_integer,
	value           in      varchar2,
	valtype		in	pls_integer
	) return boolean;

function check_condition
	(
	type            in      varchar2,  -- AND,OR
	type1           in      varchar2, --- =,!=,>,<,>=,<=,null,not null
	variable1       in      varchar2,
	vartype1	in	pls_integer,
	value1          in      varchar2,
	valtype1	in	pls_integer,
	type2           in      varchar2,
	variable2       in      varchar2,
	vartype2	in	pls_integer,
	value2          in      varchar2,
	valtype2	in	pls_integer
	) return boolean;

function math_functions
	(
	type    in      varchar2,
	x       in      number,
	y       in      number
	)
	return number;
procedure getLengthForString
	(
	i_string	in	varchar2,
	i_length	OUT	NOCOPY pls_integer
	);
procedure getPositionInString
	(
	i_string		in	varchar2,
	i_search_string		in	varchar2,
	i_start_position	in	pls_integer default null,
	i_occurrence		in	pls_integer default null,
	i_position		OUT	NOCOPY pls_integer
	);
procedure getSubString
	(
	i_string                in      varchar2,
	i_start_position        in      pls_integer default 0,
	i_length                in      pls_integer default 0,
	i_substr                OUT     NOCOPY varchar2
	);

procedure test;

end ecx_conditions;

 

/
