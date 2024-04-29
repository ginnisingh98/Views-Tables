--------------------------------------------------------
--  DDL for Package IEM_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_MIGRATE" AUTHID CURRENT_USER as
/* $Header: iemmigrs.pls 115.1 2002/12/04 19:49:13 sboorela shipped $ */

PROCEDURE START_PROCESS(
		   p_api_version_number in number,
 		   p_init_msg_list  IN   VARCHAR2 ,
	    	   p_commit	    IN   VARCHAR2 ,
		   x_return_status	OUT NOCOPY varchar2
			 	) ;
end IEM_MIGRATE;

 

/
