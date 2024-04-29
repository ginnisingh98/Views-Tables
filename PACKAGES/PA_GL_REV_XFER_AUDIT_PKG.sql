--------------------------------------------------------
--  DDL for Package PA_GL_REV_XFER_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GL_REV_XFER_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: PAGLXARS.pls 120.1 2005/06/08 21:56:03 rgandhi noship $ */
PROCEDURE process(x_where_cc			IN	VARCHAR2,
		  x_gl_date_where_clause	IN	VARCHAR2,
		 -- x_je_batch_name		IN	VARCHAR2,
		  x_from_date			IN	DATE,
		  x_to_date			IN	DATE,
		  x_request_id			IN	NUMBER);

END pa_gl_rev_xfer_audit_pkg;

 

/
