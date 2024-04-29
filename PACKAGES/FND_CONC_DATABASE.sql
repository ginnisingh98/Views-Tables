--------------------------------------------------------
--  DDL for Package FND_CONC_DATABASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_DATABASE" AUTHID CURRENT_USER as
/* $Header: AFCPDBMS.pls 115.0 2003/03/05 05:03:49 vvengala noship $ */

/*
 * Procedure: register_database
 *
 * Purpose: To register database information in fnd_database table.
 *
 * Arguments:
 *
 */
function register_database(database_name    in varchar2,
			   database_domain  in varchar2,
			   two_task         in varchar2,
			   host_name        in varchar2,
			   port_no          in number)
return boolean;

/*
 * Procedure: register_instance
 *
 * Purpose: To register database instance information in
 *          fnd_database_instance table.
 *
 * Arguments:
 *
 */
function  register_instance(database_name in varchar2,
			    inst_name     in varchar2,
			    inst_num      in number,
			    task          in varchar2,
			    host_name	  in varchar2,
			    port_no 	  in number,
			    sid_name	  in varchar2,
			    config        in varchar2,
			    descrip       in varchar2)
return boolean;

function  assign_database(database_name   in varchar2,
			  assign          in varchar2)
return boolean;

end;

 

/
