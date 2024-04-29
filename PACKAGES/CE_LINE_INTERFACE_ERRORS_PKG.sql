--------------------------------------------------------
--  DDL for Package CE_LINE_INTERFACE_ERRORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_LINE_INTERFACE_ERRORS_PKG" AUTHID CURRENT_USER as
/* $Header: celintes.pls 120.1 2002/11/12 21:20:19 bhchung ship $ */
  G_spec_revision 	VARCHAR2(1000) := '$Revision: 120.1 $';

  FUNCTION spec_revision RETURN VARCHAR2;

  FUNCTION body_revision RETURN VARCHAR2;
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_statement_number               VARCHAR2,
                       X_bank_account_num		VARCHAR2,
		       X_line_number			NUMBER,
                       X_message_name			VARCHAR2);

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_statement_number               VARCHAR2,
                       X_bank_account_num		VARCHAR2,
		       X_line_number			NUMBER,
                       X_message_name			VARCHAR2,
		       X_application_short_name		VARCHAR2);

  PROCEDURE Delete_Row(X_statement_number VARCHAR2,
		       X_bank_account_num VARCHAR2,
		       X_line_number	  NUMBER);

END CE_LINE_INTERFACE_ERRORS_PKG;

 

/
