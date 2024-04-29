--------------------------------------------------------
--  DDL for Package CSL_CSP_REQ_HEADERS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSL_CSP_REQ_HEADERS_ACC_PKG" AUTHID CURRENT_USER AS
/* $Header: cslrhacs.pls 115.8 2002/11/08 14:01:50 asiegers ship $ */

FUNCTION Replicate_Record
  ( p_req_header_id NUMBER
  )
RETURN BOOLEAN;
/*** Function that checks if (shipment) location record should be replicated. Returns TRUE if it should ***/

PROCEDURE PRE_INSERT_REQ_HEADER ( x_return_status OUT NOCOPY varchar2);
/* Called before requirement header Insert */

PROCEDURE POST_INSERT_REQ_HEADER ( x_return_status OUT NOCOPY varchar2);
/* Called after requirement header Insert */

PROCEDURE PRE_UPDATE_REQ_HEADER ( x_return_status OUT NOCOPY varchar2);
/* Called before requirement header Update */

PROCEDURE POST_UPDATE_REQ_HEADER ( x_return_status OUT NOCOPY varchar2);
/* Called after requirement header Update */

PROCEDURE PRE_DELETE_REQ_HEADER ( x_return_status OUT NOCOPY varchar2);
/* Called before requirement header Delete */

PROCEDURE POST_DELETE_REQ_HEADER ( x_return_status OUT NOCOPY varchar2);
/* Called after requirement header Delete */

PROCEDURE Delete_All_ACC_Records ( p_resource_id in NUMBER, x_return_status OUT NOCOPY varchar2);
/* Remove all ACC resords of a mobile user */

PROCEDURE Insert_All_ACC_Records( p_resource_id in NUMBER, x_return_status OUT NOCOPY varchar2);
/* Full synch for a mobile user */

END CSL_CSP_REQ_HEADERS_ACC_PKG;

 

/
