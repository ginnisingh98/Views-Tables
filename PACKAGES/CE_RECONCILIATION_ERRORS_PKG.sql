--------------------------------------------------------
--  DDL for Package CE_RECONCILIATION_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_RECONCILIATION_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: cerecers.pls 120.0 2002/08/24 02:37:29 appldev noship $ */

  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.0 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;

  PROCEDURE Insert_Row(X_statement_header_id            NUMBER,
		       X_statement_line_id            	NUMBER,
                       X_message_name			VARCHAR2);

  PROCEDURE Insert_Row(X_statement_header_id            NUMBER,
		       X_statement_line_id		NUMBER,
                       X_message_name			VARCHAR2,
                       X_application_short_name		VARCHAR2);

  PROCEDURE Delete_Row( X_statement_header_id 		NUMBER,
			X_statement_line_id   		NUMBER);

END CE_RECONCILIATION_ERRORS_PKG;

 

/
