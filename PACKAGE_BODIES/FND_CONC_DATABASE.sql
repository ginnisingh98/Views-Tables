--------------------------------------------------------
--  DDL for Package Body FND_CONC_DATABASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_DATABASE" as
/* $Header: AFCPDBMB.pls 115.1 2003/10/24 18:12:34 nkagrawa noship $ */

/*
 * Function: register_database
 *
 * Purpose: To register a database.
 *
 * Arguments:
 *
 */

/* **************************************************************************************************************************** */
function register_database(database_name    in varchar2,
			   database_domain  in varchar2,
			   two_task         in varchar2,
			   host_name        in varchar2,
			   port_no          in number)
return boolean
is
begin
	return TRUE;
end;
/* **************************************************************************************************************************** */

/* **************************************************************************************************************************** */
function  register_instance(database_name in varchar2,
                            inst_name     in varchar2,
                            inst_num      in number,
                            task	      in varchar2,
                            host_name     in varchar2,
                            port_no       in number,
                            sid_name      in varchar2,
                            config        in varchar2,
                            descrip       in varchar2)
return boolean
is
begin
		return TRUE;
end;
/* **************************************************************************************************************************** */

/* **************************************************************************************************************************** */
function  assign_database(database_name   in varchar2,
                          assign          in varchar2)
return boolean
is
begin
	return TRUE;
end;
/* **************************************************************************************************************************** */

end fnd_conc_database;

/
