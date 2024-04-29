--------------------------------------------------------
--  DDL for Package GML_PO_CON_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_PO_CON_REQ" AUTHID CURRENT_USER AS
/* $Header: GMLPORCS.pls 115.3 99/10/29 14:18:22 porting ship $ */

  PROCEDURE fire_request;

  PROCEDURE po_resub (errbuf  out varchar2,
 				retcode out number,
 				v_from_date IN OUT VARCHAR2,
 				v_to_date IN OUT VARCHAR2,
 				v_po_no IN VARCHAR2  default null);
/*Commented by Preetam B as we no longer use it. To solve the invalid objects
problem*/
/*  PROCEDURE recv_resub (errbuf  out varchar2,
 				retcode out number,
 				v_po_no IN VARCHAR2);*/

END GML_PO_CON_REQ;

 

/
