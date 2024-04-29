--------------------------------------------------------
--  DDL for Package GMS_PO_ADL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_PO_ADL_PKG" AUTHID CURRENT_USER AS
/* $Header: gmspoxas.pls 120.1 2005/07/26 14:38:23 appldev ship $ */


/*  Declare procedure update_adls.
	REQ_LINE_ID	IN	NUMBER ;
	ERR_CODE	IN OUT NOCOPY	VARCHAR2,
	ERR_MSG		IN OUT NOCOPY	VARCHAR2
*/
PROCEDURE UPDATE_ADLS(	p_req_line_id	IN 	NUMBER,
			err_code	IN OUT NOCOPY	VARCHAR2,
			err_msg		IN OUT NOCOPY	VARCHAR2 ) ;

END gms_po_adl_pkg;

 

/
