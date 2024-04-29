--------------------------------------------------------
--  DDL for Package CE_JE_CREATION_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_JE_CREATION_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: cejecers.pls 120.0 2005/04/11 19:37:59 bhchung noship $ */

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.0 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE Insert_Row(X_statement_header_id            NUMBER,
		       X_statement_line_id            	NUMBER,
                       X_message_name			VARCHAR2,
			   X_created_by		NUMBER,
			   X_creation_date 	DATE,
			   X_last_update_date	DATE,
			   X_last_updated_by	NUMBER,
			   X_last_update_login	NUMBER,
			   X_request_id		NUMBER);

  PROCEDURE Insert_Row(X_statement_header_id            NUMBER,
		       X_statement_line_id		NUMBER,
                       X_message_name			VARCHAR2,
			   X_request_id		NUMBER,
                       X_application_short_name		VARCHAR2);

  PROCEDURE Delete_Row( X_statement_header_id 		NUMBER,
			X_statement_line_id   		NUMBER);

END CE_JE_CREATION_ERRORS_PKG;

 

/
