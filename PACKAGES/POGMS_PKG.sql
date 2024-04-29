--------------------------------------------------------
--  DDL for Package POGMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POGMS_PKG" AUTHID CURRENT_USER AS
/* $Header: poxgms1s.pls 115.2 2002/11/23 00:02:18 sbull noship $ */


/*  Declare procedure update_adls.
	REQ_LINE_ID	IN	NUMBER ;
	ERR_CODE	IN OUT	varchar2,
	ERR_MSG		IN OUT	varchar2
*/
PROCEDURE UPDATE_ADLS(	p_req_line_id	IN 	NUMBER,
			err_code	IN OUT	NOCOPY varchar2,
			err_msg		IN OUT	NOCOPY varchar2 ) ;

END POGMS_PKG;

 

/
