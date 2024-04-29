--------------------------------------------------------
--  DDL for Package UMX_USER_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_USER_SEARCH_PVT" AUTHID CURRENT_USER AS
/* $Header: UMXUSRSS.pls 115.2 2003/12/17 00:10:04 cmehta noship $ */

	FUNCTION canResetPassword( 	userName IN varchar2 default null,
								funcName in varchar2,
								object_name varchar2,
								obj_pk_val varchar2 )
     RETURN  varchar2;

	FUNCTION getAccountStatus( 	p_user_id IN varchar2,
								p_start_date IN date,
								p_end_date IN date )
     RETURN  varchar2;

FUNCTION getAccountStatusCode( 	p_user_id IN varchar2,
								p_start_date IN date,
								p_end_date IN date )
     RETURN  varchar2;

end UMX_USER_SEARCH_PVT;

 

/
