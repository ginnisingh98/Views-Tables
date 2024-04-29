--------------------------------------------------------
--  DDL for Package ZX_TDS_REVERSE_DOCUMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_REVERSE_DOCUMENT_PKG" AUTHID CURRENT_USER AS
 /* $Header: zxdirevdocmtpkgs.pls 120.2 2004/06/07 18:22:19 pla ship $ */

PROCEDURE reverse_document (
 p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
 x_return_status   OUT NOCOPY 	 VARCHAR2 );


END ZX_TDS_REVERSE_DOCUMENT_PKG;

 

/
